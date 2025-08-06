package FileAcess

import os2 "core:os/os2"
import io  "core:io"
import mem "core:mem"
import strings  "core:strings"

os2 :: os2
io  :: io

@(private = "file") iid := -1

RDONLY 	   :: 1 << 0
WRONLY 	   :: 1 << 1
RDWR   	   :: 1 << 2
APPEND 	   :: 1 << 3
CREATE 	   :: 1 << 4
EXCL   	   :: 1 << 5
SYNC   	   :: 1 << 6
TRUNC  	   :: 1 << 7
SPARSE 	   :: 1 << 8

File       :: os2.File
File_Flags :: os2.File_Flags

State      :: struct ($T: typeid) { file : ^T,  is_open : bool }
FileState  :: State(File)


to_string         :: proc{to_string_object,strings.to_string}
to_string_object  :: proc(obj: ^NuoString) -> string { return to_string(obj.data) }

set_iid           :: proc "contextless" (_iid: int) { iid = _iid}
get_iid           :: proc "contextless" () -> int { return iid }

get_data          :: proc "contextless" (p: ^$P ,$T : typeid) -> ^T { return (^T)(p) }

is_valid_mode     :: proc "contextless" (mode: int) -> bool { return mode < 0 ? false:true}
get_file_mode     :: proc "contextless" (m: int) -> File_Flags 
{
	mode : File_Flags

	if m & RDONLY != 0 do mode += os2.O_RDONLY
	if m & WRONLY != 0 do mode += os2.O_WRONLY
	if m & RDWR   != 0 do mode += os2.O_RDWR
	if m & APPEND != 0 do mode += os2.O_APPEND
	if m & CREATE != 0 do mode += os2.O_CREATE
	if m & EXCL   != 0 do mode += os2.O_EXCL
	if m & SYNC   != 0 do mode += os2.O_SYNC
	if m & TRUNC  != 0 do mode += os2.O_TRUNC
	if m & SPARSE != 0 do mode += os2.O_SPARSE

	return mode
}



