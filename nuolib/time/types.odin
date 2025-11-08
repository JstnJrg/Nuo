package Time

import "nuo:variant"
// import "base:intrinsics"

Int         :: variant.Int
Float       :: variant.Float
Value       :: variant.Value
MapEntry    :: variant.MapEntry

Context     :: variant.Context
Ofunction   :: variant.Ofunction


BOOL_VAL        :: variant.BOOL_VAL
INT_VAL         :: variant.INT_VAL
FLOAT_VAL       :: variant.FLOAT_VAL
NUOOBJECT_VAL   :: variant.NUOOBJECT_VAL
VARIANT_VAL     :: variant.VARIANT_VAL


BOOL_VAL_PTR        :: variant.BOOL_VAL_PTR
INT_VAL_PTR         :: variant.INT_VAL_PTR
FLOAT_VAL_PTR       :: variant.FLOAT_VAL_PTR
NUOOBJECT_VAL_PTR   :: variant.NUOOBJECT_VAL_PTR

AS_INT_PTR          :: variant.AS_INT_PTR
AS_FLOAT_PTR        :: variant.AS_FLOAT_PTR

IS_VARIANT_PTR      :: variant.IS_VARIANT_PTR
IS_NUMERIC_PTR      :: variant.IS_NUMERIC_PTR

IMPORT_B_VALUE      :: variant.IMPORT_B_VALUE
GET_TYPE_NAME       :: variant.GET_TYPE_NAME
import_db_reserve   :: variant.import_db_reserve


create_obj_map      :: variant.create_obj_map
variant_hash        :: variant.variant_hash
hash_string         :: variant.hash_string

create_obj_string    :: variant.create_obj_string
nuostring_write_data :: variant.nuostring_write_data

register_op         :: variant.register_op
// type_is_numeric     :: intrinsics.type_is_numeric
