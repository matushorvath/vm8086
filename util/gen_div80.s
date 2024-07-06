# Utility to generate div80.s

# From generator.s
.IMPORT gen_number_times
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

    # Intialize the period loop
    add 16, 0, [gen_number_max]
    add 0, 0, [gen_number_count]

    # The highest dividend we need is 8000, 8000/80 = 100
    add 100, 0, [period_count]
    add 0, 0, [value]

period_loop:
    # Generate one period of numbers
    add [value], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 3, 0, [rb - 3]
    add number_prefix, 0, [rb - 4]
    add 80, 0, [rb - 5]
    arb -5
    call gen_number_times

    # Next value
    add  [value], 1, [value]

    add [period_count], -1, [period_count]
    jnz [period_count], period_loop

    # Finish the file
    add file_footer, 0, [rb - 1]
    arb -1
    call print_str

    hlt

##########
period_count:
    db  0
value:
    db  0

file_header:
    db  ".EXPORT div80", 10, 10, "# Generated using gen_div80.s", 10, 10, "div80:", 0

number_prefix:
    db  "", 0

file_footer:
    db  10, 10, ".EOF", 10, 0

    ds  100, 0
stack:

.EOF
