# Utility to generate mod9.s

.IMPORT print_num
.IMPORT print_str

# We need 8 bits = 256, nearest number is 261, 261/9 = 29
.SYMBOL LIMIT 29

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
    db  ".EXPORT mod9", 10, 10, "# Generated using gen_mod9.s", 10, 10, "mod9:", 10, 0
mod_line:
    db  "    db  0, 1, 2, 3, 4, 5, 6, 7, 8", 10, 0
footer:
    db  10, ".EOF", 10, 0

    ds  100, 0
stack:

.EOF
