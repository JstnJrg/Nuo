package VM

@private current_vm      : ^VM       = nil
@private current_context : ^Context  = nil

VM        :: struct 
{ 
	context_     : ^Context,
	globals      : ^Table,
	scheduler    : [MAX_TASK]^Task,
	return_      :  Value,

	task_count   : int,
	err_count    : int
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
	gc_set_max(.CALLABLE,    1 << 3 )

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
	compiler_set_nil()
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
	register_nuo_libs()
	register_builtin()
	
	register_call_data()
}

nuo_eprint  :: proc(fmt: string, args: ..any)  { eprintf(fmt, ..args) }
nuo_print   :: proc(fmt: string, args: ..any, loc := #caller_location) 
{
	eprintf(" [NUO] -> ")
	eprintf(fmt, ..args)
	eprintf("[%v]",loc)
	eprintf("\n")
}

nuo_print_cond :: proc(condition : bool, fmt: string, args: ..any)
{
	if condition do return
	nuo_print(fmt,..args)
}

nuo_assert     :: proc(condition : bool, fmt: string, args: ..any, loc := #caller_location)
{
	when NUO_DEBUG
	{
		if condition do return
		nuo_print(fmt,..args,loc=loc)
		nuo_deinit()
		assert(false,"")
	}
	else
	{
		if condition do return
		get_ctx().log(.Fatal,fmt,..args)
		nuo_deinit()
		assert(false,"")
	}
}

nuo_panic      :: proc(condition : bool, fmt: string, args: ..any, loc := #caller_location)
{
	when NUO_DEBUG
	{
		if condition do return
		nuo_print(fmt,..args,loc=loc)
		nuo_deinit()
		panic("")
	}
	else
	{
		if condition do return
		get_ctx().log(.Fatal,fmt,..args)
		nuo_deinit()
		panic("")
	}

}


create_vm  :: proc()
{
	current_vm  = new(VM,get_runtime_allocator())

	nuo_assert(current_context != nil,"something went wrong. Make sure that Context was created.")
	nuo_assert(current_vm != nil,"something went wrong. Cannot create VM.")

	task := new(Task,get_runtime_allocator())

	// 
	task.stack      = make([]Value,STACK_SIZE,get_runtime_allocator())
	task.id         = .ROOT
	task.state      = .ALWAYS
	task.stack_size = STACK_SIZE


	push_task(task)
	current_vm.context_                = current_context
	current_context.call_state.result  = &current_vm.return_

	nuo_assert(task     != nil,"something went wrong. Cannot create VM.")
	nuo_assert(current_vm.context_ != nil,"something went wrong. Cannot create VM.")
}

restore_vm :: proc()
{
	
}



config_ctx :: proc()
{
	cs                          := new(CallState,get_runtime_allocator())
	nuo_assert(cs != nil,"something went wrong. Context was not created.")

	peek_value    :: proc "contextless" (indx: int) -> ^Value #no_bounds_check { cs := get_call_state(); return &cs.args[indx] }
	disable_gc    :: proc "contextless" ()           { current_context.gc_allowed = false }
	enable_gc     :: proc "contextless" ()           { current_context.gc_allowed = true }
	trace_error   :: proc "contextless" (ok: bool)   { current_context.trace_err = ok }
	is_trace_err  :: proc "contextless" () -> bool   { return current_context.trace_err  }


	foreign_call :: proc(fn: ^Value,argc: int, dargc : int ) -> (error: bool)
	{
		#partial switch fn.type
		{	
			case .NFUNCTION : 

				push(fn)
				call_nfunction_foreign(argc,dargc)
				return check_error() || interpret() != .INTERPRET_OK

			case .OFUNCTION :

				push(fn)
				call_ofunction_foreign(argc,dargc)
				return check_error() ? true : false

			/*
				Nota(jstn): não desreferenciamos, pois um signal 
				pode ter ou possuir o objecto, então deixamos				
			*/
			case .BOUND_METHOD:

				bound  := AS_NUOOBECT_PTR(fn,BoundMethod)
				method := &bound.method
				this   := &bound.this

				push(this)
				ref_value(this) // da função (this parametro)

				return foreign_call(method,argc,1+dargc)


			case .CALLABLE:

				callable  := AS_NUOOBECT_PTR(fn,NuoCallable)
				_callable := &callable.callable
				args      := &callable.args
				argc      := argc+len(args)

				for &value in args 
				{ 
					ref_value(&value)
					push(&value) 
				}

				return foreign_call(_callable,argc,dargc)
			
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
	ctx.log                      = log
	
	ctx.disable_gc               = disable_gc
	ctx.enable_gc                = enable_gc
	ctx.trace_error              = trace_error
	ctx.is_trace_error           = is_trace_err

	ctx.copy_args                = copy_args

	ctx.call                     = foreign_call
	// ctx.call_prepare             = foreign_prepare
	ctx.push_value               = push
	ctx.pop_value                = pop

	ctx.gc_allowed               = true 
	ctx.trace_err                = true

}


get_vm      :: proc "contextless" () -> ^VM         { return current_vm }
get_ctx     :: proc "contextless" () -> ^Context    { return current_context }
get_vm_ctx  :: proc "contextless" () -> ^Context    { return current_vm.context_ }
get_globals :: proc "contextless" () -> ^Table      { return current_vm.globals }

check_error :: proc "contextless" () -> bool        { return current_vm.err_count > 0 }


safe_exit   :: proc () -> InterpretResult { null : Value; push(&null); return .INTERPRET_RUNTIME_ERROR }

get_call_state    :: proc "contextless" () -> ^CallState    { return current_vm.context_.call_state }


