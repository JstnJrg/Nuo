package Time


init :: proc(iid: int)
{
	_start()

	/* 
		0  - contants
		5 - methods
	*/
	import_db_reserve(iid,0+5)
	register_functions(iid)
}

register_constants :: proc(iid: int)
{
}

register_functions :: proc(iid: int)
{
	IMPORT_B_VALUE(iid,"get_tick_ms",get_tick_ms)
	IMPORT_B_VALUE(iid,"get_tick_ns",get_tick_ns)

	IMPORT_B_VALUE(iid,"get_time_from_system",get_time_from_system)
	IMPORT_B_VALUE(iid,"get_date_from_system",get_date_from_system)

	IMPORT_B_VALUE(iid,"get_precise_time_from_system",get_precise_time_from_system)
}
