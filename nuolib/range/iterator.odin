package Range

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
	if IS_VARIANT_PTR(ctx.peek_value(0),.NIL) { INT_VAL_PTR(cs.result,0); return }
	INT_VAL_PTR(cs.result,AS_INT_PTR(ctx.peek_value(0))+1)
}

end :: proc(ctx: ^Context) 
{
	cs     := ctx.call_state
	range  := AS_NUOOBECT_PTR(ctx.peek_value(1),Range)
	BOOL_VAL_PTR(cs.result,AS_INT_PTR(ctx.peek_value(0)) < _get_size(range))
}

next :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	value := ctx.peek_value(0)

	range := AS_NUOOBECT_PTR(ctx.peek_value(1),Range)
	idx   := AS_INT_PTR(value)
	
    if idx < _get_size(range)
    {		
		from,_,step := _values(range)
		r           := cs.result; INT_VAL_PTR(value,idx)

		get_op_binary(.OP_MULT,value.type,step.type)(value,step,r,ctx)
		get_op_binary(.OP_ADD,from.type,r.type)(from,r,r,ctx)
				
        return
    }

    NIL_VAL_PTR(cs.result)
}

cleanup :: proc(ctx: ^Context) { NIL_VAL_PTR(ctx.call_state.result) }