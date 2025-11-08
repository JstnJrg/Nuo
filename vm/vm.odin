#+private
package VM


setup_and_interpret    :: proc{setup_and_interpret_0,setup_and_interpret_1} 

setup_and_interpret_0  :: proc(fid,argc: int)        -> InterpretResult { return vm_call_function_db(fid,argc) ? interpret():.INTERPRET_RUNTIME_ERROR }
setup_and_interpret_1  :: proc(fn: ^Value,argc: int) -> InterpretResult { return vm_call_function_db(AS_INT_PTR(fn),argc) ? interpret():.INTERPRET_RUNTIME_ERROR }


@(private)
interpret            :: proc() -> InterpretResult { return run() }

@(private="file",optimization_mode="favor_size")
run :: proc() -> InterpretResult
{
	ctx     := get_vm_ctx()
	frame   := current_frame()
	_return := get_temp_return()

	out: for
	{
		#partial switch read_instruction()
		{
		  case .OP_LOAD: push(read_constant())

		  case .OP_LITERAL:

		  	fn := get_op_unary(read_instruction(),.NIL)
		  	fn(nil,nil,peek_c(),ctx)
		  	push_e()

		  case .OP_POP: pop_unref()

		  case .OP_SUB_SP: pop_offset_unref(read_index())

		  case .OP_UNARY:
		  	
		  	op  := read_instruction()
		  	rhs := pop()
		  	r   := peek_c()

		  	fn  := get_op_unary(op,rhs.type)
		  	fn(nil,rhs,r,ctx)  

			if check_error() do return safe_exit()
			push_e()

		  case .OP_BINARY:

			op  := read_instruction()
			rhs := pop()
			lhs := pop()
			r   := peek_c()

			fn  := get_op_binary(op,lhs.type,rhs.type)
			fn(lhs,rhs,r,ctx) 

			if check_error() do return safe_exit()
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

			if check_error() do return safe_exit()
			push_e()		        

		  case .OP_DEFINE_GLOBAL:
		  	table_set(get_globals(),string_db_get_hash(read_index()),peek(0))

		  case .OP_GET_GLOBAL: 
		  	table_get(get_globals(),string_db_get_hash(read_index()),peek_c()) ; push_e()

		  case .OP_SET_GLOBAL: 
		  	table_set(get_globals(),string_db_get_hash(read_index()),peek(0)) 

		  case .OP_GET_LOCAL: 
		  	push_ref(&frame.locals[read_index()])//push_ptr(&frame.slots[read_byte()])

		  case .OP_SET_LOCAL:

		  	local := &frame.locals[read_index()]
		  	value := peek(0)

			ref_value(value)
			unref_value(local)
			VARIANT2VARIANT_PTR(value,local)

		case .OP_JUMP_IF_FALSE: 

			jmp_address := read_index()
			if #force_inline falsey(peek(0)) do frame.ip = &function_db_get_chunk(frame.function_id).code[jmp_address]
			
		case .OP_JUMP_IF_TRUE: 

			jmp_address := read_byte()
			if !falsey(peek(0)) do frame.ip = &function_db_get_chunk(frame.function_id).code[jmp_address]

		case .OP_JUMP : frame.ip = &function_db_get_chunk(frame.function_id).code[read_index()]

		case .OP_MATCH: match_case()

		case .OP_CALL:

			argc   	:= read_index()
			callee  := get_call_type(peek(0))
			callee(argc)
			          
			if check_error() do return safe_exit()
			frame = current_frame()

		case .OP_CALL1:

			super_call()

			if check_error() do return safe_exit()
			frame = current_frame()

		case .OP_INHERIT:

			lhs := peek(1)
			rhs := peek(0)
			op  := read_instruction()

			fn  := get_op_binary(op,lhs.type,rhs.type)
			fn(lhs,rhs,peek_c(),ctx)  

			if check_error() do return safe_exit()		

		case .OP_INVOKE:

			handler := get_handler(peek(0))
			handler(read_index())

			if check_error() do return safe_exit()

			frame = current_frame()

		case .OP_GET_PROPERTY:

			op     := read_instruction()
			sidi   := read_index()
			sid_va := read_value(sidi)

			// nota(jsnt): não foi foi unref
			object := pop()
			r      := peek_c()

		  	fn     := get_op_binary(op,object.type,sid_va.type)
			fn(object,sid_va,r,ctx) 

			if check_error() do return safe_exit() 
			push_e()

		case .OP_SET_PROPERTY:

			op     := read_instruction()
			sidi   := read_index()
			sid_va := read_value(sidi) //property

			expr   := peek(1)
			object := peek(0)

		  	fn     := get_op_binary(op,object.type,sid_va.type)
			fn(object,sid_va,expr,ctx)  

			if check_error() do return safe_exit()
	
		case .OP_SET_INDEXING:

			op      := read_instruction()
			obj  	:= pop()
			indx 	:= pop()
			assign  := peek(0)

			fn      := get_op_binary(op,obj.type,indx.type)
			fn(obj,indx,assign,ctx)  

			if check_error() do return safe_exit()

    	case .OP_STORE_RETURN: VARIANT2VARIANT_PTR(pop(),_return)

		case .OP_LOAD_RETURN : push(_return)

		case .OP_RETURN: 

			r_result     := pop()
			dirty_offset := frame_is_dirty()
			
			rewind_frame()
			push(r_result)

			// Nota(jstn): quem tira da pilha é o usuario
			if end_frame(dirty_offset) 
			{ 
				when NUO_DEBUG  do println("[FINISH] -> ",get_task().tos)
				return .INTERPRET_OK 
			}
			
			frame = current_frame()
			set_globals(frame.iid)

		case : 
		  	println("[NOT HANDLER]")
		  	break out
		}



	}






	return .INTERPRET_RUNTIME_ERROR
}