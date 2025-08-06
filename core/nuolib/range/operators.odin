package Range


register_operators :: proc()
{
	regiser_constructor(.OP_CONSTRUCT,.RANGE,.RANGE,construct_range)

// 	register_setget(.OP_SET_PROPERTY,.TRANSFORM2D,.SYMID,transform2_set)
// 	register_setget(.OP_GET_PROPERTY,.TRANSFORM2D,.SYMID,transform2_get)

// 	register_op(.OP_MULT,.TRANSFORM2D,.TRANSFORM2D,trans2_trans2_mult)
// 	register_op(.OP_EQUAL,.TRANSFORM2D,.TRANSFORM2D,trans2_trans2_equal)
// 	register_op(.OP_NOT_EQUAL,.TRANSFORM2D,.TRANSFORM2D,trans2_trans2_not_equal)


// 	register_op(.OP_MULT,.TRANSFORM2D,.INT,trans2_int_mult)
// 	register_op(.OP_MULT,.TRANSFORM2D,.FLOAT,trans2_float_mult)
// 	register_op(.OP_MULT,.TRANSFORM2D,.VECTOR2,trans2_vec2_mult)
// 	register_op(.OP_MULT,.VECTOR2,.TRANSFORM2D,vec2_trans2_mult)

// 	register_op(.OP_MULT,.TRANSFORM2D,.RECT2,trans2_rect2_mult)
// 	register_op(.OP_MULT,.RECT2,.TRANSFORM2D,rect2_trans2_mult)

// 	register_op(.OP_EQUAL,.TRANSFORM2D,.TRANSFORM2D,trans2_trans2_equal)
// 	register_op(.OP_NOT_EQUAL,.TRANSFORM2D,.TRANSFORM2D,trans2_trans2_not_equal)
}


// register_properties :: proc(cid: int)
// {
// 	class_register_static_property(cid,"IDENTITY",static_default_setter,static_default_getter)
// 	class_register_static_property(cid,"FLIP_X",static_default_setter,static_default_getter)
// 	class_register_static_property(cid,"FLIP_Y",static_default_setter,static_default_getter)
// }

construct_range :: #force_inline proc(_,_,variant_return: ^Value, ctx: ^Context)
{
	cs   := ctx.call_state
	args := cs.args
	argc := cs.argc

	if ctx.runtime_error( argc == 2 && IS_NUMERIC_PTR(args),"invalid range construct, low and high must be number.") do return

	from := ctx.peek_value(0)
	to   := ctx.peek_value(1)
	r    := cs.result

	get_op_binary(.OP_LESS,from.type,to.type)(from,to,r,ctx)
	range := create_range(from,to, AS_BOOL_PTR(r))

	_set_length(range,ctx)
	NUOOBJECT_VAL_PTR(variant_return,range)
}