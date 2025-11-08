package Variant


init_context :: proc(ctx: ^Context)
{
	#assert(size_of(SafeMethod) == size_of(Buffer)," SafeMethod != Buffer condition is true.")


	init_context_internal(ctx)
	init_db()
	gc_create()

	// 
	register_variant_operators()
	register_variant_constructors()
	register_variant_setgets()
	register_nuo_dependencies()

	when NUO_DEBUG do tests()
}


register_nuo_dependencies :: proc()
{
	// Nota(jstn): tabela primaria de globais 
	register_import(NUO_IMPORT_NAME,.NUO,error_import_setter)
	register_import("Nuo",.BUILTIN,error_import_setter)
}


