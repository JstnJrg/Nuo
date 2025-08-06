#+private
package FileAcess


open :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state

	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.INT) && IS_VARIANT_PTR(ctx.peek_value(1),.STRING),"'open' expects %v, but got %v and must be '%v' and '%v'.",2,cs.argc,GET_TYPE_NAME(.INT),GET_TYPE_NAME(.STRING)) do return

	mode := AS_INT_PTR(ctx.peek_value(0))
	path := to_string(AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString))

    if ctx.runtime_warning(is_valid_mode(mode),"invalid mode.") { NIL_VAL_PTR(cs.result); return }

    f, err  := os2.open(path,get_file_mode(mode))
    if ctx.runtime_warning( err == nil ,os2.error_string(err)) { NIL_VAL_PTR(cs.result); return }

    _any    := create_any(.IMPORT,get_iid())
    state   := FileState{f,true}

    COPY_DATA(&_any._mem,&state)
    NUOOBJECT_VAL_PTR(cs.result,_any)
}

exists :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING),"'exists' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	path := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))
	BOOL_VAL_PTR(cs.result,os2.exists(path))
}

get_absolute_path :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING),"'get_absolute_path' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	path := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))
	r    := create_obj_string()

	ctx.init_runtime_temp()
	defer ctx.end_runtime_temp()

	s,err := os2.get_absolute_path(path,ctx.get_runtime_allocator())
	if ctx.runtime_warning( err == nil ,os2.error_string(err)) { NIL_VAL_PTR(cs.result); return }

	nuostring_write_data(s,r)
	NUOOBJECT_VAL_PTR(cs.result,r)
}

get_relative_path :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) && IS_VARIANT_PTR(ctx.peek_value(1),.STRING),"'get_relative_path' expects %v, but got %v and must be '%v' and '%v'.",2,cs.argc,GET_TYPE_NAME(.STRING),GET_TYPE_NAME(.STRING)) do return

	path_from := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))
	path_to   := to_string(AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString))
	r         := create_obj_string()

	ctx.init_runtime_temp()
	defer ctx.end_runtime_temp()

	s,err := os2.get_relative_path(path_from,path_to,ctx.get_runtime_allocator())
	if ctx.runtime_warning( err == nil ,os2.error_string(err)) { NIL_VAL_PTR(cs.result); return }

	nuostring_write_data(s,r)
	NUOOBJECT_VAL_PTR(cs.result,r)
}


// Nota(jstn): cria um link físico (dois nomes para o mesmo arquivo)
link :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) && IS_VARIANT_PTR(ctx.peek_value(1),.STRING),"'link' expects %v, but got %v and must be '%v' and '%v'.",2,cs.argc,GET_TYPE_NAME(.STRING),GET_TYPE_NAME(.STRING)) do return

	old_path := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))
	new_path := to_string(AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString))

	err := os2.link(old_path,new_path)
	ctx.runtime_warning( err == nil ,os2.error_string(err)) 
	NIL_VAL_PTR(cs.result)
}

symlink :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) && IS_VARIANT_PTR(ctx.peek_value(1),.STRING),"'symlink' expects %v, but got %v and must be '%v' and '%v'.",2,cs.argc,GET_TYPE_NAME(.STRING),GET_TYPE_NAME(.STRING)) do return

	old_path := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))
	new_path := to_string(AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString))

	err := os2.symlink(old_path,new_path)
	ctx.runtime_warning( err == nil ,os2.error_string(err)) 
	NIL_VAL_PTR(cs.result)
}

name :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'name' expects %v, but got %v.",0,cs.argc) do return

	if ctx.runtime_error(IS_VARIANT_PTR(ctx.peek_value(0),.ANY),"cannot call 'name' on the import directly. Make an instance instead.") do return

	_any       := AS_NUOOBECT_PTR(ctx.peek_value(0),Any)
	file_state := get_data(&_any._mem,FileState)

	file       := file_state.file
    r          := create_obj_string()
	
 	if ctx.runtime_warning(file_state.is_open,"condition File != null is false.") { NUOOBJECT_VAL_PTR(cs.result,r); return }

    nuostring_write_data(os2.name(file),r)
	NUOOBJECT_VAL_PTR(cs.result,r)
}


write :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING),"'write' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return
	if ctx.runtime_error(IS_VARIANT_PTR(ctx.peek_value(1),.ANY),"cannot call 'write' on the import directly. Make an instance instead.") do return

	data       := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))

	_any       := AS_NUOOBECT_PTR(ctx.peek_value(1),Any)
	file_state := get_data(&_any._mem,FileState)
	file       := file_state.file

	if ctx.runtime_warning(file_state.is_open,"condition File != null is false.") { INT_VAL_PTR(cs.result,-1); return }
	n,err      := #force_inline os2.write(file,transmute([]byte)(data))

	ctx.runtime_warning( err == nil ,os2.error_string(err))
    INT_VAL_PTR(cs.result,n)
}


write_at :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state

	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) && IS_VARIANT_PTR(ctx.peek_value(1),.INT),"'write_at' expects %v, but got %v and must be '%v' and '%v'.",2,cs.argc,GET_TYPE_NAME(.STRING),GET_TYPE_NAME(.INT)) do return
	if ctx.runtime_error(IS_VARIANT_PTR(ctx.peek_value(2),.ANY),"cannot call 'write_at' on the import directly. Make an instance instead.") do return

	offset := AS_INT_PTR(ctx.peek_value(1))
	data   := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))

	_any       := AS_NUOOBECT_PTR(ctx.peek_value(2),Any)
	file_state := get_data(&_any._mem,FileState)
	file       := file_state.file

	if ctx.runtime_warning(file_state.is_open,"condition File != null is false.") { INT_VAL_PTR(cs.result,-1); return }

    n,err := #force_inline os2.write_at(file,transmute([]byte)(data),i64(offset))
    ctx.runtime_warning( err == nil ,os2.error_string(err))
    INT_VAL_PTR(cs.result,n)
}

read :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'read' expects %v, but got %v.",0,cs.argc) do return
	if ctx.runtime_error(IS_VARIANT_PTR(ctx.peek_value(0),.ANY),"cannot call 'read' on the import directly. Make an instance instead.") do return

	_any       := AS_NUOOBECT_PTR(ctx.peek_value(0),Any)
	file_state := get_data(&_any._mem,FileState)

	file       := file_state.file
    r          := create_obj_string()
	
 	if ctx.runtime_warning(file_state.is_open,"condition File != null is false.") { NUOOBJECT_VAL_PTR(cs.result,r); return }

 	file_size,err  := os2.file_size(file)
 	if ctx.runtime_warning(err == nil ,os2.error_string(err)) { NUOOBJECT_VAL_PTR(cs.result,r); return }

    resize(&r.data.buf,file_size)
    _,err = #force_inline os2.read(file,r.data.buf[:])

    ctx.runtime_warning(err == nil ,os2.error_string(err))
	NUOOBJECT_VAL_PTR(cs.result,r)
}

read_at :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.INT) ,"'read_at' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.INT)) do return
	if ctx.runtime_error(IS_VARIANT_PTR(ctx.peek_value(1),.ANY),"cannot call 'read_at' on the import directly. Make an instance instead.") do return

	offset     := AS_INT_PTR(ctx.peek_value(0))
	_any       := AS_NUOOBECT_PTR(ctx.peek_value(1),Any)
	
	file_state := get_data(&_any._mem,FileState)
	file       := file_state.file
    r          := create_obj_string()

    if ctx.runtime_warning(file_state.is_open,"condition File != null is false.") { NUOOBJECT_VAL_PTR(cs.result,r); return }

 	file_size,err  := os2.file_size(file)
 	if ctx.runtime_warning(err == nil ,os2.error_string(err)) { NUOOBJECT_VAL_PTR(cs.result,r); return }

    resize(&r.data.buf,file_size-i64(offset*size_of(byte)))
    _,err      = #force_inline os2.read_at(file,r.data.buf[:],i64(offset))

    ctx.runtime_warning(err == nil ,os2.error_string(err))
    NUOOBJECT_VAL_PTR(cs.result,r)
}


flush :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state

	if ctx.runtime_error(cs.argc == 0,"'flush' expects %v, but got %v.",0,cs.argc) do return
	if ctx.runtime_error(IS_VARIANT_PTR(ctx.peek_value(0),.ANY),"cannot call 'flush' on the import directly. Make an instance instead.") do return

	_any       := AS_NUOOBECT_PTR(ctx.peek_value(0),Any)
	file_state := get_data(&_any._mem,FileState)
	file       := file_state.file
	
 	if ctx.runtime_warning(file_state.is_open,"condition File != null is false.") { NIL_VAL_PTR(cs.result); return }

	err        := os2.flush(file_state.file)
	ctx.runtime_warning(err == nil ,os2.error_string(err))
    NIL_VAL_PTR(cs.result)
}



// // Nota(jstn):
// // flush -> envia os dados do buffer para o SO e não garante que os dados foram/serão gravados
// // sync  -> força o SO a escrever no disco tudo que estiver pendente no buffer (garante que os dados foram/serão gravados)
sync :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state

	if ctx.runtime_error(cs.argc == 0,"'sync' expects %v, but got %v.",0,cs.argc) do return
	if ctx.runtime_error(IS_VARIANT_PTR(ctx.peek_value(0),.ANY),"cannot call 'sync' on the import directly. Make an instance instead.") do return

	_any       := AS_NUOOBECT_PTR(ctx.peek_value(0),Any)
	file_state := get_data(&_any._mem,FileState)
	file       := file_state.file
	
 	if ctx.runtime_warning(file_state.is_open,"condition File != null is false.") { NIL_VAL_PTR(cs.result); return }

	err        := os2.sync(file_state.file)
	ctx.runtime_warning(err == nil ,os2.error_string(err))
    NIL_VAL_PTR(cs.result)
}

remove :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING),"'remove' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	path := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))
	err  := os2.remove(path)
	ok   := err == nil

	ctx.runtime_warning(ok,os2.error_string(err))
    BOOL_VAL_PTR(cs.result,ok)
}

is_file :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING),"'is_file' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	path := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))
    BOOL_VAL_PTR(cs.result,os2.is_file(path))
}

is_dir :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING),"'is_dir' expects %v, but got %v and must be '%v'.",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	path := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))
    BOOL_VAL_PTR(cs.result,os2.is_dir(path))
}

rename :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) && IS_VARIANT_PTR(ctx.peek_value(1),.STRING),"'rename' expects %v, but got %v and must be '%v' and '%v'.",2,cs.argc,GET_TYPE_NAME(.STRING),GET_TYPE_NAME(.STRING)) do return

	old_path := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))
	new_path := to_string(AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString))

	err      := os2.rename(old_path,new_path)
	ok       := err == nil

	ctx.runtime_warning(ok,os2.error_string(err))
    BOOL_VAL_PTR(cs.result,ok)
}

copy :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING) && IS_VARIANT_PTR(ctx.peek_value(1),.STRING),"'copy' expects %v, but got %v and must be '%v' and '%v'.",2,cs.argc,GET_TYPE_NAME(.STRING),GET_TYPE_NAME(.STRING)) do return

	old_path := to_string(AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString))
	new_path := to_string(AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString))

	err      := os2.copy_file(old_path,new_path)
	ok       := err == nil

	ctx.runtime_warning(ok,os2.error_string(err))
    BOOL_VAL_PTR(cs.result,ok)
}

is_open :: proc(ctx: ^Context) 
{
	cs   := ctx.call_state

	if ctx.runtime_error(cs.argc == 0,"'is_open' expects %v, but got %v.",0,cs.argc) do return
	if ctx.runtime_error(IS_VARIANT_PTR(ctx.peek_value(0),.ANY),"cannot call 'is_open' on the import directly. Make an instance instead.") do return

	_any       := AS_NUOOBECT_PTR(ctx.peek_value(0),Any)
	file_state := get_data(&_any._mem,FileState)
	file       := file_state.file
	
    BOOL_VAL_PTR(cs.result,file_state.is_open)
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

