#+private

package VM

@(optimization_mode="favor_size")
parse_stmt :: proc(bp : BindPower =.DEFAULT) -> ^Node 
{
	skip_stmt_terminator()

	loc   := peek_cloc()
	ttype := peek_ctype() 

	if !check(ttype) do return create_bad_node(loc)
	
	ok, stmt_calle := get_stmt_lu(ttype)
	
	if ok 
	{
		stmt_node := stmt_calle(bp)

		if is_if()  // solve if's bug    
		{ 
			if_end(); skip_stmt_terminator()
			return create_stmt_node(stmt_node)
		}
		if is_block_terminator(peek_ctype())
		{
			skip_stmt_terminator()
			return create_stmt_node(stmt_node)
		}

		expected_stmt_terminator("expected newline or semicolan at end of statement. got '%v'.",peek_ctk().text)
		skip_stmt_terminator()
		return create_stmt_node(stmt_node)
	}

	expr := expression(bp)

	// /*Nota(jstn): evita expressões com um termianador de expressões, caso seja  um e esteja em um bloco */	
	if is_block_terminator(peek_ctype()) { skip_stmt_terminator(); return create_expression_node(expr,loc) }

	expected_stmt_terminator("expected newline or semicolan at end of expression. got '%v'.",peek_ctk().text)
	skip_stmt_terminator()
	return create_expression_node(expr,loc)
}

@(optimization_mode="favor_size")
expression :: proc(bp :BindPower) -> ^Node 
{	
	loc           := peek_cloc() 
	type          := peek_ctype()
	ok,nud_callee := get_nud_lu(type)

	if !ok 
	{ 
		compile_error("unexpected token '%v', no nud handler.",peek_ctk().text);  
		return create_bad_node(loc) 
	}

	left := nud_callee(get_nud_bp(type))

	for not_is_eof() && has_not_error()
	{
		type   = peek_ctype(); lbp := get_led_bp(type)

		if lbp > bp 
		{
			ok,led_callee := get_led_lu(type)
			
			if !ok 
			{ 
				led_tk := peek_c(); loc = peek_cloc()
				compile_error("unexpected token '%v', no led handler.",peek_ctk().text) 
				return create_bad_node(loc)
			}

			left = led_callee(left,lbp)
		}
		else do break
	}

	return left
}