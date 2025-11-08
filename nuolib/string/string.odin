package String

import strings  "core:strings"



nuostring_write_rune  :: #force_inline proc (data: rune, obj: ^NuoString) { strings.write_rune(&obj.data,data) }







length :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'length' expects %v, but got %v.",0,cs.argc) do return	
	
	n_string := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
	INT_VAL_PTR(cs.result,len(to_string(n_string)))
}


contains :: proc(ctx: ^Context) 
{
	// cs := ctx.ctx
	// if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING),"'contains' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return	
	
	// s        := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)
	// n_string := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)

	// _bool    := strings.index(to_string(s),to_string(n_string))
	// BOOL_VAL_PTR(cs.result,_bool)
}


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

	t         := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

	s,_       := strings.repeat(data0,rcount,ctx.get_runtime_allocator())
	n_stringr := create_obj_string()

	nuostring_write_data(s,n_stringr)
	NUOOBJECT_VAL_PTR(cs.result,n_stringr)
}

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

reverse :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'length' expects %v, but got %v.",0,cs.argc) do return	
	
	string0   := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
	data0     := to_string(string0)

	t         := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

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

	t          := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

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


	t         := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

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


	t         := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

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

         t    := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

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

hash :: proc(ctx: ^Context) 
{	
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'hash' expects %v, but got %v .",0,cs.argc) do return

	s  := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
	INT_VAL_PTR(cs.result,int(hash_string(to_string(s))))
}

to_lower :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'to_lower' expects %v, but got %v .",0,cs.argc) do return

	s         := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
	n_string  := create_obj_string()

         t    := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

	r, _      := strings.to_lower(to_string(s),ctx.get_runtime_allocator())	

	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

to_upper :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'to_upper' expects %v, but got %v .",0,cs.argc) do return

	s         := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
	n_string  := create_obj_string()

         t    := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

	r, _      := strings.to_upper(to_string(s),ctx.get_runtime_allocator())	

	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

to_camel_case :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'to_camel_case' expects %v, but got %v .",0,cs.argc) do return

	s         := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
	n_string  := create_obj_string()

         t    := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

	r, _      := strings.to_camel_case(to_string(s),ctx.get_runtime_allocator())	

	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

to_pascal_case :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'to_pascal_case' expects %v, but got %v .",0,cs.argc) do return

	s         := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
	n_string  := create_obj_string()

         t    := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

	r, _      := strings.to_pascal_case(to_string(s),ctx.get_runtime_allocator())	

	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

to_snake_case :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'to_snake_case' expects %v, but got %v .",0,cs.argc) do return

	s         := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
	n_string  := create_obj_string()

         t    := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

	r, _      := strings.to_snake_case(to_string(s),ctx.get_runtime_allocator())	

	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

to_kebab_case :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'to_snake_case' expects %v, but got %v .",0,cs.argc) do return

	s         := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
	n_string  := create_obj_string()

         t    := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

	r, _      := strings.to_kebab_case(to_string(s),ctx.get_runtime_allocator())	

	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}

to_ada_case :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'to_ada_case' expects %v, but got %v .",0,cs.argc) do return

	s         := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
	n_string  := create_obj_string()

         t    := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

	r, _      := strings.to_ada_case(to_string(s),ctx.get_runtime_allocator())	

	nuostring_write_data(r,n_string)
	NUOOBJECT_VAL_PTR(cs.result,n_string)
}
