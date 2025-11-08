package Tokenizer

import utf8string "core:unicode/utf8/utf8string"
import unicode    "core:unicode"
import strings 	  "core:strings"
import mem        "core:mem"
import fmt        "core:fmt"
import util       "nuo:util"


NuoTerminator :: `EOF`
Error_Handler :: #type proc(pos: Localization, fmt: string, args: ..any)


Tokenizer 	  :: struct 
{
	state :         TokenizerState,
	src   : 		strings.Builder,
	bf 	  :			utf8string.String,
	path  :         string,
	error_handler:  Error_Handler,
	allocator:      mem.Allocator,
	len   :			int,
	offset_start  : int,
	offset_current: int,
	line   : 		int,
	column : 		int,
	rune_count:     int,
	err_count:      int
}


TokenizerState :: struct 
{
	offset_start   : int,
	offset_current : int,
	line           : int,
	column         : int
}

tokenizer_create   :: proc( allocator:= context.allocator ) -> ^Tokenizer 
{ 
	t     := new(Tokenizer,allocator)
	// bf, _ := strings.builder_make_none(allocator)

	// t.src = bf
	t.allocator = allocator
	return t 
}

tokenizer_destroy  :: proc (t: ^Tokenizer) 
{ 
	strings.builder_destroy(&t.src) 
	free(t,t.allocator)
}

tokenizer_save_state :: proc "contextless" (t: ^Tokenizer) 
{
	state               := &t.state
	state.offset_start   = t.offset_start
	state.offset_current = t.offset_current
	state.line           = t.line
	state.column         = t.column
}

tokenizer_restore_state :: proc "contextless" (t: ^Tokenizer) 
{
	state           := &t.state
	t.offset_start   = state.offset_start
	t.offset_current = state.offset_current
	t.line           = state.line
	t.column         = state.column
}


tokenizer_init :: proc(t: ^Tokenizer, source, path: string)
{
	// Nota(jstn): por conta do allocador arena, para evitar zonas mortas (mover de um lugar para outro o array dinamico)
	bf, _ := strings.builder_make_len_cap(0,len(source)+len(NuoTerminator),t.allocator)
	t.src  = bf
	
	// 
	strings.write_string(&t.src,source)
	strings.write_string(&t.src,NuoTerminator)

	utf8string.init(&t.bf,strings.to_string(t.src))

	t.error_handler  = tokenizer_default_error_handler
	t.path,_	     = util.get_absolute_path(path,t.allocator)
	t.len  		     = utf8string.len(&t.bf)-len(NuoTerminator)
	t.line   		 = t.len > 0 ? 1:0
	t.column 		 = t.len > 0 ? 1:0
}


tokenizer_default_error_handler :: proc(pos: Localization ,msg: string, args: ..any) 
{
	// C:/Users/JSTN JRG/Desktop/XscriptVersions/Nuo/nuo.odin(68:2) Error: Undeclared name: k
	fmt.eprintf(" [NUO TOKENIZER] %s (%d:%d) Error: ", pos.file, pos.line, pos.column)
	fmt.eprintf(msg, ..args)
	fmt.eprintf("\n")
}

error :: proc (t: ^Tokenizer, msg: string, args: ..any)
{
	if t.error_handler != nil do t.error_handler(peek_localization(t),msg,..args)
	t.err_count += 1
}


tokenizer_scan :: proc (t: ^Tokenizer) -> Token
{
	skip_whitespace(t); skip_comment(t)
	if is_eof(t) do return create_eof_token(t)

	scan_operator :: proc (t: ^Tokenizer) -> Token
	{
		helper :: proc (t: ^Tokenizer, ch :  rune, type_default,type: TokenType) -> (tk: Token)
		{
			if match(t,ch) { eat(t); tk = create_token(t,type) }
			else do  tk = create_token(t,type_default)

			same(t)
			return
		}

		helper2 :: proc (t: ^Tokenizer, ch_a, ch_b :  rune, type_default,type_a,type_b: TokenType) -> (tk: Token)
		{
			if      match(t,ch_a) { eat(t); tk = create_token(t,type_a) }
			else if match(t,ch_b) { eat(t); tk = create_token(t,type_b) }
			else do tk = create_token(t,type_default)

			same(t)
			return
		}
		
		helper3 :: proc (t: ^Tokenizer,type: TokenType) -> (tk: Token)
		{
			tk = create_token(t,type)
			same(t)
			return
		}

		switch at(t)
		{
			case '+': eat(t); return helper(t,'=',.Add,.Add_Eq)
			case '-': eat(t); return helper(t,'=',.Sub,.Sub_Eq)
			case '*': eat(t); return helper2(t,'=','*',.Mult,.Mult_Eq,.Mult_Mult)
			case '/': eat(t); return helper(t,'=',.Quo,.Quo_Eq)
			case '%': eat(t); return helper(t,'=',.Mod,.Mod_Eq)
			case '^': eat(t); return helper(t,'=',.Xor_Bit,.Xor_Bit_Eq)
			case '!': eat(t); return helper(t,'=',.Not,.Not_Eq)
			case '=': eat(t); return helper(t,'=',.Equal,.Equal_Eq)
			case '.': eat(t); return helper(t,'.',.Dot,.Dot_Dot)

			case '@': eat(t); return helper3(t,.At)
			case '~': eat(t); return helper3(t,.Not_Bit)
			case ';': eat(t); return helper3(t,.Semicolon)
			case ':': eat(t); return helper3(t,.Colon)
			case '?': eat(t); return helper3(t,.Question)
			case ',': eat(t); return helper3(t,.Comma)
			case '{': eat(t); return helper3(t,.Open_Brace)
			case '}': eat(t); return helper3(t,.Close_Brace)
			case '[': eat(t); return helper3(t,.Open_Bracket)
			case ']': eat(t); return helper3(t,.Close_Bracket)
			case '(': eat(t); return helper3(t,.Open_Paren)
			case ')': eat(t); return helper3(t,.Close_Paren)

			case '|': eat(t); return helper2(t,'=','|',.Or_Bit,.Or_Bit_Eq,.Or)
			case '&': eat(t); return helper2(t,'=','&',.And_Bit,.And_Bit_Eq,.And)
			case '<': eat(t); return helper2(t,'=','<',.Less,.Less_Eq,.Shift_L_Bit)
			case '>': eat(t); return helper2(t,'=','>',.Greater,.Greater_Eq,.Shift_R_Bit)

			case '\\': eat(t); if match(t,'\r') { eat(t); eat(t); newline2(t) } ; same(t); return tokenizer_scan(t)
			case '\n': eat(t); tk := helper3(t,.Newline); newline(t); return tk 
		}

		return create_error_token(t,"")
	}

	switch ch := at(t); ch
	{
	  case '0'..='9'            : return scan_number(t)
	  case 'a'..='z', 'A'..='Z' : return scan_identifier(t)
	  case '"'                  : return scan_string(t)
	  case '_'                  : return scan_underscore(t)

	  case '\n': fallthrough
	  case '\\': fallthrough
	  case '+' : fallthrough
	  case '-' : fallthrough
	  case '*' : fallthrough
	  case '/' : fallthrough
	  case '%' : fallthrough
	  case '^' : fallthrough
	  case '!' : fallthrough
	  case '=' : fallthrough
	  case '.' : fallthrough

	  case '~' : fallthrough
	  case ';' : fallthrough
	  case ':' : fallthrough
	  case '?' : fallthrough
	  case ',' : fallthrough
	  case '{' : fallthrough
	  case '}' : fallthrough
	  case '[' : fallthrough
	  case ']' : fallthrough
	  case '(' : fallthrough
	  case ')' : fallthrough

	  case '@' : fallthrough
	  case '|' : fallthrough
	  case '&' : fallthrough
	  case '<' : fallthrough
	  case '>' : return scan_operator(t)
	}

	error(t,"unexpected character %w was found.",at(t))
	return create_error_token(t,".")
}




scan_number :: proc(t: ^Tokenizer) -> (tk: Token)
{
	eat_digit :: proc(t: ^Tokenizer) { for unicode.is_digit(at(t)) do eat(t) }
	defer restore_count(t)

	eat_digit(t)

	for (match(t,'_') || match_count(t,'.'))
	{ 
		if !unicode.is_digit(at_next(t)) { if match_count_next(t,'.') do reduce_count(t,1); break }
		eat(t); eat_digit(t) 
	}

	tk = create_token(t,get_count(t) > 0 ? .Float:.Int)
	same(t)
	return 
}

scan_identifier :: proc(t: ^Tokenizer) -> (tk: Token)
{
	eat_letter  :: proc(t: ^Tokenizer) { for !is_eof(t) && unicode.is_letter(at(t)) do eat(t) }
	is_keywoord :: proc (t: ^Tokenizer, str : string) -> (bool,TokenType)
	{
		for i    in TokenType.L_Keyword_Begin..<TokenType.L_Keyword_End          do if Tokens[i] == str do return true,i
		for kw,i in custom_keyword_tokens do if custom_keyword_tokens[i] == str  { kind := int(TokenType.L_Custom_Keyword_Begin)+1+i; return true,TokenType(kind) }
		return false,.Identifier
	}

	eat_letter(t)

	ch := at(t)
	for !is_eof(t) && (match(t,'_') || unicode.is_digit(ch) || unicode.is_letter(ch)) { eat(t); ch = at(t)}

	_, kind := is_keywoord(t,at_slice(t))
	tk = create_token(t,kind)
	same(t)
	return 
}


scan_string :: proc(t: ^Tokenizer) -> (tk: Token)
{

	scan_escape :: proc (t: ^Tokenizer, bf : ^strings.Builder)
	{
		switch at(t)
		{
			case '"' : strings.write_rune(bf,'"')    ; eat(t)
			case '\\': strings.write_rune(bf,'\\')   ; eat(t)
			case '0' : strings.write_rune(bf,'\x00') ; eat(t)
			case 'a' : strings.write_rune(bf,'\a')   ; eat(t)
			case 'b' : strings.write_rune(bf,'\b')   ; eat(t)
			case 'e' : strings.write_rune(bf,'\x1b') ; eat(t)
			case 'n' : strings.write_rune(bf,'\n')   ; eat(t)
			case 'f' : strings.write_rune(bf,'\f')   ; eat(t)
			case 'r' : strings.write_rune(bf,'\r')   ; eat(t)
			case 't' : strings.write_rune(bf,'\t')   ; eat(t)
			case 'v' : strings.write_rune(bf,'\v')   ; eat(t)
			case '%' : strings.write_rune(bf,'%')    ; eat(t)
			case     : error(t,"illegal character %v in escape sequence.",at(t))
		}
	}

	eat(t)
	same(t)

	buf, _ := strings.builder_make_none(t.allocator)

	for !is_eof(t) && !match(t,'"')
	{
		ch := at(t); eat(t)

		if ch == '\\' { scan_escape(t,&buf); continue }
		strings.write_rune(&buf,ch)
	}
	
	if !match(t,'"') do error(t,"string literal was not terminated.")

	tk = create_string_token(t,strings.to_string(buf))
	eat(t)
	same(t)

	return 
}

scan_underscore :: proc(t: ^Tokenizer) -> (tk: Token)
{
	eat(t)

	if !is_eof(t) && (unicode.is_letter(at(t)) || unicode.is_digit(at(t))) do return scan_identifier(t)
	if match(t,'_') do return scan_identifier(t)


	tk = create_token(t,.Underscore)
	same(t)
	return 
}
