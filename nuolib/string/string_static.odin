package String


stringfy :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 ,"'stringfy' expects %v, but got %v and must be 'variant'.",1,cs.argc) do return

	n_string  := create_obj_string()

	t         := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)


	nuostring_write_data(aprint_any(ctx.peek_value(0),ctx.get_runtime_allocator()),n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}