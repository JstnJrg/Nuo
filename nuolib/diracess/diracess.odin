#+private
package DirAcess

open :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state

	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING),"'open' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	path    := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))
    f, err  := os2.open(path)

    if ctx.runtime_warning( err == nil ,os2.error_string(err)) { NIL_VAL_PTR(cs.result); return }

    _any    := create_any(.IMPORT,get_iid())
    state   := FileState{f,true}

    COPY_DATA(&_any._mem,&state)
    NUOOBJECT_VAL_PTR(cs.result,_any)
}



read_dir :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state

	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.INT),"'read_dir' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.INT)) do return
	if ctx.runtime_error(IS_VARIANT_PTR(ctx.peek_value(1),.ANY),"cannot call 'read_dir' on the import directly. Make an instance instead.") do return

	_any       := AS_NUOOBECT_PTR(ctx.peek_value(1),Any)
	n          := AS_INT_PTR(ctx.peek_value(0)) 

	file_state := get_data(&_any._mem,FileState)
	file       := file_state.file

	if ctx.runtime_warning(file_state.is_open,"condition File != null is false.") { NIL_VAL_PTR(cs.result); return }


	t    := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)
   
	arr := create_obj_array() 
	data:= &arr.data    

	files, e := os2.read_directory(file,n,ctx.get_runtime_allocator())
	ctx.runtime_warning(e == nil,os2.error_string(e))

	for _f in files
	{
		s := create_obj_string()
		nuostring_write_data(_f.fullpath,s)
		append(data,NUOOBJECT_VAL(s)) 
	}

    NUOOBJECT_VAL_PTR(cs.result,arr)
}


copy_directory_all :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) && IS_VARIANT_PTR(ctx.peek_value(1),.STRING),"'copy_directory_all' expects %v, but got %v and must be '%v' and '%v'.",2,cs.argc,GET_TYPE_NAME(.STRING),GET_TYPE_NAME(.STRING)) do return

	from_path := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))
	to_path   := to_string(AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString))

	e        := os2.copy_directory_all(to_path,from_path)
	ok       := e == nil

	ctx.runtime_warning(ok,os2.error_string(e))
    BOOL_VAL_PTR(cs.result,ok)
}


make_dir :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) ,"'make_dir' expects %v, but got %v and must be '%v' and '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	path     := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))

	e        := os2.make_directory(path)
	ok       := e == nil

	ctx.runtime_warning(ok,os2.error_string(e))
    BOOL_VAL_PTR(cs.result,ok)
}


make_dir_all :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) ,"'make_dir_all' expects %v, but got %v and must be '%v' and '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	path     := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))

	e        := os2.make_directory_all(path)
	ok       := e == nil

	ctx.runtime_warning(ok,os2.error_string(e))
    BOOL_VAL_PTR(cs.result,ok)
}

remove_all :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) ,"'remove_all' expects %v, but got %v and must be '%v' and '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	path     := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))

	e        := os2.remove_all(path)
	ok       := e == nil

	ctx.runtime_warning(ok,os2.error_string(e))
    BOOL_VAL_PTR(cs.result,ok)
}

set_working_directory :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) ,"'set_working_directory' expects %v, but got %v and must be '%v' and '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	path     := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))

	e        := os2.set_working_directory(path)
	ok       := e == nil

	ctx.runtime_warning(ok,os2.error_string(e))
    BOOL_VAL_PTR(cs.result,ok)
}


get_working_directory :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state

	if ctx.runtime_error(cs.argc == 0,"'get_working_directory' expects %v, but got %v.",0,cs.argc) do return

	t    := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

	str  := create_obj_string()
   	s, e := os2.get_working_directory(ctx.get_runtime_allocator())
	ctx.runtime_warning(e == nil,os2.error_string(e))

	nuostring_write_data(s,str)
    NUOOBJECT_VAL_PTR(cs.result,str)
}






close :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state

	if ctx.runtime_error(cs.argc == 0,"'close' expects %v, but got %v.",0,cs.argc) do return
	if ctx.runtime_error(IS_VARIANT_PTR(ctx.peek_value(0),.ANY),"cannot call 'close' on the import directly. Make an instance instead.") do return

	_any       := AS_NUOOBECT_PTR(ctx.peek_value(0),Any)
	file_state := get_data(&_any._mem,FileState)
	file       := file_state.file

	if ctx.runtime_warning(file_state.is_open,"condition File != null is false.") { NIL_VAL_PTR(cs.result); return }

    err := os2.close(file_state.file)
    ctx.runtime_warning(err == nil,os2.error_string(err))

    file_state.file    = nil
	file_state.is_open = false

    NIL_VAL_PTR(cs.result)
}

