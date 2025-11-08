#+private
package Time

import time "core:time"


get_tick_ms :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'get_tick_ms' expects %v, but got %v.",0,cs.argc) do return	
	INT_VAL_PTR(cs.result,#force_inline _get_tick_ms())
}

get_tick_ns :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'get_tick_ns' expects %v, but got %v.",0,cs.argc) do return	
	INT_VAL_PTR(cs.result,#force_inline _get_tick_ns())
}
get_precise_time_from_system :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'get_precise_time_from_system' expects %v, but got %v.",0,cs.argc) do return	

	hour, min, sec, nanos := time.precise_clock_from_time(time.now())

	_map := create_obj_map()
	data := &_map.data

	h    := create_obj_string(); nuostring_write_data("hour",h)
	m    := create_obj_string(); nuostring_write_data("minute",m)
	s    := create_obj_string(); nuostring_write_data("second",s)
	n    := create_obj_string(); nuostring_write_data("nanosecond",n)

	data[hash_string("hour")]       = MapEntry{NUOOBJECT_VAL(h),VARIANT_VAL(hour)}
	data[hash_string("minute")]     = MapEntry{NUOOBJECT_VAL(m),VARIANT_VAL(min)}
	data[hash_string("second")]     = MapEntry{NUOOBJECT_VAL(s),VARIANT_VAL(sec)}
	data[hash_string("nanosecond")] = MapEntry{NUOOBJECT_VAL(n),VARIANT_VAL(nanos)}

	NUOOBJECT_VAL_PTR(cs.result,_map)
}


get_time_from_system :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'get_time_from_system' expects %v, but got %v.",0,cs.argc) do return	

	hour, min, sec := time.clock_from_time(time.now())

	_map := create_obj_map()
	data := &_map.data

	h    := create_obj_string(); nuostring_write_data("hour",h)
	m    := create_obj_string(); nuostring_write_data("minute",m)
	s    := create_obj_string(); nuostring_write_data("second",s)

	data[hash_string("hour")]       = MapEntry{NUOOBJECT_VAL(h),VARIANT_VAL(hour)}
	data[hash_string("minute")]     = MapEntry{NUOOBJECT_VAL(m),VARIANT_VAL(min)}
	data[hash_string("second")]     = MapEntry{NUOOBJECT_VAL(s),VARIANT_VAL(sec)}

	NUOOBJECT_VAL_PTR(cs.result,_map)
}

get_date_from_system :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'get_date_from_system' expects %v, but got %v.",0,cs.argc) do return	

	year,_month,day := time.date(time.now()); month := int(_month)

	_map := create_obj_map()
	data := &_map.data

	y    := create_obj_string(); nuostring_write_data("year",y)
	m    := create_obj_string(); nuostring_write_data("month",m)
	d    := create_obj_string(); nuostring_write_data("day",d)

	data[hash_string("year")]       = MapEntry{NUOOBJECT_VAL(y),VARIANT_VAL(year)}
	data[hash_string("month")]      = MapEntry{NUOOBJECT_VAL(m),VARIANT_VAL(month)}
	data[hash_string("day")]        = MapEntry{NUOOBJECT_VAL(d),VARIANT_VAL(day)}

	NUOOBJECT_VAL_PTR(cs.result,_map)
}

