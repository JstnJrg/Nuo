package Callable


init :: proc(cid: int)
{
	// methods - 3
	class_db_methods_table_reserve(cid,3)
	b_methods(cid)
}


b_methods :: proc(cid: int)
{
	// B_METHOD(cid,"call",call,.INTRINSICS)
	B_METHOD(cid,"attach",attach,.STATIC)


	// 
	B_METHOD(cid,"bind",bind,.INTRINSICS)
	B_METHOD(cid,"get_bound_arguments",get_bound_arguments,.INTRINSICS)
}


