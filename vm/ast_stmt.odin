package VM

StmtNode   :: struct 
{
	using base : Node,
	expr 	   : ^Node			
}

ClassNode :: struct 
{
	using base   :  Node,
	methods      : ^Node,
	super        : ^Node, 
	properties   : ^Node,
	properties_n :  StringMap,
	name         :  string, 
	field_count  :  int,
	extends      :  bool,
	loc          :  Localization		
}

ImportNode :: struct 
{
	using base :  Node,
	name       :  string,
	iname      :  string,
	fid        :  int,
	iid        :  int,
	imported   :  bool,
	native     :  bool,
	loc        :  Localization		
}

FunctionNode :: struct 
{
	using base :  Node,
	body       : ^Node,
	name       :  string,
	argc       :  int,
	loc        :  Localization		
}

PrintNode :: struct 
{
	using base :  Node,
	expr       : ^Node,
	loc        :  Localization		
}

DefineVariableNode :: struct
{
	using base :  Node,
	rhs        : ^Node,
	name       :  string,
	local      :  bool,
	loc        : Localization
}

BlockNode     :: struct 
{
	using base  :  Node,
	body        : ^Node,
	l_count     :  int,
	loc         :  Localization
}

WhileNode     :: struct 
{
	using base  :  Node,
	condition   : ^Node,
	body        : ^Node,
	loc         :  Localization
}

ForNode     :: struct 
{
	using base  :  Node,
	body        : ^Node,
	loc         :  Localization
}

MatchNode  :: struct 
{
	using base    :  Node,
	condition     : ^Node,
	cases         : ^Node,
	bodies        : ^Node,
	dbody         : ^Node,
	default       : bool,
	loc           : Localization
}


IfNode  :: struct 
{
	using base  :  Node,
	condition   : ^Node,
	body        : ^Node,
	elif        : ^Node,
	loc         :  Localization
}

BreakNode :: struct
{
	using base : Node,
	l_count    : int,
	loc        : Localization
}

ContinueNode :: struct
{
	using base : Node,
	l_count    : int,
	loc        : Localization
}

ReturnNode :: struct
{
	using base :  Node,
	expr       : ^Node,
	l_count    :  int,
	loc        :  Localization
}