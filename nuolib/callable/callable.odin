package Callable


call :: proc(ctx: ^Context)
{
	cs   := ctx.call_state
	argc := cs.argc

	t    := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

	adata := make([]Value,argc+1,ctx.get_runtime_allocator())
	ctx.copy_args(cs.args[:],adata[:],argc+1)

  defer 
  { 
  	cs.args = cs.args[0:][:0]
  	unref_slice(adata[:]) 
  }

	_call(ctx)
}


bind :: proc(ctx: ^Context)
{
	cs   := ctx.call_state
	argc := cs.argc

	callable      := AS_NUOOBECT_PTR(ctx.peek_value(argc),NuoCallable)
	callable_args := &callable.args

	callable2      := create_obj_callable(); 
	callable_args2 := &callable2.args

	calle          := ODINFUNCTION_VAL(call)

	ref_value(&callable.callable)
	VARIANT2VARIANT_PTR(&callable.callable,&callable2.callable)
	VARIANT2VARIANT_PTR(&calle,&callable2.callee)

	if argc <= 0 { NUOOBJECT_VAL_PTR(cs.result,callable2); return }

	ref_slice(callable_args[:])
	ref_slice(cs.args[:argc])


	__append(callable_args2,callable_args[:])
	__append(callable_args2,cs.args[:argc])

	NUOOBJECT_VAL_PTR(cs.result,callable2)
}


get_bound_arguments :: proc(ctx: ^Context)
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'get_bound_arguments' expects %v, but got %v.",0,cs.argc) do return	

	callable      := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoCallable)
	args          := create_obj_array()

	ref_slice(callable.args[:])
	__append(&args.data,callable.args[:])

	NUOOBJECT_VAL_PTR(cs.result,args)
}





// has_connections :: proc(ctx: ^Context)
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 0,"'has_connections' expects %v, but got %v.",0,cs.argc) do return	

// 	signal := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoSignal)
// 	sdata  := &signal.data

// 	BOOL_VAL_PTR(cs.result,len(sdata) > 0)
// }

// get_connections :: proc(ctx: ^Context)
// {
// 	cs := ctx.call_state
// 	if ctx.runtime_error(cs.argc == 0,"'get_connections' expects %v, but got %v.",0,cs.argc) do return	

// 	signal := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoSignal)
// 	sdata  := &signal.data

// 	arr    := create_obj_array()
// 	__append(&arr.data,sdata[:])
// 	NUOOBJECT_VAL_PTR(cs.result,arr)
// }
