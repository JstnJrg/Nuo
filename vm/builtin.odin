#+private
package VM 


register_builtin :: proc()
{
	std_nuo()
	std_task()
}



std_nuo :: proc()
{
	iid := import_db_get_id_by_name("Nuo",.BUILTIN)
	import_db_reserve(iid,4)
	
	IMPORT_B_VALUE(iid,"print",print_value)
	IMPORT_B_VALUE(iid,"int",_int)
	IMPORT_B_VALUE(iid,"float",_float)
	IMPORT_B_VALUE(iid,"typeof",typeof)


	// 
	IMPORT_B_VALUE(iid,"TYPE_NIL",INT_VAL(int(VariantType.NIL)))
	IMPORT_B_VALUE(iid,"TYPE_BOOL",INT_VAL(int(VariantType.BOOL)))
	IMPORT_B_VALUE(iid,"TYPE_INT",INT_VAL(int(VariantType.INT)))
	IMPORT_B_VALUE(iid,"TYPE_FLOAT",INT_VAL(int(VariantType.FLOAT)))

	IMPORT_B_VALUE(iid,"TYPE_STRING",INT_VAL(int(VariantType.STRING)))
	IMPORT_B_VALUE(iid,"TYPE_ARRAY",INT_VAL(int(VariantType.ARRAY)))
	IMPORT_B_VALUE(iid,"TYPE_TRANSFORM2D",INT_VAL(int(VariantType.TRANSFORM2D)))
	IMPORT_B_VALUE(iid,"TYPE_VECTOR2",INT_VAL(int(VariantType.VECTOR2)))

	IMPORT_B_VALUE(iid,"TYPE_RECT2",INT_VAL(int(VariantType.RECT2)))
	IMPORT_B_VALUE(iid,"TYPE_COLOR",INT_VAL(int(VariantType.COLOR)))

	IMPORT_B_VALUE(iid,"TYPE_OFUNCTION",INT_VAL(int(VariantType.OFUNCTION)))
	IMPORT_B_VALUE(iid,"TYPE_NFUNCTION",INT_VAL(int(VariantType.NFUNCTION)))

	IMPORT_B_VALUE(iid,"TYPE_INSTANCE",INT_VAL(int(VariantType.INSTANCE)))
	IMPORT_B_VALUE(iid,"TYPE_CLASS",INT_VAL(int(VariantType.CLASS)))
	IMPORT_B_VALUE(iid,"TYPE_IMPORT",INT_VAL(int(VariantType.IMPORT)))
}



print_value :: proc(ctx: ^Context)
{
	cs   := ctx.call_state
	argc := cs.argc

	if ctx.runtime_error(argc != 0,"'print' expects arguments.") do return	

	print_values(cs.args[0:][:argc])	
	
	NIL_VAR_PTR(cs.result)
}

typeof :: proc(ctx: ^Context)
{
	cs   := ctx.call_state
	argc := cs.argc

	if ctx.runtime_error(argc == 1,"'typeof' expects %v, but got %v.",1,argc) do return	
	INT_VAL_PTR(cs.result,Int(GET_TYPE(ctx.peek_value(0))))
}


_int :: proc(ctx: ^Context)
{
	cs   := ctx.call_state
	argc := cs.argc
	int_ : Int

	if ctx.runtime_error(argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&int_),"'int' expects %v, but got %v and must be a 'number'.",1,argc) do return	
	INT_VAL_PTR(cs.result,int_)
}

_float :: proc(ctx: ^Context)
{
	cs     := ctx.call_state
	argc   := cs.argc
	float_ : f32

	if ctx.runtime_error(argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&float_),"'float' expects %v, but got %v and must be a 'number'.",1,argc) do return	
	FLOAT_VAL_PTR(cs.result,f32(float_))
}