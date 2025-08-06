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