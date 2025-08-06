package FileAcess


init :: proc(iid: int)
{
	set_iid(iid)
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
	// IMPORT_B_VALUE(iid,"",INT_VAL())
	// IMPORT_B_VALUE(iid,"",INT_VAL())
	// IMPORT_B_VALUE(iid,"",INT_VAL())
	// IMPORT_B_VALUE(iid,"",INT_VAL())
	// IMPORT_B_VALUE(iid,"",INT_VAL())
	// IMPORT_B_VALUE(iid,"",INT_VAL())
	// IMPORT_B_VALUE(iid,"TAU",FLOAT_VAL(TAU))
	// IMPORT_B_VALUE(iid,"e",FLOAT_VAL(E))
}

register_functions :: proc(iid: int)
{
	IMPORT_B_VALUE(iid,"open",open)
	IMPORT_B_VALUE(iid,"exists",exists)
	IMPORT_B_VALUE(iid,"get_absolute_path",get_absolute_path)
	IMPORT_B_VALUE(iid,"get_relative_path",get_relative_path)

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

	// IMPORT_B_VALUE(iid,"unlerp",_unlerp)
	// IMPORT_B_VALUE(iid,"smootherstep",_smootherstep)

	// IMPORT_B_VALUE(iid,"floor",_floor)
	// IMPORT_B_VALUE(iid,"round",_round)
	// IMPORT_B_VALUE(iid,"mod",_mod)

	// IMPORT_B_VALUE(iid,"remap",_remap)
	// IMPORT_B_VALUE(iid,"remap_clamped",_remap_clamped)
	// IMPORT_B_VALUE(iid,"wrap",_wrap)

	// IMPORT_B_VALUE(iid,"smoothstep",_smoothstep)
	// IMPORT_B_VALUE(iid,"hypot",_hypot)

	// // 
	// IMPORT_B_VALUE(iid,"randi",randi)
	// IMPORT_B_VALUE(iid,"randf",randf)
	// IMPORT_B_VALUE(iid,"randf_range",randf_range)
	
}
