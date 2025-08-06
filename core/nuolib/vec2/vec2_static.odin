package Vec2


from_angle :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	dt : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&dt) ,"'from_angle' expects %v, but got %v and must be 'number'.",1,cs.argc) do return	
	v := _from_angle(dt)

	VECTOR2_VAL_PTR(cs.result,&v)
}


from_circle :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	values : [2]Float

	for i in 0..< 2 do if ctx.runtime_error(cs.argc == 2 && IS_NUMERIC_PTR(ctx.peek_value(i),&values[i]) ,"'from_circle' expects %v, but got %v and must be 'number' and 'number'.",2,cs.argc) do return	
	
	v := _from_circle(values[0],values[1])
	VECTOR2_VAL_PTR(cs.result,&v)
}

random_unit :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'random_unit' expects %v, but got %v.",0,cs.argc) do return	

	v := _rand()
	VECTOR2_VAL_PTR(cs.result,&v)
}