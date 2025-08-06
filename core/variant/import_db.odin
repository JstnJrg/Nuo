package Variant

ImportInfo  :: struct 
{	
	globals       : Table,        // metodos que requerem o esse contexto
	setter        : ImportSetter, //TODO
	getter        : ImportGetter, //TODO

	id            : int,
	sid           : int,
	api           : ImportApi 
}


ImportManager :: struct
{
	import_array : [dynamic]^ImportInfo,
	import_mapa  : map[string]int     
}

ImportApi  :: enum u8
{
	NONE,    //default, simboliza err
	IMPORT,  // requerem importação
	BUILTIN, // não requerem importação
	NUO      // é a tabela de gloabis da VM, não podem ser importado
}



ImportSetter :: #type proc( id : int, property,variant_return: ^Value,ctx: ^Context)
ImportGetter :: #type proc( id : int, property,variant_return: ^Value,ctx: ^Context)


register_import :: proc(name: string, api : ImportApi , setter : ImportSetter = default_import_setter , getter : ImportGetter = default_import_getter) -> int
{
	ctx_allocator := get_context_allocator()
	iid           := db_get_import_iinfo_id()
	
	iinfo        := new(ImportInfo,ctx_allocator)
	
	iinfo.id      = iid
	iinfo.api     = api
	iinfo.setter  = setter
	iinfo.getter  = getter
	iinfo.sid     = string_db_register_string(name)
	iinfo.globals = make(Table,ctx_allocator)

	db_register_import_info(iinfo)

	return iid
}


import_db_is_valid_id    :: proc "contextless" (iid: int) -> bool { return iid >= 0 && iid < db_get_import_iinfo_id() }

import_db_get_iinfo      :: proc "contextless" (iid: int) -> ^ImportInfo { return db_get_import_array()[iid] }

import_db_get_globals    :: proc "contextless" (iid: int) -> ^Table { return &import_db_get_iinfo(iid).globals }

import_db_name           :: proc "contextless" (iid: int) -> string { return string_db_get_string(import_db_get_iinfo(iid).sid) }

import_db_hash           :: proc "contextless" (iid: int) -> u32 { return string_db_get_hash(import_db_get_iinfo(iid).sid) }

import_db_get_id_by_name :: proc "contextless" (iname: string, api : ImportApi) -> int 
{ 
	iid, has := db_get_import_mapa()[iname]
	if has && import_db_check_api(iid,api) do return iid
	return -1 
}

import_db_get_api_by_name :: proc "contextless" (iname: string) -> ImportApi
{ 
	iid, has := db_get_import_mapa()[iname]
	if has do return import_db_get_iinfo(iid).api
	return .NONE
}

import_db_check_api :: proc "contextless" (iid: int, api: ImportApi) -> bool { return import_db_get_iinfo(iid).api == api }
import_db_get_api   :: proc "contextless" (iid: int) -> ImportApi { return import_db_get_iinfo(iid).api }

import_db_get_iinfo_name :: proc "contextless" (iname: string, api : ImportApi) -> ^ImportInfo { return import_db_get_iinfo(import_db_get_id_by_name(iname,api)) }

import_db_get_setter     :: proc "contextless" (iid: int) -> ImportSetter { return import_db_get_iinfo(iid).setter }

import_db_get_getter      :: proc "contextless" (iid: int) -> ImportGetter { return import_db_get_iinfo(iid).getter }

import_db_register_setter :: proc "contextless" (iid: int, setter: ImportSetter) { iinfo := import_db_get_iinfo(iid); iinfo.setter = setter }

import_db_register_getter :: proc "contextless" (iid: int, getter: ImportGetter) { iinfo := import_db_get_iinfo(iid); iinfo.getter = getter }


import_db_get_value       :: proc "contextless" (iid: int,name: string) -> (Value,bool)
{
	value : Value
	ok    := table_get_ptr(import_db_get_globals(iid),hash_string(name),&value)
	return value,ok
}

import_db_initialize_value :: proc "contextless" (iid: int,name: string) { table_set_value(import_db_get_globals(iid),hash_string(name),NIL_VAL()) }

import_get_import_names    :: proc(iid: int ,callable : proc(iid,_iid: int,iname: string)) { for i in 0..< db_get_import_iinfo_id() do callable(iid,i,import_db_name(i)) } 

import_get_import_hashes   :: proc(iid: int ,callable : proc(iid,_iid: int,ihash: u32))    { for i in 0..< db_get_import_iinfo_id() do callable(iid,i,import_db_hash(i)) } 


// Registra as classes e Import na tabela de globais
import_db_register_all_db :: proc(iid: int)
{
	register_classes :: proc(iid: int,cid: int, hash: u32) { table_set_value(import_db_get_globals(iid),hash,CLASS_VAL(cid)) }
	register_imports :: proc(iid: int, _iid:int , hash: u32)    { if import_db_check_api(_iid,.BUILTIN) do table_set_value(import_db_get_globals(iid),hash,IMPORT_VAL(_iid)) }

	import_get_import_hashes(iid,register_imports)
	class_db_get_classes_hashes(iid,register_classes)
}




















































