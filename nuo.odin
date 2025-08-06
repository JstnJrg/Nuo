package NuoMain

import fmt       "core:fmt"
import mem       "core:mem"
import vm        "nuo:vm"
import os        "core:os"
import strings   "core:strings"


NuoContext :: struct
{

}




main :: proc()
{

	// when ODIN_DEBUG
	// {
	// 	track : mem.Tracking_Allocator
	// 	mem.tracking_allocator_init(&track,context.allocator) 
	// 	context.allocator = mem.tracking_allocator(&track)
		
	// 	defer
	// 	{
	// 		fmt.println("\n\n======================================================")

	// 		len_0 := len(track.allocation_map)
	// 		len_1 := len(track.bad_free_array)

	// 		if len_0 > 0
	// 		{
	// 			fmt.printfln("allocation not freed: %v\n",len_0)
	// 			for _,entry in track.allocation_map do fmt.printfln("bytes: %v\nplace: %v\n",entry.size,entry.location)
	// 		} 

	// 		if len_1 > 0
	// 		{
	// 			fmt.printfln("\nincorrect frees: %v",len_1)
	// 			for entry in track.bad_free_array do fmt.printfln("memory: %p\nlocation:%v",entry.memory,entry.location)
	// 		}

	// 		mem.tracking_allocator_destroy(&track)
	// 	}
	// }


	args := os.args

	if len(args) == 2
	{
		script_path := args[1]

		      vm.nuo_init()
		defer vm.nuo_deinit()

		vm.create_vm()
		
		vm.nuo_init_compiler()
		fid   := vm.compile(script_path)
		vm.nuo_deinit_compiler()


	    if fid < 0 do return

	    fn, has := vm.nuo_context_get(0,"main")

		vm.nuo_call(fid,0)
		if fn, has := vm.nuo_context_get(0,"main"); has do vm.nuo_call(&fn,0)

	}
	else do fmt.println("[NUO] ","invalid command line.")




	//       vm.nuo_init()
	// defer vm.nuo_deinit()

	// vm.create_vm()
	

	// vm.nuo_init_compiler()
	// fid   := vm.compile("script.nuo")

	// vm.nuo_deinit_compiler()


    // if fid < 0 do return

    // fn, has := vm.nuo_context_get(0,"main")

	// vm.nuo_call(fid,0)
	// if fn, has := vm.nuo_context_get(0,"main"); has do vm.nuo_call(&fn,0)

	// fmt.println(os.args)
}


// construct :: proc()
// {

// 	      vm.nuo_init()
// 	defer vm.nuo_deinit()

// 	vm.create_vm()



// 	      vm.nuo_init()
// 	defer vm.nuo_deinit()

// 	vm.create_vm()
	

// 	vm.nuo_init_compiler()
// 	fid   := vm.compile("script.nuo")

// 	vm.nuo_deinit_compiler()


//     if fid < 0 do return

//     fn, has := vm.nuo_context_get(0,"main")

// 	vm.nuo_call(fid,0)
// 	if fn, has := vm.nuo_context_get(0,"main"); has do vm.nuo_call(&fn,0)

// 	fmt.println(os.args)

// 	// ctx_anew
// 	// ctx_amake



// }