package Variant


IMPORT_B_VALUE :: proc{IB_METHOD_0,IB_METHOD_1,IB_VALUE_0,IB_VALUE_1}//,IB_METHOD_2,IB_METHOD_3}
IMPORT_B_SAFE  :: proc{IB_METHOD_2}//,IB_METHOD_3}

IB_METHOD_0     :: #force_inline proc "contextless" (iid: int , m_name: string ,method : Ofunction) { t := import_db_get_globals(iid); t[hash_string(m_name)] = ODINFUNCTION_VAL(method) }
IB_METHOD_1     :: #force_inline proc "contextless" (iid: int , m_hash: u32 ,method : Ofunction)    { t := import_db_get_globals(iid); t[m_hash] = ODINFUNCTION_VAL(method) }

IB_METHOD_2     :: #force_inline proc (iid: int , m_name: string , method : Ofunction, types: ..VariantType)    
{ 
	t  := import_db_get_globals(iid)
	t[hash_string(m_name)] = SAFEFUNCTION_VAL(method,..types)
}

IB_METHOD_3     :: #force_inline proc (iid: int , m_hash: u32 , method : Ofunction, types: ..VariantType)    
{ 
	t        := import_db_get_globals(iid)
	t[m_hash] = SAFEFUNCTION_VAL(method,..types)
}


IB_VALUE_0      :: #force_inline proc "contextless" (iid: int , _name: string ,value : Value)       { t := import_db_get_globals(iid); t[hash_string(_name)] = value }
IB_VALUE_1      :: #force_inline proc "contextless" (iid: int , _hash: u32 ,value : Value)          { t := import_db_get_globals(iid); t[_hash] = value }


CLASS_B_METHOD   :: proc{CB_METHOD_0,CB_METHOD_1}//,CB_METHOD_2,CB_METHOD_3}

CB_METHOD_0      :: #force_inline proc (cid: int , m_name: string ,method : Ofunction, mtype : MethodType) { class_db_register_class_method(cid,m_name,ODINFUNCTION_VAL(method),mtype) }
CB_METHOD_1      :: #force_inline proc (cid: int , m_hash: u32 ,method : Ofunction,mtype : MethodType)     { class_db_register_class_method_hash(cid,m_hash,ODINFUNCTION_VAL(method),mtype) }

// CB_METHOD_2      :: #force_inline proc (cid: int , m_hash: u32 ,method : Ofunction,mtype : MethodType, types : ..VariantType ) { class_db_register_class_method_hash(cid,m_hash,SAFEFUNCTION_VAL(method,types),mtype) }
// CB_METHOD_3      :: #force_inline proc (cid: int , m_name: string ,method : Ofunction,mtype : MethodType, types : ..VariantType ) { class_db_register_class_method_hash(cid,hash_string(m_name),SAFEFUNCTION_VAL(method,types),mtype) }