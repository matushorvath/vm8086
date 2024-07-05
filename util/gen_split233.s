# Utility to generate split233.s

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

    add 8, 0, [gen_number_max]
    add 0, 0, [part_index]

part_loop:
    # Part header
    add part_header, 0, [rb - 1]
    arb -1
    call print_str

    add [part_index], 0, [rb - 1]
    arb -1
    call print_num
    out ':'

    # Parts 0 and 1 are 3 bits, part 2 is 2 bits
    lt  [part_index], 2, [part_bits]
    add [part_bits], 2, [part_bits]

    # Calculate number of periods and period length
    mul [part_index], -3, [rb - 1]
    add [rb - 1], 8, [rb - 1]
    arb -1
    call pow_2
    add [rb - 3], 0, [period_index]

    mul [part_index], 3, [rb - 1]
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
    add [part_bits], 0, [rb - 3]
    add number_prefix, 0, [rb - 4]
    add [period_length], 0, [rb - 5]
    arb -5
    call gen_number_times

    # value = (value + 1) mod 8
    add [value], 1, [value]
    eq  [value], 8, [tmp]
    mul [tmp], -8, [tmp]
    add [value], [tmp], [value]

    add [period_index], -1, [period_index]
    jnz [period_index], period_loop

    # Loop to next part
    add [part_index], 1, [part_index]
    eq  [part_index], 3, [tmp]
    jz  [tmp], part_loop

    # Finish the file
    add file_footer, 0, [rb - 1]
    arb -1
    call print_str

    hlt

##########
part_bits:
    db  0
part_index:
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
    db  ".EXPORT split233", 10, ".EXPORT split233_0", 10, ".EXPORT split233_1", 10, ".EXPORT split233_2", 10, 10
    db  "# Generated using gen_split233.s", 10, 10
    db  "split233:", 10, "    db  split233_0", 10, "    db  split233_1", 10, "    db  split233_2", 0

part_header:
    db  10, 10, "split233_", 0

number_prefix:
    db  "0b", 0

file_footer:
    db  10, 10, ".EOF", 10, 0

    ds  100, 0
stack:

.EOF
