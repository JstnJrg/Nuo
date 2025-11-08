package VM


AstSet           :: bit_set[AstType;u64]

get_node_type    :: proc "contextless"(node: ^Node) -> AstType { return node.type }
can_assign_node  :: proc "contextless" (node: ^Node) -> bool   { return node.type == .NAMED_VAR && reinterpret_node(node,NamedVariableNode).can_assign }

is_in_set_node   :: proc "contextless" (set: AstSet, node: ^Node) -> bool { return node.type in set }
is_callable      :: proc "contextless" (node: ^Node) -> bool 
{
	set  :: AstSet{.UNARY,.BINARY,.LITERAL,.INT,.FLOAT,.STRING,.VECTOR}
	return is_in_set_node(set,node)
}

reinterpret_node :: proc "contextless"(node: ^Node, $T: typeid) -> ^T { return (^T)(node) }

container_node_append :: proc(c,node: ^Node) { c := reinterpret_node(c,ContainerNode); append(&c.args,node) }
get_container_node_len:: proc(c: ^Node) -> int 
{ 
	c := reinterpret_node(c,ContainerNode)
	return len(c.args) 
}

block_append_node     :: proc(b: ^Node, node: ^Node)
{
	block := reinterpret_node(b,BlockNode)
	container_node_append(block.body,node)
}




alloca_node :: proc(type: AstType, $T: typeid) -> ^T {
	node     := ctx_anew(T)
	node.type = type
	return node
}

// // ============== PLACEHOLDER
// create_stmt_node :: proc(name: string, loc :) -> ^StmtNode
// {

// 	lhs := 	

	
// 	node      := alloca_node(.STATEMENT,StmtNode)
// 	node.expr  = expr
// 	return node
// }



// =============== EXPR


create_bad_node :: proc(loc: Localization) -> ^BadExprNode {
	node      := alloca_node(.ERROR,BadExprNode)
	node.loc   = loc
	return node
}

create_expression_node :: proc(expr: ^Node, loc: Localization) -> ^ExprNode {
	node      := alloca_node(.EXPRESSION,ExprNode)
	node.expr  = expr
	node.loc   = loc
	return node
}



create_literal_node :: proc(op: Opcode ,loc: Localization) -> ^LiteralNode{
	node         := alloca_node(.LITERAL,LiteralNode)
	node.op       = op
	node.loc      = loc
	node.constant = true
	return node
}

create_int_node :: proc(number: Int ,loc: Localization, constant := false) -> ^IntNode{
	node         := alloca_node(.INT,IntNode)
	node.number   = number
	node.constant = constant
	node.loc      = loc
	return node
}

create_float_node :: proc(number: Float ,loc: Localization, constant := false) -> ^FloatNode{
	node         := alloca_node(.FLOAT,FloatNode)
	node.number   = number
	node.constant = constant
	node.loc      = loc
	return node
}

create_string_node :: proc(data: string ,loc: Localization, constant := false) -> ^StringNode{
	node         := alloca_node(.STRING,StringNode)
	node.str      = data
	node.constant = constant
	node.loc      = loc
	return node
}


create_binary_node :: proc(op: Opcode,lhs,rhs: ^Node,loc: Localization) -> ^BinaryNode{
	node         := alloca_node(.BINARY,BinaryNode)
	node.lhs      = lhs
	node.rhs      = rhs
	node.op       = op
	node.loc      = loc
	return node
}

create_ternary_node :: proc(condition,lhs,rhs: ^Node,loc: Localization) -> ^TernaryNode {
	node           := alloca_node(.TERNARY,TernaryNode)
	node.condition  = condition
	node.lhs        = lhs
	node.rhs        = rhs
	node.loc        = loc
	return node
}

create_unary_node :: proc(op: Opcode,rhs: ^Node,loc: Localization) -> ^UnaryNode{
	node         := alloca_node(.UNARY,UnaryNode)
	node.rhs      = rhs
	node.op       = op
	node.loc      = loc
	return node
}

create_dinamic_node :: proc(type: AstType ,args: ^Node,loc: Localization) -> ^DinamicNode{
	node        := alloca_node(type,DinamicNode)
	node.args    = args
	node.loc     = loc
	return node
}

create_container_node :: proc() -> ^ContainerNode{

	node        := alloca_node(.CONTAINER,ContainerNode)
	node.args    = ctx_amake([dynamic]^Node)
	return node
}

create_named_var_node :: proc(name: string,local,can_assign: bool,local_index: int, loc: Localization) -> ^NamedVariableNode{

	node           := alloca_node(.NAMED_VAR,NamedVariableNode)
	node.name       = name
	node.l_index    = local_index
	node.local      = local
	node.can_assign = can_assign
	node.loc        = loc
	return node
}

create_assignment_node :: proc(name: string,local: bool,local_index: int,rhs: ^Node, loc: Localization) -> ^AssignmentNode{

	node        := alloca_node(.ASSIGNMENT,AssignmentNode)
	node.name    = name
	node.l_index = local_index
	node.local   = local
	node.rhs     = rhs
	node.loc     = loc
	return node
}

create_call_node :: proc(callee, args : ^Node, loc: Localization) -> ^CallNode{

	node        := alloca_node(.CALL,CallNode)
	node.callee  = callee
	node.args    = args
	node.loc     = loc
	return node
}

create_call_method_node :: proc(m_name: string,lhs, args: ^Node, loc: Localization) -> ^CallMethodNode{

	node        := alloca_node(.CALL_METHOD,CallMethodNode)
	node.m_name  = m_name
	node.args    = args
	node.lhs     = lhs
	node.loc     = loc
	return node
}

create_super_call_method_node :: proc(m_name: string,lhs, args: ^Node, loc: Localization) -> ^CallMethodNode{

	node        := alloca_node(.SUPER,CallMethodNode)
	node.m_name  = m_name
	node.args    = args
	node.lhs     = lhs
	node.loc     = loc
	return node
}

// create_new_node :: proc(class, args : ^Node, loc: Localization) -> ^NewNode{

// 	node       := alloca_node(.NEW,NewNode)
// 	node.class  = class
// 	node.args   = args
// 	node.loc    = loc
// 	return node
// }

create_get_property_node :: proc(property: string, lhs : ^Node, loc: Localization) -> ^GetPropertyNode{

	node          := alloca_node(.GET_PROPERTY,GetPropertyNode)
	node.property  = property
	node.lhs       = lhs
	node.loc       = loc
	return node
}

create_set_property_node :: proc(property: string,lhs, expr: ^Node, loc: Localization) -> ^SetPropertyNode{

	node          := alloca_node(.SET_PROPERTY,SetPropertyNode)
	node.property  = property
	node.lhs       = lhs
	node.expr      = expr
	node.loc       = loc
	return node
}

create_object_operator_node :: proc(set: bool,lhs,index,rhs: ^Node, loc: Localization) -> ^ObjectOperatorNode
{
	node          := alloca_node(.OBJECT_OPERATOR,ObjectOperatorNode)
	node.lhs       = lhs
	node.index     = index
	node.rhs       = rhs
	node.set       = set
	node.loc       = loc
	return node
}









// ================================== STMT
create_stmt_node :: proc(expr: ^Node) -> ^StmtNode {
	node      := alloca_node(.STATEMENT,StmtNode)
	node.expr  = expr
	return node
}

create_block_node :: proc(local_count: int, container: ^Node, loc : Localization) -> ^ BlockNode{
	node         := alloca_node(.BLOCK,BlockNode)
	node.l_count  = local_count
	node.body     = container
	node.loc      = loc
	return node
}

create_import_node :: proc(fid,iid: int, name,iname: string, imported,native : bool, loc : Localization) -> ^ImportNode {
	node         := alloca_node(.IMPORT,ImportNode)
	node.name     = name
	node.iname    = iname
	node.fid      = fid
	node.iid      = iid
	node.imported = imported
	node.native   = native
	node.loc      = loc
	return node
}

create_print_node :: proc(container: ^Node, loc : Localization) -> ^PrintNode
{
	node       := alloca_node(.PRINT,PrintNode)
	node.expr   = container
	node.loc    = loc
	return node
}

create_class_node :: proc(cname: string,extends: bool, field_count: int , super,container : ^Node, properties_n : StringMap, loc : Localization) -> ^ClassNode
{
	node             := alloca_node(.CLASS,ClassNode)
	node.name         = cname
	node.methods      = container
	node.super        = super
	node.extends      = extends
	node.field_count  = field_count
	node.properties_n = properties_n
	node.loc          = loc
	return node
}


create_definevariable_node :: proc(name: string,is_local: bool,rhs: ^Node, loc : Localization) -> ^DefineVariableNode
{
	node       := alloca_node(.DEFINE_VAR,DefineVariableNode)
	node.rhs    = rhs
	node.name   = name
	node.local  = is_local
	node.loc    = loc
	return node
} 

create_while_node :: proc(condition,body: ^Node, loc : Localization) -> ^WhileNode
{
	node           := alloca_node(.WHILE,WhileNode)
	node.condition  = condition
	node.body       = body
	node.loc        = loc
	return node
}

create_for_node :: proc(body: ^Node, loc : Localization) -> ^ForNode
{
	node           := alloca_node(.FOR,ForNode)
	node.body       = body
	node.loc        = loc
	return node
}

create_match_node :: proc(condition,cases,bodies,dbody: ^Node,default: bool, loc : Localization) -> ^MatchNode
{
	node           := alloca_node(.MATCH,MatchNode)
	node.condition  = condition
	node.cases      = cases
	node.bodies     = bodies
	node.dbody      = dbody
	node.default    = default
	node.loc        = loc
	return node
}

create_if_node :: proc(condition,body,elif: ^Node, loc : Localization) -> ^IfNode
{
	node           := alloca_node(.IF,IfNode)
	node.condition  = condition
	node.body       = body
	node.elif       = elif
	node.loc        = loc
	return node
}  

create_break_node :: proc(local_count: int ,loc : Localization) -> ^BreakNode
{
	node           := alloca_node(.BREAK,BreakNode)
	node.l_count    = local_count
	node.loc        = loc
	return node
} 

create_continue_node :: proc(local_count: int ,loc : Localization) -> ^ContinueNode
{
	node           := alloca_node(.CONTINUE,ContinueNode)
	node.l_count    = local_count
	node.loc        = loc
	return node
} 

create_function_node :: proc(name: string, argc: int, body: ^Node, loc : Localization) -> ^FunctionNode
{
	node           := alloca_node(.FUNCTION,FunctionNode)
	node.name       = name
	node.argc       = argc
	node.body       = body
	node.loc        = loc
	return node
}

create_return_node :: proc(local_count: int, expr: ^Node ,loc : Localization) -> ^ReturnNode
{
	node           := alloca_node(.RETURN,ReturnNode)
	node.l_count    = local_count
	node.expr       = expr
	node.loc        = loc
	return node
} 

create_default_return_node :: proc(local_count: int = 0, loc : Localization) -> ^ReturnNode
{
	node           := alloca_node(.RETURN,ReturnNode)
	node.l_count    = local_count
	node.expr       = create_literal_node(.OP_NIL,loc)
	node.loc        = loc
	return node
}  