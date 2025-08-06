package Variant


ClassInfo :: struct
{
	methods    : MethodsTable,
	setget     : map[u32]PropertyInfo,
	csetget    : map[u32]StaticPropertyInfo,
	icreator   : FnCreator,

	cid        : int,
	sid        : int,
	name_id    : int,
	api        : ClassApi
}

ClassManager :: struct
{
	class_array : [dynamic]^ClassInfo,
	class_mapa  : map[string]int,
}

ClassApi     :: enum 
{
	NONE,
	ATOMIC, // não se pode extender dessas classes
	 // 
} 

PropertyInfo :: struct
{
	setter  : FnSetterGetter,
	getter  : FnSetterGetter,
}

StaticPropertyInfo :: struct
{
	getter : FnClassSetterGetter,
	setter : FnClassSetterGetter,
}

MethodType  :: enum u8 
{
	NUO,   // que só podem ser usadas sob controle e ser chamados por Odin
	STATIC,
	INSTANCE,   
	INTRINSICS, //tipos atomicos só veêm metodos intrinsics
}


MethodInfo  :: struct
{
	callable : Value,
	type     : MethodType
}


FnCreator           :: proc(cid: int ,ctx: ^Context) -> (^NuoInstance,bool)
FnSetterGetter      :: proc(instance: ^NuoInstance, sid: int, ret: ^Value, ctx: ^Context)
FnClassSetterGetter :: proc(cid, sid: int, ret: ^Value, ctx: ^Context)

class_db_register_class :: proc(class_name : string, sid := -1, capi : ClassApi = .NONE, creator := class_db_default_creator ) -> int 
{
	db_allocator      := get_context_allocator()
	class_info        := new(ClassInfo,db_allocator)	
	cid               := db_get_classinfo_id()

	class_info.methods  = make(MethodsTable,db_allocator)
	class_info.setget   = make(map[u32]PropertyInfo,db_allocator)
	class_info.csetget  = make(map[u32]StaticPropertyInfo,db_allocator)

	class_info.cid      = cid
	class_info.sid      = sid
	class_info.icreator = creator
	class_info.api      = capi
	class_info.name_id  = string_db_register_string(class_name)

	db_append_class_info(class_info)
	db_register_in_mapa(string_db_get_string(class_info.name_id),cid)
	// class_db_inherit_from(cid,sid)

	return cid
}

class_db_register_class_method :: proc(cid: int, _method_name: string, method: Value, type : MethodType = .INSTANCE) 
{
	ci  := db_get_classinfo(cid)
	mi  : MethodInfo

	mi.callable = method
	mi.type     = type

	method_table_set_info(db_get_classinfo_table(cid),hash_string(_method_name),&mi)
}


class_db_register_class_creator :: proc "contextless" (cid: int ,fn: FnCreator) 
{
	ci          := db_get_classinfo(cid)
	ci.icreator  = fn
}

class_db_register_class_method_hash :: proc(cid: int, _method_hash: u32, method: Value, type : MethodType = .INSTANCE) 
{
	ci  := db_get_classinfo(cid)
	mi  : MethodInfo

	mi.callable = method
	mi.type     = type
	method_table_set_info(db_get_classinfo_table(cid),_method_hash,&mi)
}

class_register_static_property :: proc(cid: int, pname: string, setter, getter : FnClassSetterGetter)
{
	ci  := db_get_classinfo(cid)
	spi : StaticPropertyInfo
	spi.setter = setter
	spi.getter = getter
	ci.csetget[hash_string(pname)] = spi
}

class_instance_register_value :: proc(instance: ^NuoInstance, pname: string, value: Value)
{
	hash := hash_string(pname)
	t    := &instance.fields
	table_set_value(t,hash,value)	
}

class_register_property :: proc(cid: int, pname: string, setter, getter : FnSetterGetter)
{
	ci  := db_get_classinfo(cid)
	pi : PropertyInfo
	pi.setter = setter
	pi.getter = getter
	ci.setget[hash_string(pname)] = pi
}

class_db_is_valid_sid           :: proc "contextless" (sid: int) -> bool { return sid >= 0 }

class_db_set_sid                :: proc "contextless" (cid,sid: int)
{ 
	ci     := db_get_classinfo(cid)
	ci.sid  = sid
}

class_db_get_class_name         :: #force_inline proc "contextless" (cid: int) -> string { return string_db_get_string(db_get_classinfo(cid).name_id) }

class_db_get_class_hash         :: #force_inline proc "contextless" (cid: int) -> u32 { return string_db_get_hash(db_get_classinfo(cid).name_id) }

class_db_check_class            :: #force_inline proc "contextless" (class_name: string) -> (int,bool) { return db_check_in_mapa(class_name) }

class_db_can_extends            :: #force_inline proc "contextless" (cid: int) -> bool { ci := db_get_classinfo(cid); return ci.api != .ATOMIC }

class_db_get_class_table        :: #force_inline proc "contextless" (cid: int) -> ^MethodsTable { return db_get_classinfo_table(cid) }

class_db_inherit_from           :: #force_inline proc "contextless" (cid,sid: int)
{
	if !class_db_is_valid_sid(sid) do return

	ci  := db_get_classinfo(cid)
	sci := db_get_classinfo(sid)

	for h,pi  in sci.setget  do ci.setget[h] = pi
	for h,spi in sci.csetget do ci.csetget[h] = spi
}

class_db_inherit_from_super     :: #force_inline proc "contextless" (cid: int)
{
	ci  := db_get_classinfo(cid)
	sid := ci.sid

	if !class_db_is_valid_sid(sid) do return

	sci := db_get_classinfo(sid)

	for h,pi  in sci.setget  do ci.setget[h] = pi
	for h,spi in sci.csetget do ci.csetget[h] = spi
}

class_db_get_method             :: #force_inline proc "contextless" (cid: int, m_hash: u32, m : ^Value, type : MethodType) -> bool { return method_table_get_ptr(class_db_get_class_table(cid),m_hash,m,type) }

class_db_call_creator           :: #force_inline proc (cid: int, ctx: ^Context) -> (^NuoInstance,bool) { ci := db_get_classinfo(cid); return  ci.icreator(cid,ctx) }

class_db_get_setter             :: #force_inline proc (cid: int, hash: u32) -> FnSetterGetter  
{ 
	ci     := db_get_classinfo(cid)
	pi, ok := &ci.setget[hash]
	sid    := ci.sid

	for !ok && class_db_is_valid_sid(sid)
	{
		ci     = db_get_classinfo(sid)
		pi, ok = &ci.setget[hash]
		sid    = ci.sid
	}
	
	return ok ? pi.setter : class_db_default_setter
}

class_db_get_getter             :: #force_inline proc "contextless" (cid: int, hash: u32) -> FnSetterGetter  
{ 
	ci     := db_get_classinfo(cid)
	pi, ok := &ci.setget[hash]
	sid    := ci.sid

	for !ok && class_db_is_valid_sid(sid)
	{
		ci     = db_get_classinfo(sid)
		pi, ok = &ci.setget[hash]
		sid    = ci.sid
	}

	return ok ? pi.getter : class_db_default_getter
}

class_db_get_csetter             :: #force_inline proc (cid: int, hash: u32) -> FnClassSetterGetter  
{ 
	ci     := db_get_classinfo(cid)
	pi, ok := &ci.csetget[hash]
	sid    := ci.sid

	for !ok && class_db_is_valid_sid(sid)
	{
		ci     = db_get_classinfo(sid)
		pi, ok = &ci.csetget[hash]
		sid    = ci.sid
	}

	return ok ? pi.setter : class_db_default_csetter
}

class_db_get_cgetter             :: #force_inline proc "contextless" (cid: int, hash: u32) -> FnClassSetterGetter
{ 
	ci     := db_get_classinfo(cid)
	pi, ok := &ci.csetget[hash]
	sid    := ci.sid

	for !ok && class_db_is_valid_sid(sid)
	{
		ci     = db_get_classinfo(sid)
		pi, ok = &ci.csetget[hash]
		sid    = ci.sid
	}

	return ok ? pi.getter : class_db_default_cgetter
}



class_db_get_classes_names      :: proc(data: int, callable : proc(data,cid: int,cname: string)) { for i in 0..< db_get_classinfo_id() do callable(data,i,class_db_get_class_name(i)) } 

class_db_get_classes_hashes     :: proc(data: int, callable : proc(data,cid: int,chash: u32))   { for i in 0..< db_get_classinfo_id() do callable(data,i,class_db_get_class_hash(i)) } 

class_db_super_get_method       :: #force_inline proc (cid: int, m_hash: u32, m : ^Value, mtype : MethodType) -> bool 
{ 
    cinfo  := db_get_classinfo(cid)
    sid    := cinfo.sid

    if class_db_is_valid_sid(sid) && class_db_get_method(sid,m_hash,m,mtype) do return true
    return false    
}


class_db_get_method_recursively :: #force_inline proc (cid: int, m_hash: u32, m : ^Value, mtype : MethodType) -> bool 
{
	if class_db_get_method(cid,m_hash,m,mtype)    do return true
    
    cinfo  := db_get_classinfo(cid)
    sid    := cinfo.sid

	for class_db_is_valid_sid(sid) 
	{
		if class_db_get_method(sid,m_hash,m,mtype) do return true
		cinfo = db_get_classinfo(sid)
		sid   = cinfo.sid
	}
	
	return false
}

class_db_get_id_by_name :: #force_inline proc "contextless" (class_name: string) -> int { cid,has := db_get_class_db_mapa()[class_name]; return has? cid: -1 }

class_db_default_creator :: proc(cid: int, ctx: ^Context ) -> (^NuoInstance,bool) { return create_obj_instance(cid),false }
class_db_error_creator   :: proc(cid: int, ctx: ^Context ) -> (^NuoInstance,bool) { ctx.runtime_error(false,"Class '%v' cannot be instatiate.",class_db_get_class_name(cid)); return nil,true }

class_db_default_setter  :: proc(instance: ^NuoInstance, sid: int, ret: ^Value, ctx: ^Context)
{
	hash := string_db_get_hash(sid)
	t    := &instance.fields
	table_instance_set(t,hash,ret)
}

class_db_default_getter  :: proc(instance: ^NuoInstance, sid: int, ret: ^Value, ctx: ^Context)
{
	hash := string_db_get_hash(sid)
	t    := &instance.fields
    if !table_instance_get(t,hash,ret) do ctx.runtime_error(false,"invalid acess to property or key '%v' on instance of '%v'.",string_db_get_string(sid),class_db_get_class_name(instance.cid))
}


class_db_default_csetter  :: proc(cid, sid: int, ret: ^Value, ctx: ^Context)
{
   ctx.runtime_error(false,"cannot find member '%v' in '%v' Class.",string_db_get_string(sid),class_db_get_class_name(cid))
}

class_db_default_cgetter  :: proc(cid, sid: int, ret: ^Value, ctx: ^Context)
{
    ctx.runtime_error(false,"cannot find member '%v' in '%v' Class.",string_db_get_string(sid),class_db_get_class_name(cid))
}


class_db_get_deinit_method     :: proc (instance: ^NuoInstance) -> (Value,bool)
{
	sid    := string_db_get_id("_deinit")
	method : Value

	if sid == -1 do return method, false

	hash      := string_db_get_hash(sid)
	sucess    := class_db_get_method(instance.cid,hash,&method,.INSTANCE)

	return method, sucess
}
