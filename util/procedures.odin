package General


init_arena          :: proc (arena: ^Arena, size : uint = 1*MegaByte, backing_allocator := context.allocator ) -> bool { return arena_init(arena,size,backing_allocator)  == .None }

get_arena_allocator :: proc(arena: ^Arena) -> Allocator { return arena_allocator(arena) }
deinit_arena        :: proc(arena: ^Arena) { arena_destroy(arena) }

hash_string         :: #force_inline proc "contextless" (data: string) 	-> u32 { return fnv32a(transmute([]byte)data) }
to_string           :: proc "contextless" (b: Builder) -> (res: string) { return string(b.buf[:]) }