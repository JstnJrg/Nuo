package String

import "nuo:variant"
import utf8string "core:unicode/utf8/utf8string"


//

UFT8String :: utf8string.String
UTF8Init   :: utf8string.init
UTF8Len    :: utf8string.len
UTF8At     :: utf8string.at
UTF8Slice  :: utf8string.slice

//


Value       :: variant.Value

Context     :: variant.Context
Ofunction   :: variant.Ofunction

NuoString   :: variant.NuoString
NuoArray    :: variant.NuoArray

B_METHOD    :: variant.CLASS_B_METHOD 

// println     :: variant.println

BOOL_VAL_PTR        :: variant.BOOL_VAL_PTR
INT_VAL_PTR         :: variant.INT_VAL_PTR
NUOOBJECT_VAL_PTR   :: variant.NUOOBJECT_VAL_PTR
RID_VAL_PTR         :: variant.RID_VAL_PTR
NIL_VAL_PTR         :: variant.NIL_VAL_PTR
REINTERPRET_MEM     :: variant.REINTERPRET_MEM

AS_INT_PTR          :: variant.AS_INT_PTR
AS_SYMID_PTR        :: variant.AS_SYMID_PTR
AS_NUOOBECT_PTR     :: variant.AS_NUOOBECT_PTR

IS_VARIANT_PTR      :: variant.IS_VARIANT_PTR
GET_TYPE_NAME       :: variant.GET_TYPE_NAME

ref_value            :: variant.ref_value
unref_value          :: variant.unref_value
ref_object           :: variant.ref_object
unref_object         :: variant.unref_object
ref_slice            :: variant.ref_slice
unref_slice          :: variant.unref_slice

Arena_Temp           :: variant.Arena_Temp

aprint_any           :: variant.aprint_any

register_setget      :: variant.register_setget 
register_op          :: variant.register_op
string_db_get_string :: variant.string_db_get_string

hash_string          :: variant.hash_string

create_obj_string    :: variant.create_obj_string
nuostring_write_data :: variant.nuostring_write_data

class_db_methods_table_reserve :: variant.class_db_methods_table_reserve


