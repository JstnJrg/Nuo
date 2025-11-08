#+private

package VM


opt :: proc(node: ^Node) -> (^Node, bool)
{
	#partial switch node.type
	{
		// case .BINARY:

		// 	binary_node := reinterpret_node(node,BinaryNode)
		// 	lhs         := binary_node.lhs
		// 	rhs         := binary_node.rhs
		// 	op          := binary_node.op
		// 	loc         := binary_node.loc

		// 	println("--------------> COnstante", rhs,lhs)
		// 	if lhs.constant && rhs.constant
		// 	{

		// 	}

	}


	return nil, false
} 