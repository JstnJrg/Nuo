#+private
package VM

import variant "nuo:variant"
import util    "nuo:util"
import OpCode  "nuo:opcode"
import nuolibs "nuo:nuolib"


// constants

STACK_SIZE          :: util.STACK_SIZE
MAX_CHUNK_CONSTANT  :: util.MAX_CHUNK_CONSTANT
MAX_VARIABLE_NAME   :: util.MAX_VARIABLE_NAME
MAX_MATCH_CASE      :: util.MAX_MATCH_CASE
MAX_ARGUMENTS       :: util.MAX_ARGUMENTS
MAX_FRAMES          :: util.MAX_FRAMES

NUO_IMPORT_NAME     :: util.NUO_IMPORT_NAME
NUO_DEBUG			:: util.NUO_DEBUG


// opcode
Int                :: util.Int
Float              :: util.Float
Opcode             :: OpCode.OpCode
Nuobject           :: variant.NuoObject
InterpretResult    :: variant.InterpretResult
get_operator_name  :: OpCode.get_operator_name

// 
atoi               :: util.atoi
atof               :: util.atof


// 
Localization :: variant.Localization
_VariantType :: variant.VariantType
NuoArena     :: util.NuoArena 

Value        :: variant.Value
Task         :: variant.Task

NuoInstance  :: variant.NuoInstance
Any          :: variant.Any 


print_any    :: variant.print_any
Task_VM    :: variant.Task(STACK_SIZE)
Context    :: variant.Context
CallState  :: variant.CallState
CallFrame  :: variant.CallFrame
Ofunction  :: variant.Ofunction
Arena      :: util.Arena
Allocator  :: util.Allocator
eprintf    :: util.eprintf
println    :: util.println

ptr_offset :: util.ptr_offset
ptr_sub    :: util.ptr_sub

long_ext   :: util.long_ext
read_entire_file_from_filename :: util.read_entire_file_from_filename

// nuo lib
register_nuo_libs     :: nuolibs.register_nuo_libs


// variant
VARIANT2VARIANT_PTR   :: variant.VARIANT2VARIANT_PTR
GET_VARIANT_TYPE_NAME :: variant.GET_VARIANT_TYPE_NAME
GET_TYPE_NAME         :: variant.GET_TYPE_NAME
GET_TYPE              :: variant.GET_TYPE

ref_value			  :: variant.ref_value
unref_value			  :: variant.unref_value


print_values        :: variant.print_values

hash_string         :: variant.hash_string

// op
get_op_unary  :: variant.get_op_unary
get_op_binary :: variant.get_op_binary


// 
init_context :: variant.init_context

// db
register_nuo_dependencies   :: variant.register_nuo_dependencies

// import db
register_import             :: variant.register_import
import_db_get_globals       :: variant.import_db_get_globals
import_db_get_id_by_name    :: variant.import_db_get_id_by_name
import_db_name              :: variant.import_db_name
import_db_get_value         :: variant.import_db_get_value
import_db_initialize_value  :: variant.import_db_initialize_value

import_get_classes_names    :: variant.import_get_import_names
import_get_classes_hashes   :: variant.import_get_import_hashes

import_db_register_all_db   :: variant.import_db_register_all_db
// import_get_import_hashes    :: variant.import_get_import_hashes
import_get_import_names     :: variant.import_get_import_names
import_db_check_api         :: variant.import_db_check_api

// error_import_setter         :: variant.error_import_setter
// error_import_getter         :: variant.error_import_getter
// default_import_setter       :: variant.default_import_setter
// default_import_getter       :: variant.default_import_getter

// function_db
db_create_function        :: variant.db_create_function
function_db_get_finfo     :: variant.function_db_get_finfo
function_db_get_chunk     :: variant.function_db_get_chunk
function_db_is_valid_id   :: variant.function_db_is_valid_id
function_db_get_name      :: variant.function_db_get_name

function_db_get_fid_string :: variant.function_db_get_fid_string

function_db_push_opcode   :: variant.function_db_push_opcode
function_db_push_constant :: variant.function_db_push_constant
function_db_push_index    :: variant.function_db_push_index

function_db_get_current_address_index :: variant.function_db_get_current_address_index       
function_db_set_address               :: variant.function_db_set_address

disassembly_function                  :: variant.disassembly_function

// string_db
string_db_register_string :: variant.string_db_register_string
string_db_get_string      :: variant.string_db_get_string
string_db_get_hash        :: variant.string_db_get_hash
string_clone			  :: util.string_clone

// class_db_register_class
class_db_register_class         :: variant.class_db_register_class
class_db_register_class_method  :: variant.class_db_register_class_method
class_db_get_class_name         :: variant.class_db_get_class_name
class_db_get_method             :: variant.class_db_get_method
class_db_super_get_method       :: variant.class_db_super_get_method

class_db_get_method_recursively :: variant.class_db_get_method_recursively
class_db_get_id_by_name         :: variant.class_db_get_id_by_name
class_db_call_creator           :: variant.class_db_call_creator

class_db_can_extends            :: variant.class_db_can_extends
class_db_check_class            :: variant.class_db_check_class

class_db_get_classes_names      :: variant.class_db_get_classes_names
class_db_get_classes_hashes     :: variant.class_db_get_classes_hashes




// 
// INT_VAL       :: variant.INT_VAL
// FLOAT_VAL     :: variant.FLOAT_VAL

// NIL_VAL_PTR   :: variant.NIL_VAL_PTR
// BOOL_VAL_PTR  :: variant.BOOL_VAL_PTR
SYMID_VAL	  :: variant.SYMID_VAL
IMPORT_VAL    :: variant.IMPORT_VAL
INT_VAL       :: variant.INT_VAL

NIL_VAR_PTR    :: variant.NIL_VAL_PTR
BOOL_VAL_PTR   :: variant.BOOL_VAL_PTR
INT_VAL_PTR    :: variant.INT_VAL_PTR
IMPORT_VAL_PTR :: variant.IMPORT_VAL_PTR
FLOAT_VAL_PTR  :: variant.FLOAT_VAL_PTR

VARIANT_VAL     :: variant.VARIANT_VAL
NUOFUNCTION_VAL :: variant.NUOFUNCTION_VAL
CLASS_VAL       :: variant.CLASS_VAL

VARIANT_VAL_PTR   :: variant.VARIANT_VAL_PTR
NUOOBJECT_VAL_PTR :: variant.NUOOBJECT_VAL_PTR

IMPORT_B_VALUE      :: variant.IMPORT_B_VALUE

falsey			:: variant.IS_ZERO

AS_INT_PTR      :: variant.AS_INT_PTR
AS_BOOL_PTR     :: variant.AS_BOOL_PTR
AS_NUOOBECT_PTR :: variant.AS_NUOOBECT_PTR


IS_VARIANT_PTR  :: variant.IS_VARIANT_PTR
IS_NUMERIC_PTR  :: variant.IS_NUMERIC_PTR



REINTERPRET_MEM     :: variant.REINTERPRET_MEM
REINTERPRET_MEM_PTR :: variant.REINTERPRET_MEM_PTR


create_obj_instance  :: variant.create_obj_instance
create_obj_array     :: variant.create_obj_array





// gc
gc_free_list    :: variant.gc_free_list
gc_end          :: variant.gc_end
gc_set_max      :: variant.gc_set_max


create_obj_string_literal :: variant.create_obj_string_literal


// table
Table            :: variant.Table
table_set        :: variant.table_set
table_get        :: variant.table_get
table_import_get :: variant.table_import_get