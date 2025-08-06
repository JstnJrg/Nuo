package Range
import    "core:math/linalg"


_types         :: proc "contextless" (range : ^Range) -> (VariantType,VariantType,VariantType) { return range.from.type,range.to.type,range.step.type }

_values        :: proc "contextless" (range : ^Range) -> (^Value,^Value,^Value) { return &range.from,&range.to,&range.step }

_set_length    :: proc (range : ^Range, ctx: ^Context)
{ 
	a,b,s        := _types(range)
	from,to,step := _values(range)
	r0           := VARIANT_VAL(1)
	r            :  Value

	get_op_binary(.OP_SUB,b,a)(to,from,&r,ctx)
	get_op_binary(.OP_DIV,r.type,s)(&r,step,&r,ctx)
	get_op_binary(.OP_ADD,r.type,r0.type)(&r,&r0,&r,ctx)

	len : Float; IS_NUMERIC_PTR(&r,&len)
	range.length = len
}

_get_length :: proc "contextless" (range : ^Range) -> Float { return range.length }
_get_size   :: proc "contextless" (range: ^Range) -> int    { return int(range.length) }
_set_step   :: proc "contextless" (range : ^Range, s: ^Value) { _,_,step := _values(range); VARIANT2VARIANT_PTR(s,step) }


_check         :: proc (range: ^Range,ctx: ^Context)  -> (bool,bool)
{
	from,to,step := _values(range)
	zero_step    := INT_VAL(0)
	
	n_step       := ctx.peek_value(0)
	r            := ctx.call_state.result


	equal_function        := get_op_binary(.OP_EQUAL,n_step.type,zero_step.type) // n_setp == zerp
	a_b_less_function     := get_op_binary(.OP_LESS,from.type,to.type) // from < to
	b_a_less_function     := get_op_binary(.OP_LESS,to.type,from.type) // to < from
	s_zero_less_function  := get_op_binary(.OP_LESS,n_step.type,zero_step.type) // n_step < zero
	zero_s_less_function  := get_op_binary(.OP_LESS,zero_step.type,n_step.type) // zero < n_step

	if equal_function(n_step,&zero_step,r,ctx); AS_BOOL_PTR(r) do return false,false
	if a_b_less_function(from,to,r,ctx);  AS_BOOL_PTR(r) do if s_zero_less_function(n_step,&zero_step,r,ctx);  AS_BOOL_PTR(r) do return true,false
	if a_b_less_function(from,to,r,ctx);  AS_BOOL_PTR(r) do if s_zero_less_function(n_step,&zero_step,r,ctx);  AS_BOOL_PTR(r) do return true,false
	if b_a_less_function(to,from,r,ctx);  AS_BOOL_PTR(r) do if zero_s_less_function(&zero_step,n_step,r,ctx);  AS_BOOL_PTR(r) do return true,false

	return true,true
}


_contains     :: proc (range: ^Range, value: ^Value,ctx: ^Context)  -> bool
{
	from,to,step := _values(range)
	zero         := VARIANT_VAL(0)
	epsilon      := Float(0.0001)
	epsilon_     := VARIANT_VAL(epsilon)
	r            := ctx.call_state.result
	r2,r3        : Value

	get_op_binary(.OP_SUB,from.type,epsilon_.type)(from,&epsilon_,&r2,ctx)
	get_op_binary(.OP_ADD,to.type,epsilon_.type)(to,&epsilon_,&r3,ctx)

	a := get_op_binary(.OP_LESS,zero.type,step.type)  
	b := get_op_binary(.OP_LESS,value.type,r2.type)
	c := get_op_binary(.OP_LESS,r3.type,value.type)

	
	if a(&zero,step,r,ctx); AS_BOOL_PTR(r)
	{
		if b(value,&r2,r,ctx); AS_BOOL_PTR(r) do return false
		if c(&r3,value,r,ctx); AS_BOOL_PTR(r) do return false
	}

	get_op_binary(.OP_ADD,from.type,epsilon_.type)(from,&epsilon_,&r2,ctx)
	get_op_binary(.OP_SUB,to.type,epsilon_.type)(to,&epsilon_,&r3,ctx)

	a  = get_op_binary(.OP_LESS,step.type,zero.type)  
	b  = get_op_binary(.OP_LESS,r2.type,value.type)
	c  = get_op_binary(.OP_LESS,value.type,r3.type) 


	if a(step,&zero,r,ctx); AS_BOOL_PTR(r)
	{
		if b(&r2,value,r,ctx); AS_BOOL_PTR(r) do return false
		if c(value,&r3,r,ctx); AS_BOOL_PTR(r) do return false
	}

	get_op_binary(.OP_SUB,value.type,from.type)(value,from,r,ctx)
	get_op_binary(.OP_DIV,r.type,step.type)(r,step,r,ctx)

	l : Float; IS_NUMERIC_PTR(r,&l)
	return linalg.abs(l-linalg.round(l)) < epsilon
}



_reverse  :: proc (range: ^Range,ctx: ^Context)
{
	_,_,s        := _types(range)
	from,to,step := _values(range)
	r            := ctx.call_state.result

	VARIANT2VARIANT_PTR(to,r)
	VARIANT2VARIANT_PTR(from,to)
	VARIANT2VARIANT_PTR(r,from)

	get_op_unary(.OP_NEGATE,s)(nil,step,step,ctx)	
}

_at  :: proc (range: ^Range, indx: ^Value,ctx: ^Context)
{
	_,_,s        := _types(range)
	from,to,step := _values(range)
	r            := ctx.call_state.result

	get_op_binary(.OP_MULT,step.type,indx.type)(step,indx,r,ctx)
	get_op_binary(.OP_ADD,from.type,r.type)(from,r,indx,ctx)

	if _contains(range,indx,ctx) do VARIANT2VARIANT_PTR(indx,r)
	else do NIL_VAL_PTR(r)
}

_to_array  :: proc (range: ^Range,ctx: ^Context)
{
	_,_,s        := _types(range)
	from,to,step := _values(range)
	size         := _get_length(range)
	r            := ctx.call_state.result
		
	array        := create_obj_array()
	data         := &array.data
	size          = linalg.floor(size)

	resize(data,int(size))

	for i in 0..< int(size) 
	{ 
		value := VARIANT_VAL(i)
		get_op_binary(.OP_MULT,step.type,value.type)(step,&value,r,ctx)
		get_op_binary(.OP_ADD,from.type,r.type)(from,r,r,ctx)
		VARIANT2VARIANT_PTR(r,&data[i])
	}

	NUOOBJECT_VAL_PTR(r,array)
}