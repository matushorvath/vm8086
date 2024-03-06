.EXPORT init_memory
.EXPORT read
.EXPORT write
.EXPORT push
.EXPORT pull

# From binary.s
.IMPORT binary

# From error.s
.IMPORT report_error

# From state.s
.IMPORT reg_sp

# From util.s
.IMPORT check_16bit
.IMPORT mod_8bit

# Where IO is mapped in 6502 memory
.SYMBOL IOPORT                          65520       # 0xfff0;

##########
init_memory:
.FRAME tmp, src, tgt, cnt
    arb -4

    # Initialize memory space for the 6502.

    # Validate the load address is a valid 16-bit number
    add [binary + 1], 0, [rb - 1]
    arb -1
    call check_16bit

    # Validate the image will fit to 16-bits when loaded there
    add [binary + 1], [binary + 4], [rb + tgt]
    lt  65536, [rb + tgt], [rb + tmp]
    jz  [rb + tmp], init_memory_load_address_ok

    add image_too_big_error, 0, [rb - 1]
    arb -1
    call report_error

init_memory_load_address_ok:
    # The 6502 memory space will start where the binary starts now
    add binary + 5, 0, [mem]

    # Do we need to move the binary to a different load address?
    jz  [binary + 1], init_memory_done

    # Yes, calculate beginning address of the source (binary),
    add binary + 5, 0, [rb + src]

    # Calculate the beginning address of the target ([mem] + [load])
    add [mem], [binary + 1], [rb + tgt]

    # Number of bytes to copy
    add [binary + 4], 0, [rb + cnt]

init_memory_loop:
    # Move the image from src to tgt (iterating in reverse direction)
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
    arb 4
    ret 0
.ENDFRAME

##########
read:
.FRAME addr; value, tmp                 # returns value
    arb -2

    # Is this IO?
    eq  [rb + addr], IOPORT, [rb + tmp]
    jz  [rb + tmp], read_mem

    # Yes, do we need to simulate a 0x0d?
    jnz [read_io_simulate_0d_flag], read_io_simulate_0d

read_io_next_char:
    # No, regular input
    in  [rb + value]

    # Drop any 0x0d characters, we simulate those after a 0x0a automatically
    eq  [rb + value], 13, [rb + tmp]
    jnz [rb + tmp], read_io_next_char

    # If 0x0a, next input char should be 0x0d
    eq  [rb + value], 10, [read_io_simulate_0d_flag]

    jz  0, read_done

read_io_simulate_0d:
    # If the last character we got was 0x0a, simulate a following 0x0d
    add 0, 0, [read_io_simulate_0d_flag]
    add 13, 0, [rb + value]

    jz  0, read_done

read_mem:
    # No, regular memory read
    add [mem], [rb + addr], [ip + 1]
    add [0], 0, [rb + value]

read_done:
    arb 2
    ret 1

read_io_simulate_0d_flag:
    db  0
.ENDFRAME

##########
write:
.FRAME addr, value; tmp
    arb -1

    # Is this IO?
    eq  [rb + addr], IOPORT, [rb + tmp]
    jz  [rb + tmp], write_mem

    # Yes, drop any 0x0a characters
    eq  [rb + value], 13, [rb + tmp]
    jnz [rb + tmp], write_done

    # Output the character
    out [rb + value]
    jz  0, write_done

write_mem:
    # No, regular memory write
    add [mem], [rb + addr], [ip + 3]
    add [rb + value], 0, [0]

write_done:
    arb 1
    ret 2
.ENDFRAME

##########
push:
.FRAME value; tmp
    arb -1

    add 256, [reg_sp], [rb - 1]         # stack starts at 0x100 = 256
    add [rb + value], 0, [rb - 2]
    arb -2
    call write

    add [reg_sp], -1, [rb - 1]
    arb -1
    call mod_8bit
    add [rb - 3], 0, [reg_sp]

    arb 1
    ret 1
.ENDFRAME

##########
pull:
.FRAME tmp                              # returns tmp
    arb -1

    add [reg_sp], 1, [rb - 1]
    arb -1
    call mod_8bit
    add [rb - 3], 0, [reg_sp]

    add 256, [reg_sp], [rb - 1]         # stack starts at 0x100 = 256
    arb -1
    call read
    add [rb - 3], 0, [rb + tmp]

    arb 1
    ret 0
.ENDFRAME

##########
mem:
    db 0

image_too_big_error:
    db  "image too big to load at specified address", 0

.EOF
