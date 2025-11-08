package Variant

Transform2D :: struct 
{
	using _  : NuoObject,
	data     : mat2x3
}

Any :: struct 
{
	using _  : NuoObject,
	_mem     : Buffer,
	id       : int,
	etype    : VariantType
}

Range :: struct
{
	using _  : NuoObject,
	from     : Value, // só numericos
	to       : Value, // só numericos
	step     : Value, // só numericos
	length   : Float
}

BoundMethod ::struct
{
	using _  : NuoObject,
	method   : Value,
	this     : Value
}




create_transform2   :: proc{create_transform2_1,create_transform2_2}

create_transform2_1 :: proc(x_axis,y_axis,origin: ^Vec2) -> ^Transform2D 
{ 
	if has, obj := gc_peek_from_frees(.TRANSFORM2D); has 
	{
		t  := reinterpret_object(obj,Transform2D)

		mat := &t.data
		mat[0] = x_axis^
		mat[1] = y_axis^
		mat[2] = origin^	

		return t
	}

	t   := create_T(Transform2D,.TRANSFORM2D)
	mat := &t.data

	mat[0] = x_axis^
	mat[1] = y_axis^
	mat[2] = origin^

	return t
}

create_transform2_2 :: proc(_mat: ^mat2x3) -> ^Transform2D 
{
	if has, obj := gc_peek_from_frees(.TRANSFORM2D); has 
	{
		t  := reinterpret_object(obj,Transform2D)

		mat := &t.data
		mat^ = _mat^	

		return t
	}


	t   := create_T(Transform2D,.TRANSFORM2D)
	mat := &t.data
	mat^ = _mat^

	return t
}

create_any :: proc(etype: VariantType, id: int) -> ^Any
{
	if has, obj := gc_peek_from_frees(.ANY); has 
	{
		a      := reinterpret_object(obj,Any)
		a.etype = etype
		a.id    = id
		return a
	}


	a   := create_T(Any,.ANY)
	a.etype = etype
	a.id    = id
	return a
}

create_range :: proc(from, to : ^Value, dir : bool) -> ^Range
{
	if has, obj := gc_peek_from_frees(.RANGE); has 
	{
		r      := reinterpret_object(obj,Range)
		step   := INT_VAL(dir? 1:-1)

		VARIANT2VARIANT_PTR(from,&r.from)
		VARIANT2VARIANT_PTR(to,&r.to)
		VARIANT2VARIANT_PTR(&step,&r.step)			
		return r
	}


	r    := create_T(Range,.RANGE)
	step := INT_VAL(dir? 1:-1)

	VARIANT2VARIANT_PTR(from,&r.from)
	VARIANT2VARIANT_PTR(to,&r.to)
	VARIANT2VARIANT_PTR(&step,&r.step)	

	return r
}

create_bound_method :: proc(this, method: ^Value) -> ^BoundMethod
{
	ref_value(this) //Nota(jstn): a referencia da instancia	


	if has, obj := gc_peek_from_frees(.BOUND_METHOD); has 
	{
		bound := reinterpret_object(obj,BoundMethod)
		VARIANT2VARIANT_PTR(this,&bound.this)
		VARIANT2VARIANT_PTR(method,&bound.method)
		return bound
	}


	bound := create_T(BoundMethod,.BOUND_METHOD)

	VARIANT2VARIANT_PTR(this  ,&bound.this)
	VARIANT2VARIANT_PTR(method,&bound.method)

	return bound
}


