#+private

package VM

@(private="file") current_codegen : ^CodeGen

PROGRAM_FUNCTION_NAME :: `_____PROGRAM_____`

LabelType   :: enum u8 {BREAK,CONTINUE}

LabelData   :: struct 
{
	address : int,
	depth   : int,
	type    : LabelType
}

CaseData   :: struct 
{ 
	start_address: int,
  	end_address  : int 
}


CodeGen :: struct
{
	labels : [dynamic]LabelData,
	fid    : int,
	iid    : int,
	ldepth : int
}

codegen_set_fid      :: proc "contextless" (fid: int) { current_codegen.fid = fid   }
codegen_get_fid      :: proc "contextless" () -> int  { return current_codegen.fid  }

codegen_set_iid      :: proc "contextless" (iid: int) { current_codegen.iid = iid   }
codegen_get_iid      :: proc "contextless" () -> int  { return current_codegen.iid  }

codegen_initialize_global :: proc(gname: string)  { import_db_initialize_value(codegen_get_iid(),gname) }

codegen_push_label        :: proc (l : LabelData) { append(&current_codegen.labels,l) }
codegen_register_break    :: proc(address: int)   { codegen_push_label(LabelData{address,current_codegen.ldepth,.BREAK}) }
codegen_register_continue :: proc(address: int)   { codegen_push_label(LabelData{address,current_codegen.ldepth,.CONTINUE}) }
codegen_is_label          :: proc(l: ^LabelData, type: LabelType) -> bool { return l.type == type }
codegen_get_label_address :: proc(l: ^LabelData) -> int { return l.address }
codegen_get_label_array   :: proc "contextless" () -> ^[dynamic]LabelData { return &current_codegen.labels }

codegen_begin_label_depth :: proc "contextless" () -> int 
{ 
	current_codegen.ldepth += 1
	return current_codegen.ldepth
}

codegen_end_label_depth   :: proc "contextless" () { current_codegen.ldepth -= 1 }
codegen_is_same_ldepth    :: proc "contextless" (lid: int,l: ^LabelData) -> bool { return lid == l.depth }
codegen_clear_labels      :: proc() { if len(current_codegen.labels) > 0 do clear(&current_codegen.labels) }

codegen_create_adynamic   :: proc($T: typeid) -> [dynamic]T {return ctx_amake([dynamic]T) }



codegen_finish       :: proc () -> int 
{ 
	loc := peek_cloc()
	gerate_bytecode(create_literal_node(.OP_NIL,loc),0)
	codegen_emit_opcode(.OP_RETURN,loc) 
	return codegen_get_fid()
}


codegen_init         :: proc() 
{ 
	current_codegen = ctx_new(CodeGen) 
	labels         := ctx_amake([dynamic]LabelData)

	nuo_assert(current_codegen != nil,"something went wrong. Could not create CodeGen.")

	current_codegen.labels = labels
	codegen_init_program()
}

codegen_report_error_cond :: proc(condiction: bool, fmt: string, args: ..any) -> (sucess: bool)
{
	if condiction { sucess = true; return }

	set_cpsr_err()
	eprintf(" [NUO CODEGEN] Error: ")
	eprintf(fmt, ..args)
	eprintf("\n")

	return
}

codegen_registe_db :: proc() { import_db_register_all_db(codegen_get_iid()) }

codegen_init_program :: proc() 
{ 
	nuo_assert(get_ctx() != nil,"something went wrong . Make sure that Context was created.")
	fid                  := db_create_function(PROGRAM_FUNCTION_NAME,0,0,codegen_get_iid()) 
	current_codegen.fid   = fid
}

codegen_init_new_program :: proc(fname :="") 
{ 
	nuo_assert(get_ctx() != nil,"something went wrong . Make sure that Context was created.")
	fid                  := db_create_function(fname,0,0,codegen_get_iid()) 
	current_codegen.fid   = fid
}



codegen_create_function :: proc(name: string,argc,dargs: int, iid := 0) -> int { return db_create_function(name,argc,dargs,iid) }


codegen_generate :: proc(node: ^Node) 
{ 
	// Nota(jstn): alguns slots são memorias invalidas, pois a arena da AST
	// está em modo temporario, então convém limpar
	codegen_clear_labels()
	gerate_bytecode(node,0) 
}

// generate_default_return :: proc(loc: Localization) { gerate_bytecode(create_literal_node(.OP_NIL,loc),0); codegen_emit_opcode(.OP_RETURN,loc) }

gerate_bytecode :: proc(node: ^Node,rcount: int ,max_recursion := 1024)
{

	if !codegen_report_error_cond(node != nil,"something went wrong in generate Bytecode.")  { set_cpsr_err(); return }
	if !codegen_report_error_cond(rcount < max_recursion ,"something went wrong. Max recursion reached.") { set_cpsr_err(); return }

	for_loop_container :: proc(rcount: int,node: ^Node)
	{
		node := reinterpret_node(node,ContainerNode)
		for n in node.args do gerate_bytecode(n,rcount)
	}


	#partial switch node.type
	{

		case .STATEMENT:

			stmt_node := reinterpret_node(node,StmtNode)
			expr      := stmt_node.expr
			gerate_bytecode(expr,rcount+1)

		case .EXPRESSION:

			expr_node := reinterpret_node(node,ExprNode)
			expr      := expr_node.expr
			loc       := expr_node.loc
			gerate_bytecode(expr,rcount+1)
			codegen_emit_opcode(.OP_POP,loc)

		case .CONTAINER: 
			for_loop_container(rcount+1,node)

		case .LITERAL:

			literal_node := reinterpret_node(node,LiteralNode)
			op           := literal_node.op
			loc          := literal_node.loc

			codegen_emit_opcode(.OP_LITERAL,loc)
			codegen_emit_opcode(op,loc)	

		case .INT:

			int_node := reinterpret_node(node,IntNode)
			loc      := int_node.loc
			codegen_emit_load(VARIANT_VAL(int_node.number),loc)

		case .FLOAT:

			float_node := reinterpret_node(node,FloatNode)
			loc        := float_node.loc
			codegen_emit_load(VARIANT_VAL(float_node.number),loc)
		
		case .STRING:

			string_node := reinterpret_node(node,StringNode)
			str         := string_node.str
			loc         := string_node.loc
			codegen_emit_load(VARIANT_VAL(create_obj_string_literal(str,true)),loc)

		case .UNARY:

			unary_node := reinterpret_node(node,UnaryNode)
			rhs         := unary_node.rhs
			op          := unary_node.op
			loc         := unary_node.loc

			gerate_bytecode(rhs,rcount+1)
			codegen_emit_opcode(.OP_UNARY,loc)
			codegen_emit_opcode(op,loc)


		case .BINARY:

			binary_node := reinterpret_node(node,BinaryNode)
			lhs         := binary_node.lhs
			rhs         := binary_node.rhs
			op          := binary_node.op
			loc         := binary_node.loc

			gerate_bytecode(lhs,rcount+1)
			gerate_bytecode(rhs,rcount+1)

			codegen_emit_opcode(.OP_BINARY,loc)
			codegen_emit_opcode(op,loc)

		case .TERNARY:

			ternary_node   := reinterpret_node(node,TernaryNode)
			condition      := ternary_node.condition
			lhs            := ternary_node.lhs
			rhs            := ternary_node.rhs
			loc            := ternary_node.loc

			gerate_bytecode(condition,rcount+1)
			false_address  := codegen_emit_jump_and_get_address_index(.OP_JUMP_IF_FALSE,loc)
			
			codegen_emit_opcode(.OP_POP,loc)
			gerate_bytecode(lhs,rcount+1)

			jmp_address    := codegen_emit_jump_and_get_address_index(.OP_JUMP,loc)
			codegen_set_address(false_address,codegen_get_current_address_index())
			
			codegen_emit_opcode(.OP_POP,loc)
			gerate_bytecode(rhs,rcount+1)

			codegen_set_address(jmp_address,codegen_get_current_address_index())

		case .VECTOR:

			vector_node := reinterpret_node(node,DinamicNode)
			args        := vector_node.args 
			argc        := get_container_node_len(args)
			loc         := vector_node.loc

			for_loop_container(rcount+1,args)

			codegen_emit_opcode(.OP_CONSTRUCT,loc)
			
			codegen_emit_opcode(.OP_CONSTRUCT,loc)
			codegen_emit_index(argc,loc)
			codegen_emit_type(.VECTOR2,loc)

			codegen_report_error_cond(argc == 2,"implement Vec%v handler",argc)

		case .COLOR:

			vector_node := reinterpret_node(node,DinamicNode)
			args        := vector_node.args 
			argc        := get_container_node_len(args)
			loc         := vector_node.loc

			for_loop_container(rcount+1,args)

			codegen_emit_opcode(.OP_CONSTRUCT,loc)
			
			codegen_emit_opcode(.OP_CONSTRUCT,loc)
			codegen_emit_index(argc,loc)
			codegen_emit_type(.COLOR,loc)

			codegen_report_error_cond(argc == 4,"implement Color%v handler",argc)

		case .RECT:

			rect_node   := reinterpret_node(node,DinamicNode)
			args        := rect_node.args 
			argc        := get_container_node_len(args)
			loc         := rect_node.loc

			for_loop_container(rcount+1,args)

			codegen_emit_opcode(.OP_CONSTRUCT,loc)
			
			codegen_emit_opcode(.OP_CONSTRUCT,loc)
			codegen_emit_index(argc,loc)
			codegen_emit_type(.RECT2,loc)

			codegen_report_error_cond(argc == 2,"implement Rect2 %v handler",argc)

		case .TRANSFORM:

			trans2D_node := reinterpret_node(node,DinamicNode)
			args         := trans2D_node.args 
			argc         := get_container_node_len(args)
			loc          := trans2D_node.loc

			for_loop_container(rcount+1,args)

			codegen_emit_opcode(.OP_CONSTRUCT,loc)
			
			codegen_emit_opcode(.OP_CONSTRUCT,loc)
			codegen_emit_index(argc,loc)
			codegen_emit_type(.TRANSFORM2D,loc)

			codegen_report_error_cond(argc == 3,"implement Transform2D %v handler",argc)


		case .ARRAY:

			array_node  := reinterpret_node(node,DinamicNode)
			args        := array_node.args 
			argc        := get_container_node_len(args)
			loc         := array_node.loc

			for_loop_container(rcount+1,args)

			codegen_emit_opcode(.OP_CONSTRUCT,loc)
			
			codegen_emit_opcode(.OP_CONSTRUCT,loc)
			codegen_emit_index(argc,loc)
			codegen_emit_type(.ARRAY,loc)
		
		case .MAP:

			map_node    := reinterpret_node(node,DinamicNode)
			data        := reinterpret_node(map_node.args,ContainerNode)
			keys_values := data.args
			argc        := get_container_node_len(data)
			loc         := map_node.loc

			//Nota(jstn): It's key-value

			for idx := 0; idx < argc; idx += 2
			{
				gerate_bytecode(keys_values[idx],rcount+1)   //key
				gerate_bytecode(keys_values[idx+1],rcount+1) //value
			}

			codegen_emit_opcode(.OP_CONSTRUCT,loc)
			
			codegen_emit_opcode(.OP_CONSTRUCT,loc)
			codegen_emit_index(argc,loc)
			codegen_emit_type(.MAP,loc)

		case .RANGE:

			range_node  := reinterpret_node(node,DinamicNode)
			args        := range_node.args
			argc        := get_container_node_len(args)
			loc         := range_node.loc

			codegen_report_error_cond(argc == 2,"Oops invalid range. got %v arguments.",argc)

			for_loop_container(rcount+1,args)

			codegen_emit_opcode(.OP_CONSTRUCT,loc)
			codegen_emit_opcode(.OP_CONSTRUCT,loc)

			codegen_emit_index(argc,loc)
			codegen_emit_type(.RANGE,loc)

		case .SIGNAL:

			signal_node  := reinterpret_node(node,DinamicNode)
			loc          := signal_node.loc

			codegen_emit_opcode(.OP_CONSTRUCT,loc)
			codegen_emit_opcode(.OP_CONSTRUCT,loc)

			codegen_emit_index(0,loc)
			codegen_emit_type(.SIGNAL,loc)

		case .PRINT:

			print_node := reinterpret_node(node,PrintNode)
			args       := print_node.expr
			loc        := print_node.loc
			
			for_loop_container(rcount+1,args)
			codegen_emit_opcode(.OP_PRINT,loc)
			codegen_emit_index(get_container_node_len(args),loc)

		case .DEFINE_VAR:

			define_var_node := reinterpret_node(node,DefineVariableNode)
			rhs             := define_var_node.rhs
			name            := define_var_node.name
			is_local        := define_var_node.local
			loc             := define_var_node.loc

			name_index      := string_db_register_string(name)

			gerate_bytecode(rhs,rcount+1)

			if !is_local
			{
				codegen_emit_opcode(.OP_DEFINE_GLOBAL,loc)
				codegen_emit_index(name_index,loc)
				codegen_emit_opcode(.OP_POP,loc)
			}


		case .NAMED_VAR:

			named_var_node := reinterpret_node(node,NamedVariableNode)
			name           := named_var_node.name
			local_index    := named_var_node.l_index
			is_local       := named_var_node.local
			loc            := named_var_node.loc

			if !is_local
			{
				name_index := string_db_register_string(name)
				codegen_emit_opcode(.OP_GET_GLOBAL,loc)
				codegen_emit_index(name_index,loc)
			}
			else 
			{ 
				codegen_emit_opcode(.OP_GET_LOCAL,loc)
				codegen_emit_index(local_index,loc) 
			}


		case .ASSIGNMENT:

			assign_node    := reinterpret_node(node,AssignmentNode)
			rhs            := assign_node.rhs
			name           := assign_node.name
			local_index    := assign_node.l_index
			is_local       := assign_node.local
			loc            := assign_node.loc

			gerate_bytecode(rhs,rcount+1)

			if !is_local
			{
				name_index := string_db_register_string(name)
				codegen_emit_opcode(.OP_SET_GLOBAL,loc)
				codegen_emit_index(name_index,loc)
			}
			else
			{
				codegen_emit_opcode(.OP_SET_LOCAL,loc)
				codegen_emit_index(local_index,loc)
			}

		case .CALL:

			call_node := reinterpret_node(node,CallNode)
			callee    := call_node.callee
			args      := call_node.args
			argc      := get_container_node_len(args)
			loc       := call_node.loc

			for_loop_container(rcount+1,args)
			gerate_bytecode(callee,rcount+1)

			codegen_emit_opcode(.OP_CALL,loc)
			codegen_emit_index(argc,loc)

		case .SUPER:

			call_method_node := reinterpret_node(node,CallMethodNode)
			lhs              := call_method_node.lhs
			method_name      := call_method_node.m_name
			args             := call_method_node.args
			loc              := call_method_node.loc

			for_loop_container(rcount+1,args)
			gerate_bytecode(lhs,rcount+1) //this

			sid := string_db_register_string(method_name)

			codegen_emit_opcode(.OP_CALL1,loc)
			codegen_emit_index(get_container_node_len(args),loc)
			codegen_emit_index(sid,loc)


		case .CALL_METHOD:

			call_method_node := reinterpret_node(node,CallMethodNode)
			lhs              := call_method_node.lhs
			method_name      := call_method_node.m_name
			args             := call_method_node.args
			loc              := call_method_node.loc

			for_loop_container(rcount+1,args)
			gerate_bytecode(lhs,rcount+1)

			sid := string_db_register_string(method_name)

			codegen_emit_opcode(.OP_INVOKE,loc)
			codegen_emit_index(get_container_node_len(args),loc)
			codegen_emit_index(sid,loc)



		case .NEW:

			new_node := reinterpret_node(node,NewNode)
			lhs      := new_node.class
			args     := new_node.args
			loc      := new_node.loc

			for_loop_container(rcount+1,args)
			gerate_bytecode(lhs,rcount+1)

			codegen_emit_opcode(.OP_NEW,loc)
			codegen_emit_index(get_container_node_len(args),loc)


		case .GET_PROPERTY:

			get_property_node := reinterpret_node(node,GetPropertyNode)
			property          := get_property_node.property
			lhs               := get_property_node.lhs
			loc               := get_property_node.loc

			property_sid := string_db_register_string(property)
			sidi         := codegen_push_constant(SYMID_VAL(property_sid))

			gerate_bytecode(lhs,rcount+1)
			codegen_emit_opcode(.OP_GET_PROPERTY,loc)

			codegen_emit_opcode(.OP_GET_PROPERTY,loc)
			codegen_emit_index(sidi,loc)

		case .SET_PROPERTY:

			set_property_node := reinterpret_node(node,SetPropertyNode)
			property          := set_property_node.property
			lhs               := set_property_node.lhs
			expr              := set_property_node.expr
			loc               := set_property_node.loc

			gerate_bytecode(expr,rcount+1)
			gerate_bytecode(lhs,rcount+1)

			property_sid := string_db_register_string(property)
			sidi         := codegen_push_constant(SYMID_VAL(property_sid))

			codegen_emit_opcode(.OP_SET_PROPERTY,loc)
			
			codegen_emit_opcode(.OP_SET_PROPERTY,loc)
			codegen_emit_index(sidi,loc)


			// Nota(jstn): Para quebrar o bug, uma vez que o _mem é copiado, e não é passado a referencia
			// então, subistitui onde quer que a variavel está guardada, eu sei que é uma pessima abordagem
			// mas é o que eu pensei até aqui.

			// STACK : obj, value -> pop: obj, exp: pop value
			// deixamos o obj na pilha, pois precisamos transforma-lo num bool
			// caso use o buffer, salta para atribuição, caso não, não atribui

			set_property :: proc(node: ^Node)
			{
				#partial switch node.type
				{

					case .NAMED_VAR:

						named_var_node := reinterpret_node(node,NamedVariableNode)
						name           := named_var_node.name
						local_index    := named_var_node.l_index
						is_local       := named_var_node.local
						loc            := named_var_node.loc


						if !is_local
						{
							name_index := string_db_register_string(name)
							jmp_if_not_use_buffer := codegen_emit_jump_and_get_address_index(.OP_JUMP_IF_TRUE,loc)
							
							// Nota(jstn): uso do buffer
							codegen_emit_opcode(.OP_POP,loc)
							
							codegen_emit_opcode(.OP_SET_GLOBAL,loc)
							codegen_emit_index(name_index,loc)

							used_buffer := codegen_emit_jump_and_get_address_index(.OP_JUMP,loc)

							// Nota(jstn): não uso do buffer
							codegen_set_address(jmp_if_not_use_buffer,codegen_get_current_address_index())
							codegen_emit_opcode(.OP_POP,loc)

							// 
							codegen_set_address(used_buffer,codegen_get_current_address_index())
						}
						else 
						{ 
							jmp_if_not_use_buffer := codegen_emit_jump_and_get_address_index(.OP_JUMP_IF_TRUE,loc)
							
							// Nota(jstn): uso do buffer
							codegen_emit_opcode(.OP_POP,loc)
							codegen_emit_opcode(.OP_SET_LOCAL,loc)
							codegen_emit_index(local_index,loc)

							used_buffer := codegen_emit_jump_and_get_address_index(.OP_JUMP,loc)

							// Nota(jstn): não uso do buffer
							codegen_set_address(jmp_if_not_use_buffer,codegen_get_current_address_index())
							codegen_emit_opcode(.OP_POP,loc)

							// 
							codegen_set_address(used_buffer,codegen_get_current_address_index())
						}
				
					case .GET_PROPERTY:

						get_property_node := reinterpret_node(node,GetPropertyNode)
						property          := get_property_node.property
						lhs               := get_property_node.lhs
						loc               := get_property_node.loc

						jmp_if_not_use_buffer := codegen_emit_jump_and_get_address_index(.OP_JUMP_IF_TRUE,loc)

						// Nota(jstn): uso do buffer
						codegen_emit_opcode(.OP_POP,loc)
						
						gerate_bytecode(lhs,0)

						property_sid := string_db_register_string(property)
						sidi         := codegen_push_constant(SYMID_VAL(property_sid))

						codegen_emit_opcode(.OP_SET_PROPERTY,loc)

						codegen_emit_opcode(.OP_SET_PROPERTY,loc)
						codegen_emit_index(sidi,loc)

						set_property(lhs)
						// codegen_emit_opcode(.OP_POP,loc)

						used_buffer := codegen_emit_jump_and_get_address_index(.OP_JUMP,loc)

						// Nota(jstn): não uso do buffer
						codegen_set_address(jmp_if_not_use_buffer,codegen_get_current_address_index())
						codegen_emit_opcode(.OP_POP,loc)

						// 
						codegen_set_address(used_buffer,codegen_get_current_address_index())
				
								
					case .OBJECT_OPERATOR:

						obj_operator_node := reinterpret_node(node,ObjectOperatorNode)
						lhs               := obj_operator_node.lhs
						index             := obj_operator_node.index
						rhs               := obj_operator_node.rhs
						set               := obj_operator_node.set
						loc               := obj_operator_node.loc

						jmp_if_not_use_buffer := codegen_emit_jump_and_get_address_index(.OP_JUMP_IF_TRUE,loc)

						// Nota(jstn): uso do buffer
						codegen_emit_opcode(.OP_POP,loc)


						// 	gerate_bytecode(rhs,rcount+1)
						gerate_bytecode(index,0)
						gerate_bytecode(lhs,0)

						codegen_emit_opcode(.OP_SET_INDEXING,loc)
						codegen_emit_opcode(.OP_SET_INDEXING,loc)

						used_buffer := codegen_emit_jump_and_get_address_index(.OP_JUMP,loc)

						// Nota(jstn): não uso do buffer
						codegen_set_address(jmp_if_not_use_buffer,codegen_get_current_address_index())
						codegen_emit_opcode(.OP_POP,loc)

						// 
						codegen_set_address(used_buffer,codegen_get_current_address_index())


					case .CALL : 

						call_node := reinterpret_node(node,CallNode)
						loc       := call_node.loc
						codegen_emit_opcode(.OP_POP,loc)


					case .CALL_METHOD:

						call_method_node := reinterpret_node(node,CallMethodNode)
						loc              := call_method_node.loc
						codegen_emit_opcode(.OP_POP,loc)




					case : unreachable("not handler set_property '%v'.",node.type)
				}
			}

			set_property(lhs)


		case .OBJECT_OPERATOR:

			obj_operator_node := reinterpret_node(node,ObjectOperatorNode)
			lhs               := obj_operator_node.lhs
			index             := obj_operator_node.index
			rhs               := obj_operator_node.rhs
			set               := obj_operator_node.set
			loc               := obj_operator_node.loc

			if set 
			{
				gerate_bytecode(rhs,rcount+1)
				gerate_bytecode(index,rcount+1)
				gerate_bytecode(lhs,rcount+1)

				codegen_emit_opcode(.OP_SET_INDEXING,loc)
				codegen_emit_opcode(.OP_SET_INDEXING,loc)
			}
			else
			{
				gerate_bytecode(lhs,rcount+1)
				gerate_bytecode(index,rcount+1)

				codegen_emit_opcode(.OP_BINARY,loc)
				codegen_emit_opcode(.OP_GET_INDEXING,loc)
			}


		case .BLOCK:

			block_node  := reinterpret_node(node,BlockNode)
			body        := block_node.body
			local_count := block_node.l_count
			loc         := block_node.loc

			for_loop_container(rcount+1,body)
			if local_count > 0 { codegen_emit_opcode(.OP_SUB_SP,loc); codegen_emit_index(local_count,loc) }


		case .WHILE:

			while_node  := reinterpret_node(node,WhileNode)
			condition   := while_node.condition
			body        := while_node.body
			loc         := while_node.loc

			// (1)
			jmp_address   := codegen_emit_jump_and_get_address_index(.OP_JUMP,loc)
			
			// (3)
			block_address := codegen_get_current_address_index()

			codegen_emit_opcode(.OP_POP,loc)
			
			ldepth := codegen_begin_label_depth()
			gerate_bytecode(body,rcount+1)
			codegen_end_label_depth()

			codegen_set_address(jmp_address,codegen_get_current_address_index())

			// (2)
			continue_address := codegen_get_current_address_index()
			gerate_bytecode(condition,rcount+1)

			true_address := codegen_emit_jump_and_get_address_index(.OP_JUMP_IF_TRUE,loc)
			codegen_set_address(true_address,block_address)

			// (4)
			codegen_emit_opcode(.OP_POP,loc)


			#reverse for &l in codegen_get_label_array()
			{
				if l.depth < ldepth                    do break
				if !codegen_is_same_ldepth(ldepth,&l)  do continue
				
				if codegen_is_label(&l,.BREAK)         do codegen_set_address(codegen_get_label_address(&l),codegen_get_current_address_index())
				else if codegen_is_label(&l,.CONTINUE) do codegen_set_address(codegen_get_label_address(&l),continue_address)
			}

		case .FOR:

			for_node   := reinterpret_node(node,ForNode)
			body       := for_node.body
			loc        := for_node.loc

			gerate_bytecode(body,rcount+1)
			// gerate_bytecode(pbody,rcount+1)

		case .MATCH:

			match_node    := reinterpret_node(node,MatchNode)
			condition     := match_node.condition

			cases         := match_node.cases
			bodies        := match_node.bodies
			
			dbody         := match_node.dbody
			default       := match_node.default
			loc           := match_node.loc

			clen          := get_container_node_len(cases)
			blen          := get_container_node_len(bodies)

			nuo_assert(clen == blen,"something went wrong in match case.")
			alabels := codegen_create_adynamic(CaseData)


			if clen > 0 || default
			{
				//(1)
				initial_jmp_address   := codegen_emit_jump_and_get_address_index(.OP_JUMP,loc)

				for body in reinterpret_node(bodies,ContainerNode).args
				{
					case_data : CaseData
					case_data.start_address = codegen_get_current_address_index()
					
					gerate_bytecode(body,rcount+1)
					case_data.end_address   = codegen_emit_jump_and_get_address_index(.OP_JUMP,loc)

					append(&alabels,case_data)
				}

				// (2)
				codegen_set_address(initial_jmp_address,codegen_get_current_address_index())

				for _case in reinterpret_node(cases,ContainerNode).args        do gerate_bytecode(_case,rcount+1)
				for &case_data in alabels do codegen_emit_load(VARIANT_VAL(case_data.start_address),loc)

				// (3)
				gerate_bytecode(condition,rcount+1)

				codegen_emit_opcode(.OP_MATCH,loc)
				codegen_emit_index(clen,loc)

				if default do gerate_bytecode(dbody,rcount+1)

				// end
				for &case_data in alabels do codegen_set_address(case_data.end_address,codegen_get_current_address_index())
			}


		case .IF:

			if_node   := reinterpret_node(node,IfNode)
			
			condition := if_node.condition
			body      := if_node.body
			elif      := if_node.elif
			loc       := if_node.loc

			gerate_bytecode(condition,rcount+1)
			false_addres := codegen_emit_jump_and_get_address_index(.OP_JUMP_IF_FALSE,loc)

			codegen_emit_opcode(.OP_POP,loc)
			gerate_bytecode(body,rcount+1)

			true_address := codegen_emit_jump_and_get_address_index(.OP_JUMP,loc)

			codegen_set_address(false_addres,codegen_get_current_address_index())
			codegen_emit_opcode(.OP_POP,loc)

			if elif != nil do gerate_bytecode(elif,rcount+1)

			codegen_set_address(true_address,codegen_get_current_address_index())

		case .BREAK:

			break_node  := reinterpret_node(node,BreakNode)
			local_count := break_node.l_count
			loc         := break_node.loc

			if local_count >  0 { codegen_emit_opcode(.OP_SUB_SP,loc); codegen_emit_index(local_count,loc) }
			codegen_register_break(codegen_emit_jump_and_get_address_index(.OP_JUMP,loc))

		case .CONTINUE:

			continue_node  := reinterpret_node(node,ContinueNode)
			local_count    := continue_node.l_count
			loc            := continue_node.loc

			if local_count >  0 { codegen_emit_opcode(.OP_SUB_SP,loc); codegen_emit_index(local_count,loc) }
			codegen_register_continue(codegen_emit_jump_and_get_address_index(.OP_JUMP,loc))		

		case .RETURN :

			return_node := reinterpret_node(node,ReturnNode)
			expr        := return_node.expr
			local_count := return_node.l_count
			loc         := return_node.loc

			gerate_bytecode(expr,rcount+1)
			codegen_emit_opcode(.OP_STORE_RETURN,loc)

			if local_count >  0 { codegen_emit_opcode(.OP_SUB_SP,loc); codegen_emit_index(local_count,loc) }

			codegen_emit_opcode(.OP_LOAD_RETURN,loc)
			codegen_emit_opcode(.OP_RETURN,loc)
			
			// generate(return_node.expr)
			// emit_instruction(.OP_STORE_RETURN,loc)
			
			// // Nota(jstn): uma otimização
			// if local_count > 0 do emit_instruction_and_slot_index(.OP_SUB_SP,local_count,loc)

			// emit_instruction(.OP_LOAD_RETURN,loc)
			// emit_instruction(.OP_RETURN,loc)
	
		case .FUNCTION:

			function_node := reinterpret_node(node,FunctionNode)
			body          := function_node.body
			name          := function_node.name
			arg_count     := function_node.argc
			loc           := function_node.loc

			efid := codegen_get_fid()
			nfid := codegen_create_function(name,arg_count,0,codegen_get_iid())

			codegen_set_fid(nfid)
			gerate_bytecode(body,rcount+1)
			// generate_default_return(loc)
			codegen_set_fid(efid)

			fn_name_index := string_db_register_string(name)
			codegen_emit_load(NUOFUNCTION_VAL(nfid),loc)

			codegen_emit_opcode(.OP_DEFINE_GLOBAL,loc)
			codegen_emit_index(fn_name_index,loc)
			codegen_emit_opcode(.OP_POP,loc)

		case .CLASS:

			class_node := reinterpret_node(node,ClassNode)
			methods_c  := reinterpret_node(class_node.methods,ContainerNode)
			name       := class_node.name
			super      := class_node.super
			extends    := class_node.extends
			loc        := class_node.loc

			class_id   := class_db_register_class(name)

			for m in methods_c.args
			{
				method_node := reinterpret_node(m,FunctionNode)
				body          := method_node.body
				mname         := method_node.name
				argc          := method_node.argc
				// mloc          := method_node.loc

				efid          := codegen_get_fid()
				nfid          := codegen_create_function(mname,argc,0,codegen_get_iid())

				codegen_set_fid(nfid)
				gerate_bytecode(body,rcount+1)
				codegen_set_fid(efid)

				class_db_register_class_method(class_id,mname,NUOFUNCTION_VAL(nfid))
			}

			class_name_index := string_db_register_string(name)
			codegen_emit_load(CLASS_VAL(class_id),loc)

			codegen_emit_opcode(.OP_DEFINE_GLOBAL,loc)
			codegen_emit_index(class_name_index,loc)

			// 
			if extends
			{
				gerate_bytecode(super,rcount+1)
				codegen_emit_opcode(.OP_INHERIT,loc)

				codegen_emit_opcode(.OP_INHERIT,loc)

				codegen_emit_opcode(.OP_POP,loc)
				codegen_emit_opcode(.OP_POP,loc)
			}
			else do codegen_emit_opcode(.OP_POP,loc)

			
		case .IMPORT:

			import_node := reinterpret_node(node,ImportNode)
			name        := import_node.name
			iname       := import_node.iname
			fid         := import_node.fid
			iid         := import_node.iid
			imported    := import_node.imported
			native      := import_node.native
			loc         := import_node.loc

			if native
			{
				_iid := import_db_get_id_by_name(name,.IMPORT)
				codegen_report_error_cond(_iid >= 0, "cannot resolve '%v' as native Import",name)

				import_name_index := string_db_register_string(name)
				codegen_emit_load(IMPORT_VAL(_iid),loc)
				
				codegen_emit_opcode(.OP_DEFINE_GLOBAL,loc)
				codegen_emit_index(import_name_index,loc)
				codegen_emit_opcode(.OP_POP,loc)

			}
			else if imported
			{
				_iid := import_db_get_id_by_name(iname,.IMPORT)
				nuo_panic( _iid >= 0, "Oops! this's a compiler bug. Please report.")

				import_name_index := string_db_register_string(name)
				codegen_emit_load(IMPORT_VAL(_iid),loc)

				codegen_emit_opcode(.OP_DEFINE_GLOBAL,loc)
				codegen_emit_index(import_name_index,loc)
				codegen_emit_opcode(.OP_POP,loc)
			}
			else
			{
				codegen_emit_load(NUOFUNCTION_VAL(fid),loc)
				// gerate_bytecode(callee,rcount+1)

				codegen_emit_opcode(.OP_CALL,loc)
				codegen_emit_index(0,loc)
				codegen_emit_opcode(.OP_POP,loc)

				import_name_index := string_db_register_string(name)
				codegen_emit_load(IMPORT_VAL(iid),loc)

				codegen_emit_opcode(.OP_DEFINE_GLOBAL,loc)
				codegen_emit_index(import_name_index,loc)
				codegen_emit_opcode(.OP_POP,loc)
			}


		case : codegen_report_error_cond(false,"not handler '%v'.",node)
		
	}
}