package VM

@private current_vm      : ^VM       = nil
@private current_context : ^Context  = nil

VM        :: struct 
{ 
    task         : ^Task_VM,
	context_     : ^Context,
	globals      : ^Table,
	return_      :  Value,
	err_count    : int,
	exit_count   : int
}

nuo_init   :: proc()
{
	init_runtime_arena()
	nuo_init_ctx()

	// 
	nuo_init_config_gc()
	nuo_register()
	nuo_names_register()
}

nuo_init_config_gc  :: proc "contextless" ()
{
	gc_set_max(.STRING,      1 << 4 )
	gc_set_max(.INSTANCE,    1 << 3 )
	gc_set_max(.ARRAY,       1 << 3 )
	gc_set_max(.MAP,         1 << 3 )
	gc_set_max(.SIGNAL,      1 << 3 )

	// buffer
	gc_set_max(.TRANSFORM2D, 1 << 3 )
}

nuo_init_compiler   :: proc()
{
	init_compiler_arena()
	nuo_init_compiler_ctx()
}


nuo_init_compiler_ctx :: proc() { init_compiler_ctx()       }
nuo_free_all_compiler :: proc() { compiler_arena_free_all() }

nuo_deinit_compiler   :: proc()
{
	nuo_free_all_compiler()
	compiler_arena_destroy()
}

@private
nuo_init_ctx ::proc()
{
	current_context = new(Context,get_runtime_allocator())
	nuo_assert(current_context != nil,"something went wrong. Context was not created.")

	config_ctx()
	init_context(get_ctx())
}

nuo_deinit :: proc() 
{
	nuo_deinit_compiler()
	gc_end()

	runtime_arena_free_all()
	runtime_arena_destroy()
}


// registro incial da VM
nuo_register :: proc()
{
	register_call_data()
	register_nuo_libs()
	register_builtin()
}

nuo_eprint  :: proc(fmt: string, args: ..any)  { eprintf(fmt, ..args) }
nuo_print   :: proc(fmt: string, args: ..any) 
{
	eprintf(" [NUO] -> ")
	eprintf(fmt, ..args)
	eprintf("\n")
}

nuo_print_cond :: proc(condition : bool, fmt: string, args: ..any)
{
	if condition do return
	nuo_print(fmt,..args)
}

nuo_assert     :: proc(condition : bool, fmt: string, args: ..any)
{
	if condition do return
	nuo_print(fmt,..args)
	nuo_deinit()
}

nuo_panic      :: proc(condition : bool, fmt: string, args: ..any)
{
	if condition do return
	nuo_print(fmt,..args)
	nuo_deinit()
	panic("")
}


create_vm  :: proc()
{
	current_vm  = new(VM,get_runtime_allocator())

	nuo_assert(current_context != nil,"something went wrong. Make sure that Context was created.")
	nuo_assert(current_vm != nil,"something went wrong. Cannot create VM.")

	
	current_vm.task                    = new(Task_VM,get_runtime_allocator())
	current_vm.context_                = current_context
	current_context.call_state.result  = &current_vm.return_

	nuo_assert(current_vm.task     != nil,"something went wrong. Cannot create VM.")
	nuo_assert(current_vm.context_ != nil,"something went wrong. Cannot create VM.")
}

config_ctx :: proc()
{
	cs                          := new(CallState,get_runtime_allocator())
	nuo_assert(cs != nil,"something went wrong. Context was not created.")

	peek_value   :: proc "contextless" (indx: int) -> ^Value #no_bounds_check { cs := get_call_state(); return &cs.args[indx] }
	disable_gc   :: proc "contextless" () { current_context.gc_allowed = false }
	enable_gc    :: proc "contextless" () { current_context.gc_allowed = true }
	vm_exit      :: proc "contextless" (value: int) { current_vm.exit_count += value }
	trace_error  :: proc "contextless" (ok: bool) { current_context.trace_err = ok }

	foreign_call :: proc(fn: ^Value,argc: int, dargc : int ) -> (error: bool)
	{
		#partial switch fn.type
		{	
			case .NFUNCTION : 

				push(fn)
				call_nfunction(argc,dargc)
				return check_error() || interpret() != .INTERPRET_OK

			case .OFUNCTION :

				push(fn)
				call_ofunction_foreign(argc,dargc)
				return check_error() ? true : false

			case          :	return false
		}
	}

	copy_args :: proc "contextless" (from,to : []Value, offset : int ) { for i in 0..< offset do to[i] = from[i] }



	ctx                         := current_context
	ctx.call_state               = cs

	ctx.peek_value               = peek_value
	ctx.get_runtime_allocator    = get_runtime_allocator
	ctx.init_runtime_temp        = runtime_arena_temp_begin
	ctx.end_runtime_temp         = runtime_arena_temp_end
	
	ctx.runtime_assert           = nuo_assert
	ctx.runtime_panic            = nuo_panic
	ctx.runtime_error            = cond_report_error
	ctx.runtime_warning          = cond_report_warning 
	ctx.runtime_error_no_loc     = _cond_report_error
	
	ctx.disable_gc               = disable_gc
	ctx.enable_gc                = enable_gc
	ctx.trace_error              = trace_error
	ctx.copy_args                = copy_args

	ctx.call                     = foreign_call
	ctx.push_value               = push
	ctx.pop_value                = pop
	ctx.vm_exit					 = vm_exit

	ctx.gc_allowed               = true 
	ctx.trace_err                = true

}


get_vm      :: proc "contextless" () -> ^VM         { return current_vm }
get_ctx     :: proc "contextless" () -> ^Context    { return current_context }
get_vm_ctx  :: proc "contextless" () -> ^Context    { return current_vm.context_ }
get_globals :: proc "contextless" () -> ^Table      { return current_vm.globals }
get_task    :: proc "contextless" () -> ^Task_VM    { return current_vm.task }
check_error :: proc "contextless" () -> bool        { return current_vm.err_count > 0 }

get_call_state    :: proc "contextless" () -> ^CallState    { return current_vm.context_.call_state }
vm_can_exit       :: proc "contextless" () -> bool { return current_vm.exit_count > 0 }


