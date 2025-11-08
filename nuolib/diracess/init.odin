package DirAcess


init :: proc(iid: int)
{
	set_iid(iid)

	/* 
		0  - contants
		9 - methods
	*/
	import_db_reserve(iid,0+9)

	register_constants(iid)
	register_functions(iid)
}

register_constants :: proc(iid: int)
{
}

register_functions :: proc(iid: int)
{
	IMPORT_B_VALUE(iid,"open",open)
	IMPORT_B_VALUE(iid,"read_dir",read_dir)
	IMPORT_B_VALUE(iid,"copy_directory_all",copy_directory_all)
	IMPORT_B_VALUE(iid,"make_dir",make_dir)

	IMPORT_B_VALUE(iid,"make_dir_all",make_dir_all)
	IMPORT_B_VALUE(iid,"remove_all",remove_all)
	IMPORT_B_VALUE(iid,"get_working_directory",get_working_directory)
	IMPORT_B_VALUE(iid,"set_working_directory",set_working_directory)
	
	IMPORT_B_VALUE(iid,"close",close)
}
