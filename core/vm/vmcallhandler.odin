#+private

package VM

call_dispatch   : [VariantType]CallData 

HandleType  :: #type proc(argc: int)
CallType    :: #type proc(argc : int, dargc := 0)


/*
	Noat(jstn): callee - diz respeito a bytecode do tipo OP_CALL, ou seja para chamadas directas
				hanlde - é para acesso a metodos ou funções a objecto que encapsulam-nos. util para
				devidos tratamentos. 
*/

CallData :: struct 
{
	callee    : CallType,
	handle    : HandleType,
	_id       : int //Nota(jstn): para nativos (e.g: string, color etc.)
}


register_call_data :: proc()
{
	handle_types()
	call_types()
	classe_id_types()
	import_id_types()
	fallbacks()
}

call_types :: proc()
{
	register_call_type(.NFUNCTION,call_nfunction)
	register_call_type(.OFUNCTION,call_ofunction)
}

handle_types :: proc()
{
	// Nota(jstn): atomicos
	// register_handle_type(.OBJ_ANY,    any_handle_type)
	register_handle_type(.VECTOR2,atomic_handle)
	register_handle_type(.ARRAY,atomic_handle)
	register_handle_type(.MAP,atomic_handle)
	register_handle_type(.STRING, atomic_handle)
	register_handle_type(.RECT2,  atomic_handle)
	register_handle_type(.COLOR,  atomic_handle)
	register_handle_type(.TRANSFORM2D,  atomic_handle)
	register_handle_type(.RANGE, atomic_handle)
	register_handle_type(.SIGNAL,atomic_handle)

	register_handle_type(.ANY,any_handle)

	// register_handle_type(.COLOR_VAL,  atomic_handle_type)
	// register_handle_type(.OBJ_ARRAY,  atomic_handle_type)
	// register_handle_type(.OBJ_TRANSFORM2, atomic_handle_type)
	// register_handle_type(.RECT2_VAL, atomic_handle_type)

	register_handle_type(.CLASS,class_handle)
	register_handle_type(.INSTANCE,class_instance_handle)
	register_handle_type(.IMPORT,import_handle)

	// register_handle_type(.OBJ_PACKAGE,import_handle_type)
	// register_handle_type(.OBJ_NATIVE_CLASS,import_handle_type)
}

import_id_types :: proc() 
{
	// register_type_class(.VECTOR2,class_db_get_id_by_name(GET_TYPE_NAME(.VECTOR2)))
	// register_type_class(.ARRAY,class_db_get_id_by_name(GET_TYPE_NAME(.ARRAY)))

	// register_type_import(.OBJ_STRING,     get_import_ID_by_name_importID(TYPE_TO_STRING(.OBJ_STRING),     .INTRINSICS))
	// register_type_import(.VECTOR2_VAL,    get_import_ID_by_name_importID(TYPE_TO_STRING(.VECTOR2_VAL),    .INTRINSICS))
	// register_type_import(.RECT2_VAL,      get_import_ID_by_name_importID(TYPE_TO_STRING(.RECT2_VAL),      .INTRINSICS))
	// register_type_import(.COLOR_VAL,      get_import_ID_by_name_importID(TYPE_TO_STRING(.COLOR_VAL),      .INTRINSICS))
	// register_type_import(.OBJ_ARRAY,      get_import_ID_by_name_importID(TYPE_TO_STRING(.OBJ_ARRAY),      .INTRINSICS))
	// register_type_import(.OBJ_TRANSFORM2, get_import_ID_by_name_importID(TYPE_TO_STRING(.OBJ_TRANSFORM2), .INTRINSICS))
}


classe_id_types :: proc() 
{
	register_type_class(.VECTOR2,class_db_get_id_by_name(GET_TYPE_NAME(.VECTOR2)))
	register_type_class(.RECT2,  class_db_get_id_by_name(GET_TYPE_NAME(.RECT2)))
	register_type_class(.COLOR,  class_db_get_id_by_name(GET_TYPE_NAME(.COLOR)))
	register_type_class(.ARRAY,  class_db_get_id_by_name(GET_TYPE_NAME(.ARRAY)))
	register_type_class(.MAP,  class_db_get_id_by_name(GET_TYPE_NAME(.MAP)))
	register_type_class(.STRING, class_db_get_id_by_name(GET_TYPE_NAME(.STRING)))
	register_type_class(.TRANSFORM2D, class_db_get_id_by_name(GET_TYPE_NAME(.TRANSFORM2D)))
	register_type_class(.RANGE,       class_db_get_id_by_name(GET_TYPE_NAME(.RANGE)))
	register_type_class(.SIGNAL,      class_db_get_id_by_name(GET_TYPE_NAME(.SIGNAL)))

	// register_type_import(.OBJ_STRING,     get_import_ID_by_name_importID(TYPE_TO_STRING(.OBJ_STRING),     .INTRINSICS))
	// register_type_import(.VECTOR2_VAL,    get_import_ID_by_name_importID(TYPE_TO_STRING(.VECTOR2_VAL),    .INTRINSICS))
	// register_type_import(.RECT2_VAL,      get_import_ID_by_name_importID(TYPE_TO_STRING(.RECT2_VAL),      .INTRINSICS))
	// register_type_import(.COLOR_VAL,      get_import_ID_by_name_importID(TYPE_TO_STRING(.COLOR_VAL),      .INTRINSICS))
	// register_type_import(.OBJ_ARRAY,      get_import_ID_by_name_importID(TYPE_TO_STRING(.OBJ_ARRAY),      .INTRINSICS))
	// register_type_import(.OBJ_TRANSFORM2, get_import_ID_by_name_importID(TYPE_TO_STRING(.OBJ_TRANSFORM2), .INTRINSICS))
}



fallbacks :: proc()
{
	for &value in call_dispatch
	{
		if value.callee == nil do value.callee = call_fallback
		if value.handle == nil do value.handle = fallback_handle
	}
}



// register_foreign_call_types :: proc() 
// {
// 	register_foreign_call_type(.OBJ_FUNCTION,oscript_call_function)
// 	// register_call_type(.NATIVE_OP_FUNC_VAL,call_native_function)
// }



// // ============================================================================


register_handle_type      :: proc "contextless" (type: VariantType, handle: HandleType)  { call_dispatch[type].handle = handle }
register_call_type        :: proc "contextless" (type: VariantType, fn: CallType )       { call_dispatch[type].callee = fn     }
register_type_import      :: proc "contextless" (type: VariantType, iid : int )          { call_dispatch[type]._id = iid       } 

register_type_class       :: proc "contextless" (type: VariantType, cid : int )          { call_dispatch[type]._id = cid       } 
 

// Nota(jstn): registra uma função com base no tipo, para tipos objectos chamados fora do oscript
// register_foreign_call_type  :: proc "contextless" (obj_type: VariantType, function: call_type){ call_dispatch[obj_type].cforeign = function } 



// // =================================================================================

// Nota(jstn): registra uma função com base no tipo, para tipos objectos
// Nota(jstn): obtem a função com base no tipo
get_call_type             :: #force_inline proc "contextless" (value: ^Value)     -> CallType { return call_dispatch[value.type].callee  }
// get_foreign_call_type_ptr :: #force_inline proc "contextless" (value: ^Value)     -> CallType { return call_dispatch[value.type].cforeign}
get_call_type_by_type     :: #force_inline proc "contextless" (type: VariantType) -> CallType { return call_dispatch[type].callee }


get_handle                :: #force_inline proc "contextless" (value: ^Value)     -> HandleType { return call_dispatch[value.type].handle }
get_handle_type_by_type   :: #force_inline proc "contextless" (type: VariantType) -> HandleType { return call_dispatch[type].handle }
get_import_id             :: #force_inline proc "contextless" (type: VariantType) -> int        { return call_dispatch[type]._id }
get_class_id              :: #force_inline proc "contextless" (type: VariantType) -> int        { return call_dispatch[type]._id }












// ======================================= handlers =======================================


fallback_handle :: #force_inline proc(argc: int) { cond_report_error(false,"invalid handle") }




// Nota(jstn): handler para instancia de classes
@(optimization_mode = "favor_size")
atomic_handle :: #force_inline proc(argc: int) 
{
	sid         := read_index()
	method_hash := string_db_get_hash(sid)
	type        := peek(0).type
	cid         := get_class_id(type)

	nuo_assert(cid >= 0,"Oops! it's a bug. please registe the _id. .")

	method      :  Value
	method_ptr  := &method


	if class_db_get_method(cid,method_hash,method_ptr,.INTRINSICS)
	{
	    callee := get_call_type(method_ptr) 
	    push(method_ptr)
		callee(argc)
		return
	}

	cond_report_error(false,"method '%v' not declared in base of '%v'.",string_db_get_string(sid),GET_TYPE_NAME(type))
}


// Nota(jstn): handler any
@(optimization_mode = "favor_size")
any_handle :: #force_inline proc(argc: int) 
{
	sid         := read_index()
	method_hash := string_db_get_hash(sid)
	_any        := AS_NUOOBECT_PTR(peek(0),Any)
	_id         := _any.id

	nuo_assert(_id >= 0,"Oops! it's a bug. please registe the _id. .")

	method      :  Value
	method_ptr  := &method

	#partial switch _any.etype
	{
		case        : cond_report_error(false,"Oops! any is just for import."); return
		
		case .IMPORT: 

			if table_import_get(import_db_get_globals(_id),method_hash,method_ptr) 
			{
			    callee := get_call_type(method_ptr) 
			    push(method_ptr)
				callee(argc)
				return
			}		

	}

	cond_report_error(false,"method '%v' not declared in <Reference#%p>.",string_db_get_string(sid),_any)
}


// Nota(jstn): handler para instancia de classes
@(optimization_mode = "favor_size")
class_instance_handle :: #force_inline proc(argc: int) 
{
	sid         := read_index()
	method_hash := string_db_get_hash(sid)

	instance    := AS_NUOOBECT_PTR(peek(0),NuoInstance)
	method      :  Value
	method_ptr  := &method

	// // Nota(jstn): não chamamos metodos armazenados em propriedades, pois é problematico
	// // Nota(jstn): pode se dar ao caso de uma variavel possuir um metodo,
	// // ou seja, lhe ser atribuída um função, então procuramos nela
	// // TODO: atribuir um metodo a uma variavel é problematico sem closure
	// // implementar mais tarde closure

	if class_db_get_method_recursively(instance.cid,method_hash,method_ptr,.INSTANCE) 
	{
	    callee := get_call_type(method_ptr) 
	    push(method_ptr)
		callee(argc,1)
		
		return
	}

	cond_report_error(false,"method '%v' not declared by '%v' Class.",string_db_get_string(sid),class_db_get_class_name(instance.cid))
}

@(optimization_mode = "favor_size")
import_handle :: #force_inline proc(argc: int) 
{
	sid         := read_index()
	method_hash := string_db_get_hash(sid)
	iid         := AS_INT_PTR(peek(0))

	method      :  Value
	method_ptr  := &method

	// // Nota(jstn): não chamamos metodos armazenados em propriedades, pois é problematico
	// // Nota(jstn): pode se dar ao caso de uma variavel possuir um metodo,
	// // ou seja, lhe ser atribuída um função, então procuramos nela
	// // TODO: atribuir um metodo a uma variavel é problematico sem closure
	// // implementar mais tarde closure


	if table_import_get(import_db_get_globals(iid),method_hash,method_ptr) 
	{
	    callee := get_call_type(method_ptr) 
	    push(method_ptr)
		callee(argc)

		// IMPORT_VAL_PTR
	    // NUOOBJECT_VAL_PTR(peek_c(),instance)
		// push_e()
		return
	}

	cond_report_error(false,"method '%v' not declared by '%v'.",string_db_get_string(sid),import_db_name(iid))
}


@(optimization_mode = "favor_size")
class_handle :: #force_inline proc(argc: int) 
{
	sid         := read_index()
	method_hash := string_db_get_hash(sid)
	cid         := AS_INT_PTR(peek(0))

	method      :  Value
	method_ptr  := &method

	if class_db_get_method_recursively(cid,method_hash,method_ptr,.STATIC) 
	{
	    callee := get_call_type(method_ptr) 
	    push(method_ptr)
		callee(argc,1)
		
		return
	}

	cond_report_error(false,"method '%v' not declared by '%v' Class.",string_db_get_string(sid),class_db_get_class_name(cid))
}


// // Nota(jstn): handler para pacotes ou imports, são metodos estaticos
// @(optimization_mode = "favor_size")
// import_handle_type :: #force_inline proc(#any_int argc: Int,has_error_p: ^bool) 
// {
// 	sym_indx        := read_byte()
// 	hash            := get_symbol_hash_BD(sym_indx)
	
// 	import_id 		:= AS_IMPORT_BD_ID_PTR(pop_ptr())
// 	@static method 	: Value


// 	if !table_get_hash(get_import_context_importID(import_id),hash,&method) {
// 		runtime_error("method not declared '",get_symbol_str_BD(sym_indx),"' in package '",get_import_name(import_id),"'")
// 		has_error_p^ = true
// 		return
// 	}

// 	if !is_valid_import_acess_importID(import_id,hash) {
// 		runtime_error("invalid acess '",get_symbol_str_BD(sym_indx),"' in package '",get_import_name(import_id),"'")
// 		has_error_p^ = true
// 		return
// 	}


// 	callee := #force_inline get_call_type_ptr(&method) 
// 		      #force_inline callee(&method,argc,0,has_error_p)
// }























