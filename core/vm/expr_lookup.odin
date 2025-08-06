package VM



// member :: proc(lhs: ^Node, bp: BindPower) -> ^Node {

// 	loc := peek_clocalization(); advance()

// 	// Nota(jstn): 'new'
// 	if at(.New)
// 	{	
// 		advance()
// 		expect(.Open_Paren,"expected '(' after 'new'.")
// 		argc,argcontainer := argument_list(bp)
// 		expect(.Close_Paren,"expected ')' after arguments.")

// 		return create_new_node(lhs,argcontainer,argc,loc)
// 	}

// 	expect(.Identifier,"expect property name after '.'.")
// 	if has_error() do return create_bad_node(peek_p(),loc)
// 	tk_property := peek_p()

// 	// Nota(jstn): set,get,invoke
// 	if at(.Equal)      { advance(); rhs := expression(.DEFAULT); return create_set_property_node(lhs,rhs,tk_property.text,.OP_SET_PROPERTY,loc) }
// 	if at(.Open_Paren) { advance(); argc,container := argument_list(bp); expect(.Close_Paren,"expected '(' after arguments."); return create_call_method_node(lhs,container,tk_property.text,argc,loc)}

// 	if ok, op := assignmetopcode(peek_ctype()); ok {
// 		advance()
// 		rhs := expression(.DEFAULT); 
// 		bin_node  := create_binary_node(create_get_property_node(lhs,tk_property.text,.OP_GET_PROPERTY,loc),rhs,op,loc)
// 		return create_set_property_node(lhs,bin_node,tk_property.text,.OP_SET_PROPERTY,loc)
// 	} 



// 	return create_get_property_node(lhs,tk_property.text,.OP_GET_PROPERTY,loc)
// }

member :: proc(lhs: ^Node, bp: BindPower) -> ^Node
{
	_new   :: proc(lhs: ^Node, bp: BindPower) -> ^Node
	{
		loc := peek_cloc(); advance()
		expect(.Open_Paren,"expected '(' after 'new'.")
		return create_new_node(lhs,argument_list(bp),loc)
	}

	_call_method :: proc(lhs: ^Node, bp: BindPower) -> ^Node
	{
		loc         := peek_ploc()
		method_tk   := peek_ptk(); advance()
		method_name := method_tk.text
		return create_call_method_node(method_name,lhs,argument_list(bp),loc)
	}

	_set_property :: proc(lhs: ^Node, bp: BindPower) -> ^Node
	{
		loc         := peek_ploc()
		property_tk := peek_ptk(); advance()
		property    := property_tk.text

		return create_set_property_node(property,lhs,expression(.DEFAULT),loc)
	}

	_get_property :: proc(lhs: ^Node, bp: BindPower) -> ^Node
	{
		loc         := peek_ploc()
		property_tk := peek_ptk()
		property    := property_tk.text

		return create_get_property_node(property,lhs,loc)
	}

	_set_property_l :: proc(lhs: ^Node, bp: BindPower, op: Opcode) -> ^Node
	{
		loc          := peek_ploc()
		property_tk  := peek_ptk()

		get_property := _get_property(lhs,bp); advance()
		property     := property_tk.text

		binary_node := create_binary_node(op,get_property,expression(.DEFAULT),loc)
		return create_set_property_node(property,lhs,binary_node,loc)
	}

	loc := peek_cloc(); advance()

	if at(.New)        do return _new(lhs,bp)

	expect(.Identifier,"expect property name after '.'.")
	
	if at(.Open_Paren) do return _call_method(lhs,bp)
	if at(.Equal)      do return _set_property(lhs,bp)

	if op, ok := assignme2opcode(peek_ctype()); ok do return _set_property_l(lhs,bp,op)

	return _get_property(lhs,bp)
}


call_stmt_l :: proc(lhs: ^Node, bp: BindPower) -> ^Node
{
	loc      := peek_cloc(); advance()
	compile_error_cond(!is_callable(lhs),"expected a valid expression for callee.")
	return create_call_node(lhs,argument_list(bp),loc)
}

argument_list :: proc(bp: BindPower) -> ^Node 
{
	container        := create_container_node()
	argc             : int

	for not_is_eof() && has_not_error() && !at(.Close_Paren)
	{
	  skip(.Newline); container_node_append(container,expression(.DEFAULT))
	  skip(.Comma)
	  
	  argc += 1
	  compile_error_cond(argc < MAX_ARGUMENTS,"can't have more than '%v' arguments.",MAX_ARGUMENTS)
	}

	expect(.Close_Paren,"expected ')' after arguments.")
	return container
}


assignment :: proc(lhs: ^Node, bp: BindPower) -> ^Node
{
	loc := peek_cloc(); advance()
	compile_error_cond(can_assign_node(lhs),"invalid assignment. expected a identifier as target in assignment.")

	if has_error() do return create_bad_node(loc)

	named_node := reinterpret_node(lhs,NamedVariableNode)
	return create_assignment_node(named_node.name,named_node.local,named_node.l_index,expression(bp),loc)
}

assignment_l :: proc(lhs: ^Node, bp: BindPower) -> ^Node
{
	loc := peek_cloc(); advance()
	compile_error_cond(can_assign_node(lhs),"invalid assignment. expected a identifier as target in assignment.")

	if has_error() do return create_bad_node(loc)


	//Nota(jstn): certifique-se que assignme2opcode, corresponda sempre
	// com os tokens registrado para esse led.
	named_node := reinterpret_node(lhs,NamedVariableNode)
	op,_       := assignme2opcode(peek_ptype())
	rhs        := create_binary_node(op,named_node,expression(bp),loc)

	return create_assignment_node(named_node.name,named_node.local,named_node.l_index,rhs,loc)
}






binary   :: proc(lhs: ^Node, bp: BindPower) -> ^Node 
{
	t,loc := peek_ctk(),peek_cloc(); advance()

	#partial switch t.type 
	{
		case .Sub:  return create_binary_node(.OP_SUB,lhs,expression(bp),loc)
		case .Add:  return create_binary_node(.OP_ADD,lhs,expression(bp),loc)
		case .Mult: return create_binary_node(.OP_MULT,lhs,expression(bp),loc)

		case .Mult_Mult:   return create_binary_node(.OP_MULT_MULT,lhs,expression(bp),loc)
		case .Quo:         return create_binary_node(.OP_DIV,lhs,expression(bp),loc)
		case .Mod:         return create_binary_node(.OP_MOD,lhs,expression(bp),loc)
		case .And_Bit:     return create_binary_node(.OP_BIT_AND,lhs,expression(bp),loc)
		case .Xor_Bit:     return create_binary_node(.OP_BIT_XOR,lhs,expression(bp),loc)
		case .Or_Bit:      return create_binary_node(.OP_BIT_OR,lhs,expression(bp),loc)
		case .Shift_L_Bit: return create_binary_node(.OP_SHIFT_LEFT,lhs,expression(bp),loc)
		case .Shift_R_Bit: return create_binary_node(.OP_SHIFT_RIGHT,lhs,expression(bp),loc)
		case .Equal_Eq:    return create_binary_node(.OP_EQUAL,lhs,expression(bp),loc)
		case .Less: 	   return create_binary_node(.OP_LESS,lhs,expression(bp),loc)
		case .Greater: 	   return create_binary_node(.OP_GREATER,lhs,expression(bp),loc)
		case .Not_Eq: 	   return create_binary_node(.OP_NOT_EQUAL,lhs,expression(bp),loc)
		case .Less_Eq:     return create_binary_node(.OP_LESS_EQUAL,lhs,expression(bp),loc)
		case .Greater_Eq:  return create_binary_node(.OP_GREATER_EQUAL,lhs,expression(bp),loc)

		case .And: 		   return create_binary_node(.OP_AND,create_unary_node(.OP_BOOLIANIZE,lhs,loc),create_unary_node(.OP_BOOLIANIZE,expression(bp),loc),loc)
		case .Or :		   return create_binary_node(.OP_OR,create_unary_node(.OP_BOOLIANIZE,lhs,loc),create_unary_node(.OP_BOOLIANIZE,expression(bp),loc),loc)

		case .If :         
						   condition := create_unary_node(.OP_BOOLIANIZE,expression(bp),loc); expect(.Else,"expected 'else' after ternary operator condition")
						   rhs       := expression(bp)
						   return  create_ternary_node(condition,lhs,rhs,loc)

		case .Question :   // a ? true: false    
						    condition := create_unary_node(.OP_BOOLIANIZE,lhs,loc)
						    lhs       := expression(bp) ; expect(.Colon,"expected ':' after ternary operator condition")
						    rhs       := expression(bp)
						   return  create_ternary_node(condition,lhs,rhs,loc)

		case : unreachable("Oops! it's a compiler bug ."); return nil
	}
}

group  :: proc(bp: BindPower) -> ^Node 
{
	advance()
	node := expression(.DEFAULT)
	expect(.Close_Paren,"expected closing ')' after grouping expression. got '%v'.",peek_ctype())
	return node
}

unary   :: proc(bp: BindPower) -> ^Node 
{
	t,loc := peek_ctk(),peek_cloc(); advance()


	#partial switch t.type 
	{
		case .Sub:          return create_unary_node(.OP_NEGATE,expression(bp),loc) 
		case .Add:          return expression(bp)
		case .Not:          return create_unary_node(.OP_NOT,create_unary_node(.OP_BOOLIANIZE,expression(bp),loc),loc)
		case .Not_Literal:  return create_unary_node(.OP_NOT,create_unary_node(.OP_BOOLIANIZE,expression(bp),loc),loc)
		case .Not_Bit:      return create_unary_node(.OP_BIT_NEGATE,expression(bp),loc)
		case :              unreachable("Oops! it's a compiler bug .",); return nil
	}
}

primary :: proc(bp: BindPower) -> ^Node
{
	t   := peek_ctk()
	loc := peek_cloc(); advance()

	#partial switch t.type
	{
		case .True :  return create_literal_node(.OP_TRUE,loc)
		case .False:  return create_literal_node(.OP_FALSE,loc)
		case .Null :  return create_literal_node(.OP_NIL,loc)
		case .Int  :  return create_int_node(atoi(t.text),loc)
		case .Float:  return create_float_node(Float(atof(t.text)),loc)
		case .String: return create_string_node(t.text,loc)
		case : unreachable("Oops! it's a compiler bug ."); return nil
	}
}


identifier :: proc(bp: BindPower) -> ^Node 
{

	loc   := peek_cloc(); var_name_tk := peek_ctk(); advance()
	l_node : ^Node

	if is_in_scope() && identifier_l(bp,var_name_tk,&l_node,loc) do return l_node

	has,gdata :=  global_check_redeclaration_var(var_name_tk)
	compile_error_cond(has,"identifier '%v' not declared in the current scope.",var_name_tk.text)

	if !has do return create_bad_node(loc)
	return create_named_var_node(var_name_tk.text,false,kind_can_assign(gdata.kind),-1,loc)
}

identifier_l :: proc(bp: BindPower, var_name_tk: Token ,l_node: ^^Node,loc: Localization) -> (sucess: bool)
{
	has,ldata :=  scope_check_redeclaration_var(var_name_tk)
	sucess     = has
	if has do l_node^ = create_named_var_node(var_name_tk.text,true,kind_can_assign(ldata.kind),ldata.index,loc)
	return 
}




vec        :: proc(bp: BindPower) -> ^Node 
{
	loc   := peek_cloc(); type := peek_ctype(); advance()
	if at(.Dot) do return create_named_var_node(peek_ptk().text,false,false,-1,loc)

	#partial switch type
	{
		case .Vec2: 

			container := create_container_node()
			expect(.Open_Paren,"expected '(' after Vec2.")

			for not_is_eof() && has_not_error() && !at(.Close_Paren)
			{
				container_node_append(container,expression(.DEFAULT))
				skip(.Comma)
			}

			        expect(.Close_Paren,"expected ')' after Vec2 arguments.")
			argc := get_container_node_len(container)

			compile_error_cond(argc == 2, "Vec2 expects 2 arguments, but got %v",argc)
			return create_dinamic_node(.VECTOR,container,loc)
	}



	unreachable("Oops! It's a bug in Vec2 handle")
	return nil
}

color  :: proc(bp: BindPower) -> ^Node 
{
	loc   := peek_cloc(); type := peek_ctype(); advance()
	if at(.Dot) do return create_named_var_node(peek_ptk().text,false,false,-1,loc)

	#partial switch type
	{
		case .Color: 

			container := create_container_node()
			expect(.Open_Paren,"expected '(' after Color.")

			for not_is_eof() && has_not_error() && !at(.Close_Paren)
			{
				container_node_append(container,expression(.DEFAULT))
				skip(.Comma)
			}

			        expect(.Close_Paren,"expected ')' after Color arguments.")
			argc := get_container_node_len(container)

			compile_error_cond(argc == 4, "Color expects 4 arguments, but got %v",argc)
			return create_dinamic_node(.COLOR,container,loc)
	}
	
	unreachable("Oops! It's a bug in Color handle")
	return nil
}

rect      :: proc(bp: BindPower) -> ^Node 
{

	loc   := peek_cloc(); type := peek_ctype(); advance()
	if at(.Dot) do return create_named_var_node(peek_ptk().text,false,false,-1,loc)

	#partial switch type
	{
		case .Rect2: 

			container := create_container_node()
			expect(.Open_Paren,"expected '(' after Rect2.")

			for not_is_eof() && has_not_error() && !at(.Close_Paren)
			{
				container_node_append(container,expression(.DEFAULT))
				skip(.Comma)
			}

			        expect(.Close_Paren,"expected ')' after Rect2 arguments.")
			argc := get_container_node_len(container)

			compile_error_cond(argc == 2, "Rect2 expects 2 arguments, but got %v",argc)
			return create_dinamic_node(.RECT,container,loc)
	}



	unreachable("Oops! It's a bug in Rect2 handle")
	return nil
}


transform :: proc(bp: BindPower) -> ^Node
{
	loc   := peek_cloc(); type := peek_ctype(); advance()
	if at(.Dot) do return create_named_var_node(peek_ptk().text,false,false,-1,loc)

	#partial switch type
	{
		case .Transform2D: 

			container := create_container_node()
			expect(.Open_Paren,"expected '(' after Transform2D.")

			for not_is_eof() && has_not_error() && !at(.Close_Paren)
			{
				container_node_append(container,expression(.DEFAULT))
				skip(.Comma)
			}

			        expect(.Close_Paren,"expected ')' after Transform2D arguments.")
			argc := get_container_node_len(container)

			compile_error_cond(argc == 3, "Transform2D expects 3 arguments, but got %v",argc)
			return create_dinamic_node(.TRANSFORM,container,loc)
	}



	unreachable("Oops! It's a bug in Transform2D handle")
	return nil
}



array :: proc(bp: BindPower) -> ^Node 
{
	loc       := peek_cloc(); advance()
	container := create_container_node()

	skip_for(.Newline,-1)

	for not_is_eof() && has_not_error() && !at(.Close_Bracket)
	{
		container_node_append(container,expression(.DEFAULT))
		skip(.Comma)
		skip_for(.Newline,-1)
	}

	expect(.Close_Bracket,"expected ']'.")
	return create_dinamic_node(.ARRAY,container,loc)
}


map_ :: proc(bp: BindPower) -> ^Node 
{
	loc       := peek_cloc(); advance()
	values    := create_container_node()

	skip_for(.Newline,-1)

	for not_is_eof() && has_not_error() && !at(.Close_Brace)
	{
		container_node_append(values,expression(.DEFAULT)); skip(.Colon)
		container_node_append(values,expression(.DEFAULT)); skip(.Comma)
		skip_for(.Newline,-1)
	}

	expect(.Close_Brace,"expected '}'.")
	return create_dinamic_node(.MAP,values,loc)
}


indexing :: proc(lhs: ^Node,bp: BindPower) -> ^Node
{
	loc    := peek_cloc(); advance()
	index  := expression(.DEFAULT)
	
	rhs    : ^Node
	set    : bool

	expect(.Close_Bracket,"expected ']'.")
	
	if at(.Equal) { advance(); rhs = expression(.DEFAULT); set = true }
	if op, ok := assignme2opcode(peek_ctype()); ok
	{
		advance(); set = true

		get_indexing := create_object_operator_node(false,lhs,index,rhs,loc)
		binary_node  := create_binary_node(op,get_indexing,expression(.DEFAULT),loc)

		return create_object_operator_node(set,lhs,index,binary_node,loc)
	}

	return create_object_operator_node(set,lhs,index,rhs,loc)
}

range :: proc(lhs: ^Node, bp: BindPower) -> ^Node 
{
	loc       := peek_cloc(); advance()
	container := create_container_node()
	rhs       := expression(.DEFAULT)

	container_node_append(container,lhs)
	container_node_append(container,rhs)

	return create_dinamic_node(.RANGE,container,loc)
}

signal :: proc(bp: BindPower) -> ^Node 
{
	loc       := peek_cloc(); advance()
	container := create_container_node()

	expect(.Open_Paren,"expected '(' after 'Signal'.")

	for not_is_eof() && has_not_error() && !at(.Close_Paren) { expect(.Identifier,"expected 'Identifier' as Signal arguments."); skip(.Comma) }

	expect(.Close_Paren,"expected ')'.")
	return create_dinamic_node(.SIGNAL,container,loc)
}


super :: proc(bp: BindPower) -> ^Node
{
	loc := peek_cloc(); advance()

	compile_error_cond(is_in_class(),"can't use 'super' outside of a class.")
	if has_error() do return create_bad_node(loc)

	has,ldata :=  scope_check_redeclaration_var(synthetic_token("this"))
	compile_error_assert(has,"Oops! this should not happen. It's a compiler bug in 'super' handler.")

	expect(.Open_Paren,"expected '(' after super keyword.")
	expect(.Close_Paren,"expected ')'.")

	expect(.Dot,"expected '.' after ")
	expect(.Identifier,"expect method name after '.'.")

	method_name_tk := peek_ptk()
	expect(.Open_Paren,"expected '(' after method name.")

	method_name := method_name_tk.text
	args        := argument_list(bp)
	lhs         := create_named_var_node("this",true,kind_can_assign(ldata.kind),ldata.index,loc)

	return create_super_call_method_node(method_name,lhs,args,loc)
}


this :: proc(bp: BindPower) -> ^Node 
{
	loc   := peek_cloc() ; advance()
	compile_error_cond(is_in_class(),"can't use 'this' outside of a class.")

	if has_error() do return create_bad_node(loc)

	has,ldata :=  scope_check_redeclaration_var(synthetic_token("this"))
	compile_error_assert(has,"Oops! this should not happen. It's a compiler bug in 'this' handler.")

	return create_named_var_node("this",true,kind_can_assign(ldata.kind),ldata.index,loc)
}