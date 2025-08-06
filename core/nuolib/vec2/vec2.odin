package Vec2


abs :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'abs' expects %v, but got %v.",0,cs.argc) do return	

	vec2  := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	rvec2 := _abs(vec2)
	VECTOR2_VAL_PTR(cs.result,&rvec2)
}

aspect :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'aspect' expects %v, but got %v.",0,cs.argc) do return	
	FLOAT_VAL_PTR(cs.result,#force_inline _aspect(REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)))
}

angle :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'angle' expects %v, but got %v.",0,cs.argc) do return	
	FLOAT_VAL_PTR(cs.result,#force_inline _angle(REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)))
}

// angle_from :: proc(ctx: ^Context) 
// {
// 	if ctx.argc != 1 || !IS_VECTOR2D_PTR(&ctx.args[0]) { error_msg("angle_from",1,"a Vector2",ctx); return }

// 	a   := #force_inline _angle(AS_VECTOR2_PTR(&ctx.args[1]))
// 	b   := #force_inline _angle(AS_VECTOR2_PTR(&ctx.args[0]))

// 	FLOAT_VAL_PTR(cs.result, b-a)
// }

angle_to_point :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'angle_to_point' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	v1 := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	v2 := REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2)

	r := #force_inline _sub(v1,v2)
	FLOAT_VAL_PTR(cs.result,#force_inline _angle(&r))
}

bounce :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'bounce' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	
	n  := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	
	if !_is_normalized(n) 
	{ 
		ZERO := _ZERO
		ctx.runtime_warning(false,"the normal must be normalized. Returning Vec2(0,0) as fallback.")
		VECTOR2_VAL_PTR(cs.result,&ZERO)
		return
	}

	vec2 := REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2)
	r    := -#force_inline _reflect(vec2,n)

	VECTOR2_VAL_PTR(cs.result,&r)
}

clamp :: proc (ctx: ^Context) 
{
	cs := ctx.call_state
	for i in 0..<2 do if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(i),.VECTOR2),"'clamp' expects %v, but got %v and must be '%v's.",2,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	min  := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	max  := REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2)
	vec2 := REINTERPRET_MEM_PTR(ctx.peek_value(2),Vec2)
	r    := #force_inline _clamp(vec2,min,max)

	VECTOR2_VAL_PTR(cs.result,&r)
}

cross :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'cross' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	
	FLOAT_VAL_PTR(cs.result,#force_inline _cross(REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2),REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)))
}

direction_to :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'cross' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	to    := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	from  := REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2)

	s     := _sub(to,from)
	n     := #force_inline _normalize(&s)

	VECTOR2_VAL_PTR(cs.result,&n)
}

dot :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'dot' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	
	FLOAT_VAL_PTR(cs.result,#force_inline _dot(REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2),REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)))
}

distance_to :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'distance_to' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return

	to    := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	from  := REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2)

	s := _sub(to,from)
	FLOAT_VAL_PTR(cs.result,#force_inline _length(&s))
}

distance_to_squared :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'distance_to_squared' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return

	to    := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	from  := REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2)

	s := _sub(to,from)
	FLOAT_VAL_PTR(cs.result,#force_inline _length_squared(&s))
}

floor :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'floor' expects %v, but got %v.",0,cs.argc) do return	

	vec2 := #force_inline _floor(REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2))
	VECTOR2_VAL_PTR(cs.result,&vec2)
}


invert :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'invert' expects %v, but got %v.",0,cs.argc) do return	

	vec2  := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	ivec2 := #force_inline _invert(vec2)
	
	VECTOR2_VAL_PTR(cs.result,&ivec2)
}

is_equal_approx :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'is_equal_approx' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	vec2_a  := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	vec2_b  := REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2)

	BOOL_VAL_PTR(cs.result, #force_inline _is_equal_approx(vec2_a,vec2_b))
}

is_normalized :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'is_normalized' expects %v, but got %v.",0,cs.argc) do return	
	BOOL_VAL_PTR(cs.result, #force_inline _is_normalized(REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)))
}

length :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'length' expects %v, but got %v.",0,cs.argc) do return	
	FLOAT_VAL_PTR(cs.result,#force_inline _length(REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)))
}

length_squared :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'length_squared' expects %v, but got %v.",0,cs.argc) do return	
	FLOAT_VAL_PTR(cs.result,#force_inline _length_squared(REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)))
}

lerp :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	dt : Float

	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2) && IS_NUMERIC_PTR(ctx.peek_value(1),&dt),"'lerp' expects %v, but got %v and must be '%v' and 'number'.",2,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	to    := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	vec2  := REINTERPRET_MEM_PTR(ctx.peek_value(2),Vec2)
	r     := #force_inline _lerp(vec2,to,dt)

	VECTOR2_VAL_PTR(cs.result,&r)
}

limit_length :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	dt : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&dt),"'limit_length' expects %v, but got %v and must be number'.",1,cs.argc) do return	

	vec2   := REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2)
	r      := #force_inline _limit_length(vec2,dt)

	VECTOR2_VAL_PTR(cs.result,&r)
}

min :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'min' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	vec2_a  := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	vec2_b  := REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2)
	r       := #force_inline _min(vec2_a,vec2_b)

	VECTOR2_VAL_PTR(cs.result,&r)
}

max :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'max' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	vec2_a  := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	vec2_b  := REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2)
	r       := #force_inline _max(vec2_a,vec2_b)

	VECTOR2_VAL_PTR(cs.result,&r)
}

normalize :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'normalize' expects %v, but got %v.",0,cs.argc) do return	
	
	vec2 := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	n    := #force_inline _normalize(vec2)

	VECTOR2_VAL_PTR(cs.result,&n)
}

move_toward :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	dt : Float

	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2) && IS_NUMERIC_PTR(ctx.peek_value(1),&dt),"'move_toward' expects %v, but got %v and must be '%v' and 'number'.",2,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	to    := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	vec2  := REINTERPRET_MEM_PTR(ctx.peek_value(2),Vec2)
	r     := #force_inline _move_toward(vec2,to,dt)

	VECTOR2_VAL_PTR(cs.result,&r)
}


posmod  :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	dt : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&dt),"'posmod' expects %v, but got %v and must be 'number'.",1,cs.argc) do return	
	if dt == 0.0
	{
		ZERO := _ZERO
		ctx.runtime_warning(false,"the argument is zero. Returning Vec2(0,0) as fallback.")
		VECTOR2_VAL_PTR(cs.result,&ZERO)
		return
	}

	vec2  := REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2)
	r     := #force_inline _posmod(vec2,dt)

	VECTOR2_VAL_PTR(cs.result,&r)
}


reflect :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'reflect' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	vec2_a  := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	vec2_b  := REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2)
	r       := #force_inline _reflect(vec2_b,vec2_a)

	VECTOR2_VAL_PTR(cs.result,&r)
}

round :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'round' expects %v, but got %v.",0,cs.argc) do return	
	
	vec2 := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	v    := #force_inline _round(vec2)

	VECTOR2_VAL_PTR(cs.result,&v)
}

rotate :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	dt : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&dt),"'rotate' expects %v, but got %v and must be 'number'.",1,cs.argc) do return	

	vec2  := REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2)
	r     := #force_inline _rotate(vec2,dt)

	VECTOR2_VAL_PTR(cs.result,&r)
}

sign :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'sign' expects %v, but got %v.",0,cs.argc) do return	
	
	vec2 := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	v    := #force_inline _sign(vec2)

	VECTOR2_VAL_PTR(cs.result,&v)
}

smoothstep :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	dt : Float

	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2) && IS_NUMERIC_PTR(ctx.peek_value(1),&dt),"'smoothstep' expects %v, but got %v and must be '%v' and 'number'.",2,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	to    := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	vec2  := REINTERPRET_MEM_PTR(ctx.peek_value(2),Vec2)
	r     := #force_inline _smoothstep(vec2,to,dt)

	VECTOR2_VAL_PTR(cs.result,&r)
}

slerp :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	dt : Float

	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2) && IS_NUMERIC_PTR(ctx.peek_value(1),&dt),"'slerp' expects %v, but got %v and must be '%v' and 'number'.",2,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	to    := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	vec2  := REINTERPRET_MEM_PTR(ctx.peek_value(2),Vec2)
	r     := #force_inline _slerp(vec2,to,dt)

	VECTOR2_VAL_PTR(cs.result,&r)
}

slide :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'slide' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	
	n  := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	
	if !_is_normalized(n) 
	{ 
		ZERO := _ZERO
		ctx.runtime_warning(false,"the normal must be normalized. Returning Vec2(0,0) as fallback.")
		VECTOR2_VAL_PTR(cs.result,&ZERO)
		return
	}

	vec2 := REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2)
	r    := #force_inline _slide(vec2,n)

	VECTOR2_VAL_PTR(cs.result,&r)
}

snapped :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	dt : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&dt),"'snapped' expects %v, but got %v and must be number'.",1,cs.argc) do return	

	vec2   := REINTERPRET_MEM_PTR(ctx.peek_value(1),Vec2)
	r      := #force_inline _stepfy(vec2,dt)

	VECTOR2_VAL_PTR(cs.result,&r)
}

orthogonal :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'orthogonal' expects %v, but got %v.",0,cs.argc) do return	
	
	vec2 := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	v    := #force_inline _orthogonal(vec2)

	VECTOR2_VAL_PTR(cs.result,&v)
}
