package Array


import rand "core:math/rand"
import      "nuo:variant"


Float       :: variant.Float
Int         :: variant.Int
Vec2        :: variant.Vec2
Value       :: variant.Value

Context     :: variant.Context

Ofunction   :: variant.Ofunction
NuoArray    :: variant.NuoArray

B_METHOD    :: variant.CLASS_B_METHOD

println     :: variant.println

get_op_unary      :: variant.get_op_unary
get_op_binary     :: variant.get_op_binary
context_has_error :: variant.context_has_error

ref_value         :: variant.ref_value
unref_value       :: variant.unref_value

ref_value_costum  :: variant.ref_value_costum
// unref_value       :: variant.unref_value

ref_object        :: variant.ref_object
unref_object      :: variant.unref_object
ref_slice         :: variant.ref_slice
unref_slice       :: variant.unref_slice
ref_slice_costum  :: variant.ref_slice_costum


BOOL_VAL_PTR        :: variant.BOOL_VAL_PTR
INT_VAL_PTR         :: variant.INT_VAL_PTR
NIL_VAL_PTR         :: variant.NIL_VAL_PTR
// FLOAT_VAL_PTR       :: variant.FLOAT_VAL_PTR
VARIANT2VARIANT_PTR :: variant.VARIANT2VARIANT_PTR


AS_NUOOBECT_PTR     :: variant.AS_NUOOBECT_PTR
AS_INT_PTR          :: variant.AS_INT_PTR
AS_BOOL_PTR         :: variant.AS_BOOL_PTR
NUOOBJECT_VAL_PTR   :: variant.NUOOBJECT_VAL_PTR
// AS_FLOAT_PTR        :: variant.AS_FLOAT_PTR

IS_VARIANT_PTR      :: variant.IS_VARIANT_PTR
IS_NUMERIC_PTR      :: variant.IS_NUMERIC_PTR

// REINTERPRET_MEM     :: variant.REINTERPRET_MEM
// REINTERPRET_MEM_PTR :: variant.REINTERPRET_MEM_PTR
COPY_DATA           :: variant.COPY_DATA
GET_TYPE_NAME        :: variant.GET_TYPE_NAME

create_any           :: variant.create_any
create_obj_array     :: variant.create_obj_array
register_setget      :: variant.register_setget 
register_op          :: variant.register_op
variant_hash_compare :: variant.variant_hash_compare

string_db_get_string :: variant.string_db_get_string
class_register_static_property :: variant.class_register_static_property


// 
rshuffle   :: rand.shuffle
rchoice    :: rand.choice


