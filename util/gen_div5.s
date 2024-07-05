# Utility to generate div5.s

.IMPORT print_str
.IMPORT print_num

# We need 10 bits = 1024, nearest number is 1025, 1025/5 = 205
.SYMBOL LIMIT 205

    arb stack

    add header, 0, [rb - 1]
    arb -1
    call print_str

loop:
    add line_start, 0, [rb - 1]
    arb -1
    call print_str

    add 5, 0, [index]

inside_loop:
    add [number], 0, [rb - 1]
    arb -1
    call print_num

    add [index], -1, [index]
    jz  [index], inside_done

    out ','
    out ' '

    jz  0, inside_loop

inside_done:
    out 10

    add [number], 1, [number]
    eq  [number], LIMIT + 1, [tmp]
    jz  [tmp], loop

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
    db  ".EXPORT div5", 10, 10, "# Generated using gen_div5.s", 10, 10, "div5:", 10, 0
line_start:
    db  "    db  ", 0
footer:
    db  10, ".EOF", 10, 0

    ds  100, 0
stack:

.EOF
