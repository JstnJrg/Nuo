package Variant


VARIANT_VAL     :: proc {NIL_VAL,INT_VAL,BOOL_VAL,FLOAT_VAL,NUOOBJECT_VAL}
VARIANT_VAL_PTR :: proc {NIL_VAL_PTR,INT_VAL_PTR,FLOAT_VAL_PTR,BOOL_VAL_PTR,NUOOBJECT_VAL_PTR}

FLOAT_VAL   :: #force_inline proc "contextless" (value: Float)  -> Value      
{ 
	variant : Variant
	variant._float = value
	return Value{variant,.FLOAT} 
}
INT_VAL     :: #force_inline proc "contextless" (value: Int)    -> Value      
{
	variant : Variant
	variant._int = value
	return Value{variant,.INT}   
}

BOOL_VAL    :: #force_inline proc "contextless" (value: bool)   -> Value      
{ 
	variant : Variant
	variant._bool = value
	return Value{variant,.BOOL}  
}
NIL_VAL     :: #force_inline proc "contextless" () -> Value { return Value{{}, .NIL}    }

SYMID_VAL   :: #force_inline proc "contextless" (sid: Int)    -> Value      
{
	variant : Variant
	variant._int = sid
	return Value{variant,.SYMID}   
}


VECTOR2_VAL  :: #force_inline proc "contextless" (v : Vec2)	-> Value 
{
	variant : Variant; v := v
	COPY_DATA(&variant._mem,&v)
	return Value{variant,.VECTOR2}
}

NUOOBJECT_VAL   :: #force_inline proc "contextless" (obj: ^NuoObject) -> Value
{
	variant : Variant
	variant._obj = obj
	return Value{variant,obj.type}	
}

NUOFUNCTION_VAL :: #force_inline proc "contextless" (fid: int) -> Value
{
	variant : Variant
	variant._int = fid
	return Value{variant,.NFUNCTION}	
}

ODINFUNCTION_VAL :: #force_inline proc "contextless" (fn: Ofunction) -> Value
{
	variant : Variant
	fn      := fn
	COPY_DATA(&variant._mem,&fn)
	return Value{variant,.OFUNCTION}	
}

IMPORT_VAL :: #force_inline proc "contextless" (iid: int) -> Value
{
	variant : Variant
	variant._int = iid
	return Value{variant,.IMPORT}	
}

CLASS_VAL :: #force_inline proc "contextless" (cid: int) -> Value
{
	variant : Variant
	variant._int = cid
	return Value{variant,.CLASS}	
}

// ANY_VAL :: #force_inline proc "contextless" (D: ^$T , id: int, etype: VariantType) -> Value
// {
// 	_any       : Any(T)
// 	_any.data  = D
// 	_any.id    = id
// 	_any.etype = etype

// 	variant : Variant
// 	COPY_DATA(variant._mem,&_any)
// 	return Value{variant,.ANY}	
// }




FLOAT_VAL_PTR        :: #force_inline proc "contextless" (value: ^Value, data : Float) {   value.type = .FLOAT ; value.variant._float = data }
INT_VAL_PTR          :: #force_inline proc "contextless" (value: ^Value, data: Int)   { value.type = .INT  ; value.variant._int = data  }
BOOL_VAL_PTR         :: #force_inline proc "contextless" (value: ^Value, data: bool)  { value.type = .BOOL ; value.variant._bool =  data }
NIL_VAL_PTR          :: #force_inline proc "contextless" (value: ^Value)			     { value.type = .NIL ; value.variant =  {}   }


ODINFUNCTION_VAL_PTR :: #force_inline proc "contextless" (value: ^Value,fn: Ofunction) { fn := fn; COPY_DATA(&value.variant._mem,&fn) }
IMPORT_VAL_PTR       :: #force_inline proc "contextless" (value: ^Value, data: Int)   { value.type = .IMPORT  ; value.variant._int = data  }


NUOOBJECT_VAL_PTR    :: #force_inline proc "contextless" (value: ^Value,obj: ^NuoObject) 
{
	value.type         = obj.type
	value.variant._obj = obj	
}


VARIANT2VARIANT_PTR :: #force_inline proc "contextless" (from,to: ^Value) { to^ = from^ }

COPY_DATA     :: #force_inline proc "contextless" (buffer: ^Buffer, data : ^$T)   { mcopy(buffer,data,size_of(T)) }


VECTOR2_VAL_PTR  :: #force_inline proc "contextless" (value: ^Value, v: ^Vec2)	
{
	COPY_DATA(&value.variant._mem,v)
	value.type = .VECTOR2
}

RECT2_VAL_PTR  :: #force_inline proc "contextless" (value: ^Value, rect2: ^Rect2)	
{
	COPY_DATA(&value.variant._mem,rect2)
	value.type = .RECT2
}

COLOR_VAL_PTR  :: #force_inline proc "contextless" (value: ^Value, color: ^Color)	
{
	COPY_DATA(&value.variant._mem,color)
	value.type = .COLOR
}

RID_VAL_PTR  :: #force_inline proc "contextless" (value: ^Value, data: ^$T)	
{
	COPY_DATA(&value.variant._mem,data)
	value.type = .RID
}
// ANY_VAL_PTR    :: #force_inline proc "contextless" (value: ^Value, D: ^$T , id: int, etype: VariantType) -> Value
// {
// 	_any       : Any(T)
// 	_any.data  = D
// 	_any.id    = id
// 	_any.etype = etype

// 	COPY_DATA(&value.variant._mem,&_any)
// 	value.type = .ANY	
// }