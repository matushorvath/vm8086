# Utility to generate bits.s

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

    add 32, 0, [gen_number_max]
    add 0, 0, [bit_index]

bit_loop:
    # Bit header
    add bit_header, 0, [rb - 1]
    arb -1
    call print_str

    add [bit_index], 0, [rb - 1]
    arb -1
    call print_num
    out ':'

    # Calculate number of periods and period length
    mul [bit_index], -1, [rb - 1]
    add [rb - 1], 8, [rb - 1]
    arb -1
    call pow_2
    add [rb - 3], 0, [period_index]

    add [bit_index], 0, [rb - 1]
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
    add 1, 0, [rb - 3]
    add number_prefix, 0, [rb - 4]
    add [period_length], 0, [rb - 5]
    arb -5
    call gen_number_times

    # value = !value
    eq  [value], 0, [value]

    add [period_index], -1, [period_index]
    jnz [period_index], period_loop

    # Loop to next bit
    add [bit_index], 1, [bit_index]
    eq  [bit_index], 8, [tmp]
    jz  [tmp], bit_loop

    # Finish the file
    add file_footer, 0, [rb - 1]
    arb -1
    call print_str

    hlt

##########
bit_index:
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
    db  ".EXPORT bits", 10, ".EXPORT bit_0", 10, ".EXPORT bit_1", 10, ".EXPORT bit_2", 10, ".EXPORT bit_3"
    db  10, ".EXPORT bit_4", 10, ".EXPORT bit_5", 10, ".EXPORT bit_6", 10, ".EXPORT bit_7"
    db  10, 10, "# Generated using gen_bits.s", 10, 10
    db  "bits:", 10, "    db  bit_0", 10, "    db  bit_1", 10, "    db  bit_2", 10, "    db  bit_3"
    db  10, "    db  bit_4", 10, "    db  bit_5", 10, "    db  bit_6", 10, "    db  bit_7", 0

bit_header:
    db  10, 10, "bit_", 0

number_prefix:
    db  "", 0

file_footer:
    db  10, 10, ".EOF", 10, 0

    ds  100, 0
stack:

.EOF
