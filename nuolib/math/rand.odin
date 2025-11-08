package Math

// _acos :: proc(ctx: ^Context) 
// {
// 	cs    := ctx.call_state
// 	value : Float

// 	if ctx.runtime_error(cs.argc == 1 && IS_NUMERIC_PTR(ctx.peek_value(0),&value),"'acos' expects %v, but got %v and must be '%v'",1,cs.argc,"number") do return
// 	FLOAT_VAL_PTR(cs.result,acos(value))
// }

randi :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'randi' expects %v, but got %v.",0,cs.argc) do return
	INT_VAL_PTR(cs.result,int(int31()))
}

randf :: proc(ctx: ^Context) 
{
	cs    := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'randf' expects %v, but got %v.",0,cs.argc) do return
	FLOAT_VAL_PTR(cs.result,Float(float32()))
}

randf_range :: proc(ctx: ^Context) 
{
	cs     := ctx.call_state
	values : [2]Float

	for  i in 0..<2 do if ctx.runtime_error(cs.argc == 2 && IS_NUMERIC_PTR(ctx.peek_value(i),&values[i]),"'randf_range' expects %v, but got %v and must be '%v's",2,cs.argc,"number's") do return
	if ctx.runtime_error(values[0] <= values[1],"low must be lower than or equal to high") do return  

	FLOAT_VAL_PTR(cs.result,Float(float32_range(f32(values[0]),f32(values[1]))))
}