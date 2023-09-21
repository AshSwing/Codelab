add_rules("mode.debug", "mode.release")
set_languages("c17")

target("build")
    set_kind("static")
    set_basename("leptjson")
    add_files("src/*.c")

target("test")
    set_kind("binary")
    set_basename("leptjson_test")
    add_deps("build")
    add_files("test/*.c")

