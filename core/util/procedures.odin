package General


init_arena :: proc (arena: ^Arena,type : ArenaType, size : uint = 2*MegaByte ) -> bool
{
	#partial switch type
	{
		case .Growing : return arena_init_growing(arena,size)  == .None 
		case .Static  : return arena_init_static(arena,size)   == .None
		case          : return false
		// case .Buffer  : return vmem.arena_init_buffer(arena,buffer) == .None
	}

	return false
}

get_arena_allocator :: proc(arena: ^Arena) -> Allocator { return arena_allocator(arena) }
deinit_arena        :: proc(arena: ^Arena) { arena_destroy(arena) }

hash_string :: #force_inline proc "contextless" (data: string) 	-> u32 { return fnv32a(transmute([]byte)data) }
// hash_bytes  :: #force_inline proc "contextless" (data: []u8) 	-> u32 { return fnv32a(data) }


to_string :: proc "contextless" (b: Builder) -> (res: string) { return string(b.buf[:]) }

