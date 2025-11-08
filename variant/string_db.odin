package Variant

String  :: struct 
{ 
	data : string,
	hash: u32 
}

StringTable        :: struct  
{ 
	string_db       : [dynamic]String,     
	string_map      : map[string]int,
	// string_internal : map[u32]int
}


string_db_register_string :: proc(str : string) -> int
{
	string_allocator := get_context_allocator()

	string_map       := db_get_string_db_map()
	// string_hash_map  := db_get_string_db_hash_map()

	if str in string_map do return string_map[str]

	n_str, _  := string_clone(str,string_allocator)
	hash      := hash_string(n_str)
	
	str_data  := String{n_str,hash}
	string_id := db_get_string_id()

	db_append_string(str_data)

	string_map[n_str]     = string_id
	// string_hash_map[hash] = string_id  

	return string_id
}

string_db_get_string :: proc "contextless" (id: int) -> string { return db_get_string_db()[id].data }
string_db_get_hash   :: proc "contextless" (id: int) -> u32    { return db_get_string_db()[id].hash }

// string_db_get_string_by_hash :: proc "contextless" (hash: u32) -> string
// {
// 	string_hash_map  := db_get_string_db_hash_map()
// 	string_id, has   := string_hash_map[hash] 
// 	return has ? db_get_string_db()[string_id].data: ""
// }

string_db_get_id :: proc "contextless" (str : string ) -> int
{
	string_map     := db_get_string_db_map()
	string_id, has := string_map[str]
	return has ? string_id: -1
}
