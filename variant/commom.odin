package Variant



VARIANNT_DEBUG :: proc()
{
	println("==================================================================")

	println("[VALUE SIZE] ----> ",size_of(Value))
	println("[STACK SIZE] ----> ",STACK_SIZE)
	println("[FRAME SIZE] ----> ",MAX_FRAMES)

	println("[Vec2] ---------> ",size_of(Vec2))
	println("[Buffer] -------> ",size_of(Buffer))

	println("[Rect2] --------> ",size_of(Rect2))
	println("[Transform2] ---> ",size_of(Transform2D))
	println("[Any] ----------> ",size_of(Any))
	println("[Callable] -----> ",size_of(NuoCallable))
	println("[SafeMethod] ---> ",size_of(SafeMethod))

	println("==================================================================")
}




GET_VARIANT_TYPE         :: proc "contextless" (value: ^Value) -> VariantType { return value.type }
BOOLEANIZE               :: #force_inline proc "contextless" (value: ^Value)  -> bool { return !IS_ZERO(value) }

EXPOSED                  :: #force_inline proc "contextless" (value: ^Value, v: ^Visibility ) -> bool { return value.type in v }

// peek_value               :: proc "contextless" (args: []Value,indx: int) -> ^Value { return &args[indx] }


GET_TYPE_NAME            :: #force_inline proc "contextless" (type: VariantType) -> string
{
	@static value : Value
	value.type    = type
	return GET_VARIANT_TYPE_NAME(&value)
}

GET_TYPE                 :: #force_inline proc "contextless" (value: ^Value) -> VariantType { return value.type }

GET_VARIANT_TYPE_NAME    :: #force_inline proc "contextless" (value: ^Value) -> string
{
	#partial switch value.type
	{
		case .NIL    	: return "nil"
		case .BOOL   	: return "bool"
		case .FLOAT     : return "float"
		case .INT 		: return "int"
		case .STRING    : return "String"

		case .SYMID     : return "String"


		// case .RECT2_VAL		: return "Rect2"
		// // case .COLOR_VAL		: return "Color"

		case .VECTOR2     : return "Vec2"
		case .COMPLEX     : return "Complex"
		case .RECT2       : return "Rect2"
		case .COLOR       : return "Color"

		case .RID         : return "RID"
		case .TRANSFORM2D : return "Transform2D"
		case .RANGE       : return "Range"
		case .SIGNAL      : return "Signal"

		case .CALLABLE    : return "Callable"
		case .TASK        : return "Task"

		case .BOUND_METHOD : fallthrough
		case .NFUNCTION    : fallthrough
		case .SFUNCTION    : fallthrough
		case .OFUNCTION    : return "function"

		case .INSTANCE   : return "Class instance"
		case .ARRAY	     : return "Array"
		case .MAP        : return "Dictionary"

		// case .OBJ_ENUM      : return "enum"

		// case .OBJ_ANY       : return "@Any"
		// case .OBJ_STRING    : return "String"
		case .CLASS      : return "Class"
		case .IMPORT     : return "Import"
		// // case .O

		// case .OBJ_CLASS_INSTANCE				: return "class instance"
		// case .NATIVE_OP_FUNC_VAL, .OBJ_FUNCTION : return "function"
		// case .OBJ_NATIVE_CLASS 					: return "OScriptNativeClass"
		// case .OBJ_PACKAGE						: return "Package"
		// // case .OBJ_CLASS                         : return "class"
		case 				: return "<!>"
	}
}

IS_ZERO  :: proc "contextless" (value: ^Value) -> bool 
{
	#partial switch value.type 
	{
		case .NIL    		: return true
		case .INT			: return AS_INT_PTR(value)    == 0
		case .FLOAT		    : return AS_FLOAT_PTR(value)  == 0.0
		case .BOOL 			: return !AS_BOOL_PTR(value)

		case .VECTOR2       : return AS_VECTOR2_PTR(value)^              == Vec2{0,0}
		case .COMPLEX       : return REINTERPRET_MEM_PTR(value,Complex)^ == Complex{0,0}
		case .RECT2         : return AS_RECT2_PTR(value)^                == Rect2{Vec2{0,0}, Vec2{0,0}}
		case .COLOR         : return AS_COLOR_PTR(value)^                == Color{0,0,0,0}

		case .STRING        : return to_string(AS_NUOOBECT_PTR(value,NuoString).data) == ""
		case .TRANSFORM2D   : return AS_NUOOBECT_PTR(value,Transform2D).data          == mat2x3{0,0,0,0,0,0}

		case .SIGNAL        : return len(AS_NUOOBECT_PTR(value,NuoSignal).data)   == 0
		case .CALLABLE      : return IS_ZERO(&AS_NUOOBECT_PTR(value,NuoCallable).callable)

		case .ARRAY         : return len(AS_NUOOBECT_PTR(value,NuoArray).data) == 0
		case .MAP           : return len(AS_NUOOBECT_PTR(value,NuoMap).data)   == 0

		case .SFUNCTION     : fallthrough
		case .OFUNCTION     : fallthrough
		case .CLASS         : fallthrough
		case .RID           : fallthrough
		case .INSTANCE      : fallthrough
		case .RANGE         : fallthrough
		case .ANY           : fallthrough
		case .BOUND_METHOD  : fallthrough
		case .IMPORT        : fallthrough
		case .NFUNCTION     : return false


		case 				: return true
	}
}

variant_hash :: proc (value : ^Value, rcount := 0, max_recursion := 100) -> u32
{

	if rcount  >= max_recursion      
	{ 
		when NUO_DEBUG do get_context().runtime_warning(false,"Max recursion reached.")
		return 0
	}


	#partial switch value.type
	{
		case .BOOL   	: return AS_BOOL_PTR(value) ? 1:0
		case .NIL    	: return 0
		case .INT 		: return one_64(AS_INT_PTR(value))
		case .FLOAT     : return murmur3_one_float(AS_FLOAT_PTR(value))


		case .STRING    : return hash_string(to_string(AS_NUOOBECT_PTR(value,NuoString).data))

		case .VECTOR2        : 

							  v := AS_VECTOR2_PTR(value)
							  h := murmur3_one_float(v.x)
							  h  = murmur3_one_float(v.y,h)
							  return fmix32(h)

		case .COMPLEX        : 

							  c := REINTERPRET_MEM_PTR(value,Complex)

							  h := hash_string("Complex")
							  h  = murmur3_one_float(c.x,h)
							  h  = murmur3_one_float(c.y,h)
							  return fmix32(h)

		case .RECT2          : 

							  r    := AS_RECT2_PTR(value)
							  pos  := &r[0]
							  size := &r[1]
							  
							  h := murmur3_one_float(pos.x)
							  h  = murmur3_one_float(pos.y,h)
							  h  = murmur3_one_float(size.x,h)
							  h  = murmur3_one_float(size.y,h)

							  return fmix32(h)

		case .COLOR          : 

							  c := AS_COLOR_PTR(value)
							  h := murmur3_one_32(c.r)
							  h  = murmur3_one_32(c.g,h)
							  h  = murmur3_one_32(c.b,h)
							  h  = murmur3_one_32(c.a,h)
							  return fmix32(h)

		case .TRANSFORM2D   : 

							 t   := AS_NUOOBECT_PTR(value,Transform2D)
							 mat := &t.data
							 x   := &mat[0]
							 y   := &mat[1]
							 o   := &mat[2]

							 h := murmur3_one_float(x.x)
							 h  = murmur3_one_float(x.y,h)
							 h  = murmur3_one_float(y.x,h)
							 h  = murmur3_one_float(y.y,h)
							 h  = murmur3_one_float(o.x,h)
							 h  = murmur3_one_float(o.y,h)
							 return fmix32(h)

		case .RANGE          :

							  range := AS_NUOOBECT_PTR(value,Range)
							  h     := variant_hash(&range.from)
							  h      = murmur3_one_32(variant_hash(&range.to),h)
							  h      = murmur3_one_32(variant_hash(&range.step),h)
							  return fmix32(h)



		case .ARRAY          : 
							  array_ := AS_NUOOBECT_PTR(value,NuoArray)
							  data   := &array_.data

							  h      := murmur3_one_32(VariantType.ARRAY)
							  for &v in data do h = murmur3_one_32(variant_hash(&v,rcount+1),h)
							  
							  return fmix32(h)

		case .MAP            : 
							  map_ := AS_NUOOBECT_PTR(value,NuoMap)
							  data   := &map_.data

							  h      := murmur3_one_32(VariantType.MAP)
							  for _,&me in data
							  {
							  	h = murmur3_one_32(variant_hash(&me.key,rcount+1),h)
							  	h = murmur3_one_32(variant_hash(&me.value,rcount+1),h)
							  }
							  
							  return fmix32(h)


		case .INSTANCE         : 

								h0 := (uintptr)(AS_NUOOBECT_PTR(value,NuoInstance))
								h  := one_64(h0)
								return fmix32(h)


		case .ANY         : 

								h0 := (uintptr)(AS_NUOOBECT_PTR(value,Any))
								h  := one_64(h0)
								return fmix32(h)

		case .SIGNAL            : 

								h0 := (uintptr)(AS_NUOOBECT_PTR(value,NuoSignal))
								h  := one_64(h0)
								return fmix32(h)

		case .CALLABLE          : 

								h0 := (uintptr)(AS_NUOOBECT_PTR(value,NuoCallable))
								h  := one_64(h0)
								return fmix32(h)

		case .BOUND_METHOD    :

								bound := AS_NUOOBECT_PTR(value,BoundMethod)
								h     := murmur3_one_32(variant_hash(&bound.method,rcount+1),variant_hash(&bound.this,rcount+1))
								return fmix32(h)

		case .OFUNCTION       : 

							  h0 := hash_string("ofunction")
							  id := (uintptr)(REINTERPRET_MEM_PTR(value,Ofunction))
							  h  := murmur3_one_32(id,h0)
							  return fmix32(h)

		case .SFUNCTION       : 

							  h0 := hash_string("ofunction")
							  id := (uintptr)(&REINTERPRET_MEM_PTR(value,SafeMethod).callable)
							  h  := murmur3_one_32(id,h0)
							  return fmix32(h)


		case .NFUNCTION 	  :
							  h  := hash_string("nfunction")
							  id := AS_INT_PTR(value)
							  h   = murmur3_one_32(id,h)
							  return fmix32(h)

		case .CLASS 	     :
							  h   := hash_string("Class")
							  cid := AS_INT_PTR(value)
							  h    = murmur3_one_32(cid,h)
							  return fmix32(h)
	
		case .IMPORT 	     :
							  h   := hash_string("Import")
							  iid := AS_INT_PTR(value)
							  h    = murmur3_one_32(iid,h)
							  return fmix32(h)


		case 				: return 0
	}
}

variant_hash_compare :: proc (value_a,value_b : ^Value, rcount: int, max_recursion := 100) -> bool
{

	if      value_a.type != value_b.type  do return false
	else if rcount  >= max_recursion      
	{ 
		when NUO_DEBUG do get_context().runtime_warning(false,"Max recursion reached.")
		return false 
	}

	#partial switch value_a.type
	{
		case .BOOL   	    : fallthrough
		case .NIL    	    : fallthrough
		case .INT 		    : fallthrough
		case .FLOAT         : fallthrough

		case .VECTOR2       : fallthrough
		case .COMPLEX       : fallthrough
		case .RECT2         : fallthrough

		case .STRING        : fallthrough
		case .RANGE         : fallthrough
		case .SIGNAL        : fallthrough
		case .CALLABLE      : fallthrough

		case .OFUNCTION     : fallthrough
		case .NFUNCTION     : fallthrough
		case .SFUNCTION     : fallthrough
		case .RID           : fallthrough 
		case .BOUND_METHOD  : fallthrough
		case .ANY           : fallthrough
		case .INSTANCE      : fallthrough

		case .TRANSFORM2D   : return variant_hash(value_a) == variant_hash(value_b)
		
		// 
		case .ARRAY		    : 

							 arr0  := AS_NUOOBECT_PTR(value_a,NuoArray)
    						 p0    := &arr0.data

							 arr1  := AS_NUOOBECT_PTR(value_b,NuoArray)
    						 p1    := &arr1.data

    						 len0  := len(p0)
    						 len1  := len(p1)

    						 min   := len0 > len1 ? len1:len0

    						 for i in 0..< min do variant_hash_compare(&p0[i],&p1[i],rcount+1,max_recursion) or_return

							 return true

		case .MAP            :

							 map_a := AS_NUOOBECT_PTR(value_a,NuoMap)
							 p0    := &map_a.data

							 map_b := AS_NUOOBECT_PTR(value_b,NuoMap)
							 p1    := &map_b.data

    						 len0  := len(p0)
    						 len1  := len(p1)

    						 if map_a == map_b do return true
    						 (len0 == len1 )   or_return


    						for hash, &me_a in p0
    						{
    							me_b,ok := p1[hash]
    							(ok && variant_hash_compare(&me_a.value,&me_b.value,rcount+1,max_recursion)) or_return
    						}

    						return true

		case 			: return false
	}


	return false
}