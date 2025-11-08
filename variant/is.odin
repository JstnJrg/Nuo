package Variant

IS_VARIANT_PTR   :: #force_inline proc "contextless" (value_p: ^Value, type: VariantType) -> bool { return value_p.type == type }


IS_CALLABLE_PTR      :: #force_inline proc "contextless" (value: ^Value) -> bool
{
	return IS_VARIANT_PTR(value,.OFUNCTION) || IS_VARIANT_PTR(value,.NFUNCTION) || IS_VARIANT_PTR(value,.BOUND_METHOD) || IS_VARIANT_PTR(value,.CALLABLE)
}

IS_CALLABLE_NO_RF_PTR :: #force_inline proc "contextless" (value: ^Value) -> bool
{
	return IS_VARIANT_PTR(value,.OFUNCTION) || IS_VARIANT_PTR(value,.NFUNCTION)
}

IS_VARIANT_SLICE :: #force_inline proc "contextless" (args: []Value,types : []VariantType) -> bool
{
	for &value, indx in args do if value.type != types[indx] do return false
	return true
}




IS_NUMERIC_PTR        :: proc{IS_NUMERIC_SLICE_PTR,IS_NUMERIC_PTR_1,IS_NUMERIC_PTR_2}


IS_NUMERIC_SLICE_PTR   :: #force_inline proc "contextless" (args: []Value) -> bool { for &value,indx in args do if value.type != .FLOAT && value.type != .INT do return false; return true }


IS_NUMERIC_PTR_1         :: #force_inline proc "contextless" (value: ^Value, to: ^$T ) -> bool
{
	#partial switch value.type
	{
		case .INT   :  to^ = T(AS_INT_PTR(value));   return true
		case .FLOAT :  to^ = T(AS_FLOAT_PTR(value)); return true
	}

	return false
}

IS_NUMERIC_PTR_2         :: #force_inline proc "contextless" (value: ^Value) -> bool
{
	#partial switch value.type
	{
		case .INT   :  return true
		case .FLOAT :  return true
	}

	return false
}



IS_INT_PTR         :: #force_inline proc "contextless" (value: ^Value, to: ^$T ) -> bool
{
	#partial switch value.type { case .INT   :  to^ = T(AS_INT_PTR(value));   return true }

	return false
}