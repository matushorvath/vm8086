.EXPORT init_memory

# From binary.s
.IMPORT binary

# TODO validate load address, size; see init_state for example

##########
init_memory:
.FRAME src, tgt, cnt
    arb -3

    # Initialize memory space for the 6502.

    # Calculate the beginning address of the source (binary)
    add binary, BINARY_DATA, [rb + src]

    # Calculate the beginning address of the target (MEM + [load])
    add MEM, [binary + 1], [rb + tgt]

    # Number of bytes to copy
    add [binary + 2], 0, [rb + cnt]

    # Move the image from src to tgt (iterating in reverse direction)
init_memory_loop:
    jz  [rb + cnt], init_memory_done
    add [rb + cnt], -1, [rb + cnt]

    # Copy one byte
    add [rb + src], [rb + cnt], [ip + 5]
    add [rb + tgt], [rb + cnt], [ip + 3]
    add [0], 0, [0]

    # Zero the source byte
    add [rb + src], [rb + cnt], [ip + 3]
    add 0, 0, [0]

    jz  0, init_memory_loop

init_memory_done:
    arb 3
    ret 0
.ENDFRAME

.EOF
