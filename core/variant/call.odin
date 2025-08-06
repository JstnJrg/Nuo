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
	vm_exit               : proc "contextless" (value: int),
	trace_error           : proc "contextless" (can: bool),

	
	// runtime allocator
	get_runtime_allocator : proc() -> Allocator,
	init_runtime_temp     : proc(),
	end_runtime_temp      : proc(),
	
	runtime_assert        : proc(condition : bool, fmt: string, args: ..any),
	runtime_error         : proc(condition : bool, fmt: string, args: ..any) -> bool,
	runtime_error_no_loc  : proc(condition : bool, fmt: string, args: ..any) -> bool,
	runtime_warning       : proc(condition : bool, fmt: string, args: ..any) -> bool,
	runtime_panic         : proc(condition : bool, fmt: string, args: ..any),



	// chamada de funções
	call                  : proc(fn: ^Value,argc, dargc: int) -> (error: bool),
	push_value            : proc(value: ^Value),
	pop_value             : proc() ->  ^Value, //não deve unref o objecto


	// 
	trace_err             : bool,


	//
	err_count             : int,
	gc_allowed            : bool
}

CallState :: struct
{
	// temps     : [MAX_ARGUMENTS]Value,
	args      : []Value,
	result    : ^Value,
	argc      : int
}


CallFrame   :: struct
{
	locals       : []Value, 
	ip           : ^int,
	function_id  : int,
	iid          : int // ao retornar
}


Task :: struct($STACK_SIZE :  int)
{
	stack        : [STACK_SIZE]Value,
	frames       : [MAX_FRAMES]CallFrame,

	frame_count  : int,
	tos          : int
} 
