package Rect2

init :: proc(cid: int)
{
	register_operators()

	// methods - 14
	class_db_methods_table_reserve(cid,14)
	b_methods(cid)
}

b_methods :: proc(cid: int)
{
	B_METHOD(cid,"abs",abs,.INTRINSICS)
	B_METHOD(cid,"distance_to",distance_to,.INTRINSICS)
	B_METHOD(cid,"encloses",encloses,.INTRINSICS)
	B_METHOD(cid,"expand",expand,.INTRINSICS)

	B_METHOD(cid,"get_center",get_center,.INTRINSICS)
	B_METHOD(cid,"get_area",get_area,.INTRINSICS)
	B_METHOD(cid,"grow",grow,.INTRINSICS)
	B_METHOD(cid,"get_support",get_support,.INTRINSICS)

	B_METHOD(cid,"grow_individual",grow_individual,.INTRINSICS)
	B_METHOD(cid,"has_point",has_point,.INTRINSICS)
	B_METHOD(cid,"has_no_area",has_no_area,.INTRINSICS)
	B_METHOD(cid,"intersects",intersects,.INTRINSICS)

	B_METHOD(cid,"merge",merge,.INTRINSICS)
	B_METHOD(cid,"clip",clip,.INTRINSICS)
}
