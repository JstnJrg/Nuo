package Signal

connect :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_CALLABLE_PTR(ctx.peek_value(0)) ,"'connect' expects %v, but got %v and must be 'Callable'.",1,cs.argc) do return	

	signal := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoSignal)
	sdata  := &signal.data

          ctx.disable_gc()
    defer ctx.enable_gc()

          ctx.trace_error(false)
    defer ctx.trace_error(true)
	
	_connect(sdata,ctx)    
	NIL_VAL_PTR(cs.result)
}

disconnect :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_CALLABLE_PTR(ctx.peek_value(0)) ,"'disconnect' expects %v, but got %v and must be 'Callable'.",1,cs.argc) do return	

	signal := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoSignal)
	sdata  := &signal.data

          ctx.disable_gc()
    defer ctx.enable_gc()

          ctx.trace_error(false)
    defer ctx.trace_error(true)

	_disconnect(sdata,ctx)
	NIL_VAL_PTR(cs.result)
}

emit :: proc(ctx: ^Context)
{
	cs   := ctx.call_state
	argc := cs.argc

	signal := AS_NUOOBECT_PTR(ctx.peek_value(argc),NuoSignal)
	sdata  := &signal.data
	
	  t    := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

	adata := make([]Value,argc+1,ctx.get_runtime_allocator())
	ctx.copy_args(cs.args[:],adata[:],argc+1)

  defer 
  { 
  	cs.args = cs.args[0:][:0]
  	unref_slice(adata[:]) 
  }

	what   := adata[0:][:argc] // args

	_emit_signal(sdata,what,ctx)
	NIL_VAL_PTR(cs.result)
}

has_connections :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'has_connections' expects %v, but got %v.",0,cs.argc) do return	

	signal := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoSignal)
	sdata  := &signal.data

	BOOL_VAL_PTR(cs.result,len(sdata) > 0)
}

get_connections :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'get_connections' expects %v, but got %v.",0,cs.argc) do return	

	signal := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoSignal)
	sdata  := &signal.data

	arr    := create_obj_array()
	__append(&arr.data,sdata[:])
	NUOOBJECT_VAL_PTR(cs.result,arr)
}
