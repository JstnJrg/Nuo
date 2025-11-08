package Tokenizer

import utf8string "core:unicode/utf8/utf8string"
import unicode    "core:unicode"
import strings 	  "core:strings"


at  	    :: proc(t: ^Tokenizer) -> rune { return utf8string.at(&t.bf,t.offset_current)}

match 	    :: proc(t: ^Tokenizer, tk : rune ) -> bool { return utf8string.at(&t.bf,t.offset_current) == tk }

match_safe  :: proc(t: ^Tokenizer, tk : rune ) -> bool { return !is_eof(t) && utf8string.at(&t.bf,t.offset_current) == tk }

match_count :: proc(t: ^Tokenizer, tk : rune ) -> bool 
{ 
	value := (utf8string.at(&t.bf,t.offset_current) == tk)
	if value do t.rune_count += 1
	return value
}

match_count_next :: proc(t: ^Tokenizer, tk : rune ) -> bool 
{ 
	value := (utf8string.at(&t.bf,t.offset_current+1) == tk)
	return value
}

reduce_count :: proc(t: ^Tokenizer, offset: int ) { t.rune_count -= offset }


restore_count :: proc "contextless" (t: ^Tokenizer) { t.rune_count = 0 }
get_count     :: proc "contextless" (t: ^Tokenizer) -> int  { return t.rune_count }

newline     :: proc (t: ^Tokenizer) { t.line += 1; t.column = 0 }

newline2    :: proc (t: ^Tokenizer) { t.line += 1 }

at_next     :: proc(t: ^Tokenizer) -> rune { return utf8string.at(&t.bf,t.offset_current+1)}

eat 	    :: proc "contextless" (t: ^Tokenizer) { t.offset_current +=1; t.column +=1 }

at_slice    :: proc(t: ^Tokenizer) -> string { return utf8string.slice(&t.bf,t.offset_start,t.offset_current) }

same        :: proc "contextless" (t: ^Tokenizer) { t.offset_start = t.offset_current }

is_eof      :: proc "contextless" (t: ^Tokenizer) -> bool { return t.offset_current >= t.len }

has_error   :: proc "contextless" (t: ^Tokenizer) -> bool { return t.err_count > 0 }

skip_whitespace :: proc(t: ^Tokenizer) 
{
	loop: for
	{
		if is_eof(t) do break loop
		switch at(t) 
		{ 
			case '\t','\r','\v',' ','\f':  eat(t)
			case : break loop
		}
	}
	
	same(t)
}

skip_comment :: proc(t: ^Tokenizer) 
{ 
	 if  !match(t,'#')       do return
	 for !match_safe(t,'\n') && !is_eof(t) do eat(t) 
	 same(t)	
}


create_token 	 :: proc(t: ^Tokenizer,type: TokenType ) -> (token: Token) 
{
	token.type 		= type
	token.text 		= at_slice(t)
	token.position	= peek_localization(t)
	return
}

create_string_token 	 :: proc(t: ^Tokenizer,data: string ) -> (token: Token) 
{
	token.type 		= .String
	token.text 		= data
	token.position	= peek_localization(t)
	return
}

peek_localization   :: proc "contextless" (t: ^Tokenizer) -> Localization { return Localization{t.path,t.line,t.column,t.offset_current} }


synthetic_token 	:: proc(value: string) -> Token { t: Token; t.text = value; return t  }
token_equals 		:: proc(t : ^Token, s: string) -> bool { return t.text == s }


create_eof_token :: proc(t: ^Tokenizer) -> (token: Token) 
{
	token.type 		= .EOF
	token.text 		= "EOF"
	token.position	= peek_localization(t)
	return
}

create_error_token :: proc(t: ^Tokenizer,message : string) -> (token: Token)
{
	token.type 		= .Error
	token.text 		= message
	token.position	= peek_localization(t)
	return
}



