package Variant

Table        :: map[u32]Value
MethodsTable :: map[u32]MethodInfo


table_set_value :: #force_inline proc "contextless" (t: ^Table, hash: u32 ,value: Value) -> (sucess: bool) 
{
	sucess  = hash in t
	t[hash] = value
	return 
}

table_get_ptr :: #force_inline proc "contextless" (t: ^Table, hash: u32 ,value: ^Value) -> (sucess: bool) 
{
	sucess  = hash in t 
	sucess  or_return

	VARIANT2VARIANT_PTR(&t[hash],value)
	return 
}

method_table_set_info :: #force_inline proc "contextless" (t: ^MethodsTable, hash: u32 ,mi : ^MethodInfo) -> (sucess: bool) 
{
	sucess = hash in t
	t[hash]     = mi^
	return 
}

method_table_get_ptr :: #force_inline proc "contextless" (t: ^MethodsTable, hash: u32 ,value: ^Value, mtype : MethodType) -> (sucess: bool) 
{
	sucess  = hash in t 
	sucess  or_return

	mi      := &t[hash]
	sucess   = (mi.type == mtype )

	VARIANT2VARIANT_PTR(&mi.callable,value)

	return 
}


/*
	IMPORT

*/
table_import_get  :: table_get_ptr


IMPORT_B_VALUE :: proc{IB_METHOD_0,IB_METHOD_1,IB_VALUE_0,IB_VALUE_1}
IB_METHOD_0     :: #force_inline proc "contextless" (iid: int , m_name: string ,method : Ofunction) { t := import_db_get_globals(iid); t[hash_string(m_name)] = ODINFUNCTION_VAL(method) }
IB_METHOD_1     :: #force_inline proc "contextless" (iid: int , m_hash: u32 ,method : Ofunction)    { t := import_db_get_globals(iid); t[m_hash] = ODINFUNCTION_VAL(method) }
IB_VALUE_0      :: #force_inline proc "contextless" (iid: int , _name: string ,value : Value)       { t := import_db_get_globals(iid); t[hash_string(_name)] = value }
IB_VALUE_1      :: #force_inline proc "contextless" (iid: int , _hash: u32 ,value : Value)          { t := import_db_get_globals(iid); t[_hash] = value }



CLASS_B_METHOD   :: proc{CB_METHOD_0,CB_METHOD_1}
CB_METHOD_0 :: #force_inline proc (cid: int , m_name: string ,method : Ofunction, mtype : MethodType) { class_db_register_class_method(cid,m_name,ODINFUNCTION_VAL(method),mtype) }
CB_METHOD_1 :: #force_inline proc (cid: int , m_hash: u32 ,method : Ofunction,mtype : MethodType)     { class_db_register_class_method_hash(cid,m_hash,ODINFUNCTION_VAL(method),mtype) }



/* 
		INSTANCE
		set - os fields são criados dinamicamente, então não devolve nenhum bool 
*/
table_instance_set :: #force_inline proc (t: ^Table, hash : u32 ,value: ^Value) 
{
	if hash in t do unref_value(&t[hash])
	
	ref_value(value)
	t[hash] = value^
}

table_instance_get :: #force_inline proc (t: ^Table, hash : u32 ,value: ^Value) -> (sucess: bool)
{
	sucess = hash in t
	if sucess
	{
		t_value := &t[hash]
		VARIANT2VARIANT_PTR(t_value,value)
		ref_value(value)
	}

	return 
}


/* 
		IMPORT 
*/


table_iimport_set :: #force_inline proc (iid: int, hash : u32 ,value: ^Value, v: ^Visibility) -> (sucess, exposed: bool)
{
	t := import_db_get_globals(iid)

	if hash in t
	{
		pvalue := &t[hash]

		sucess  = true
		exposed = pvalue.type in v

		unref_value(pvalue)
	}
	
	ref_value(value)
	t[hash] = value^
	return 
}

table_iimport_get :: #force_inline proc (iid: int , hash : u32 ,value: ^Value,v: ^Visibility) -> (sucess,exposed: bool)
{
	t := import_db_get_globals(iid)
	sucess = hash in t

	if sucess
	{
		t_value := &t[hash]
		exposed  = t_value.type in v

		VARIANT2VARIANT_PTR(t_value,value)
		ref_value(value)
	}

	return 
}




/* 
		VM
		get - presume que o valor já está na table, isso é garantido pelo compilador, caso pretenda usar,
		implemente uma função semelhante.
*/
table_set :: #force_inline proc (t: ^Table, hash: u32 ,from: ^Value) -> (sucess: bool) 
{
	sucess  = hash in t

	if sucess do unref_value(&t[hash])
	ref_value(from)

	t[hash] = from^

	return 
}

table_get :: #force_inline proc (t: ^Table, hash: u32, to : ^Value) -> (sucess: bool) 
{
	sucess  = hash in t 
	from    := &t[hash]
	
	ref_value(from)
	VARIANT2VARIANT_PTR(from,to)
	
	return
}





