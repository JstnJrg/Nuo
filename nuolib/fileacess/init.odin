package FileAcess


init :: proc(iid: int)
{
	set_iid(iid)

	/* 
		9  - contants
		22 - methods
	*/
	import_db_reserve(iid,9+22)

	register_constants(iid)
	register_functions(iid)
}

register_constants :: proc(iid: int)
{
	IMPORT_B_VALUE(iid,"READ",INT_VAL(RDONLY))
	IMPORT_B_VALUE(iid,"WRITE",INT_VAL(WRONLY))
	IMPORT_B_VALUE(iid,"READ_WRITE",INT_VAL(RDWR))
	IMPORT_B_VALUE(iid,"APPEND",INT_VAL(APPEND))
	IMPORT_B_VALUE(iid,"CREATE",INT_VAL(CREATE))
	IMPORT_B_VALUE(iid,"EXCL",INT_VAL(EXCL))
	IMPORT_B_VALUE(iid,"SYNC",INT_VAL(SYNC))
	IMPORT_B_VALUE(iid,"TRUNC",INT_VAL(TRUNC))
	IMPORT_B_VALUE(iid,"SPARSE",INT_VAL(SPARSE))
}

register_functions :: proc(iid: int)
{
	IMPORT_B_VALUE(iid,"open",open)

	IMPORT_B_VALUE(iid,"stdin",_stdin)
	IMPORT_B_VALUE(iid,"stdout",_stdout)


	IMPORT_B_VALUE(iid,"exists",exists)
	IMPORT_B_VALUE(iid,"get_absolute_path",get_absolute_path)
	IMPORT_B_VALUE(iid,"get_relative_path",get_relative_path)

	IMPORT_B_VALUE(iid,"clean_path",clean_path)
	IMPORT_B_VALUE(iid,"is_absolute_path",is_absolute_path)

	IMPORT_B_VALUE(iid,"link",link)
	IMPORT_B_VALUE(iid,"symlink",symlink)
	IMPORT_B_VALUE(iid,"name",name)
	IMPORT_B_VALUE(iid,"write",write)
	
	IMPORT_B_VALUE(iid,"write_at",write_at)
	IMPORT_B_VALUE(iid,"read",read)
	IMPORT_B_VALUE(iid,"read_at",read_at)
	IMPORT_B_VALUE(iid,"flush",flush)

	IMPORT_B_VALUE(iid,"sync",sync)
	IMPORT_B_VALUE(iid,"remove",remove)
	IMPORT_B_VALUE(iid,"rename",rename)
	IMPORT_B_VALUE(iid,"close",close)

	IMPORT_B_VALUE(iid,"is_open",is_open)
	IMPORT_B_VALUE(iid,"copy",copy)
	IMPORT_B_VALUE(iid,"is_file",is_file)
	IMPORT_B_VALUE(iid,"is_dir",is_dir)
}
