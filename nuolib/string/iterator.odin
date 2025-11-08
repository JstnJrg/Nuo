package String

/*
	Iterador: para priorizar a velocidade, convém não fazer checagens,
	esses metodos presumem que serão chamadas conforme a interface estabelecia
*/

/*
	Nota(jstn): devolve um estado para a função next (não devolve o conteudo em sí)
	devolve um indx, que é o indx actual
*/


StringIterator :: struct
{
	data  : ^UFT8String,
	t     : Arena_Temp,
	it    : int
}

iterate :: proc(ctx: ^Context) 
{
	cs      := ctx.call_state
	_string := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)

	//Nota(jstn): começa a iteração
	if IS_VARIANT_PTR(ctx.peek_value(0),.NIL) 
	{
		t         := ctx.init_runtime_temp()
		allocator := ctx.get_runtime_allocator()

		iterator  := new(StringIterator,allocator)
		data      := new(UFT8String,allocator)

		iterator.t    = t
		iterator.data = data
		UTF8Init(data,to_string(_string))

		ptr          := (uintptr)(iterator)
		RID_VAL_PTR(cs.result,&ptr)
		return 
	}

	ptr           := REINTERPRET_MEM(ctx.peek_value(0),uintptr)
	s_iterator    := (^StringIterator)(ptr)
	s_iterator.it += 1

	RID_VAL_PTR(cs.result,&ptr)
}

end :: proc(ctx: ^Context) 
{
	cs      := ctx.call_state
	_string := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoString)

	ptr        := REINTERPRET_MEM(ctx.peek_value(0),uintptr)
	s_iterator := (^StringIterator)(ptr)
	_end       := s_iterator.it < UTF8Len(s_iterator.data)
	
	BOOL_VAL_PTR(cs.result,_end)
}

next :: proc(ctx: ^Context) 
{
	cs         := ctx.call_state

	ptr        := REINTERPRET_MEM(ctx.peek_value(0),uintptr)
	s_iterator := (^StringIterator)(ptr)
	len        := UTF8Len(s_iterator.data)
	
	it         := s_iterator.it

	if it < len
	{
		at := UTF8At(s_iterator.data,it)
		n  := create_obj_string()

		nuostring_write_rune(at,n)
		NUOOBJECT_VAL_PTR(cs.result,n)
		return
	}

	NIL_VAL_PTR(cs.result)
}

cleanup :: proc(ctx: ^Context) 
{
	ptr      := REINTERPRET_MEM(ctx.peek_value(0),uintptr)
	iterator := (^StringIterator)(ptr)
	
	ctx.end_runtime_temp(iterator.t)
	NIL_VAL_PTR(ctx.call_state.result)
}


