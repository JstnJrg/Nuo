package String


init :: proc(cid: int)
{
	register_operators()

	// methods - 34
	class_db_methods_table_reserve(cid,34)
	b_methods(cid)
}


b_methods :: proc(cid: int)
{
	// static
	B_METHOD(cid,"stringfy",stringfy,.STATIC)

	
	B_METHOD(cid,".iterate",iterate,.INTRINSICS)
	B_METHOD(cid,".end",end,.INTRINSICS)
	B_METHOD(cid,".next",next,.INTRINSICS)
	B_METHOD(cid,".cleanup",cleanup,.INTRINSICS)

	// 
	B_METHOD(cid,"length",length,.INTRINSICS)
	B_METHOD(cid,"repeat",repeat,.INTRINSICS)
	B_METHOD(cid,"count",count,.INTRINSICS)
	B_METHOD(cid,"join",join,.INTRINSICS)

	B_METHOD(cid,"equaln",equaln,.INTRINSICS)
	B_METHOD(cid,"prefix_length_commom",prefix_length_commom,.INTRINSICS)
	B_METHOD(cid,"has_prefix",has_prefix,.INTRINSICS)
	B_METHOD(cid,"has_suffix",has_suffix,.INTRINSICS)

	B_METHOD(cid,"reverse",reverse,.INTRINSICS)
	B_METHOD(cid,"center_justify",center_justify,.INTRINSICS)
	B_METHOD(cid,"right_justify",right_justify,.INTRINSICS)
	B_METHOD(cid,"left_justify",left_justify,.INTRINSICS)

	B_METHOD(cid,"cut",cut,.INTRINSICS)
	B_METHOD(cid,"substring",substring,.INTRINSICS)
	B_METHOD(cid,"substring_from",substring_from,.INTRINSICS)
	B_METHOD(cid,"substring_to",substring_to,.INTRINSICS)

	B_METHOD(cid,"expand_tabs",expand_tabs,.INTRINSICS)
	B_METHOD(cid,"trim_suffix",trim_suffix,.INTRINSICS)
	B_METHOD(cid,"trim_prefix",trim_prefix,.INTRINSICS)
	B_METHOD(cid,"trim",trim,.INTRINSICS)

	B_METHOD(cid,"compare",compare,.INTRINSICS)
	B_METHOD(cid,"hash",hash,.INTRINSICS)
	B_METHOD(cid,"to_lower",to_lower,.INTRINSICS)
	B_METHOD(cid,"to_upper",to_upper,.INTRINSICS)

	B_METHOD(cid,"to_camel_case",to_camel_case,.INTRINSICS)
	B_METHOD(cid,"to_pascal_case",to_pascal_case,.INTRINSICS)
	B_METHOD(cid,"to_snake_case",to_snake_case,.INTRINSICS)
	B_METHOD(cid,"to_kebab_case",to_kebab_case,.INTRINSICS)

	B_METHOD(cid,"to_ada_case",to_ada_case,.INTRINSICS)
	// B_METHOD(cid,"contains",contains,.INTRINSICS)
	// B_METHOD(cid,"",,.INTRINSICS)
	// B_METHOD(cid,"",,.INTRINSICS)
	// B_METHOD(cid,"",,.INTRINSICS)
	// B_METHOD(cid,"",,.INTRINSICS)
}