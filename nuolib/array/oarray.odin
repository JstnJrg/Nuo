package Array

_len 			:: proc(arr: ^$T/[dynamic]$E) -> int { return len(arr) }
_cap 			:: proc(arr: ^$T/[dynamic]$E) -> int { return cap(arr) }
_append 		:: proc(arr: ^$T/[dynamic]$E, what: []E) { append(arr,..what)  }

_shuffle     	:: proc(arr: ^$T/[dynamic]$E) { rshuffle(arr[:]) }
_choice     	:: proc (arr: ^$T/[dynamic]$E, result: ^Value) { result^ = rchoice(arr[:]) }

_resize         :: proc (arr: ^$T/[dynamic]$E, n: int) -> bool { return true if resize(arr,n) == nil else false } 


_equal_count    :: proc(arr: ^$T/[dynamic]$E, value_p : ^Value, ctx: ^Context,count := -1) -> (amount: int ) 
{
	r  := ctx.call_state.result

	for &value in arr
	{
		callee := get_op_binary(.OP_EQUAL,value_p.type,value.type)
		callee(&value,value_p,r,ctx)
		
		if AS_BOOL_PTR(r)
		{
			amount    += 1
			if amount == count do return
		}
	}

	return
}


_reverse  :: proc "contextless" (arr: ^$T/[dynamic]$E, len : int ) 
{
	i := 0; end := len-1

	for i < end
	{
		temp    := arr[i]
		arr[i]   = arr[end]
		arr[end] = temp

		i   += 1
		end -= 1
	}
} 



__clear        :: proc (arr: ^$T/[dynamic]$E) { clear(arr) } 

_quick_sort   :: proc (arr: ^$T/[dynamic]Value,r: ^Value,left,right : int, ctx: ^Context)
{
	i := left
	j := right
	m := (left+right)/2
	x := arr[m]

	for i <= j
	{
		l1 : for 
		{
			type_a := arr[i].type
			type_b := x.type

			callee := get_op_binary(.OP_LESS,type_a,type_b)
			callee(&arr[i],&x,r,ctx)

			( AS_BOOL_PTR(r) && i < right ) or_break l1
			i += 1					
		}

		l2 : for 
		{
			type_a := x.type
			type_b := arr[j].type
			
			callee := get_op_binary(.OP_LESS,type_a,type_b)
			callee(&x,&arr[j],r,ctx)

			( AS_BOOL_PTR(r) && j > left) or_break l2
			j -= 1					
		}

		if i <= j 
		{
			y     := arr[i]
			arr[i] = arr[j]
			arr[j] = y
			i += 1; j -= 1
		}       

	}

	if left < j     do _quick_sort(arr,r,left,j,ctx)
	if i    < right do _quick_sort(arr,r,i,right,ctx)
}



_shell_sort   :: proc (arr: ^$T/[dynamic]Value,r: ^Value, ctx: ^Context)
{
	gap : int
	x   : Value

	@(rodata,static)
	a := [?]int{9,5,3,2,1}

	n   := len(arr)
	m   := len(a)
	j,i : int

	for k in 0..<m
	{
		gap = a[k]

		for i = gap ; i < n; i += 1
		{
			x = arr[i]
			
			l3: for j = i-gap; j >= 0 ;
			{
				type_a := x.type
				type_b := arr[j].type

				callee := get_op_binary(.OP_LESS,type_a,type_b)
				callee(&x,&arr[j],r,ctx)

				if  AS_BOOL_PTR(r) 
				{
					arr[j+gap] = arr[j]
					j -= gap
				}
				else  do break l3	
			}

			arr[j+gap] = x
		}
	}
}


_shell_sort_costum   :: proc (arr: ^$T/[dynamic]Value, fn: ^Value, ctx: ^Context)
{
	gap : int
	x   : Value


	@(rodata,static)
	a := [?]int{9,5,3,2,1}

	n      := len(arr)
	m      := len(a)
	j,i    : int

	method := fn^

	for k in 0..<m
	{
		gap = a[k]

		for i = gap ; i < n; i += 1
		{
			x = arr[i]
			
			l3: for j = i-gap; j >= 0 ;
			{
				a := &x
				b := &arr[j]
				
				ref_value_costum(a,1)
				ref_value_costum(b,1)

				ctx.push_value(a)
				ctx.push_value(b)

				if ctx.call(&method,2,0) do return

				result := ctx.pop_value()
				if ctx.runtime_error_no_loc(IS_VARIANT_PTR(result,.BOOL),"'sort_costum' expects a method that returns bool.") do return

				if  AS_BOOL_PTR(result) 
				{
					arr[j+gap] = arr[j]
					j -= gap
				}
				else  do break l3	
			}

			arr[j+gap] = x
		}
	}
}



_binary :: proc (arr: ^$T/[dynamic]Value, key ,r: ^Value, ctx: ^Context) -> int
{
	key := key^

	// Nota(jstn): via mais dificil, mais pesada
	for &v,indx in arr 
	{
		type_a := key.type
		type_b := v.type

		callee := get_op_binary(.OP_EQUAL,type_a,type_b)
		#force_inline callee(&key,&v,r,ctx)
		if AS_BOOL_PTR(r) do return indx
	}

	return -1
}


_binary_costum :: proc (arr: ^$T/[dynamic]Value, ctx: ^Context) -> int
{
	method : Value
	VARIANT2VARIANT_PTR(ctx.peek_value(0),&method)

	// Nota(jstn): via mais dificil, mais pesada
	for &value,idx in arr 
	{
		a := &value

		ref_value_costum(a,1)
		ctx.push_value(a)

		if ctx.call(&method,1,0) do return -1
		result := ctx.pop_value()

		if ctx.runtime_error_no_loc(IS_VARIANT_PTR(result,.BOOL),"'find_costum' expects a method that returns bool.") do return	-1	
		if AS_BOOL_PTR(result) do return idx
	}

	return -1
}


_map :: proc(arr_from,arr_to: ^$T/[dynamic]Value ,ctx: ^Context)
{
	method : Value
	VARIANT2VARIANT_PTR(ctx.peek_value(0),&method)

	for &value in arr_from
	{
		a := &value

		ref_value_costum(a,1)
		ctx.push_value(a)

		if ctx.call(&method,1,0) do return

		result := ctx.pop_value()
		append(arr_to,result^)
	}

}

_filter :: proc(arr_from,arr_to: ^$T/[dynamic]Value, ctx: ^Context)
{
	method : Value
	VARIANT2VARIANT_PTR(ctx.peek_value(0),&method)

	for &value in arr_from
	{
		a := &value

		ref_value(a); ctx.push_value(a)
		if ctx.call(&method,1,0) do return

		result := ctx.pop_value()

		if ctx.runtime_error_no_loc(IS_VARIANT_PTR(result,.BOOL),"'filter' expects a method that returns bool.") do return
		if AS_BOOL_PTR(result) { ref_value(a); append(arr_to,value) }
	}

}


_reduce :: proc(arr : ^$T/[dynamic]Value, ctx: ^Context)
{
	method: Value
	accum : Value

	VARIANT2VARIANT_PTR(ctx.peek_value(0),&method)
	VARIANT2VARIANT_PTR(ctx.peek_value(1),&accum)

	for &value, idx in arr
	{
		a := &value

		ref_value_costum(a,1)
		ref_value_costum(&accum, (idx == 0) ? 2:1)

		ctx.push_value(a)
		ctx.push_value(&accum)

		if ctx.call(&method,2,0) do return

		unref_value(&accum)		
		VARIANT2VARIANT_PTR(ctx.pop_value(),&accum)	
	}

	VARIANT2VARIANT_PTR(&accum,ctx.call_state.result)
}


_for_each :: proc(arr: ^$T/[dynamic]Value ,ctx: ^Context)
{
	method : Value
	VARIANT2VARIANT_PTR(ctx.peek_value(0),&method)

	for &value in arr
	{
		e := &value
		ref_value_costum(e,1)

		ctx.push_value(e)
		if ctx.call(&method,1,0) do return

		unref_value(ctx.pop_value())
	}

}