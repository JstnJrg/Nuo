package Transform2D

import "nuo:variant"
import "base:intrinsics"


Float       :: variant.Float
Vec2        :: variant.Vec2
Rect2       :: variant.Rect2
mat2x3      :: variant.mat2x3
Value       :: variant.Value
Transform2D :: variant.Transform2D

Context     :: variant.Context
Ofunction   :: variant.Ofunction

B_METHOD    :: variant.CLASS_B_METHOD 

println     :: variant.println
print_vec2  :: variant.print_vec2


BOOL_VAL_PTR        :: variant.BOOL_VAL_PTR
INT_VAL_PTR         :: variant.INT_VAL_PTR
FLOAT_VAL_PTR       :: variant.FLOAT_VAL_PTR
VECTOR2_VAL_PTR     :: variant.VECTOR2_VAL_PTR
RECT2_VAL_PTR       :: variant.RECT2_VAL_PTR
NUOOBJECT_VAL_PTR   :: variant.NUOOBJECT_VAL_PTR

AS_INT_PTR          :: variant.AS_INT_PTR
AS_FLOAT_PTR        :: variant.AS_FLOAT_PTR
AS_SYMID_PTR        :: variant.AS_SYMID_PTR
AS_NUOOBECT_PTR     :: variant.AS_NUOOBECT_PTR

IS_VARIANT_PTR      :: variant.IS_VARIANT_PTR
IS_NUMERIC_PTR      :: variant.IS_NUMERIC_PTR

REINTERPRET_MEM     :: variant.REINTERPRET_MEM
REINTERPRET_MEM_PTR :: variant.REINTERPRET_MEM_PTR

GET_TYPE_NAME         :: variant.GET_TYPE_NAME
GET_VARIANT_TYPE_NAME :: variant.GET_VARIANT_TYPE_NAME

ref_value            :: variant.ref_value
unref_value          :: variant.unref_value
ref_object           :: variant.ref_object
unref_object         :: variant.unref_object

register_setget      :: variant.register_setget 
register_op          :: variant.register_op
string_db_get_string :: variant.string_db_get_string
class_register_static_property :: variant.class_register_static_property


// 
create_transform2  :: variant.create_transform2
type_is_numeric    :: intrinsics.type_is_numeric
