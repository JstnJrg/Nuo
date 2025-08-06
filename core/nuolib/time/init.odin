package Time


init :: proc(iid: int)
{
	_start()
	// register_constants(iid)
	register_functions(iid)
}

register_constants :: proc(iid: int)
{
	// IMPORT_B_VALUE(iid,"PI",FLOAT_VAL(PI))
	// IMPORT_B_VALUE(iid,"TAU",FLOAT_VAL(TAU))
	// IMPORT_B_VALUE(iid,"e",FLOAT_VAL(E))
}

register_functions :: proc(iid: int)
{
	IMPORT_B_VALUE(iid,"get_tick_ms",get_tick_ms)
	IMPORT_B_VALUE(iid,"get_tick_ns",get_tick_ns)
	// IMPORT_B_VALUE(iid,"rad2deg",rad2deg)
	// IMPORT_B_VALUE(iid,"min",_min)
	// IMPORT_B_VALUE(iid,"max",_max)

	// IMPORT_B_VALUE(iid,"abs",_abs)
	// IMPORT_B_VALUE(iid,"sign",_sign)
	// IMPORT_B_VALUE(iid,"sqrt",_sqrt)

	// IMPORT_B_VALUE(iid,"acos",_acos)
	// IMPORT_B_VALUE(iid,"asin",_asin)
	// IMPORT_B_VALUE(iid,"atan",_atan)

	// IMPORT_B_VALUE(iid,"cos",_cos)
	// IMPORT_B_VALUE(iid,"sin",_sin)
	// IMPORT_B_VALUE(iid,"tan",_tan)
	// IMPORT_B_VALUE(iid,"atan2",_atan2)

	// IMPORT_B_VALUE(iid,"ln",_ln)
	// IMPORT_B_VALUE(iid,"pow",_pow)

	// IMPORT_B_VALUE(iid,"log",_log)
	// IMPORT_B_VALUE(iid,"exp",_exp)
	// IMPORT_B_VALUE(iid,"clamp",_clamp)

	// IMPORT_B_VALUE(iid,"lerp",_lerp)
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
