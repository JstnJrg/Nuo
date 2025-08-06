package Variant


init_context :: proc(ctx: ^Context)
{
	init_context_internal(ctx)
	init_db()

	// 
	register_variant_operators()
	register_variant_constructors()
	register_variant_setgets()
	register_nuo_dependencies()
}

register_nuo_dependencies :: proc()
{
	// Nota(jstn): tabela primaria de globais 
	register_import(NUO_IMPORT_NAME,.NUO,error_import_setter)
	

	// 
	register_import("Nuo",.BUILTIN,error_import_setter)


	//Modules
	register_import("Math",.IMPORT,error_import_setter,default_import_getter)
	register_import("Time",.IMPORT,error_import_setter,default_import_getter)
	register_import("FileAcess",.IMPORT,error_import_setter,default_import_getter)


	// classes
	class_db_register_class(GET_TYPE_NAME(.VECTOR2),    -1,.ATOMIC,class_db_error_creator)
	class_db_register_class(GET_TYPE_NAME(.RECT2),      -1,.ATOMIC,class_db_error_creator)
	class_db_register_class(GET_TYPE_NAME(.COLOR),      -1,.ATOMIC,class_db_error_creator)
	class_db_register_class(GET_TYPE_NAME(.ARRAY),      -1,.ATOMIC,class_db_error_creator)
	class_db_register_class(GET_TYPE_NAME(.MAP),        -1,.ATOMIC,class_db_error_creator)
	class_db_register_class(GET_TYPE_NAME(.RANGE),      -1,.ATOMIC,class_db_error_creator)
	class_db_register_class(GET_TYPE_NAME(.STRING),     -1,.ATOMIC,class_db_error_creator)
	class_db_register_class(GET_TYPE_NAME(.TRANSFORM2D),-1,.ATOMIC,class_db_error_creator)
	class_db_register_class(GET_TYPE_NAME(.SIGNAL),     -1,.ATOMIC,class_db_error_creator)

	when NUO_DEBUG do VARIANNT_DEBUG()
}


