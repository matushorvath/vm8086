# Utility to generate shl.s

.IMPORT print_num_radix
.IMPORT print_str

    arb stack

    add header, 0, [rb - 1]
    arb -1
    call print_str

add 0, 0, [bits + 7]
b7_loop:
    add 0, 0, [bits + 6]
    b6_loop:
        add 0, 0, [bits + 5]
        b5_loop:
            add 0, 0, [bits + 4]
            b4_loop:
                add 0, 0, [bits + 3]
                b3_loop:
                    add 0, 0, [bits + 2]
                    b2_loop:
                        add 0, 0, [bits + 1]
                        b1_loop:
                            add 0, 0, [bits + 0]
                            b0_loop:
                                # Print line start
                                add line_start, 0, [rb - 1]
                                arb -1
                                call print_str

                                add 0, 0, [cnt]
                                cnt_loop:
                                    add 0, 0, [res]

                                    mul [cnt], -1, [tmp]
                                    add 8, [tmp], [bit]

                                    # Print the separator, unless this is the first number
                                    jz  [cnt], bit_loop
                                    add separator, 0, [rb - 1]
                                    arb -1
                                    call print_str

                                    bit_loop:
                                        add [bit], -1, [bit]

                                        # Calculate the shifted number
                                        mul [res], 2, [res]
                                        add bits, [bit], [ip + 1]
                                        add [0], [res], [res]

                                        jnz [bit], bit_loop

                                    # Shift the number left
                                    add power_of_two, [cnt], [ip + 1]
                                    mul [0], [res], [res]

                                    # Print the shifted number
                                    add [res], 0, [rb - 1]
                                    add 2, 0, [rb - 2]
                                    add 8, 0, [rb - 3]
                                    arb -3
                                    call print_num_radix

                                    add [cnt], 1, [cnt]
                                    eq  [cnt], 8, [tmp]
                                    jz  [tmp], cnt_loop

                                # Print line end
                                add line_end, 0, [rb - 1]
                                arb -1
                                call print_str

                                add [bits + 0], 1, [bits + 0]
                                eq  [bits + 0], 2, [tmp]
                                jz  [tmp], b0_loop

                            add [bits + 1], 1, [bits + 1]
                            eq  [bits + 1], 2, [tmp]
                            jz  [tmp], b1_loop

                        add [bits + 2], 1, [bits + 2]
                        eq  [bits + 2], 2, [tmp]
                        jz  [tmp], b2_loop

                    add [bits + 3], 1, [bits + 3]
                    eq  [bits + 3], 2, [tmp]
                    jz  [tmp], b3_loop

                add [bits + 4], 1, [bits + 4]
                eq  [bits + 4], 2, [tmp]
                jz  [tmp], b4_loop

            add [bits + 5], 1, [bits + 5]
            eq  [bits + 5], 2, [tmp]
            jz  [tmp], b5_loop

        add [bits + 6], 1, [bits + 6]
        eq  [bits + 6], 2, [tmp]
        jz  [tmp], b6_loop

    add [bits + 7], 1, [bits + 7]
    eq  [bits + 7], 2, [tmp]
    jz  [tmp], b7_loop

    add footer, 0, [rb - 1]
    arb -1
    call print_str

    hlt

new_line:
    db  1
bits:
    ds  8, 0
cnt:
    db  0
bit:
    db  0
res:
    db  0
tmp:
    db  0

header:
    db  ".EXPORT shl", 10, 10, "# Generated using gen_shl.s", 10, 10, "shl:", 10, 0
line_start:
    db  "    db  0b", 0
separator:
    db  ", 0b", 0
line_end:
    db  10, 0
footer:
    db  10, ".EOF", 10, 0
power_of_two:
    db  0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80

    ds  100, 0
stack:

.EOF
