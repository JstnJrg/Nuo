package VM


@(optimization_mode = "favor_size")
read_instruction :: #force_inline proc "contextless" () -> Opcode 
{
	frame   := current_frame()
	byte_   := frame.ip
	frame.ip = ptr_offset(frame.ip,1)
	return Opcode(byte_^)
}

@(optimization_mode = "favor_size")
get_previous_instruction :: #force_inline proc "contextless" () -> Opcode 
{
	frame   := current_frame()
	return Opcode(ptr_offset(frame.ip,-1)^)
}

@(optimization_mode = "favor_size")
read_byte :: #force_inline proc "contextless" () -> int
{
	frame   := current_frame()
	byte_   := frame.ip
	frame.ip = ptr_offset(frame.ip,1)
	return byte_^
}


@(optimization_mode = "favor_size")
read_type :: #force_inline proc "contextless" () -> VariantType { return VariantType(read_index()) }

read_index :: read_byte


@(optimization_mode = "favor_size")
read_constant :: #force_inline proc "contextless" () -> ^Value { return &function_db_get_chunk(current_frame().function_id).constants[read_byte()] }

@(optimization_mode = "favor_size")
read_value    :: #force_inline proc "contextless" (indx: int) -> ^Value { return &function_db_get_chunk(current_frame().function_id).constants[indx] }


@(optimization_mode = "favor_size")
push_e :: #force_inline proc() 
{
	task        := get_task()
	when NUO_DEBUG do if task.tos >=  STACK_SIZE do panic("[STACK OVERFLOW]")
	task.tos += 1
}

@(optimization_mode = "favor_size")
push :: #force_inline proc(value: ^Value) 
{
	task        := get_task()
	when NUO_DEBUG do if task.tos >=  STACK_SIZE do panic("[STACK OVERFLOW]")
	
	task.stack[task.tos] = value^
	task.tos += 1
}

@(optimization_mode = "favor_size")
push_ref :: #force_inline proc(value: ^Value) 
{
	task        := get_task()
	when NUO_DEBUG do if task.tos >=  STACK_SIZE do panic("stack overflow")
	
	ref_value(value)
	task.stack[task.tos] = value^
	task.tos += 1
}

@(optimization_mode = "favor_size")
pop :: #force_inline proc() -> ^Value 
{
	task     := get_task()
	task.tos -= 1
	when NUO_DEBUG do if task.tos < 0 do panic("[STACK UNDERFLOW]")
	return &task.stack[task.tos]
}

@(optimization_mode = "favor_size")
pop_unref :: #force_inline proc () 
{
	task     := get_task()
	task.tos -= 1
	when NUO_DEBUG do if task.tos < 0 do panic("[STACK UNDERFLOW]")
	unref_value(&task.stack[task.tos])
}

/* Nota(jstn): desloca o tos com base em um offset, presumo que é seguro */
@(optimization_mode = "favor_size")
pop_offset_unref :: #force_inline proc (offset: int) 
{ 
	task     := get_task(); for i in 0..< offset do unref_value(&task.stack[task.tos-1-i])
	task.tos -= offset 
}

unref_slice :: #force_inline proc (args: []Value) { for &v in args do unref_value(&v) }


@(optimization_mode = "favor_size")
pop_offset :: #force_inline proc "contextless" (offset: int )
{
	task     := get_task()
	task.tos -= offset 
}



// @(optimization_mode = "favor_size")
// pop_offset :: #force_inline proc "contextless" (offset: int) { task     := get_task(); task.tos -= offset }

@(optimization_mode = "favor_size")
peek   :: #force_inline proc "contextless" (offset : int) -> ^Value { return &current_vm.task.stack[current_vm.task.tos-1-offset] }

@(optimization_mode = "favor_size")
peek_c :: #force_inline proc "contextless" () -> ^Value { return &current_vm.task.stack[current_vm.task.tos] }

@(optimization_mode = "favor_size")
peek_slice :: #force_inline proc "contextless" (offset: int) -> []Value 
{ 
	task     := get_task()
	return task.stack[task.tos-offset:][:offset] 
}

@(optimization_mode = "favor_size")
prepare_args :: #force_inline proc  (argc: int)  
{ 
	task    := get_task()
	cs      := get_call_state()

	cs.argc  = argc
	cs.args  = task.stack[task.tos-argc:][:argc] 
}

@(optimization_mode = "favor_size")
prepare_call :: #force_inline proc  (argc,argc_s: int)  
{ 
	task    := get_task()
	cs      := get_call_state()

	cs.argc   = argc
	cs.args   = task.stack[task.tos-argc_s:][:argc_s] 
	cs.result = &current_vm.return_
}



jump        :: #force_inline proc "contextless" ( address: int) 
{
	frame   := current_frame()
	frame.ip = &function_db_get_chunk(frame.function_id).code[address]
}


current_frame  :: proc "contextless" () -> ^CallFrame { return &current_vm.task.frames[current_vm.task.frame_count-1] }
advance_frame  :: proc "contextless" () { current_vm.task.frame_count += 1 }
rewind_frame   :: proc "contextless" () { current_vm.task.frame_count -= 1 }
update_globals :: proc "contextless" (iid: int) { current_vm.globals = import_db_get_globals(iid) }
end_frame      :: proc "contextless" () -> bool { return current_vm.task.frame_count == 0 }

report_error   :: proc(fmt: string, args: ..any)
{
	frame := current_frame()
	chunk := function_db_get_chunk(frame.function_id)
	index := ptr_sub(frame.ip,&chunk.code[0])

	//indx-1, previous instruction
	loc   := chunk.positions[index-1] 

	// C:/Users/JSTN JRG/Desktop/XscriptVersions/Nuo/nuo.odin(68:2) Error: Undeclared name: k
	nuo_eprint("[NUO RUNTIME] %s (%d:%d) Error: ", loc.file, loc.line, loc.column)
	nuo_eprint(fmt, ..args)
	nuo_eprint("\n")
}

_report_error   :: proc(fmt: string, args: ..any)
{
	// C:/Users/JSTN JRG/Desktop/XscriptVersions/Nuo/nuo.odin(68:2) Error: Undeclared name: k
	nuo_eprint("[NUO RUNTIME] Error: ")
	nuo_eprint(fmt, ..args)
	nuo_eprint("\n")
}

report_warning  :: proc(fmt: string, args: ..any)
{
	frame := current_frame()
	chunk := function_db_get_chunk(frame.function_id)
	index := ptr_sub(frame.ip,&chunk.code[0])

	//indx-1, previous instruction
	loc   := chunk.positions[index-1] 

	// C:/Users/JSTN JRG/Desktop/XscriptVersions/Nuo/nuo.odin(68:2) Error: Undeclared name: k
	nuo_eprint("[NUO RUNTIME] %s (%d:%d) Warning: ", loc.file, loc.line, loc.column)
	nuo_eprint(fmt, ..args)
	nuo_eprint("\n")
}


cond_report_error  :: proc(condiction: bool ,fmt: string, args: ..any) -> bool
{ 
	if condiction do return false

	report_error(fmt,..args)

	current_vm.err_count       += 1
	current_context.err_count  += 1

	return true
}

_cond_report_error  :: proc(condiction: bool ,fmt: string, args: ..any) -> bool
{ 
	if condiction do return false

	_report_error(fmt,..args)

	current_vm.err_count       += 1
	current_context.err_count  += 1

	return true
}

cond_report_warning  :: proc(condiction: bool ,fmt: string, args: ..any) -> bool { 
	if condiction do return false
	report_warning(fmt,..args) 
	return true
}


cond_trace_stack :: proc(condiction: bool,fmt: string, args: ..any)
{
	if condiction do return
	cond_report_error(condiction,fmt,..args)
	trace_stack()
}

trace_stack :: proc()
{
	task := get_task()
	
	for i in 0..= task.frame_count-1
	{
		frame    := &task.frames[i]
		fid      := frame.function_id

		chunk    := function_db_get_chunk(fid)
		finfo    := function_db_get_finfo(fid)

		index    := ptr_sub(frame.ip,&chunk.code[0])
		loc      := chunk.positions[index-1]
		
		eprintf("[NUO CALLFRAME] %s (%d:%d) frame %d: '%v'.\n", loc.file, loc.line, loc.column,i,function_db_get_name(fid))	
	}
}

instatiate :: proc (argc: int)
{
	if !IS_VARIANT_PTR(peek(0),.CLASS) { cond_report_error(false,"only classes are instantiable."); return }

	class_id := AS_INT_PTR(pop())

	method     : Value
	method_ptr := &method
	
	if class_db_get_method(class_id,CLASS_INIT_HASH,method_ptr,.INSTANCE) 
	{ 
		callee     := #force_inline get_call_type(method_ptr)
		push(method_ptr)
		callee(argc) 
    }
    else do cond_report_error(argc == 0, "expected 0 arguments, but got %v.",argc)

    instance, error := class_db_call_creator(class_id,get_ctx())
    if error do return

    NUOOBJECT_VAL_PTR(peek_c(),instance)
	push_e()
}


super_call :: proc()
{
	argc        := read_index()
	sid         := read_index()
	method_hash := string_db_get_hash(sid)
	instance    := AS_NUOOBECT_PTR(peek(0),NuoInstance)

	method      :  Value
	method_ptr  := &method

	if class_db_super_get_method(instance.cid,method_hash,method_ptr,.INSTANCE)
	{
		callee := get_call_type(method_ptr)
		push(method_ptr)
		callee(argc,1)
		return
	}

	cond_report_error(false,"method '%v' not declared by Class '%v' super.",string_db_get_string(sid),class_db_get_class_name(instance.cid))
}


match_case :: #force_inline proc ()
{
	case_count      := read_index()
	condition       := pop()

	start_addresses := peek_slice(case_count); pop_offset(case_count)
	cases           := peek_slice(case_count); pop_offset(case_count)

	ctx := get_ctx()
    r   : Value

    ctx.disable_gc()
    
    defer 
    {
    	ctx.enable_gc()
    	unref_value(condition)
    	unref_slice(cases)
    }

    for &_case, idx in cases
    {

		op_function := get_op_binary(.OP_EQUAL,condition.type,_case.type)
		op_function(condition,&_case,&r,ctx)

		if AS_BOOL_PTR(&r)
		{
			jump(AS_INT_PTR(&start_addresses[idx])+1) 
			return
		}

    } 
	
}