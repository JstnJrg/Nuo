package Variant


/*
	Nota(jstn): para se evitar uma tabela paralela de
	constructors, usaremos a tabela de operadores
	
	get_op_unary será usado, .nil,.nil será a chave de acesso
*/

regiser_constructor :: register_op

register_variant_constructors :: proc()
{
	regiser_constructor(.OP_CONSTRUCT,.VECTOR2,.VECTOR2,construct_vec2)
	regiser_constructor(.OP_CONSTRUCT,.ARRAY,.ARRAY,construct_array)

	regiser_constructor(.OP_CONSTRUCT,.RECT2,.RECT2,construct_rect2)
	regiser_constructor(.OP_CONSTRUCT,.TRANSFORM2D,.TRANSFORM2D,construct_transform2D)

	regiser_constructor(.OP_CONSTRUCT,.COLOR,.COLOR,construct_color)
	regiser_constructor(.OP_CONSTRUCT,.MAP,.MAP,construct_map)

	regiser_constructor(.OP_CONSTRUCT,.SIGNAL,.SIGNAL,construct_signal)
	// regiser_constructor(.OP_CONSTRUCT,.CALLABLE,.CALLABLE,construct_callable)

	regiser_constructor(.OP_CONSTRUCT,.COMPLEX,.COMPLEX,construct_complex)
}


construct_vec2 :: #force_inline proc(_,_,variant_return: ^Value, ctx: ^Context)
{
	cs   := ctx.call_state
	vec2 : Vec2

	// Nota(jstn): já é verificado no codegen
	// if ctx.runtime_error(cs.argc == 2, "Vec2 construct expects 2 arguments") do return
	if ctx.runtime_error(IS_NUMERIC_PTR(ctx.peek_value(0),&vec2[0]) && IS_NUMERIC_PTR(ctx.peek_value(1),&vec2[1]),"invalid signature for Vec2 construct. expected Vec2(%v,%v)",GET_TYPE_NAME(.FLOAT),GET_TYPE_NAME(.FLOAT)) do return

	VECTOR2_VAL_PTR(variant_return,&vec2)
}

construct_complex :: #force_inline proc(_,_,variant_return: ^Value, ctx: ^Context)
{
	cs     := ctx.call_state
	complex : Complex

	if ctx.runtime_error(IS_NUMERIC_PTR(ctx.peek_value(0),&complex[0]) && IS_NUMERIC_PTR(ctx.peek_value(1),&complex[1]),"invalid signature for COmplex construct. expected Complex(%v,%v)",GET_TYPE_NAME(.FLOAT),GET_TYPE_NAME(.FLOAT)) do return
	COMPLEX_VAL_PTR(variant_return,&complex)
}

construct_color :: #force_inline proc(_,_,variant_return: ^Value, ctx: ^Context)
{
	cs    := ctx.call_state
	color : Color

	// Nota(jstn): já é verificado no codegen
	// if ctx.runtime_error(cs.argc == 4, "Color construct expects 4 arguments") do return

	for i in 0..<4 do if ctx.runtime_error(IS_INT_PTR(ctx.peek_value(i),&color[i]),"invalid signature for Color construct. expected Color(%v,%v,%v,%v)",GET_TYPE_NAME(.INT),GET_TYPE_NAME(.INT),GET_TYPE_NAME(.INT),GET_TYPE_NAME(.INT)) do return
	COLOR_VAL_PTR(variant_return,&color)
}

construct_rect2 :: #force_inline proc(_,_,variant_return: ^Value, ctx: ^Context)
{
	cs   := ctx.call_state

	if ctx.runtime_error(cs.argc == 2, "Rect2 construct expects 2 arguments") do return
	if ctx.runtime_error(IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2) && IS_VARIANT_PTR(ctx.peek_value(1),.VECTOR2),"invalid signature for Rect2 construct. expected Rect2(%v,%v)",GET_TYPE_NAME(.VECTOR2),GET_TYPE_NAME(.VECTOR2)) do return

	pos  := AS_VECTOR2_PTR(ctx.peek_value(0))
	size := AS_VECTOR2_PTR(ctx.peek_value(1))
	r    := Rect2{pos^,size^}

	RECT2_VAL_PTR(variant_return,&r)
}


construct_transform2D :: #force_inline proc(_,_,variant_return: ^Value, ctx: ^Context)
{
	cs   := ctx.call_state

	if ctx.runtime_error(cs.argc == 3, "Transform2D construct expects 3 arguments") do return
	if ctx.runtime_error(IS_VARIANT_PTR(ctx.peek_value(0),.VECTOR2) && IS_VARIANT_PTR(ctx.peek_value(1),.VECTOR2) && IS_VARIANT_PTR(ctx.peek_value(2),.VECTOR2),"invalid signature for Transform2D construct. expected Transform2D(%v,%v,%v)",GET_TYPE_NAME(.VECTOR2),GET_TYPE_NAME(.VECTOR2),GET_TYPE_NAME(.VECTOR2)) do return

	origin  := AS_VECTOR2_PTR(ctx.peek_value(2))
	x_axis  := AS_VECTOR2_PTR(ctx.peek_value(0))
	y_axis  := AS_VECTOR2_PTR(ctx.peek_value(1))

	NUOOBJECT_VAL_PTR(variant_return,create_transform2(x_axis,y_axis,origin))
}


construct_array :: #force_inline proc(_,_,variant_return: ^Value, ctx: ^Context)
{
	cs   := ctx.call_state
	args := cs.args

	array := create_obj_array()
	append(&array.data,..args)

	NUOOBJECT_VAL_PTR(variant_return,array)
}


construct_signal :: #force_inline proc(_,_,variant_return: ^Value, ctx: ^Context)
{
	cs     := ctx.call_state
	signal := create_obj_signal()
	NUOOBJECT_VAL_PTR(variant_return,signal)
}


construct_map :: #force_inline proc(_,_,variant_return: ^Value, ctx: ^Context)
{
	cs   := ctx.call_state
	argc := cs.argc

	_map := create_obj_map()
	data := &_map.data

	for idx := 0; idx < argc; idx += 2
	{
		key   := ctx.peek_value(idx)
		value := ctx.peek_value(idx+1)
		hash  := variant_hash(key)

		if hash in data
		{
			me := &data[hash]
			unref_value(&me.key)
			unref_value(&me.value)
		}


		data[hash] = MapEntry{key^,value^}
	}

	NUOOBJECT_VAL_PTR(variant_return,_map)
}
