package Map

init :: proc(cid: int)
{
	register_operators()

	// methods - 11
	class_db_methods_table_reserve(cid,11)
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
	B_METHOD(cid,"is_empty",is_empty,.INTRINSICS)
	B_METHOD(cid,"values",values,.INTRINSICS)
	B_METHOD(cid,"keys",keys,.INTRINSICS)

	B_METHOD(cid,"clear",_clear,.INTRINSICS)	
	B_METHOD(cid,"erase",erase,.INTRINSICS)	
	B_METHOD(cid,"has",has,.INTRINSICS)

}