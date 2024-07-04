# Utility to generate crumbs.s

# Get crumb 2 from a value
# add crumbs_2, [value], [ip + 1]
# add [0], 0, [output]

# Get crumb N from a value
# add crumbs, [N], [ip + 1]
# add [0], [value], [ip + 1]
# add [0], 0, [output]

.IMPORT print_str
.IMPORT print_num_radix

##########
    arb stack

    add file_header, 0, [rb - 1]
    arb -1
    call print_str


    # Crumb 0
    add crumb_0_header, 0, [rb - 1]
    arb -1
    call print_str

    add 0x100, 0, [index]
    add 0, 0, [crumb]
    add 0, 0, [gen_number_count]

crumb_0_loop:
    add [crumb], 0, [rb - 1]
    add 2, 0, [rb - 2]
    add 2, 0, [rb - 3]
    add number_prefix, 0, [rb - 4]
    arb -4
    call gen_number

    # crumb = (crumb + 1) mod 4
    add [crumb], 1, [crumb]
    eq  [crumb], 4, [tmp]
    mul [tmp], -4, [tmp]
    add [crumb], [tmp], [crumb]

    add [index], -1, [index]
    jnz [index], crumb_0_loop


    # Crumb 1
    add crumb_1_header, 0, [rb - 1]
    arb -1
    call print_str

    add 0x40, 0, [index]
    add 0, 0, [crumb]
    add 0, 0, [gen_number_count]

crumb_1_loop:
    add [crumb], 0, [rb - 1]
    add 2, 0, [rb - 2]
    add 2, 0, [rb - 3]
    add number_prefix, 0, [rb - 4]
    add 4, 0, [rb - 5]
    arb -5
    call gen_number_times

    # crumb = (crumb + 1) mod 4
    add [crumb], 1, [crumb]
    eq  [crumb], 4, [tmp]
    mul [tmp], -4, [tmp]
    add [crumb], [tmp], [crumb]

    add [index], -1, [index]
    jnz [index], crumb_1_loop


    # Crumb 2
    add crumb_2_header, 0, [rb - 1]
    arb -1
    call print_str

    add 0x10, 0, [index]
    add 0, 0, [crumb]
    add 0, 0, [gen_number_count]

crumb_2_loop:
    add [crumb], 0, [rb - 1]
    add 2, 0, [rb - 2]
    add 2, 0, [rb - 3]
    add number_prefix, 0, [rb - 4]
    add 16, 0, [rb - 5]
    arb -5
    call gen_number_times

    # crumb = (crumb + 1) mod 4
    add [crumb], 1, [crumb]
    eq  [crumb], 4, [tmp]
    mul [tmp], -4, [tmp]
    add [crumb], [tmp], [crumb]

    add [index], -1, [index]
    jnz [index], crumb_2_loop


    # Crumb 3
    add crumb_3_header, 0, [rb - 1]
    arb -1
    call print_str

    add 0x04, 0, [index]
    add 0, 0, [crumb]
    add 0, 0, [gen_number_count]

crumb_3_loop:
    add [crumb], 0, [rb - 1]
    add 2, 0, [rb - 2]
    add 2, 0, [rb - 3]
    add number_prefix, 0, [rb - 4]
    add 64, 0, [rb - 5]
    arb -5
    call gen_number_times

    # crumb = (crumb + 1) mod 4
    add [crumb], 1, [crumb]
    eq  [crumb], 4, [tmp]
    mul [tmp], -4, [tmp]
    add [crumb], [tmp], [crumb]

    add [index], -1, [index]
    jnz [index], crumb_3_loop


    add file_footer, 0, [rb - 1]
    arb -1
    call print_str

    hlt

##########
gen_number_times:
.FRAME value, radix, width, prefix, times;
gen_number_times_loop:
    # Generate the number
    add [rb + value], 0, [rb - 1]
    add [rb + radix], 0, [rb - 2]
    add [rb + width], 0, [rb - 3]
    add [rb + prefix], 0, [rb - 4]
    arb -4
    call gen_number

    add [rb + times], -1, [rb + times]
    jnz [rb + times], gen_number_times_loop

    ret 5
.ENDFRAME

##########
gen_number:
.FRAME value, radix, width, prefix;
    jnz [gen_number_count], gen_number_have_line

    # Start a new line
    add gen_number_line_start, 0, [rb - 1]
    arb -1
    call print_str

    add [gen_number_max], 0, [gen_number_count]
    jz  0, gen_number_gen_number

gen_number_have_line:
    # Continue an existing line
    out ','
    out ' '

gen_number_gen_number:
    # Print the number
    add [rb + prefix], 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    add [rb + radix], 0, [rb - 2]
    add [rb + width], 0, [rb - 3]
    arb -3
    call print_num_radix

    add [gen_number_count], -1, [gen_number_count]

    ret 4

gen_number_line_start:
    db  10, "    db  ", 0
.ENDFRAME

##########
index:
    db  0
crumb:
    db  0
tmp:
    db  0

gen_number_max:
    db  16
gen_number_count:
    db  0

file_header:
    db  ".EXPORT crumbs", 10, ".EXPORT crumb_0", 10, ".EXPORT crumb_1", 10, ".EXPORT crumb_2", 10, ".EXPORT crumb_3"
    db  10, 10, "# Generated using gen_crumbs.s", 10, 10
    db  "crumbs:", 10, "    db  crumb_0", 10, "    db  crumb_1", 10, "    db  crumb_2", 10, "    db  crumb_3", 0

crumb_0_header:
    db  10, 10, "crumb_0:", 0
crumb_1_header:
    db  10, 10, "crumb_1:", 0
crumb_2_header:
    db  10, 10, "crumb_2:", 0
crumb_3_header:
    db  10, 10, "crumb_3:", 0

number_prefix:
    db  "0b", 0

file_footer:
    db  10, 10, ".EOF", 10, 0

    ds  100, 0
stack:

.EOF

crumbs:
    crumb_0
    crumb_1
    crumb_2
    crumb_3

crumb_0:
    0b00, 0b01, 0b10, 0b11, 0b00, 0b01, 0b10, 0b11, ...

crumb_1:
    0b00, 0b00, 0b00, 0b00, 0b01, 0b01, 0b01, 0b01, ...

crumb_2:
    0b00, 0b00, 0b00, 0b00, 0b00, 0b00, 0b00, 0b00, ...

crumb_3:
    0b00, 0b00, 0b00, 0b00, 0b00, 0b00, 0b00, 0b00, ...







b7_loop:
    b6_loop:
        b5_loop:
            b4_loop:
                b3_loop:
                    b2_loop:
                        b1_loop:
                            b0_loop:
                                # Print line start
                                add line_start, 0, [rb - 1]
                                arb -1
                                call print_str

                                # Print the bits like '0, 0, 0, 0, 0, 0, 0, 0'
                                add [b0], 0, [rb - 1]
                                arb -1
                                call print_num

                                out ','
                                out ' '

                                add [b1], 0, [rb - 1]
                                arb -1
                                call print_num

                                out ','
                                out ' '

                                add [b2], 0, [rb - 1]
                                arb -1
                                call print_num

                                out ','
                                out ' '

                                add [b3], 0, [rb - 1]
                                arb -1
                                call print_num

                                out ','
                                out ' '

                                add [b4], 0, [rb - 1]
                                arb -1
                                call print_num

                                out ','
                                out ' '

                                add [b5], 0, [rb - 1]
                                arb -1
                                call print_num

                                out ','
                                out ' '

                                add [b6], 0, [rb - 1]
                                arb -1
                                call print_num

                                out ','
                                out ' '

                                add [b7], 0, [rb - 1]
                                arb -1
                                call print_num

                                # Print line end
                                add line_end, 0, [rb - 1]
                                arb -1
                                call print_str

                                # Calculate the number
                                add [b7], 0, [number]
                                mul [number], 2, [number]
                                add [b6], [number], [number]
                                mul [number], 2, [number]
                                add [b5], [number], [number]
                                mul [number], 2, [number]
                                add [b4], [number], [number]
                                mul [number], 2, [number]
                                add [b3], [number], [number]
                                mul [number], 2, [number]
                                add [b2], [number], [number]
                                mul [number], 2, [number]
                                add [b1], [number], [number]
                                mul [number], 2, [number]
                                add [b0], [number], [number]

                                # Pad with zero if needed
                                lt  [number], 0x10, [tmp]
                                jz  [tmp], skip_padding

                                out '0'

                            skip_padding:
                                # Print the number
                                add [number], 0, [rb - 1]
                                add 16, 0, [rb - 2]
                                add 0, 0, [rb - 3]
                                arb -3
                                call print_num_radix

                                out 10

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

number:
    db  0
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
    db  ".EXPORT bits", 10, 10, "# Generated using gen_bits.s", 10, 10, "bits:", 10, 0
line_start:
    db  "    db  ", 0
line_end:
    db  "          # 0x", 0
.EOF
