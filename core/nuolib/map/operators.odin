package Map



register_operators :: proc()
{
	// register_op(.OP_EQUAL,.ARRAY,.ARRAY,array_array_equal)
	// register_op(.OP_ADD,.ARRAY,.ARRAY,array_array_add)
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



// array_array_add :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
// {
// 	array0  := AS_NUOOBECT_PTR(lhs,NuoArray)
// 	data0   := &array0.data

// 	array1  := AS_NUOOBECT_PTR(rhs,NuoArray)
// 	data1   := &array1.data

//     defer  
//     { 
//     	unref_object(array0)
//     	unref_object(array1) 
//     }

//     array2  := create_obj_array()
//     data2   := &array2.data

//     // Do novo array
//     ref_slice(data0[:])
//     ref_slice(data1[:])

//     _append(data2,data0[:])
//     _append(data2,data1[:])

//     NUOOBJECT_VAL_PTR(ret,array2)
// }


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