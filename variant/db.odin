package Variant

DBID  :: int

DB    :: struct
{
	import_db   : ^ImportManager,
	function_db : [dynamic]^Function,
	class_db    : ^ClassManager,
    string_db   : ^StringTable
}

INITIAL_CAPACITY_SDB :: 1 << 8
INITIAL_CAPACITY_IDB :: 1 << 5
INITIAL_CAPACITY_FDB :: 1 << 8
INITIAL_CAPACITY_CDB :: 1 << 5


@(private="file") current_db : ^DB = nil


init_db :: proc()
{
	db_allocator          := get_context_allocator()
	current_db             = new(DB,db_allocator)

	// import_db
	current_db.import_db              = new(ImportManager,db_allocator)
	current_db.import_db.import_array = make([dynamic]^ImportInfo,0,INITIAL_CAPACITY_IDB,db_allocator)
	current_db.import_db.import_mapa  = make(map[string]int,INITIAL_CAPACITY_IDB,db_allocator)


	// function_db
	current_db.function_db   = make([dynamic]^Function,0,INITIAL_CAPACITY_FDB,db_allocator)	

	// class_db
	current_db.class_db      = new(ClassManager,db_allocator)
	class_db                := current_db.class_db
	class_db.class_array     = make([dynamic]^ClassInfo,0,INITIAL_CAPACITY_CDB,db_allocator)
	class_db.class_mapa      = make(map[string]int,INITIAL_CAPACITY_CDB,db_allocator)


	// string_db
	current_db.string_db      = new(StringTable,db_allocator)
	
	string_db                := current_db.string_db
	string_db.string_db       = make([dynamic]String,0,INITIAL_CAPACITY_SDB,db_allocator)
	string_db.string_map      = make(map[string]int,INITIAL_CAPACITY_SDB,db_allocator)
	// string_db.string_hash_map = make(map[u32]int,db_allocator)
}

// function db
db_get_function_db  :: proc "contextless" () -> ^[dynamic]^Function { return &current_db.function_db }
db_append_function  :: proc (f: ^Function ) { append(&current_db.function_db,f) }
db_get_function_id  :: proc "contextless" () -> int { return len(current_db.function_db)} 


// class db
db_get_class_db          :: proc "contextless" () -> ^[dynamic]^ClassInfo { return &current_db.class_db.class_array }
db_get_class_db_mapa     :: proc "contextless" () -> ^map[string]int { return &current_db.class_db.class_mapa }
db_append_class_info     :: proc (c: ^ClassInfo ) { append(&current_db.class_db.class_array,c) }
db_get_classinfo_id      :: proc "contextless" () -> int { return len(current_db.class_db.class_array)} 
db_register_in_mapa      :: proc "contextless" (class_name: string, cid: int) { current_db.class_db.class_mapa[class_name] = cid }
db_check_in_mapa         :: proc "contextless" (class_name: string) -> (int,bool) { return db_get_class_db_mapa()[class_name] }
db_get_classinfo         :: proc "contextless" (cid: int) -> ^ClassInfo { return db_get_class_db()[cid] } 
db_get_classinfo_table   :: proc "contextless" (cid: int) -> ^MethodsTable { return &db_get_classinfo(cid).methods } 


// string db
db_append_string          :: proc(s: String) { append(&current_db.string_db.string_db,s) }
db_get_string_db_map      :: proc "contextless" () -> ^map[string]int { return &current_db.string_db.string_map }
// db_get_string_db_hash_map :: proc "contextless" () -> ^map[u32]int    { return &current_db.string_db.string_hash_map }
db_get_string_id          :: proc "contextless" () -> int { return len(current_db.string_db.string_db) }
db_get_string_db          :: proc "contextless" () -> ^[dynamic]String { return &current_db.string_db.string_db }


// import db
db_get_import_manager     :: proc "contextless" () -> ^ImportManager        { return current_db.import_db }
db_get_import_array       :: proc "contextless" () -> ^[dynamic]^ImportInfo { return &current_db.import_db.import_array }
db_get_import_mapa        :: proc "contextless" () -> ^map[string]int       { return &current_db.import_db.import_mapa }


db_get_import_iinfo_id    :: proc "contextless" () -> int { return len(current_db.import_db.import_array) }
db_register_import_info   :: proc (iinfo: ^ImportInfo) { append(db_get_import_array(),iinfo); db_get_import_mapa()[string_db_get_string(iinfo.sid)] = iinfo.id }

