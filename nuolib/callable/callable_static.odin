package Callable


// atach
attach :: proc(ctx : ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_CALLABLE_PTR(ctx.peek_value(0)) ,"'attach' expects %v, but got %v and must be 'Callable'.",1,cs.argc) do return 		

	callable := create_obj_callable()
	fn       := ctx.peek_value(0)
	calle    := ODINFUNCTION_VAL(call)

	ref_value(fn)
	unref_value(&callable.callable)

	VARIANT2VARIANT_PTR(fn,&callable.callable)
	VARIANT2VARIANT_PTR(&calle,&callable.callee)

	NUOOBJECT_VAL_PTR(cs.result,callable)
}


