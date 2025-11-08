package Color


get_luminance :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'get_luminance' expects %v, but got %v.",0,cs.argc) do return	

	color := REINTERPRET_MEM_PTR(ctx.peek_value(0),Color)
	r     := _luminance(color)

	INT_VAL_PTR(cs.result,int(r))
}

invert :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'invert' expects %v, but got %v.",0,cs.argc) do return	

	color := REINTERPRET_MEM_PTR(ctx.peek_value(0),Color)
	c     := _invert(color)

	COLOR_VAL_PTR(cs.result,&c)
}

darkened      :: proc(ctx: ^Context)
{
	cs     := ctx.call_state
	amount : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&amount),"'darkened' expects %v, but got %v and must be 'number'.",1,cs.argc) do return	

	color := REINTERPRET_MEM_PTR(ctx.peek_value(1),Color)
	c     := _darkened(color,amount)

	COLOR_VAL_PTR(cs.result,&c)
}

lightened :: proc(ctx: ^Context)
{
	cs     := ctx.call_state
	amount : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&amount),"'lightened' expects %v, but got %v and must be 'number'.",1,cs.argc) do return	

	color := REINTERPRET_MEM_PTR(ctx.peek_value(1),Color)
	c     := _lightened(color,amount)

	COLOR_VAL_PTR(cs.result,&c)
}

lerp     :: proc(ctx: ^Context)
{
	cs     := ctx.call_state
	amount : Float

	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.COLOR) && IS_NUMERIC_PTR(ctx.peek_value(1),&amount),"'lerp' expects %v, but got %v and must be '%v' and 'number'.",2,cs.argc,GET_TYPE_NAME(.COLOR)) do return	

	color0 := REINTERPRET_MEM_PTR(ctx.peek_value(1),Color)
	color  := REINTERPRET_MEM_PTR(ctx.peek_value(0),Color)
	c      := _lerp(color0,color,amount)

	COLOR_VAL_PTR(cs.result,&c)
}

blend     :: proc(ctx: ^Context)
{
	cs      := ctx.call_state

	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.COLOR),"'blend' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.COLOR)) do return	

	color_a := REINTERPRET_MEM_PTR(ctx.peek_value(1),Color)
	color_b := REINTERPRET_MEM_PTR(ctx.peek_value(0),Color)
	c       := _blend(color_a,color_b)

	COLOR_VAL_PTR(cs.result,&c)
}


