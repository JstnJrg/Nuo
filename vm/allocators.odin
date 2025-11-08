#+private
package VM 

import util    "nuo:util"


@(private="file") compiler_nuoarena     : NuoArena
@(private="file") compiler_ast_nuoarena : NuoArena
@(private="file") runtime_nuoarena      : NuoArena


init_compiler_arena :: proc() 
{ 
	util.init_arena(get_compiler_arena())
	util.init_arena(get_compiler_ast_arena())
}

init_runtime_arena  :: proc() 
{ 
	util.init_arena(get_runtime_arena())  
}




arena_temp_begin           :: proc(arena: ^Arena) -> util.Arena_Temp { return util.arena_temp_begin(arena) }
arena_temp_end             :: proc(arena_temp: util.Arena_Temp)      { util.arena_temp_end(arena_temp) }

arena_free_all             :: proc(arena: ^Arena)                    { util.arena_free_all(arena) }

get_compiler_arena         :: proc() -> ^Arena { return &compiler_nuoarena.arena }
get_compiler_ast_arena     :: proc() -> ^Arena { return &compiler_ast_nuoarena.arena }
get_runtime_arena          :: proc() -> ^Arena { return &runtime_nuoarena.arena  }


get_compiler_arena_temp        :: proc() -> util.Arena_Temp { return compiler_nuoarena.temp }
get_compiler_ast_arena_temp    :: proc() -> util.Arena_Temp { return compiler_ast_nuoarena.temp }
get_runtime_arena_temp         :: proc() -> util.Arena_Temp { return runtime_nuoarena.temp  }

get_runtime_allocator          :: proc() -> util.Allocator { return util.get_arena_allocator(get_runtime_arena())  }
get_compiler_allocator         :: proc() -> util.Allocator { return util.get_arena_allocator(get_compiler_arena()) }
get_compiler_ast_allocator     :: proc() -> util.Allocator { return util.get_arena_allocator(get_compiler_ast_arena()) }


compiler_arena_temp_begin  :: proc() { compiler_nuoarena.temp = arena_temp_begin(get_compiler_arena()) }
compiler_arena_temp_end    :: proc() { arena_temp_end(get_compiler_arena_temp()) }

compiler_ast_arena_temp_begin  :: proc() { compiler_ast_nuoarena.temp = arena_temp_begin(get_compiler_ast_arena()) }
compiler_ast_arena_temp_end    :: proc() { arena_temp_end(get_compiler_ast_arena_temp()) }

ast_begin_temp                 :: compiler_ast_arena_temp_begin
ast_end_temp                   :: compiler_ast_arena_temp_end

compiler_arena_free_all    :: proc() { util.arena_free_all(get_compiler_arena()); util.arena_free_all(get_compiler_ast_arena()) }
compiler_arena_destroy     :: proc() 
{ 
	util.deinit_arena(get_compiler_arena())
	util.deinit_arena(get_compiler_ast_arena()) 
}

// runtime_arena_temp_begin   :: proc() { runtime_nuoarena.temp = arena_temp_begin(get_runtime_arena()) }
// runtime_arena_temp_end     :: proc() { arena_temp_end(get_runtime_arena_temp()) }

runtime_arena_temp_begin   :: proc() -> util.Arena_Temp { return arena_temp_begin(get_runtime_arena()) }
runtime_arena_temp_end     :: proc(t: util.Arena_Temp)  { arena_temp_end(t) }


runtime_arena_free_all     :: proc() { util.arena_free_all(get_runtime_arena()) }
runtime_arena_destroy      :: proc() { util.deinit_arena(get_runtime_arena()) }


