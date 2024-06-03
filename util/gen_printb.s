# Utility to generate printb.s

.IMPORT print_str

    arb stack

    add header_1, 0, [rb - 1]
    arb -1
    call print_str

    add header_2, 0, [rb - 1]
    arb -1
    call print_str

d2_loop:
    d1_loop:
        d0_loop:
            # Print the code to output the number
            add output_first_digit, 0, [rb - 1]
            arb -1
            call print_str

            add [d1], [d2], [tmp]
            jz  [tmp], one_digit
            jz  [d2], two_digits

            add [d2], '0', [tmp]
            out [tmp]

            add output_mid_digit, 0, [rb - 1]
            arb -1
            call print_str

        two_digits:
            add [d1], '0', [tmp]
            out [tmp]

            add output_mid_digit, 0, [rb - 1]
            arb -1
            call print_str

        one_digit:
            add [d0], '0', [tmp]
            out [tmp]

            add output_ret, 0, [rb - 1]
            arb -1
            call print_str

            jnz  [d2], end_line

            add output_nop, 0, [rb - 1]
            arb -1
            call print_str

            jnz  [d1], end_line

            add output_nop, 0, [rb - 1]
            arb -1
            call print_str

        end_line:
            out 10
            out 10

            eq  [d2], 2, [done]
            eq  [d1], 5, [tmp]
            add [done], [tmp], [done]
            eq  [d0], 5, [tmp]
            add [done], [tmp], [done]
            eq  [done], 3, [tmp]
            jnz [tmp], end

            add [d0], 1, [d0]
            eq  [d0], 10, [tmp]
            jz  [tmp], d0_loop
            add 0, 0, [d0]

        add [d1], 1, [d1]
        eq  [d1], 10, [tmp]
        jz  [tmp], d1_loop
        add 0, 0, [d1]

    add [d2], 1, [d2]
    eq  [d2], 10, [tmp]
    jz  [tmp], d2_loop

end:
    add footer, 0, [rb - 1]
    arb -1
    call print_str

    hlt

d0:
    db  0
d1:
    db  0
d2:
    db  0
done:
    db  0
tmp:
    db  0

header_1:
    db  ".EXPORT printb", 10, 10, "# Generated using gen_printb.s", 10, 10, "printb:", 10, ".FRAME byte;", 10, 0
header_2:
    db  "    mul [rb + byte], 11, [rb + byte]", 10, "    add printb_table, [rb + byte], [rb + byte]", 10, "    jz  0, [rb + byte]", 10, 10, "printb_table:", 10, 0
output_first_digit:
    db  "    out '", 0
output_mid_digit:
    db  "'", 10, "    out '", 0
output_ret:
    db  "'", 10, "    ret 1", 0
output_nop:
    db  10, "    db  0, 0", 0
footer:
    db  ".ENDFRAME", 10, 10, ".EOF", 10, 0

    ds  100, 0
stack:

.EOF
