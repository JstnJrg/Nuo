package NuoLib

import         "nuo:variant"
import strings "nuo:nuolib/string"
import         "nuo:nuolib/vec2"
import         "nuo:nuolib/rect2"
import         "nuo:nuolib/color"
import         "nuo:nuolib/transform2d"
import         "nuo:nuolib/array"
import _map    "nuo:nuolib/map"
import         "nuo:nuolib/range"
import         "nuo:nuolib/signal"

import         "nuo:nuolib/math"
import         "nuo:nuolib/time"
import         "nuo:nuolib/fileacess"

import_db_get_id_by_name :: variant.import_db_get_id_by_name
class_db_get_id_by_name  :: variant.class_db_get_id_by_name
GET_TYPE_NAME            :: variant.GET_TYPE_NAME

register_nuo_libs :: proc()
{
	vec2.init(class_db_get_id_by_name(GET_TYPE_NAME(.VECTOR2)))
	rect2.init(class_db_get_id_by_name(GET_TYPE_NAME(.RECT2)))
	color.init(class_db_get_id_by_name(GET_TYPE_NAME(.COLOR)))
	array.init(class_db_get_id_by_name(GET_TYPE_NAME(.ARRAY)))
	_map.init(class_db_get_id_by_name(GET_TYPE_NAME(.MAP)))
	strings.init(class_db_get_id_by_name(GET_TYPE_NAME(.STRING)))
	signal.init(class_db_get_id_by_name(GET_TYPE_NAME(.SIGNAL)))
	range.init(class_db_get_id_by_name(GET_TYPE_NAME(.RANGE)))

	transform2d.init(class_db_get_id_by_name(GET_TYPE_NAME(.TRANSFORM2D)))
	
	// modules
	math.init(import_db_get_id_by_name("Math",.IMPORT))
	time.init(import_db_get_id_by_name("Time",.IMPORT))
	fileacess.init(import_db_get_id_by_name("FileAcess",.IMPORT))
}