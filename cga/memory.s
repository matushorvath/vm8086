.EXPORT write_memory_b8000
.EXPORT read_memory_bc000
.EXPORT write_memory_bc000

# From div.s
.IMPORT divide

# From obj/bits.s
.IMPORT bits

# From obj/shr.s
.IMPORT shr

# From obj/print99.s
.IMPORT print99

# From state.s
.IMPORT mem

# From util.s
.IMPORT split_16_8_8

##########
.FRAME addr, value; write_through, row, col, is_attribute, addr_lo, addr_hi, tmp
    # Function with multiple entry points

write_memory_bc000:
    arb -7
    add [rb + addr], -0xbc000, [rb + addr]
    jz  0, write_memory

write_memory_b8000:
    arb -7
    add [rb + addr], -0xb8000, [rb + addr]

write_memory:
    # We will store the value in main memory, region 0xb8000
    add 0, 0, [rb + write_through]

    add [mem], [rb + addr], [rb + tmp]
    add [rb + tmp], 0xb8000, [ip + 3]
    add [rb + value], 0, [0]

    # TODO Assume 80x25 text mode for now and update the screen
    # TODO Use something faster than the divide function here
    #      divide by  80=2^4*5: shift right by 4, then use a table to divide by 5
    #      divide by 160=2^5*5: shift right by 5, then use a table to divide by 5
    # TODO Use the start address of the screen buffer
    # TODO Receive address already pre-split to bytes to avoid the split_16_8_8

    add [rb + addr], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [rb + addr_lo]
    add [rb - 4], 0, [rb + addr_hi]

    add 2, 0, [rb - 1]
    add [rb + addr_hi], 0, [rb - 4]
    add [rb + addr_lo], 0, [rb - 5]
    add 160, 0, [rb - 6]
    arb -6
    call divide
    add [rb - 8], 0, [rb + row]
    add [rb - 9], 0, [rb + col]

    # Each screen location occupies two bytes, the character and the attribute
    mul [rb + col], 8, [rb + tmp]
    add bits, [rb + tmp], [ip + 1]
    add [0], 0, [rb + is_attribute]
    add shr + 1, [rb + tmp], [ip + 1]
    add [0], 0, [rb + col]

    # Is this inside the screen area?
    lt  [rb + col], 80, [rb + tmp]
    jz  [rb + tmp], write_memory_done
    lt  [rb + row], 25, [rb + tmp]
    jz  [rb + tmp], write_memory_done

    jz  [rb + is_attribute], write_memory_char

    # TODO Attribute byte
    jz  0, write_memory_done

write_memory_char:
    # Set cursor position
    out 0x1b
    out '['
    add [rb + row], 1, [rb - 1]
    arb -1
    call print99
    out ';'
    add [rb + col], 1, [rb - 1]
    arb -1
    call print99
    out 'H'

    # Print character byte
    out [rb + value]

write_memory_done:
    arb 7
    ret 2
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
