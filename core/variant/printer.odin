package Variant



NuoOut          :: `Nuo:> `
MaxPrinter      :: 2
recursion_count := 0 


print_nil    :: proc() { print("null")   }
print_rid    :: proc() { print("@RID")   }
print_int    :: proc(value: ^Value) { print(AS_INT_PTR(value))   }
print_bool   :: proc(value: ^Value) { print(AS_BOOL_PTR(value))  }
print_float  :: proc(value: ^Value) { print(AS_FLOAT_PTR(value)) }

print_vec2   :: proc(value: ^Value) { vec2 := AS_VECTOR2_PTR(value); print("Vec2(",vec2.x,",",vec2.y,")") }
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

		case .TRANSFORM2D : print_transform2D(value)
		case .ANY         : print_aany(value)
		case .RANGE       : print_range(value)

		case .NFUNCTION : print_nfunction(value)
		case .CLASS     : print_class(value)
		case .IMPORT    : print_import(value)

		case .STRING   : print_string(value)
		case .INSTANCE : print_instance(value)
		case .SIGNAL   : print_signal(value)
		case .RID      : print_rid()

		case .ARRAY    : print_array(value)
		case .MAP      : print_map(value)


		case            : print(GET_VARIANT_TYPE(value)," not handler.")
	}
}




// =========================================

// to_debug_nil    :: proc(allocator: Allocator) -> string { return aprintf("\"%v\"","null",allocator) }
// to_debug_int    :: proc(value: ^Value,allocator: Allocator) -> string { return aprintf("\"%v\"",AS_INT_PTR(value),allocator)   }

// to_debug_bool   :: proc(value: ^Value,allocator: Allocator) -> string { return aprintf("\"%v\"",AS_BOOL_PTR(value),allocator)  }
// to_debug_float  :: proc(value: ^Value,allocator: Allocator) -> string { return aprintf("\"%v\"",AS_FLOAT_PTR(value),allocator) }

// to_debug_vec2   :: proc(value: ^Value,allocator: Allocator) -> string 
// { 
// 	vec2 := AS_VECTOR2_PTR(value);
// 	return aprintf("\"Vec2(%v,%v)\"",vec2.x,vec2.y,allocator)
// }

// to_debug_rect2  :: proc(value: ^Value,allocator: Allocator) -> string
// { 
// 	rect2 := AS_RECT2_PTR(value)
// 	pos   := &rect2[0] 
// 	size  := &rect2[1] 

// 	return aprintf("\"Rect2(%v,%v,%v,%v)\"",pos.x,pos.y,size.x,size.y,allocator) 
// }

// to_debug_color  :: proc(value: ^Value,allocator: Allocator) -> string
// { 
// 	color := AS_COLOR_PTR(value)
// 	return aprintf("\"Color(%v,%v,%v,%v)\"",color[0],color[1],color[2],color[3],allocator)
// }

// to_debug_range  :: proc(value: ^Value,allocator: Allocator) -> string
// {
// 	range := AS_NUOOBECT_PTR(value,Range)
// 	return aprintf("\"%v..%v\"",to_debug_string(&range.from,allocator),to_debug_string(&range.to,allocator),allocator)
// }

// to_debug_nfunction :: proc(value: ^Value,allocator: Allocator) -> string 
// { fid := AS_INT_PTR(value); print("function '",function_db_get_name(fid),"'") }


// to_debug_class     :: proc(value: ^Value,allocator: Allocator) -> string { cid := AS_INT_PTR(value); print("Class '",class_db_get_class_name(cid),"'") }
// to_debug_import    :: proc(value: ^Value,allocator: Allocator) -> string { iid := AS_INT_PTR(value); print("Import '",import_db_name(iid),"'") }
// to_debug_instance  :: proc(value: ^Value,allocator: Allocator) -> string { instance := AS_NUOOBECT_PTR(value,NuoInstance); print("instance of ",class_db_get_class_name(instance.cid)) }

// to_debug_any       :: proc(value: ^Value,allocator: Allocator) -> string { printf("<Reference#%p>",AS_NUOOBECT_PTR(value,Any))}

// to_debug_array     :: proc(value: ^Value,allocator: Allocator) -> string
// {
// 	array := AS_NUOOBECT_PTR(value,NuoArray)
// 	data  := &array.data
// 	len   := len(data)
	
// 	      recursion_count += 1
// 	defer recursion_count -= 1

// 	if recursion_count >= MaxPrinter { print("[...]"); return }

// 	print("[")
// 	for &content,indx in array.data
// 	{ 
// 		print_any(&content)
// 		if indx+1 != len do print(",")
// 		if recursion_count >= MaxPrinter { print("[...]"); break }
// 	}
			
// 	print("]")

// }

// to_debug_map    :: proc(value: ^Value,allocator: Allocator) -> string
// {
// 	map_  := AS_NUOOBECT_PTR(value,NuoMap)
// 	data  := &map_.data
// 	len   := len(data)
	
// 	      recursion_count += 1
// 	defer recursion_count -= 1

// 	if recursion_count >= MaxPrinter { print("{...}"); return }

// 	print("{")
// 	idx := 0

// 	for _,&me in data
// 	{ 
// 		print_any(&me.key)
// 		print(":")
// 		print_any(&me.value)
		
// 		if idx+1 != len do print(",")
// 		if recursion_count >= MaxPrinter { print("{...}"); break }

// 		idx += 1
// 	}
			
// 	print("}")

// }


// to_debug_transform2D  :: proc(value: ^Value,allocator: Allocator) -> string
// { 
// 	t   := AS_NUOOBECT_PTR(value,Transform2D)
// 	x   := &t.data[0]
// 	y   := &t.data[1]
// 	o   := &t.data[2]
//   	print("Transform2D((",x.x,",",x.y,"),(",y.x,",",y.y,"),(",o.x,",",o.y,"))") 
// }

// to_debug_string    :: proc(value: ^Value,allocator: Allocator) -> string { nuo_string := AS_NUOOBECT_PTR(value,NuoString); print("\"",to_string(nuo_string.data),"\"") }
// to_debug_signal    :: proc(value: ^Value,allocator: Allocator) -> string { print("@Signal") }



// to_debug_string :: proc(value: ^Value, allocator: Allocator) -> string
// {
// 	#partial switch GET_VARIANT_TYPE(value)
// 	{
// 		case .NIL     : print_nil()
// 		case .INT     : print_int(value)
// 		case .FLOAT   : print_float(value)
// 		case .BOOL    : print_bool(value)

// 		case .VECTOR2     : print_vec2(value)
// 		case .RECT2       : print_rect2(value)
// 		case .COLOR       : print_color(value)

// 		case .TRANSFORM2D : print_transform2D(value)
// 		case .ANY         : print_aany(value)
// 		case .RANGE       : print_range(value)

// 		case .NFUNCTION : print_nfunction(value)
// 		case .CLASS     : print_class(value)
// 		case .IMPORT    : print_import(value)

// 		case .STRING   : print_string(value)
// 		case .INSTANCE : print_instance(value)
// 		case .SIGNAL   : print_signal(value)

// 		case .ARRAY    : print_array(value)
// 		case .MAP      : print_map(value)


// 		case            : print(GET_VARIANT_TYPE(value)," not handler.")
// 	}
// }







