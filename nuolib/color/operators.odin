package Color


register_operators :: proc()
{
	register_setget(.OP_GET_PROPERTY,.COLOR,.SYMID,color_get)
	register_setget(.OP_SET_PROPERTY,.COLOR,.SYMID,color_set)
}


color_get :: #force_inline proc(_color,property_sid,variant_return: ^Value, ctx: ^Context)
{
	color := REINTERPRET_MEM_PTR(_color,Color)
	sid   := AS_SYMID_PTR(property_sid)
	s     := string_db_get_string(sid)

	switch s
	{
	   case `r` : INT_VAL_PTR(variant_return,int(color.r)) 
	   case `g` : INT_VAL_PTR(variant_return,int(color.g))
	   case `b` : INT_VAL_PTR(variant_return,int(color.b))
	   case `a` : INT_VAL_PTR(variant_return,int(color.a))   
	   case     : ctx.runtime_error(false,"cannot find property '%v' on base  '%v'.",s,GET_TYPE_NAME(.COLOR))
	}
}

color_set :: #force_inline proc(_color,property_sid,assign: ^Value, ctx: ^Context)
{
	color  := REINTERPRET_MEM_PTR(_color,Color)
	sid    := AS_SYMID_PTR(property_sid)
	s      := string_db_get_string(sid)

	if ctx.runtime_error(IS_VARIANT_PTR(assign,.INT),"cannot assign a value of type '%v' as '%v'.",GET_TYPE_NAME(assign.type),GET_TYPE_NAME(.INT)) do return

	switch s
	{
	   case `r` : color.r = u8(AS_INT_PTR(assign))
	   case `g` : color.g = u8(AS_INT_PTR(assign))
	   case `b` : color.b = u8(AS_INT_PTR(assign))
	   case `a` : color.a = u8(AS_INT_PTR(assign))
	   case     : ctx.runtime_error(false,"cannot find property '%v' on base  '%v'.",s,GET_TYPE_NAME(.COLOR))
	}

    // Nota(jstn): usa o buffer
    COLOR_VAL_PTR(assign,color)
	BOOL_VAL_PTR(_color,false)	
}

static_default_setter :: proc(cid, sid: int, ret: ^Value, ctx: ^Context) { ctx.runtime_error(false,"cannot assign a new value to a constant.") }

static_default_getter :: proc(cid, sid: int, ret: ^Value, ctx: ^Context)
{
	s := string_db_get_string(sid)
	c : Color

	switch s
	{
		case `WHITE` : c = {255,255,255,255}
		case `BLACK` : c = {0,0,0,255}
		case `GRAY`  : c = {128,128,128,255}  
		
		case `LIGHT_GRAY` : c = {200,200,200,255}
		case `DARK_GRAY`  : c = {80,80,80,255}
		case `RED`        : c = {255,0,0,255}
		
		case `GREEN` : c = {0,255,0,255}
		case `BLUE`  : c = {0,0,255,255}
		case `YELLOW`: c = {255,255,0,255}

		case `MAGENTA` : c = {255,0,255,255}
		case `CYAN`    : c = {0,255,255,255}
		case `ORANGE`  : c = {255,165,0,255}

		case `PURPLE`  : c = {128,0,128,255}
		case `BROWN`   : c = {139,69,19,255}
		case `PINK`    : c = {255,192,203,255}

		case `GOLD`    : c = {255,215,0,255}
		case `LIME`    : c = {50,205,50,255}
		case `SKYBLUE` : c = {135,206,235,255}

		case `VIOLET`: c = {238,130,239,255}
		case `BEIGE` : c = {245,245,220,255}
		case `MAROON`: c = {128,0,0,255}

		case         : ctx.runtime_error(false,"cannot find property '%v' on base  '%v'.",s,GET_TYPE_NAME(.COLOR))

	}

	COLOR_VAL_PTR(ret,&c)
}