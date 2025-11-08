package Signal

_append 		:: proc(arr: ^$T/[dynamic]$E, what: ^E)  { append(arr,what^)  }
__append 		:: proc(arr: ^$T/[dynamic]$E, what: []E) { append(arr,..what) }


_emit_signal    :: proc(carr: ^$T/[dynamic]Value, parr: []Value, ctx: ^Context)
{
	argc := len(parr)

	for &value in carr
	{
		callable := &value
		for &p in parr { ref_value(&p); ctx.push_value(&p) }

		if ctx.call(callable,argc,0) do return
		
		unref_value(ctx.pop_value())
	}
}


_connect   :: proc(sarr: ^$T/[dynamic]Value, ctx: ^Context)
{
	callable := ctx.peek_value(0)
	result   := ctx.call_state.result

	for &value,idx in sarr
	{
		get_op_binary(.OP_EQUAL,callable.type,value.type)(callable,&value,result,ctx)
		if ctx.runtime_error(!AS_BOOL_PTR(result),"Signal already connected to given callable.") do return
	}

	ref_value(callable)
	_append(sarr,callable)
}


_disconnect   :: proc(carr: ^$T/[dynamic]Value, ctx: ^Context)
{
	callable := ctx.peek_value(0)
	result   := ctx.call_state.result

	for &value,idx in carr
	{
		get_op_binary(.OP_EQUAL,callable.type,value.type)(callable,&value,result,ctx)
		if AS_BOOL_PTR(result) 
		{
			unref_value(callable) 
			unordered_remove(carr,idx)
			return 
		}
	}

	ctx.runtime_error(false,"nonexistent connection.")
}