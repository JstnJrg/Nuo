#+private

package Math

register_operators :: proc()
{
	register_op(.OP_MULT_MULT,.INT,.INT,variant_variant_mult_mult)
	register_op(.OP_MULT_MULT,.FLOAT,.INT,variant_variant_mult_mult)
	register_op(.OP_MULT_MULT,.INT,.FLOAT,variant_variant_mult_mult)
	register_op(.OP_MULT_MULT,.FLOAT,.FLOAT,variant_variant_mult_mult)
}


variant_variant_mult_mult :: #force_inline proc(lhs,rhs,ret: ^Value, ctx: ^Context)
{
	a,b : Float

	IS_NUMERIC_PTR(lhs,&a)
	IS_NUMERIC_PTR(rhs,&b)

	FLOAT_VAL_PTR(ret,pow(a,b))
}