package Color

init :: proc(cid: int)
{
	register_operators()
	b_methods(cid)
}


b_constants :: proc()
{

}

bind_constants :: proc(cid: int)
{
	class_register_static_property(cid,"IDENTITY",static_default_setter,static_default_getter)

}


b_methods   :: proc(cid: int)
{
	B_METHOD(cid,"get_luminance",get_luminance,.INTRINSICS)
	B_METHOD(cid,"darkened",darkened,.INTRINSICS)
	B_METHOD(cid,"lightened",lightened,.INTRINSICS)

	B_METHOD(cid,"lerp",lerp,.INTRINSICS)
	B_METHOD(cid,"invert",invert,.INTRINSICS)
}



static_default_setter :: proc(cid, sid: int, ret: ^Value, ctx: ^Context) { ctx.runtime_error(false,"cannot assign a new value to a constant.") }

static_default_getter :: proc(cid, sid: int, ret: ^Value, ctx: ^Context)
{
	// s := string_db_get_string(sid)

	// switch s
	// {
	// 	case `IDENTITY` : 

	// 		m : mat2x3
			
	// 		m[0] = Vec2{1,0}
	// 		m[1] = Vec2{0,1}
	// 		m[2] = Vec2{0,0}
	// 	    NUOOBJECT_VAL_PTR(ret,create_transform2(&m))
		
	// 	case `FLIP_X` : 

	// 		m : mat2x3
			
	// 		m[0] = Vec2{-1,0}
	// 		m[1] = Vec2{0,1}
	// 		m[2] = Vec2{0,0}
	// 	    NUOOBJECT_VAL_PTR(ret,create_transform2(&m))
		
	// 	case `FLIP_Y` : 

	// 		m : mat2x3
			
	// 		m[0] = Vec2{1,0}
	// 		m[1] = Vec2{0,-1}
	// 		m[2] = Vec2{0,0}
	// 	    NUOOBJECT_VAL_PTR(ret,create_transform2(&m))
	// }

}