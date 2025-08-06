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

// step :: proc(ctx: ^Context)
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0)),"'step' expects %v, but got %v and must be 'number'.",1,cs.argc) do return	

// 	range        := AS_NUOOBECT_PTR(ctx.peek_value(1),Range)   
// 	if !_check(range,ctx) do return

// 	from,to,step := _values(range)
// 	rrange       := create_range(from,to,true); _set_step(rrange,ctx.peek_value(0))
// 	NUOOBJECT_VAL_PTR(cs.result,rrange)
// }

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
// determinant :: proc(ctx: ^Context)
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 0 ,"'determinant' expects %v, but got %v.",0,cs.argc) do return	

// 	t := AS_NUOOBECT_PTR(ctx.peek_value(0),Transform2D)
// 	FLOAT_VAL_PTR(cs.result, #force_inline _basis_determinant(&t.data))
// }

// xform :: proc(ctx: ^Context)
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'xform' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

// 	t := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
// 	v := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
// 	r := #force_inline _xform(&t.data,v)

// 	VECTOR2_VAL_PTR(cs.result,&r)
// }

// xform_inv :: proc(ctx: ^Context)
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'xform_inv' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

// 	t := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
// 	v := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
// 	r := #force_inline _xform_inv(&t.data,v)

// 	VECTOR2_VAL_PTR(cs.result,&r)
// }

// // xform_rect :: proc(ctx: ^Context)
// // {
// // 	if call_state.argc != 1 || !IS_RECT2_PTR(&call_state.args[0]) { error_msg("xform_rect",1,"Rect2",call_state); return }
	
// // 	o : Rect2
// // 	t := AS_TRANSFORM2_PTR(&call_state.args[1])
// // 	r := AS_RECT2_PTR(&call_state.args[0])

// // 	#force_inline _xform_rect(t,r,&o)
// // 	RECT2_VAL_PTR(call_state.result,&o)
// // }


// // from_angle :: proc(ctx: ^Context)
// // {
// // 	theta : Float
// // 	if call_state.argc != 1 || !IS_FLOAT_CAST_PTR(&call_state.args[0],&theta) { error_msg("from_angle",1,"float",call_state); return }

// // 	t := AS_TRANSFORM2_PTR(&call_state.args[1])
// // 	o : mat2x3

// // 	#force_inline _from_angle(t,&o,theta)
// // 	TRANSFORM2_MVAL_PTR(call_state.result,&o)
// // }



// get_inverse :: proc(ctx: ^Context)
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 0 ,"'get_inverse' expects %v, but got %v.",0,cs.argc) do return	

// 	from := AS_NUOOBECT_PTR(ctx.peek_value(0),Transform2D)
// 	to   : mat2x3

// 	#force_inline _inverse(&from.data,&to)
// 	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))
// }

// orthonormalized :: proc(ctx: ^Context)
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 0 ,"'orthonormalized' expects %v, but got %v.",0,cs.argc) do return	

// 	from := AS_NUOOBECT_PTR(ctx.peek_value(0),Transform2D)
// 	to   : mat2x3

// 	#force_inline _orthonormalize(&from.data,&to)
// 	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))
// }

// rotated :: proc(ctx: ^Context)
// {
// 	cs    := ctx.call_state
// 	theta : Float

// 	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&theta) ,"'rotated' expects %v, but got %v and must be 'number'.",1,cs.argc) do return	

// 	from := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
// 	to   :  mat2x3

// 	#force_inline _rotated(&from.data,&to,theta)
// 	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))		
// }

// scaled :: proc(ctx: ^Context)
// {
// 	cs    := ctx.call_state
// 	theta : Float

// 	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&theta) ,"'scaled' expects %v, but got %v and must be 'number'.",1,cs.argc) do return	

// 	from := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
// 	to   :  mat2x3

// 	#force_inline _scaled(&from.data,&to,theta)
// 	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))		
// }

// scaledV :: proc(ctx: ^Context)
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'scaledV' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

// 	from := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
// 	v    := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
// 	to   :  mat2x3

// 	#force_inline _scaledV(&from.data,&to,v)
// 	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))		
// }

// scaled_local :: proc(ctx: ^Context)
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'scaled_local' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

// 	from := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
// 	v    := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
// 	to   :  mat2x3

// 	#force_inline _scaledV_local(&from.data,&to,v)
// 	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))	
// }


// translated :: proc(ctx: ^Context)
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'translated' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

// 	from := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
// 	v    := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
// 	to   :  mat2x3

// 	#force_inline _translated(&from.data,&to,v)
// 	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))		
// }

// translated_local :: proc(ctx: ^Context)
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'translated_local' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

// 	from := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
// 	v    := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
// 	to   :  mat2x3

// 	#force_inline _translated_local(&from.data,&to,v)
// 	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))		
// }


// untranslated :: proc(ctx: ^Context)
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 0 ,"'untranslated' expects %v, but got %v.",0,cs.argc) do return	

// 	from := AS_NUOOBECT_PTR(ctx.peek_value(0),Transform2D)
// 	to   : mat2x3

// 	#force_inline _untranslated(&from.data,&to)
// 	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))	
// }


// affine_inverse :: proc(ctx: ^Context)
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 0 ,"'affine_inverse' expects %v, but got %v.",0,cs.argc) do return	

// 	from := AS_NUOOBECT_PTR(ctx.peek_value(0),Transform2D)
// 	to   : mat2x3

// 	det_is_zero := #force_inline _affine_inverse(&from.data,&to)
// 	if ctx.runtime_error(!det_is_zero," condition det != 0.0 is false.") do return

// 	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))	
// }




