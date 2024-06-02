.EXPORT write_memory_text

# From cp437.s
.IMPORT cp437

# From screen.s
.IMPORT screen_cols

# From cpu/div.s
# TODO use a faster algorithm instead
.IMPORT divide

# From util/bits.s
.IMPORT bits

# From util/shr.s
.IMPORT shr

# From util/print99.s
.IMPORT print99

# From util/util.s
.IMPORT split_16_8_8

# TODO convert CP437 to UTF8 using a table

##########
write_memory_text:
.FRAME addr, value; row, col, is_attribute, addr_lo, addr_hi, tmp
    arb -6

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
    mul [screen_cols], 2, [rb - 6]
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
    lt  [rb + row], 25, [rb + tmp]
    jz  [rb + tmp], write_memory_text_done

    jz  [rb + is_attribute], write_memory_text_char

    # TODO Attribute byte
    jz  0, write_memory_text_done

write_memory_text_char:
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

    # Print the character, converting from CP437 to UTF-8
    mul [rb + value], 3, [rb + tmp]

    add cp437 + 0, [rb + tmp], [ip + 1]
    out [0]

    add cp437 + 1, [rb + tmp], [ip + 1]
    jz  [0], write_memory_text_done
    add cp437 + 1, [rb + tmp], [ip + 1]
    out [0]

    add cp437 + 2, [rb + tmp], [ip + 1]
    jz  [0], write_memory_text_done
    add cp437 + 2, [rb + tmp], [ip + 1]
    out [0]

write_memory_text_done:
    arb 6
    ret 2
.ENDFRAME

.EOF
