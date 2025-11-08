package Variant

import util   "nuo:util"
import OpCode "nuo:opcode"
import tknzr  "nuo:tokenizer"


NUO_IMPORT_NAME  :: util.NUO_IMPORT_NAME
NUO_DEBUG		 :: util.NUO_DEBUG
NUO_DEBUG_GC     :: util.NUO_DEBUG_GC

MAX_FRAMES       :: util.MAX_FRAMES
STACK_SIZE       :: util.STACK_SIZE
MAX_ARGUMENTS    :: util.MAX_ARGUMENTS

MAX_CHUNK_CONSTANT :: util.MAX_CHUNK_CONSTANT
// 


Int      ::    util.Int
Float    ::    util.Float
Bool     ::    util.Bool
Vec2     ::    [2]Float
Complex  ::    [2]Float
Rect2    ::    [2]Vec2
Color    ::    [4]u8
mat2x3   :: matrix[2,3]Float







Opcode :: OpCode.OpCode

is_opcode_unary  :: OpCode.is_opcode_unary
opcode_to_string :: OpCode.opcode_to_string

Localization  :: tknzr.Localization


KiloByte      :: util.KiloByte
MegaByte      :: util.MegaByte

Arena_Temp    :: util.Arena_Temp
Allocator     :: util.Allocator

get_working_directory :: util.get_working_directory

Buddy_Allocator      :: util.Buddy_Allocator
get_buddy_allocator  :: util.buddy_allocator
buddy_allocator_init :: util.buddy_allocator_init
buddy_free           :: util.buddy_allocator_free

Buddy_Block          :: util.Buddy_Block

string_clone  :: util.string_clone
hash_string   :: util.hash_string


Builder               :: util.Builder
builder_make_none     :: util.builder_make_none

builder_write_string  :: util.builder_write_string
builder_reset         :: util.builder_reset
builder_destroy       :: util.builder_destroy
to_string             :: util.to_string

// hash
one_64                :: util.one_64
fmix32                :: util.fmix32

murmur3_one_float     :: util.murmur3_one_float
murmur3_one_32        :: util.murmur3_one_32





eprintf       :: util.eprintf
aprintf       :: util.aprintf
aprint        :: util.aprint
println       :: util.println
printfln	  :: util.printfln
print         :: util.print
printf        :: util.printf

mcopy         :: util.mcopy


// 
