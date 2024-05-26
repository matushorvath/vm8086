# Utility to generate split233.s

.IMPORT print_num_radix
.IMPORT print_str

    arb stack

    add header, 0, [rb - 1]
    arb -1
    call print_str

b7_loop:
    b6_loop:
        b5_loop:
            b4_loop:
                b3_loop:
                    # Print line start
                    add line_start, 0, [rb - 1]
                    arb -1
                    call print_str

                    add 1, 0, [new_line]

                    b2_loop:
                        b1_loop:
                            b0_loop:
                                # Skip separator before the first number
                                jnz [new_line], skip_separator

                                # Print separator
                                add separator, 0, [rb - 1]
                                arb -1
                                call print_str

                            skip_separator:
                                add 0, 0, [new_line]

                                # Calculate the lower 3 bits and print them
                                add [b2], 0, [tmp]
                                mul [tmp], 2, [tmp]
                                add [b1], [tmp], [tmp]
                                mul [tmp], 2, [tmp]
                                add [b0], [tmp], [rb - 1]                       # [tmp] -> param0

                                add 16, 0, [rb - 2]
                                add 0, 0, [rb - 3]
                                arb -3
                                call print_num_radix

                                # Print separator
                                add separator, 0, [rb - 1]
                                arb -1
                                call print_str

                                # Calculate the middle 3 bits and print them
                                add [b5], 0, [tmp]
                                mul [tmp], 2, [tmp]
                                add [b4], [tmp], [tmp]
                                mul [tmp], 2, [tmp]
                                add [b3], [tmp], [rb - 1]                       # [tmp] -> param0

                                add 16, 0, [rb - 2]
                                add 0, 0, [rb - 3]
                                arb -3
                                call print_num_radix

                                # Print separator
                                add separator, 0, [rb - 1]
                                arb -1
                                call print_str

                                # Calculate the upper 2 bits and print them
                                add [b7], 0, [tmp]
                                mul [tmp], 2, [tmp]
                                add [b6], [tmp], [rb - 1]                       # [tmp] -> param0

                                add 16, 0, [rb - 2]
                                add 0, 0, [rb - 3]
                                arb -3
                                call print_num_radix

                                add [b0], 1, [b0]
                                eq  [b0], 2, [tmp]
                                jz  [tmp], b0_loop
                                add 0, 0, [b0]

                            add [b1], 1, [b1]
                            eq  [b1], 2, [tmp]
                            jz  [tmp], b1_loop
                            add 0, 0, [b1]

                        add [b2], 1, [b2]
                        eq  [b2], 2, [tmp]
                        jz  [tmp], b2_loop
                        add 0, 0, [b2]

                        # Print line end
                        add line_end, 0, [rb - 1]
                        arb -1
                        call print_str

                    add [b3], 1, [b3]
                    eq  [b3], 2, [tmp]
                    jz  [tmp], b3_loop
                    add 0, 0, [b3]

                add [b4], 1, [b4]
                eq  [b4], 2, [tmp]
                jz  [tmp], b4_loop
                add 0, 0, [b4]

            add [b5], 1, [b5]
            eq  [b5], 2, [tmp]
            jz  [tmp], b5_loop
            add 0, 0, [b5]

        add [b6], 1, [b6]
        eq  [b6], 2, [tmp]
        jz  [tmp], b6_loop
        add 0, 0, [b6]

    add [b7], 1, [b7]
    eq  [b7], 2, [tmp]
    jz  [tmp], b7_loop
    add 0, 0, [b7]

    add footer, 0, [rb - 1]
    arb -1
    call print_str

    hlt

new_line:
    db  1
b0:
    db  0
b1:
    db  0
b2:
    db  0
b3:
    db  0
b4:
    db  0
b5:
    db  0
b6:
    db  0
b7:
    db  0
tmp:
    db  0

header:
    db  ".EXPORT split233", 10, 10, "# Generated using gen_split233.s", 10, 10, "split233:", 10, 0
line_start:
    db  "    db  0x", 0
separator:
    db  ", 0x", 0
line_end:
    db  10, 0
footer:
    db  10, ".EOF", 10, 0

    ds  100, 0
stack:

.EOF
