package Signal

init :: proc(cid: int)
{
	// methods - 26
	class_db_methods_table_reserve(cid,5)
	b_methods(cid)
}


b_methods :: proc(cid: int)
{
	// // 
	B_METHOD(cid,"connect",connect,.INTRINSICS)
	B_METHOD(cid,"emit",emit,.INTRINSICS)
	B_METHOD(cid,"disconnect",disconnect,.INTRINSICS)	
	B_METHOD(cid,"has_connections",has_connections,.INTRINSICS)

	B_METHOD(cid,"get_connections",get_connections,.INTRINSICS)
}