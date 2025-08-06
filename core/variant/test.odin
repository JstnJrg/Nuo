package Variant


onfunction_test :: proc(ctx: ^Context)
{
	println(ctx.call_state.args)
}