package Variant


error_import_setter :: #force_inline proc(iid : int ,property_sid,variant_return: ^Value, ctx: ^Context) { ctx.runtime_error(false,"Import is ready-only.") }
error_import_getter :: #force_inline proc(iid : int ,property_sid,variant_return: ^Value, ctx: ^Context) { ctx.runtime_error(false,"Import is ready-only.") }



default_import_setter :: #force_inline proc(iid: int ,property_sid,variant_return: ^Value, ctx: ^Context)
{
	sid          := AS_SYMID_PTR(property_sid)
	s            := string_db_get_string(sid)
	hash         := string_db_get_hash(sid)
	exposed      := Visibility{.IMPORT,.CLASS}

	has,exposed_ := table_iimport_set(iid,hash,variant_return,&exposed)

	ctx.runtime_error(has,"cannot find property '%v' on base  '%v'.",s,GET_TYPE_NAME(.IMPORT))
	ctx.runtime_error(!exposed_,"acess denied to assign '%v'.",s)	
}


default_import_getter :: #force_inline proc(iid: int ,property_sid,variant_return: ^Value, ctx: ^Context)
{
	sid          := AS_SYMID_PTR(property_sid)
	s            := string_db_get_string(sid)
	hash         := string_db_get_hash(sid)

	exposed      := Visibility{.IMPORT}
	has,exposed_ := table_iimport_get(iid,hash,variant_return,&exposed)

	ctx.runtime_error(has,"Import invalid acess to property or key '%v' on '%v'.",s,import_db_name(iid))
	ctx.runtime_error(!exposed_,"acess denied to '%v'.",s)
}


default_class_error_creator   :: proc(ctx: ^Context )
{
	cs  := ctx.call_state
	cid := AS_INT_PTR(ctx.peek_value(cs.argc))
	ctx.runtime_error(false,"Class '%v' cannot be instatiate.",class_db_get_class_name(cid)) 
}



CLASS_INIT       :: `_init`
CLASS_PROPERTIES :: "@_____PROPERTIES_____"
CLASS_INIT_HASH := hash_string(CLASS_INIT)


default_class_creator :: proc(ctx: ^Context)
{
	cs   := ctx.call_state
	argc := cs.argc

	if ctx.runtime_error(IS_VARIANT_PTR(ctx.peek_value(argc),.CLASS),"only classes are instantiable.") do return
	

	t     := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

	adata := make([]Value,argc,ctx.get_runtime_allocator())
	ctx.copy_args(cs.args[:],adata[:],argc)

	defer { cs.args = cs.args[0:][:0]; unref_slice(adata[:]) }

	cid        := AS_INT_PTR(ctx.peek_value(argc))


	// instance
	instance  := create_obj_instance(cid)
	instancev := NUOOBJECT_VAL(instance)
	

	// ============ _____PROPERTIES_____ ============
	properties := class_db_get_method_list_recursively(cid,hash_string(CLASS_PROPERTIES),.INSTANCE,ctx.get_runtime_allocator())
	count      := len(properties) 

	for i in 0..< count
	{
		ref_object(instance)
		ctx.push_value(&instancev)

		if ctx.call(&properties[count-1-i],0,1) do return
		ctx.pop_value() //nil
	}

	// ============ _init ============

	method     : Value
	method_p   := &method

	has        := class_db_get_method(cid,CLASS_INIT_HASH,method_p,.INSTANCE) 

	if !has
	{
		if ctx.runtime_error(argc == 0, "expected '0' arguments, but got '%v'.",argc) do return
		NUOOBJECT_VAL_PTR(cs.result,instance)
		return
	}

	// _init call
	for &value in adata 
	{ 
		p := &value
		ref_value(p)
		ctx.push_value(p) 
	}

	ctx.push_value(&instancev)
	if ctx.call(method_p,argc,1) do return

	ctx.pop_value() // Nota(jstn): A referencia é passada além.
	ctx.runtime_assert(instance.ref_count > 0,"_new, ref_count reachs zero ? Oops it's a bug.")

	NUOOBJECT_VAL_PTR(cs.result,instance)
}






















// Nota(jstn): class general bultin



INSTANCE_MASK       :: u32(0x5A5A5A5A)


instance_get_meta   :: proc(ctx: ^Context )
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING),"'get_meta' expects %v, but got %v and must be '%v'",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	s    := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
	i    := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoInstance)

	str  := to_string(s.data)
	hash := (hash_string(str) ~ INSTANCE_MASK)
  
    ctx.runtime_error(table_instance_get(&i.fields,hash,cs.result),"invalid acess to meta '%v' on instance of '%v'.",str,class_db_get_class_name(i.cid))
}

instance_set_meta   :: proc(ctx: ^Context )
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 2 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING),"'set_meta' expects %v, but got %v and must be '%v' and 'Variant'",2,cs.argc,GET_TYPE_NAME(.STRING)) do return

	s    := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
	i    := AS_NUOOBECT_PTR(ctx.peek_value(2),NuoInstance)

	str  := to_string(s.data)
	hash := (hash_string(str) ~ INSTANCE_MASK)

	table_instance_set(&i.fields,hash,ctx.peek_value(1))
	NIL_VAL_PTR(cs.result)
}

instance_has_meta   :: proc(ctx: ^Context )
{
	cs   := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_VARIANT_PTR(ctx.peek_value(0),.STRING),"'has_meta' expects %v, but got %v and must be '%v'",1,cs.argc,GET_TYPE_NAME(.STRING)) do return

	s    := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
	i    := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoInstance)

	str  := to_string(s.data)
	hash := (hash_string(str) ~ INSTANCE_MASK)

	BOOL_VAL_PTR(cs.result,hash in &i.fields)
}


instance_call :: proc(ctx: ^Context)
{
	cs   := ctx.call_state
	argc := cs.argc

	if ctx.runtime_error(argc >= 1 ," 'call' expects over 0 arguments, but got %v and must be 'String' and 'Variant's ",argc) do return

	s    := AS_NUOOBECT_PTR(ctx.peek_value(0),NuoString)
	i    := AS_NUOOBECT_PTR(ctx.peek_value(argc),NuoInstance)

	hash := hash_string(to_string(s.data))

	t    := ctx.init_runtime_temp()
	defer   ctx.end_runtime_temp(t)

	adata := make([]Value,argc+1,ctx.get_runtime_allocator())
	ctx.copy_args(cs.args[:],adata[:],argc+1)

	defer 
	{ 
		cs.args = cs.args[0:][:0]
	  	unref_slice(adata[:]) 
	}

	what   := adata[1:argc] // args
	method : Value

	if class_db_get_method_recursively(i.cid,hash,&method,.INSTANCE) 
	{
		for &p in what { ref_value(&p); ctx.push_value(&p) }

    	this         := NUOOBJECT_VAL(i)
    	bound_method := NUOOBJECT_VAL(create_bound_method(&this,&method))

		if ctx.call(&bound_method,argc-1,0) do return

		unref_value(ctx.pop_value())
		unref_value(&bound_method)
		
		NIL_VAL_PTR(cs.result)
		return
	}

	ctx.runtime_error(false,"method '%v' not declared by '%v' Class.",to_string(s.data),class_db_get_class_name(i.cid))

}