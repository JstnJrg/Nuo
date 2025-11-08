package VM


codegen_emit_load :: proc(value: Value, loc : Localization) -> int
{
	fid   := codegen_get_fid()
	index := function_db_push_constant(fid,value)

	codegen_report_error_cond(index < MAX_CHUNK_CONSTANT,"too many constants in one chunk. Maximum allowed '%v', got '%v'.",MAX_CHUNK_CONSTANT,index)
	
	function_db_push_opcode(fid,.OP_LOAD,loc)
	function_db_push_index(fid,index,loc)

	return index
}

codegen_emit_loadi :: proc(index: int, loc : Localization)
{
	fid   := codegen_get_fid()
	function_db_push_opcode(fid,.OP_LOAD,loc)
	function_db_push_index(fid,index,loc)
}

codegen_push_constant  :: proc(value: Value) -> int 
{
	fid   := codegen_get_fid()
	index := function_db_push_constant(fid,value) 
	return index
} 
codegen_emit_opcode    :: proc(opcode: Opcode, loc : Localization)        { function_db_push_opcode(codegen_get_fid(),opcode,loc) }
codegen_emit_index     :: proc(index: int , loc : Localization)           { function_db_push_index(codegen_get_fid(),index,loc) }
codegen_emit_type      :: proc(type: VariantType , loc : Localization)    { function_db_push_index(codegen_get_fid(),int(type),loc) }


codegen_emit_jump_and_get_address_index :: proc(op: Opcode,loc: Localization) -> int
{
	codegen_emit_opcode(op,loc)
	codegen_emit_opcode(op,loc)
	return codegen_get_current_address_index()
}

codegen_emit_return :: proc(loc : Localization)
{
	fid := codegen_get_fid()
	function_db_push_opcode(fid,.OP_RETURN,loc)
}


codegen_get_current_address_index :: proc() -> int { return function_db_get_current_address_index(codegen_get_fid()) }
codegen_set_address               :: proc(index, address: int) { function_db_set_address(codegen_get_fid(),index,address+1) }




// codegen_finish_emit_return :: proc(loc : Localization)
// {
// 	fid := codegen_get_pfid()
// 	function_db_push_opcode(fid,.OP_RETURN,loc)
// }