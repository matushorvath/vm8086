.EXPORT write_memory_text

# From cp437.s
.IMPORT cp437

# From screen.s
.IMPORT screen_cols

# From cpu/div.s
# TODO use a faster algorithm instead
.IMPORT divide

# From cpu/state.s
.IMPORT mem

# From util/bits.s
.IMPORT bits

# From util/nibbles.s
.IMPORT nibbles

# From util/shr.s
.IMPORT shr

# From util/print99.s
.IMPORT print99

# From util/util.s
.IMPORT split_16_8_8

# TODO convert CP437 to UTF8 using a table

##########
write_memory_text:
.FRAME addr, value; row, col, col_x8, char, attr, addr_lo, addr_hi, tmp
    arb -8

    # TODO Use something faster than the divide function here
    #      divide by  80=2^4*5: shift right by 4, then use a table to divide by 5
    #      divide by 160=2^5*5: shift right by 5, then use a table to divide by 5
    # TODO Use the start address of the screen buffer
    # TODO Receive address already pre-split to bytes to avoid the split_16_8_8

    # Convert address to a row and column on screen
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

    # Is this inside the screen area?
    lt  [rb + row], 25, [rb + tmp]
    jz  [rb + tmp], write_memory_text_done

    # Each screen location occupies two bytes, so divide col by 2
    mul [rb + col], 8, [rb + col_x8]
    add shr + 1, [rb + col_x8], [ip + 1]
    add [0], 0, [rb + col]

    # Is this the character or the attribute?
    add bits, [rb + col_x8], [ip + 1]
    jz  [0], write_memory_text_get_attr

    # This are the attributes, load the character from video memory
    add [rb + value], 0, [rb + attr]

    add [mem], [rb + addr], [rb + tmp]
    add [rb + tmp], 0xb7fff, [ip + 1]
    add [0], 0, [rb + char]

    jz  0, write_memory_text_print

write_memory_text_get_attr:
    # This is the character, load the attributes from video memory
    add [rb + value], 0, [rb + char]

    add [mem], [rb + addr], [rb + tmp]
    add [rb + tmp], 0xb8001, [ip + 1]
    add [0], 0, [rb + attr]

write_memory_text_print:
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

    # Set colors
    out 0x1b
    out '['

    mul [rb + attr], 2, [rb + attr]

    add nibbles + 0, [rb + attr], [ip + 1]
    add [0], palette_text_fg, [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call print99

    out ';'

    add nibbles + 1, [rb + attr], [ip + 1]
    add [0], palette_text_bg_light, [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call print99

    out 'm'

    # Print the character, converting from CP437 to UTF-8
    mul [rb + char], 3, [rb + tmp]

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

    # Reset color
    out 0x1b
    out '['
    out '0'
    out 'm'

write_memory_text_done:
    arb 8
    ret 2
.ENDFRAME

##########
palette_text_fg:
    db  30                              # Black
    db  34                              # Blue
    db  32                              # Green
    db  36                              # Cyan
    db  31                              # Red
    db  35                              # Magenta
    db  33                              # Brown
    db  37                              # Light Gray
    db  90                              # Dark Gray
    db  94                              # Light Blue
    db  92                              # Light Green
    db  96                              # Light Cyan
    db  91                              # Light Red
    db  95                              # Light Magenta
    db  93                              # Yellow
    db  97                              # White

palette_text_bg_light:
    db  49                              # Black (49 for default color or 40 for explicitly black)
    db  44                              # Blue
    db  42                              # Green
    db  46                              # Cyan
    db  41                              # Red
    db  45                              # Magenta
    db  43                              # Brown
    db  47                              # Light Gray
    # TODO light colors don't work with print99, because they're > 100
    db  49 #100                             # Dark Gray
    db  44 #104                             # Light Blue
    db  42 #102                             # Light Green
    db  46 #106                             # Light Cyan
    db  41 #101                             # Light Red
    db  45 #105                             # Light Magenta
    db  43 #103                             # Yellow
    db  47 #107                             # White

# TODO text mode palette with blinking

.EOF
