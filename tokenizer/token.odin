package Tokenizer

Token :: struct
{
	position  : Localization,
	text      : string,
	type      : TokenType
}


Localization :: struct
{
	file  : string,
	line  : int,  
	column: int,
	offset: int 
}


TokenType :: enum u8
{
	Invalid, //start
	Error,
	EOF,
	Underscore,
	Coment,

	L_Literal_Begin,
	    Int,
	    Float,
	    String,
	    Identifier,
	    WString,
	    Array,
    L_Literal_End,


    L_Operator_begin,
	    Equal,      // =
	    Not,        // !
	    Hash,       // #
	    At,         // @
	    Dollar,     // $
	    Question,   // ?
	    Add,        // +
	    Sub,        // -
	    Mult,       // *
	    Quo,        // /
	    Mod,        // %

	    Mult_Mult, // **

	    And_Bit,    // &
	    Or_Bit,     // |
	    Xor_Bit,    // ^
	    And_Not_Bit,// &~
	    Shift_L_Bit,// <<
	    Shift_R_Bit,// >>

	L_Assign_Operator_Begin,
	    Add_Eq,     // +=
	    Sub_Eq,     // -=
	    Mult_Eq,    // *=
	    Quo_Eq,     // /=
	    Mod_Eq,     // %=

	    And_Bit_Eq, // &=
	    Or_Bit_Eq,  // |=
	    Not_Bit,    // ~
	    Xor_Bit_Eq, // ^=
	    Shift_L_Bit_Eq, // <<=
	    Shift_R_Bit_Eq, // >>=
	L_Assign_Operator_End,

	L_Comparison_Begin,
	    Equal_Eq,   // ==
	    Not_Eq,     // !=
	    Less,       // <
	    Less_Eq,    // <=
	    Greater,      // >
	    Greater_Eq,   // >=
	L_Comparison_End,
	
	    Open_Paren,     // (
	    Close_Paren,    // )
	    Open_Bracket,   // [
	    Close_Bracket,  // ]
	    Open_Brace,     // {
	    Close_Brace,    // }

	    Colon,      // :
	    Comma,      // ,
	    Semicolon,  // ;
	    Dot,        // .
	    Dot_Dot,    // ..
	    Newline,    // '\n'

    L_Operator_End,

    L_Keyword_Begin,
	    Import,     // import
	    Class,      // class
	    Super,      // super
	    This,       // this
	    In,         // in
	    Extends,    // extends

	    If,         // if
	    Elif,       // elif
	    Else,       // else
	    For,        // for
	    While,      // while,
	    // Repeat,     // repeat
	    Until,      // until

	    Match,      // Match
	    Case,       // case
	    Break,      // break
	    As,         // as
	    From,       // from
	    Continue,   // continue
	    Return,     // return
	    Fn,         // fn
	    Set,        // var
	    // Enum,       // enum

	    True,       // true
	    False,      // false
	    Null,       // null

	    With,       // with

	    And,        // and,&&
	    Or,         // or,||
	    Not_Literal,// Not

	L_Keyword_End,
  
    COUNT,
    
    L_Custom_Keyword_Begin,

    	Vec2,			// Vec2
    	Rect2,          // Rect2
    	Transform2D,
    	Color,
    	Signal,
    	Callable,
    	// Task
    	Complex
}


Tokens := [TokenType.COUNT]string{
	"Invalid", //start
	"Error",
	"EOF",
	"_",
	"Coment",

	"",
	    "integer",
	    "float",
	    "String",
	    "identifier",
	    "WString",
	    "Array",
    "",

    "",
	    "=",      // =
	    "!",      // !
	    "#",      // #
	    "@",      // @
	    "$",      // $
	    "?",      // ?
	    "+",      // +
	    "-",      // -
	    "*",      // *
	    "/",      // /
	    "%",      // %

	    "**",     // **
	    "&",      // &
	    "|",      // |
	    "^",      // ^
	    "&~",     // &~
	    "<<",     // <<
	    ">>",     // >>

	"",
	    "+=",     // +=
	    "-=",     // -=
	    "*=",     // *=
	    "/=",     // /=
	    "%=",     // %=
	    "&=",     // &=
	    "|=",     // |=
	    "~",      // ~
	    "^=",     // ^=
	    "<<=",    // <<=
	    ">>=",    // >>=
	"",

	"",
	    "==",     // ==
	    "!=",     // !=
	    "<",      // <
	    "<=",     // <=
	    ">",      // >
	    ">=",     // >=
	"",
	    ")",     // (
	    "(",     // )
	    "[",     // [
	    "]",     // ]
	    "{",     // {
	    "}",     // }
	    ":",     // :
	    ",",     // ,
	    ";",     // ;
	    ".",     // .
	    "..",    // ..
	    "\\n",   // '\n'
	"",

	"",
    "import",     // import
    "Class",      // class

    "super",      //super
    "this",       // this
    "in",         // in
    "extends",    // extends
    // "new",        // new
    "if",         // if
    "elif",       // elif
    "else",       // else
    "for",        // for
    "while",      // while,
    // "repeat",      // repeat
    "until",      // until

    "match",      // Match
    "case",       // case
    "break",      // break
    "as",         // as
    "from",       // from
    "continue",   // continue
    "return",     // return
    "fn",         // fn
    "set",        // set
    // Enum,      // enum
    // Assert,    // assert

    "true",       // true
    "false",      // false
    "null",       // null

    "with",    // with

    "and",    // and,&&
    "or",     // or,||
    "not",    // Not

    ""
} 


custom_keyword_tokens := []string{
    "Vec2",
    "Rect2",
    "Transform2D",
    "Color",
    "Signal",
    "Callable",
    // "Task"
    "Complex"
}