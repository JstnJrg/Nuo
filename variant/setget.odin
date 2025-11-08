package Variant


/*
	set - Object.property = expr
		  expr Object estarão assim concretamente na pilha, então
		  Object é transformando em um bool, util para pular Values
		  que usam o buffer ou não 

*/


register_setget :: register_op

register_variant_setgets :: proc()
{
	register_setget(.OP_SET_PROPERTY,.CLASS,.SYMID,class_set)
	register_setget(.OP_GET_PROPERTY,.CLASS,.SYMID,class_get)

	register_setget(.OP_SET_PROPERTY,.INSTANCE,.SYMID,instance_set)
	register_setget(.OP_GET_PROPERTY,.INSTANCE,.SYMID,instance_get)

	register_setget(.OP_SET_PROPERTY,.IMPORT,.SYMID,import_set)
	register_setget(.OP_GET_PROPERTY,.IMPORT,.SYMID,import_get)

	// register_setget(.OP_SET_PROPERTY,.CLASS,.SYMID,class_set)
	register_setget(.OP_GET_PROPERTY,.MAP,.SYMID,map_property_get)
	register_setget(.OP_SET_PROPERTY,.MAP,.SYMID,map_property_set)

	register_setget(.OP_GET_INDEXING,.ARRAY,.INT,array_get)
	register_setget(.OP_SHIFT_RIGHT,.ARRAY,.INT,array_get)
	register_setget(.OP_SET_INDEXING,.ARRAY,.INT,array_set)


	register_setget(.OP_GET_INDEXING,.MAP,.INT,map_get)
	register_setget(.OP_GET_INDEXING,.MAP,.FLOAT,map_get)
	register_setget(.OP_GET_INDEXING,.MAP,.INSTANCE,map_get)
	register_setget(.OP_GET_INDEXING,.MAP,.ARRAY,map_get)
	register_setget(.OP_GET_INDEXING,.MAP,.CLASS,map_get)
	register_setget(.OP_GET_INDEXING,.MAP,.MAP,map_get)
	register_setget(.OP_GET_INDEXING,.MAP,.STRING,map_get)
	register_setget(.OP_GET_INDEXING,.MAP,.RANGE,map_get)
	register_setget(.OP_GET_INDEXING,.MAP,.VECTOR2,map_get)
	register_setget(.OP_GET_INDEXING,.MAP,.RECT2,map_get)
	register_setget(.OP_GET_INDEXING,.MAP,.COLOR,map_get)
	register_setget(.OP_GET_INDEXING,.MAP,.TRANSFORM2D,map_get)
	register_setget(.OP_GET_INDEXING,.MAP,.SIGNAL,map_get)


	register_setget(.OP_SET_INDEXING,.MAP,.INT,map_set)
	register_setget(.OP_SET_INDEXING,.MAP,.FLOAT,map_set)
	register_setget(.OP_SET_INDEXING,.MAP,.INSTANCE,map_set)
	register_setget(.OP_SET_INDEXING,.MAP,.ARRAY,map_set)
	register_setget(.OP_SET_INDEXING,.MAP,.CLASS,map_set)
	register_setget(.OP_SET_INDEXING,.MAP,.MAP,map_set)
	register_setget(.OP_SET_INDEXING,.MAP,.STRING,map_set)
	register_setget(.OP_SET_INDEXING,.MAP,.RANGE,map_set)
	register_setget(.OP_SET_INDEXING,.MAP,.VECTOR2,map_set)
	register_setget(.OP_SET_INDEXING,.MAP,.RECT2,map_set)
	register_setget(.OP_SET_INDEXING,.MAP,.COLOR,map_set)
	register_setget(.OP_SET_INDEXING,.MAP,.TRANSFORM2D,map_set)
	register_setget(.OP_SET_INDEXING,.MAP,.SIGNAL,map_set)

}




// OP_INHERIT,


import_set :: #force_inline proc(_import,property_sid,variant_return: ^Value, ctx: ^Context)
{
    iid    := AS_INT_PTR(_import)
	setter := import_db_get_setter(iid)
	setter(iid,property_sid,variant_return,ctx)

    // Nota(jstn): não usa o buffer, portanto pula o registro, ou seja, não será reguardado
	BOOL_VAL_PTR(_import,true)	
}

import_get :: #force_inline proc(_import,property_sid,variant_return: ^Value, ctx: ^Context)
{
	iid    := AS_INT_PTR(_import)
	getter := import_db_get_getter(iid)
	getter(iid,property_sid,variant_return,ctx)
}



class_set :: #force_inline proc(class,property_sid,ret: ^Value, ctx: ^Context)
{
	cid       := AS_INT_PTR(class)
	sid       := AS_SYMID_PTR(property_sid)
	hash      := string_db_get_hash(sid)
	csetter   := class_db_get_csetter(cid,hash)

	csetter(cid,sid,ret,ctx)

    // Nota(jstn): não usa o buffer, portanto pula o registro, ou seja, não será reguardado
	BOOL_VAL_PTR(class,true)	
}

class_get :: #force_inline proc(class,property_sid,ret: ^Value, ctx: ^Context)
{
	cid       := AS_INT_PTR(class)
	sid       := AS_SYMID_PTR(property_sid)
	hash      := string_db_get_hash(sid)
	cgetter   := class_db_get_cgetter(cid,hash)

	cgetter(cid,sid,ret,ctx)
}



instance_set :: #force_inline proc(instance,property_sid,variant_return: ^Value, ctx: ^Context)
{
	_instance := AS_NUOOBECT_PTR(instance,NuoInstance)
	sid       := AS_SYMID_PTR(property_sid)
	hash      := string_db_get_hash(sid)
	setter    := class_db_get_setter(_instance.cid,hash)

	setter(_instance,sid,variant_return,ctx)

	//a reponsabilidade de unref a instancia não é do setter 
	unref_object(_instance)

    // Nota(jstn): não usa o buffer, portanto pula o registro, ou seja, não será reguardado
	BOOL_VAL_PTR(instance,true)	
}

instance_get :: #force_inline proc(instance,property_sid,variant_return: ^Value, ctx: ^Context)
{
	_instance := AS_NUOOBECT_PTR(instance,NuoInstance)
	sid       := AS_SYMID_PTR(property_sid)
	hash      := string_db_get_hash(sid)
	getter    := class_db_get_getter(_instance.cid,hash)

	getter(_instance,sid,variant_return,ctx)

	// Nota(jstn): o variant_return aponta para mesma memoria que o object, 
	// então, ao ser atribuído, seu valor muda, perdendo assim a referencia 
	// da instancia, portanto, precisamos descontar seu rc, pois foi incrementado pelo GET
	

	//a reponsabilidade de unref a instancia não é do getter 
	unref_object(_instance)
}



map_property_set :: #force_inline proc(_map,property_sid,assign: ^Value, ctx: ^Context)
{
	map_   := AS_NUOOBECT_PTR(_map,NuoMap)
	sid    := AS_SYMID_PTR(property_sid)
	hash   := string_db_get_hash(sid)
	data   := &map_.data
	_,ok   := data[hash]

	ref_value(assign)

	if ok
	{
		me_p   := &data[hash]
		unref_value(&me_p.value)
		VARIANT2VARIANT_PTR(assign,&me_p.value)
	}
	else
	{
 		key := create_obj_string()
    	nuostring_write_data(string_db_get_string(sid),key)
		data[hash] = MapEntry{VARIANT_VAL(key),assign^}
	}


	//a reponsabilidade de unref a instancia não é do getter 
	unref_object(map_)

    // Nota(jstn): não usa o buffer, portanto pula o registro, ou seja, não será reguardado
	BOOL_VAL_PTR(_map,true)	
}

map_property_get :: #force_inline proc(_map,property_sid,variant_return: ^Value, ctx: ^Context)
{
	map_   := AS_NUOOBECT_PTR(_map,NuoMap)
	sid    := AS_SYMID_PTR(property_sid)
	hash   := string_db_get_hash(sid)
	data   := &map_.data
	me,ok  := data[hash]

	if ctx.runtime_error(ok,"invalid acess to property or key '%v' on base of '%v'.",string_db_get_string(sid),GET_VARIANT_TYPE_NAME(_map)) do return

   	VARIANT2VARIANT_PTR(&me.value,variant_return)
   	ref_value(&me.value)

	//a reponsabilidade de unref a instancia não é do getter 
	unref_object(map_)
}



array_get :: #force_inline proc(arr,index,variant_return: ^Value, ctx: ^Context)
{
	array := AS_NUOOBECT_PTR(arr,NuoArray)
	idx   := AS_INT_PTR(index)

	data  := &array.data
	len   := len(data)
    idx    = idx >= 0 ? idx: idx+len

    if ctx.runtime_error(idx >= 0 && idx < len,"%d is out of range 0..<%d on base '%v'.",idx,len,GET_VARIANT_TYPE_NAME(arr)) do return

    e := &data[idx]
   
    ref_value(e)
    unref_object(array)

    VARIANT2VARIANT_PTR(e,variant_return) 
}


array_set           :: #force_inline proc(arr,index,assign: ^Value, ctx: ^Context)
{
	array := AS_NUOOBECT_PTR(arr,NuoArray)
	idx   := AS_INT_PTR(index)

	data  := &array.data
	len   := len(data)
    idx    = idx >= 0 ? idx: idx+len

    if ctx.runtime_error(idx >= 0 && idx < len,"%d is out of range 0..<%d on base '%v'.",idx,len,GET_VARIANT_TYPE_NAME(arr)) do return

    e := &data[idx]
    
    ref_value(assign)
    unref_value(e)

    VARIANT2VARIANT_PTR(assign,e) 

    unref_object(array)
}


map_get :: #force_inline proc(_map,variant,variant_return: ^Value, ctx: ^Context)
{
	map_ := AS_NUOOBECT_PTR(_map,NuoMap)

	data  := &map_.data
	me,ok := data[variant_hash(variant)]
	
    if ctx.runtime_error(ok,"invalid acess to property on base of type '%v'.",GET_VARIANT_TYPE_NAME(_map)) do return

    value := &me.value
 
    ref_value(value)

    unref_value(variant)
    unref_object(map_)

    VARIANT2VARIANT_PTR(value,variant_return) 
}


map_set           :: #force_inline proc(_map,variant_idx,assign: ^Value, ctx: ^Context)
{
	map_  := AS_NUOOBECT_PTR(_map,NuoMap)
	hash  := variant_hash(variant_idx)
	data  := &map_.data
	me,ok := data[hash]

	// Nota(jstn): é mesma coisa que deixa-lo assim, sem qualquer alteração no rc
	// unref_value(variant_idx)
	// ref_value(variant_idx)
	
	ref_value(assign)

	if ok
	{	
		unref_value(&me.value)
		unref_value(&me.key)
	}
	else do me = MapEntry{}

	VARIANT2VARIANT_PTR(assign,&me.value)
	VARIANT2VARIANT_PTR(variant_idx,&me.key) 

	data[hash] = me
    unref_object(map_)
}