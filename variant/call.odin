package Variant


InterpretResult :: distinct enum u8 
{ 
	INTERPRET_COMPILE_OK,
	INTERPRET_COMPILE_ERROR, 
	INTERPRET_OK, 
	INTERPRET_RUNTIME_ERROR 
}


Context :: struct
{
	call_state            : ^CallState,	

	// runtime utils
	peek_value            : proc "contextless" (idx: int) -> ^Value,
	copy_args             : proc "contextless" (from,to : []Value, offset : int ),
	disable_gc            : proc "contextless" (),
	enable_gc             : proc "contextless" (),
	trace_error           : proc "contextless" (can: bool),
	is_trace_error        : proc "contextless" () -> bool,

	
	// runtime allocator
	get_runtime_allocator : proc() -> Allocator,
	init_runtime_temp     : proc() -> Arena_Temp,
	end_runtime_temp      : proc(t: Arena_Temp),

	// 
	log                   : log_proc, 
	

	runtime_assert        : proc(condition : bool, fmt: string, args: ..any, loc := #caller_location),
	runtime_error         : proc(condition : bool, fmt: string, args: ..any, loc := #caller_location) -> bool,
	runtime_error_no_loc  : proc(condition : bool, fmt: string, args: ..any, loc := #caller_location) -> bool,
	runtime_warning       : proc(condition : bool, fmt: string, args: ..any, loc := #caller_location) -> bool,
	runtime_panic         : proc(condition : bool, fmt: string, args: ..any, loc := #caller_location),


	// chamada de funções
	call                  : proc(fn: ^Value,argc, dargc: int) -> (error: bool),
	call_prepare          : proc(fn: ^Value,argc, dargc: int),
	push_value            : proc(value: ^Value),
	pop_value             : proc() ->  ^Value, //não deve unref o objecto


	//
	trace_err             : bool,
	gc_allowed            : bool
}


CallState :: struct
{
	args      : []Value,
	result    : ^Value,
	argc      : int
}


CallFrame   :: struct
{
	locals       : []Value, 
	ip           : ^int,
	function_id  :  int,
	iid          :  int, // ao retornar
	dirty_offset :  int,
	// dirty        :  bool
}


Task :: struct
{
	stack        : []Value,
	frames       : [MAX_FRAMES]CallFrame,

	frame_count  : int,
	stack_size   : int,
	tos          : int,

	id           : enum u8 {ROOT,OTHER},
	state        : enum u8 {ALWAYS,NEW,RUNNING,YIELDED,RESUMED,DEAD}
} 



