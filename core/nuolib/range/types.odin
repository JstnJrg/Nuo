package Range

import "nuo:variant"
import "base:intrinsics"


Float       :: variant.Float
Value       :: variant.Value
Range       :: variant.Range
VariantType :: variant.VariantType

println     :: variant.println
printer     :: variant.print_any

Context     :: variant.Context
Ofunction   :: variant.Ofunction

B_METHOD    :: variant.CLASS_B_METHOD 

INT_VAL     :: variant.INT_VAL
VARIANT_VAL :: variant.VARIANT_VAL

BOOL_VAL_PTR        :: variant.BOOL_VAL_PTR
INT_VAL_PTR         :: variant.INT_VAL_PTR
FLOAT_VAL_PTR       :: variant.FLOAT_VAL_PTR
NIL_VAL_PTR         :: variant.NIL_VAL_PTR
VARIANT_VAL_PTR     :: variant.VARIANT_VAL_PTR
NUOOBJECT_VAL_PTR   :: variant.NUOOBJECT_VAL_PTR
VARIANT2VARIANT_PTR :: variant.VARIANT2VARIANT_PTR

AS_INT_PTR          :: variant.AS_INT_PTR
AS_FLOAT_PTR        :: variant.AS_FLOAT_PTR
AS_BOOL_PTR         :: variant.AS_BOOL_PTR
// AS_SYMID_PTR        :: variant.AS_SYMID_PTR
AS_NUOOBECT_PTR     :: variant.AS_NUOOBECT_PTR

IS_VARIANT_PTR      :: variant.IS_VARIANT_PTR
IS_NUMERIC_PTR      :: variant.IS_NUMERIC_PTR

GET_TYPE_NAME         :: variant.GET_TYPE_NAME
GET_VARIANT_TYPE_NAME :: variant.GET_VARIANT_TYPE_NAME

ref_value            :: variant.ref_value
unref_value          :: variant.unref_value
ref_object           :: variant.ref_object
unref_object         :: variant.unref_object

get_op_unary         :: variant.get_op_unary
get_op_binary        :: variant.get_op_binary

register_setget      :: variant.register_setget 
register_op          :: variant.register_op
regiser_constructor  :: variant.regiser_constructor

// string_db_get_string :: variant.string_db_get_string
class_register_static_property :: variant.class_register_static_property

// 
create_range         :: variant.create_range
create_obj_array     :: variant.create_obj_array
