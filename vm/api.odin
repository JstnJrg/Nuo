package VM

import variant "nuo:variant"

// InterpretResult :: InterpretResult

VariantType       :: _VariantType
NuoContext        :: Context

nuo_compile       :: compile
nuo_free_compiler :: nuo_deinit_compiler

// nuo_init_compiler_ctx  :: nuo_init_compiler_ctx
nuo_free_compiler_data   :: nuo_free_all_compiler

nuo_create_ictx          :: variant.register_import
nuo_Value                :: variant.Value

nuo_setup_and_interpret  :: setup_and_interpret
nuo_get_value_by_context :: import_db_get_value

nuo_push                 :: push
nuo_pop                  :: pop
nuo_peek                 :: peek
nuo_call                 :: setup_and_interpret
nuo_context_get          :: variant.import_db_get_value
nuo_variant_val          :: variant.VARIANT_VAL

nuo_class_db_register_class_method  :: class_db_register_class_method
nuo_class_db_register_class         :: class_db_register_class
nuo_class_db_set_sid                :: variant.class_db_set_sid

// nuo_class_db_register_class_creator :: variant.class_db_register_class_creator

nuo_class_register_property         :: variant.class_register_property
nuo_class_register_static_property  :: variant.class_register_static_property
nuo_class_db_default_csetter        :: variant.class_db_default_csetter
nuo_class_db_default_cgetter        :: variant.class_db_default_cgetter


nuo_register_import                 :: variant.register_import
nuo_import_db_register_setter       :: variant.import_db_register_setter
nuo_import_db_register_getter       :: variant.import_db_register_getter

nuo_string_db_register_string       :: string_db_register_string

NUO_CLASS_B_METHOD                  :: variant.CLASS_B_METHOD 
NUO_IMPORT_B_VALUE                  :: variant.IMPORT_B_VALUE






