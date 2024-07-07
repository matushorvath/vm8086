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
.IMPORT screen_text_negative_row_size
.IMPORT screen_text_row_shr_table

# From registers.s
.IMPORT mode_high_res_text
.IMPORT mode_not_blinking

# From cpu/state.s
.IMPORT mem

# From util/bits.s
.IMPORT bit_0

# From util/div80.s
.IMPORT div80

# From util/nibbles.s
.IMPORT nibble_0
.IMPORT nibble_1

# From util/shr.s
.IMPORT shr_1

# From util/printb.s
.IMPORT printb

##########
write_memory_text:
.FRAME addr, value; row, col, char, attr, tmp
    arb -5

    # TODO don't draw if mode_enable_output is 0; redraw whole screen after enabling output

    # Is this inside the screen area?
    # TODO use start address of the screen buffer
    lt  [rb + addr], [screen_page_size], [rb + tmp]
    jz  [rb + tmp], write_memory_text_done

    # Divide the address by 80 or 160, depending on screen row size
    #  80: row = addr / 80, col = (addr - row * 80) / 2
    # 160: row = (addr / 80) / 2, col = (addr - row * 160) / 2

    # Divide by 80 only, the divide by either 1 or 2 depending on which text mode this is
    add div80, [rb + addr], [ip + 1]
    add [0], [screen_text_row_shr_table], [ip + 1]
    add [0], 0, [rb + row]

    # Calculate column * 2, it will be divided by 2 later
    mul [rb + row], [screen_text_negative_row_size], [rb + tmp]
    add [rb + addr], [rb + tmp], [rb + col]

    # Is this the character or the attributes?
    add bit_0, [rb + col], [ip + 1]
    jz  [0], write_memory_text_get_attr

    # These are the attributes, load the character from video memory
    add [rb + value], 0, [rb + attr]

    add [mem], 0xb7fff, [rb + tmp]
    add [rb + tmp], [rb + addr], [ip + 1]
    add [0], 0, [rb + char]

    jz  0, write_memory_text_print

write_memory_text_get_attr:
    # This is the character, load the attributes from video memory
    add [rb + value], 0, [rb + char]

    add [mem], 0xb8001, [rb + tmp]
    add [rb + tmp], [rb + addr], [ip + 1]
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

    # Output the character
    add [rb + char], 0, [rb - 1]
    add [rb + attr], 0, [rb - 2]
    arb -2
    call output_character

    # Reset all attributes
    # TODO only reset when needed
    out 0x1b
    out '['
    out '0'
    out 'm'

write_memory_text_done:
    arb 5
    ret 2
.ENDFRAME

##########
output_character:
.FRAME char, attr; tmp
    arb -1

    # Set colors, unless it's the default white-on-black
    eq  [rb + attr], 0x07, [rb + tmp]
    jnz [rb + tmp], output_character_after_color

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

output_character_after_color:
    jnz [mode_high_res_text], output_character_double_width

    # Select double width font for 40x25
    out 0x1b
    out '#'
    out '6'

output_character_double_width:
    jnz [mode_not_blinking], output_character_blink

    # Turn on blinking
    out 0x1b
    out '['
    out '5'
    out 'm'

output_character_blink:
    # Print the character, converting from CP437 to UTF-8
    add cp437_0, [rb + char], [ip + 1]
    out [0]

    add cp437_1, [rb + char], [ip + 1]
    jz  [0], output_character_done
    add cp437_1, [rb + char], [ip + 1]
    out [0]

    add cp437_2, [rb + char], [ip + 1]
    jz  [0], output_character_done
    add cp437_2, [rb + char], [ip + 1]
    out [0]

output_character_done:
    arb 1
    ret 2
.ENDFRAME

.EOF
