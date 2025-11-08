package Callable


_append 		:: proc(arr: ^$T/[dynamic]$E, what: ^E)  { append(arr,what^)  }
__append 		:: proc(arr: ^$T/[dynamic]$E, what: []E) { append(arr,..what) }


_call    :: proc(ctx: ^Context)
{
	args  := &ctx.call_state.args
	argc  := ctx.call_state.argc

	for &value in args[:argc] { ref_value(&value); ctx.push_value(&value) }
	if ctx.call(ctx.peek_value(argc),argc,0) do return
	
	VARIANT2VARIANT_PTR(ctx.pop_value(),ctx.call_state.result)
}


// _connect   :: proc(sarr: ^$T/[dynamic]Value, ctx: ^Context)
// {
// 	callable := ctx.peek_value(0)
// 	result   := ctx.call_state.result

// 	for &value,idx in sarr
// 	{
// 		get_op_binary(.OP_EQUAL,callable.type,value.type)(callable,&value,result,ctx)
// 		if ctx.runtime_error(!AS_BOOL_PTR(result),"Signal already connected to given callable.") do return
// 	}

// 	ref_value(callable)
// 	_append(sarr,callable)
// }


// _disconnect   :: proc(carr: ^$T/[dynamic]Value, ctx: ^Context)
// {
// 	callable := ctx.peek_value(0)
// 	result   := ctx.call_state.result

// 	for &value,idx in carr
// 	{
// 		get_op_binary(.OP_EQUAL,callable.type,value.type)(callable,&value,result,ctx)
// 		if AS_BOOL_PTR(result) 
// 		{
// 			unref_value(callable) 
// 			unordered_remove(carr,idx)
// 			return 
// 		}
// 	}

// 	ctx.runtime_error(false,"nonexistent connection.")
// }