package Variant

evalue	 :: #type proc(lhs,rhs,variant_return: ^Value, ctx: ^Context)

@(private="file") dispatch_table  : [Opcode.OP_OPERATOR_COUNT][VariantType][VariantType]evalue


register_variant_operators :: proc()
{
	// op_Literal
	register_op(.OP_TRUE,.NIL,.NIL,variant_variant_true)
	register_op(.OP_FALSE,.NIL,.NIL,variant_variant_false)
	register_op(.OP_NIL,.NIL,.NIL,variant_variant_nil)

	// 
	register_op(.OP_EQUAL,.NIL,.NIL,nil_nil_equal)
	register_op(.OP_NOT_EQUAL,.NIL,.NIL,nil_nil_not_equal)

	// BOOL
	register_op(.OP_EQUAL,.BOOL,.BOOL,bool_bool_equal)
	register_op(.OP_NOT_EQUAL,.BOOL,.BOOL,bool_bool_not_equal)

	// INT
	register_op(.OP_NEGATE,.INT,.INT,int_int_negate)

	register_op(.OP_ADD,.INT,.INT,int_int_add)
	register_op(.OP_SUB,.INT,.INT,int_int_sub)
	register_op(.OP_MULT,.INT,.INT,int_int_mult)
	register_op(.OP_DIV,.INT,.INT,int_int_div)
	register_op(.OP_MOD,.INT,.INT,int_int_mod)

	register_op(.OP_LESS,.INT,.INT,int_int_less)
	register_op(.OP_GREATER,.INT,.INT,int_int_greater)
	register_op(.OP_EQUAL,.INT,.INT,int_int_equal)

	register_op(.OP_LESS_EQUAL,.INT,.INT,int_int_less_equal)
	register_op(.OP_GREATER_EQUAL,.INT,.INT,int_int_greater_equal)
	register_op(.OP_NOT_EQUAL,.INT,.INT,int_int_not_equal)

	register_op(.OP_BIT_NEGATE,.INT,.INT,int_bit_negate)
	register_op(.OP_BIT_AND,.INT,.INT,int_int_bit_and)
	register_op(.OP_BIT_OR,.INT,.INT,int_int_bit_or)
	register_op(.OP_BIT_XOR,.INT,.INT,int_int_bit_xor)
	register_op(.OP_SHIFT_LEFT,.INT,.INT,int_int_bit_shift_left)
	register_op(.OP_SHIFT_RIGHT,.INT,.INT,int_int_bit_shift_right)

 
    // INT, FLOAT
	register_op(.OP_ADD,.INT,.FLOAT,int_float_add)
	register_op(.OP_SUB,.INT,.FLOAT,int_float_sub)
	register_op(.OP_MULT,.INT,.FLOAT,int_float_mult)
	register_op(.OP_DIV,.INT,.FLOAT,int_float_div)

	register_op(.OP_LESS,.INT,.FLOAT,int_float_less)
	register_op(.OP_GREATER,.INT,.FLOAT,int_float_greater)
	register_op(.OP_EQUAL,.INT,.FLOAT,int_float_equal)

	register_op(.OP_LESS_EQUAL,.INT,.FLOAT,int_float_less_equal)
	register_op(.OP_GREATER_EQUAL,.INT,.FLOAT,int_float_greater_equal)
	register_op(.OP_NOT_EQUAL,.INT,.FLOAT,int_float_not_equal)

	// FLOAT,INT
	register_op(.OP_ADD,.FLOAT,.INT,float_int_add)
	register_op(.OP_SUB,.FLOAT,.INT,float_int_sub)
	register_op(.OP_MULT,.FLOAT,.INT,float_int_mult)
	register_op(.OP_DIV,.FLOAT,.INT,float_int_div)

	
	register_op(.OP_LESS,.FLOAT,.INT,float_int_less)
	register_op(.OP_GREATER,.FLOAT,.INT,float_int_greater)
	register_op(.OP_EQUAL,.FLOAT,.INT,float_int_equal)


	register_op(.OP_LESS_EQUAL,.FLOAT,.INT,float_int_less_equal)
	register_op(.OP_GREATER_EQUAL,.FLOAT,.INT,float_int_greater_equal)
	register_op(.OP_NOT_EQUAL,.FLOAT,.INT,float_int_not_equal)


	// FLOAT
	register_op(.OP_NEGATE,.FLOAT,.FLOAT,float_float_negate)

	register_op(.OP_ADD,.FLOAT,.FLOAT,float_float_add)
	register_op(.OP_SUB,.FLOAT,.FLOAT,float_float_sub)
	register_op(.OP_MULT,.FLOAT,.FLOAT,float_float_mult)
	register_op(.OP_DIV,.FLOAT,.FLOAT,float_float_div)

	register_op(.OP_LESS,.FLOAT,.FLOAT,float_float_less)
	register_op(.OP_GREATER,.FLOAT,.FLOAT,float_float_greater)
	register_op(.OP_EQUAL,.FLOAT,.FLOAT,float_float_equal)

	register_op(.OP_LESS_EQUAL,.FLOAT,.FLOAT,float_float_less_equal)
	register_op(.OP_GREATER_EQUAL,.FLOAT,.FLOAT,float_float_greater_equal)
	register_op(.OP_NOT_EQUAL,.FLOAT,.FLOAT,float_float_not_equal)


	// 
	register_op(.OP_INHERIT,.CLASS,.CLASS,variant_variant_inherit)
	register_fallback()
}


register_op    :: proc "contextless" (op: Opcode, type_left,type_right: VariantType, function: evalue ) { dispatch_table[op][type_left][type_right] = function }
get_op_unary   :: #force_inline proc "contextless" (op: Opcode, type_a: VariantType)        -> evalue { return dispatch_table[op][type_a][type_a] }
get_op_binary  :: #force_inline proc "contextless" (op: Opcode, type_a,type_b: VariantType) -> evalue { return dispatch_table[op][type_a][type_b] }






// fallback
register_fallback :: proc "contextless" ()
{
	for op in Opcode(0)..< Opcode.OP_OPERATOR_COUNT do for type_a in VariantType do for type_b in VariantType 
	{			
		if get_op_binary(op,type_a,type_b) != nil do continue 

		#partial switch op
		{
			case .OP_BOOLIANIZE: register_op(op,type_a,type_b,variant_variant_boolianize); continue
			case .OP_NOT       : register_op(op,type_a,type_b,variant_variant_not);        continue
			case .OP_AND       : register_op(op,type_a,type_b,variant_variant_and);        continue
			case .OP_OR        : register_op(op,type_a,type_b,variant_variant_or);         continue
			case .OP_EQUAL     : register_op(op,type_a,type_b,variant_variant_equal);      continue	
		}

		register_op(op,type_a,type_b, is_opcode_unary(op) ? variant_variant_unary_fallback:variant_variant_fallback)
			// #partial switch op
			// {
			// 	case .OP_EQUAL : dispatch_table[op][type_a][type_b]    = evaluate_variant_variant_equal
			// 	case .OP_AND   : dispatch_table[op][type_a][.NONE_VAL] = evaluate_variant_variant_and
			// 	case .OP_OR    : dispatch_table[op][type_a][.NONE_VAL] = evaluate_variant_variant_or
			// 	case .OP_NOT   : dispatch_table[op][type_a][.NONE_VAL] = evaluate_variant_not	
			// } 
	}  
}




variant_variant_fallback :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context) {
	if   ctx.trace_err do ctx.runtime_error(false,"invalid operation between '%v' and '%v' .",GET_VARIANT_TYPE_NAME(variant_left),GET_VARIANT_TYPE_NAME(variant_right))
	BOOL_VAL_PTR(variant_return,false)
	ctx.err_count += 1
}

variant_variant_unary_fallback :: #force_inline proc(_,variant_right,variant_return: ^Value, ctx: ^Context) {
	if ctx.trace_err do ctx.runtime_error(false,"unary operation not supported for type '%v'.",GET_VARIANT_TYPE_NAME(variant_right))	
	BOOL_VAL_PTR(variant_return,false)
	ctx.err_count += 1
}

// ================================================== inherit

variant_variant_inherit :: #force_inline proc(to,from,_: ^Value, ctx: ^Context)
{
    cid    := AS_INT_PTR(to)
    sid    := AS_INT_PTR(from)

    if ctx.runtime_error(class_db_can_extends(sid),"could not find base Class '%v'.",class_db_get_class_name(sid)) do return
    class_db_set_sid(cid,sid)
}


// ================================================== generic

variant_variant_boolianize :: #force_inline proc(_,variant_right,variant_return: ^Value, ctx: ^Context) {
	_bool := BOOLEANIZE(variant_right)
	if ctx.gc_allowed do unref_value(variant_right)
	BOOL_VAL_PTR(variant_return,_bool)
}

// Nota(jstn): recebe um valor bool, não é necessario unref
variant_variant_not :: #force_inline proc(_,variant_right,variant_return: ^Value, ctx: ^Context) {
	BOOL_VAL_PTR(variant_return,!AS_BOOL_PTR(variant_right))
}

variant_variant_and :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context) {
	BOOL_VAL_PTR(variant_return,AS_BOOL_PTR(variant_left) && AS_BOOL_PTR(variant_right))
}

variant_variant_or :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context) {
	BOOL_VAL_PTR(variant_return,AS_BOOL_PTR(variant_left) || AS_BOOL_PTR(variant_right))
}

variant_variant_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context) 
{
	_bool := variant_hash_compare(variant_left,variant_right,0)
	if ctx.gc_allowed { unref_value(variant_left); unref_value(variant_right) }
	BOOL_VAL_PTR(variant_return,_bool)
}


//  ================================================== literal
variant_variant_true :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context) {
	BOOL_VAL_PTR(variant_return,true)
}

variant_variant_false :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context) {
	BOOL_VAL_PTR(variant_return,false)
}

variant_variant_nil :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context) {
	NIL_VAL_PTR(variant_return)
}

// =================================================== nil
nil_nil_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context) {
	BOOL_VAL_PTR(variant_return,true)
}

nil_nil_not_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context) {
	BOOL_VAL_PTR(variant_return,false)
}

// ================================================== bool
bool_bool_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_BOOL_PTR(variant_left) == AS_BOOL_PTR(variant_right))
}

bool_bool_not_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_BOOL_PTR(variant_left) != AS_BOOL_PTR(variant_right))
}


// ===================================================== int
int_int_negate :: #force_inline proc(_,variant_right,variant_return: ^Value, ctx: ^Context) { 
	INT_VAL_PTR(variant_return,-AS_INT_PTR(variant_right)) 
}

int_int_add :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	INT_VAL_PTR(variant_return,AS_INT_PTR(variant_left)+AS_INT_PTR(variant_right))
}

int_int_sub :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	INT_VAL_PTR(variant_return,AS_INT_PTR(variant_left)-AS_INT_PTR(variant_right))
}

int_int_mult :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	INT_VAL_PTR(variant_return,AS_INT_PTR(variant_left)*AS_INT_PTR(variant_right))
}

int_int_div :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context)
{
	b := AS_INT_PTR(variant_right)
	if ctx.runtime_error(b != 0,"division by zero error in operator '/'.") do return
	INT_VAL_PTR(variant_return,AS_INT_PTR(variant_left)/b)
}

int_int_mod :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context)
{
	b 	  := AS_INT_PTR(variant_right)
	if ctx.runtime_error(b != 0,"modulo by zero error in operator '%%'.") do return
	INT_VAL_PTR(variant_return,AS_INT_PTR(variant_left)%b)
}

int_int_bit_and :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	INT_VAL_PTR(variant_return,AS_INT_PTR(variant_left) & AS_INT_PTR(variant_right))
}

int_int_bit_or :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	INT_VAL_PTR(variant_return,AS_INT_PTR(variant_left) | AS_INT_PTR(variant_right))
}

int_int_bit_xor :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	INT_VAL_PTR(variant_return,AS_INT_PTR(variant_left) ~ AS_INT_PTR(variant_right))
}

int_bit_negate :: #force_inline proc(_,variant_right,variant_return: ^Value, ctx: ^Context){
	INT_VAL_PTR(variant_return,~AS_INT_PTR(variant_right))
}

int_int_bit_shift_left :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context)
{
	a := AS_INT_PTR(variant_left)
	b := AS_INT_PTR(variant_right)

	if ctx.runtime_error(a > 0 || b > 0,"invalid operands for bit shifting. Only positive operands are supported.") do return
	INT_VAL_PTR(variant_return, Int(uint(a) << uint(b)))
}

int_int_bit_shift_right :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context)
{
	a := AS_INT_PTR(variant_left)
	b := AS_INT_PTR(variant_right)

	if ctx.runtime_error(a > 0 || b > 0,"invalid operands for bit shifting. Only positive operands are supported.") do return 
	INT_VAL_PTR(variant_return, Int(uint(a) >> uint(b)))
}

int_int_less :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_INT_PTR(variant_left) < AS_INT_PTR(variant_right))
}

int_int_greater :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_INT_PTR(variant_left) > AS_INT_PTR(variant_right))
}

int_int_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_INT_PTR(variant_left) == AS_INT_PTR(variant_right))
}

int_int_less_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_INT_PTR(variant_left) <= AS_INT_PTR(variant_right))
}

int_int_greater_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_INT_PTR(variant_left) >= AS_INT_PTR(variant_right))
}

int_int_not_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_INT_PTR(variant_left) != AS_INT_PTR(variant_right))
}



// ============================================ Int and float

int_float_add :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	FLOAT_VAL_PTR(variant_return,Float(AS_INT_PTR(variant_left))+AS_FLOAT_PTR(variant_right))
}

int_float_sub :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	FLOAT_VAL_PTR(variant_return,Float(AS_INT_PTR(variant_left))-AS_FLOAT_PTR(variant_right))
}

int_float_mult :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	FLOAT_VAL_PTR(variant_return,Float(AS_INT_PTR(variant_left))*AS_FLOAT_PTR(variant_right))
}

int_float_div :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context)
{
	b := AS_FLOAT_PTR(variant_right)
	if ctx.runtime_error(b != 0,"division by zero error in operator '/'.") do return
	FLOAT_VAL_PTR(variant_return,Float(AS_INT_PTR(variant_left))/b)
}

int_float_less :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,Float(AS_INT_PTR(variant_left)) < AS_FLOAT_PTR(variant_right))
}

int_float_greater :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,Float(AS_INT_PTR(variant_left)) > AS_FLOAT_PTR(variant_right))
}

int_float_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,Float(AS_INT_PTR(variant_left)) == AS_FLOAT_PTR(variant_right))
}

int_float_less_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,Float(AS_INT_PTR(variant_left)) <= AS_FLOAT_PTR(variant_right))
}

int_float_greater_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,Float(AS_INT_PTR(variant_left)) >= AS_FLOAT_PTR(variant_right))
}
int_float_not_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,Float(AS_INT_PTR(variant_left)) != AS_FLOAT_PTR(variant_right))
}


// ============================================ float and Int

float_int_add :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	FLOAT_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left)+Float(AS_INT_PTR(variant_right)))
}

float_int_sub :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	FLOAT_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left)-Float(AS_INT_PTR(variant_right)))
}

float_int_mult :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	FLOAT_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left)*Float(AS_INT_PTR(variant_right)))
}

float_int_div :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context)
{
	b := AS_INT_PTR(variant_right)
	if ctx.runtime_error(b != 0,"division by zero error in operator '/'.") do return 
	FLOAT_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left)/Float(b))
}


float_int_less :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left) < Float(AS_INT_PTR(variant_right)))
}

float_int_greater :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left) > Float(AS_INT_PTR(variant_right)))
}

float_int_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left) == Float(AS_INT_PTR(variant_right)))
}

float_int_less_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left) <= Float(AS_INT_PTR(variant_right)))
}

float_int_greater_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left) >= Float(AS_INT_PTR(variant_right)))
}

float_int_not_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left) != Float(AS_INT_PTR(variant_right)))
}



// ============================================ float
float_float_negate :: #force_inline proc(_,variant_right,variant_return: ^Value, ctx: ^Context){
	FLOAT_VAL_PTR(variant_return,-AS_FLOAT_PTR(variant_right))
}



float_float_add :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	FLOAT_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left)+AS_FLOAT_PTR(variant_right))
}

float_float_sub :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	FLOAT_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left)-AS_FLOAT_PTR(variant_right))
}

float_float_mult :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	FLOAT_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left)*AS_FLOAT_PTR(variant_right))
}

float_float_div :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	b := AS_FLOAT_PTR(variant_right)
	if ctx.runtime_error(b != 0,"division by zero error in operator '/'.") do return 
	FLOAT_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left)/b)
}

float_float_less :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left) < AS_FLOAT_PTR(variant_right))
}

float_float_greater :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left) > AS_FLOAT_PTR(variant_right))
}

float_float_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left) == AS_FLOAT_PTR(variant_right))
}

float_float_less_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left) <= AS_FLOAT_PTR(variant_right))
}

float_float_greater_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left) >= AS_FLOAT_PTR(variant_right))
}

float_float_not_equal :: #force_inline proc(variant_left,variant_right,variant_return: ^Value, ctx: ^Context){
	BOOL_VAL_PTR(variant_return,AS_FLOAT_PTR(variant_left) != AS_FLOAT_PTR(variant_right))
}




