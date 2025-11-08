package Complex


from_polar :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	p  : Float
	m  : Float

	if ctx.runtime_error(cs.argc == 2 && IS_NUMERIC_PTR(ctx.peek_value(0),&m) && IS_NUMERIC_PTR(ctx.peek_value(1),&p) ,"'from_polar' expects %v, but got %v and must be 'float' and 'float'.",2,cs.argc) do return	
	
	z := _from_polar(m,p)
	COMPLEX_VAL_PTR(cs.result,&z)
}