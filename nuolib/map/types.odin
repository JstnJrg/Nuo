package Map

// import      "core:reflect"
import      "nuo:variant"

Int         :: variant.Int
Value       :: variant.Value

Context     :: variant.Context

Ofunction   :: variant.Ofunction
NuoMap      :: variant.NuoMap
NuoArray    :: variant.NuoArray

MapEntry    :: variant.MapEntry

B_METHOD    :: variant.CLASS_B_METHOD

// println     :: variant.println

// get_op_unary      :: variant.get_op_unary
// get_op_binary     :: variant.get_op_binary
// context_has_error :: variant.context_has_error

ref_value         :: variant.ref_value
unref_value       :: variant.unref_value
ref_object        :: variant.ref_object
unref_object      :: variant.unref_object

Arena_Temp           :: variant.Arena_Temp
// ref_slice         :: variant.ref_slice
// unref_slice       :: variant.unref_slice


VARIANT_VAL         :: variant.VARIANT_VAL

BOOL_VAL_PTR        :: variant.BOOL_VAL_PTR
INT_VAL_PTR         :: variant.INT_VAL_PTR
NIL_VAL_PTR         :: variant.NIL_VAL_PTR
RID_VAL_PTR         :: variant.RID_VAL_PTR
REINTERPRET_MEM_PTR :: variant.REINTERPRET_MEM_PTR
REINTERPRET_MEM     :: variant.REINTERPRET_MEM

// FLOAT_VAL_PTR       :: variant.FLOAT_VAL_PTR
VARIANT2VARIANT_PTR :: variant.VARIANT2VARIANT_PTR


AS_NUOOBECT_PTR     :: variant.AS_NUOOBECT_PTR
AS_INT_PTR          :: variant.AS_INT_PTR
AS_BOOL_PTR         :: variant.AS_BOOL_PTR
NUOOBJECT_VAL_PTR   :: variant.NUOOBJECT_VAL_PTR
// AS_FLOAT_PTR        :: variant.AS_FLOAT_PTR

IS_VARIANT_PTR      :: variant.IS_VARIANT_PTR

// REINTERPRET_MEM     :: variant.REINTERPRET_MEM
// REINTERPRET_MEM_PTR :: variant.REINTERPRET_MEM_PTR
COPY_DATA           :: variant.COPY_DATA
GET_TYPE_NAME        :: variant.GET_TYPE_NAME

register_setget      :: variant.register_setget 
register_op          :: variant.register_op
get_op_binary        :: variant.get_op_binary
variant_hash_compare :: variant.variant_hash_compare

string_db_get_string :: variant.string_db_get_string
class_register_static_property :: variant.class_register_static_property
class_db_methods_table_reserve :: variant.class_db_methods_table_reserve

variant_hash        :: variant.variant_hash
hash_string         :: variant.hash_string

create_obj_map       :: variant.create_obj_map
create_obj_array     :: variant.create_obj_array

create_obj_string    :: variant.create_obj_string
nuostring_write_data :: variant.nuostring_write_data