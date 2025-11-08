package Map



has :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 1,"'has' expects %v, but got %v.",1,cs.argc) do return

	_map  := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoMap)
	data  := &_map.data

   BOOL_VAL_PTR(cs.result,variant_hash(ctx.peek_value(0)) in data)  
}


size :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'size' expects %v, but got %v.",0,cs.argc) do return	

	_map  := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoMap)
	data  := &_map.data

	INT_VAL_PTR(cs.result,len(data))
}

is_empty :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'is_empty' expects %v, but got %v.",0,cs.argc) do return	

	_map  := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoMap)
	data  := &_map.data

	BOOL_VAL_PTR(cs.result,len(data) == 0)
}

values :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'values' expects %v, but got %v.",0,cs.argc) do return	

	_map   := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoMap)
	data_m := &_map.data

	array  := create_obj_array()
	data_r := &array.data


	for _,&me in data_m
	{
		ref_value(&me.value)
		append(data_r,me.value)
	}

	NUOOBJECT_VAL_PTR(cs.result,array)
}

keys :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'keys' expects %v, but got %v.",0,cs.argc) do return	

	_map   := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoMap)
	data_m := &_map.data

	array  := create_obj_array()
	data_r := &array.data


	for _,&me in data_m
	{
		ref_value(&me.key)
		append(data_r,me.key)
	}

	NUOOBJECT_VAL_PTR(cs.result,array)
}

_clear :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'clear' expects %v, but got %v.",0,cs.argc) do return	

	_map   := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoMap)
	data_m := &_map.data

	for _,&me in data_m
	{
		unref_value(&me.value)
		unref_value(&me.key)
	}

	clear(data_m)
	NIL_VAL_PTR(cs.result)
}


erase :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1,"'erase' expects %v, but got %v.",1,cs.argc) do return	

	_map   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoMap)
	data_m := &_map.data

    hash   := variant_hash(ctx.peek_value(0))

	if hash in data_m
	{	
		_, deleted_value := delete_key(data_m,hash)	

		unref_value(&deleted_value.value)
		unref_value(&deleted_value.key)
	}

	NIL_VAL_PTR(cs.result)
}