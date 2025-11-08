package String

import strings  "core:strings"


to_string         :: proc{to_string_object,to_string_builder}

to_string_object  :: proc(obj: ^NuoString) -> string { return to_string(obj.data) }
to_string_builder :: strings.to_string

