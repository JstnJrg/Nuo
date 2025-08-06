package Variant

import "core:strings"
import "core:mem"
import "core:os/os2"

Frame :: struct
{
	buffer    : strings.Builder,
	ip        : ^int,
	fid       : int
} 

@(private="file") current_frame : ^Frame


get_current_frame :: proc "contextless" () -> ^Frame { return current_frame }
get_frame_buffer  :: proc "contextless" () -> ^strings.Builder { return &get_current_frame().buffer }
set_current_frame :: proc "contextless" (f: ^Frame)  { current_frame = f }

init_frame        :: proc(allocator : Allocator)
{
	f := new(Frame,allocator)
	strings.builder_init_len_cap(&f.buffer,0,8,allocator)
	set_current_frame(f)
}

end_frame         ::  proc() { set_current_frame(nil) }


read_instruction  :: #force_inline proc "contextless" () -> Opcode 
{
	frame   := get_current_frame()	
	byte_   := frame.ip
	frame.ip = mem.ptr_offset(frame.ip,1)
	return Opcode(byte_^)
}
read_byte        :: #force_inline proc "contextless" () -> int
{
	frame   := get_current_frame()
	byte_   := frame.ip
	frame.ip = mem.ptr_offset(frame.ip,1)
	return byte_^
}

read_loc_line    :: #force_inline proc "contextless" () -> int
{
	frame   := get_current_frame()
	chunk   := function_db_get_chunk(frame.fid)

	index   := mem.ptr_sub(frame.ip,&chunk.code[0])
	loc     := &chunk.positions[index-1]

	// loc.file, loc.line, loc.column
	
	return loc.line
}

write_line    :: #force_inline proc ()
{
	frame   := get_current_frame()
	chunk   := function_db_get_chunk(frame.fid)

	index   := mem.ptr_sub(frame.ip,&chunk.code[0])
	bf      := get_frame_buffer()

	strings.write_int(bf,index-1)
	strings.write_string(bf,": ")
}



read_index       :: read_byte



prepare_frame    :: proc (fid: int) 
{ 
	frame    := get_current_frame()
	chunk    := function_db_get_chunk(fid)

	frame.ip  = &chunk.code[0]
	frame.fid = fid
}


disassembly_function :: proc(fid : int)
{
	if !function_db_is_valid_id(fid) do return
	disassembly(fid)
}


disassembly :: proc(fid: int, fname := "nuo_disassembly.txt")
{
	ctx       := get_context()
	ctx.init_runtime_temp()

	defer ctx.end_runtime_temp()

	init_frame(ctx.get_runtime_allocator())
	prepare_frame(fid)

	defer end_frame()


	buffer := get_frame_buffer()
	r,_    := strings.center_justify("DISASSEMBLY",50," * ",ctx.get_runtime_allocator())
	



	// strings.builder_init_len_cap(&buffer,0,8,allocator)
	strings.write_string(buffer,r)
	strings.write_string(buffer,"\n\n")

	

	// 
	write_string2 :: proc(b: ^strings.Builder, s,r : string) 
	{ 
		strings.write_string(b,s)
		strings.write_string(b,r)
	}

	write_int2 :: proc(b: ^strings.Builder, r: int ,s: string) 
	{ 
		strings.write_int(b,r)
		strings.write_string(b,s)
	}



	out: for
	{

		bf          := buffer
		instruction := read_instruction()
		

		#partial switch instruction
		{
		  case .OP_LOAD:

		  	write_line()
		  	write_string2(bf,opcode_to_string(instruction)," ,")
		  	write_int2(bf,read_index(),"\n")

		  case .OP_LITERAL:

		  	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_string2(bf,opcode_to_string(read_instruction()),"\n") //op

		  case .OP_POP: 

		  	write_line()
		  	write_string2(bf,opcode_to_string(instruction),"\n")

		  case .OP_SUB_SP: 

		  	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_int2(bf,read_index(),"\n") // offset

		  case .OP_UNARY:
		  	
		  	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_string2(bf,opcode_to_string(read_instruction()),"\n") //op

		  case .OP_BINARY:

		  	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_string2(bf,opcode_to_string(read_instruction()),"\n") //op

		  case .OP_CONSTRUCT:

		  	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_string2(bf,opcode_to_string(read_instruction())," ,") //op

			write_int2(bf,read_index()," ,") // argc
			write_int2(bf,read_index(),"\n") // types
		        

		  case .OP_DEFINE_GLOBAL:

		  	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_int2(bf,read_index(),"\n") // sid

		  case .OP_GET_GLOBAL:

		  	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_int2(bf,read_index(),"\n") // sid

		  case .OP_SET_GLOBAL:

		  	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_int2(bf,read_index(),"\n") // sid

		  case .OP_GET_LOCAL: 

		  	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_int2(bf,read_index(),"\n") // local slot

		  case .OP_SET_LOCAL:

		  	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_int2(bf,read_index(),"\n") // local slot

		  case .OP_JUMP_IF_FALSE: 

		  	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_int2(bf,read_index(),"\n") // jmp address
		
		  case .OP_JUMP_IF_TRUE: 

		  	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_int2(bf,read_index(),"\n") // jmp address

		  case .OP_JUMP: 

		  	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_int2(bf,read_index(),"\n") // jmp address

		 case .OP_MATCH:

		 	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_int2(bf,read_index(),"\n") // case count

		 case .OP_CALL:

		 	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_int2(bf,read_index(),"\n") // argc

		 case .OP_CALL1:

		 	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_int2(bf,read_index()," ,") // argc
			write_int2(bf,read_index(),"\n") // sid

		 case .OP_INHERIT:

		 	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_string2(bf,opcode_to_string(read_instruction()),"\n") //op


    	 case .OP_NEW:
		
			write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_int2(bf,read_index(),"\n") // argc
			// write_int2(bf,read_index(),"\n") // sid

		 case .OP_INVOKE:

		 	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_int2(bf,read_index()," ,") // argc
			write_int2(bf,read_index(),"\n") // sidi

		 case .OP_GET_PROPERTY:

		 	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_string2(bf,opcode_to_string(read_instruction())," ,") //op
			write_int2(bf,read_index(),"\n") // sidi (valor a caregar)


		 case .OP_SET_PROPERTY:

		 	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_string2(bf,opcode_to_string(read_instruction())," ,") //op
			write_int2(bf,read_index(),"\n") // sidi (valor a caregar)
		
		 case .OP_SET_INDEXING:

		 	write_line()
			write_string2(bf,opcode_to_string(instruction)," ,")
			write_string2(bf,opcode_to_string(read_instruction()),"\n") //op

	     case .OP_STORE_RETURN: 

	     	write_line()
			write_string2(bf,opcode_to_string(instruction),"\n")

		 case .OP_LOAD_RETURN : 

		 	write_line()
			write_string2(bf,opcode_to_string(instruction),"\n")

         case .OP_RETURN: 

         	write_line()
			write_string2(bf,opcode_to_string(instruction),"\n")

		 case : break out
		
		} 

	}


	f, _  := os2.open(fname, os2.O_CREATE | os2.O_RDWR | os2.O_TRUNC )
	bytes := strings.to_string(buffer^)

	os2.write(f,transmute([]byte)bytes)
}