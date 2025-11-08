package Variant


@(private="file") runtime_context : ^Context
@(private="file") allocators : NuoAllocators


NuoAllocators :: struct 
{ 
	small : Buddy_Allocator
}



init_context_internal :: proc(ctx : ^Context)
{
	set_context(ctx)
	init_buddy_allocator()

}

init_buddy_allocator :: proc()
{
	get_bake_size :: proc "contextless" (n: int) -> int 
	{ 
		if n  <= 1 do return n
		upper := 1
		for upper < n do upper <<= 1
		lower := upper >> 1
		return (n-lower) < (n-upper)? lower:upper 
	}

	is_power_of_two :: proc "contextless" (x: int) -> bool { return x > 0 && (x & (x-1)) == 0 }
	get_offset      :: proc "contextless" (available: int) -> int { l := 1; for l <= available do l <<= 1; return l >> 1 }

	bsize       := 16*KiloByte
	start       := 0
	available   := bsize-start
	alignment   := uint(32)
	
	offset      := get_offset(bsize)
	bake_buffer := make([dynamic]u8,start+offset,start+offset,get_context_allocator())
	buffer      := bake_buffer[start:][:offset]

	p           := raw_data(buffer)
	alignment    = alignment < size_of(Buddy_Block) ? size_of(Buddy_Block): alignment

	// println("-------> ",uintptr(p) % uintptr(size_of(Buddy_Block)))
	get_context().runtime_panic( uintptr(p) % uintptr(size_of(Buddy_Block)) == 0,"please adjust the Bake Buffer")
    buddy_allocator_init(&allocators.small,buffer,alignment)
}

set_context           :: proc "contextless" (ctx : ^Context)         { runtime_context = ctx }
get_context_allocator :: proc () -> Allocator                        { return runtime_context.get_runtime_allocator() }
get_context           :: proc "contextless" () -> ^Context           { return runtime_context }
// context_has_error     :: proc "contextless" (ctx : ^Context) -> bool { return ctx.err_count > 0 }

small_get_allocator   :: #force_inline proc() -> Allocator                       { return get_buddy_allocator(&allocators.small) }
get_buddy             :: #force_inline proc "contextless" () -> ^Buddy_Allocator { return &allocators.small }
smallnew              :: #force_inline proc ($T: typeid) -> ^T                   { p := new(T,small_get_allocator()); assert( p != nil ,"Value is nullptr, increase the Pool's size"); return p }
memfree               :: #force_inline proc (L: ^$T)                             { buddy_free(get_buddy(),L) }

create_T              :: proc($T: typeid, type : VariantType) -> ^T 
{
	obj          := smallnew(T)
	obj.type      = type
	obj.ref_count = 1
	gc_set_in_list(obj)

	return obj
}
