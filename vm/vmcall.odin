package VM


call_fallback  :: proc(argc: int, dargc := 0)
{ cond_report_error(false,"invalid call.") }


call_nfunction :: proc(argc : int, dargc := 0)
{
	call :: proc(fid,argc,dargc: int)
	{
		task  := get_task()
		chunk := function_db_get_chunk(fid)
		finfo := function_db_get_finfo(fid)
		iid   := finfo.iid

		cond_report_error(argc == finfo.arity," '%v' expects %v arguments, but got %v.",function_db_get_name(fid),finfo.arity,argc)
		cond_trace_stack(task.frame_count < MAX_FRAMES-1 ,"STACK OVER FLOW\n")

		current_vm.globals = import_db_get_globals(iid)
		frame             := &task.frames[task.frame_count]
		frame.dirty_offset = 0 //Nota(jstn): restaura
		frame.ip           = &chunk.code[0]
		frame.locals       = task.stack[task.tos-argc-dargc:] 
		frame.iid          = iid
		frame.function_id  = fid

		advance_frame()
	}

	// Nota(jstn): o fid da função é guardado em _int.
	call(AS_INT_PTR(pop()),argc,dargc)

}

call_ofunction :: proc(argc : int, dargc := 0)
{
	call :: proc(argc: int, dargc := 0 )
	{
		ofn := REINTERPRET_MEM(pop(),Ofunction)
		ctx := get_ctx()
		cs  := ctx.call_state

		prepare_call(argc,argc+dargc)
		pop_offset(argc+dargc)

		ofn(ctx)

		unref_slice(cs.args)
		push(cs.result)
	}

	call(argc,dargc)
}

call_sfunction :: proc(argc : int, dargc := 0)
{
	call :: proc(argc: int, dargc := 0 )
	{
		sm    := REINTERPRET_MEM_PTR(pop(),SafeMethod)
		ctx   := get_ctx()
		cs    := ctx.call_state
		ofn   := sm.callable

		prepare_call(argc,argc+dargc)
		pop_offset(argc+dargc)

		if safe_check_args(sm,ctx)
		{	
			ofn(ctx)

			unref_slice(cs.args)
			push(cs.result)
			
			return
		}

		
		types := sm.args_types[0:][:sm.argc]
		_cond_report_error(false,"invalid function signature. expects %v",types)
	}

	call(argc,dargc)
}

call_bfunction :: proc(argc : int, dargc := 0)
{
	vbound := pop()
	bound  := AS_NUOOBECT_PTR(vbound,BoundMethod)
	method := &bound.method
	this   := &bound.this

	callee := get_call_type(method)

	ref_value(this) // da função (this parametro)
	unref_value(vbound)

	push(this)
	push(method)

	callee(argc,1)
}


call_cfunction :: proc(argc : int, dargc := 0)
{
	callable := AS_NUOOBECT_PTR(peek(0),NuoCallable)
	ccallee  := &callable.callee
	callee   := get_call_type(ccallee)

	push(ccallee)
	callee(argc,1) // +1
}


call_nfunction_foreign :: proc(argc : int, dargc := 0)
{
	call :: proc(fid,argc,dargc: int)
	{
		task  := get_task()
		chunk := function_db_get_chunk(fid)
		finfo := function_db_get_finfo(fid)
		iid   := finfo.iid

		_cond_report_error(argc == finfo.arity," '%v' expects %v arguments, but got %v.",function_db_get_name(fid),finfo.arity,argc)
		_cond_trace_stack(task.frame_count < MAX_FRAMES-1 ,"STACK OVER FLOW\n")

		current_vm.globals = import_db_get_globals(iid)
		frame             := &task.frames[task.frame_count]
		frame.dirty_offset = task.frame_count
		frame.ip           = &chunk.code[0]
		frame.locals       = task.stack[task.tos-argc-dargc:] 
		frame.iid          = iid
		frame.function_id  = fid

		advance_frame()
	}

	// Nota(jstn): o fid da função é guardado em _int.
	call(AS_INT_PTR(pop()),argc,dargc)

}


call_bfunction_foreign :: proc(argc : int, dargc := 0)
{
	vbound := pop()
	bound  := AS_NUOOBECT_PTR(vbound,BoundMethod)
	method := &bound.method
	this   := &bound.this

	callee := get_call_type(method)

	ref_value(this) // da função (this parametro)
	unref_value(vbound)

	push(this)
	push(method)

	callee(argc,1+dargc)
}



call_ofunction_foreign :: proc(argc : int, dargc := 0)
{
	call :: proc(argc,dargc: int)
	{
		ofn := REINTERPRET_MEM(pop(),Ofunction)
		ctx := get_ctx()
		cs  := ctx.call_state

		prepare_call(argc,argc+dargc)
		pop_offset(argc+dargc)

		ofn(ctx)

		unref_slice(cs.args)
		push(cs.result)
	}

	call(argc,dargc)
}



//  ====================================== INTRINSICS ==========================================
// @private
// vm_call_main_function_db :: proc(fid: int ,main_argc : int = 0) -> ( sucess : bool )
// {
// 	if !function_db_is_valid_id(fid) do return

// 	task  := get_task()
// 	chunk := function_db_get_chunk(fid)
// 	finfo := function_db_get_finfo(fid)

// 	if main_argc  != finfo.arity { _cond_report_error(false,"'%v' expects %v arguments, but got %v.",function_db_get_name(fid),finfo.arity,main_argc); return }

// 	frame    := &task.frames[task.frame_count]
// 	frame.ip  = &chunk.code[0]
// 	sucess    = true

// 	advance_frame()
// 	return
// }


vm_call_function_db :: proc(fid,argc: int) -> ( sucess : bool )
{
	task  := get_task()
	chunk := function_db_get_chunk(fid)
	finfo := function_db_get_finfo(fid)
	iid   := finfo.iid

	if argc != finfo.arity { _cond_report_error(false,"'%v' expects %v arguments, but got %v.",function_db_get_name(fid),finfo.arity,argc); return }

	current_vm.globals = import_db_get_globals(iid)
	frame             := &task.frames[task.frame_count]
	frame.ip           = &chunk.code[0]
	frame.locals       = task.stack[task.tos-argc:]   
	frame.iid          = iid
	frame.function_id  = fid
	sucess             = true

	advance_frame()
	return
}