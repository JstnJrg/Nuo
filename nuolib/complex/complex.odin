package Complex


conj :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'conjugate' expects %v, but got %v.",0,cs.argc) do return	

	z  := REINTERPRET_MEM_PTR(ctx.peek_value(0),Complex)
	zr := Complex{z.x,-z.y}

	COMPLEX_VAL_PTR(cs.result,&zr)
}

module :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'abs' expects %v, but got %v.",0,cs.argc) do return	

	z  := REINTERPRET_MEM_PTR(ctx.peek_value(0),Complex)
	FLOAT_VAL_PTR(cs.result,_module(z))
}

arg :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'arg' expects %v, but got %v.",0,cs.argc) do return	

	z  := REINTERPRET_MEM_PTR(ctx.peek_value(0),Complex)
	FLOAT_VAL_PTR(cs.result,_arg(z))
}

pow :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.INT),"'pow' expects %v, but got %v and must be 'int'.",1,cs.argc) do return	

	n  := AS_INT_PTR(ctx.peek_value(0))
	z  := REINTERPRET_MEM_PTR(ctx.peek_value(1),Complex)

	zr := _pow(z,n)
	COMPLEX_VAL_PTR(cs.result,&zr)
}