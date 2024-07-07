.EXPORT output_character_hi

# From the config file
.IMPORT config_log_cga_debug

# From blocks_4x2.s
.IMPORT blocks_4x2_0
.IMPORT blocks_4x2_1
.IMPORT blocks_4x2_2
.IMPORT blocks_4x2_3

# From graphics_palette.s
.IMPORT palette_graphics

# From log.s
.IMPORT redraw_screen_graphics_log

# From registers.s
.IMPORT mode_enable_output

# From screen.s
.IMPORT screen_needs_redraw

# From cpu/state.s
.IMPORT mem

# From util/bits.s
.IMPORT bit_0
.IMPORT bit_2
.IMPORT bit_4
.IMPORT bit_6

# From util/div80.s
.IMPORT div80

# From util/printb.s
.IMPORT printb

# From util/shr.s
.IMPORT shr_1

##########
output_character_hi:
.FRAME addr_row0, table_hi, table_lo; char, tmp
    arb -2

    # Read first row of pixels
    add [rb + addr_row0], 0, [ip + 1]
    add [0], 0, [rb + tmp]

    add [rb + table_hi], [rb + tmp], [ip + 1]
    add [0], 0, [r0c0]
    add [rb + table_lo], [rb + tmp], [ip + 1]
    add [0], 0, [r0c1]

    # Read second row of pixels
    add [rb + addr_row0], 0x2000, [ip + 1]                  # 0x2000 because of interlacing
    add [0], 0, [rb + tmp]

    add [rb + table_hi], [rb + tmp], [ip + 1]
    add [0], 0, [r1c0]
    add [rb + table_lo], [rb + tmp], [ip + 1]
    add [0], 0, [r1c1]

    # Read third row of pixels
    add [rb + addr_row0], 80, [ip + 1]                      # 80 is one row of pixels
    add [0], 0, [rb + tmp]

    add [rb + table_hi], [rb + tmp], [ip + 1]
    add [0], 0, [r2c0]
    add [rb + table_lo], [rb + tmp], [ip + 1]
    add [0], 0, [r2c1]

    # Read fourth row of pixels
    add [rb + addr_row0], 0x2050, [ip + 1]                  # 0x2050 = 0x2000 + 80
    add [0], 0, [rb + tmp]

    add [rb + table_hi], [rb + tmp], [ip + 1]
    add [0], 0, [r3c0]
    add [rb + table_lo], [rb + tmp], [ip + 1]
    add [0], 0, [r3c1]

    # Build a characters out of the individual pixels
    #
    #      c0 c1 
    # r0 | a  b |
    # r1 | c  d |
    # r2 | e  f |
    # r3 | g  h |
    #
    # char = 0xhgfedcba

    mul [r3c1], 0b10000000, [rb + char]
    mul [r3c0], 0b01000000, [rb + tmp]
    add [rb + char], [rb + tmp], [rb + char]
    mul [r2c1], 0b00100000, [rb + tmp]
    add [rb + char], [rb + tmp], [rb + char]
    mul [r2c0], 0b00010000, [rb + tmp]
    add [rb + char], [rb + tmp], [rb + char]
    mul [r1c1], 0b00001000, [rb + tmp]
    add [rb + char], [rb + tmp], [rb + char]
    mul [r1c0], 0b00000100, [rb + tmp]
    add [rb + char], [rb + tmp], [rb + char]
    mul [r0c1], 0b00000010, [rb + tmp]
    add [rb + char], [rb + tmp], [rb + char]
    add [r0c0], [rb + char], [rb + char]

    # Set foreground and background color
    out 0x1b
    out '['

    out '3'
    out '8'
    out ';'
    out '2'
    out ';'

# TODO use the correct foreground color
    out '2'
    out '5'
    out '5'
    out ';'
    out '2'
    out '5'
    out '5'
    out ';'
    out '2'
    out '5'
    out '5'
    out ';'

#    mul [rb + color_fg], 3, [rb + tmp]
#
#    add [palette_graphics], [rb + tmp], [ip + 1]
#    add [0], 0, [rb - 1]
#    arb -1
#    call printb
#    out ';'
#
#    add [rb + tmp], 1, [rb + tmp]
#    add [palette_graphics], [rb + tmp], [ip + 1]
#    add [0], 0, [rb - 1]
#    arb -1
#    call printb
#    out ';'
#
#    add [rb + tmp], 1, [rb + tmp]
#    add [palette_graphics], [rb + tmp], [ip + 1]
#    add [0], 0, [rb - 1]
#    arb -1
#    call printb

    out ';'
    out '4'
    out '8'
    out ';'
    out '2'
    out ';'

    out '0'
    out ';'
    out '0'
    out ';'
    out '0'
    out ';'

    out 'm'

    # Print the character
    add blocks_4x2_0, [rb + char], [ip + 1]
    out [0]

    add blocks_4x2_1, [rb + char], [ip + 1]
    jz  [0], output_character_hi_done
    add blocks_4x2_1, [rb + char], [ip + 1]
    out [0]

    add blocks_4x2_2, [rb + char], [ip + 1]
    jz  [0], output_character_hi_done
    add blocks_4x2_2, [rb + char], [ip + 1]
    out [0]

    add blocks_4x2_3, [rb + char], [ip + 1]
    jz  [0], output_character_hi_done
    add blocks_4x2_3, [rb + char], [ip + 1]
    out [0]

output_character_hi_done:
    arb 2
    ret 3
.ENDFRAME

##########
# Output character function for current mode
output_character:
    db  0

# Pixel data for currently processed character
r0c0:
    db  0
r0c1:
    db  0
r1c0:
    db  0
r1c1:
    db  0
r2c0:
    db  0
r2c1:
    db  0
r3c0:
    db  0
r3c1:
    db  0

.EOF
