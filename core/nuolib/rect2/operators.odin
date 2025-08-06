package Rect2


register_operators :: proc()
{
	register_setget(.OP_GET_PROPERTY,.RECT2,.SYMID,rect2_get)
	register_setget(.OP_SET_PROPERTY,.RECT2,.SYMID,rect2_set)

	// // UNARY
	// register_op(.OP_NEGATE,.VECTOR2,.VECTOR2,vec2_vec2_negate)

	// // INT,VEC2
	// register_op(.OP_ADD,.INT,.VECTOR2,int_vec2_add)
	// register_op(.OP_SUB,.INT,.VECTOR2,int_vec2_sub)
	// register_op(.OP_MULT,.INT,.VECTOR2,int_vec2_mult)

	// // VEC2,INT
	// register_op(.OP_ADD,.VECTOR2,.INT,vec2_int_add)
	// register_op(.OP_SUB,.VECTOR2,.INT,vec2_int_sub)
	// register_op(.OP_MULT,.VECTOR2,.INT,vec2_int_mult)
	// register_op(.OP_DIV,.VECTOR2,.INT,vec2_int_div)

	// // FLOAT,VEC2
	// register_op(.OP_ADD,.FLOAT,.VECTOR2,float_vec2_add)
	// register_op(.OP_SUB,.FLOAT,.VECTOR2,float_vec2_sub)
	// register_op(.OP_MULT,.FLOAT,.VECTOR2,float_vec2_mult)

	// // VEC2,FLOAT
	// register_op(.OP_ADD,.VECTOR2,.FLOAT,vec2_float_add)
	// register_op(.OP_SUB,.VECTOR2,.FLOAT,vec2_float_sub)
	// register_op(.OP_MULT,.VECTOR2,.FLOAT,vec2_float_mult)
	// register_op(.OP_MULT,.VECTOR2,.FLOAT,vec2_float_div)
	
	// // VEC2,VEC2
	// register_op(.OP_ADD,.VECTOR2,.VECTOR2,vec2_vec2_add)
	// register_op(.OP_SUB,.VECTOR2,.VECTOR2,vec2_vec2_sub)
	// register_op(.OP_MULT,.VECTOR2,.VECTOR2,vec2_vec2_mult)
	// register_op(.OP_DIV,.VECTOR2,.VECTOR2,vec2_vec2_div)

	// register_op(.OP_LESS,.VECTOR2,.VECTOR2,vec2_vec2_less)
	// register_op(.OP_GREATER,.VECTOR2,.VECTOR2,vec2_vec2_greater)
	// register_op(.OP_EQUAL,.VECTOR2,.VECTOR2,vec2_vec2_equal)
	// register_op(.OP_NOT_EQUAL,.VECTOR2,.VECTOR2,vec2_vec2_not_equal)
	// register_op(.OP_LESS_EQUAL,.VECTOR2,.VECTOR2,vec2_vec2_less_equal)
	// register_op(.OP_GREATER_EQUAL,.VECTOR2,.VECTOR2,vec2_vec2_greater_equal)
}


rect2_get :: #force_inline proc(_rect2,property_sid,variant_return: ^Value, ctx: ^Context)
{
	rect2 := REINTERPRET_MEM_PTR(_rect2,Rect2)
	sid   := AS_SYMID_PTR(property_sid)
	s     := string_db_get_string(sid)

	switch s
	{
	   case `size`    : VECTOR2_VAL_PTR(variant_return,&rect2[1])
	   case `position`: VECTOR2_VAL_PTR(variant_return,&rect2[0])
	   case           : ctx.runtime_error(false,"cannot find property '%v' on base  '%v'.",s,GET_TYPE_NAME(.RECT2))
	}

}

rect2_set :: #force_inline proc(_rect2,property_sid,assign: ^Value, ctx: ^Context)
{
	rect2   := REINTERPRET_MEM_PTR(_rect2,Rect2)
	sid     := AS_SYMID_PTR(property_sid)
	s       := string_db_get_string(sid)

	if ctx.runtime_error(IS_VARIANT_PTR(assign,.VECTOR2),"cannot assign a value of type '%v' as '%v'.",GET_TYPE_NAME(assign.type),GET_TYPE_NAME(.VECTOR2)) do return

	switch s
	{
	   case `size`    : rect2[1] = REINTERPRET_MEM_PTR(assign,Vec2)^
	   case `position`: rect2[0] = REINTERPRET_MEM_PTR(assign,Vec2)^
	   case           : ctx.runtime_error(false,"cannot find property '%v' on base  '%v'.",s,GET_TYPE_NAME(.RECT2))
	}

    // Nota(jstn): usa o buffer
    RECT2_VAL_PTR(assign,rect2)
	BOOL_VAL_PTR(_rect2,false)	
}




// // ==================================== unary Vec2

// vec2_vec2_negate :: #force_inline proc(_,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := -REINTERPRET_MEM(rhs,Vec2)
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }


// // ==================================== int, Vec2

// int_vec2_add :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := Float(AS_INT_PTR(lhs))+REINTERPRET_MEM(rhs,Vec2)
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }

// int_vec2_sub :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := Float(AS_INT_PTR(lhs))-REINTERPRET_MEM(rhs,Vec2)
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }

// int_vec2_mult :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := Float(AS_INT_PTR(lhs))*REINTERPRET_MEM(rhs,Vec2)
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }

// // ==================================== float , Vec2

// float_vec2_add :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := AS_FLOAT_PTR(lhs)+REINTERPRET_MEM(rhs,Vec2)
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }

// float_vec2_sub :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := AS_FLOAT_PTR(lhs)-REINTERPRET_MEM(rhs,Vec2)
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }

// float_vec2_mult :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := AS_FLOAT_PTR(lhs)*REINTERPRET_MEM(rhs,Vec2)
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }



// // ==================================== Vec2,int

// vec2_int_add :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := REINTERPRET_MEM(lhs,Vec2)+Float(AS_INT_PTR(rhs))
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }

// vec2_int_sub :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := REINTERPRET_MEM(lhs,Vec2)-Float(AS_INT_PTR(rhs))
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }

// vec2_int_mult :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := REINTERPRET_MEM(lhs,Vec2)*Float(AS_INT_PTR(rhs))
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }

// vec2_int_div :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	b := Float(AS_INT_PTR(rhs))
// 	if ctx.runtime_error( b != 0,"division by zero error in operator '/'.") do return 

// 	vec2 := REINTERPRET_MEM(lhs,Vec2)/b
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }


// // ==================================== Vec2,float

// vec2_float_add :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := REINTERPRET_MEM(lhs,Vec2)+AS_FLOAT_PTR(rhs)
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }

// vec2_float_sub :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := REINTERPRET_MEM(lhs,Vec2)-AS_FLOAT_PTR(rhs)
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }

// vec2_float_mult :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := REINTERPRET_MEM(lhs,Vec2)*AS_FLOAT_PTR(rhs)
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }

// vec2_float_div :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	b := AS_FLOAT_PTR(rhs)
// 	if ctx.runtime_error( b != 0,"division by zero error in operator '/'.") do return 

// 	vec2 := REINTERPRET_MEM(lhs,Vec2)/b
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }


// // ==================== Vec2,Vec2

// vec2_vec2_add :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := REINTERPRET_MEM(lhs,Vec2)+REINTERPRET_MEM(rhs,Vec2)
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }

// vec2_vec2_sub :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := REINTERPRET_MEM(lhs,Vec2)-REINTERPRET_MEM(rhs,Vec2)
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }

// vec2_vec2_mult :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := REINTERPRET_MEM(lhs,Vec2)*REINTERPRET_MEM(rhs,Vec2)
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }

// vec2_vec2_div :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	vec2 := REINTERPRET_MEM(lhs,Vec2)/REINTERPRET_MEM(rhs,Vec2)
// 	VECTOR2_VAL_PTR(ret,&vec2)
// }

// vec2_vec2_less :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	BOOL_VAL_PTR(ret,_length_squared(REINTERPRET_MEM_PTR(lhs,Vec2)) < _length_squared(REINTERPRET_MEM_PTR(rhs,Vec2)))
// }

// vec2_vec2_greater :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	BOOL_VAL_PTR(ret,_length_squared(REINTERPRET_MEM_PTR(lhs,Vec2)) > _length_squared(REINTERPRET_MEM_PTR(rhs,Vec2)))
// }

// vec2_vec2_equal :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	BOOL_VAL_PTR(ret,REINTERPRET_MEM(lhs,Vec2) == REINTERPRET_MEM(rhs,Vec2))
// }

// vec2_vec2_not_equal :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	BOOL_VAL_PTR(ret,REINTERPRET_MEM(lhs,Vec2) != REINTERPRET_MEM(rhs,Vec2))
// }

// vec2_vec2_less_equal :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	BOOL_VAL_PTR(ret,_length_squared(REINTERPRET_MEM_PTR(lhs,Vec2)) <= _length_squared(REINTERPRET_MEM_PTR(rhs,Vec2)))
// }

// vec2_vec2_greater_equal :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
// {
// 	BOOL_VAL_PTR(ret,_length_squared(REINTERPRET_MEM_PTR(lhs,Vec2)) >= _length_squared(REINTERPRET_MEM_PTR(rhs,Vec2)))
// }