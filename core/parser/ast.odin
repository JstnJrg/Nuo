package Parser

AstType :: enum u8 
{
	// NONE,
	PROGRAM,
	IMPORT,
	FUNCTION,
	CLASS,
	BLOCK,
	// ENUM,

	// // 
	ERROR,

	// // 
	STATEMENT,
	EXPRESSION,

	// // 
	LITERAL,
	FLOAT,
	INT,
	STRING,
	ARRAY,
	MAP,
	VECTOR, // qualquer
	COLOR,
	RECT,  // qualquer
	TRANSFORM, // qualquer
	RANGE,
	SIGNAL,

	// 
	GROUP,
	UNARY,
	BINARY,
	LOGICAL,

	DEFINE_VAR,

	NAMED_VAR,
	// NAMEDLOCAVAR,
	OBJECT_OPERATOR,

	ASSIGNMENT,
	// MEMBER,
	TERNARY,

	// BOCK,
	CONTAINER,
	PRINT,

	CALL,
	IF,
	WHILE,
	MATCH,
	FOR,
	BREAK,
	CONTINUE,
	RETURN,
	NEW,
	SUPER,
	SET_PROPERTY,
	GET_PROPERTY,
	
	CALL_METHOD,
}

