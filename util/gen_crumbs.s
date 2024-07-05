# Utility to generate crumbs.s

# From generator.s
.IMPORT gen_number_times
.IMPORT pow_2

.IMPORT gen_number_max
.IMPORT gen_number_count

# From libxib.a
.IMPORT print_str
.IMPORT print_num

##########
    arb stack

    add file_header, 0, [rb - 1]
    arb -1
    call print_str

    add 16, 0, [gen_number_max]
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

    # Intialize the period loop
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
