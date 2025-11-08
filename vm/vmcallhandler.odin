#+private

package VM

call_dispatch : [VariantType]CallData 

HandleType   :: #type proc(argc: int)
CallType     :: #type proc(argc : int, dargc := 0)


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
	register_call_type(.SFUNCTION,call_sfunction)

	register_call_type(.BOUND_METHOD,call_bfunction)
	register_call_type(.CALLABLE,call_cfunction)
}

handle_types :: proc()
{
	// Nota(jstn): atomicos
	register_handler_type(.VECTOR2,atomic_handler)
	register_handler_type(.COMPLEX,atomic_handler)
	register_handler_type(.ARRAY,atomic_handler)
	register_handler_type(.MAP,atomic_handler)
	register_handler_type(.STRING, atomic_handler)
	register_handler_type(.RECT2,  atomic_handler)
	register_handler_type(.COLOR,  atomic_handler)
	register_handler_type(.TRANSFORM2D,  atomic_handler)
	register_handler_type(.RANGE, atomic_handler)
	register_handler_type(.SIGNAL,atomic_handler)
	register_handler_type(.CALLABLE,atomic_handler)
	// register_handle_type(.TASK,atomic_handle)

	register_handler_type(.ANY,any_handler)
	register_handler_type(.CLASS,class_handler)
	register_handler_type(.INSTANCE,class_instance_handler)
	register_handler_type(.IMPORT,import_handler)
}

import_id_types :: proc() 
{

}


classe_id_types :: proc() 
{
	register_type_class(.VECTOR2,class_db_get_id_by_name(GET_TYPE_NAME(.VECTOR2)))
	register_type_class(.COMPLEX,class_db_get_id_by_name(GET_TYPE_NAME(.COMPLEX)))
	register_type_class(.RECT2,  class_db_get_id_by_name(GET_TYPE_NAME(.RECT2)))
	register_type_class(.COLOR,  class_db_get_id_by_name(GET_TYPE_NAME(.COLOR)))
	register_type_class(.ARRAY,  class_db_get_id_by_name(GET_TYPE_NAME(.ARRAY)))
	register_type_class(.MAP,    class_db_get_id_by_name(GET_TYPE_NAME(.MAP)))
	register_type_class(.STRING, class_db_get_id_by_name(GET_TYPE_NAME(.STRING)))
	register_type_class(.TRANSFORM2D, class_db_get_id_by_name(GET_TYPE_NAME(.TRANSFORM2D)))
	register_type_class(.RANGE,       class_db_get_id_by_name(GET_TYPE_NAME(.RANGE)))
	register_type_class(.SIGNAL,      class_db_get_id_by_name(GET_TYPE_NAME(.SIGNAL)))
	register_type_class(.CALLABLE,    class_db_get_id_by_name(GET_TYPE_NAME(.CALLABLE)))
	// register_type_class(.TASK,        class_db_get_id_by_name(GET_TYPE_NAME(.TASK)))
}



fallbacks :: proc()
{
	for &value in call_dispatch
	{
		if value.callee == nil do value.callee = call_fallback
		if value.handle == nil do value.handle = fallback_handler
	}
}


// // ============================================================================


register_handler_type     :: proc "contextless" (type: VariantType, handle: HandleType)  { call_dispatch[type].handle = handle }
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


get_handler               :: #force_inline proc "contextless" (value: ^Value)     -> HandleType { return call_dispatch[value.type].handle }
get_handle_type_by_type   :: #force_inline proc "contextless" (type: VariantType) -> HandleType { return call_dispatch[type].handle }
get_import_id             :: #force_inline proc "contextless" (type: VariantType) -> int        { return call_dispatch[type]._id }
get_class_id              :: #force_inline proc "contextless" (type: VariantType) -> int        { return call_dispatch[type]._id }












// ======================================= handlers =======================================


fallback_handler :: #force_inline proc(argc: int) { cond_report_error(false,"invalid handle") }




// Nota(jstn): handler para instancia de classes
@(optimization_mode = "favor_size")
atomic_handler :: #force_inline proc(argc: int) 
{
	sid         := read_index()
	method_hash := string_db_get_hash(sid)
	type        := peek(0).type
	cid         := get_class_id(type)

	nuo_assert(cid >= 0,"atomic cid >= 0 condition is false ! it's a bug. please registe the _id.")

	method_ptr  := get_temp_return()

	if class_db_get_method(cid,method_hash,method_ptr,.INTRINSICS)
	{
	    callee := get_call_type(method_ptr) 
	    push(method_ptr)
		callee(argc,1) // +1 for object
		return
	}

	cond_report_error(false,"method '%v' not declared in base of '%v'.",string_db_get_string(sid),GET_TYPE_NAME(type))
}


// Nota(jstn): handler any
@(optimization_mode = "favor_size")
any_handler :: #force_inline proc(argc: int) 
{
	sid         := read_index()
	method_hash := string_db_get_hash(sid)
	_any        := AS_NUOOBECT_PTR(peek(0),Any)
	_id         := _any.id

	nuo_assert(_id >= 0,"any.id >= 0 condition is false! it's a bug. please registe the _id.")

	method_ptr  := get_temp_return()

	#partial switch _any.etype
	{
		case .CLASS:

			if class_db_get_method_recursively(_id,method_hash,method_ptr,.INSTANCE) 
			{
			    callee := get_call_type(method_ptr) 
			    push(method_ptr)
				callee(argc,1) // +1 for object
				return
			}

		case .IMPORT: 

			if table_import_get(import_db_get_globals(_id),method_hash,method_ptr) 
			{
			    callee := get_call_type(method_ptr) 
			    push(method_ptr)
				callee(argc,1) // +1 for object
				return
			}


		case       : cond_report_error(false,"Oops! any is just for import and classes instance."); return
				

	}

	cond_report_error(false,"method '%v' not declared in <Reference#%p>.",string_db_get_string(sid),_any)
}


// Nota(jstn): handler para instancia de classes
@(optimization_mode = "favor_size")
class_instance_handler :: #force_inline proc(argc: int) 
{
	sid         := read_index()
	method_hash := string_db_get_hash(sid)

	instance    := AS_NUOOBECT_PTR(peek(0),NuoInstance)
	method_ptr  := get_temp_return()

	if class_db_get_method_recursively(instance.cid,method_hash,method_ptr,.INSTANCE) 
	{
	    callee := get_call_type(method_ptr) 
	    push(method_ptr)
		callee(argc,1) // +1 for object
		
		return
	}

	cond_report_error(false,"method '%v' not declared by '%v' Class.",string_db_get_string(sid),class_db_get_class_name(instance.cid))
}

@(optimization_mode = "favor_size")
import_handler :: #force_inline proc(argc: int) 
{
	sid         := read_index()
	method_hash := string_db_get_hash(sid)
	iid         := AS_INT_PTR(peek(0))
	method_ptr  := get_temp_return()

	if table_import_get(import_db_get_globals(iid),method_hash,method_ptr) 
	{
	    callee := get_call_type(method_ptr) 
	    push(method_ptr)
		callee(argc,1) // +1 for object

		return
	}

	cond_report_error(false,"method '%v' not declared by '%v'.",string_db_get_string(sid),import_db_name(iid))
}


@(optimization_mode = "favor_size")
class_handler :: #force_inline proc(argc: int) 
{
	sid         := read_index()
	method_hash := string_db_get_hash(sid)
	cid         := AS_INT_PTR(peek(0))
	method_ptr  := get_temp_return()

	if class_db_get_method_recursively(cid,method_hash,method_ptr,.STATIC) 
	{
	    callee := get_call_type(method_ptr) 
	    push(method_ptr)
		callee(argc,1) // +1 for object
		
		return
	}

	cond_report_error(false,"method '%v' not declared by '%v' Class.",string_db_get_string(sid),class_db_get_class_name(cid))
}