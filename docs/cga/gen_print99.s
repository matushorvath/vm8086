# Utility to generate print99.s

.IMPORT print_str

    arb stack

    add header_1, 0, [rb - 1]
    arb -1
    call print_str

    add header_2, 0, [rb - 1]
    arb -1
    call print_str

d1_loop:
    d0_loop:
        # Print the code to output a one or two digit number
        jnz [d1], two_digits

        add output_start_one_digit, 0, [rb - 1]
        arb -1
        call print_str

        jz  0, common

    two_digits:
        add output_start_two_digits, 0, [rb - 1]
        arb -1
        call print_str

        add [d1], '0', [tmp]
        out [tmp]

        add output_mid_two_digits, 0, [rb - 1]
        arb -1
        call print_str

    common:
        add [d0], '0', [tmp]
        out [tmp]

        add output_end, 0, [rb - 1]
        arb -1
        call print_str

        add [d0], 1, [d0]
        eq  [d0], 10, [tmp]
        jz  [tmp], d0_loop
        add 0, 0, [d0]

    add [d1], 1, [d1]
    eq  [d1], 10, [tmp]
    jz  [tmp], d1_loop
    add 0, 0, [d1]

    add footer, 0, [rb - 1]
    arb -1
    call print_str

    hlt

d0:
    db  0
d1:
    db  0
tmp:
    db  0

header_1:
    db  ".EXPORT print99", 10, 10, "# Generated using gen_print99.s", 10, 10, "print99:", 10, ".FRAME byte;", 10, 0
header_2:
    db  "    mul [rb + byte], 9, [rb + byte]", 10, "    add print99_table, [rb + byte], [ip + 2]", 10, "    jz  0, [0]", 10, 10, "print99_table:", 10, 0
output_start_one_digit:
    db  "    arb 0", 10, "    out '", 0
output_start_two_digits:
    db  "    out '", 0
output_mid_two_digits:
    db  "'", 10, "    out '", 0
output_end:
    db  "'", 10, "    ret 1", 10, 10, 0
footer:
    db  10, ".ENDFRAME", 10, ".EOF", 10, 0

    ds  100, 0
stack:

.EOF
