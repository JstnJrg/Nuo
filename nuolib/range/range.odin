package Range


length :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'length' expects %v, but got %v.",0,cs.argc) do return	

	range := AS_NUOOBECT_PTR(ctx.peek_value(0),Range)
	FLOAT_VAL_PTR(cs.result,_get_length(range))
}

step :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0)),"'step' expects %v, but got %v and must be 'number'.",1,cs.argc) do return	

	range          := AS_NUOOBECT_PTR(ctx.peek_value(1),Range)   
	zero,direction := _check(range,ctx)

	if ctx.runtime_error(zero,"'step' cannot be zero.") do return
	if ctx.runtime_error(direction,"'step' is incompatible with the direction of the range.") do return

	from,to,step := _values(range)
	rrange       := create_range(from,to,true)

	_set_step(rrange,ctx.peek_value(0))
	_set_length(rrange,ctx)

	NUOOBJECT_VAL_PTR(cs.result,rrange)
}

contains :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0)),"'contains' expects %v, but got %v and must be 'number'.",1,cs.argc) do return	

	range        := AS_NUOOBECT_PTR(ctx.peek_value(1),Range)   
	BOOL_VAL_PTR(cs.result,_contains(range,ctx.peek_value(0),ctx))
}

at :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.INT),"'at' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.INT)) do return	

	range        := AS_NUOOBECT_PTR(ctx.peek_value(1),Range)   
	_at(range,ctx.peek_value(0),ctx)
}

reverse :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'reverse' expects %v, but got %v.",0,cs.argc) do return	

	range        := AS_NUOOBECT_PTR(ctx.peek_value(0),Range)   

	from,to,step := _values(range)
	rrange       := create_range(from,to,true)
	_set_step(rrange,step)

	_reverse(rrange,ctx)
	NUOOBJECT_VAL_PTR(cs.result,rrange)
}

first :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'first' expects %v, but got %v.",0,cs.argc) do return	

	range        := AS_NUOOBECT_PTR(ctx.peek_value(0),Range)   
	from,_,_     := _values(range)
	VARIANT2VARIANT_PTR(from,cs.result)
}

to_array :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'to_array' expects %v, but got %v.",0,cs.argc) do return	

	range        := AS_NUOOBECT_PTR(ctx.peek_value(0),Range)   
	_to_array(range,ctx)
}



last :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'last' expects %v, but got %v.",0,cs.argc) do return	

	range        := AS_NUOOBECT_PTR(ctx.peek_value(0),Range)   
	_,to,_       := _values(range)
	VARIANT2VARIANT_PTR(to,cs.result)
}

