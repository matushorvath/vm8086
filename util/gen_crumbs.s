# Utility to generate crumbs.s

# Get value 2 from a value
# add crumbs_2, [value], [ip + 1]
# add [0], 0, [output]

# Get value N from a value
# add crumbs, [N], [ip + 1]
# add [0], [value], [ip + 1]
# add [0], 0, [output]

.IMPORT print_str
.IMPORT print_num
.IMPORT print_num_radix

##########
    arb stack

    add file_header, 0, [rb - 1]
    arb -1
    call print_str

    add 0, 0, [crumb_index]

crumb_loop:
    # Crumb header
    add crumb_header, 0, [rb - 1]
    arb -1
    call print_str

    add [crumb_index], 0, [rb - 1]
    arb -1
    call print_num
    out ':'

    # Calculate number of periods and period length
    mul [crumb_index], -2, [rb - 1]
    add [rb - 1], 8, [rb - 1]
    arb -1
    call pow_2
    add [rb - 3], 0, [period_index]

    mul [crumb_index], 2, [rb - 1]
    arb -1
    call pow_2
    add [rb - 3], 0, [period_length]

    # Intialize the number loop
    add 0, 0, [value]
    add 0, 0, [gen_number_count]

period_loop:
    # Generate one period of numbers
    add [value], 0, [rb - 1]
    add 2, 0, [rb - 2]
    add 2, 0, [rb - 3]
    add number_prefix, 0, [rb - 4]
    add [period_length], 0, [rb - 5]
    arb -5
    call gen_number_times

    # value = (value + 1) mod 4
    add [value], 1, [value]
    eq  [value], 4, [tmp]
    mul [tmp], -4, [tmp]
    add [value], [tmp], [value]

    add [period_index], -1, [period_index]
    jnz [period_index], period_loop

    # Loop to next crumb
    add [crumb_index], 1, [crumb_index]
    eq  [crumb_index], 4, [tmp]
    jz  [tmp], crumb_loop

    # Finish the file
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
crumb_index:
    db  0
period_index:
    db  0
period_length:
    db  0
value:
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

crumb_header:
    db  10, 10, "crumb_", 0

number_prefix:
    db  "0b", 0

file_footer:
    db  10, 10, ".EOF", 10, 0

    ds  100, 0
stack:

.EOF
