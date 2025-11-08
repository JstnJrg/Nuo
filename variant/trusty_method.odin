package Variant

TypeSet       :: Visibility

SAFE_MAX_ARGS :: 7

SafeMethod    :: struct
{
	callable   : Ofunction,
	args_types : [SAFE_MAX_ARGS]VariantType,
	argc       : u8
}

safe_argument      :: proc(value: ^Value, $T: typeid) -> T 
{
	#partial switch type
	{
		case .NIL    	: return nil

		case .BOOL   	: return AS_BOOL_PTR(value)
		case .FLOAT     : return AS_FLOAT_PTR(value)
		case .INT 		: return AS_INT_PTR(value)
		case .STRING    : return to_string(AS_NUOOBECT_PTR(value,NuoString).data)

		case .SYMID     : return nil

		case .VECTOR2     : return AS_VECTOR2_PTR(value)
		case .COMPLEX     : return REINTERPRET_MEM_PTR(value,Complex)
		case .RECT2       : return AS_RECT2_PTR(value)

		case .COLOR       : return AS_COLOR_PTR(value)
		case .RID         : return &value._mem
		case .TRANSFORM2D : return AS_NUOOBECT_PTR(value,Transform2D)
		case .RANGE       : return AS_NUOOBECT_PTR(value,Range)

		case .SIGNAL      : return AS_NUOOBECT_PTR(value,NuoSignal)
		case .CALLABLE    : return AS_NUOOBECT_PTR(value,NuoCallable)

		case .TASK        : return nil

		case .BOUND_METHOD : return AS_NUOOBECT_PTR(value,BoundMethod)
		case .NFUNCTION    : return AS_INT_PTR(value)
		case .OFUNCTION    : return REINTERPRET_MEM_PTR(value,Ofunction)

		case .INSTANCE     : return AS_NUOOBECT_PTR(value,NuoInstance)
		case .ARRAY	       : return AS_NUOOBECT_PTR(value,NuoArray)
		case .MAP          : return AS_NUOOBECT_PTR(value,NuoMap)

		case .ANY        : return AS_NUOOBECT_PTR(value,Any)
		case .CLASS      : return AS_INT_PTR(value)
		case .IMPORT     : return AS_INT_PTR(value)

		case 			 : return nil
	}
}

safe_check_args    :: #force_inline proc "contextless" (sm: ^SafeMethod, ctx: ^Context) -> bool
{
	cs       := ctx.call_state
	sargc    := int(sm.argc)

	( sargc == cs.argc) or_return

	types    := sm.args_types[0:][:sargc]
	args     := cs.args

	for i in 0..< sargc do (types[i] == args[i].type) or_return

	return true
}











