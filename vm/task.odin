// #+private
package VM 


MAX_TASK        :: 1
TASK_STACK_SIZE :: 32



get_task_id       :: proc "contextless" () -> int { return current_vm.task_count-1 }

get_task          :: proc "contextless" () -> ^Task             { return current_vm.scheduler[current_vm.task_count-1] }
get_task_offset   :: proc "contextless" (offset: int) -> ^Task  { return current_vm.scheduler[current_vm.task_count-1-offset] }

yield_task        :: proc "contextless" () -> bool { return get_task().state == .YIELDED }
dead_task         :: proc "contextless" ()
{ 
	get_task().state = .DEAD 
}

end_task          :: proc "contextless" () -> bool { return current_vm.task_count-1 == 0 }


push_task   :: proc "contextless" (t: ^Task)     
{ 
	current_vm.scheduler[current_vm.task_count] = t
	current_vm.task_count += 1
}

pop_task   :: proc "contextless" ()     { current_vm.task_count -= 1 }

// create_obj_task
// NuoTask

// NuoTask   :: struct
// {
// 	using _    : NuoObject,
// 	task       : ^Task
// }

// Task :: struct
// {
// 	stack        : []Value,
// 	frames       : [MAX_FRAMES]CallFrame,

// 	task_count   : int,	
// 	frame_count  : int,
// 	stack_size   : int,
// 	tos          : int
// } 

	// id           : enum u8 {ROOT,OTHER}
	// state        : enum u8 {NEW,RUNNING,YIELDED,DEAD}



inicialize_task :: proc(nuo_task: ^NuoTask)
{
	task           := new(Task)
	task.stack      = make([]Value,TASK_STACK_SIZE)
	task.stack_size = TASK_STACK_SIZE
	task.id         = .OTHER
	task.state      = .NEW
	nuo_task.task   = task
}




std_task :: proc()
{
	// cid := class_db_get_id_by_name(GET_TYPE_NAME(.TASK))	
	
	// B_METHOD(cid,"create",task_create,.STATIC)
	// B_METHOD(cid,"yield",task_yield,.STATIC)


	// B_METHOD(cid,"call",task_call,.INTRINSICS)
	// B_METHOD(cid,"resume",task_resume,.INTRINSICS)
}


task_create :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 1 && IS_CALLABLE_PTR(ctx.peek_value(0)) ,"'create' expects %v, but got %v and must be 'Callable'.",1,cs.argc) do return	

	nuo_task := create_obj_task()
	inicialize_task(nuo_task)

	VARIANT2VARIANT_PTR(ctx.peek_value(0),&nuo_task.callable)
	NUOOBJECT_VAL_PTR(cs.result,nuo_task)
}


task_yield :: proc(ctx: ^Context)
{
	cs := ctx.call_state
	if ctx.runtime_error(cs.argc == 0 ,"'yield' expects %v, but got %v .",0,cs.argc) do return	

	task := get_task()

	if ctx.runtime_error(task.id    != .ROOT, "'yield' called outside of a coroutine.") do return
	if ctx.runtime_error(task.state == .RUNNING, "'yield' a função não está rodando, arranja uma mensagem de erro.") do return

	task.state = .YIELDED
	NIL_VAR_PTR(cs.result)
}


task_call :: proc(ctx: ^Context)
{
	cs       := ctx.call_state
	argc     := cs.argc

	nuo_task := AS_NUOOBECT_PTR(ctx.peek_value(argc),NuoTask)
	task     := nuo_task.task

	if ctx.runtime_error(task.state == .NEW , "'Call' a coroutine não é nova.") do return


	t     := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

	adata := make([]Value,argc+1,ctx.get_runtime_allocator())
	ctx.copy_args(cs.args[:],adata[:],argc+1)

	defer 
	{ 
		cs.args = cs.args[0:][:0]
		unref_slice(adata[:]) 
	}

	// 
	push_task(task); task.state = .RUNNING; task_id   := get_task_id()

	/* 

		Nota(jstn): referencias para a função ( e se a função for pausada, não devemos limpar as referencias)

	*/
	for &value in cs.args[:argc] { ref_value(&value); ctx.push_value(&value) }
	if ctx.call(&nuo_task.callable,argc,0) do return
	
	_task    := get_task()
	_task_id := get_task_id()

 	ctx.runtime_error(_task_id      == task_id,"TaskID != currentID, it's a bug, report.")
	ctx.runtime_error(_task.state   == .YIELDED || task.state == .RUNNING," TaskState bug, report..")

	if check_error() do return


	if _task_id == task_id
	{
		/*
			Nota(jstn): tem dois cenarios

			YIELDED -> parou numa sentença, precisamos conservar o valor na pilha anterior
			e devolver uma referencia

			RUNNING    -> a task terminou e é seguro remover seu valor e passa-lo adiante
		*/
		if task.state == .YIELDED
		{
			result := peek(0)  // da pilha do task corrente
			pop_task()
			ref_value(result)  // da task que vai receber
			VARIANT2VARIANT_PTR(result,cs.result)

			// Nota(jstn): está pausada, então precisamos conservar a vida dos argumentos
			// for &value in cs.args[:argc] do ref_value(&value)

			return
		}

		// Nota(jstn): a função terminou, então podemos marcar a task como morta
		result  := ctx.pop_value();pop_task(); _task.state = .DEAD
		VARIANT2VARIANT_PTR(result,cs.result)
		return
	}

	NIL_VAR_PTR(cs.result)
}




task_resume :: proc(ctx: ^Context)
{
	cs       := ctx.call_state
	argc     := cs.argc

	nuo_task := AS_NUOOBECT_PTR(ctx.peek_value(argc),NuoTask)
	task     := nuo_task.task

	if ctx.runtime_error(cs.argc == 0 ,"'resume' expects %v, but got %v .",0,cs.argc) do return	
	if ctx.runtime_error(task.state == .YIELDED , "'resume' a coroutine não está yielded.") do return


	t     := ctx.init_runtime_temp()
	defer ctx.end_runtime_temp(t)

	adata := make([]Value,argc+1,ctx.get_runtime_allocator())
	ctx.copy_args(cs.args[:],adata[:],argc+1)

	defer 
	{ 
		cs.args = cs.args[0:][:0]
		unref_slice(adata[:]) 
	}

	println("=============================> Resume ")
	push_task(task)

	task.state = .RUNNING
	if ctx.runtime_error(interpret() == .INTERPRET_OK,"'resume' error.") do return

	// Nota(jstn): precisamos devolver o valor a quem chamou

	result := pop()
	// a := AS_NUOOBECT_PTR(result,NuoArray)	
	// println("aaaaaaaaaaa> ",a,adata)	
	pop_task()

	push(result)


	println("==============================> End Resume ")
	// ctx.runtime_error(false,"kkkkkk")
}









