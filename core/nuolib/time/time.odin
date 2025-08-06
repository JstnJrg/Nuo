#+private
package Time



get_tick_ms :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'get_tick_ms' expects %v, but got %v.",0,cs.argc) do return	
	INT_VAL_PTR(cs.result,#force_inline _get_tick_ms())
}

get_tick_ns :: proc(ctx: ^Context) 
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0,"'get_tick_ns' expects %v, but got %v.",0,cs.argc) do return	
	INT_VAL_PTR(cs.result,#force_inline _get_tick_ns())
}