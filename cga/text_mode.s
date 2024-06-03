.EXPORT write_memory_text

# From cp437.s
.IMPORT cp437_b0
.IMPORT cp437_b1
.IMPORT cp437_b2

# From screen.s
.IMPORT screen_page_size
.IMPORT screen_row_size_160

# From cpu/state.s
.IMPORT mem

# From util/bits.s
.IMPORT bits

# From util/mod5.s
.IMPORT div5

# From util/nibbles.s
.IMPORT nibbles

# From util/shr.s
.IMPORT shr

# From util/printb.s
.IMPORT printb

# From util/util.s
.IMPORT split_16_8_8

##########
write_memory_text:
.FRAME addr, value; row, col, col_x8, char, attr, addr_lo, addr_hi, tmp
    arb -8

    # Is this inside the screen area?
    # TODO use start address of the screen buffer
    lt  [rb + addr], [screen_page_size], [rb + tmp]
    jz  [rb + tmp], write_memory_text_done

    # Split the 14-bit address in video memory to bytes
    # TODO receive address already pre-split to bytes to avoid the split_16_8_8
    add [rb + addr], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [rb + addr_lo]
    add [rb - 4], 0, [rb + addr_hi]

    # Divide the address 80 or 160, depending on screen row size. We first divide by either
    # 2^4 or 2^5 using shift operations, then use the div5/mod5 tables to divide by 5.
    #
    # 0 1 2 3 4 5 6 7   0 1 2 3 4 5 6 7
    #     ==addr_hi==   ====addr_lo====
    #     ====div====   ==div== ==mod==         divide by 2^4
    #     ====div====   =div= ===mod===         divide by 2^5
    #
    # addr = div * 2^4 + mod1 = (row * 5 + mod2) * 2^4 + mod1 = row * 80 + col
    # col = addr - row * 80

    jnz [screen_row_size_160], write_memory_text_calc_160

    # Screen row is 80 bytes, divide by 2^4
    mul [rb + addr_hi], 0x10, [rb + row]

    mul [rb + addr_lo], 8, [rb + tmp]
    add shr + 4, [rb + tmp], [ip + 1]
    add [0], [rb + row], [rb + row]

    # Divide the result by 5
    add div5, [rb + row], [ip + 1]
    add [0], 0, [rb + row]

    # Calculate column
    mul [rb + row], -80, [rb + tmp]
    add [rb + addr], [rb + tmp], [rb + col]

    jz  0, write_memory_text_after_calc

write_memory_text_calc_160:
    # Screen row is 160 bytes, divide by 2^5
    mul [rb + addr_hi], 0x08, [rb + row]

    mul [rb + addr_lo], 8, [rb + tmp]
    add shr + 5, [rb + tmp], [ip + 1]
    add [0], [rb + row], [rb + row]

    # Divide the result by 5
    add div5, [rb + row], [ip + 1]
    add [0], 0, [rb + row]

    # Calculate column
    mul [rb + row], -160, [rb + tmp]
    add [rb + addr], [rb + tmp], [rb + col]

write_memory_text_after_calc:
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
    call printb

    out ';'

    add [rb + col], 1, [rb - 1]
    arb -1
    call printb

    out 'H'

    # Set colors
    out 0x1b
    out '['

    mul [rb + attr], 2, [rb + attr]

    add nibbles + 0, [rb + attr], [ip + 1]
    add [0], palette_text_fg, [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call printb

    out ';'

    add nibbles + 1, [rb + attr], [ip + 1]
    add [0], palette_text_bg_light, [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call printb

    out 'm'

    # Print the character, converting from CP437 to UTF-8
    add cp437_b0, [rb + char], [ip + 1]
    out [0]

    add cp437_b1, [rb + char], [ip + 1]
    jz  [0], write_memory_text_done
    add cp437_b1, [rb + char], [ip + 1]
    out [0]

    add cp437_b2, [rb + char], [ip + 1]
    jz  [0], write_memory_text_done
    add cp437_b2, [rb + char], [ip + 1]
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
    db  100                             # Dark Gray
    db  104                             # Light Blue
    db  102                             # Light Green
    db  106                             # Light Cyan
    db  101                             # Light Red
    db  105                             # Light Magenta
    db  103                             # Yellow
    db  107                             # White

# TODO text mode palette with blinking

.EOF
