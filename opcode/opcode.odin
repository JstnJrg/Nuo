package OpCode

OpCode :: distinct enum u8
{
	OP_ADD,
	OP_SUB,
	OP_MULT,
	OP_MULT_MULT,
	OP_DIV,
	OP_MOD,
	OP_NEGATE,
	OP_BOOLIANIZE,

	OP_BIT_AND,
	OP_BIT_OR,
	OP_BIT_NEGATE,
	OP_BIT_XOR,

	OP_NOT,
	OP_EQUAL,
	OP_GREATER,
	OP_LESS,

	OP_SHIFT_LEFT,
	OP_SHIFT_RIGHT,

	OP_NOT_EQUAL,
	OP_GREATER_EQUAL,
	OP_LESS_EQUAL,

	OP_AND,
	OP_OR,

	OP_GET_INDEXING,

	OP_GET_PROPERTY,
	OP_SET_PROPERTY,

	OP_SET_INDEXING, //obj

	OP_CONSTRUCT,

	OP_NIL,
	OP_FALSE,
	OP_TRUE,

	OP_INHERIT,

	OP_OPERATOR_COUNT, //usado pelo register_op

	OP_LITERAL,
	OP_BINARY,
	OP_UNARY,


	OP_PRINT,
	OP_POP,
	OP_SUB_SP,

	OP_LOAD,

	OP_DEFINE_GLOBAL,

	OP_GET_GLOBAL,
	OP_SET_GLOBAL,

	OP_GET_LOCAL,
	OP_SET_LOCAL,

	OP_JUMP_IF_FALSE,
	OP_JUMP_IF_TRUE,
	OP_MATCH,
	OP_JUMP,

	OP_CALL,
	OP_CALL1, //SUPER
	
	// OP_CLASS,

	OP_INVOKE,

	// OP_NEW,
	// OP_PROPERTY,

	OP_STORE_RETURN, // guarda numa regiao de retorno
	OP_LOAD_RETURN, // remove da regiao de retorn

	OP_RETURN,

	OP_MAX
}



opcode_to_string :: proc(op: OpCode) -> string {

	switch op
	{
		case .OP_ADD : 		return "OP_ADD"
		case .OP_SUB :		return "OP_SUB"
		case .OP_MULT:		return "OP_MULT"
		case .OP_MULT_MULT: return "OP_MULT_MULT"
		case .OP_DIV:		return "OP_DIV"
		case .OP_MOD:		return "OP_MOD"
		case .OP_NEGATE:	return "OP_NEGATE"

		case .OP_BIT_AND:	return "OP_BIT_AND"
		case .OP_BIT_OR:	return "OP_BIT_OR"
		case .OP_BIT_NEGATE:return "OP_BIT_NEGATE"
		case .OP_BIT_XOR:	return "OP_BIT_XOR"

		case .OP_NOT:		return "OP_NOT"
		case .OP_EQUAL:		return "OP_EQUAL"
		case .OP_GREATER:	return "OP_GREATER"
		case .OP_LESS:		return "OP_LESS"

		case .OP_SHIFT_LEFT:		return "OP_SHIFT_LEFT"
		case .OP_SHIFT_RIGHT:		return "OP_SHIFT_RIGHT"

		case .OP_NOT_EQUAL:			return "OP_NOT_EQUAL"
		case .OP_GREATER_EQUAL:		return "OP_GREATER_EQUAL"
		case .OP_LESS_EQUAL:		return "OP_LESS_EQUAL"

		case .OP_AND:		return "OP_AND"
		case .OP_OR:		return "OP_OR"

		case .OP_GET_INDEXING:		return "OP_GET_INDEXING"
		case .OP_SET_INDEXING:		return "OP_SET_INDEXING"
		// case .OP_SET_ARRAY:			return "OP_SET_ARRAY"

		case .OP_OPERATOR_COUNT:	return "OP_OPERATOR_COUNT" //não é uma instrução bem tecnicamente

		case .OP_BINARY:	return "OP_BINARY"
		case .OP_UNARY:	    return "OP_UNARY"

		case .OP_PRINT:		return "OP_PRINT"
		case .OP_POP:		return "OP_POP"
		case .OP_SUB_SP:	return "OP_SUB_SP"

		case .OP_LOAD: return "OP_LOAD"

		case .OP_BOOLIANIZE: return "OP_BOOLIANIZE"
		case .OP_LITERAL:   return "OP_LITERAL"
		case .OP_NIL:		return "OP_NIL"
		case .OP_FALSE:		return "OP_FALSE"
		case .OP_TRUE:		return "OP_TRUE"

		case .OP_DEFINE_GLOBAL:			return "OP_DEFINE_GLOBAL"
		// case .OP_DEFINE_GLOBAL_TEMP:		return "OP_DEFINE_GLOBAL_TEMP"
		
		case .OP_CONSTRUCT:		    	return "OP_CONSTRUCT"
		// case .OP_CONSTRUCT_ENUM:        return "OP_CONSTRUCT_ENUM"
		// case. OP_CONSTRUCT_CLASS:       return "OP_CONSTRUCT_CLASS"
		// case .OP_CONSTRUCT_ARRAY:		return "OP_CONSTRUCT_ARRAY"
		// case .OP_CONSTRUCT_RECT2:		return "OP_CONSTRUCT_RECT2"
		// case .OP_CONSTRUCT_VECTOR2:		return "OP_CONSTRUCT_VECTOR2"
		// case .OP_CONSTRUCT_COLOR:   	return "OP_CONSTRUCT_COLOR"
		// case .OP_CONSTRUCT_TRANSFORM2:	return "OP_CONSTRUCT_TRANSFORM2"

		case .OP_GET_GLOBAL:		return "OP_GET_GLOBAL"
		case .OP_SET_GLOBAL:		return "OP_SET_GLOBAL"

		case .OP_GET_LOCAL:			return "OP_GET_LOCAL"
		case .OP_SET_LOCAL:			return "OP_SET_LOCAL"

		case .OP_JUMP_IF_FALSE:		return "OP_JUMP_IF_FALSE"
		case .OP_JUMP_IF_TRUE:		return "OP_JUMP_IF_TRUE"
		case .OP_JUMP:				return "OP_JUMP"
		case .OP_MATCH:             return "OP_MATCH"

		case .OP_CALL:		return "OP_CALL"
		case .OP_CALL1:     return "OP_CALL1"
		// case .OP_CLASS:		return "OP_CLASS"

		case .OP_INVOKE:		return "OP_INVOKE"
		// case .OP_SUPER_INVOKE:	return "OP_SUPER_INVOKE"
		case .OP_INHERIT:		return "OP_INHERIT"

		case .OP_GET_PROPERTY:	return "OP_GET_PROPERTY"
		case .OP_SET_PROPERTY:	return "OP_SET_PROPERTY"
		
		case .OP_STORE_RETURN:	return "OP_STORE_RETURN"
		case .OP_LOAD_RETURN:	return "OP_LOAD_RETURN"

		// case .OP_NEW:		    return "OP_NEW"

		case .OP_RETURN:		return "OP_RETURN"

		case .OP_MAX:		    return "OP_MAX"

	}


	return "Bad OpCode"
}


get_operator_name :: proc(op: OpCode) -> string
{
	#partial switch op
	{
		case .OP_ADD : 		return "+"
		case .OP_SUB :		return "-"
		case .OP_MULT:		return "*"
		case .OP_MULT_MULT: return "**"
		case .OP_DIV:		return "/"
		case .OP_MOD:		return "%"
		case .OP_NEGATE:	return "-"

		case .OP_BIT_AND:	return "&"
		case .OP_BIT_OR:	return "|"
		case .OP_BIT_NEGATE:return "~"
		case .OP_BIT_XOR:	return "^"

		case .OP_NOT:		return "not"
		case .OP_EQUAL:		return "="
		case .OP_GREATER:	return ">"
		case .OP_LESS:		return "<"

		case .OP_SHIFT_LEFT:		return "<<"
		case .OP_SHIFT_RIGHT:		return ">>"

		case .OP_NOT_EQUAL:			return "!="
		case .OP_GREATER_EQUAL:		return ">="
		case .OP_LESS_EQUAL:		return "<="
		case .OP_GET_INDEXING:      return "[]"

		case 			   :		return "<!>"
	}
}

is_opcode_unary :: proc "contextless" (op: OpCode) -> bool
{
	#partial switch op
	{
		case .OP_NOT       : fallthrough
		case .OP_NEGATE    : fallthrough
		case .OP_BIT_NEGATE: return true
		case               : return false
	}

	return false
}