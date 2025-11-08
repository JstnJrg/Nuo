package Variant

VariantType :: distinct enum u8
{
	NIL,
	BOOL,
	INT,
	FLOAT,
	SYMID, //não é operacional

	VECTOR2,
	COMPLEX,
	RECT2,
	COLOR,

	NFUNCTION,
	SFUNCTION,
	OFUNCTION,
	IMPORT,
	CLASS,
	RID,

	OBJ, //marca o inicio de funções que usam a heap
	
	STRING,
	ARRAY,
	
	MAP,
	RANGE,
	INSTANCE,

	CALLABLE,
	TASK,

	TRANSFORM2D,
	ANY,
	BOUND_METHOD,
	SIGNAL,


	MAX
}

Visibility :: bit_set[VariantType;u32] 
bufferlen  :: 16
Buffer     :: [bufferlen]byte

Ofunction  :: #type proc(ctx: ^Context)

Variant   :: struct #raw_union
{
    _int  : Int,
    _float: Float,
    _bool : Bool,
    _mem  : Buffer,
}

Value :: struct #align(8)
{
	variant : Variant,
	type    : VariantType
}