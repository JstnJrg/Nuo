package Map

/*
	Iterador: para priorizar a velocidade, convém não fazer checagens,
	esses metodos presumem que serão chamadas conforme a interface estabelecia
*/

/*
	Nota(jstn): devolve um estado para a função next (não devolve o conteudo em sí)
	devolve um indx, que é o indx actual
*/
iterate :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state

	//Nota(jstn): começa a iteração
	if IS_VARIANT_PTR(ctx.peek_value(0),.NIL) { INT_VAL_PTR(cs.result,0); return }
	idx    := AS_INT_PTR(ctx.peek_value(0))+1
	INT_VAL_PTR(cs.result,idx)
}

end :: proc(ctx: ^Context) 
{
	cs     := ctx.call_state
	_map   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoMap)
	BOOL_VAL_PTR(cs.result,AS_INT_PTR(ctx.peek_value(0)) < len(_map.data))
}

next :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state

	_map   := AS_NUOOBECT_PTR(ctx.peek_value(1),NuoMap)
	data   := &_map.data

	len    := len(data)
	idx    := AS_INT_PTR(ctx.peek_value(0))

    if idx < len
    {
      it := 0 
    	for _,&me in data
    	{
    		if it == idx 
    		{
    			e := &me.value
    			ref_value(e); VARIANT2VARIANT_PTR(e,cs.result) 
    			return
    		}
    		it += 1
    	}
     }

    NIL_VAL_PTR(cs.result)
}