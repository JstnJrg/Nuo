package String

import strings  "core:strings"

length :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'length' expects %v, but got %v.",0,cs.argc) do return	
	
	n_string := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
	INT_VAL_PTR(cs.result,len(to_string(n_string)))
}

// contains :: proc(ctx: ^Context) 
// {
// 	cs := ctx.ctx
// 	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING),"'contains' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return	
	
// 	n_string0 := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)
// 	n_string1 := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)

// 	data0     := to_string(n_string0)
// 	data1     := to_string(n_string1)


// 	// _bool     := strings.index(data0,data1)

	

// 	BOOL_VAL_PTR(cs.result,false)
// }


count :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING),"'count' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return	
	
	n_string0 := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)
	n_string1 := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)

	data0     := to_string(n_string0)
	data1     := to_string(n_string1)

	INT_VAL_PTR(cs.result,strings.count(data0,data1))
}

repeat :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1  && IS_VARIANT_PTR(ctx.peek_value(0),.INT),"'repeat' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.INT)) do return	
	
	n_string0 := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)
	rcount    := AS_INT_PTR(ctx.peek_value(0))

	data0     := to_string(n_string0)
	len       := len(data0)

	if ctx.runtime_error(rcount > 0,"repeat coun condition > 0 is false.") do return
	if ctx.runtime_error((len*rcount)/rcount == len ,"repeat count will cause an overflow") do return

	ctx.init_runtime_temp()
	defer ctx.end_runtime_temp()

	s,_       := strings.repeat(data0,rcount,ctx.get_runtime_allocator())
	n_stringr := create_obj_string()

	nuostring_write_data(s,n_stringr)
	NUOOBJECT_VAL_PTR(cs.result,n_stringr)
}


// replace :: proc(ctx: ^Context) 
// {
// 	cs := ctx.ctx
	
// 	if ctx.runtime_error(cs.argc == 3 ,"'replace' expects %v, but got %v and must be '%v'.",3,cs.argc) do return
// 	if ctx.runtime_error(IS_VARIANT_PTR(ctx.peek_value(0),.STRING) && IS_VARIANT_PTR(ctx.peek_value(1),.STRING) && IS_VARIANT_PTR(ctx.peek_value(2),.INT) ,"'replace' expects '%v','%v' and '%v'.",GET_TYPE_NAME(.STRING),GET_TYPE_NAME(.STRING),GET_TYPE_NAME(.INT)) do return	
	
// 	// n_string0 := AS_NUOOBECT_PTR(ctx.peek_value(cs.argc),NuoString)

// 	// n_stringo := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
// 	// n_stringn := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)
// 	// count     := AS_INT_PTR(ctx.peek_value(2))

// 	// data0     := to_string(n_string0)
// 	// datao     := to_string(n_stringo)
// 	// datan     := to_string(n_stringn)

// 	// ctx.init_runtime_temp()
// 	// defer ctx.end_runtime_temp()

// 	println(":--------->")

// 	s,_       := strings.replace("a b c dddddddddddd","d",".",2)
	
		

// 	INT_VAL_PTR(cs.result,-1)
// }




equaln :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) ,"'equaln' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)
	n_string  := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)

	data0     := to_string(string0)
	data1     := to_string(n_string)

	BOOL_VAL_PTR(cs.result, #force_inline strings.equal_fold(data0,data1))
}


prefix_length_commom :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) ,"'prefix_length_commom' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)
	n_string  := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)

	data0     := to_string(string0)
	data1     := to_string(n_string)

	INT_VAL_PTR(cs.result, #force_inline strings.prefix_length(data0,data1))
}

has_prefix :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) ,"'has_prefix' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)
	n_string  := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)

	data0     := to_string(string0)
	data1     := to_string(n_string)

	BOOL_VAL_PTR( cs.result, #force_inline strings.has_prefix(data0,data1))
}

has_suffix :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) ,"'has_suffix' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)
	n_string  := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)

	data0     := to_string(string0)
	data1     := to_string(n_string)

	BOOL_VAL_PTR( cs.result, #force_inline strings.has_suffix(data0,data1))
}

join :: proc(ctx: ^Context) 
{

	cs   := ctx.call_state
	argc := cs.argc
	
	if ctx.runtime_error(cs.argc > 1 ," 'join' expects over 1 arguments, but got %v and must be String's",argc) do return
	for i in 0..< argc do if ctx.runtime_error(IS_VARIANT_PTR(ctx.peek_value(i),.STRING)," 'join' expects over 1 arguments, but got %v and must be String's",argc) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(argc),NuoString)

	n_string  := create_obj_string()
	data0     := to_string(string0)

	n_stringr := create_obj_string()
	nuostring_write_data(data0,n_stringr)

	for i in 0..< argc-1 
	{
		a_string   :=  AS_NUOOBECT_PTR(ctx.peek_value(argc-1),NuoString)
		b_string   :=  AS_NUOOBECT_PTR(ctx.peek_value(i),NuoString)
		
		nuostring_write_data(to_string(a_string),n_stringr)
		nuostring_write_data(to_string(b_string),n_stringr)
	}

	NUOOBJECT_VAL_PTR(cs.result,n_stringr)
}

// replace :: proc(ctx: ^Context) 
// {
// 	amount : Int
// 	if ctx.argc != 3 || !IS_VAL_STRING_PTR(&ctx.args[0]) || !IS_VAL_STRING_PTR(&ctx.args[1]) || !IS_INT_PTR(&ctx.args[2],&amount) { error_msg("replace",3,"String's and int",ctx); return }

// 	string_r    := CREATE_OBJ_STRING_NO_DATA()

// 	temp_arena  := ctx.init_temp()
// 	allocator   := ctx.get_allocator()

// 	r,allocated := #force_inline strings.replace(VAL_STRING_DATA_PTR(&ctx.args[3]),VAL_STRING_DATA_PTR(&ctx.args[0]),VAL_STRING_DATA_PTR(&ctx.args[1]),amount,allocator)
// 	defer ctx.end_temp(temp_arena)

// 	OBJ_STRING_WRITE_DATA_STRING(string_r,r,true)
// 	OBJECT_VAL_PTR(ctx.result,string_r,.OBJ_STRING)
// }


// remove :: proc(ctx: ^Context) 
// {
// 	value : Int
// 	if ctx.argc != 2 || !IS_VAL_STRING_PTR(&ctx.args[0]) || !IS_INT_PTR(&ctx.args[1],&value) { error_msg("remove",2,"String and int",ctx); return }

// 	string_r     := CREATE_OBJ_STRING_NO_DATA()

// 	temp_arena  := ctx.init_temp()
// 	allocator   := ctx.get_allocator()

// 	r, _ := #force_inline strings.remove(VAL_STRING_DATA_PTR(&ctx.args[2]),VAL_STRING_DATA_PTR(&ctx.args[0]),value,allocator)
// 	defer ctx.end_temp(temp_arena)

// 	OBJ_STRING_WRITE_DATA_STRING(string_r,r,true)
// 	OBJECT_VAL_PTR(ctx.result,string_r,.OBJ_STRING)
// }


reverse :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'length' expects %v, but got %v.",0,cs.argc) do return	
	
	string0   := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
	data0     := to_string(string0)

	ctx.init_runtime_temp()
	defer ctx.end_runtime_temp()

	r,_       := #force_inline strings.reverse(data0,ctx.get_runtime_allocator())

	n_string  := create_obj_string()
	nuostring_write_data(r,n_string)

	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

center_justify :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) && IS_VARIANT_PTR(ctx.peek_value(1),.INT) ,"'center_justify' expects %v, but got %v and must be '%v' and '%v'.",2,cs.argc,GET_TYPE_NAME(.STRING),GET_TYPE_NAME(.INT)) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(2),NuoString)
	string_1  := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)

	amount    := AS_INT_PTR(ctx.peek_value(1))

	data0     := to_string(string0)
	data1     := to_string(string_1)

	n_string  := create_obj_string()


	ctx.init_runtime_temp()
	defer ctx.end_runtime_temp()

	r,_        := #force_inline strings.center_justify(data0,amount,data1,ctx.get_runtime_allocator())

	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

right_justify :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) && IS_VARIANT_PTR(ctx.peek_value(1),.INT) ,"'right_justify' expects %v, but got %v and must be '%v' and '%v'.",2,cs.argc,GET_TYPE_NAME(.STRING),GET_TYPE_NAME(.INT)) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(2),NuoString)
	string_1  := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)

	amount    := AS_INT_PTR(ctx.peek_value(1))

	data0     := to_string(string0)
	data1     := to_string(string_1)

	n_string  := create_obj_string()


	ctx.init_runtime_temp()
	defer ctx.end_runtime_temp()

	r,_        := #force_inline strings.right_justify(data0,amount,data1,ctx.get_runtime_allocator())

	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

left_justify :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) && IS_VARIANT_PTR(ctx.peek_value(1),.INT) ,"'left_justify' expects %v, but got %v and must be '%v' and '%v'.",2,cs.argc,GET_TYPE_NAME(.STRING),GET_TYPE_NAME(.INT)) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(2),NuoString)
	string_1  := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)

	amount    := AS_INT_PTR(ctx.peek_value(1))

	data0     := to_string(string0)
	data1     := to_string(string_1)

	n_string  := create_obj_string()

	ctx.init_runtime_temp()
	defer ctx.end_runtime_temp()

	r,_        := #force_inline strings.left_justify(data0,amount,data1,ctx.get_runtime_allocator())

	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

cut :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.INT) && IS_VARIANT_PTR(ctx.peek_value(1),.INT) ,"'cut' expects %v, but got %v and must be '%v' and '%v'.",2,cs.argc,GET_TYPE_NAME(.INT),GET_TYPE_NAME(.INT)) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(2),NuoString)

	l         := AS_INT_PTR(ctx.peek_value(0))
	h         := AS_INT_PTR(ctx.peek_value(1))

	r         := strings.cut(to_string(string0),l,h)
	n_string  := create_obj_string()

	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

substring :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.INT) && IS_VARIANT_PTR(ctx.peek_value(1),.INT) ,"'substring' expects %v, but got %v and must be '%v' and '%v'.",2,cs.argc,GET_TYPE_NAME(.INT),GET_TYPE_NAME(.INT)) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(2),NuoString)

	l         := AS_INT_PTR(ctx.peek_value(0))
	h         := AS_INT_PTR(ctx.peek_value(1))

	r,_       := strings.substring(to_string(string0),l,h)
	n_string  := create_obj_string()

	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

substring_from :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.INT) ,"'substring_from' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.INT)) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)
	l         := AS_INT_PTR(ctx.peek_value(0))

	r,_       := strings.substring_from(to_string(string0),l)
	n_string  := create_obj_string()

	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

substring_to :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.INT) ,"'substring_to' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.INT)) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)
	l         := AS_INT_PTR(ctx.peek_value(0))

	r,_       := strings.substring_to(to_string(string0),l)
	n_string  := create_obj_string()

	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

expand_tabs :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.INT) ,"'expand_tabs' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.INT)) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)
	tabe_size := AS_INT_PTR(ctx.peek_value(0))

	n_string  := create_obj_string()
	if ctx.runtime_warning(tabe_size > 0,"tab size must be positive.") { NUOOBJECT_VAL_PTR(cs.result,n_string); return }

	ctx.init_runtime_temp()
	defer ctx.end_runtime_temp()

	r,_       := strings.expand_tabs(to_string(string0),tabe_size,ctx.get_runtime_allocator())
	
	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

trim_suffix :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) ,"'trim_suffix' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)
	suffix    := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)

	n_string  := create_obj_string()
	r         := #force_inline strings.trim_suffix(to_string(string0),to_string(suffix))
	
	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

trim_prefix :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) ,"'trim_prefix' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)
	preffix   := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)

	n_string  := create_obj_string()
	r         := #force_inline strings.trim_prefix(to_string(string0),to_string(preffix))
	
	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

trim :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) ,"'trim' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)
	s         := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)

	n_string  := create_obj_string()
	r         := #force_inline strings.trim(to_string(string0),to_string(s))
	
	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

compare :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) ,"'compare' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	string0   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)
	s         := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)

	INT_VAL_PTR(cs.result,#force_inline strings.compare(to_string(string0),to_string(s)))
}


// get_last_index :: proc(ctx: ^Context) {
	



// 	when OSCRIPT_ALLOW_RUNTIME_CHECK do if argc != 1 || !IS_VAL_STRING_PTR(&args[0]) { 
// 	  	CALL_ERROR_STRING(ctx,"'get_last_index' function expects '1' arg, but got ",", and the arguments must be a string.")
// 	  	return
// 	}
// 	INT_VAL_PTR( ctx.result, #force_inline strings.last_index_any(VAL_STRING_DATA_PTR(&args[argc]),VAL_STRING_DATA_PTR(&args[0])))
// }


// // get_first_index :: proc(ctx: ^Context) {
	
// //


// // 	when OSCRIPT_ALLOW_RUNTIME_CHECK do if argc != 1 || !IS_VAL_STRING_PTR(&args[0]) { 
// // 	  	CALL_ERROR_STRING(ctx,"'get_first_index' function expects '1' arg, but got ",", and the arguments must be a string.")
// // 	  	return
// // 	}
// // 	INT_VAL_PTR( ctx.result, #force_inline strings.index_any(VAL_STRING_DATA_PTR(&args[argc]),VAL_STRING_DATA_PTR(&args[0])))
// // }

// // get_index :: proc(ctx: ^Context) {
	
// //


// // 	when OSCRIPT_ALLOW_RUNTIME_CHECK do if argc != 1 || !IS_VAL_STRING_PTR(&args[0]) { 
// // 	  	CALL_ERROR_STRING(ctx,"'get_index' function expects '1' arg, but got ",", and the arguments must be a string.")
// // 	  	return
// // 	}
// // 	INT_VAL_PTR( ctx.result, #force_inline strings.index(VAL_STRING_DATA_PTR(&args[argc]),VAL_STRING_DATA_PTR(&args[0])))
// // }


// hash :: proc(ctx: ^Context) 
// {	
// 	if ctx.argc != 0 { error_msg0("hash",0,ctx); return }
// 	INT_VAL_PTR( ctx.result, int(VAL_AS_OBJ_STRING_PTR(&ctx.args[0]).hash))
// }

// to_lower :: proc(ctx: ^Context) 
// {
// 	if ctx.argc != 0 { error_msg0("to_lower",0,ctx); return }

// 	temp_arena  := ctx.init_temp()
// 	allocator   := ctx.get_allocator()

// 	s, _        := #force_inline strings.to_lower(VAL_STRING_DATA_PTR(&ctx.args[0]),allocator)	
// 	defer ctx.end_temp(temp_arena)
	
// 	string_r := CREATE_OBJ_STRING_NO_DATA()

// 	OBJ_STRING_WRITE_DATA_STRING(string_r,s,true)
// 	OBJECT_VAL_PTR(ctx.result,string_r,.OBJ_STRING)
// }

// to_upper :: proc(ctx: ^Context) 
// {
// 	if ctx.argc != 0 { error_msg0("to_upper",0,ctx); return }

// 	temp_arena  := ctx.init_temp()
// 	allocator   := ctx.get_allocator()

// 	s, _        := #force_inline strings.to_upper(VAL_STRING_DATA_PTR(&ctx.args[0]),allocator)	
// 	defer ctx.end_temp(temp_arena)
	
// 	string_r := CREATE_OBJ_STRING_NO_DATA()

// 	OBJ_STRING_WRITE_DATA_STRING(string_r,s,true)
// 	OBJECT_VAL_PTR(ctx.result,string_r,.OBJ_STRING)
// }

// to_camel_case :: proc(ctx: ^Context) 
// {
// 	if ctx.argc != 0 { error_msg0("to_camel_case",0,ctx); return }

// 	temp_arena  := ctx.init_temp()
// 	allocator   := ctx.get_allocator()

// 	s,_         := #force_inline strings.to_camel_case(VAL_STRING_DATA_PTR(&ctx.args[0]))
// 	defer ctx.end_temp(temp_arena)
	
// 	string_r := CREATE_OBJ_STRING_NO_DATA()

// 	OBJ_STRING_WRITE_DATA_STRING(string_r,s,true)
// 	OBJECT_VAL_PTR(ctx.result,string_r,.OBJ_STRING)
// }

// to_pascal_case :: proc(ctx: ^Context) 
// {
// 	if ctx.argc != 0 { error_msg0("to_pascal_case",0,ctx); return }

// 	temp_arena  := ctx.init_temp()
// 	allocator   := ctx.get_allocator()

// 	s,_         := #force_inline strings.to_pascal_case(VAL_STRING_DATA_PTR(&ctx.args[0]),allocator)
// 	defer ctx.end_temp(temp_arena)
	
// 	string_r := CREATE_OBJ_STRING_NO_DATA()

// 	OBJ_STRING_WRITE_DATA_STRING(string_r,s,true)
// 	OBJECT_VAL_PTR(ctx.result,string_r,.OBJ_STRING)
// }

// to_snake_case :: proc(ctx: ^Context) 
// {
// 	if ctx.argc != 0 { error_msg0("to_snake_case",0,ctx); return }

// 	temp_arena  := ctx.init_temp()
// 	allocator   := ctx.get_allocator()

// 	s,_         := #force_inline strings.to_snake_case(VAL_STRING_DATA_PTR(&ctx.args[0]),allocator)	
// 	defer ctx.end_temp(temp_arena)

// 	string_r := CREATE_OBJ_STRING_NO_DATA()
	
// 	OBJ_STRING_WRITE_DATA_STRING(string_r,s,true)
// 	OBJECT_VAL_PTR(ctx.result,string_r,.OBJ_STRING)
// }

// to_kebab_case :: proc(ctx: ^Context) 
// {
// 	if ctx.argc != 0 { error_msg0("to_kebab_case",0,ctx); return }

// 	temp_arena  := ctx.init_temp()
// 	allocator   := ctx.get_allocator()

// 	s,e_ 		:= #force_inline strings.to_kebab_case(VAL_STRING_DATA_PTR(&ctx.args[0]),allocator)	
// 	defer ctx.end_temp(temp_arena)

// 	string_r := CREATE_OBJ_STRING_NO_DATA()

// 	OBJ_STRING_WRITE_DATA_STRING(string_r,s,true)
// 	free_all(allocator)

// 	OBJECT_VAL_PTR(ctx.result,string_r,.OBJ_STRING)
// }

// to_ada_case :: proc(ctx: ^Context) 
// {
// 	if ctx.argc != 0 { error_msg0("to_ada_case",0,ctx); return }

// 	temp_arena  := ctx.init_temp()
// 	allocator   := ctx.get_allocator()

// 	s,_ 		:= #force_inline strings.to_ada_case(VAL_STRING_DATA_PTR(&ctx.args[0]),allocator)
// 	defer ctx.end_temp(temp_arena)
	
// 	string_r := CREATE_OBJ_STRING_NO_DATA()
	
// 	OBJ_STRING_WRITE_DATA_STRING(string_r,s,true)
// 	OBJECT_VAL_PTR(ctx.result,string_r,.OBJ_STRING)
// }

// get_file :: proc(ctx: ^Context) 
// {
// 	if ctx.argc != 0 { error_msg0("get_file",0,ctx); return }

// 	path     := VAL_STRING_DATA_PTR(&ctx.args[0])
// 	string_r := CREATE_OBJ_STRING_NO_DATA()
	
// 	OBJ_STRING_WRITE_DATA_STRING(string_r,filepath.base(path),true)
// 	OBJECT_VAL_PTR(ctx.result,string_r,.OBJ_STRING)
// }

// get_filename :: proc(ctx: ^Context) 
// {
// 	if ctx.argc != 0 { error_msg0("get_filename",0,ctx); return }

// 	path     := VAL_STRING_DATA_PTR(&ctx.args[0])
// 	string_r := CREATE_OBJ_STRING_NO_DATA()
	
// 	OBJ_STRING_WRITE_DATA_STRING(string_r,filepath.stem(path),true)
// 	OBJECT_VAL_PTR(ctx.result,string_r,.OBJ_STRING)
// }

// get_short_filename :: proc(ctx: ^Context) 
// {
// 	if ctx.argc != 0 { error_msg0("get_short_filename",0,ctx); return }

// 	path     := VAL_STRING_DATA_PTR(&ctx.args[0])
// 	string_r := CREATE_OBJ_STRING_NO_DATA()
	
// 	OBJ_STRING_WRITE_DATA_STRING(string_r,filepath.stem(path),true)
// 	OBJECT_VAL_PTR(ctx.result,string_r,.OBJ_STRING)
// }

// get_extension :: proc(ctx: ^Context) 
// {
// 	if ctx.argc != 0 { error_msg0("get_extension",0,ctx); return }

// 	path     := VAL_STRING_DATA_PTR(&ctx.args[0])
// 	string_r := CREATE_OBJ_STRING_NO_DATA()
	
// 	OBJ_STRING_WRITE_DATA_STRING(string_r,filepath.ext(path),true)
// 	OBJECT_VAL_PTR(ctx.result,string_r,.OBJ_STRING)
// }

// get_long_extension :: proc(ctx: ^Context) 
// {
// 	if ctx.argc != 0 { error_msg0("get_long_extension",0,ctx); return }

// 	path     := VAL_STRING_DATA_PTR(&ctx.args[0])
// 	string_r := CREATE_OBJ_STRING_NO_DATA()
	
// 	OBJ_STRING_WRITE_DATA_STRING(string_r,filepath.long_ext(path),true)
// 	OBJECT_VAL_PTR(ctx.result,string_r,.OBJ_STRING)
// }