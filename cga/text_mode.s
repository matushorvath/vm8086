.EXPORT write_memory_text

# From cp437.s
.IMPORT cp437_0
.IMPORT cp437_1
.IMPORT cp437_2

# From text_palette.s
.IMPORT palette_text_fg
.IMPORT palette_text_bg_ptr

# From screen.s
.IMPORT screen_page_size
.IMPORT screen_row_size_160

# From registers.s
.IMPORT mode_high_res_text
.IMPORT mode_not_blinking

# From cpu/state.s
.IMPORT mem

# From util/bits.s
.IMPORT bit_0

# From util/mod5.s
.IMPORT div5

# From util/nibbles.s
.IMPORT nibble_0
.IMPORT nibble_1

# From util/shr.s
.IMPORT shr_1
.IMPORT shr_4
.IMPORT shr_5

# From util/printb.s
.IMPORT printb

# From util/util.s
.IMPORT split_16_8_8

##########
write_memory_text:
.FRAME addr, value; row, col, char, attr, addr_lo, addr_hi, tmp
    arb -7

    # TODO don't draw if mode_enable_output is 0; redraw whole screen after enabling output

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

    # Divide the address by 80 or 160, depending on screen row size. We first divide by either
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

    add shr_4, [rb + addr_lo], [ip + 1]
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

    add shr_5, [rb + addr_lo], [ip + 1]
    add [0], [rb + row], [rb + row]

    # Divide the result by 5
    add div5, [rb + row], [ip + 1]
    add [0], 0, [rb + row]

    # Calculate column
    mul [rb + row], -160, [rb + tmp]
    add [rb + addr], [rb + tmp], [rb + col]

write_memory_text_after_calc:
    # Is this the character or the attributes?
    add bit_0, [rb + col], [ip + 1]
    jz  [0], write_memory_text_get_attr

    # These are the attributes, load the character from video memory
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
    # Each screen location occupies two bytes, so divide col by 2
    add shr_1, [rb + col], [ip + 1]
    add [0], 0, [rb + col]

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

    # Set colors, unless it's the default white-on-black
    eq  [rb + attr], 0x07, [rb + tmp]
    jnz [rb + tmp], write_memory_text_after_color

    out 0x1b
    out '['

    # Set foreground and background color
    out '3'
    out '8'
    out ';'
    out '2'
    out ';'

    add nibble_0, [rb + attr], [ip + 1]
    mul [0], 3, [rb + tmp]

    add palette_text_fg + 0, [rb + tmp], [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call printb
    out ';'

    add palette_text_fg + 1, [rb + tmp], [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call printb
    out ';'

    add palette_text_fg + 2, [rb + tmp], [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call printb

    out ';'
    out '4'
    out '8'
    out ';'
    out '2'
    out ';'

    add nibble_1, [rb + attr], [ip + 1]
    mul [0], 3, [rb + tmp]

    add [palette_text_bg_ptr], [rb + tmp], [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call printb
    out ';'

    add [rb + tmp], 1, [rb + tmp]
    add [palette_text_bg_ptr], [rb + tmp], [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call printb
    out ';'

    add [rb + tmp], 1, [rb + tmp]
    add [palette_text_bg_ptr], [rb + tmp], [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call printb

    out 'm'

write_memory_text_after_color:
    jnz [mode_high_res_text], write_memory_text_after_double_width

    # Select double width font for 40x25
    out 0x1b
    out '#'
    out '6'

write_memory_text_after_double_width:
    jnz [mode_not_blinking], write_memory_text_after_blink

    # Turn on blinking
    out 0x1b
    out '['
    out '5'
    out 'm'

write_memory_text_after_blink:
    # Print the character, converting from CP437 to UTF-8
    add cp437_0, [rb + char], [ip + 1]
    out [0]

    add cp437_1, [rb + char], [ip + 1]
    jz  [0], write_memory_text_after_print
    add cp437_1, [rb + char], [ip + 1]
    out [0]

    add cp437_2, [rb + char], [ip + 1]
    jz  [0], write_memory_text_after_print
    add cp437_2, [rb + char], [ip + 1]
    out [0]

write_memory_text_after_print:
    # Reset all attributes
    # TODO only reset when needed
    out 0x1b
    out '['
    out '0'
    out 'm'

write_memory_text_done:
    arb 7
    ret 2
.ENDFRAME

.EOF
