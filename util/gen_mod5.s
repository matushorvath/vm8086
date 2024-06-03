# Utility to generate mod9.s

.IMPORT print_str
.IMPORT print_num

# We need 10 bits = 1024, nearest number is 1025, 1025/5 = 205
.SYMBOL LIMIT 205

    arb stack

    add header, 0, [rb - 1]
    arb -1
    call print_str

    add 0, 0, [number]

mod_loop:
    add mod_line, 0, [rb - 1]
    arb -1
    call print_str

    add [number], 1, [number]
    eq  [number], LIMIT + 1, [tmp]
    jz  [tmp], mod_loop

    add div_header, 0, [rb - 1]
    arb -1
    call print_str

    add 0, 0, [number]

div_loop:
    add div_line_start, 0, [rb - 1]
    arb -1
    call print_str

    add 5, 0, [index]

div_inside_loop:
    add [number], 0, [rb - 1]
    arb -1
    call print_num

    add [index], -1, [index]
    jz  [index], div_inside_done

    out ','
    out ' '

    jz  0, div_inside_loop

div_inside_done:
    out 10

    add [number], 1, [number]
    eq  [number], LIMIT + 1, [tmp]
    jz  [tmp], div_loop

    add footer, 0, [rb - 1]
    arb -1
    call print_str

    hlt

number:
    db  0
index:
    db  0
tmp:
    db  0

header:
    db  ".EXPORT div5", 10, ".EXPORT mod5", 10, 10, "# Generated using gen_mod5.s", 10, 10, "mod5:", 10, 0
mod_line:
    db  "    db  0, 1, 2, 3, 4", 10, 0
div_header:
    db  10, "div5:", 10, 0
div_line_start:
    db  "    db  ", 0
footer:
    db  10, ".EOF", 10, 0

    ds  100, 0
stack:

.EOF
