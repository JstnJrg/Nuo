package VM


import_stmt :: proc(bp: BindPower) -> ^Node 
{
	loc := peek_cloc(); advance()
	expect(.Identifier,"expected a import name")
	
	import_name_tk := peek_ptk()

	compile_error_cond(!is_in_scope(),"import must be in global scope.")
	compile_error_cond(tk_len(import_name_tk) < MAX_VARIABLE_NAME,"import name cannot be longer than '%v' characters.",MAX_VARIABLE_NAME)

	//==========================
	import_native_stmt :: proc(import_name_tk : Token, loc: Localization) -> ^Node 
	{ 
		global_declare_entety(import_name_tk,.IMPORT,loc)
		return create_import_node(-1,-1,import_name_tk.text,"",false,true,loc) 
	}
	if !at(.String) do return import_native_stmt(import_name_tk,loc)

	expect(.String,"expected import path")
	
	import_path_tk := peek_ptk()
	path_hash      := hash_dependecie(import_path_tk.text)

	if has, loc    := has_dependencie(path_hash); has
	{
		if is_dependecie_in_use(path_hash) do compile_error_cond(false,"cyclic import. '%v' is still in use at '%v'",import_path_tk.text,loc.file)
		if ok, iname := was_importated(path_hash); has
		{
	        global_declare_entety(import_name_tk,.IMPORT,loc)
			return create_import_node(-1,-1,import_name_tk.text,iname,true,false,loc)
		}	
	}
	

	if has_error() do return create_bad_node(loc)

	code,ok := load_script(import_path_tk.text)
    compile_error_cond(ok,"something went wrong in load '%v'.",import_path_tk.text)

    if has_error() do return create_bad_node(loc)

    e_prs   := get_cpser()
    e_tknzr := get_ctknzr()
	
	// Nota(jstn): registra o actual script como depencia
	// para evitar referencias ciclicas de scripts
	register_dependencies(import_name_tk.text,path_hash,loc)

	defer
	{
		_has_not_error := has_not_error()
		set_ctknzr(e_tknzr)
        set_cpsr(e_prs)

        // 
        global_declare_entety(import_name_tk,.IMPORT,loc)
        dependecie_set_in_use(path_hash,false)

        compile_error_cond(_has_not_error,"something went wrong at compiling import.")
	}



	// // Nota(jstn): inicializa a analise do novo ficheiro

	set_ctknzr(atknzr_create_and_init(code,import_path_tk.text))
	set_cpsr(apsr_create())


	// // Nota(jstn): inicializa um novo compilador evitando
	// // assim dados compartilhados
	
	abegin_new_acompiler()
	defer end_new_compiler()

    //Nota(jstn): prepass
    prepass()

	// start
	advance()
	skip_stmt_terminator()

	// Nota(jstn): programa corrente
	fid := codegen_get_fid()
	defer codegen_set_fid(fid)

	// troca os contextos
	e_iid  := codegen_get_iid()
	iid    := register_import(import_name_tk.text,.IMPORT)

	codegen_set_iid(iid)
	defer codegen_set_iid(e_iid)

	// nota(jstn): novo programa
	codegen_init_new_program()

	/* Nota(jstn): Regista a db, afim de que estejam disponiveis
	no codigo, porém só classes que foram registadas antes da compilação 
	*/
	codegen_registe_db()
	global_declare_db(codegen_get_iid())
	

    ctx_ast_begin_temp()
	for not_is_eof() && has_not_error()
	{
		node := parse_stmt()
		if has_not_error() do codegen_generate(node)
	}

	ctx_ast_end_temp()
	nfid := codegen_finish()

	return create_import_node(nfid,iid,import_name_tk.text,"",false,false,loc)

	// return create_import_node(container,import_name.text,hash_string(import_path.text),false,false,loc)
}


class_stmt :: proc(bp: BindPower) -> ^Node
{
	loc       := peek_cloc(); advance()
	expect(.Identifier,"expected a Class name after 'Class'."); class_name_tk := peek_ptk()
	
	// Extends
	super   : ^Node
	extends : bool


	if at(.Extends) 
	{
		advance()
		super   = expression(bp)
		extends = true
	}

	skip_for(.Newline,0)
	expect(.Open_Brace," expected '{{' after class name.")

	compile_error_cond(!is_in_scope(),"class must be in global scope.")
	compile_error_cond(tk_len(class_name_tk) < MAX_VARIABLE_NAME,"class name cannot be longer than '%v' characters.",MAX_VARIABLE_NAME)

	// Nota(jstn): o prepass já verificou
	// 
	// has, gdata :=  global_check_redeclaration_var(class_name_tk)
	// if has do compile_error_cond(!has,"Class '%v' has the same name as a previously declared '%v' at (%v,%v).",class_name_tk.text,kind2string(gdata.kind),gdata.loc.line,gdata.loc.column)
	
	// Nota(jstn): o prepass já declarou
	// global_declare_entety(class_name_tk,.CLASS,loc)

	// 
	methods := create_container_node(); skip_stmt_terminator()

	      begin_class()
	defer end_class()
	
	for not_is_eof() && has_not_error() && !at(.Close_Brace)
	{
		method := parse_method(); skip_stmt_terminator()
		container_node_append(methods,method)
	}

	expect(.Close_Brace," expected '}' after class body.")
	return create_class_node(class_name_tk.text,extends,super,methods,loc)

}

parse_method :: proc() -> ^Node
{
	loc := peek_cloc()

	expect(.Identifier,"expected a method name ."); method_name_tk := peek_ptk()
	expect(.Open_Paren," expected '(' after method name.")
	
	compile_error_cond(tk_len(method_name_tk) < MAX_VARIABLE_NAME,"method name cannot be longer than '%v' characters.",MAX_VARIABLE_NAME)
	
	      begin_function()
	defer end_function()

	ptype  := get_function_type()
	mtype  := tk_equal(method_name_tk,CLASS_INIT)
	mdtype := mtype ? false : tk_equal(method_name_tk,CLASS_DEINIT)


	      set_function_type(mtype ? .TYPE_INITIALIZER: mdtype ?  .TYPE_DEINITIALIZER : .TYPE_METHOD) 
	defer set_function_type(ptype)


	// Nota(jstn): Scopo dos parametros da função
	argc : int     = 0
	name : string  = method_name_tk.text

	      push_control_data(compiler_get_scope_depth(),.FUNCTION)
	defer pop_control_data()

	       begin_scope()
	defer  end_scope()

	for not_is_eof() && has_not_error() && !at(.Close_Paren) 
	{
		expect(.Identifier,"expected a parameter name.")

		var_name_tk  := peek_ptk()
		has, ldata   := scope_check_redeclaration_var(var_name_tk)

		if has do compile_error_cond(!has,"argument '%v' has the same name as a previously declared '%v' at (%v,%v).",var_name_tk.text,kind2string(ldata.kind),ldata.loc.line,ldata.loc.column)

		scope_declare_entety(var_name_tk,.IDENTIFIER,var_name_tk.position)
		skip(.Comma)

		argc += 1

		compile_error_cond(tk_len(var_name_tk) < MAX_VARIABLE_NAME,"argument name cannot be longer than '%v' characters.",MAX_VARIABLE_NAME)
		compile_error_cond(argc < MAX_ARGUMENTS,"cannot have more than '%v' arguments, but got '%v'.",MAX_ARGUMENTS,argc)
	}
	
	expect(.Close_Paren," expected ')' after function parameters.")

	// 
	this_tk := synthetic_token("this")
	scope_declare_entety(this_tk,.IDENTIFIER,loc)


	// Nota(jstn): só permite dois paragrafos por função (até o corpo)
	skip_for(.Newline,2)

	// // Nota(jstn): torna a função acessivel a ela mesma
	// global_declare_entety(function_name_tk,.IDENTIFIER,loc)

	body      := block_stmt(.DEFAULT)
	container := create_container_node()
	m_return  := create_default_return_node(scope_get_local_count(),loc)

	container_node_append(container,body)

	// Nota(jstn): é oconstructor da class, não pode retornar nada
	// e devemos garantir que retorne a instancia

	// Nota(jstn): _deinit não pode receber paramentros
	if mtype
	{
	    has,ldata :=  scope_check_redeclaration_var(this_tk)
	    compile_error_assert(has,"Oops! this should not happen. It's a compiler bug in 'parse_method' handler.")
	    m_return  = create_return_node(scope_get_local_count(),create_named_var_node("this",true,kind_can_assign(ldata.kind),ldata.index,loc),loc)
	}
	else if mdtype do compile_error_cond(argc == 0,"'%v' should not receiver arguments.",CLASS_DEINIT)


	// Nota(jstn): para sair do metodo
	container_node_append(container,m_return)

	sbody     := create_block_node(scope_get_local_count(),container,loc)
	return create_function_node(name,argc,sbody,loc)
}


fn_stmt        :: proc(bp: BindPower) -> ^Node
{
	loc       := peek_cloc(); advance()

	expect(.Identifier,"expected a function name after 'fn'."); function_name_tk := peek_ptk()
	expect(.Open_Paren," expected '(' after function name.")
	compile_error_cond(!is_in_scope(),"function must be in global scope.")

	compile_error_cond(tk_len(function_name_tk) < MAX_VARIABLE_NAME,"function name cannot be longer than '%v' characters.",MAX_VARIABLE_NAME)
	
	// Nota(jstn): o prepass já checou e declarou a função
	// has, gdata :=  global_check_redeclaration_var(function_name_tk)
	// if has do compile_error_cond(!has,"function '%v' has the same name as a previously declared '%v' at (%v,%v).",function_name_tk.text,kind2string(gdata.kind),gdata.loc.line,gdata.loc.column)
	
	// 
	      begin_function()
	defer end_function()

	ptype :=  get_function_type()
	          set_function_type(.TYPE_FUNCTION)
	defer     set_function_type(ptype)
	// 

	// create_function_node()
	// Nota(jstn): Scopo dos parametros da função
	argc : int     = 0
	name : string  = function_name_tk.text

	      push_control_data(compiler_get_scope_depth(),.FUNCTION)
	defer pop_control_data()

	       begin_scope()
	defer  end_scope()

	for not_is_eof() && has_not_error() && !at(.Close_Paren) 
	{
		expect(.Identifier,"expected a parameter name.")

		var_name_tk  := peek_ptk()
		has, ldata   := scope_check_redeclaration_var(var_name_tk)

		if has do compile_error_cond(!has,"argument '%v' has the same name as a previously declared '%v' at (%v,%v).",var_name_tk.text,kind2string(ldata.kind),ldata.loc.line,ldata.loc.column)

		scope_declare_entety(var_name_tk,.IDENTIFIER,var_name_tk.position)
		skip(.Comma)

		argc += 1

		compile_error_cond(tk_len(var_name_tk) < MAX_VARIABLE_NAME,"argument name cannot be longer than '%v' characters.",MAX_VARIABLE_NAME)
		compile_error_cond(argc < MAX_ARGUMENTS,"cannot have more than '%v' arguments, but got '%v'.",MAX_ARGUMENTS,argc)
	}
	
	expect(.Close_Paren," expected ')' after function parameters.")


	// Nota(jstn): só permite dois paragrafos por função (até o corpo)
	skip_for(.Newline,2)

	// Nota(jstn): ajuda a capturar
	// scope_depth := compiler_get_scope_depth()

	// Nota(jstn): o prepass já fez isso
	// Nota(jstn): torna a função acessivel a ela mesma
	// global_declare_entety(function_name_tk,.FUNCTION,loc)

	body      := block_stmt(bp)
	container := create_container_node(); 

	container_node_append(container,body)
	container_node_append(container,create_default_return_node(argc,loc))

	sbody     := create_block_node(scope_get_local_count(),container,loc)

	return create_function_node(name,argc,sbody,loc)
}

print_stmt     :: proc(bp: BindPower) -> ^Node 
{
	loc       := peek_cloc()
	container := create_container_node(); advance()

	if is_stmt_terminator(peek_ctype()) || is_block_terminator(peek_ctype()) do container_node_append(container,create_literal_node(.OP_NIL,loc))
	else do for !is_stmt_terminator(peek_ctype()) && !is_block_terminator(peek_ctype()) && has_not_error() { container_node_append(container,expression(bp)); skip(.Comma) }

	return 	create_print_node(container,loc)
}


var_stmt   :: proc(bp: BindPower) -> ^Node 
{
	if is_in_scope() do return var_stmt_local(bp)

	advance(); loc := peek_cloc()
	expect(.Identifier,"expected a variable name after 'var'. got '%v'.",peek_ctype())

	var_name_tk := peek_ptk()
	compile_error_cond(tk_len(var_name_tk) < MAX_VARIABLE_NAME,"variable name cannot be longer than '%v' characters.",MAX_VARIABLE_NAME)

	has, gdata :=  global_check_redeclaration_var(var_name_tk)
	if has do compile_error_cond(!has,"variable '%v' has the same name as a previously declared '%v' at (%v,%v).",var_name_tk.text,kind2string(gdata.kind),gdata.loc.line,gdata.loc.column)
	
	rhs : ^Node

	if   at(.Equal) { advance(); rhs = expression(bp) }
	else do rhs = create_literal_node(.OP_NIL,loc)

	global_declare_entety(var_name_tk,.IDENTIFIER,loc)
	return create_definevariable_node(var_name_tk.text,false,rhs,loc)
}

var_stmt_local :: proc(bp: BindPower) -> ^Node
{

	advance(); loc := peek_cloc()
	expect(.Identifier,"expected a variable name after 'var'. got '%v'.",peek_ctype())

	var_name_tk := peek_ptk()

	has,ldata := scope_check_redeclaration_var(var_name_tk)
	if has do compile_error_cond(!has,"variable '%v' has the same name as a previously declared '%v' at (%v,%v).",var_name_tk.text,kind2string(ldata.kind),ldata.loc.line,ldata.loc.column)
	
	rhs : ^Node

	if   at(.Equal) { advance(); rhs = expression(bp) }
	else do rhs = create_literal_node(.OP_NIL,loc)

	scope_declare_entety(var_name_tk,.IDENTIFIER,loc)
	return create_definevariable_node(var_name_tk.text,true,rhs,loc)
}

while_stmt :: proc( bp: BindPower ) -> ^Node
{
	loc := peek_cloc(); advance()

	// 
	      begin_loop()
	defer end_loop()

	// Nota(jstn): +1, pois o bloco é quem inicializa um scope
	push_control_data(compiler_get_scope_depth(),.LOOP)
	defer pop_control_data()

	// 

	condition := expression(.DEFAULT); skip_for(.Newline,1)
	body      := block_stmt(bp)

	return create_while_node(condition,body,loc)
}

for_stmt :: proc( bp: BindPower ) -> ^Node
{
	loc := peek_cloc(); advance()

	begin_scope()
	defer end_scope()

	expect(.Identifier,"expected loop variable name after 'for'."); var_name_tk := peek_ptk()
	compile_error_cond(tk_len(var_name_tk) < MAX_VARIABLE_NAME,"variable name cannot be longer than '%v' characters.",MAX_VARIABLE_NAME)
	
	has,ldata := scope_check_redeclaration_var(var_name_tk)
	if has do compile_error_cond(!has,"variable '%v' has the same name as a previously declared '%v' at (%v,%v).",var_name_tk.text,kind2string(ldata.kind),ldata.loc.line,ldata.loc.column)
	
	expect(.In,"expected 'in' after for loop variable.")

	expr := expression(.DEFAULT)

	begin_loop()
	defer end_loop()
	
	push_control_data(compiler_get_scope_depth(),.LOOP)
	defer pop_control_data()

	/*
		for cond in expr

		as

		{

			set expr_t   = expr
			set cond     = null
			set value_t  = null
			
			while 
			(  value_t = expr_t.iterate(value_t)
			   cond    = expr_t.next(value_t)
			   exp_t.end(value_t) -> deve retornar um bool e deixar na pilha
			)
			{
				//expressoes, codigo
			}



		}
	
	*/

	// Nota(jstn):  precisamos proteger essas variaveis, pois são ocultas

	expr_t      := synthetic_token(".expr_t")
	value_t     := synthetic_token(".value_t")

	scope_declare_entety(expr_t,.IDENTIFIER,loc)
	scope_declare_entety(var_name_tk,.IDENTIFIER,loc)
	scope_declare_entety(value_t,.IDENTIFIER,loc)

	// 
	hidden_body := create_container_node() 
	nil_node    := create_literal_node(.OP_NIL,loc)

	// 0
	container_node_append(hidden_body,create_stmt_node(create_definevariable_node(expr_t.text,true,expr,loc)))
	container_node_append(hidden_body,create_stmt_node(create_definevariable_node(var_name_tk.text,true,nil_node,loc)))
	container_node_append(hidden_body,create_stmt_node(create_definevariable_node(value_t.text,true,nil_node,loc)))

	// gets

	_,ldata_e := scope_check_redeclaration_var(expr_t)
	get_expr_t  := create_named_var_node(expr_t.text,true,kind_can_assign(ldata_e.kind),ldata_e.index,loc)

	_,ldata_v   := scope_check_redeclaration_var(value_t)
	get_value_t := create_named_var_node(value_t.text,true,kind_can_assign(ldata_v.kind),ldata_v.index,loc)

	_,ldata_c   := scope_check_redeclaration_var(var_name_tk)
	get_cond    := create_named_var_node(var_name_tk.text,true,kind_can_assign(ldata_c.kind),ldata_c.index,loc)


	// (1) value_t = expr_t.iterate(null)
	container_args   := create_container_node(); container_node_append(container_args,get_value_t)
	call_node        := create_call_method_node(".iterate",get_expr_t,container_args,loc)
	expr_0           := create_expression_node(create_assignment_node(value_t.text,true,ldata_v.index,call_node,loc),loc)

	// (2) cond = expr_t.next(value_t)
	container_args_1 := create_container_node(); container_node_append(container_args_1,get_value_t)
	call_node_1      := create_call_method_node(".next",get_expr_t,container_args_1,loc)
	expr_1           := create_expression_node(create_assignment_node(var_name_tk.text,true,ldata_c.index,call_node_1,loc),loc)

	// (3) expr_t.end(value_t)
	container_args_2 := create_container_node(); container_node_append(container_args_2,get_value_t)
	call_node_2      := create_call_method_node(".end",get_expr_t,container_args_2,loc)

	// 
	skip_for(.Newline,1)
	body   := block_stmt(bp)

	// Nota(jstn): condiction container
	// as duas primeiras expressões, são ''expr'', portanto depois saiem da pilha
	// a ultima permanece por não ser, e será avaliada como a condição

	condition_container := create_container_node()
	container_node_append(condition_container,expr_0) 
	container_node_append(condition_container,expr_1)
	container_node_append(condition_container,call_node_2)

	while_node := create_while_node(condition_container,body,loc)

	// 
	container_node_append(hidden_body,while_node)

	// parameters body
	block := create_block_node(scope_get_local_count(),hidden_body,loc)
	return create_for_node(block,loc)
}




match_stmt :: proc(bp: BindPower) -> ^Node 
{
	loc       := peek_cloc(); advance()
	condition := expression(bp)

	skip_for(.Newline,2)
	expect(.Open_Brace,"expected '{{' after match condition.")

	cases   := create_container_node()
	bodies  := create_container_node()
	
	dbody         : ^Node
	cases_count   : int
	default_count : int

	skip_for(.Newline)

	for not_is_eof() && has_not_error() && !at(.Close_Brace)
	{
		cases_count += 1
		
		compile_error_cond(cases_count < MAX_MATCH_CASE,"too many match cases.")
		compile_error_cond(default_count <= 1,"multiple default clauses")

		if at(.Underscore)
		{
			advance()
			expect(.Colon,"expected ':' after '_' .")
			dbody = match_block_stmt(bp); skip_for(.Newline)
			default_count += 1
			continue
		}

	    expect(.Case,"'%v' unexpected token was found in match stmt.",peek_ctk().text)
		container_node_append(cases,expression(bp))

		expect(.Colon,"expected ':' after condition.")
		container_node_append(bodies,match_block_stmt(bp))
		skip_for(.Newline)
	}

	expect(.Close_Brace,"expected '}' after match statement. got '%v'",peek_ctype())
	return create_match_node(condition,cases,bodies,dbody,default_count > 0,loc)
}

match_block_stmt :: proc( bp: BindPower ) -> ^Node
{

	loc := peek_cloc()

	skip_stmt_terminator()
	body := create_container_node()
	
	begin_scope()
	defer end_scope()

	for not_is_eof() && has_not_error() && !at(.Close_Brace) && !at(.Case) && !at(.Underscore) do container_node_append(body,parse_stmt(.DEFAULT))
	return create_block_node(scope_get_local_count(),body,loc)
}

if_stmt :: proc( bp: BindPower ) -> ^Node
{
	loc := peek_cloc(); advance()

	condition     := expression(.DEFAULT); skip_for(.Newline,2)
	body          := block_stmt(bp)
	elif          : ^Node

	newline_count := 1
	skip_for(.Newline,newline_count)

	#partial switch peek_ctype() 
	{
		case .Elif: elif = elif_stmt(bp,newline_count)
		case .Else: elif = else_stmt(bp,newline_count)
	}

	/*
		Nota(jstn): resolve o bug do if, no caso de
		procurar por elif, else e não enontrar, acaba por consumir
		alguns tokens que terminam uma stmt
	*/
	if_begin()


	
	return create_if_node(condition,body,elif,loc)
}

elif_stmt :: proc(bp: BindPower, newline_count: int ) -> ^Node
{
	loc := peek_cloc(); advance()

	condition     := expression(.DEFAULT); skip_for(.Newline,newline_count)
	body          := block_stmt(bp)
	elif          : ^Node
	
	skip_for(.Newline,newline_count)

	#partial switch peek_ctype() 
	{
		case .Elif: elif = elif_stmt(bp,newline_count)
		case .Else: elif = else_stmt(bp,newline_count)
	}
	
	return create_if_node(condition,body,elif,loc)
}

else_stmt :: proc(bp: BindPower, newline_count: int ) -> ^Node
{
	loc := peek_cloc();advance()
	skip_for(.Newline,newline_count)
	return create_if_node(create_literal_node(.OP_TRUE,loc),block_stmt(bp),nil,loc)
}

block_stmt :: proc( bp: BindPower ) -> ^Node
{

	loc := peek_cloc()
	expect(.Open_Brace,"expected open '{{' before block body. got '%v'.",peek_ctype())

	skip_stmt_terminator()
	body := create_container_node()
	
	begin_scope()
	defer end_scope()

	for not_is_eof() && has_not_error() && !at(.Close_Brace) do container_node_append(body,parse_stmt(.DEFAULT))
	expect(.Close_Brace,"expected closing '}' after block body. got '%v'.",peek_ctype())

	// println("BODY -------------------> ",scope_get_local_count())

	return create_block_node(scope_get_local_count(),body,loc)
}


break_stmt :: proc(bp: BindPower) -> ^Node
{
	loc := peek_cloc(); advance()
	compile_error_cond(is_in_loop(),"cannot use 'break' outside of a loop.")

	cdata   := peek_control_data(.LOOP)
	l_count := 0
	
	if cdata != nil do 	l_count = scope_get_local_count_from_depth(cdata.scope_depth)
	return create_break_node(l_count,loc)
}

continue_stmt :: proc(bp: BindPower) -> ^Node
{
	loc := peek_cloc(); advance()
	compile_error_cond(is_in_loop(),"cannot use 'continue' outside of a loop.")

	cdata   := peek_control_data(.LOOP)
	l_count := 0
	
	if cdata != nil do 	l_count = scope_get_local_count_from_depth(cdata.scope_depth)
	return create_continue_node(l_count,loc)
}

return_stmt :: proc(bp: BindPower) -> ^Node
{
	loc := peek_cloc(); advance()
	compile_error_cond(is_in_function(),"you cannot use a return statement in the file scope.")

	cdata   := peek_control_data(.FUNCTION)
	l_count := 0
	expr    : ^Node

	// Nota(jstn): _init
	if is_init_function()
	{
		compile_error_cond(is_stmt_terminator(peek_ctype()) || is_block_terminator(peek_ctype()) ,"constructor cannot return a value.")
		this_tk := synthetic_token("this")

	    has,ldata :=  scope_check_redeclaration_var(this_tk)
	    l_count    = scope_get_local_count_from_depth(cdata.scope_depth)
	    
	    compile_error_assert(has,"Oops! this should not happen. It's a compiler bug in 'return_stmt' handler.")
	    return create_return_node(l_count,create_named_var_node("this",true,kind_can_assign(ldata.kind),ldata.index,loc),loc)
	}
	else if is_function_type(.TYPE_DEINITIALIZER)
	{
		compile_error_cond(is_stmt_terminator(peek_ctype()) || is_block_terminator(peek_ctype()) ,"'%v' cannot return a value.",CLASS_DEINIT)
		l_count = scope_get_local_count_from_depth(cdata.scope_depth)
		return create_return_node(l_count,create_literal_node(.OP_NIL,loc),loc)		
	}



	// 
	if cdata != nil do 	l_count = scope_get_local_count_from_depth(cdata.scope_depth)
	
	if is_stmt_terminator(peek_ctype()) || is_block_terminator(peek_ctype()) do expr = create_literal_node(.OP_NIL,loc)
	else do expr =  expression(bp) //!is_stmt_terminator(peek_ctype()) && !is_block_terminator(peek_ctype()) && has_not_error()

	return create_return_node(l_count,expr,loc)
}


// signal_stmt :: proc(bp: BindPower) -> ^Node
// {
// 	loc       := peek_cloc(); advance()

// 	expect(.Identifier,"expected a function name after 'fn'."); function_name_tk := peek_ptk()
// 	expect(.Open_Paren," expected '(' after function name.")
// 	compile_error_cond(!is_in_scope(),"function must be in global scope.")

// 	compile_error_cond(tk_len(function_name_tk) < MAX_VARIABLE_NAME,"function name cannot be longer than '%v' characters.",MAX_VARIABLE_NAME)
// }