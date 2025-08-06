package Variant


FunctionInfo :: struct
{
	id            : int,
	iid           : int,
	arity         : int,
	name_id       : int,
	default_arity : int
}

Function    :: struct
{
	chunk  : ^Chunk,
	ffinfo : FunctionInfo
}


db_create_function :: proc(fn_name : string, arity, default_arity: int, import_id := 0) -> DBID
{
	db_allocator          := get_context_allocator()
	function              := new(Function,db_allocator)
	fid                   := db_get_function_id()
	function.chunk         = create_chunk(db_allocator)               

	ffinfo                := &function.ffinfo
	ffinfo.id              = fid
	ffinfo.iid             = import_id
	ffinfo.arity           = arity
	ffinfo.default_arity   = default_arity
	ffinfo.name_id         = string_db_register_string(fn_name)

	db_append_function(function)
	return fid
}

function_db_is_valid_id   :: proc "contextless" (fid: int) -> bool { return fid >= 0 && fid < db_get_function_id() }


function_db_get_function   :: proc "contextless" (fid: int) -> ^Function     { return db_get_function_db()[fid] }
function_db_get_finfo      :: proc "contextless" (fid: int) -> ^FunctionInfo { return &db_get_function_db()[fid].ffinfo }
function_db_get_chunk      :: proc "contextless" (fid: int) -> ^Chunk        { return function_db_get_function(fid).chunk }

function_db_get_fid_string :: proc (fname: string) -> int 
{ 
	for i in 0..< db_get_function_id() do if function_db_get_name(i) == fname do return i
	return -1
}

function_db_get_name      :: proc(fid: int) -> string
{
	ffinfo := function_db_get_finfo(fid)
	return string_db_get_string(ffinfo.name_id)
}

function_db_push_opcode    :: proc(fid: int, opcode : Opcode, position : Localization) { push_opcode(function_db_get_chunk(fid),int(opcode),position) }

function_db_push_index     :: proc(fid: int, index: int , position : Localization)     { push_opcode(function_db_get_chunk(fid),index,position) }

function_db_push_constant  :: proc(fid: int, constant : Value) -> int                  { return push_constant(function_db_get_chunk(fid),constant) }

function_db_get_current_address_index :: proc(fid: int) -> int                               { return len(function_db_get_chunk(fid).code)-1 }

function_db_set_address               :: proc(fid,indx,address: int)              { function_db_get_chunk(fid).code[indx] = address }


// function_db_push_    :: proc(fid: int, opcode : Opcode, position : Localization) { push_opcode(function_db_get_chunk(fid),int(opcode),position) }



// emit_jump_and_get_address:: proc(op: Opcode,loc: Localization) -> Int {
// 	emit_instruction(op,loc)
// 	emit_instruction(op,loc)
// 	return get_current_address()
// }

// fill_label_jump_placehold :: proc(#any_int indx: Int, #any_int offset: Uint) {
// 	check_jump_limit(indx)
// 	if has_error() do return
// 	get_current_chunk().code[indx] = offset+1
// }
