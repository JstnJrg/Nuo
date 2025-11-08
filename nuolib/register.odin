package NuoLib

import         "nuo:variant"

import strings "nuo:nuolib/string"
import         "nuo:nuolib/vec2"
import         "nuo:nuolib/complex"
import         "nuo:nuolib/rect2"

import         "nuo:nuolib/color"
import         "nuo:nuolib/transform2d"
import         "nuo:nuolib/array"
import _map    "nuo:nuolib/map"

import         "nuo:nuolib/range"
import         "nuo:nuolib/signal"
import         "nuo:nuolib/callable"

import         "nuo:nuolib/math"
import         "nuo:nuolib/time"
import         "nuo:nuolib/fileacess"
import         "nuo:nuolib/diracess"


register_import          :: variant.register_import
import_db_get_id_by_name :: variant.import_db_get_id_by_name
import_db_register_init  :: variant.import_db_register_init

default_import_getter    :: variant.default_import_getter
error_import_setter      :: variant.error_import_setter


class_db_register_class     :: variant.class_db_register_class
class_db_get_id_by_name     :: variant.class_db_get_id_by_name
class_db_load               :: variant.class_db_load
default_class_error_creator :: variant.default_class_error_creator

GET_TYPE_NAME               :: variant.GET_TYPE_NAME

register_nuo_libs :: proc()
{
	// classes
	class_db_load(class_db_register_class(GET_TYPE_NAME(.VECTOR2),    -1,.ATOMIC,default_class_error_creator),vec2.init)
	class_db_load(class_db_register_class(GET_TYPE_NAME(.COMPLEX),    -1,.ATOMIC,default_class_error_creator),complex.init)
	class_db_load(class_db_register_class(GET_TYPE_NAME(.RECT2),      -1,.ATOMIC,default_class_error_creator),rect2.init)
	class_db_load(class_db_register_class(GET_TYPE_NAME(.COLOR),      -1,.ATOMIC,default_class_error_creator),color.init)
	class_db_load(class_db_register_class(GET_TYPE_NAME(.ARRAY),      -1,.ATOMIC,default_class_error_creator),array.init)
	class_db_load(class_db_register_class(GET_TYPE_NAME(.MAP),        -1,.ATOMIC,default_class_error_creator),_map.init)
	class_db_load(class_db_register_class(GET_TYPE_NAME(.RANGE),      -1,.ATOMIC,default_class_error_creator),range.init)
	class_db_load(class_db_register_class(GET_TYPE_NAME(.STRING),     -1,.ATOMIC,default_class_error_creator),strings.init)
	class_db_load(class_db_register_class(GET_TYPE_NAME(.TRANSFORM2D),-1,.ATOMIC,default_class_error_creator),transform2d.init)
	class_db_load(class_db_register_class(GET_TYPE_NAME(.SIGNAL),     -1,.ATOMIC,default_class_error_creator),signal.init)
	class_db_load(class_db_register_class(GET_TYPE_NAME(.CALLABLE),   -1,.ATOMIC,default_class_error_creator),callable.init)

	// modules
	import_db_register_init(register_import("Math",.IMPORT,error_import_setter,default_import_getter),math.init)
	import_db_register_init(register_import("Time",.IMPORT,error_import_setter,default_import_getter),time.init)
	import_db_register_init(register_import("FileAcess",.IMPORT,error_import_setter,default_import_getter),fileacess.init)
	import_db_register_init(register_import("DirAcess",.IMPORT,error_import_setter,default_import_getter),diracess.init)
}