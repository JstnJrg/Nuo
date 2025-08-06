package VM


call_fallback  :: proc(argc: int, dargc := 0)
{
// if callee == nil { runtime_error("invalid call of type '",GET_TYPE_NAME(callee_value),"'."); return .INTERPRET_RUNTIME_ERROR }
	cond_report_error(false,"invalid call.")
}


call_nfunction :: proc(argc : int, dargc := 0)
{
	call :: proc(fid,argc,dargc: int)
	{
		task  := current_vm.task
		chunk := function_db_get_chunk(fid)
		finfo := function_db_get_finfo(fid)
		iid   := finfo.iid

		cond_report_error(argc == finfo.arity," '%v' expects %v arguments, but got %v.",function_db_get_name(fid),finfo.arity,argc)
		cond_trace_stack(task.frame_count < MAX_FRAMES-1 ,"STACK OVER FLOW\n")

		current_vm.globals = import_db_get_globals(iid)
		frame             := &task.frames[task.frame_count]
		frame.ip           = &chunk.code[0]
		frame.locals       = task.stack[task.tos-argc-dargc:] 
		frame.iid          = iid
		frame.function_id  = fid

		advance_frame()
	}

	// Nota(jstn): o fid da função é guardado em _int.
	fid := AS_INT_PTR(pop())
	call(fid,argc,dargc)

}


call_ofunction :: proc(argc : int, dargc := 0)
{
	call :: proc(argc: int)
	{
		ofn := REINTERPRET_MEM(pop(),Ofunction)
		ctx := get_ctx()
		cs  := ctx.call_state

		prepare_call(argc,argc+1)
		pop_offset(argc+1)

		ofn(ctx)

		unref_slice(cs.args)
		push(cs.result)
	}

	call(argc)
}

call_ofunction_foreign :: proc(argc : int, dargc := 0)
{
	call :: proc(argc: int)
	{
		ofn := REINTERPRET_MEM(pop(),Ofunction)
		ctx := get_ctx()
		cs  := ctx.call_state

		prepare_call(argc,argc)
		pop_offset(argc)

		ofn(ctx)

		unref_slice(cs.args)
		push(cs.result)
	}

	call(argc)
}



//  ====================================== INTRINSICS ==========================================
@private
vm_call_main_function_db :: proc(fid: int ,main_argc : int = 0) -> ( sucess : bool )
{
	if !function_db_is_valid_id(fid) do return

	task  := current_vm.task
	chunk := function_db_get_chunk(fid)
	finfo := function_db_get_finfo(fid)

	if main_argc  != finfo.arity { _cond_report_error(false,"'%v' expects %v arguments, but got %v.",function_db_get_name(fid),finfo.arity,main_argc); return }

	frame    := &current_vm.task.frames[current_vm.task.frame_count]
	frame.ip  = &chunk.code[0]
	sucess    = true

	advance_frame()
	return
}


vm_call_function_db :: proc(fid,argc: int) -> ( sucess : bool )
{
	task  := current_vm.task
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