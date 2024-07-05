# Utility to generate shl.s

# From generator.s
.IMPORT gen_number
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

    add 8, 0, [gen_number_max]
    add 0, 0, [shift_index]

shift_loop:
    # Shift header
    add shift_header, 0, [rb - 1]
    arb -1
    call print_str

    add [shift_index], 0, [rb - 1]
    arb -1
    call print_num
    out ':'

    # Calculate number of periods and period length
    add [shift_index], 0, [rb - 1]
    arb -1
    call pow_2
    add [rb - 3], 0, [period_index]
    add [rb - 3], 0, [increment]

    mul [shift_index], -1, [rb - 1]
    add [rb - 1], 8, [rb - 1]
    arb -1
    call pow_2
    add [rb - 3], 0, [period_length]

    # Intialize the period loop
    add 0, 0, [gen_number_count]

period_loop:
    # Generate one period of numbers
    add [period_length], 0, [number_index]
    add 0, 0, [value]

number_loop:
    # Generate one number
    add [value], 0, [rb - 1]
    add 2, 0, [rb - 2]
    add 8, 0, [rb - 3]
    add number_prefix, 0, [rb - 4]
    arb -4
    call gen_number

    # Next number
    add  [value], [increment], [value]

    add [number_index], -1, [number_index]
    jnz [number_index], number_loop

    # Next period
    add [period_index], -1, [period_index]
    jnz [period_index], period_loop

    # Loop to next shift
    add [shift_index], 1, [shift_index]
    eq  [shift_index], 8, [tmp]
    jz  [tmp], shift_loop

    # Finish the file
    add file_footer, 0, [rb - 1]
    arb -1
    call print_str

    hlt

##########
shift_index:
    db  0
period_index:
    db  0
period_length:
    db  0
number_index:
    db  0
increment:
    db  0
value:
    db  0
tmp:
    db  0

file_header:
    db  ".EXPORT shl", 10, ".EXPORT shl_0", 10, ".EXPORT shl_1", 10, ".EXPORT shl_2", 10, ".EXPORT shl_3"
    db  10, ".EXPORT shl_4", 10, ".EXPORT shl_5", 10, ".EXPORT shl_6", 10, ".EXPORT shl_7"
    db  10, 10, "# Generated using gen_shl.s", 10, 10
    db  "shl:", 10, "    db  shl_0", 10, "    db  shl_1", 10, "    db  shl_2", 10, "    db  shl_3"
    db  10, "    db  shl_4", 10, "    db  shl_5", 10, "    db  shl_6", 10, "    db  shl_7", 0

shift_header:
    db  10, 10, "shl_", 0

number_prefix:
    db  "0b", 0

file_footer:
    db  10, 10, ".EOF", 10, 0

    ds  100, 0
stack:

.EOF
