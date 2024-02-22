.EXPORT init_memory

# From binary.s
.IMPORT binary

# From libxib.a
.IMPORT print_num

##########
init_memory:
.FRAME tmp, src, tgt, cnt
    arb -4

# Initialize the memory space for the 6502.

    # TODO delme
    add binary, 0, [rb - 1]
    arb -1
    call print_num
    out 10

    # Calculate the start address of the source (binary)
    add binary, BINARY_DATA, [rb + src]

    # TODO delme
    add [rb + src], 0, [rb - 1]
    arb -1
    call print_num
    out 10

    # Calculate the start address of the target (MEM + [load])
    add MEM, [binary + 1], [rb + tgt]

    # TODO delme
    add [rb + tgt], 0, [rb - 1]
    arb -1
    call print_num
    out 10

    # Number of bytes to copy
    add [binary + 2], 0, [rb + cnt]

    # TODO delme
    add [rb + cnt], 0, [rb - 1]
    arb -1
    call print_num
    out 10

    # Move the image from src to tgt (iterating in reverse direction)
init_memory_loop:
    jz  [rb + cnt], init_memory_done
    add [rb + cnt], -1, [rb + cnt]

    # Copy one byte
    add [rb + src], [rb + cnt], [ip + 5]
    add [rb + tgt], [rb + cnt], [ip + 3]
    add [0], 0, [0]

    jz  0, init_memory_loop

init_memory_done:

    arb 4
    ret 0
.ENDFRAME

.EOF
