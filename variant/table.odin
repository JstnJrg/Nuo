package Variant

Table        :: map[u32]Value
MethodsTable :: map[u32]MethodInfo


table_set_value :: #force_inline proc "contextless" (t: ^Table, hash: u32 ,value: Value) -> (sucess: bool) 
{
	sucess  = hash in t
	t[hash] = value
	return 
}

table_get_ptr :: #force_inline proc "contextless" (t: ^Table, hash: u32 ,value: ^Value) -> (sucess := true) 
{
	( hash in t ) or_return
	VARIANT2VARIANT_PTR(&t[hash],value)
	return 
}

method_table_set_info :: #force_inline proc "contextless" (t: ^MethodsTable, hash: u32 ,mi : ^MethodInfo) -> (sucess: bool) 
{
	sucess      = hash in t
	t[hash]     = mi^
	return 
}

method_table_get_ptr :: #force_inline proc "contextless" (t: ^MethodsTable, hash: u32 ,value: ^Value, mtype : MethodType) -> (sucess := true) 
{
	( hash in t ) or_return

	mi      := &t[hash]
	(mi.type == mtype ) or_return

	VARIANT2VARIANT_PTR(&mi.callable,value)
	return 
}


/*
	IMPORT

*/
table_import_get  :: table_get_ptr


/* 
		INSTANCE
		set - os fields são criados em tempo de compilação, então não devolve nenhum bool 
*/
table_instance_set :: #force_inline proc (t: ^Table, hash : u32 ,value: ^Value) 
{
	if hash in t do unref_value(&t[hash])
	
	ref_value(value)
	t[hash] = value^
}

table_instance_get :: #force_inline proc (t: ^Table, hash : u32 ,value: ^Value) -> (sucess := true)
{
	( hash in t ) or_return

	t_value := &t[hash]
	VARIANT2VARIANT_PTR(t_value,value)
	ref_value(value)

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
		exposed = pvalue.type in v
		sucess  = true
		unref_value(pvalue)
	}
	
	ref_value(value)
	t[hash] = value^
	return 
}

table_iimport_get :: #force_inline proc (iid: int , hash : u32 ,value: ^Value,v: ^Visibility) -> (sucess,exposed : bool)
{
	t     := import_db_get_globals(iid)
	(hash in t ) or_return

	t_value := &t[hash]

	exposed  = t_value.type in v
	sucess   = true

	VARIANT2VARIANT_PTR(t_value,value)
	ref_value(value)

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





