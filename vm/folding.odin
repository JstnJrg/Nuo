package VM

import linalg "core:math/linalg"



is   :: proc "contextless" (lhs_type,rhs_type,a,b: AstType, ) -> bool { return lhs_type == a && rhs_type == b }



fold :: proc(node: ^Node) -> ^Node
{

	#partial switch node.type
	{
		case .BINARY:

			binary_node       := reinterpret_node(node,BinaryNode)
			binary_node.lhs    = fold(binary_node.lhs)
			binary_node.rhs    = fold(binary_node.rhs)

			loc               := binary_node.loc
			op                := binary_node.op
			lhs_type          := binary_node.lhs.type
			rhs_type          := binary_node.rhs.type

			if lhs_type != rhs_type
			{
				if      is(lhs_type,rhs_type,.FLOAT,.INT)
				{
					res, error := folding_float_int(binary_node.lhs,binary_node.rhs,op,loc)
					error or_break
					return res
				}
				else if is(lhs_type,rhs_type,.INT,.FLOAT)
				{
					res, error := folding_int_float(binary_node.lhs,binary_node.rhs,op,loc)
					error or_break
					return res
				}

				return node
			}

			#partial switch lhs_type
			{
				case .INT: 
					res, error := folding_int(binary_node.lhs,binary_node.rhs,op,loc)
					error or_break 
					return res

				case .FLOAT: 
					res, error := folding_float(binary_node.lhs,binary_node.rhs,op,loc)
					error      or_break
					return res

				case .STRING:
					res , error := folding_string(binary_node.lhs,binary_node.rhs,op,loc)
					error or_break
					return res
			}
	}

	return node
}

folding_int       :: proc(nlhs,nrhs: ^Node, op : Opcode,loc: Localization) -> (^Node, bool)
{
	lhs      := reinterpret_node(nlhs,IntNode).number
	rhs      := reinterpret_node(nrhs,IntNode).number

	#partial switch op
	{
		case .OP_SUB : return create_int_node(lhs-rhs,loc), true
		case .OP_ADD : return create_int_node(lhs+rhs,loc), true
		case .OP_MULT: return create_int_node(lhs*rhs,loc), true
		case .OP_DIV : 

			if rhs == 0 do return nil, false
			return create_int_node(lhs/rhs,loc), true

		// case .OP_MULT_MULT: return create_int_node(linalg.pow(lhs,rhs),loc)
		case .OP_MOD      : 

			if rhs == 0 do return nil, false
			return create_int_node(lhs%rhs,loc), true


		case .OP_SHIFT_LEFT : 

			if lhs < 0 || rhs < 0 do return nil, false
			return create_int_node(int(uint(lhs) << uint(rhs)),loc), true

		case .OP_SHIFT_RIGHT: 

			if lhs < 0 || rhs < 0 do return nil, false
			return create_int_node(int(uint(lhs) >> uint(rhs)),loc), true

		case .OP_EQUAL      : return create_literal_node((lhs == rhs) ? .OP_TRUE: .OP_FALSE,loc), true
		case .OP_LESS       : return create_literal_node((lhs < rhs) ? .OP_TRUE: .OP_FALSE,loc), true
		case .OP_GREATER    : return create_literal_node((lhs > rhs) ? .OP_TRUE: .OP_FALSE,loc), true
		case .OP_NOT_EQUAL  : return create_literal_node((lhs != rhs) ? .OP_TRUE: .OP_FALSE,loc), true

		case .OP_LESS_EQUAL       : return create_literal_node((lhs <= rhs) ? .OP_TRUE: .OP_FALSE,loc), true
		case .OP_GREATER_EQUAL    : return create_literal_node((lhs >= rhs) ? .OP_TRUE: .OP_FALSE,loc), true

		case .OP_BIT_AND    : return create_int_node(lhs & rhs ,loc), true
		case .OP_BIT_OR     : return create_int_node(lhs | rhs ,loc), true
		case .OP_BIT_XOR    : return create_int_node(lhs ~ rhs ,loc), true
	}

	return nil, false
} 


folding_float     :: proc(nlhs,nrhs: ^Node, op : Opcode,loc: Localization) -> (^Node, bool)
{
	lhs      := reinterpret_node(nlhs,FloatNode).number
	rhs      := reinterpret_node(nrhs,FloatNode).number

	#partial switch op
	{
		case .OP_SUB : return create_float_node(lhs-rhs,loc), true
		case .OP_ADD : return create_float_node(lhs+rhs,loc), true
		case .OP_MULT: return create_float_node(lhs*rhs,loc), true
		case .OP_DIV : 

			if rhs == 0 do return nil, false
			return create_float_node(lhs/rhs,loc), true

		case .OP_EQUAL      : return create_literal_node((lhs == rhs) ? .OP_TRUE: .OP_FALSE,loc), true
		case .OP_LESS       : return create_literal_node((lhs < rhs) ? .OP_TRUE: .OP_FALSE,loc), true
		case .OP_GREATER    : return create_literal_node((lhs > rhs) ? .OP_TRUE: .OP_FALSE,loc), true
		case .OP_NOT_EQUAL  : return create_literal_node((lhs != rhs) ? .OP_TRUE: .OP_FALSE,loc), true

		case .OP_LESS_EQUAL       : return create_literal_node((lhs <= rhs) ? .OP_TRUE: .OP_FALSE,loc), true
		case .OP_GREATER_EQUAL    : return create_literal_node((lhs >= rhs) ? .OP_TRUE: .OP_FALSE,loc), true
	}

	return nil, false
} 

folding_string    :: proc(nlhs,nrhs: ^Node, op: Opcode,loc: Localization) -> (^Node, bool)
{
	lhs      := reinterpret_node(nlhs,StringNode).str
	rhs      := reinterpret_node(nrhs,StringNode).str

	#partial switch op
	{
		case .OP_ADD:
			str, _ := concatenate([]string{lhs,rhs},ctx_aallocator())
			return create_string_node(str,loc),true
	}

	return nil, false
} 

folding_float_int :: proc(nlhs,nrhs: ^Node, op : Opcode,loc: Localization) -> (^Node, bool)
{
	lhs      := reinterpret_node(nlhs,FloatNode).number
	rhs      := f32(reinterpret_node(nrhs,IntNode).number)

	#partial switch op
	{
		case .OP_SUB : return create_float_node(lhs-rhs,loc), true
		case .OP_ADD : return create_float_node(lhs+rhs,loc), true
		case .OP_MULT: return create_float_node(lhs*rhs,loc), true
		case .OP_DIV : 

			if rhs == 0 do return nil, false
			return create_float_node(lhs/rhs,loc), true

		case .OP_EQUAL      : return create_literal_node((lhs == rhs) ? .OP_TRUE: .OP_FALSE,loc), true
		case .OP_LESS       : return create_literal_node((lhs < rhs) ? .OP_TRUE: .OP_FALSE,loc), true
		case .OP_GREATER    : return create_literal_node((lhs > rhs) ? .OP_TRUE: .OP_FALSE,loc), true
		case .OP_NOT_EQUAL  : return create_literal_node((lhs != rhs) ? .OP_TRUE: .OP_FALSE,loc), true

		case .OP_LESS_EQUAL       : return create_literal_node((lhs <= rhs) ? .OP_TRUE: .OP_FALSE,loc), true
		case .OP_GREATER_EQUAL    : return create_literal_node((lhs >= rhs) ? .OP_TRUE: .OP_FALSE,loc), true
	}

	return nil, false
}

folding_int_float :: proc(nlhs,nrhs: ^Node, op : Opcode,loc: Localization) -> (^Node, bool)
{
	lhs      := f32(reinterpret_node(nlhs,IntNode).number)
	rhs      := reinterpret_node(nrhs,FloatNode).number

	#partial switch op
	{
		case .OP_SUB : return create_float_node(lhs-rhs,loc), true
		case .OP_ADD : return create_float_node(lhs+rhs,loc), true
		case .OP_MULT: return create_float_node(lhs*rhs,loc), true
		case .OP_DIV : 

			if rhs == 0 do return nil, false
			return create_float_node(lhs/rhs,loc), true

		case .OP_EQUAL      : return create_literal_node((lhs == rhs) ? .OP_TRUE: .OP_FALSE,loc), true
		case .OP_LESS       : return create_literal_node((lhs < rhs) ? .OP_TRUE: .OP_FALSE,loc), true
		case .OP_GREATER    : return create_literal_node((lhs > rhs) ? .OP_TRUE: .OP_FALSE,loc), true
		case .OP_NOT_EQUAL  : return create_literal_node((lhs != rhs) ? .OP_TRUE: .OP_FALSE,loc), true

		case .OP_LESS_EQUAL       : return create_literal_node((lhs <= rhs) ? .OP_TRUE: .OP_FALSE,loc), true
		case .OP_GREATER_EQUAL    : return create_literal_node((lhs >= rhs) ? .OP_TRUE: .OP_FALSE,loc), true
	}

	return nil, false
}
