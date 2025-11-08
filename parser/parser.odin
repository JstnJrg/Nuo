package Parser

Parser :: struct 
{
	// state     : ParserState,
	p_tk      : Token,
	c_tk      : Token,
	err_count : int
}

ParserState :: struct
{
	p_tk : Token,
	c_tk : Token,
	err_count : int
}

create  	:: proc(alloator: Allocator) -> ^Parser { return new(Parser,alloator) }
destroy 	:: proc(p: ^Parser) { free(p) }

has_error	:: proc "contextless" (p: ^Parser) -> bool { return p.err_count > 0 }

at 			:: proc "contextless" (p: ^Parser,type: TokenType) -> bool { return p.c_tk.type == type }
at_previous :: proc "contextless" (p: ^Parser,type: TokenType) -> bool { return p.p_tk.type == type }

is_eof 		:: proc "contextless" (p: ^Parser) -> bool { return p.c_tk.type == .EOF }

// parser_save_state :: proc(p: ^Parser) 
// {
// 	state               := &t.state
// 	state.offset_start   = t.offset_start
// 	state.offset_current = t.offset_current
// 	state.line           = t.line
// 	state.column         = t.column
// }



tokenizer_save_state :: proc(t: ^Tokenizer) 
{
	state               := &t.state
	state.offset_start   = t.offset_start
	state.offset_current = t.offset_current
	state.line           = t.line
	state.column         = t.column
}

tokenizer_restore_state :: proc(t: ^Tokenizer) 
{
	state           := &t.state
	t.offset_start   = state.offset_start
	t.offset_current = state.offset_current
	t.line           = state.line
	t.column         = state.column
}


advance 	:: proc  (p: ^Parser,t: ^Tokenizer)
{
	p.p_tk = p.c_tk

	for	
	{
		p.c_tk = scan(t)
		
		if p.c_tk.type != .Error do break
		p.err_count += 1

		break
	}
}

expected	:: proc (p: ^Parser,t: ^Tokenizer,type: TokenType) -> (sucess: bool) {
	if  peek_current(p).type  == type { advance(p,t); sucess = true; return }
	return 
}

expected_previous	:: proc (p: ^Parser,t: ^Tokenizer,type: TokenType) -> (sucess: bool) { 
	if peek_previous(p).type  == type { advance(p,t); sucess = true; return }
	return 
}

peek_previous 		:: proc "contextless" (p: ^Parser) -> Token { return p.p_tk }
peek_current 		:: proc "contextless" (p: ^Parser) -> Token { return p.c_tk  }

peek_current_type 	:: proc "contextless" (p: ^Parser) -> TokenType { return peek_current(p).type  }
peek_previous_type 	:: proc "contextless" (p: ^Parser) -> TokenType { return peek_previous(p).type }

