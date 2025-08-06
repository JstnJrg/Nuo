package Variant


AS_FLOAT    :: #force_inline proc "contextless" (value: Value) -> Float 	{ return value.variant._float }
AS_INT	    :: #force_inline proc "contextless" (value: Value) -> Int   	{ return value.variant._int   }
AS_BOOL     :: #force_inline proc "contextless" (value: Value) -> bool  	{ return value.variant._bool  }

AS_FLOAT_PTR    :: #force_inline proc "contextless" (value: ^Value) -> Float 	{ return value.variant._float }
AS_INT_PTR	    :: #force_inline proc "contextless" (value: ^Value) -> Int   	{ return value.variant._int   }
AS_SYMID_PTR    :: #force_inline proc "contextless" (value: ^Value) -> Int   	{ return value.variant._int   }
AS_BOOL_PTR     :: #force_inline proc "contextless" (value: ^Value) -> bool  	{ return value.variant._bool  }

AS_VECTOR2_PTR  :: #force_inline proc "contextless" (value: ^Value) -> ^Vec2  { return (^Vec2)(&value.variant._mem) }
AS_RECT2_PTR    :: #force_inline proc "contextless" (value: ^Value) -> ^Rect2 { return (^Rect2)(&value.variant._mem) }
AS_COLOR_PTR    :: #force_inline proc "contextless" (value: ^Value) -> ^Color { return (^Color)(&value.variant._mem) }

AS_NUOOBECT_PTR :: proc{AS_NUOOBECT_PTR1,AS_NUOOBECT_PTR2}

AS_NUOOBECT_PTR1 :: #force_inline proc "contextless" (value: ^Value) -> ^NuoObject { return value.variant._obj }
AS_NUOOBECT_PTR2 :: #force_inline proc "contextless" (value: ^Value, $T: typeid) -> ^T { return reinterpret_object(value.variant._obj,T) }


REINTERPRET_MEM     :: proc "contextless" (value: ^Value, $T: typeid) -> T  { return (^T)(&value.variant._mem)^ }
REINTERPRET_MEM_PTR :: proc "contextless" (value: ^Value, $T: typeid) -> ^T { return (^T)(&value.variant._mem) }
