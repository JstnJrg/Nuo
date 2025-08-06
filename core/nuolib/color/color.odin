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
	c     := _darkened(color,&amount)

	COLOR_VAL_PTR(cs.result,&c)
}

lightened :: proc(ctx: ^Context)
{
	cs     := ctx.call_state
	amount : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&amount),"'lightened' expects %v, but got %v and must be 'number'.",1,cs.argc) do return	

	color := REINTERPRET_MEM_PTR(ctx.peek_value(1),Color)
	c     := _lightened(color,&amount)

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























// abs :: proc(ctx: ^Context) 
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 0,"'abs' expects %v, but got %v.",0,cs.argc) do return	

// 	r0 := REINTERPRET_MEM_PTR(ctx.peek_value(0),Rect2)
// 	r  : Rect2

// 	_abs(r0,&r)
// 	RECT2_VAL_PTR(cs.result,&r)
// }

// distance_to :: proc(ctx: ^Context) 
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'distance_to' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

// 	r0 := REINTERPRET_MEM_PTR(ctx.peek_value(1),Rect2)
// 	v  := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)

// 	d   : Float

// 	_distance_to(r0,v,&d)
// 	FLOAT_VAL_PTR(cs.result,d)
// }

// encloses :: proc(ctx: ^Context) 
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.RECT2),"'encloses' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.RECT2)) do return	

// 	r0 := REINTERPRET_MEM_PTR(ctx.peek_value(1),Rect2)
// 	r1 := REINTERPRET_MEM_PTR(ctx.peek_value(0),Rect2)

// 	BOOL_VAL_PTR(cs.result,_encloses(r0,r1))
// }

// expand :: proc(ctx: ^Context) 
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'expand' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

// 	r0    := REINTERPRET_MEM_PTR(ctx.peek_value(1),Rect2)
// 	v     := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
// 	rect2 : Rect2
	
// 	_expand(r0,&rect2,v)
// 	RECT2_VAL_PTR(cs.result,&rect2)
// }

// get_center :: proc(ctx: ^Context) 
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 0,"'get_center' expects %v, but got %v.",0,cs.argc) do return	

// 	r0 := REINTERPRET_MEM_PTR(ctx.peek_value(0),Rect2)
// 	v  : Vec2

// 	_get_center(r0,&v)
// 	VECTOR2_VAL_PTR(cs.result,&v)
// }

// get_area :: proc(ctx: ^Context) 
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 0,"'get_area' expects %v, but got %v.",0,cs.argc) do return	

// 	r0 := REINTERPRET_MEM_PTR(ctx.peek_value(0),Rect2)
// 	a  : Float

// 	_get_area(r0,&a)
// 	FLOAT_VAL_PTR(cs.result,a)
// }

// grow :: proc(ctx: ^Context) 
// {
// 	cs     := ctx.call_state
// 	offset : Float

// 	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&offset),"'grow' expects %v, but got %v and must be 'number'.",1,cs.argc) do return	

// 	r0 := REINTERPRET_MEM_PTR(ctx.peek_value(1),Rect2)
// 	r  : Rect2
	
// 	_grow(r0,&r,&offset)
// 	RECT2_VAL_PTR(cs.result,&r)
// }

// // Retorna  ponto mais distante do Rect2, em relação a direcção(supporte) data.
// get_support :: proc(ctx: ^Context) 
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'get_support' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

// 	r0        := REINTERPRET_MEM_PTR(ctx.peek_value(1),Rect2)
// 	direction := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
// 	support   : Vec2

// 	_get_support(r0,direction,&support)
// 	VECTOR2_VAL_PTR(cs.result,&support)
// }

// grow_individual :: proc(ctx: ^Context) 
// {
// 	cs := ctx.call_state
// 	offsets : [4]Float

// 	for i in 0..<4 do if ctx.runtime_error(cs.argc == 4 && IS_NUMERIC_PTR(ctx.peek_value(i),&offsets),"'grow_individual' expects %v, but got %v and must be 'number','number','number' and 'number'.",4,cs.argc) do return

// 	r0  := REINTERPRET_MEM_PTR(ctx.peek_value(4),Rect2)
// 	r   : Rect2

// 	_grow_individual(r0,&r,&offsets)
// 	RECT2_VAL_PTR(cs.result,&r)
// }

// has_point :: proc(ctx: ^Context) 
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'has_point' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

// 	r0    := REINTERPRET_MEM_PTR(ctx.peek_value(1),Rect2)
// 	point := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)

// 	BOOL_VAL_PTR(cs.result,_has_point(r0,point))
// }

// has_no_area :: proc(ctx: ^Context) 
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 0,"'has_no_area' expects %v, but got %v.",0,cs.argc) do return	

// 	r0 := REINTERPRET_MEM_PTR(ctx.peek_value(0),Rect2)
// 	BOOL_VAL_PTR(cs.result,_has_no_area(r0))
// }


// intersects :: proc(ctx: ^Context) 
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.RECT2),"'intersects' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.RECT2)) do return	

// 	r0 := REINTERPRET_MEM_PTR(ctx.peek_value(1),Rect2)
// 	r1 := REINTERPRET_MEM_PTR(ctx.peek_value(0),Rect2)

// 	BOOL_VAL_PTR(cs.result,_intersects(r0,r1))
// }

// merge :: proc(ctx: ^Context) 
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.RECT2),"'merge' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.RECT2)) do return	

// 	r0 := REINTERPRET_MEM_PTR(ctx.peek_value(1),Rect2)
// 	r1 := REINTERPRET_MEM_PTR(ctx.peek_value(0),Rect2)
// 	r  : Rect2

// 	_merge(r0,r1,&r)
// 	RECT2_VAL_PTR(cs.result,&r)
// }

// clip :: proc(ctx: ^Context) 
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.RECT2),"'clip' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.RECT2)) do return	

// 	r0 := REINTERPRET_MEM_PTR(ctx.peek_value(1),Rect2)
// 	r1 := REINTERPRET_MEM_PTR(ctx.peek_value(0),Rect2)
// 	r  : Rect2

// 	_clip(r0,r1,&r)
// 	RECT2_VAL_PTR(cs.result,&r)
// }
