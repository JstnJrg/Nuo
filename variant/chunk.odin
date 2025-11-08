package Variant

INSTRUCTION_INITIAL_CAPACITY :: 1 << 8
LOC_INITIAL_CAPACITY         :: 1 << 8

Chunk :: distinct struct 
{
	code 		: 		[dynamic]int,
	positions   : 		[dynamic]Localization,
	constants	: 	    [dynamic]Value,
}

create_chunk        :: proc(allocator := context.allocator ) -> ^Chunk 
{ 
	chunk           := new(Chunk,allocator)
	chunk.code       = make([dynamic]int,0,INSTRUCTION_INITIAL_CAPACITY,allocator)
	chunk.positions  = make([dynamic]Localization,0,LOC_INITIAL_CAPACITY,allocator)
	chunk.constants  = make([dynamic]Value,0,MAX_CHUNK_CONSTANT,allocator)
	return chunk
}

destroy_chunk :: proc( chunk: ^Chunk)
{
	delete(chunk.constants)
	delete(chunk.positions)
	delete(chunk.code)
	free(chunk)
}

push_opcode :: proc(chunk : ^Chunk, opcode : int, position : Localization)
{
	append(&chunk.code,opcode)
	append(&chunk.positions,position)
}

push_constant :: proc(chunk: ^Chunk, constant : Value) -> int 
{
	append(&chunk.constants,constant)
	return len(chunk.constants)-1
}




