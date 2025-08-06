#+private

package VM



/*
	Nota(jstn): as funções e declarações que usam o prepass devem somente
	serem chamads dentro de uma função principal, como main ,senão o aplicativo crasha
*/


PrepassCallType :: #type proc()

@(cold,private = "file")
_prepass :: proc "contextless" (type: TokenType, callable: PrepassCallType ) 
{
	cludata        := get_call_lookup_data(type)
	cludata.ppass   = callable
}

get_prepass_call :: proc "contextless" (type: TokenType ) -> (bool,PrepassCallType)
{
	cludata := get_call_lookup_data(type)
	ok      := cludata.ppass != nil
	return ok, cludata.ppass
}


@(optimization_mode="favor_size")
prepass :: proc()
{
	t :=  get_ctknzr()

	      tk_save_state(t)
    defer tk_restore_state(t)
 
	advance()
	skip_stmt_terminator()

	for not_is_eof() && has_not_error()
	{
		skip_stmt_terminator()
		ttype := peek_ctype()

		if !check(ttype) do break

		ok, ppass_stmt := get_prepass_call(ttype)

		if ok 
		{
			ppass_stmt()
			if is_eof() || has_error()   do break

			expected_stmt_terminator("expected newline or semicolan at end of statement. got '%v'.",peek_ctk().text)
			skip_stmt_terminator()
			continue
		}

		prepass_default()
		// compile_error_cond(false,"'%v' bad prepass token. token not register. ", peek_ctk().text)
	}
}


register_prepass ::proc()
{
	_prepass(.Import,prepass_default)
	_prepass(.Set,prepass_default)
	// _prepass(.Print,prepass_default)
	// _prepass(.Enum,prepass_enum)

	_prepass(.Fn,prepass_fn)
	_prepass(.Class,prepass_class)
}

prepass_default :: proc() { pskip() }

prepass_fn  :: proc()
{
	loc       := peek_cloc(); advance()

	expect(.Identifier,"expected a function name after 'fn'."); function_name_tk := peek_ptk()
	expect(.Open_Paren," expected '(' after function name.")

	compile_error_cond(tk_len(function_name_tk) < MAX_VARIABLE_NAME,"function name cannot be longer than '%v' characters.",MAX_VARIABLE_NAME)

	has, gdata :=  global_check_redeclaration_var(function_name_tk)
	if has do compile_error_cond(!has,"function '%v' has the same name as a previously declared '%v' at (%v,%v).",function_name_tk.text,kind2string(gdata.kind),gdata.loc.line,gdata.loc.column)
		
	argc   : int    = 0
	name   : string = function_name_tk.text

	for not_is_eof() && has_not_error() && !at(.Close_Paren) 
	{
		expect(.Identifier,"expected a parameter name.")
		var_name_tk  := peek_ptk()

		skip(.Comma)
		argc += 1

		compile_error_cond(tk_len(var_name_tk) < MAX_VARIABLE_NAME,"argument name cannot be longer than '%v' characters.",MAX_VARIABLE_NAME)
		compile_error_cond(argc < MAX_ARGUMENTS,"cannot have more than '%v' arguments, but got '%v'.",MAX_ARGUMENTS,argc)
	}

	expect(.Close_Paren," expected ')' after function parameters.")

	// Nota(jstn): só permite dois paragrafos por função (até o corpo)
	skip_for(.Newline,2)

	// Nota(jstn): torna a função acessivel a ela mesma
	global_declare_entety(function_name_tk,.FUNCTION,loc)
	prepass_block()

	// 
	codegen_initialize_global(name)
}

prepass_block :: proc()
{
	expect(.Open_Brace,"expected open '{{' before block body. got '%v'.",peek_ctype())
	skip_stmt_terminator()

	bcount : int = 1

	for not_is_eof() && has_not_error()
	{
		if      at(.Open_Brace)  do bcount += 1
		else if at(.Close_Brace) do bcount -= 1
		
		if bcount <= 0 do break
		advance()		
	}

	expect(.Close_Brace,"expected closing '}' after block body. got '%v'.",peek_ctype())
}

prepass_class :: proc()
{
	loc       := peek_cloc(); advance()

	expect(.Identifier,"expected a Class name after 'Class'."); class_name_tk := peek_ptk()
	compile_error_cond(tk_len(class_name_tk) < MAX_VARIABLE_NAME,"class name cannot be longer than '%v' characters.",MAX_VARIABLE_NAME)

	// 
	if at(.Extends) { for not_is_eof() && !at(.Open_Brace) do advance() }
	
	// 
	name := class_name_tk.text
	has, gdata :=  global_check_redeclaration_var(class_name_tk)
	if has do compile_error_cond(!has,"Class '%v' has the same name as a previously declared '%v' at (%v,%v).",class_name_tk.text,kind2string(gdata.kind),gdata.loc.line,gdata.loc.column)
	
	global_declare_entety(class_name_tk,.CLASS,loc)

	skip_for(.Newline,0)
	prepass_block()

	// 
	codegen_initialize_global(name)
}





// prepass_enum :: proc()
// {
// 	loc := peek_clocalization(); advance()

// 	expect(.Identifier,"expected a 'enum' name.")
// 	enum_name := peek_p()

// 	// Nota(jstn): verifica se existe uma declaração global, caso seja  uma  variavel global
// 	if has, gdata :=  global_check_redeclaration_var(enum_name); has {
// 	     error("'enum' '",enum_name.text,"' has the same name as a previously declared '",kind2string(gdata.kind),"' at (",gdata.pos.line,",",gdata.pos.column,").")
// 		 return
// 	}

// 	// Nota(jstn): verifica o comprimento do nome
// 	if token_len(&enum_name) > MAX_VARIABLE_NAME do error("identifier name cannot be longer than ",MAX_VARIABLE_NAME," characters.")

// 	expect(.Open_Brace,"expected '{' after enum name.")

// 	a: for !is_eof() && !has_error() && !at(.Close_Brace)
// 	{
// 		expect(.Identifier,"expected a identifier for 'enum' key.")
// 		t := peek_p()
// 		// 
// 		if at(.Equal)
// 		{
// 			advance()

// 			for !is_eof() && !has_error() && !at(.Comma)
// 			{
// 			   #partial switch peek_ctype() 
// 			   {
// 			      case .Float   : error("enum values must be integers"); break a
// 			      case .Int,.Add,.Sub,.Mult,.Quo,.Mod,.Mult_Mult :
// 			      case          : error("enum values must be constants"); break a
// 			   }

// 			   advance()
// 			}
// 		}

// 		if at(.Comma) do advance()
// 	}


// 	expect(.Close_Brace,"expected '}' for 'enum'.")
// 	global_declare_enum(enum_name,loc)
// }
