package Variant



NuoOut          :: `Nuo:> `
MaxPrinter      :: 100
recursion_count := 0 


print_nil    :: proc() { print("null")   }
print_rid    :: proc() { print("@RID")   }
print_int    :: proc(value: ^Value) { print(AS_INT_PTR(value))   }
print_bool   :: proc(value: ^Value) { print(AS_BOOL_PTR(value))  }
print_float  :: proc(value: ^Value) { print(AS_FLOAT_PTR(value)) }

print_vec2    :: proc(value: ^Value) { vec2 := AS_VECTOR2_PTR(value); print("Vec2(",vec2.x,",",vec2.y,")") }

print_complex :: proc(value: ^Value) 
{ 
	complex := REINTERPRET_MEM_PTR(value,Complex)
	print("Complex(",complex.x,",",complex.y,")") 
}


print_rect2  :: proc(value: ^Value) 
{ 
	rect2 := AS_RECT2_PTR(value)
	pos   := &rect2[0] 
	size  := &rect2[1] 
	print("Rect2(",pos.x,",",pos.y,",",size.x,",",size.y,")") 
}

print_color  :: proc(value: ^Value) 
{ 
	color := AS_COLOR_PTR(value)
	print("Color(",color[0],",",color[1],",",color[2],",",color[3],")") 
}

print_range  :: proc(value: ^Value)
{
	range := AS_NUOOBECT_PTR(value,Range)
	print_any(&range.from)
	print("..")
	print_any(&range.to)
}

print_bound  :: proc(value: ^Value)
{
	bound := AS_NUOOBECT_PTR(value,BoundMethod)
	print_any(&bound.method)
}


print_nfunction :: proc(value: ^Value) { fid := AS_INT_PTR(value); print("function '",function_db_get_name(fid),"'") }
print_class     :: proc(value: ^Value) { cid := AS_INT_PTR(value); print("Class '",class_db_get_class_name(cid),"'") }
print_import    :: proc(value: ^Value) { iid := AS_INT_PTR(value); print("Import '",import_db_name(iid),"'") }
print_instance  :: proc(value: ^Value) { instance := AS_NUOOBECT_PTR(value,NuoInstance); print("instance of ",class_db_get_class_name(instance.cid)) }

print_aany       :: proc(value: ^Value) { printf("<Reference#%p>",AS_NUOOBECT_PTR(value,Any))}

print_array     :: proc(value: ^Value)
{
	array := AS_NUOOBECT_PTR(value,NuoArray)
	data  := &array.data
	len   := len(data)
	
	      recursion_count += 1
	defer recursion_count -= 1

	if recursion_count >= MaxPrinter { print("[...]"); return }

	print("[")
	for &content,indx in array.data
	{ 
		print_any(&content)
		if indx+1 != len do print(",")
		if recursion_count >= MaxPrinter { print("[...]"); break }
	}
			
	print("]")

}

print_callable     :: proc(value: ^Value)
{
	callable := AS_NUOOBECT_PTR(value,NuoCallable)

	print("Callable(")
	print_any(&callable.callable)
	print(")")
}

print_task     :: proc(value: ^Value)
{
	// callable := AS_NUOOBECT_PTR(value,NuoCallable)
	print("@Task")
}

print_map    :: proc(value: ^Value)
{
	map_  := AS_NUOOBECT_PTR(value,NuoMap)
	data  := &map_.data
	len   := len(data)
	
	      recursion_count += 1
	defer recursion_count -= 1

	if recursion_count >= MaxPrinter { print("{...}"); return }

	print("{")
	idx := 0

	for _,&me in data
	{ 
		print_any(&me.key)
		print(":")
		print_any(&me.value)
		
		if idx+1 != len do print(",")
		if recursion_count >= MaxPrinter { print("{...}"); break }

		idx += 1
	}
			
	print("}")

}


print_transform2D  :: proc(value: ^Value) 
{ 
	t   := AS_NUOOBECT_PTR(value,Transform2D)
	x   := &t.data[0]
	y   := &t.data[1]
	o   := &t.data[2]
  	print("Transform2D((",x.x,",",x.y,"),(",y.x,",",y.y,"),(",o.x,",",o.y,"))") 
}

print_string    :: proc(value: ^Value) { nuo_string := AS_NUOOBECT_PTR(value,NuoString); print("\"",to_string(nuo_string.data),"\"") }
print_signal    :: proc(value: ^Value) { print("@Signal") }


print_values :: proc(values: []Value)
{
	l  := len(values)
	print(NuoOut)

	for &value,index in values
	{
		print_any(&value)
		if index < l-1 do print(",")
	}

	println('\n')
}

print_any :: proc(value: ^Value, max_r := 0)
{
	#partial switch GET_VARIANT_TYPE(value)
	{
		case .NIL     : print_nil()
		case .INT     : print_int(value)
		case .FLOAT   : print_float(value)
		case .BOOL    : print_bool(value)

		case .VECTOR2     : print_vec2(value)
		case .RECT2       : print_rect2(value)
		case .COLOR       : print_color(value)
		case .COMPLEX     : print_complex(value)

		case .TRANSFORM2D  : print_transform2D(value)
		case .ANY          : print_aany(value)
		case .RANGE        : print_range(value)
		case .BOUND_METHOD : print_bound(value)

		case .NFUNCTION : print_nfunction(value)
		case .CLASS     : print_class(value)
		case .IMPORT    : print_import(value)

		case .STRING   : print_string(value)
		case .INSTANCE : print_instance(value)
		case .SIGNAL   : print_signal(value)
		case .RID      : print_rid()

		case .ARRAY    : print_array(value)
		case .MAP      : print_map(value)
		case .CALLABLE : print_callable(value)
		case .TASK     : print_task(value)


		case            : print(GET_VARIANT_TYPE(value)," not handler.")
	}
}





// ==========================================================



aprint_nil    :: proc(allocator : Allocator, newline := false) -> string { return aprint("null","",sep ="",allocator=allocator)   }
aprint_rid    :: proc(allocator : Allocator, newline := false) -> string { return aprint("@RID","",sep ="",allocator=allocator)   }
aprint_int    :: proc(value: ^Value,allocator : Allocator, newline := false) -> string { return aprint(AS_INT_PTR(value),sep ="",allocator=allocator)   }
aprint_bool   :: proc(value: ^Value,allocator : Allocator, newline := false) -> string { return aprint(AS_BOOL_PTR(value),sep ="",allocator=allocator)  }
aprint_float  :: proc(value: ^Value,allocator : Allocator, newline := false) -> string { return aprint(AS_FLOAT_PTR(value),sep ="",allocator=allocator) }

aprint_vec2   :: proc(value: ^Value, allocator : Allocator, newline := false) -> string 
{ 
	vec2 := AS_VECTOR2_PTR(value); 
	return aprint("Vec2(",vec2.x,",",vec2.y,")",sep ="",allocator=allocator) 
}

aprint_complex :: proc(value: ^Value, allocator : Allocator, newline := false) -> string 
{ 
	complex := REINTERPRET_MEM_PTR(value,Complex)
	return aprint("Complex(",complex.x,",",complex.y,")",sep ="",allocator=allocator) 
}

aprint_rect2  :: proc(value: ^Value, allocator : Allocator, newline := false) -> string 
{ 
	rect2 := AS_RECT2_PTR(value)
	pos   := &rect2[0] 
	size  := &rect2[1] 
	return aprint("Rect2(",pos.x,",",pos.y,",",size.x,",",size.y,")",sep ="",allocator=allocator) 
}

aprint_color  :: proc(value: ^Value, allocator : Allocator, newline := false) -> string
{ 
	color := AS_COLOR_PTR(value)
	return aprint("Color(",color[0],",",color[1],",",color[2],",",color[3],")",sep ="",allocator=allocator) 
}

aprint_range  :: proc(value: ^Value, allocator : Allocator, newline := false) -> string
{
	range := AS_NUOOBECT_PTR(value,Range)
	return aprint(aprint_any(&range.from,allocator,newline),aprint("..","",sep ="",allocator=allocator),aprint_any(&range.to,allocator,newline),"",sep ="",allocator=allocator)
}

aprint_bound  :: proc(value: ^Value, allocator : Allocator, newline := false) -> string
{
	bound := AS_NUOOBECT_PTR(value,BoundMethod)
	return aprint_any(&bound.method,allocator,newline)
}


aprint_nfunction :: proc(value: ^Value, allocator : Allocator, newline := false) -> string
{ fid := AS_INT_PTR(value); return aprint("function '",function_db_get_name(fid),"'",sep ="",allocator=allocator) }

aprint_class     :: proc(value: ^Value, allocator : Allocator, newline := false) -> string
{ cid := AS_INT_PTR(value); return aprint("Class '",class_db_get_class_name(cid),"'",sep ="",allocator=allocator) }

aprint_import    :: proc(value: ^Value, allocator : Allocator, newline := false) -> string
{ iid := AS_INT_PTR(value); return aprint("Import '",import_db_name(iid),"'",sep ="",allocator=allocator) }

aprint_instance  :: proc(value: ^Value, allocator : Allocator, newline := false) -> string
{ instance := AS_NUOOBECT_PTR(value,NuoInstance); return aprint("instance of ",class_db_get_class_name(instance.cid),sep ="",allocator=allocator) }

aprint_aany       :: proc(value: ^Value,allocator : Allocator, newline := false) -> string { return aprint("<Reference#%p>",AS_NUOOBECT_PTR(value,Any),sep ="",allocator=allocator)}


aprint_callable     :: proc(value: ^Value,allocator : Allocator, newline := false) -> string
{
	callable := AS_NUOOBECT_PTR(value,NuoCallable)
	r        := aprint("Callable(",aprint_any(&callable.callable,allocator,newline),")",sep ="",allocator=allocator)
	return r
}

aprint_task     :: proc(value: ^Value,allocator : Allocator, newline := false) -> string
{
	r  := aprint("@Task",sep ="",allocator=allocator)
	return r
}



aprint_array     :: proc(value: ^Value,allocator : Allocator, newline := false) -> string
{
	array := AS_NUOOBECT_PTR(value,NuoArray)
	data  := &array.data
	len   := len(data)
	
	      recursion_count += 1
	defer recursion_count -= 1

	if recursion_count >= MaxPrinter do return aprint("[...]",sep ="",allocator=allocator)

	r := aprint("[","",sep ="",allocator=allocator)

	for &content,indx in array.data
	{ 
		r = aprint(r,aprint_any(&content,allocator,newline),sep ="",allocator=allocator)
		if indx+1 != len do r = aprint(r,",",sep="",allocator=allocator)
		if recursion_count >= MaxPrinter { r = aprint(r,"[...]",sep ="",allocator=allocator); break }
	}
			
	return aprint(r,"]",sep ="",allocator=allocator)

}

aprint_map    :: proc(value: ^Value,allocator : Allocator, newline := false) -> string
{
	map_  := AS_NUOOBECT_PTR(value,NuoMap)
	data  := &map_.data
	len   := len(data)
	
	      recursion_count += 1
	defer recursion_count -= 1



	if recursion_count >= MaxPrinter do return aprint("{...}",sep ="",allocator=allocator)

	r := aprint("{","",sep ="",allocator=allocator)
	idx := 0

	for _,&me in data
	{ 
		r = aprint(r,aprint_any(&me.key,allocator,newline),sep ="",allocator=allocator)
		r = aprint(r,":",aprint_any(&me.value,allocator,newline),sep ="",allocator=allocator)
		
		if idx+1 != len do r = aprint(r,",","",sep ="",allocator=allocator)
		if recursion_count >= MaxPrinter { r = aprint(r,"{...}",sep ="",allocator=allocator); break }

		idx += 1
	}
			
	return aprint(r,"}",sep ="",allocator=allocator)
}


aprint_transform2D  :: proc(value: ^Value,allocator : Allocator, newline := false) -> string 
{ 
	t   := AS_NUOOBECT_PTR(value,Transform2D)
	x   := &t.data[0]
	y   := &t.data[1]
	o   := &t.data[2]
  	return aprint("Transform2D((",x.x,",",x.y,"),(",y.x,",",y.y,"),(",o.x,",",o.y,"))",sep ="",allocator=allocator) 
}

aprint_string    :: proc(value: ^Value, allocator : Allocator, newline := false) -> string
{ nuo_string := AS_NUOOBECT_PTR(value,NuoString); return aprint("\"",to_string(nuo_string.data),"\"","",sep ="",allocator=allocator) }

aprint_signal    :: proc(value: ^Value, allocator : Allocator, newline := false) -> string
{ return aprint("@Signal",sep ="",allocator=allocator) }


aprint_values :: proc(values: []Value,allocator : Allocator, newline := false) -> string
{
	l  := len(values)
	r  := aprint(NuoOut,sep ="",allocator=allocator)

	for &value,index in values
	{
		r = aprint(r,aprint_any(&value,allocator,newline),sep ="",allocator=allocator)
		if index < l-1 do r = aprint(r,",",sep ="",allocator=allocator)
	}

	return aprint(r,'\n',sep ="",allocator=allocator)
}

aprint_any :: proc(value: ^Value,allocator : Allocator, newline := false, max_r := 0) -> string
{
	#partial switch GET_VARIANT_TYPE(value)
	{
		case .NIL     : return aprint_nil(allocator,newline)
		case .INT     : return aprint_int(value,allocator,newline)
		case .FLOAT   : return aprint_float(value,allocator,newline)
		case .BOOL    : return aprint_bool(value,allocator,newline)

		case .VECTOR2     : return aprint_vec2(value,allocator,newline)
		case .RECT2       : return aprint_rect2(value,allocator,newline)
		case .COLOR       : return aprint_color(value,allocator,newline)
		case .COMPLEX     : return aprint_complex(value,allocator,newline)

		case .TRANSFORM2D  : return aprint_transform2D(value,allocator,newline)
		case .ANY          : return aprint_aany(value,allocator,newline)
		case .RANGE        : return aprint_range(value,allocator,newline)
		case .BOUND_METHOD : return aprint_bound(value,allocator,newline)

		case .NFUNCTION : return aprint_nfunction(value,allocator,newline)
		case .CLASS     : return aprint_class(value,allocator,newline)
		case .IMPORT    : return aprint_import(value,allocator,newline)

		case .STRING   : return aprint_string(value,allocator,newline)
		case .INSTANCE : return aprint_instance(value,allocator,newline)
		case .SIGNAL   : return aprint_signal(value,allocator,newline)
		case .RID      : return aprint_rid(allocator,newline)

		case .ARRAY    : return aprint_array(value,allocator,newline)
		case .MAP      : return aprint_map(value,allocator,newline)
		case .CALLABLE : return aprint_callable(value,allocator,newline)
		case .TASK     : return aprint_task(value,allocator,newline)


		case            : return aprint(GET_VARIANT_TYPE(value)," not handler.","",sep ="",allocator=allocator)
	}
}


