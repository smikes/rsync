#!/usr/bin/awk -f

BEGIN {
    while ((getline i < "proto.h") > 0) old_protos = old_protos ? old_protos "\n" i : i
    close("proto.h")
    protos = "/* This file is automatically generated with \"make proto\". DO NOT EDIT */\n"
}

inheader {
    protos = protos "\n" ((inheader = /\)[ \t]*$/ ? 0 : 1) ? $0 : $0 ";")
    next
}

/^FN_(LOCAL|GLOBAL)_[^(]+\([^,()]+/ {
    local = /^FN_LOCAL/
    gsub(/^FN_(LOC|GLOB)AL_|,.*$/, "")
    sub(/^BOOL\(/, "BOOL ")
    sub(/^CHAR\(/, "char ")
    sub(/^INTEGER\(/, "int ")
    sub(/^STRING\(/, "char *")
    protos = protos "\n" $0 (local ? "(int module_id);" : "(void);")
    next
}

/^static|^extern|;/||!/^[A-Za-z][A-Za-z0-9_]* / { next }

/\(.*\)[ \t]*$/ {
    protos = protos "\n" $0 ";"
    next
}

/\(/ {
    inheader = 1
    protos = protos "\n" $0
}

END {
    if (old_protos != protos) print protos > "proto.h"
    printf "" > "proto.h-tstamp"
}
