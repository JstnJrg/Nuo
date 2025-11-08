package Variant


tests :: proc()
{
	VARIANNT_DEBUG()
	// ci := class_db_register_class("Test")
	// class_db_register_class_method(ci,"_deinit",ODINFUNCTION_VAL(_deinit_text))

}



_deinit_text :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	NIL_VAL_PTR(cs.result)
}