package Array

init :: proc(cid: int)
{	
	// methods - 26
	class_db_methods_table_reserve(cid,26)

	register_operators()
	register_properties(cid)
	b_methods(cid)
}


b_methods :: proc(cid: int)
{
	// 
	B_METHOD(cid,".iterate",iterate,.INTRINSICS)
	B_METHOD(cid,".end",end,.INTRINSICS)
	B_METHOD(cid,".next",next,.INTRINSICS)
	B_METHOD(cid,".cleanup",cleanup,.INTRINSICS)

	// 
	B_METHOD(cid,"size",size,.INTRINSICS)
	B_METHOD(cid,"shuffle",shuffle,.INTRINSICS)	
	B_METHOD(cid,"clear",_clear,.INTRINSICS)
	B_METHOD(cid,"resize",resize_,.INTRINSICS)

	B_METHOD(cid,"choice",choice,.INTRINSICS)
	B_METHOD(cid,"append",append_,.INTRINSICS)
	B_METHOD(cid,"append_array",append_array,.INTRINSICS)
	B_METHOD(cid,"pop_back",pop_back,.INTRINSICS)

	B_METHOD(cid,"pop_front",pop_front,.INTRINSICS)
	B_METHOD(cid,"qsort",qsort,.INTRINSICS)
	B_METHOD(cid,"ssort",ssort,.INTRINSICS)
	B_METHOD(cid,"count",count,.INTRINSICS)
	
	B_METHOD(cid,"reverse",reverse,.INTRINSICS)
	B_METHOD(cid,"has",has,.INTRINSICS)
	B_METHOD(cid,"fill",fill,.INTRINSICS)
	B_METHOD(cid,"find",find,.INTRINSICS)

	B_METHOD(cid,"sort_costum",sort_costum,.INTRINSICS)
	B_METHOD(cid,"map",map_,.INTRINSICS)
	B_METHOD(cid,"filter",filter,.INTRINSICS)
	B_METHOD(cid,"reduce",reduce,.INTRINSICS)

	B_METHOD(cid,"find_costum",find_costum,.INTRINSICS)
	B_METHOD(cid,"for_each",for_each,.INTRINSICS)

}