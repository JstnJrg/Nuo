package VM


ExprNode   :: struct 
{
	using base : Node,
	expr 	   : ^Node,
	loc 	   : Localization			
}

BadExprNode :: struct 
{
	using base : Node,
	loc        : Localization
}

LiteralNode  :: struct 
{ 
	using base : Node,
	op         : Opcode,
	loc        : Localization
}

IntNode  :: struct 
{ 
	using base : Node,
	number     : Int,
	loc        : Localization
}

FloatNode  :: struct 
{ 
	using base : Node,
	number     : Float,
	loc        : Localization
}

StringNode :: struct 
{
	using base : Node,
	str        : string,
	loc        : Localization
}

UnaryNode :: struct 
{
	using base: Node,
	rhs       : ^Node,
	op        : Opcode,
	loc       : Localization
} 

BinaryNode :: struct 
{
	using base : Node,
	lhs        : ^Node,
	rhs        : ^Node,
	op         : Opcode,
	loc        : Localization
}

TernaryNode :: struct 
{
	using base : Node,
	condition  : ^Node,
	lhs        : ^Node,
	rhs        : ^Node,
	loc        : Localization
}

DinamicNode :: struct 
{
	using base : Node,
	args       : ^Node,
	loc        : Localization
}


// TernaryNode :: struct {
// 	using base :  Node,
// 	lhs        : ^Node,
// 	condition  : ^Node,
// 	rhs        : ^Node,
// 	loc        : Localization
// }

// LogicalNode :: struct {
// 	using base : Node,
// 	lhs        : ^Node,
// 	rhs        : ^Node,
// 	op         : Opcode,
// 	loc        : Localization
// }


ContainerNode :: struct 
{
	using base : Node,
	args       : [dynamic]^Node
}


NamedVariableNode   :: struct 
{
  using base   : Node,
  name         : string,
  l_index      : int,
  can_assign   : bool,
  local        : bool,
  loc          : Localization
}

AssignmentNode   :: struct 
{
  using base   :  Node,
  name         :  string,
  rhs          : ^Node, 
  local        :  bool, 
  l_index      :  int,        
  loc          :  Localization
}

CallNode :: struct 
{
	using base :  Node,
	callee     : ^Node,
	args       : ^Node,
	loc        :  Localization 
}

NewNode      :: struct 
{
	using base :  Node,
	class      : ^Node,
	args       : ^Node,
	loc        :  Localization
}

SetPropertyNode :: struct 
{
	using base :  Node,
	lhs        : ^Node,
	expr       : ^Node,
	property   :  string,     
	loc        :  Localization
}

GetPropertyNode :: struct 
{
	using base :  Node,
	lhs        : ^Node,
	property   :  string,     
	loc        :  Localization
}

// GetImportProperty :: struct
// {
// 	using base   : Node,
// 	tk           : Token,
// 	loc          : Localization
// }

CallMethodNode :: struct 
{
	using base :  Node,
	lhs        : ^Node,
	args       : ^Node,
	m_name     :  string,     
	loc        : Localization
}

ObjectOperatorNode :: struct 
{
	using base :  Node,
	lhs        : ^Node,
	index      : ^Node,
	rhs        : ^Node,
	set        :  bool,
	loc        : Localization
}
