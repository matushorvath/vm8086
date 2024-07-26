.EXPORT gen_number_times
.EXPORT gen_number

.EXPORT pow_2

.EXPORT gen_number_max
.EXPORT gen_number_count

# From libxib.a
.IMPORT print_str
.IMPORT print_num_radix

##########
gen_number_times:
.FRAME value, radix, width, prefix, times;
.loop:
    # Generate the number
    add [rb + value], 0, [rb - 1]
    add [rb + radix], 0, [rb - 2]
    add [rb + width], 0, [rb - 3]
    add [rb + prefix], 0, [rb - 4]
    arb -4
    call gen_number

    add [rb + times], -1, [rb + times]
    jnz [rb + times], .loop

    ret 5
.ENDFRAME

##########
gen_number:
.FRAME value, radix, width, prefix;
    jnz [gen_number_count], .have_line

    # Start a new line
    add .line_start, 0, [rb - 1]
    arb -1
    call print_str

    add [gen_number_max], 0, [gen_number_count]
    jz  0, .print_number

.have_line:
    # Continue an existing line
    out ','
    out ' '

.print_number:
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

.line_start:
    db  10, "    db  ", 0
.ENDFRAME

##########
pow_2:
.FRAME exponent; output
    arb -1

    add 1, 0, [rb + output]

pow_2_loop:
    jz  [rb + exponent], pow_2_done
    mul [rb + output], 2, [rb + output]
    add [rb + exponent], -1, [rb + exponent]
    jz  0, pow_2_loop

pow_2_done:
    arb 1
    ret 1
.ENDFRAME

##########
gen_number_max:
    db  0
gen_number_count:
    db  0

.EOF
