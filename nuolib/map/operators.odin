package Map



register_operators :: proc()
{
	// register_op(.OP_EQUAL,.ARRAY,.ARRAY,array_array_equal)
	register_op(.OP_ADD,.MAP,.MAP,map_map_add)
	// register_setget(.OP_GET_PROPERTY,.VECTOR2,.SYMID,vec2_get)
	// register_setget(.OP_SET_PROPERTY,.VECTOR2,.SYMID,vec2_set)
}

register_properties :: proc(cid: int)
{
	// class_register_static_property(cid,"LEN",static_default_setter,static_default_getter)
	// class_register_static_property(cid,"FLIP_X",static_default_setter,static_default_getter)
	// class_register_static_property(cid,"FLIP_Y",static_default_setter,static_default_getter)
}







// static_default_setter :: proc(cid, sid: int, ret: ^Value, ctx: ^Context) { ctx.runtime_error(false,"cannot assign a new value to a constant.") }

// static_default_getter :: proc(cid, sid: int, ret: ^Value, ctx: ^Context) { }



map_map_add :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
{
	_map1   := AS_NUOOBECT_PTR(lhs,NuoMap)
	data_m1 := &_map1.data

	_map2   := AS_NUOOBECT_PTR(rhs,NuoMap)
	data_m2 := &_map2.data

    defer { unref_object(_map1); unref_object(_map2) }

    _map    := create_obj_map()
    data_m3 := &_map.data

    for key, &me in data_m1
    {
    	ref_value(&me.value)
    	ref_value(&me.key)
    	data_m3[key] = me
    }
    
    for key, &me in data_m2
    {
		if key in data_m3 
		{ 
			_me := &data_m3[key]
			unref_value(&_me.key)
			unref_value(&_me.value) 
		}

    	ref_value(&me.value)
    	ref_value(&me.key)
    	data_m3[key] = me
    }

    NUOOBJECT_VAL_PTR(ret,_map)
}


// array_array_equal :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
// {
// 	array0  := AS_NUOOBECT_PTR(lhs,NuoArray)
// 	data0   := &array0.data

// 	array1  := AS_NUOOBECT_PTR(rhs,NuoArray)
// 	data1   := &array1.data

// 	defer if ctx.gc_allowed 
// 	{ 
// 		unref_object(array0)
// 		unref_object(array1) 
// 	}

//     if array0     == array1     { BOOL_VAL_PTR(ret,true); return }
//     if len(data0) != len(data1) { BOOL_VAL_PTR(ret,false); return }

//     BOOL_VAL_PTR(ret,variant_hash_compare(lhs,rhs,0))
// }