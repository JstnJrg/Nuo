package General


NUO_IMPORT_NAME     :: `_____GLOBALS_____`
NUO_DEBUG           :: !true
NUO_DEBUG_GC        :: true

STACK_SIZE		    :: #config(STACK_SIZE,1024)
MAX_FRAMES 		    :: 1 << 7

MAX_CHUNK_CONSTANT 	:: #config(CHUNK_SIZE,1 << 9)//usado pela chunk, delimita o numero de constantes na chunk
MAX_VARIABLE_NAME   :: 1 << 5


// MAX_STACK_OPCODE	:: 1 << 8					 //usado pelo compilador, esse numero é mais do que suficiente

// MAX_LOCAL			:: #config(LOCAL_SIZE,1 << 8) // número maximo de variaveis locais
MAX_MATCH_CASE      :: 1 << 8
MAX_ARGUMENTS		:: 1 << 4 // argumentos de funções
MAX_FIELDS          :: 1 << 6 // campos de classes
