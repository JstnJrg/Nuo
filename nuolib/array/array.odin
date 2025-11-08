package Array

size :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'size' expects %v, but got %v.",0,cs.argc) do return	

	array := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoArray)
	INT_VAL_PTR(cs.result,_len(&array.data))
}

shuffle :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'shuffle' expects %v, but got %v.",0,cs.argc) do return	

	array := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoArray)

    _shuffle(&array.data)
	NIL_VAL_PTR(cs.result)
}

_clear :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'clear' expects %v, but got %v.",0,cs.argc) do return	

	array := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoArray)
	data  := &array.data

    unref_slice(data[:])
    __clear(data)

	NIL_VAL_PTR(cs.result)
}


resize_ :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.INT),"'resize' expects %v, but got %v, and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.INT)) do return	

	amount := AS_INT_PTR(ctx.peek_value(0))
	if amount < 0 
	{ 
		ctx.runtime_warning(false,"'resize' condition p_size < 0 is true.")
	    BOOL_VAL_PTR(cs.result,false) 
	    return
	}

	array  := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoArray)
	data   := &array.data
	size   := _len(data)
	sucess := true

	if amount > size
	{
		offset := amount-size
		sucess  = _resize(data,amount)

		for i in 0..<offset do NIL_VAL_PTR(&data[size+i])
	}
	else if size > amount
	{
		offset := size-amount
		unref_slice(data[size-offset:])
		sucess  = _resize(data,amount)
	}

	BOOL_VAL_PTR(cs.result, sucess )
}

choice :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'choice' expects %v, but got %v.",0,cs.argc) do return

	array  := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoArray)
	data   := &array.data

	_choice(data,cs.result)
	ref_value(cs.result)
}

append_ :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	argc  := cs.argc
	
	if ctx.runtime_error(cs.argc > 0,"'append' expects over 0 arguments.") do return

	array  := AS_NUOOBECT_PTR(ctx.peek_value(argc),NuoArray)
	data   := &array.data
	what   := cs.args[0:][:argc]

	ref_slice(what)
	_append(data,what)

	NIL_VAL_PTR(cs.result)
}


append_array :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.ARRAY),"'append_array' expects %v, but got %v and must be a '%v'.",1,cs.argc,GET_TYPE_NAME(.ARRAY)) do return

	array0  := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoArray)
	data0   := &array0.data
	
	array1  := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoArray)
	data1   := &array1.data

	ref_slice(data0[:])
	_append(data1,data0[:])

	NIL_VAL_PTR(cs.result)
}




// /*
//     Nota(jstn): não diminuímos seu rc, pois é responsabilidade 
//     de quem vai receber diminuir, caso não for recebido, a VM
//     vai diminuir, quem receber, vai ganhar a responsabilidade
//     , ou seja, o rc será transferido.

//     Poderiamos diminuir o rc do array e incrementar, de quem vai receber.
//     No final será mesma coisa que manter intacto. 

// */
pop_back :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'pop_back' expects %v, but got %v.",0,cs.argc) do return

	array  := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoArray)
	data   := &array.data

	last,_ := pop_safe(data)
    VARIANT2VARIANT_PTR(&last,cs.result)
}

pop_front :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'pop_front' expects %v, but got %v.",0,cs.argc) do return

	array   := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoArray)
	data    := &array.data

    first,_ := pop_front_safe(data)
    VARIANT2VARIANT_PTR(&first,cs.result)
}


qsort :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'qsort' expects %v, but got %v.",0,cs.argc) do return

	array   := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoArray)
	data    := &array.data
    size    := len(data)-1

    if size <= 0 { NIL_VAL_PTR(cs.result); return }

          ctx.disable_gc()
    defer ctx.enable_gc()

          ctx.trace_error(false)
    defer ctx.trace_error(true)

    _quick_sort(data,cs.result,0,size,ctx)
	NIL_VAL_PTR(cs.result)
}

sort_costum :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_CALLABLE_PTR(ctx.peek_value(0)),"'sort_costum' expects %v, but got %v and must be 'Callable'.",1,cs.argc) do return

	array   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoArray)
	data    := &array.data
    size    := len(data)

    if size <= 0 { NIL_VAL_PTR(cs.result); return }

    fn    := ctx.peek_value(0)
    args  : [1]Value

    // Nota(jstn): precisamos restaurar a pilha
  
    ctx.copy_args(cs.args[0:],args[:],1)
    defer 
    {
    	cs.args = cs.args[0:][:0] // garantimos que não aconteca unref duas vezes
    	unref_slice(args[:])
    }

     _shell_sort_costum(data,fn,ctx)
	NIL_VAL_PTR(cs.result)
}


map_ :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_CALLABLE_PTR(ctx.peek_value(0)),"'map' expects %v, but got %v and must be 'Callable'.",1,cs.argc) do return

	array   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoArray)
	data    := &array.data
  size    := len(data)

    array1  := create_obj_array()
    data1   := &array1.data

    if size <= 0 { NUOOBJECT_VAL_PTR(cs.result,array1); return }

    args  : [1]Value

    // Nota(jstn): precisamos restaurar a pilha, _reduce pode evoncar um metodo
    // que evoca um constructor, então, cs.args estará alterado, então, poderá ser 
    // um slice de comprimento zero, então a responsabilidade de unref será do metodo aqui.
  
    ctx.copy_args(cs.args[0:],args[:],1)
    defer 
    {
    	cs.args = cs.args[0:][:0] // garantimos que não aconteca unref duas vezes
    	unref_slice(args[:])
    }
     
    _map(data,data1,ctx)
	NUOOBJECT_VAL_PTR(cs.result,array1)
}


filter :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_CALLABLE_PTR(ctx.peek_value(0)),"'filter' expects %v, but got %v and must be 'Callable'.",1,cs.argc) do return

	array   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoArray)
	data    := &array.data
    size    := len(data)

    array1  := create_obj_array()
    data1   := &array1.data

    if size <= 0 { NUOOBJECT_VAL_PTR(cs.result,array1); return }
    
    args  : [1]Value

    // Nota(jstn): precisamos restaurar a pilha, como o callable
    // retorna true/false, então é garantido um cs.argc igual no minimo a
    //  1.
  
    ctx.copy_args(cs.args[0:],args[:],1)
    defer 
    {
    	cs.args = cs.args[0:][:0]
    	unref_slice(args[:])
    }
     
    _filter(data,data1,ctx)
	NUOOBJECT_VAL_PTR(cs.result,array1)
}

reduce :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 2 && IS_CALLABLE_PTR(ctx.peek_value(0)),"'reduce' expects %v, but got %v and must be 'Callable' and 'Variant'.",2,cs.argc) do return

	array   := AS_NUOOBECT_PTR(ctx.peek_value(2),NuoArray)
	data    := &array.data
  size    := len(data)

    if size <= 0 { NIL_VAL_PTR(cs.result); return }

    args  : [3]Value

    // Nota(jstn): precisamos restaurar a pilha, _reduce pode evoncar um metodo
    // que evoca um constructor, então, cs.args estará alterado, então, poderá ser 
    // um slice de comprimento zero, então a responsabilidade de unref será do metodo aqui.
  
    ctx.copy_args(cs.args[:],args[:],3)
    defer 
    {
    	cs.args = cs.args[0:][:0] // garantimos que não aconteca unref duas vezes
    	unref_slice(args[:])
    }
     
    _reduce(data,ctx)
}


for_each :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_CALLABLE_PTR(ctx.peek_value(0)),"'for_each' expects %v, but got %v and must be 'Callable'.",1,cs.argc) do return

	array   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoArray)
	data    := &array.data
  size    := len(data)

    if size <= 0 { NIL_VAL_PTR(cs.result); return }
    
    args  : [1]Value

    // Nota(jstn): precisamos restaurar a pilha, como o callable
    // retorna true/false, então é garantido um cs.argc igual no minimo a
    //  1.
          ctx.copy_args(cs.args[0:],args[:],1)
    defer 
    {
    	cs.args = cs.args[0:][:0]
    	unref_slice(args[:])
    }
     
    _for_each(data,ctx)
	NIL_VAL_PTR(cs.result)
}


ssort :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'ssort' expects %v, but got %v.",0,cs.argc) do return

	array   := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoArray)
	data    := &array.data
    size    := len(data)-1

    if size <= 0 { NIL_VAL_PTR(cs.result); return }

          ctx.disable_gc()
    defer ctx.enable_gc()

          ctx.trace_error(false)
    defer ctx.trace_error(true)

    _shell_sort(data,cs.result,ctx)
	NIL_VAL_PTR(cs.result)
}

find :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 1,"'find' expects %v, but got %v.",1,cs.argc) do return

	array  := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoArray)
	data   := &array.data
	len    := len(data)

    if len == 0 
    { 
    	INT_VAL_PTR(cs.result,-1)
    	return 
    }
          ctx.disable_gc()
    defer ctx.enable_gc()

          ctx.trace_error(false)
    defer ctx.trace_error(true)

    idx := _binary(data,ctx.peek_value(0),cs.result,ctx)
    INT_VAL_PTR(cs.result,idx)
}

find_costum :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_CALLABLE_PTR(ctx.peek_value(0)),"'find_costum' expects %v, but got %v and must be 'Callable'.",1,cs.argc) do return

	array  := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoArray)
	data   := &array.data
	len    := len(data)

    if len <= 0 { INT_VAL_PTR(cs.result,-1); return }

    args  : [1]Value
  
    ctx.copy_args(cs.args[0:],args[:],1)
    defer 
    {
    	cs.args = cs.args[0:][:0] // garantimos que não aconteca unref duas vezes
    	unref_slice(args[:])
    }

    INT_VAL_PTR(cs.result,_binary_costum(data,ctx))
}


fill :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 1,"'fill' expects %v, but got %v.",1,cs.argc) do return

	array  := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoArray)
	data   := &array.data
	len    := len(data)
	
	// Nota(jstn): antigo conteúdo
	unref_slice(data[:])
	e := ctx.peek_value(0)
    
    for i in 0..<len { VARIANT2VARIANT_PTR(e,&data[i]); ref_value(e) }
    NIL_VAL_PTR(cs.result)
}


count :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 1,"'count' expects %v, but got %v.",1,cs.argc) do return

	array  := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoArray)
	data   := &array.data

          ctx.disable_gc()
    defer ctx.enable_gc()
 
    INT_VAL_PTR(cs.result,_equal_count(data,ctx.peek_value(0),ctx))
}

has :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 1,"'has' expects %v, but got %v.",1,cs.argc) do return

	array  := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoArray)
	data   := &array.data

          ctx.disable_gc()
    defer ctx.enable_gc()

          ctx.trace_error(false)
    defer ctx.trace_error(true)

   BOOL_VAL_PTR(cs.result,_equal_count(data,ctx.peek_value(0),ctx,1) != 0 )  
}

reverse :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'reverse' expects %v, but got %v.",0,cs.argc) do return

	array   := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoArray)
	data    := &array.data

    _reverse(data,len(data))
    NIL_VAL_PTR(cs.result)
}

