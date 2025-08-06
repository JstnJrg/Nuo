package String

register_operators :: proc()
{
	register_op(.OP_ADD,.STRING,.STRING,string_string_add)
	register_op(.OP_EQUAL,.STRING,.STRING,string_string_equal)
	register_op(.OP_LESS,.STRING,.STRING,string_string_less)
	register_op(.OP_GREATER,.STRING,.STRING,string_string_greater)
	register_op(.OP_LESS_EQUAL,.STRING,.STRING,string_string_less_equal)
	register_op(.OP_GREATER_EQUAL,.STRING,.STRING,string_string_greater_eqaul)

}







string_string_add :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
{
	str0   := AS_NUOOBECT_PTR(lhs,NuoString)
	str1   := AS_NUOOBECT_PTR(rhs,NuoString)

	defer
	{
		unref_object(str0)
		unref_object(str1)
	}

	str2 := create_obj_string()

	nuostring_write_data(to_string(str0),str2)
	nuostring_write_data(to_string(str1),str2)

	NUOOBJECT_VAL_PTR(ret,str2)
}

string_string_equal :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
{
	str0   := AS_NUOOBECT_PTR(lhs,NuoString)
	str1   := AS_NUOOBECT_PTR(rhs,NuoString)

	defer if ctx.gc_allowed
	{
		unref_object(str0)
		unref_object(str1)
	}

	BOOL_VAL_PTR(ret,hash_string(to_string(str0)) == hash_string(to_string(str1)))
}

string_string_less :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
{
	str0   := AS_NUOOBECT_PTR(lhs,NuoString)
	str1   := AS_NUOOBECT_PTR(rhs,NuoString)

	defer if ctx.gc_allowed
	{
		unref_object(str0)
		unref_object(str1)
	}

	BOOL_VAL_PTR(ret,hash_string(to_string(str0)) < hash_string(to_string(str1)))
}

string_string_greater :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
{
	str0   := AS_NUOOBECT_PTR(lhs,NuoString)
	str1   := AS_NUOOBECT_PTR(rhs,NuoString)

	defer if ctx.gc_allowed
	{
		unref_object(str0)
		unref_object(str1)
	}

	BOOL_VAL_PTR(ret,hash_string(to_string(str0)) > hash_string(to_string(str1)))
}

string_string_less_equal :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
{
	str0   := AS_NUOOBECT_PTR(lhs,NuoString)
	str1   := AS_NUOOBECT_PTR(rhs,NuoString)

	defer if ctx.gc_allowed
	{
		unref_object(str0)
		unref_object(str1)
	}

	BOOL_VAL_PTR(ret,hash_string(to_string(str0)) <= hash_string(to_string(str1)))
}

string_string_greater_eqaul :: #force_inline proc(lhs,rhs,ret: ^Value,ctx: ^Context)
{
	str0   := AS_NUOOBECT_PTR(lhs,NuoString)
	str1   := AS_NUOOBECT_PTR(rhs,NuoString)

	defer if ctx.gc_allowed
	{
		unref_object(str0)
		unref_object(str1)
	}

	BOOL_VAL_PTR(ret,hash_string(to_string(str0)) >= hash_string(to_string(str1)))
}