package General

import os2      "core:os/os2"
import filepath "core:path/filepath"
import os       "core:os"
import strings  "core:strings"
import strconv  "core:strconv"
import mem      "core:mem"
import vmem     "core:mem/virtual"
import fmt      "core:fmt"
import hash     "core:hash"


// 
Int       :: int
Float     :: f32
Bool      :: bool

NuoArena :: struct
{
	arena     : Arena,
	temp      : Arena_Temp,
	// assert    : proc(condition: bool, fmt : string, args: ..any)
}


// 
ArenaType  :: vmem.Arena_Kind
Arena      :: vmem.Arena
Arena_Temp :: vmem.Arena_Temp

// 
Byte     :: mem.Byte
KiloByte :: mem.Kilobyte
MegaByte :: mem.Megabyte
GigaByte :: mem.Gigabyte
TeraByte :: mem.Terabyte
PetaByte :: mem.Petabyte

// 
Allocator :: mem.Allocator

// 
get_working_directory :: os2.get_working_directory
get_absolute_path     :: os2.get_absolute_path
get_relative_path     :: os2.get_relative_path
get_clean_path        :: os2.clean_path

read_entire_file_from_filename :: os.read_entire_file_from_filename


// 
long_ext              :: filepath.long_ext


// 
atoi                  :: strconv.atoi
atof                  :: strconv.atof

// 
eprintf               :: fmt.eprintf
aprintf               :: fmt.aprintf
eprintfln			  :: fmt.eprintfln
printfln              :: fmt.printfln
printf                :: fmt.printf
println               :: fmt.println
print                 :: fmt.print

// mem 
arena_init_growing    :: vmem.arena_init_growing
arena_init_static     :: vmem.arena_init_static
arena_allocator       :: vmem.arena_allocator
arena_destroy         :: vmem.arena_destroy

arena_temp_begin      :: vmem.arena_temp_begin
arena_temp_end        :: vmem.arena_temp_end

arena_free_all        :: vmem.arena_free_all

Buddy_Allocator       :: mem.Buddy_Allocator
buddy_allocator       :: mem.buddy_allocator
buddy_allocator_init  :: mem.buddy_allocator_init
buddy_allocator_free  :: mem.buddy_allocator_free

Buddy_Block           :: mem.Buddy_Block


ptr_offset            :: mem.ptr_offset
ptr_sub               :: mem.ptr_sub
mcopy                 :: mem.copy

// string
string_clone          :: strings.clone
Builder               :: strings.Builder

builder_write_string  :: strings.write_string
builder_reset         :: strings.builder_reset
builder_destroy		  :: strings.builder_destroy


unsafe_to_cstring     :: strings.unsafe_to_cstring
to_cstring            :: strings.to_cstring
