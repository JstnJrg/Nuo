package Color

import "nuo:variant"
import "base:intrinsics"


Float       :: variant.Float
Vec2        :: variant.Vec2
Color       :: variant.Color
Value       :: variant.Value

Context     :: variant.Context
Ofunction   :: variant.Ofunction

B_METHOD    :: variant.CLASS_B_METHOD 

println     :: variant.println

BOOL_VAL_PTR        :: variant.BOOL_VAL_PTR
INT_VAL_PTR         :: variant.INT_VAL_PTR
FLOAT_VAL_PTR       :: variant.FLOAT_VAL_PTR
COLOR_VAL_PTR       :: variant.COLOR_VAL_PTR

AS_INT_PTR          :: variant.AS_INT_PTR
AS_FLOAT_PTR        :: variant.AS_FLOAT_PTR
AS_SYMID_PTR        :: variant.AS_SYMID_PTR

IS_VARIANT_PTR      :: variant.IS_VARIANT_PTR
IS_NUMERIC_PTR      :: variant.IS_NUMERIC_PTR

REINTERPRET_MEM     :: variant.REINTERPRET_MEM
REINTERPRET_MEM_PTR :: variant.REINTERPRET_MEM_PTR

GET_TYPE_NAME        :: variant.GET_TYPE_NAME

register_setget      :: variant.register_setget 
register_op          :: variant.register_op
string_db_get_string :: variant.string_db_get_string

class_register_static_property :: variant.class_register_static_property
class_db_default_csetter	   :: variant.class_db_default_csetter
class_db_default_cgetter	   :: variant.class_db_default_cgetter


// 
type_is_numeric    :: intrinsics.type_is_numeric
