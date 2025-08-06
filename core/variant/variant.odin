package Variant

VariantType :: distinct enum u8
{
	NIL,
	BOOL,
	INT,
	FLOAT,
	SYMID, //não é operacional

	VECTOR2,
	RECT2,
	COLOR,

	NFUNCTION,
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

	TRANSFORM2D,
	ANY,
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
    _obj  : ^NuoObject,
    _mem  : Buffer,
}

Value :: struct #align(8)
{
	variant : Variant,
	type    : VariantType
}