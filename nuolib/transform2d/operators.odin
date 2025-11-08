package Transform2D


register_operators :: proc()
{
	register_setget(.OP_SET_PROPERTY,.TRANSFORM2D,.SYMID,transform2_set)
	register_setget(.OP_GET_PROPERTY,.TRANSFORM2D,.SYMID,transform2_get)

	register_op(.OP_MULT,.TRANSFORM2D,.TRANSFORM2D,trans2_trans2_mult)
	register_op(.OP_EQUAL,.TRANSFORM2D,.TRANSFORM2D,trans2_trans2_equal)
	register_op(.OP_NOT_EQUAL,.TRANSFORM2D,.TRANSFORM2D,trans2_trans2_not_equal)


	register_op(.OP_MULT,.TRANSFORM2D,.INT,trans2_int_mult)
	register_op(.OP_MULT,.TRANSFORM2D,.FLOAT,trans2_float_mult)
	register_op(.OP_MULT,.TRANSFORM2D,.VECTOR2,trans2_vec2_mult)
	register_op(.OP_MULT,.VECTOR2,.TRANSFORM2D,vec2_trans2_mult)

	register_op(.OP_MULT,.TRANSFORM2D,.RECT2,trans2_rect2_mult)
	register_op(.OP_MULT,.RECT2,.TRANSFORM2D,rect2_trans2_mult)

	register_op(.OP_EQUAL,.TRANSFORM2D,.TRANSFORM2D,trans2_trans2_equal)
	register_op(.OP_NOT_EQUAL,.TRANSFORM2D,.TRANSFORM2D,trans2_trans2_not_equal)
}


register_properties :: proc(cid: int)
{
	class_register_static_property(cid,"IDENTITY",static_default_setter,static_default_getter)
	class_register_static_property(cid,"FLIP_X",static_default_setter,static_default_getter)
	class_register_static_property(cid,"FLIP_Y",static_default_setter,static_default_getter)
}


trans2_trans2_mult :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
{
	o0 := AS_NUOOBECT_PTR(lhs,Transform2D)
	o1 := AS_NUOOBECT_PTR(rhs,Transform2D)

	t0 := &o0.data
	t1 := &o1.data

	o  :  mat2x3
	
	temp  := t1[2] 
	o[2]   = _xform(t0,&temp)
	
	x0 := mult_x(t0,&t1[0])
	x1 := mult_y(t0,&t1[0])

	y0 := mult_x(t0,&t1[1])
	y1 := mult_y(t0,&t1[1])

	o[0,0] = x0
	o[1,0] = x1
	o[0,1] = y0
	o[1,1] = y1

	unref_object(o0)
	unref_object(o1)

	NUOOBJECT_VAL_PTR(ret,create_transform2(&o))		
}

trans2_int_mult :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
{
	o0 := AS_NUOOBECT_PTR(lhs,Transform2D)
	t0 := &o0.data

	s  := Float(AS_INT_PTR(rhs))

	o  :  mat2x3
	
	o[0] = t0[0]*s
	o[1] = t0[1]*s
	o[2] = t0[2]*s

	unref_object(o0)
	NUOOBJECT_VAL_PTR(ret,create_transform2(&o))	
}

trans2_float_mult :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
{
	o0 := AS_NUOOBECT_PTR(lhs,Transform2D)
	t0 := &o0.data

	s  := AS_FLOAT_PTR(rhs)

	o  :  mat2x3
	
	o[0] = t0[0]*s
	o[1] = t0[1]*s
	o[2] = t0[2]*s

	unref_object(o0)
	NUOOBJECT_VAL_PTR(ret,create_transform2(&o))
}

trans2_trans2_equal :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
{
	o0 := AS_NUOOBECT_PTR(lhs,Transform2D)
	o1 := AS_NUOOBECT_PTR(rhs,Transform2D)

	defer if ctx.gc_allowed 
	{ 
		unref_object(o0)
		unref_object(o1)
	}

	t0 := &o0.data
	t1 := &o1.data
	eq := true
	
	for i in 0..<3 do if t0[i] != t1[i] { eq = false; break }
	BOOL_VAL_PTR(ret,eq)
}

trans2_trans2_not_equal :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
{
	o0 := AS_NUOOBECT_PTR(lhs,Transform2D)
	o1 := AS_NUOOBECT_PTR(rhs,Transform2D)

	defer if ctx.gc_allowed 
	{ 
		unref_object(o0)
		unref_object(o1)
	}

	t0 := &o0.data
	t1 := &o1.data
	nq := false
	
	for i in 0..<3 do if t0[i] != t1[i] { nq = true; break }

	BOOL_VAL_PTR(ret,nq)
}

trans2_vec2_mult :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
{
	o0 := AS_NUOOBECT_PTR(lhs,Transform2D)

	t  := &o0.data
	v  := REINTERPRET_MEM_PTR(rhs,Vec2)

	r := #force_inline _xform(t,v)

	unref_object(o0) 
	VECTOR2_VAL_PTR(ret,&r)
}

vec2_trans2_mult :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
{
	o0 := AS_NUOOBECT_PTR(rhs,Transform2D)

	t  := &o0.data
	v  := REINTERPRET_MEM_PTR(lhs,Vec2)

	r := #force_inline  _xform_inv(t,v)

	unref_object(o0) 
	VECTOR2_VAL_PTR(ret,&r)
}

trans2_rect2_mult :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
{
	o0 := AS_NUOOBECT_PTR(lhs,Transform2D)
	t  := &o0.data

	r  := REINTERPRET_MEM_PTR(rhs,Rect2)
	
	o : Rect2
	#force_inline _xform_rect(t,r,&o)

	unref_object(o0) 
	RECT2_VAL_PTR(ret,&o)
}

rect2_trans2_mult :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
{
	o0 := AS_NUOOBECT_PTR(rhs,Transform2D)
	t  := &o0.data
	it : mat2x3

	r  := REINTERPRET_MEM_PTR(lhs,Rect2)
	o  : Rect2
	
	#force_inline _affine_inverse(t,&it)
	#force_inline _xform_rect(&it,r,&o)

	unref_object(o0)
	RECT2_VAL_PTR(ret,&o)
}

// STATIC
static_default_setter :: proc(cid, sid: int, ret: ^Value, ctx: ^Context) { ctx.runtime_error(false,"cannot assign a new value to a constant.") }

static_default_getter :: proc(cid, sid: int, ret: ^Value, ctx: ^Context)
{
	s := string_db_get_string(sid)

	switch s
	{
		case `IDENTITY` : 

			m : mat2x3
			
			m[0] = Vec2{1,0}
			m[1] = Vec2{0,1}
			m[2] = Vec2{0,0}
		    NUOOBJECT_VAL_PTR(ret,create_transform2(&m))
		
		case `FLIP_X` : 

			m : mat2x3
			
			m[0] = Vec2{-1,0}
			m[1] = Vec2{0,1}
			m[2] = Vec2{0,0}
		    NUOOBJECT_VAL_PTR(ret,create_transform2(&m))
		
		case `FLIP_Y` : 

			m : mat2x3
			
			m[0] = Vec2{1,0}
			m[1] = Vec2{0,-1}
			m[2] = Vec2{0,0}
		    NUOOBJECT_VAL_PTR(ret,create_transform2(&m))
	}

}

// 
transform2_set :: #force_inline proc(t,component_sid,ret: ^Value, ctx: ^Context)
{
    o0      := AS_NUOOBECT_PTR(t,Transform2D)
	_t      := &o0.data

	sid     := AS_SYMID_PTR(component_sid)
	s       := string_db_get_string(sid)

	if ctx.runtime_error(IS_VARIANT_PTR(ret,.VECTOR2),"cannot assign a value of type '%v' as '%v'.",GET_VARIANT_TYPE_NAME(ret),GET_TYPE_NAME(.VECTOR2)) do return

	v := REINTERPRET_MEM_PTR(ret,Vec2)
	defer unref_object(o0)
		
	switch s
	{
		case `x`       : _t[0] = v^
		case `y`       : _t[1] = v^
		case `origin`  : _t[2] = v^
		case           : ctx.runtime_error(false,"cannot find property '%v' on base  '%v'.",s,GET_VARIANT_TYPE_NAME(t))
	}

	BOOL_VAL_PTR(t,true)	
}


transform2_get :: #force_inline proc(t,component_sid,ret: ^Value, ctx: ^Context)
{
    o0      := AS_NUOOBECT_PTR(t,Transform2D)
	_t      := &o0.data

	sid     := AS_SYMID_PTR(component_sid)
	s       := string_db_get_string(sid)

	defer unref_object(o0)
		
	switch s
	{
		case `x`       : VECTOR2_VAL_PTR(ret,&_t[0])
		case `y`       : VECTOR2_VAL_PTR(ret,&_t[1])
		case `origin`  : VECTOR2_VAL_PTR(ret,&_t[2])
		case           : ctx.runtime_error(false,"cannot find property '%v' on base  '%v'.",s,GET_VARIANT_TYPE_NAME(t))
	}
}