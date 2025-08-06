package General


NUO_IMPORT_NAME     :: `_____GLOBALS_____`
NUO_DEBUG           :: !true
NUO_DEBUG_GC        :: !true

STACK_SIZE		    :: #config(STACK_SIZE,(8*KiloByte)/16)+1
MAX_FRAMES 		    :: 1 << 7

MAX_CHUNK_CONSTANT 	:: #config(CHUNK_SIZE,1 << 9)//usado pela chunk, delimita o numero de constantes na chunk
MAX_VARIABLE_NAME   :: 1 << 5



// MAX_STACK_OPCODE	:: 1 << 8					 //usado pelo compilador, esse numero é mais do que suficiente

// MAX_LOCAL			:: #config(LOCAL_SIZE,1 << 8) // número maximo de variaveis locais
MAX_MATCH_CASE      :: 1 << 8
// MAX_COURROTINE		:: 1 << 4 // rotinas de loops
MAX_ARGUMENTS		:: 1 << 4 // argumentos de funções
// MAX_ENUM_FIELDS     :: 1 << 16
// MAX_VARIABLE_NAME   :: 1 << 5
// MAX_OPCODE			:: 1 << 4
// MAX_JUMP 			:: 1 << 32

// // Nota(jstn) : valores de Stack, Janela de frames e de Programas
// // Nota(jstn) : tirei 1MB de pilha e coloquei 32Kb de pilha, que corresponde a 1024 Values aomesmo tempo na pilha

// MAX_PROGRAM			:: 1 << 0 // 1
// MAX_GLOBAL_FRAME    :: 1 << 4


// // Compiler
// OSCRIPT_ALLOW_RUNFILE_SCOPE          :: !false
// OSCRIPT_REPORT_TOS			         :: !true
// OSCRIPT_DEBUG                        :: !true

// // Nota(jstn) : flags que podem ser desativadas para o tempo de execução, por favor não desactive, pois, pode quebrar o programa
// OSCRIPT_ALLOW_RUNTIME_WARNINGS 		:: true
// OSCRIPT_ALLOW_RUNTIME_CHECK			:: true
// OSCRIPT_ALLOW_RUNTIME_CHECK_BOUNDS  :: true
// OSCRIPT_ALLOW_RUNTIME_PROFILING     :: true