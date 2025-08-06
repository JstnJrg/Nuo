package Variant

@(private="file")
Free :: struct
{
	obj   : ^NuoObject,
	count : int,
	max   : int
}

@(private="file")
GC :: struct
{
	frees : [VariantType]Free,
	obj   : ^NuoObject
}

@(private="file") _gc : GC




ref_value   :: proc (value: ^Value)
{
	if value.type < .OBJ do return
	obj := AS_NUOOBECT_PTR(value)
	obj.ref_count += 1

	// when NUO_DEBUG do printfln("[NUO GC] ->  '%v' | '%v' ",obj.ref_count,obj.type)
}

ref_value_costum :: proc (value: ^Value, offset: int)
{
	if value.type < .OBJ do return
	obj := AS_NUOOBECT_PTR(value)
	obj.ref_count += offset

	// when NUO_DEBUG do printfln("[NUO GC] ->  '%v' | '%v' ",obj.ref_count,obj.type)
}

unref_value :: proc (value: ^Value)
{
	if value.type < .OBJ do return
	
	obj := AS_NUOOBECT_PTR(value)
	obj.ref_count -= 1

	if obj.ref_count <= 0 
	{
		when NUO_DEBUG do printfln("[NUO GC] ->  '%v' | '%v' ",obj.ref_count,obj.type)
		gc_free_obj_with_dependencies(obj)
	}
}

unref_value_costum :: proc (value: ^Value, offset: int)
{
	if value.type < .OBJ do return
	
	obj := AS_NUOOBECT_PTR(value)
	obj.ref_count -= offset

	if obj.ref_count <= 0 
	{
		when NUO_DEBUG do printfln("[NUO GC] ->  '%v' | '%v' ",obj.ref_count,obj.type)
		gc_free_obj_with_dependencies(obj)
	}
}


ref_object  :: proc (obj: ^NuoObject)
{
	obj.ref_count += 1
	// when NUO_DEBUG do printfln("[NUO GC] ->  '%v' | '%v' ",obj.ref_count,obj.type)
}

unref_object :: proc (obj: ^NuoObject)
{
	obj.ref_count -= 1

	if obj.ref_count <= 0 
	{
		when NUO_DEBUG do printfln("[NUO GC] ->  '%v' | '%v' ",obj.ref_count,obj.type)
		gc_free_obj_with_dependencies(obj)
	}
}


ref_slice_costum    :: proc (s: []Value, offset: int) { for &value in s do ref_value_costum(&value,offset) }

ref_slice    :: proc (s: []Value) { for &value in s do ref_value(&value) }

unref_slice  :: proc (s: []Value) { for &value in s { unref_value(&value) }}
unref_table  :: proc (t: ^Table) { for _,&value_p in t do unref_value(&value_p) }
unref_map    :: proc (t: ^map[u32]MapEntry) { for _,&mk in t { unref_value(&mk.key); unref_value(&mk.value) } }



gc_free_obj_with_dependencies :: proc(obj: ^NuoObject)
{
	#partial switch obj.type
	{
		case .STRING:
			
			obj_s := reinterpret_object(obj,NuoString)

			// Nota(jstn): vivem durante toda execução
			if obj_s.static { obj_s.ref_count = 1e9; return }

			gc_remove_from_list(obj); if gc_set_in_free_list(obj) do return
			gc_free_object(obj)
			// obj_string := reinterpret_object(NuoString)

		case .INSTANCE:

			obj_instance   := reinterpret_object(obj,NuoInstance)
			method, sucess := class_db_get_deinit_method(obj_instance)

			if sucess
			{
				/*
					Nota(jstn): o ref_count é 2, para evitar recursão infinita, pois this é uma variavel
					local e éremovido no final do escopo ao chamar a função _deinit.

					Se ao sair de _deinit o ref_count for 1, então não houve nenhum objecto que fez referencia a instancia,
					caso contario, houve.

					E atenção, para ofunction esse unref para garantir o valor 1, é responsabilidade do provedor
					do metodo, caso não, haverá vazamento de memoria.


					Bugs: não checa o valor valor do ponteiro do call frame. Então pode se estourar a pilha
					de chamada ao chamar o _deinit.

				*/
				obj_instance.ref_count = 2 // 1 do scopo e 1 para sobreviver no final

				ctx            := get_context()
				instance_value := NUOOBJECT_VAL(obj_instance)

				ctx.push_value(&instance_value)
				ctx.vm_exit(1)
					
				// Nota(jstn): erro, caso seja verdade.
				if ctx.call(&method,0,1) do return

				ctx.vm_exit(-1)
				ctx.pop_value() // O valor nil da pilha

				// Nota(jstn): 
				ctx.runtime_assert(obj_instance.ref_count != 0,"_deinit, ref_count reach zero ? Oops it's a bug.")


				// Nota(jstn): caso seja diferente de 1, então existe mais uma referencia a esse objecto
				// então removemos a nossa referencia (+1)
				if obj_instance.ref_count != 1 { obj_instance.ref_count -= 1; return }
			}

			unref_table(&obj_instance.fields)

			gc_remove_from_list(obj)
			if gc_set_in_free_list(obj) do return
			
			gc_free_object(obj)

	    case .ARRAY:
	    	
	    	_obj := reinterpret_object(obj,NuoArray)
	    	unref_slice(_obj.data[:])

			gc_remove_from_list(obj)
			if gc_set_in_free_list(obj) do return
			
			gc_free_object(obj)

	    case .MAP:
	    	
	    	_obj := reinterpret_object(obj,NuoMap)
	    	unref_map(&_obj.data)

			gc_remove_from_list(obj)
			if gc_set_in_free_list(obj) do return
			
			gc_free_object(obj)

	    case .SIGNAL:
	    	
	    	_obj := reinterpret_object(obj,NuoSignal)
			gc_remove_from_list(obj)

			if gc_set_in_free_list(obj) do return
			gc_free_object(obj)


		// BUFFER

		case .ANY        : fallthrough
		case .RANGE      : fallthrough
		case .TRANSFORM2D: 

			gc_remove_from_list(obj)
			if gc_set_in_free_list(obj) do return
			gc_free_object(obj)

	}

}


gc_set_max :: proc "contextless" (type: VariantType, amount: int) { _gc.frees[type].max = amount } 
gc_begin   :: proc "contextless" (obj: ^NuoObject)   { _gc.obj = obj }

gc_set_in_free_list :: proc "contextless" (obj: ^NuoObject ) -> bool 
{
	f := &_gc.frees[obj.type]

	if f.count < f.max
	{
		obj.next      = nil
		obj.prev      = nil
		obj.ref_count = 1

		obj.next      = f.obj
		f.obj         = obj

		f.count += 1

		return true
	}

	return false
}

gc_peek_from_frees :: #force_inline proc "contextless" (type: VariantType) -> (bool, ^NuoObject) 
{
	f := &_gc.frees[type]

	if f.count > 0 
	{
		obj      := f.obj
		f.obj     = obj.next
		f.count  -= 1

		obj.next  = _gc.obj
		obj.prev  = nil

		if _gc.obj != nil do _gc.obj.prev = obj
		_gc.obj = obj

		return true, obj
	}

	return false,nil
}


gc_clear_frees :: proc()
{

	for &f in _gc.frees
	{
		aux := f.obj
		for aux != nil 
		{ 
			u := aux.next
			gc_free_object(aux)
			aux = u
		}
	}
}

gc_free_list    :: proc() 
{ 
	aux  := _gc.obj
	for aux != nil 
	{ 
	   u := aux.next
	   gc_free_object(aux)
	   aux = u
	}

	gc_begin(nil)
	gc_debug()
}

gc_end :: proc()
{
	gc_clear_frees()
	gc_free_list()
}


gc_set_in_list :: proc "contextless" (obj: ^NuoObject)
{
	obj.next = _gc.obj
	obj.prev = nil

	if _gc.obj != nil do _gc.obj.prev = obj
	_gc.obj = obj
}

gc_remove_from_list :: proc "contextless" (obj: ^NuoObject)
{
	if obj == nil do return

	prev := obj.prev
	next := obj.next

	if prev != nil do prev.next = next
	else do _gc.obj = next

	if next != nil do next.prev = prev

	// if SET_IN_FREE_LIST(obj) do return
	// free_object(obj)
}


gc_clear_obj_data :: proc(obj: ^NuoObject)
{
	obj.ref_count = 1

	#partial switch obj.type
	{
		case .STRING:
			_obj := reinterpret_object(obj,NuoString)
			builder_reset(&_obj.data)

	    case .INSTANCE:
	    	_obj := reinterpret_object(obj,NuoInstance)
	    	clear(&_obj.fields)
	    	_obj.cid = -1

	    case .ARRAY:
	    	_obj := reinterpret_object(obj,NuoArray)
	    	clear(&_obj.data)
	    	shrink(&_obj.data,8)

	    case .SIGNAL:
	    	_obj     := reinterpret_object(obj,NuoSignal)
	    	clear(&_obj.data)
	    	shrink(&_obj.data,8)

	    case .MAP:
	    	_obj := reinterpret_object(obj,NuoMap)
	    	clear(&_obj.data)

	    // byuffer
	    case .TRANSFORM2D:
	    	_obj := reinterpret_object(obj,Transform2D)
	    	_obj.data = mat2x3{}


	    // case .OBJ_ANY:
	    // 	object_p      := (^Any)(obj)
	    // 	object_p.etype = .NONE_VAL
	    // 	object_p.id    = -1
	 }
}



gc_free_object :: proc(obj: ^NuoObject)
{
	#partial switch obj.type
	{
		case .STRING:
			
			obj_string := reinterpret_object(obj,NuoString)
			builder_destroy(&obj_string.data)
			free(obj_string)

		case .INSTANCE:

			obj_instance := reinterpret_object(obj,NuoInstance)
			delete(obj_instance.fields)
			free(obj_instance)

		case .ARRAY:

			obj_array := reinterpret_object(obj,NuoArray)
			delete(obj_array.data)
			free(obj_array)

		case .SIGNAL:

			obj_signal := reinterpret_object(obj,NuoSignal)
			delete(obj_signal.data)
			free(obj_signal)

		case .MAP:

			obj_map := reinterpret_object(obj,NuoMap)
			delete(obj_map.data)
			free(obj_map)


		case .ANY        : fallthrough
		case .RANGE      : fallthrough
		case .TRANSFORM2D: memfree(obj)
		
	}

}





gc_debug :: proc()
{
	// when NUO_DEBUG && NUO_DEBUG_GC
	// {
	// 	      printfln("================ [GC DEBUG] ================")
	// 	defer printfln("============================================")
		
	// 	for t in VariantType
	// 	{
	// 		f := &_gc.frees[t]
	// 		printfln("TYPE: '%v'\nCOUNT: '%v'\nMAX: '%v'",t,f.count,f.max)
	// 	}
	// }
}


