package Map

/*
	Iterador: para priorizar a velocidade, convém não fazer checagens,
	esses metodos presumem que serão chamadas conforme a interface estabelecia
*/

/*
	Nota(jstn): devolve um estado para a função next (não devolve o conteudo em sí)
	devolve um indx, que é o indx actual
*/


MapaIterator :: struct
{
	data  : []Value,
	t     : Arena_Temp,
	it    : int
}


iterate :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	_map  := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoMap)

	//Nota(jstn): começa a iteração

	if IS_VARIANT_PTR(ctx.peek_value(0),.NIL) 
	{
		t         := ctx.init_runtime_temp()
		allocator := ctx.get_runtime_allocator()
		iterator  := new(MapaIterator,allocator)
		data      := make([]Value,len(_map.data),allocator)
	
		iterator.t    = t
		iterator.data = data
		ptr          := (uintptr)(iterator)

		idx := 0
		for _,&me in _map.data { data[idx] = me.value; idx += 1 } 

		RID_VAL_PTR(cs.result,&ptr)
		return 
	}

	ptr           := REINTERPRET_MEM(ctx.peek_value(0),uintptr)
	mapa_iterator := (^MapaIterator)(ptr)
	mapa_iterator.it += 1

	RID_VAL_PTR(cs.result,&ptr)
}

end :: proc(ctx: ^Context) 
{
	cs     := ctx.call_state
	_map   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoMap)

	ptr    := REINTERPRET_MEM(ctx.peek_value(0),uintptr)
	mapa_iterator := (^MapaIterator)(ptr)

	_end   := mapa_iterator.it < len(_map.data)
	BOOL_VAL_PTR(cs.result,_end)
}

next :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state

	_map   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoMap)
	data   := &_map.data

	len    := len(data)
	ptr    := REINTERPRET_MEM(ctx.peek_value(0),uintptr)

	mapa_iterator := (^MapaIterator)(ptr)
	it            := mapa_iterator.it

	if it < len
	{
		value       := &mapa_iterator.data[it]
		ref_value(value)
		VARIANT2VARIANT_PTR(value,cs.result)
		return
	}

	NIL_VAL_PTR(cs.result)
}

cleanup :: proc(ctx: ^Context) 
{
	ptr           := REINTERPRET_MEM(ctx.peek_value(0),uintptr)
	mapa_iterator := (^MapaIterator)(ptr)

	ctx.end_runtime_temp(mapa_iterator.t)
	NIL_VAL_PTR(ctx.call_state.result)
}


