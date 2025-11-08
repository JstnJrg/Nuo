package Color

init :: proc(cid: int)
{
	register_operators()

	// methods - 6
	class_db_methods_table_reserve(cid,6)
	bind_constants(cid)
	b_methods(cid)
}


b_constants :: proc()
{

}

bind_constants :: proc(cid: int)
{
	class_register_static_property(cid,"WHITE",static_default_setter,static_default_getter)
	class_register_static_property(cid,"BLACK",static_default_setter,static_default_getter)
	class_register_static_property(cid,"GRAY",static_default_setter,static_default_getter)

	class_register_static_property(cid,"LIGHT_GRAY",static_default_setter,static_default_getter)
	class_register_static_property(cid,"DARK_GRAY",static_default_setter,static_default_getter)
	class_register_static_property(cid,"RED",static_default_setter,static_default_getter)

	class_register_static_property(cid,"GREEN",static_default_setter,static_default_getter)
	class_register_static_property(cid,"BLUE",static_default_setter,static_default_getter)
	class_register_static_property(cid,"YELLOW",static_default_setter,static_default_getter)

	class_register_static_property(cid,"MAGENTA",static_default_setter,static_default_getter)
	class_register_static_property(cid,"CYAN",static_default_setter,static_default_getter)
	class_register_static_property(cid,"ORANGE",static_default_setter,static_default_getter)

	class_register_static_property(cid,"PURPLE",static_default_setter,static_default_getter)
	class_register_static_property(cid,"BROWN",static_default_setter,static_default_getter)
	class_register_static_property(cid,"PINK",static_default_setter,static_default_getter)

	class_register_static_property(cid,"GOLD",static_default_setter,static_default_getter)
	class_register_static_property(cid,"LIME",static_default_setter,static_default_getter)
	class_register_static_property(cid,"SKYBLUE",static_default_setter,static_default_getter)

	class_register_static_property(cid,"VIOLET",static_default_setter,static_default_getter)
	class_register_static_property(cid,"BEIGE",static_default_setter,static_default_getter)
	class_register_static_property(cid,"MARRON",static_default_setter,static_default_getter)
}


b_methods   :: proc(cid: int)
{
	B_METHOD(cid,"get_luminance",get_luminance,.INTRINSICS)
	B_METHOD(cid,"darkened",darkened,.INTRINSICS)
	B_METHOD(cid,"lightened",lightened,.INTRINSICS)

	B_METHOD(cid,"lerp",lerp,.INTRINSICS)
	B_METHOD(cid,"invert",invert,.INTRINSICS)
	B_METHOD(cid,"blend",blend,.INTRINSICS)
}
