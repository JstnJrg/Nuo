package Time

import "nuo:variant"
// import "base:intrinsics"

Int         :: variant.Int
Float       :: variant.Float
Value       :: variant.Value

Context     :: variant.Context
Ofunction   :: variant.Ofunction

BOOL_VAL        :: variant.BOOL_VAL
INT_VAL         :: variant.INT_VAL
FLOAT_VAL       :: variant.FLOAT_VAL

BOOL_VAL_PTR        :: variant.BOOL_VAL_PTR
INT_VAL_PTR         :: variant.INT_VAL_PTR
FLOAT_VAL_PTR       :: variant.FLOAT_VAL_PTR

AS_INT_PTR          :: variant.AS_INT_PTR
AS_FLOAT_PTR        :: variant.AS_FLOAT_PTR

IS_VARIANT_PTR      :: variant.IS_VARIANT_PTR
IS_NUMERIC_PTR      :: variant.IS_NUMERIC_PTR

IMPORT_B_VALUE      :: variant.IMPORT_B_VALUE
GET_TYPE_NAME       :: variant.GET_TYPE_NAME


register_op         :: variant.register_op
// type_is_numeric     :: intrinsics.type_is_numeric
