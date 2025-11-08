package Complex


register_operators :: proc()
{
	register_setget(.OP_GET_PROPERTY,.COMPLEX,.SYMID,complex_get)
	register_setget(.OP_SET_PROPERTY,.COMPLEX,.SYMID,complex_set)

	// // UNARY
	register_op(.OP_NEGATE,.COMPLEX,.COMPLEX,complex_complex_negate)

	// // INT,VEC2
	register_op(.OP_ADD,.INT,.COMPLEX,int_complex_add)
	register_op(.OP_SUB,.INT,.COMPLEX,int_complex_sub)
	register_op(.OP_MULT,.INT,.COMPLEX,int_complex_mult)

	// // COMPLEX,INT
	register_op(.OP_ADD,.COMPLEX,.INT,complex_int_add)
	register_op(.OP_SUB,.COMPLEX,.INT,complex_int_sub)
	register_op(.OP_MULT,.COMPLEX,.INT,complex_int_mult)
	register_op(.OP_DIV,.COMPLEX,.INT,complex_int_div)

	// // FLOAT,COMPLEX
	register_op(.OP_ADD,.FLOAT,.COMPLEX,float_complex_add)
	register_op(.OP_SUB,.FLOAT,.COMPLEX,float_complex_sub)
	register_op(.OP_MULT,.FLOAT,.COMPLEX,float_complex_mult)

	// // COMPLEX,FLOAT
	register_op(.OP_ADD,.COMPLEX,.FLOAT,complex_float_add)
	register_op(.OP_SUB,.COMPLEX,.FLOAT,complex_float_sub)
	register_op(.OP_MULT,.COMPLEX,.FLOAT,complex_float_mult)
	register_op(.OP_DIV,.COMPLEX,.FLOAT,complex_float_div)
	
	// // COMPLEX,VEC2
	register_op(.OP_ADD,.COMPLEX,.COMPLEX,complex_complex_add)
	register_op(.OP_SUB,.COMPLEX,.COMPLEX,complex_complex_sub)
	register_op(.OP_MULT,.COMPLEX,.COMPLEX,complex_complex_mult)
	register_op(.OP_DIV,.COMPLEX,.COMPLEX,complex_complex_div)

	// register_op(.OP_LESS,.COMPLEX,.COMPLEX,complex_complex_less)
	// register_op(.OP_GREATER,.COMPLEX,.COMPLEX,complex_complex_greater)
	register_op(.OP_EQUAL,.COMPLEX,.COMPLEX,complex_complex_equal)
	register_op(.OP_NOT_EQUAL,.COMPLEX,.COMPLEX,complex_complex_not_equal)

}

register_properties :: proc(cid: int)
{
	// class_register_static_property(cid,"ZERO",static_default_setter,static_default_getter)
	// class_register_static_property(cid,"RIGHT",static_default_setter,static_default_getter)
	// class_register_static_property(cid,"LEFT",static_default_setter,static_default_getter)
	// class_register_static_property(cid,"UP",static_default_setter,static_default_getter)
	// class_register_static_property(cid,"DOWN",static_default_setter,static_default_getter)
	// class_register_static_property(cid,"ONE",static_default_setter,static_default_getter)
}


complex_get :: #force_inline proc(_z,property_sid,variant_return: ^Value, ctx: ^Context)
{
	z    := REINTERPRET_MEM_PTR(_z,Complex)
	sid  := AS_SYMID_PTR(property_sid)
	s    := string_db_get_string(sid)

	switch s
	{
	   case `Re`: FLOAT_VAL_PTR(variant_return,z.x)
	   case `Im`: FLOAT_VAL_PTR(variant_return,z.y)
	   case    : ctx.runtime_error(false,"cannot find property '%v' on base  '%v'.",s,GET_TYPE_NAME(.COMPLEX))
	}

    // Nota(jstn): não usa o buffer, portanto pula o registro, ou seja, não será reguardado
}

complex_set :: #force_inline proc(_z,property_sid,assign: ^Value, ctx: ^Context)
{
	z       := REINTERPRET_MEM_PTR(_z,Complex)
	sid     := AS_SYMID_PTR(property_sid)
	s       := string_db_get_string(sid)
	value   : Float

	if ctx.runtime_error(IS_NUMERIC_PTR(assign,&value),"cannot assign a value of type '%v' as '%v'.",GET_TYPE_NAME(assign.type),GET_TYPE_NAME(.FLOAT)) do return

	switch s
	{
	   case `Re`: z[0] = value
	   case `Im`: z[1] = value
	   case    : ctx.runtime_error(false,"cannot find property '%v' on base  '%v'.",s,GET_TYPE_NAME(.COMPLEX))
	}

    // Nota(jstn): usa o buffer
    COMPLEX_VAL_PTR(assign,z)
	BOOL_VAL_PTR(_z,false)	
}




// STATIC
// static_default_setter :: proc(cid, sid: int, ret: ^Value, ctx: ^Context) { ctx.runtime_error(false,"cannot assign a new value to a constant.") }

// static_default_getter :: proc(cid, sid: int, ret: ^Value, ctx: ^Context)
// {
// 	s := string_db_get_string(sid)

// 	switch s
// 	{
// 		case `ZERO` : v := _ZERO;  COMPLEX_VAL_PTR(ret,&v)
// 		case `UP`   : v := _UP;    COMPLEX_VAL_PTR(ret,&v)
// 		case `DOWN` : v := _DOWN;  COMPLEX_VAL_PTR(ret,&v)
// 		case `RIGHT`: v := _RIGHT; COMPLEX_VAL_PTR(ret,&v)
// 		case `LEFT` : v := _LEFT;  COMPLEX_VAL_PTR(ret,&v)
// 		case `ONE`  : v := _ONE;   COMPLEX_VAL_PTR(ret,&v)
// 	}

// }














// ==================================== unary Vec2

complex_complex_negate :: #force_inline proc(_,rhs,ret: ^Value, ctx: ^Context)
{
	z := -REINTERPRET_MEM(rhs,Complex)
	COMPLEX_VAL_PTR(ret,&z)
}


// ==================================== int, Complex

int_complex_add :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	z := REINTERPRET_MEM(rhs,Complex)
	r := Complex{z.x+Float(AS_INT_PTR(lhs)),z.y}
	COMPLEX_VAL_PTR(ret,&r)
}

int_complex_sub :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	z := REINTERPRET_MEM(rhs,Complex)
	r := Complex{z.x-Float(AS_INT_PTR(lhs)),z.y}
	COMPLEX_VAL_PTR(ret,&r)
}

int_complex_mult :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	z  := REINTERPRET_MEM(rhs,Complex); 
	r  := z*Float(AS_INT_PTR(lhs))
	COMPLEX_VAL_PTR(ret,&r)
}

// ==================================== float,Complex

float_complex_add :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	z := REINTERPRET_MEM(rhs,Complex)
	r := Complex{z.x+AS_FLOAT_PTR(lhs),z.y}
	COMPLEX_VAL_PTR(ret,&r)
}

float_complex_sub :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	z := REINTERPRET_MEM(rhs,Complex)
	r := Complex{z.x-AS_FLOAT_PTR(lhs),z.y}
	COMPLEX_VAL_PTR(ret,&r)
}

float_complex_mult :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	z  := REINTERPRET_MEM(rhs,Complex); 
	r  := z*AS_FLOAT_PTR(lhs)
	COMPLEX_VAL_PTR(ret,&r)
}



// ==================================== Complex,int

complex_int_add :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	z := REINTERPRET_MEM(lhs,Complex)
	r := Complex{z.x+Float(AS_INT_PTR(rhs)),z.y}
	COMPLEX_VAL_PTR(ret,&r)
}

complex_int_sub :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	z := REINTERPRET_MEM(lhs,Complex)
	r := Complex{z.x-Float(AS_INT_PTR(rhs)),z.y}
	COMPLEX_VAL_PTR(ret,&r)
}

complex_int_mult :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	z  := REINTERPRET_MEM(lhs,Complex); 
	r  := z*Float(AS_INT_PTR(rhs))
	COMPLEX_VAL_PTR(ret,&r)
}

complex_int_div :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	b := Float(AS_INT_PTR(rhs))
	if ctx.runtime_error( b != 0,"division by zero error in operator '/'.") do return 
	
	z  := REINTERPRET_MEM(lhs,Complex); 
	r  := z/b
	COMPLEX_VAL_PTR(ret,&r)
}


// ==================================== Complex,float

complex_float_add :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	z := REINTERPRET_MEM(lhs,Complex)
	r := Complex{z.x+AS_FLOAT_PTR(rhs),z.y}
	COMPLEX_VAL_PTR(ret,&r)
}

complex_float_sub :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	z := REINTERPRET_MEM(lhs,Complex)
	r := Complex{z.x-AS_FLOAT_PTR(rhs),z.y}
	COMPLEX_VAL_PTR(ret,&r)
}

complex_float_mult :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	z  := REINTERPRET_MEM(lhs,Complex); 
	r  := z*AS_FLOAT_PTR(rhs)
	COMPLEX_VAL_PTR(ret,&r)
}

complex_float_div :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	b := AS_FLOAT_PTR(rhs)
	if ctx.runtime_error( b != 0,"division by zero error in operator '/'.") do return 
	
	z  := REINTERPRET_MEM(lhs,Complex); 
	r  := z/b
	COMPLEX_VAL_PTR(ret,&r)
}


// ==================== Complex , Complex

complex_complex_add :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	a := REINTERPRET_MEM(lhs,Complex)
	b := REINTERPRET_MEM(rhs,Complex)
	
	r := Complex{a.x+b.x,a.y+b.y}
	COMPLEX_VAL_PTR(ret,&r)
}

complex_complex_sub :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	a := REINTERPRET_MEM(lhs,Complex)
	b := REINTERPRET_MEM(rhs,Complex)

	r := Complex{a.x-b.x,a.y-b.y}
	COMPLEX_VAL_PTR(ret,&r)
}

complex_complex_mult :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	a := REINTERPRET_MEM(lhs,Complex)
	b := REINTERPRET_MEM(rhs,Complex)
	
	r := Complex{a.x*b.x-a.y*b.y,a.x*b.y+a.y*b.x}
	COMPLEX_VAL_PTR(ret,&r)
}

complex_complex_div :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	a  := REINTERPRET_MEM(lhs,Complex)
	b  := REINTERPRET_MEM(rhs,Complex)

	z0 := b.x*b.x+b.y*b.y

	if ctx.runtime_error(z0 != 0 ,"division by zero error in operator '/'.") do return

	z1 := Complex{a.x*b.x+a.y*b.y,-a.x*b.y+a.y*b.x}/z0
	COMPLEX_VAL_PTR(ret,&z1)
}


complex_complex_equal :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	BOOL_VAL_PTR(ret,REINTERPRET_MEM(lhs,Complex) == REINTERPRET_MEM(rhs,Complex))
}

complex_complex_not_equal :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	BOOL_VAL_PTR(ret,REINTERPRET_MEM(lhs,Complex) != REINTERPRET_MEM(rhs,Complex))
}

