# Utility to generate shr.s

# From generator.s
.IMPORT gen_number_times
.IMPORT pow_2

.IMPORT gen_number_max
.IMPORT gen_number_count

# From libxib.a
.IMPORT print_str
.IMPORT print_num

# TODO rename shr_ng

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
    mul [shift_index], -1, [rb - 1]
    add [rb - 1], 8, [rb - 1]
    arb -1
    call pow_2
    add [rb - 3], 0, [period_index]

    add [shift_index], 0, [rb - 1]
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
    add 8, 0, [rb - 3]
    add number_prefix, 0, [rb - 4]
    add [period_length], 0, [rb - 5]
    arb -5
    call gen_number_times

    # Next value
    add  [value], 1, [value]

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
value:
    db  0
tmp:
    db  0

file_header:
    db  ".EXPORT shr_ng", 10, ".EXPORT shr_0", 10, ".EXPORT shr_1", 10, ".EXPORT shr_2", 10, ".EXPORT shr_3"
    db  10, ".EXPORT shr_4", 10, ".EXPORT shr_5", 10, ".EXPORT shr_6", 10, ".EXPORT shr_7"
    db  10, 10, "# Generated using gen_shr.s", 10, 10
    db  "shr_ng:", 10, "    db  shr_0", 10, "    db  shr_1", 10, "    db  shr_2", 10, "    db  shr_3"
    db  10, "    db  shr_4", 10, "    db  shr_5", 10, "    db  shr_6", 10, "    db  shr_7", 0

shift_header:
    db  10, 10, "shr_", 0

number_prefix:
    db  "0b", 0

file_footer:
    db  10, 10, ".EOF", 10, 0

    ds  100, 0
stack:

.EOF
