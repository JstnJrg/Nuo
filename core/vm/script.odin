package VM


NUO_EXTENSION :: `.nuo` 


is_valid_extension :: proc (str: string) -> bool { return long_ext(str) == NUO_EXTENSION }

get_script_data    :: proc(str: string) -> (string,bool) 
{ 
	data,err := read_entire_file_from_filename(str,get_compiler_allocator())
	nuo_print_cond(err != false,"'%v' loading failed.",str)
	return transmute(string)data,err
} 

load_script        :: proc(path: string) -> (string,bool)
{
	if is_valid_extension(path) do return get_script_data(path)
	nuo_print(" '%v' is not a valid path to a Nuo file.",path)
	return "",false
}