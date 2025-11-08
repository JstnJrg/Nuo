package Variant


NuoObject :: struct
{
	next     : ^NuoObject,
	prev     : ^NuoObject,

	ref_count: int,
	type     : VariantType,
}

NuoString :: struct
{
	using _    : NuoObject,
	data       : Builder,
	static     : bool
} 

NuoArray :: struct 
{
	using _    : NuoObject,
	data 	   : [dynamic]Value
}

MapEntry :: struct
{
	key   : Value,
	value : Value
}


NuoMap :: struct 
{
	using _    : NuoObject,
	data 	   : map[u32]MapEntry
}

NuoCallable :: struct 
{
	using _    : NuoObject,
	args 	   : [dynamic]Value,
	callable   : Value,
	callee     : Value,
}


NuoInstance :: struct
{
	using _    : NuoObject,
	fields	   : Table,
	cid        : int
}

NuoSignal :: struct 
{
	using _    : NuoObject,
	data 	   : [dynamic]Value
} 

NuoTask   :: struct
{
	using _    : NuoObject,
	task       : ^Task,
	callable   : Value
}



reinterpret_object    :: #force_inline proc "contextless" (obj: ^NuoObject, $T: typeid) -> ^T { return (^T)(obj) }  
nuostring_write_data  :: #force_inline proc (data: string, obj: ^NuoObject) 
{
	nuo_str := reinterpret_object(obj,NuoString)
	builder_write_string(&nuo_str.data,data)
}




create_object :: #force_inline proc($T: typeid, type: VariantType, allocator := context.allocator) -> ^T
{
	obj          := new(T,allocator)
	obj.type      = type
	obj.ref_count = 1
	gc_set_in_list(obj)

	return obj
}

create_obj_instance :: proc(cid: int) -> ^NuoInstance
{
	if has, _obj := gc_peek_from_frees(.INSTANCE); has 
	{
		obj     := reinterpret_object(_obj,NuoInstance)
		gc_clear_obj_data(_obj)
		
		obj.cid  = cid
		return obj
	}

	obj       := create_object(NuoInstance,.INSTANCE)
	obj.cid    = cid
	return obj
}

create_obj_array :: proc() -> ^NuoArray
{
	if has, _obj := gc_peek_from_frees(.ARRAY); has 
	{
		obj     := reinterpret_object(_obj,NuoArray)
		gc_clear_obj_data(_obj)
		return obj
	}

	obj       := create_object(NuoArray,.ARRAY)
	return obj
}


create_obj_callable :: proc() -> ^NuoCallable
{
	if has, _obj := gc_peek_from_frees(.CALLABLE); has 
	{
		obj     := reinterpret_object(_obj,NuoCallable)
		gc_clear_obj_data(_obj)
		return obj
	}

	obj       := create_object(NuoCallable,.CALLABLE)
	return obj
}


create_obj_signal :: proc() -> ^NuoSignal
{
	if has, _obj := gc_peek_from_frees(.SIGNAL); has 
	{
		obj     := reinterpret_object(_obj,NuoSignal)
		gc_clear_obj_data(_obj)
		return obj
	}

	obj       := create_object(NuoSignal,.SIGNAL)
	return obj
}

create_obj_string_literal :: proc(data: string, static := false ) -> ^NuoString
{

	if has, _obj := gc_peek_from_frees(.STRING); has 
	{
		obj         := reinterpret_object(_obj,NuoString)
		gc_clear_obj_data(_obj)

		obj.static   = static
		builder_write_string(&obj.data,data)

		return obj
	}

	obj       := create_object(NuoString,.STRING)
	obj.static = static
	
	builder_write_string(&obj.data,data)
	return obj
}

create_obj_string :: proc() -> ^NuoString
{

	if has, _obj := gc_peek_from_frees(.STRING); has 
	{
		obj         := reinterpret_object(_obj,NuoString)
		gc_clear_obj_data(_obj)
		return obj
	}

	obj       := create_object(NuoString,.STRING)
	return obj
}


create_obj_map :: proc() -> ^NuoMap
{
	if has, _obj := gc_peek_from_frees(.MAP); has 
	{
		obj     := reinterpret_object(_obj,NuoMap)
		gc_clear_obj_data(_obj)
		return obj
	}

	obj       := create_object(NuoMap,.MAP)
	return obj
}


create_obj_task :: proc() -> ^NuoTask
{
	if has, _obj := gc_peek_from_frees(.TASK); has 
	{
		obj     := reinterpret_object(_obj,NuoTask)
		gc_clear_obj_data(_obj)
		return obj
	}

	obj       := create_object(NuoTask,.TASK)
	return obj
}