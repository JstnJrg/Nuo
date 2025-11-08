package Vec2

init :: proc(cid: int)
{
	register_operators()

	// methods - 35
	class_db_methods_table_reserve(cid,35)
	register_properties(cid)
	b_methods(cid)
}

b_methods :: proc(cid: int)
{
	// STATIC
	B_METHOD(cid,"from_angle",from_angle,.STATIC)
	B_METHOD(cid,"from_circle",from_circle,.STATIC)
	B_METHOD(cid,"random_unit",random_unit,.STATIC)

	// 
	B_METHOD(cid,"abs",abs,.INTRINSICS)
	B_METHOD(cid,"aspect",aspect,.INTRINSICS)
	B_METHOD(cid,"angle",angle,.INTRINSICS)
	B_METHOD(cid,"angle_to_point",angle_to_point,.INTRINSICS)

	B_METHOD(cid,"bounce",bounce,.INTRINSICS)
	B_METHOD(cid,"clamp",clamp,.INTRINSICS)
	B_METHOD(cid,"cross",cross,.INTRINSICS)
	B_METHOD(cid,"direction_to",direction_to,.INTRINSICS)

	B_METHOD(cid,"dot",dot,.INTRINSICS)
	B_METHOD(cid,"distance_to",distance_to,.INTRINSICS)
	B_METHOD(cid,"distance_to_squared",distance_to_squared,.INTRINSICS)
	B_METHOD(cid,"floor",floor,.INTRINSICS)

	B_METHOD(cid,"invert",invert,.INTRINSICS)
	B_METHOD(cid,"is_equal_approx",is_equal_approx,.INTRINSICS)
	B_METHOD(cid,"length",length,.INTRINSICS)
	B_METHOD(cid,"length_squared",length_squared,.INTRINSICS)

	B_METHOD(cid,"lerp",lerp,.INTRINSICS)
	B_METHOD(cid,"limit_length",limit_length,.INTRINSICS)
	B_METHOD(cid,"min",min,.INTRINSICS)
	B_METHOD(cid,"max",max,.INTRINSICS)

	B_METHOD(cid,"normalize",normalize,.INTRINSICS)
	B_METHOD(cid,"move_toward",move_toward,.INTRINSICS)
	B_METHOD(cid,"posmod",posmod,.INTRINSICS)
	B_METHOD(cid,"reflect",reflect,.INTRINSICS)

	B_METHOD(cid,"round",round,.INTRINSICS)
	B_METHOD(cid,"rotate",rotate,.INTRINSICS)
	B_METHOD(cid,"sign",sign,.INTRINSICS)
	B_METHOD(cid,"smoothstep",smoothstep,.INTRINSICS)
	
	B_METHOD(cid,"slerp",slerp,.INTRINSICS)
	B_METHOD(cid,"slide",slide,.INTRINSICS)
	B_METHOD(cid,"snapped",snapped,.INTRINSICS)
	B_METHOD(cid,"orthogonal",orthogonal,.INTRINSICS)
}
