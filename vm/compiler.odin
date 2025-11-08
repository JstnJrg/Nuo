package VM

@(private="file") current_compiler : ^Compiler
@(private="file") current_ctx      : ^CompilerContext



CompilerContext :: struct
{
	get_allocator     : proc() -> Allocator,
	get_rallocator    : proc() -> Allocator,
	get_ast_allocator : proc() -> Allocator,

	begin_temp        : proc(),
	end_temp          : proc(),
	ast_begin_temp    : proc(),
	ast_end_temp      : proc()
}

Compiler :: struct 
{
	//
	globals        : ^GlobalScope,
	scope		   : ^Scope,
	class          : ^Class,
	dependecies    : ^Dependecies,

	enclosing      : ^Compiler,
	controls       : ^ControlData,
	
	//
	temp_count     : int,

	// 
	compiler_detph   : int,
	class_depth      : int,
	function_depth   : int,
	function_type    : FunctionType,

	loop_depth       : int,
	scope_depth      : int,
	is_if            : int,
}

EntetyType :: enum u8 
{
	IDENTIFIER,
	FUNCTION,
	CLASS,
	IMPORT,
	ENUM,
	// DECORATOR,
}

ControlType :: enum u8 
{
	FUNCTION,
	LOOP
}

FunctionType :: distinct enum u8 
{
	TYPE_SCRIPT,
	TYPE_FUNCTION,
	TYPE_INITIALIZER,
	TYPE_DEINITIALIZER,
	TYPE_METHOD,
}


GlobalScope    :: struct { symbols : map[string]SymbolData }
StringMap      :: map[string]int

Scope          :: struct 
{
	locals     : map[string]SymbolData,
	enclosing  : ^Scope,
	
	index_level : int,
	local_count : int,
	func_depth  : int,
	depth       : int
}

Class         :: struct 
{
	properties : StringMap,
	enclosing  : ^Class,
	depth      : int
}

SymbolData     :: struct 
{
	loc   : Localization,
	index : int,
	kind  : EntetyType
}

ControlData  :: struct 
{
	scope_depth : int,
	enclosing   : ^ControlData,
	type        : ControlType  
}


DependecieData :: struct
{
	name   : string,
	loc    : Localization,
	in_use : bool 
}

Dependecies :: struct {  imports : map[u32]DependecieData  }




@private
init_compiler_ctx :: proc()
{
	ctx               := new(CompilerContext,get_compiler_allocator())

	ctx.get_allocator     = get_compiler_allocator
	ctx.get_rallocator    = get_runtime_allocator
	ctx.get_ast_allocator = get_compiler_ast_allocator

	ctx.begin_temp     = compiler_arena_temp_begin
	ctx.end_temp       = compiler_arena_temp_end

	ctx.ast_begin_temp = ast_begin_temp
	ctx.ast_end_temp   = ast_end_temp

	current_ctx        = ctx
} 

ctx_new          :: proc($T : typeid) -> ^T { return new(T,current_ctx.get_allocator()) }
ctx_make         :: proc($T : typeid) ->  T { return make(T,current_ctx.get_allocator()) }

ctx_anew         :: proc($T : typeid) -> ^T { return new(T,current_ctx.get_ast_allocator()) }
ctx_amake        :: proc($T : typeid) ->  T { return make(T,current_ctx.get_ast_allocator()) }

ctx_allocator    :: proc() -> Allocator { return current_ctx.get_allocator()  }
ctx_rallocator   :: proc() -> Allocator { return current_ctx.get_rallocator() }
ctx_aallocator   :: proc() -> Allocator { return current_ctx.get_ast_allocator() }







// ================ Compiler

compiler_begin_temp :: proc() { current_ctx.begin_temp(); current_compiler.temp_count += 1 }
compiler_end_temp   :: proc() 
{ 
	if current_compiler.temp_count <= 0 do return
	current_ctx.end_temp()
}

ctx_ast_begin_temp :: proc() { current_ctx.ast_begin_temp(); current_compiler.temp_count += 1 }
ctx_ast_end_temp   :: proc() 
{ 
	if current_compiler.temp_count <= 0 do return
	current_ctx.ast_end_temp()
}

begin_new_compiler :: proc()
{
	nuo_assert(current_ctx != nil,"something went wrong. Make sure that CompilerContext was created.")
	
	enclosing_compiler              := current_compiler
	current_compiler                 = ctx_new(Compiler)

	current_compiler.globals         = create_global_scope()
	current_compiler.dependecies     = create_dependencies()
	current_compiler.enclosing       = enclosing_compiler

	current_compiler.compiler_detph += 1
	current_compiler.function_depth  = 0
}

abegin_new_acompiler :: proc()
{
	nuo_assert(current_ctx != nil,"something went wrong. Make sure that CompilerContext was created.")
	
	enclosing_compiler             := current_compiler
	current_compiler                = ctx_anew(Compiler)

	current_compiler.globals        = acreate_global_scope()
	current_compiler.dependecies    = enclosing_compiler.dependecies
	current_compiler.enclosing      = enclosing_compiler

	current_compiler.compiler_detph += 1
	current_compiler.function_depth  = 0
}


end_new_compiler   :: proc "contextless" () { current_compiler = current_compiler.enclosing }


compiler_set_nil           :: proc() 
{
	current_compiler = nil
	current_ctx      = nil
}


compiler_get_depth       :: proc "contextless" () -> int { return current_compiler.compiler_detph }
compiler_get_scope_depth :: proc "contextless" () -> int { return current_compiler.scope_depth }
compiler_is_main         :: proc "contextless" () -> bool { return current_compiler.compiler_detph == 1 }


if_begin                 :: proc "contextless" () { current_compiler.is_if += 1 }
if_end                   :: proc "contextless" () { current_compiler.is_if -= 1 }
is_if                    :: proc "contextless" () -> bool { return current_compiler.is_if > 0  }











// ===================== Function

begin_function    :: proc "contextless" () { current_compiler.function_depth += 1 }
end_function      :: proc "contextless" () { current_compiler.function_depth -= 1}
get_function_depth:: proc "contextless" () -> int { return current_compiler.function_depth }
set_function_type :: proc "contextless" (ftype: FunctionType) { current_compiler.function_type = ftype }
get_function_type :: proc "contextless" () -> FunctionType { return current_compiler.function_type }


is_in_function      :: proc() -> bool  { return current_compiler.function_depth > 0 }
is_init_function    :: proc() -> bool  { return current_compiler.function_type  == .TYPE_INITIALIZER }
is_function_type    :: proc(type: FunctionType) -> bool  { return current_compiler.function_type  == type }
is_method_function  :: proc() -> bool  { return current_compiler.function_type  == .TYPE_METHOD }


// ===================== Class
begin_class        :: proc() 
{ 
	defer current_compiler.class_depth += 1 

	if current_compiler.class == nil
	{
		current_compiler.class            = new(Class,ctx_aallocator())
		current_compiler.class.properties = make(StringMap,ctx_aallocator())
		current_compiler.class.depth      = current_compiler.class_depth
		return
	}
	
	enclosing_class                  := current_compiler.class
	current_compiler.class            = new(Class,ctx_aallocator())
	current_compiler.class.properties = make(StringMap,ctx_aallocator())
	current_compiler.class.enclosing  = enclosing_class
	current_compiler.class.depth      = current_compiler.class_depth

}

end_class          :: proc() 
{ 
	current_compiler.class        = current_compiler.class.enclosing
	current_compiler.class_depth -= 1
}


get_class_depth    :: proc "contextless" () -> int { return current_compiler.function_depth }
is_in_class        :: proc() -> bool  { return current_compiler.class_depth > 0 }



class_declare_property  :: proc{class_declare_property1,class_declare_property2}


class_declare_property1 :: proc "contextless" (property: string) { current_compiler.class.properties[property]= -1 }

class_declare_property2 :: proc "contextless" (property: Token)  { current_compiler.class.properties[property.text]= -1 }


class_has_property      :: proc{class_has_property1,class_has_property2}

class_has_property1     :: proc "contextless" (property: string) -> bool
{
	_, has := current_compiler.class.properties[property]
	return has
}

class_has_property2     :: proc "contextless" (property: Token) -> bool
{
	_, has := current_compiler.class.properties[property.text]
	return has
}










// ===================== Control
begin_loop          :: proc "contextless" () { current_compiler.loop_depth += 1 }
end_loop            :: proc "contextless" () { current_compiler.loop_depth -= 1 } 
is_in_loop          :: proc "contextless" () -> bool { return current_compiler.loop_depth > 0 }

push_control_data   :: proc(depth: int, type : ControlType)  
{ 
	enclosing                              := current_compiler.controls
	
	current_compiler.controls             = new(ControlData,ctx_aallocator()) 
	current_compiler.controls.scope_depth = depth
	current_compiler.controls.type        = type
	current_compiler.controls.enclosing   = enclosing
}

pop_control_data :: proc "contextless" () {  current_compiler.controls = current_compiler.controls.enclosing }

peek_control_data :: proc "contextless" (type: ControlType) -> ^ControlData
{
	l := current_compiler.controls
	for l != nil && l.type != type do l = l.enclosing
	return l
}



// ===================== Scope
begin_scope    :: proc()
{
	defer current_compiler.scope_depth += 1

	if current_compiler.scope == nil
	{
		current_compiler.scope        = new(Scope,ctx_aallocator())
		current_compiler.scope.locals = make(map[string]SymbolData,ctx_aallocator())
		current_compiler.scope.func_depth = current_compiler.function_depth
		return
	}

	enclosing_scope                   := current_compiler.scope
	current_compiler.scope             = new(Scope,ctx_aallocator())
	current_compiler.scope.locals      = make(map[string]SymbolData,ctx_aallocator())
	current_compiler.scope.enclosing   = enclosing_scope
	current_compiler.scope.index_level = enclosing_scope.local_count+enclosing_scope.index_level
	current_compiler.scope.depth       = current_compiler.scope_depth
	current_compiler.scope.func_depth  = current_compiler.function_depth
}


end_scope  :: proc "contextless" () 
{ 
	current_compiler.scope	= current_compiler.scope.enclosing
	current_compiler.scope_depth -= 1 
}


is_in_scope                   :: proc "contextless" () -> bool { return current_compiler.scope_depth > 0 }

scope_check_redeclaration_var :: proc "contextless" (var_name : Token) -> (has: bool, ldata: ^SymbolData ) 
{
	scope := current_compiler.scope

	for scope != nil 
	{
		if l, ok := scope.locals[var_name.text]; ok 
		{ 
			ldata = &scope.locals[var_name.text]
			has   = ok
			break 
		}

		scope = scope.enclosing
	}

	return
}


scope_declare_entety :: proc "contextless" (var_name : Token,etype: EntetyType ,loc: Localization) -> int
{
	scope    := current_compiler.scope
	defer scope.local_count += 1

	sd       : SymbolData
	
	sd.loc   = loc
	sd.index = scope.index_level+scope.local_count
	sd.kind  = etype
	
	scope.locals[var_name.text] = sd
	return sd.index
}

scope_get_local_data :: proc "contextless" (var_name : Token) -> (ldata: ^SymbolData,has: bool) 
{
	scope := current_compiler.scope

	for scope != nil 
	{
		if l, ok := scope.locals[var_name.text]; ok 
		{ 
			ldata := &scope.locals[var_name.text]
			has = ok
			break 
		}
	}
	return
}

scope_get_local_slot :: proc "contextless" (var_name : Token) -> int
{
	if ld , ok  := scope_get_local_data(var_name); ok do return ld.index
	return -1
}

scope_get_local_count               :: proc "contextless" () -> int { return current_compiler.scope.local_count }

scope_get_local_count_from_depth    :: proc "contextless" (depth: int ) ->  (sum: int) 
{
	scope := current_compiler.scope
	for scope != nil 
	{
		if scope.depth < depth do break
		sum  += scope.local_count
		scope = scope.enclosing
	}
	return
}

scope_get_local_count_from_func_depth :: proc "contextless" (depth: int ) ->  (sum: int) 
{
	scope := current_compiler.scope
	for scope != nil 
	{
		if scope.func_depth < depth do break
		sum  += scope.local_count
		scope = scope.enclosing
	}
	return
}

scope_get_depth       				:: proc "contextless" () -> int { return current_compiler.scope.depth }



// ================ GlobalScope

create_global_scope :: proc() -> ^GlobalScope {
	gs         := ctx_new(GlobalScope)
	gs.symbols  = ctx_make(map[string]SymbolData)
	return gs
}

acreate_global_scope :: proc() -> ^GlobalScope {
	gs         := ctx_anew(GlobalScope)
	gs.symbols  = ctx_amake(map[string]SymbolData)
	return gs
}

// ================= GlobalVars

global_declare_entety        :: proc{global_declare_entety_tk,global_declare_entety_str}

global_declare_entety_tk      :: proc (var_name : Token,etype: EntetyType ,loc: Localization) 
{
	has, msg := names_check_reserved(var_name.text,etype)
	compile_error_cond(!has,msg,var_name.text)

	sd       : SymbolData
	
	sd.loc   = loc
	sd.index = -1
	sd.kind  = etype
	
	current_compiler.globals.symbols[var_name.text] = sd
}

global_declare_entety_str    :: proc (var_name : string,etype: EntetyType ,loc: Localization) 
{
	has, msg := names_check_reserved(var_name,etype)
	compile_error_cond(!has,msg,var_name)

	sd       : SymbolData
	
	sd.loc   = loc
	sd.index = -1
	sd.kind  = etype
	
	current_compiler.globals.symbols[var_name] = sd
}

global_declare_db      :: proc (iid: int) 
{
	callable_c :: proc(_: int, _: int, class_name : string)       
	{ 
		loc := synthetic_loc()
		global_declare_entety(class_name,.CLASS,loc) 
	}
	
	callable_i :: proc(iid: int, _iid: int, import_name : string) { loc := synthetic_loc(); if import_db_check_api(_iid,.BUILTIN) do global_declare_entety(import_name,.IMPORT,loc) }

	/* Atomic -> só queremos essas classes	*/
	class_db_get_classes_names(iid,callable_c)
	import_get_import_names(iid,callable_i)
}

global_check_redeclaration_var :: proc "contextless" (var_name : Token) -> (has: bool, gdata: ^SymbolData) 
{
	gscope  := current_compiler.globals
	g, ok   := gscope.symbols[var_name.text]

	gdata    = &gscope.symbols[var_name.text]
	has      = ok
	return
}


// =============================  dependencias
create_dependencies  :: proc() -> ^Dependecies
{
	dp         := ctx_new(Dependecies)
	dp.imports  = ctx_make(map[u32]DependecieData)
	return dp
}

register_dependencies        :: proc{register_dependencies_string,register_dependencies_hash}

register_dependencies_string :: proc (iname: string ,path: string, loc: Localization ) 
{ 
    d := DependecieData{string_clone(iname,ctx_allocator()),loc,true,}
	current_compiler.dependecies.imports[hash_string(path)] = d
}

register_dependencies_hash  :: proc (iname: string ,dhash: u32, loc: Localization ) 
{ 
    d := DependecieData{string_clone(iname,ctx_allocator()),loc,true}
	current_compiler.dependecies.imports[dhash] = d
}

dependecie_set_in_use          :: proc{dependecie_set_in_use_hash,dependecie_set_in_use_string}

dependecie_set_in_use_hash     :: proc "contextless" (dhash: u32, value: bool)   { dd := &current_compiler.dependecies.imports[dhash]; dd.in_use = value }

dependecie_set_in_use_string   :: proc "contextless" (path: string, value: bool) { dd := &current_compiler.dependecies.imports[hash_string(path)]; dd.in_use = value }

hash_dependecie                :: proc "contextless" (path: string) -> u32   { return hash_string(path) }

is_dependecie_in_use           :: proc{is_dependecie_in_use_hash,is_dependecie_in_use_string}

is_dependecie_in_use_hash      :: proc "contextless" (dhash: u32)   -> bool  { return current_compiler.dependecies.imports[dhash].in_use }

is_dependecie_in_use_string    :: proc "contextless" (path: string) -> bool  { return current_compiler.dependecies.imports[hash_string(path)].in_use }

get_dependencies               :: proc "contextless" () -> ^Dependecies      { return current_compiler.dependecies }


has_dependencie                :: proc{has_dependencie_hash,has_dependencie_string}

has_dependencie_hash           :: proc "contextless" (hpath: u32) -> (has: bool, loc : Localization) 
{
	cd     := current_compiler.dependecies

	if hpath in cd.imports
	{
		loc = cd.imports[hpath].loc
		has = true
	}

	return
}

has_dependencie_string         :: proc "contextless" (path: string) -> (has: bool, loc : Localization) 
{
	path_h := hash_string(path)
	cd     := current_compiler.dependecies

	if path_h in cd.imports
	{
		loc = cd.imports[path_h].loc
		has = true
	}

	return
}

was_importated      :: proc{was_importated_hash,was_importated_string}


was_importated_hash :: proc "contextless" (path_hash: u32) -> (was : bool, iname: string ) 
{ 
	d := current_compiler.dependecies
	if path_hash in d.imports
	{
		dd   := &d.imports[path_hash]
		was   = !dd.in_use
		iname = dd.name
	}

	return 
}

was_importated_string :: proc "contextless" (path: string) -> (was : bool) 
{ 
	path_hash := hash_string(path)
	d         := current_compiler.dependecies
	
	if path_hash in d.imports do was = !d.imports[path_hash].in_use
	return 
}


// 

sd_check_kind :: proc "contextless" (sd: ^SymbolData, type: EntetyType ) -> bool { return sd.kind == type }

kind2string :: proc "contextless" (kind : EntetyType ) -> string
{
	switch kind 
	{
		case .IDENTIFIER: 		return "variable"
		case .FUNCTION:         return "function"
		case .CLASS:	        return "class"
		case .IMPORT:           return "import"
		case .ENUM:             return "enum"
		case:                   return "bad kind"
	}
}


kind_can_assign :: proc(kind : EntetyType) -> bool
{
	switch kind 
	{
		case .ENUM:             fallthrough
		case .IDENTIFIER: 		return true

		case .FUNCTION:         fallthrough
		case .CLASS:	        fallthrough
		case .IMPORT:           fallthrough
		
		case:                   return false
	}	
}

print_globals_symbols :: proc()
{
	for s,&sd in current_compiler.globals.symbols do println("[GLOBAL] -> ",s,kind2string(sd.kind))
}