#+private
package Math


deg2rad :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	value : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&value),"'deg2rad' expects %v, but got %v and must be '%v'",1,cs.argc,"number") do return
	FLOAT_VAL_PTR(cs.result,to_radians(value))
}

rad2deg :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	value : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&value),"'rad2deg' expects %v, but got %v and must be '%v'",1,cs.argc,"number") do return
	FLOAT_VAL_PTR(cs.result,to_degrees(value))
}

_min :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	
	a     : Float
	b     : Float

	if ctx.runtime_error(cs.argc == 2 && IS_NUMERIC_PTR(ctx.peek_value(0),&a) && IS_NUMERIC_PTR(ctx.peek_value(1),&b),"'min' expects %v, but got %v and must be '%v's",2,cs.argc,"number") do return
	FLOAT_VAL_PTR(cs.result,min(a,b))
}

_max :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	
	a     : Float
	b     : Float

	if ctx.runtime_error(cs.argc == 2 && IS_NUMERIC_PTR(ctx.peek_value(0),&a) && IS_NUMERIC_PTR(ctx.peek_value(1),&b),"'max' expects %v, but got %v and must be '%v's",2,cs.argc,"number") do return
	FLOAT_VAL_PTR(cs.result,max(a,b))
}

_abs :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	value : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&value),"'abs' expects %v, but got %v and must be '%v'",1,cs.argc,"number") do return
	FLOAT_VAL_PTR(cs.result,abs(value))
}

_sign :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	value : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&value),"'sign' expects %v, but got %v and must be '%v'",1,cs.argc,"number") do return
	FLOAT_VAL_PTR(cs.result,sign(value))
}

_sqrt :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	value : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&value) && value >= 0,"'sqrt' expects %v, but got %v and must be '%v'",1,cs.argc,"positive number") do return
	FLOAT_VAL_PTR(cs.result,sqrt(value))
}

_cos :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	value : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&value),"'cos' expects %v, but got %v and must be '%v'",1,cs.argc,"number") do return
	FLOAT_VAL_PTR(cs.result,cos(value))
}

_sin :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	value : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&value),"'sin' expects %v, but got %v and must be '%v'",1,cs.argc,"number") do return
	FLOAT_VAL_PTR(cs.result,sin(value))
}

_tan :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	value : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&value),"'tan' expects %v, but got %v and must be '%v'",1,cs.argc,"number") do return
	FLOAT_VAL_PTR(cs.result,tan(value))
}

_atan2 :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	
	a     : Float
	b     : Float

	if ctx.runtime_error(cs.argc == 2 && IS_NUMERIC_PTR(ctx.peek_value(0),&a) && IS_NUMERIC_PTR(ctx.peek_value(1),&b),"'atan2' expects %v, but got %v and must be '%v's",2,cs.argc,"number's") do return
	FLOAT_VAL_PTR(cs.result,atan2(a,b))
}


_acos :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	value : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&value),"'acos' expects %v, but got %v and must be '%v'",1,cs.argc,"number") do return
	FLOAT_VAL_PTR(cs.result,acos(value))
}

_asin :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	value : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&value),"'asin' expects %v, but got %v and must be '%v'",1,cs.argc,"number") do return
	FLOAT_VAL_PTR(cs.result,asin(value))
}

_atan :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	value : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&value),"'atan' expects %v, but got %v and must be '%v'",1,cs.argc,"number") do return
	FLOAT_VAL_PTR(cs.result,atan(value))
}

_ln :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	value : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&value) && value > 0,"'ln' expects %v, but got %v and must be '%v'",1,cs.argc,"positive number") do return
	FLOAT_VAL_PTR(cs.result,ln(value))
}

_log :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	
	a     : Float
	b     : Float

	if ctx.runtime_error(cs.argc == 2 && IS_NUMERIC_PTR(ctx.peek_value(0),&a) && IS_NUMERIC_PTR(ctx.peek_value(1),&b),"'log' expects %v, but got %v and must be '%v's",2,cs.argc,"number") do return
	if ctx.runtime_error(a > 0 && b > 0,"'log' expects %v, but got %v and must be '%v's",2,cs.argc,"number's") do return

	FLOAT_VAL_PTR(cs.result,log(a,b))
}

_exp :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	value : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&value) ,"'exp' expects %v, but got %v and must be '%v'",1,cs.argc,"number") do return
	FLOAT_VAL_PTR(cs.result,exp(value))
}

_pow :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	
	a     : Float
	b     : Float

	if ctx.runtime_error(cs.argc == 2 && IS_NUMERIC_PTR(ctx.peek_value(0),&a) && IS_NUMERIC_PTR(ctx.peek_value(1),&b),"'pow' expects %v, but got %v and must be '%v's",2,cs.argc,"number") do return
	FLOAT_VAL_PTR(cs.result,pow(a,b))
}

_clamp :: proc(ctx: ^Context) 
{
	cs     := ctx.call_state
	values : [3]Float

	for  i in 0..<3 do if ctx.runtime_error(cs.argc == 3 && IS_NUMERIC_PTR(ctx.peek_value(i),&values[i]),"'clamp' expects %v, but got %v and must be '%v's",3,cs.argc,"number's") do return
	FLOAT_VAL_PTR(cs.result,clamp(values[0],values[1],values[2]))
}

_lerp :: proc(ctx: ^Context) 
{
	cs     := ctx.call_state
	values : [3]Float

	for  i in 0..<3 do if ctx.runtime_error(cs.argc == 3 && IS_NUMERIC_PTR(ctx.peek_value(i),&values[i]),"'lerp' expects %v, but got %v and must be '%v's",3,cs.argc,"number's") do return
	FLOAT_VAL_PTR(cs.result,lerp(values[0],values[1],values[2]))
}

_unlerp :: proc(ctx: ^Context) 
{
	cs     := ctx.call_state
	values : [3]Float

	for  i in 0..<3 do if ctx.runtime_error(cs.argc == 3 && IS_NUMERIC_PTR(ctx.peek_value(i),&values[i]),"'unlerp' expects %v, but got %v and must be '%v's",3,cs.argc,"number's") do return
	FLOAT_VAL_PTR(cs.result,unlerp(values[0],values[1],values[2]))
}

_smootherstep :: proc(ctx: ^Context) 
{
	cs     := ctx.call_state
	values : [3]Float

	for  i in 0..<3 do if ctx.runtime_error(cs.argc == 3 && IS_NUMERIC_PTR(ctx.peek_value(i),&values[i]),"'smootherstep' expects %v, but got %v and must be '%v's",3,cs.argc,"number's") do return
	FLOAT_VAL_PTR(cs.result,smootherstep(values[0],values[1],values[2]))
}

_floor :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	value : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&value),"'floor' expects %v, but got %v and must be '%v'",1,cs.argc,"number") do return
	FLOAT_VAL_PTR(cs.result,floor(value))
}

_round :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	value : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&value),"'round' expects %v, but got %v and must be '%v'",1,cs.argc,"number") do return
	FLOAT_VAL_PTR(cs.result,round(value))
}

_mod :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	a,b   : Float

	if ctx.runtime_error(cs.argc == 2 && IS_NUMERIC_PTR(ctx.peek_value(0),&a) && IS_NUMERIC_PTR(ctx.peek_value(1),&b),"'mod' expects %v, but got %v and must be '%v'",2,cs.argc,"number's") do return
	FLOAT_VAL_PTR(cs.result,mod(a,b))
}

_remap :: proc(ctx: ^Context) 
{
	cs     := ctx.call_state
	values : [5]Float

	for  i in 0..<5 do if ctx.runtime_error(cs.argc == 5 && IS_NUMERIC_PTR(ctx.peek_value(i),&values[i]),"'remap' expects %v, but got %v and must be '%v's",5,cs.argc,"number's") do return
	FLOAT_VAL_PTR(cs.result,remap(values[0],values[1],values[2],values[3],values[4]))
}

_remap_clamped :: proc(ctx: ^Context) 
{
	cs     := ctx.call_state
	values : [5]Float

	for  i in 0..<5 do if ctx.runtime_error(cs.argc == 5 && IS_NUMERIC_PTR(ctx.peek_value(i),&values[i]),"'remap_clamped' expects %v, but got %v and must be '%v's",5,cs.argc,"number's") do return
	FLOAT_VAL_PTR(cs.result,remap_clamped(values[0],values[1],values[2],values[3],values[4]))
}


_wrap :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	a,b   : Float

	if ctx.runtime_error(cs.argc == 2 && IS_NUMERIC_PTR(ctx.peek_value(0),&a) && IS_NUMERIC_PTR(ctx.peek_value(1),&b),"'wrap' expects %v, but got %v and must be '%v'",2,cs.argc,"number's") do return
	FLOAT_VAL_PTR(cs.result,wrap(a,b))
}

_smoothstep :: proc(ctx: ^Context) 
{
	cs     := ctx.call_state
	values : [3]Float

	for  i in 0..<3 do if ctx.runtime_error(cs.argc == 3 && IS_NUMERIC_PTR(ctx.peek_value(i),&values[i]),"'smoothstep' expects %v, but got %v and must be '%v's",3,cs.argc,"number's") do return
	FLOAT_VAL_PTR(cs.result,smoothstep(values[0],values[1],values[2]))
}

_hypot :: proc(ctx: ^Context) 
{
	cs     := ctx.call_state
	values : [2]Float

	for  i in 0..<2 do if ctx.runtime_error(cs.argc == 2 && IS_NUMERIC_PTR(ctx.peek_value(i),&values[i]),"'hypot' expects %v, but got %v and must be '%v's",2,cs.argc,"number's") do return
	FLOAT_VAL_PTR(cs.result,hypot(values[0],values[1]))
}


test :: proc(ctx: ^Context) 
{
	cs     := ctx.call_state
	a      := AS_INT_PTR(ctx.peek_value(0))
	FLOAT_VAL_PTR(cs.result,sin(f32(a)))
}


















