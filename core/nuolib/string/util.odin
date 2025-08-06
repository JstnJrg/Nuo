package String

import "nuo:variant"


Value       :: variant.Value

Context     :: variant.Context
Ofunction   :: variant.Ofunction

NuoString   :: variant.NuoString
NuoArray    :: variant.NuoArray

B_METHOD    :: variant.CLASS_B_METHOD 

println     :: variant.println


BOOL_VAL_PTR        :: variant.BOOL_VAL_PTR
INT_VAL_PTR         :: variant.INT_VAL_PTR
NUOOBJECT_VAL_PTR   :: variant.NUOOBJECT_VAL_PTR

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

register_setget      :: variant.register_setget 
register_op          :: variant.register_op
string_db_get_string :: variant.string_db_get_string

hash_string          :: variant.hash_string

create_obj_string    :: variant.create_obj_string
nuostring_write_data :: variant.nuostring_write_data