package Transform2D


basis_xform_inv :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'basis_xform_inv' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	t := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
	v := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	r := #force_inline _basis_xform_inv(&t.data,v)

	VECTOR2_VAL_PTR(cs.result,&r)
}

basis_xform :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'basis_xform' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	t := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
	v := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	r := #force_inline _basis_xform(&t.data,v)

	VECTOR2_VAL_PTR(cs.result,&r)
}

determinant :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'determinant' expects %v, but got %v.",0,cs.argc) do return	

	t := AS_NUOOBECT_PTR(ctx.peek_value(0),Transform2D)
	FLOAT_VAL_PTR(cs.result, #force_inline _basis_determinant(&t.data))
}

xform :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'xform' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	t := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
	v := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	r := #force_inline _xform(&t.data,v)

	VECTOR2_VAL_PTR(cs.result,&r)
}

xform_inv :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'xform_inv' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	t := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
	v := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	r := #force_inline _xform_inv(&t.data,v)

	VECTOR2_VAL_PTR(cs.result,&r)
}

// xform_rect :: proc(ctx: ^Context)
// {
// 	if call_state.argc != 1 || !IS_RECT2_PTR(&call_state.args[0]) { error_msg("xform_rect",1,"Rect2",call_state); return }
	
// 	o : Rect2
// 	t := AS_TRANSFORM2_PTR(&call_state.args[1])
// 	r := AS_RECT2_PTR(&call_state.args[0])

// 	#force_inline _xform_rect(t,r,&o)
// 	RECT2_VAL_PTR(call_state.result,&o)
// }


// from_angle :: proc(ctx: ^Context)
// {
// 	theta : Float
// 	if call_state.argc != 1 || !IS_FLOAT_CAST_PTR(&call_state.args[0],&theta) { error_msg("from_angle",1,"float",call_state); return }

// 	t := AS_TRANSFORM2_PTR(&call_state.args[1])
// 	o : mat2x3

// 	#force_inline _from_angle(t,&o,theta)
// 	TRANSFORM2_MVAL_PTR(call_state.result,&o)
// }



get_inverse :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'get_inverse' expects %v, but got %v.",0,cs.argc) do return	

	from := AS_NUOOBECT_PTR(ctx.peek_value(0),Transform2D)
	to   : mat2x3

	#force_inline _inverse(&from.data,&to)
	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))
}

orthonormalized :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'orthonormalized' expects %v, but got %v.",0,cs.argc) do return	

	from := AS_NUOOBECT_PTR(ctx.peek_value(0),Transform2D)
	to   : mat2x3

	#force_inline _orthonormalize(&from.data,&to)
	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))
}

rotated :: proc(ctx: ^Context)
{
	cs    := ctx.call_state
	theta : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&theta) ,"'rotated' expects %v, but got %v and must be 'number'.",1,cs.argc) do return	

	from := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
	to   :  mat2x3

	#force_inline _rotated(&from.data,&to,theta)
	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))		
}

scaled :: proc(ctx: ^Context)
{
	cs    := ctx.call_state
	theta : Float

	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&theta) ,"'scaled' expects %v, but got %v and must be 'number'.",1,cs.argc) do return	

	from := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
	to   :  mat2x3

	#force_inline _scaled(&from.data,&to,theta)
	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))		
}

scaledV :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'scaledV' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	from := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
	v    := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	to   :  mat2x3

	#force_inline _scaledV(&from.data,&to,v)
	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))		
}

scaled_local :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'scaled_local' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	from := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
	v    := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	to   :  mat2x3

	#force_inline _scaledV_local(&from.data,&to,v)
	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))	
}


translated :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'translated' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	from := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
	v    := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	to   :  mat2x3

	#force_inline _translated(&from.data,&to,v)
	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))		
}

translated_local :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2),"'translated_local' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.VECTOR2)) do return	

	from := AS_NUOOBECT_PTR(ctx.peek_value(1),Transform2D)
	v    := REINTERPRET_MEM_PTR(ctx.peek_value(0),Vec2)
	to   :  mat2x3

	#force_inline _translated_local(&from.data,&to,v)
	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))		
}


untranslated :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'untranslated' expects %v, but got %v.",0,cs.argc) do return	

	from := AS_NUOOBECT_PTR(ctx.peek_value(0),Transform2D)
	to   : mat2x3

	#force_inline _untranslated(&from.data,&to)
	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))	
}


affine_inverse :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'affine_inverse' expects %v, but got %v.",0,cs.argc) do return	

	from := AS_NUOOBECT_PTR(ctx.peek_value(0),Transform2D)
	to   : mat2x3

	det_is_zero := #force_inline _affine_inverse(&from.data,&to)
	if ctx.runtime_error(!det_is_zero," condition det != 0.0 is false.") do return

	NUOOBJECT_VAL_PTR(cs.result,create_transform2(&to))	
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
