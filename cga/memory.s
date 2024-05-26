.EXPORT write_memory_b8000
.EXPORT read_memory_bc000
.EXPORT write_memory_bc000

# From state.o
.IMPORT mem

# From libxib.a
# TODO remove
.IMPORT print_num_radix
.IMPORT print_str

##########
.FRAME addr, value; write_through, tmp
    # Function with multiple entry points

write_memory_bc000:
    arb -2
    add [rb + addr], -0xbc000, [rb + addr]
    jz  0, write_memory

write_memory_b8000:
    arb -2
    add [rb + addr], -0xb8000, [rb + addr]

write_memory:
    # We will store the value in main memory, region 0xb8000
    add 0, 0, [rb + write_through]

    add [mem], [rb + addr], [rb + tmp]
    add [rb + tmp], 0xb8000, [ip + 3]
    add [rb + value], 0, [0]

    # Log the memory access
    add write_memory_message, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + addr], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 4, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ' '

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    arb 2
    ret 2

write_memory_message:
    db  "CGA WR MEM: ", 0
.ENDFRAME

##########
read_memory_bc000:
.FRAME addr; value, read_through        # returns value, read_through
    arb -2

    # This region is an alias for region 0xb8000, read the value from there instead
    add 0, 0, [rb + read_through]
    add [rb + addr], -0x4000, [rb + addr]

    add [mem], [rb + addr], [ip + 1]
    add [0], 0, [rb + value]

    arb 2
    ret 1
.ENDFRAME

.EOF
