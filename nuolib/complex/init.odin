package Complex

init :: proc(cid: int)
{
	register_operators()

	// methods - 26
	class_db_methods_table_reserve(cid,5)
	b_methods(cid)
}

b_methods :: proc(cid: int)
{
	// STATIC
	B_METHOD(cid,"from_polar",from_polar,.STATIC)

	//
	B_METHOD(cid,"conjugate",conj,.INTRINSICS)
	B_METHOD(cid,"abs",module,.INTRINSICS)
	B_METHOD(cid,"arg",arg,.INTRINSICS)
	B_METHOD(cid,"pow",pow,.INTRINSICS)
}
