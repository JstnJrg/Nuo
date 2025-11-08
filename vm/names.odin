#+private

package VM


// names

NUO_NAME        :: `Nuo`
DECORATOR_NAME  :: `Decorator`

INSTANCE_NAME   :: `this`
CLASS_INIT      :: `_init`
CLASS_DEINIT    :: `_deinit`

// CLASS_INIT_HASH := hash_string(CLASS_INIT)


ReservedName   :: struct
{
	name : string,
	msg  : string,
	type : EntetyType
}

//Nota(jstn): nomes reservados
@(rodata)
RESERVED_NAMES := []ReservedName{
	{"main","'%v' is reserved as the entry point function in the initial scope.",.FUNCTION}
}


nuo_names_register       :: proc()
{
	string_db_register_string(CLASS_INIT)
	string_db_register_string(CLASS_DEINIT)
}


names_check_reserved :: proc "contextless" (name: string, type: EntetyType) -> (bool,string)
{
	for &rn in RESERVED_NAMES do if rn.name == name && rn.type != type do return true,rn.msg
	return false,""
}