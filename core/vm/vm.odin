#+private
package VM


setup_and_interpret    :: proc{setup_and_interpret_0,setup_and_interpret_1} 
setup_and_interpret_0  :: proc(fid,argc: int)        -> InterpretResult { return vm_call_function_db(fid,argc) ? interpret():.INTERPRET_RUNTIME_ERROR }
setup_and_interpret_1  :: proc(fn: ^Value,argc: int) -> InterpretResult 
{
    fid := AS_INT_PTR(fn)
	return vm_call_function_db(fid,argc) ? interpret():.INTERPRET_RUNTIME_ERROR 
}


@(private)
interpret            :: proc() -> InterpretResult { return run() }

@(private="file",optimization_mode="favor_size")
run :: proc() -> InterpretResult
{
	frame := current_frame()
	ctx   := get_vm_ctx()

	out: for
	{
		#partial switch read_instruction()
		{
		  case .OP_LOAD: 
		  	
		  	VARIANT2VARIANT_PTR(read_constant(),peek_c())
		  	push_e()

		  case .OP_LITERAL:

		  	op          := read_instruction()
		  	op_function := get_op_unary(op,.NIL)
		  	op_function(nil,nil,peek_c(),ctx)
		  	push_e()

		  case .OP_POP: pop_unref()

		  case .OP_SUB_SP: pop_offset_unref(read_index())

		  case .OP_UNARY:
		  	
		  	op  := read_instruction()
		  	rhs := pop()
		  	r   := peek_c()

		  	op_function := get_op_unary(op,rhs.type)
			op_function(nil,rhs,r,ctx)  

			if check_error() do return .INTERPRET_RUNTIME_ERROR
			push_e()

		  case .OP_BINARY:

			op  := read_instruction()
			rhs := pop()
			lhs := pop()
			r   := peek_c()

			op_function := get_op_binary(op,lhs.type,rhs.type)
			op_function(lhs,rhs,r,ctx)  

			if check_error() do return .INTERPRET_RUNTIME_ERROR
			push_e()	

		  case .OP_CONSTRUCT:

			op   := read_instruction()
			argc := read_index(); prepare_args(argc)
			type := read_type()
		
			// Nota(jstn): a responsabilidade de desreferenciar os argumentos
			// é dos constructores.
			pop_offset(argc)

		  	op_function := get_op_binary(op,type,type)
			op_function(nil,nil,peek_c(),ctx) 

			if check_error() do return .INTERPRET_RUNTIME_ERROR
			push_e()		        

		  case .OP_DEFINE_GLOBAL:

		  	sid  := read_index()
		  	hash := string_db_get_hash(sid)
		  	table_set(get_globals(),hash,peek(0))

		  case .OP_GET_GLOBAL:

		  	sid  := read_index()
		  	hash := string_db_get_hash(sid)

		  	table_get(get_globals(),hash,peek_c()) 
		  	push_e()

		  case .OP_SET_GLOBAL:

		  	sid  := read_index()
		  	hash := string_db_get_hash(sid)
		  	table_set(get_globals(),hash,peek(0)) 

		  case .OP_GET_LOCAL: push_ref(&frame.locals[read_index()])//push_ptr(&frame.slots[read_byte()])

		  case .OP_SET_LOCAL:

		  	index := read_index()
		  	local := &frame.locals[index]
		  	value := peek(0)

			ref_value(value)
			unref_value(local)
			VARIANT2VARIANT_PTR(value,local)

		case .OP_JUMP_IF_FALSE: 

			jmp_address := read_index()
			if #force_inline falsey(peek(0)) do frame.ip = &function_db_get_chunk(frame.function_id).code[jmp_address]
			
		case .OP_JUMP_IF_TRUE: 

			jmp_address := read_byte()
			if ! #force_inline falsey(peek(0)) do frame.ip = &function_db_get_chunk(frame.function_id).code[jmp_address]

		case .OP_JUMP: frame.ip = &function_db_get_chunk(frame.function_id).code[read_index()]

		case .OP_MATCH: match_case()

		case .OP_CALL:

			argc   		 := read_index()
			callee_value := peek(0)
				
			callee := #force_inline get_call_type(callee_value) 
			          #force_inline callee(argc)
			if check_error() do return .INTERPRET_RUNTIME_ERROR
			frame = current_frame()

		case .OP_CALL1:

			super_call()

			if check_error() do return .INTERPRET_RUNTIME_ERROR
			frame = current_frame()


		case .OP_INHERIT:

			lhs := peek(1)
			rhs := peek(0)
			op  := read_instruction()

			op_function := get_op_binary(op,lhs.type,rhs.type)
			op_function(lhs,rhs,peek_c(),ctx)  

			if check_error() do return .INTERPRET_RUNTIME_ERROR		

		case .OP_NEW:

			instatiate(read_index())	
			if check_error() do return .INTERPRET_RUNTIME_ERROR
			frame = current_frame()


		case .OP_INVOKE:

			handle := get_handle(peek(0))
			handle(read_index())

			if check_error() do return .INTERPRET_RUNTIME_ERROR
			frame = current_frame()

		case .OP_GET_PROPERTY:

			op     := read_instruction()
			sidi   := read_index()
			sid_va := read_value(sidi)

			// nota(jsnt): não foi foi unref
			object := pop()
			r      := peek_c()

		  	op_function := get_op_binary(op,object.type,sid_va.type)
			op_function(object,sid_va,r,ctx) 

			if check_error() do return .INTERPRET_RUNTIME_ERROR 
			push_e()

		case .OP_SET_PROPERTY:

			op     := read_instruction()
			sidi   := read_index()
			sid_va := read_value(sidi) //property

			expr   := peek(1)
			object := peek(0)

		  	op_function := get_op_binary(op,object.type,sid_va.type)
			op_function(object,sid_va,expr,ctx)  

			if check_error() do return .INTERPRET_RUNTIME_ERROR
	
		case .OP_SET_INDEXING:

			op      := read_instruction()
			obj  	:= pop()
			indx 	:= pop()
			assign  := peek(0)

			op_function := get_op_binary(op,obj.type,indx.type)
			op_function(obj,indx,assign,ctx)  

			if check_error() do return .INTERPRET_RUNTIME_ERROR

    	case .OP_STORE_RETURN: VARIANT2VARIANT_PTR(pop(),&current_vm.return_)

		case .OP_LOAD_RETURN : push(&current_vm.return_)

		case .OP_RETURN: 

			r_result := pop()
			rewind_frame()

			if end_frame() 
			{ 
				when NUO_DEBUG  do println("[FINISH] -> ",get_task().tos)
				return .INTERPRET_OK 
			}

			push(r_result)

			frame = current_frame()
			update_globals(frame.iid)

			// Nota(jstn): para funções que são chamadas exteriormente
			if vm_can_exit() do return .INTERPRET_OK

		case : 
		  	println("[NOT HANDLER]")
		  	break out
		}



	}






	return .INTERPRET_RUNTIME_ERROR
}