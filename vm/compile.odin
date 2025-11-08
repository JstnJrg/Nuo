package VM

import tknzr   "nuo:tokenizer"
import prsr    "nuo:parser" 

Node      :: prsr.Node
AstType   :: prsr.AstType
TokenType :: tknzr.TokenType
Token     :: tknzr.Token

@(private="file")   c_psr    : ^prsr.Parser
@(private="file")   c_tkzr   : ^tknzr.Tokenizer


compile   :: proc{compile_0,compile_1}

compile_0 :: proc(path: string, iid := -1, self_context := false ) -> int
{

	code,ok := load_script(path)
	if !ok do return -1

	// setup
	set_ctknzr(tknzr_create_and_init(code,path))
	set_cpsr(psr_create())

	create_lookup()
	register_lookups()

	// // compiler and codegen
	begin_new_compiler()
	defer end_new_compiler()

	codegen_init()
    codegen_set_iid(self_context? iid: 0)
    codegen_init_program()
    codegen_init_main_cache()

	/* Nota(jstn): Regista a db, afim de que estejam disponiveis
	no codigo, porém só classes que foram registadas antes da compilação 
	*/
	codegen_registe_db()
	global_declare_db(codegen_get_iid())


    //Nota(jstn): prepass
    register_prepass()
    prepass()

	// 
	advance()
	skip_stmt_terminator()

	// Nota(jstn): registra o actual script como depencia, pois está em uso
	path_hash := hash_dependecie(path)
	register_dependencies("",path_hash,peek_cloc())
	defer dependecie_set_in_use(path_hash,false)

	for not_is_eof() && has_not_error()
	{
		ctx_ast_begin_temp()
		defer ctx_ast_end_temp()		
		node := parse_stmt()
		
		if has_not_error() do codegen_generate(node)
	}

	return has_error() ? -1: codegen_finish()
}

compile_1 :: proc(code : string, iid : int ) -> int
{
	// setup
	set_ctknzr(tknzr_create_and_init(code,""))
	set_cpsr(psr_create())

	create_lookup()
	register_lookups()

	// // compiler and codegen
	begin_new_compiler()
	defer end_new_compiler()

	codegen_init()
	codegen_set_iid(iid)
	codegen_init_program()

	/* Nota(jstn): Regista a db, afim de que estejam disponiveis
	no codigo, porém só classes que foram registadas antes da compilação 
	*/
	codegen_registe_db()
	global_declare_db(codegen_get_iid())

	
    //Nota(jstn): prepass
    register_prepass()
    prepass()

	// 
	advance()
	skip_stmt_terminator()

	// Nota(jstn): registra o actual script como depencia, pois está em uso
	path_hash := hash_dependecie("")
	register_dependencies("",path_hash,peek_cloc())
	defer dependecie_set_in_use(path_hash,false)

	for not_is_eof() && has_not_error()
	{
		ctx_ast_begin_temp()
		defer ctx_ast_end_temp()		
		node := parse_stmt()
		
		if has_not_error() do codegen_generate(node)
	}

	return has_error() ? -1: codegen_finish()
}






psr_create            :: proc() -> ^prsr.Parser { return prsr.create(ctx_allocator()) }
apsr_create           :: proc() -> ^prsr.Parser { return prsr.create(ctx_aallocator()) }


tknzr_create_and_init :: proc(src,path: string) -> ^tknzr.Tokenizer
{
	t := tknzr.tokenizer_create(ctx_allocator())
	tknzr.tokenizer_init(t,src,path)
	return t
}

atknzr_create_and_init :: proc(src,path: string) -> ^tknzr.Tokenizer
{
	t := tknzr.tokenizer_create(ctx_aallocator())
	tknzr.tokenizer_init(t,src,path)
	return t
}

set_cpsr      :: proc "contextless" (p: ^prsr.Parser)      { c_psr  = p }
set_cpsr_err  :: proc "contextless" () { c_psr.err_count += 1 }
set_ctknzr    :: proc "contextless" (t: ^tknzr.Tokenizer)  { c_tkzr = t }

tk_save_state    :: proc "contextless" (t: ^tknzr.Tokenizer) { tknzr.tokenizer_save_state(t)    }
tk_restore_state :: proc "contextless" (t: ^tknzr.Tokenizer) { tknzr.tokenizer_restore_state(t) }


get_cpser     :: proc "contextless" () -> ^prsr.Parser     { return c_psr  }
get_ctknzr    :: proc "contextless" () -> ^tknzr.Tokenizer { return c_tkzr }

at            :: proc (tk_type: tknzr.TokenType ) -> bool { return prsr.at(get_cpser(),tk_type) }
at_p          :: proc (tk_type: tknzr.TokenType ) -> bool { return prsr.at_previous(get_cpser(),tk_type) }
is_eof        :: proc () -> bool { return prsr.is_eof(get_cpser()) }
not_is_eof    :: proc () -> bool { return !prsr.is_eof(get_cpser()) }
advance       :: proc () { prsr.advance(get_cpser(),get_ctknzr()) }
expect        :: proc (tk_type: tknzr.TokenType, fmt: string, args: ..any) -> bool 
{
	ok := prsr.expected(get_cpser(),get_ctknzr(),tk_type)
	if !ok do compile_error(fmt,..args)
	return ok
}

expect_p      :: proc (tk_type: tknzr.TokenType, fmt: string, args: ..any) -> bool 
{ 
	ok := prsr.expected_previous(get_cpser(),get_ctknzr(),tk_type) 
	if !ok do compile_error(fmt,..args)
	return ok
}
peek_ctk      :: proc() -> tknzr.Token { return prsr.peek_current(get_cpser()) }
peek_ptk      :: proc() -> tknzr.Token { return prsr.peek_previous(get_cpser()) }
peek_ctype    :: proc() -> tknzr.TokenType { return prsr.peek_current_type(get_cpser()) }
peek_ptype    :: proc() -> tknzr.TokenType { return prsr.peek_previous_type(get_cpser()) }
unreachable   :: proc(fmt: string,args: ..any, loc := #caller_location) { nuo_assert(false,fmt,..args); panic("") }

skip_stmt_terminator  :: proc() 
{ 
	for
	{
		#partial switch peek_ctype()
		{
			case .Newline   : fallthrough
			case .Semicolon : advance()
			case            : return
		} 
	}
}

check :: proc (ttype: TokenType) -> bool
{
	if is_in_scope() do return true

	#partial switch ttype 
	{ 
		case .Import: fallthrough
		case .Fn    : fallthrough 
		case .Set   : fallthrough
		// case .At    : fallthrough
		case .Class : return true 
	}

	compile_error_cond(false,"unexpected token was found in filescope.")
	return false
}

has_error     :: proc() -> bool { return prsr.has_error(get_cpser()) }
has_not_error :: proc() -> bool { return !prsr.has_error(get_cpser()) }

skip          :: proc(ttype: TokenType) { if at(ttype) do advance() }
pskip         :: proc() { for not_is_eof() && has_not_error() && !at(.Newline) && !at(.Semicolon) do advance() }
skip_for      :: proc(ttype: TokenType, limit : int = -1) 
{ 
	count : int = 0
	for at(ttype) { advance(); count += 1; if limit != -1 && count > limit do break }
}

peek_cloc   :: proc() -> Localization 
{ 
	loc                  := peek_ctk().position
	sid                  := string_db_register_string(loc.file)
	loc.file              = string_db_get_string(sid)
	return loc 
}

peek_ploc   :: proc() -> Localization 
{ 
	loc                  := peek_ptk().position
	sid                  := string_db_register_string(loc.file)
	loc.file              = string_db_get_string(sid)
	return loc 
}

is_stmt_terminator :: proc(tk_type: TokenType) -> bool
{
	#partial switch tk_type 
	{
		case .Newline:     fallthrough
		case .Semicolon:   fallthrough
		case .EOF:         return true
	}

	return false
}

is_block_terminator :: proc(tk_type: TokenType) -> bool
{
	#partial switch tk_type 
	{
		case .Close_Brace: return true
	}

	return false
}

expected_stmt_terminator :: proc(fmt: string, args: ..any)
{
	if is_stmt_terminator(peek_ctype()) { advance(); return }
	compile_error(fmt,..args)
}

compile_error_cond :: proc(condition: bool,fmt: string, args: ..any) 
{
	if condition do return
	compile_error(fmt,..args)
}


compile_error_assert :: proc(condition: bool,fmt: string, args: ..any) 
{
	if condition do return
	compile_error(fmt,..args)
	nuo_assert(condition,fmt,..args)
}


compile_error :: proc(fmt: string, args: ..any) 
{
	loc := peek_cloc(); set_cpsr_err()
	eprintf(" [NUO COMPILE] %s (%d:%d) Error: ",loc.file, loc.line, loc.column)
	eprintf(fmt, ..args)
	eprintf("\n")
}



assignme2opcode :: proc(t : TokenType ) -> (Opcode,bool) {

	opcode : Opcode = .OP_MAX

    #partial switch t {
	case .Add_Eq			: opcode = .OP_ADD
	case .Sub_Eq			: opcode = .OP_SUB
	case .Mult_Eq			: opcode = .OP_MULT
	case .Quo_Eq			: opcode = .OP_DIV
	case .Mod_Eq			: opcode = .OP_MOD
	case .And_Bit_Eq	 	: opcode = .OP_BIT_AND
	case .Or_Bit_Eq		  	: opcode = .OP_BIT_OR
	case .Xor_Bit_Eq		: opcode = .OP_BIT_XOR
	case .Shift_L_Bit_Eq  	: opcode = .OP_SHIFT_LEFT
	case .Shift_R_Bit_Eq  	: opcode = .OP_SHIFT_RIGHT
    }
	return opcode,opcode != .OP_MAX
}

tk_len           :: proc(t: tknzr.Token) -> int { return len(t.text) }
tk_equal         :: proc "contextless" (t: tknzr.Token, str: string) -> bool { return t.text == str }
synthetic_token  :: proc(value: string) -> Token { t: Token; t.position = peek_cloc() ; t.text = value; return t  }

synthetic_loc    :: proc(path := "", line := 0, column := 0, offset := 0) -> Localization
{ 
	@(static) loc : Localization
	loc = Localization{path,line,column,offset}
	return loc 
}
// p_pass_save_state    :: proc() { tk_save_state(get_current_tkzr()) }
// p_pass_restore_state :: proc() { tk_restore_state(get_current_tkzr()) }



