.EXPORT redraw_screen_graphics_lo
.EXPORT write_memory_graphics_lo

# From the config file
.IMPORT config_log_cga_debug

# From blocks_4x2.s
.IMPORT blocks_4x2_0
.IMPORT blocks_4x2_1
.IMPORT blocks_4x2_2
.IMPORT blocks_4x2_3

# From graphics_palette.s
.IMPORT palette_graphics
.IMPORT color_mappings

# From log.s
.IMPORT redraw_screen_graphics_log

# From registers.s
.IMPORT mode_enable_output

# From screen.s
.IMPORT screen_needs_redraw

# From cpu/state.s
.IMPORT mem

# From util/crumbs.s
.IMPORT crumb_0
.IMPORT crumb_1
.IMPORT crumb_2
.IMPORT crumb_3

# From util/div80.s
.IMPORT div80

# From util/printb.s
.IMPORT printb

# From util/shr.s
.IMPORT shr_1

##########
redraw_screen_graphics_lo:
.FRAME row, col, addr_row0, tmp
    arb -4

    # We are going to draw, is output enabled?
    jnz [mode_enable_output], redraw_screen_graphics_enabled

    # Drawing is disabled, screen contents will no longer match CGA memory
    add 1, 0, [screen_needs_redraw]

    jz  0, redraw_screen_graphics_done

redraw_screen_graphics_enabled:
    # Redraw the whole screen by iterating over pairs of characters

    # Initialize the row loop
    add [mem], 0xb8000, [rb + addr_row0]
    add 0, 0, [rb + row]

redraw_screen_graphics_row_loop:
    # Set cursor position for each row
    out 0x1b
    out '['

    add [rb + row], 1, [rb - 1]
    arb -1
    call printb

    out ';'
    out '0'
    out 'H'

    # Initialize the column loop
    add 0, 0, [rb + col]

redraw_screen_graphics_col_loop:
    # Build and output the two characters
    add [rb + addr_row0], 0, [rb - 1]
    add crumb_3, 0, [rb - 2]
    add crumb_2, 0, [rb - 3]
    arb -3
    call output_character

    add [rb + addr_row0], 0, [rb - 1]
    add crumb_1, 0, [rb - 2]
    add crumb_0, 0, [rb - 3]
    arb -3
    call output_character

    # Next column
    add [rb + addr_row0], 1, [rb + addr_row0]               # 1 byte of CGA memory processed with every iteration
    add [rb + col], 2, [rb + col]                           # 2 characters output with every iteration

    # 320x200: 160 = 640 pixels / 4 pixels per terminal character
    # 640x200: 160 = 320 pixels / 2 pixels per terminal character
    eq  [rb + col], 160, [rb + tmp]
    jz  [rb + tmp], redraw_screen_graphics_col_loop

    # We have processed 4 rows of pixels (since each terminal character is 4 pixels high)
    # Because of interlacing, we only need to increment addr_row0 by two rows each iteration
    # It is incremented by one row during the course of drawing the row
    # Here we need to increment it by one additional row to prepare it for next row loop iteration
    #
    # row 0: <addr>                 *. .. .. .. .. .. .. .. * addr_row0 was here before we drew current row
    # row 1: <addr + 0x2000>        .. .. .. .. .. .. .. ..   (this row is 8kB below, not relevant for calculations)
    # row 2: <addr + 80>            *. .. .. .. .. .. .. .. * addr_row0 points here now, after drawing current row
    # row 3: <addr + 0x2000 + 80>   .. .. .. .. .. .. .. ..   (this row is also not relevant for calculations)
    # row 0: <addr + 80 + 80>       *. .. .. .. .. .. .. .. * addr_row0 needs to point here for the next row

    # Next row
    add [rb + addr_row0], 80, [rb + addr_row0]              # 80 = increment addr_row0 by one pixel row, as explained above
    add [rb + row], 1, [rb + row]                           # 1 row of characters was output

    eq  [rb + row], 50, [rb + tmp]                          # 50 = 200 pixels / 4 pixels per terminal character
    jz  [rb + tmp], redraw_screen_graphics_row_loop

    # Reset all attributes
    out 0x1b
    out '['
    out '0'
    out 'm'

    add 0, 0, [screen_needs_redraw]

    # CGA logging
    jz  [config_log_cga_debug], redraw_screen_graphics_done
    call redraw_screen_graphics_log

redraw_screen_graphics_done:
    arb 4
    ret 0
.ENDFRAME

##########
write_memory_graphics_lo:
.FRAME addr, value; row, col, addr_row0, tmp
    arb -4

    # Update both characters affected by writing one byte to CGA memory
    #
    # 320x200:
    # bits:     01 23 45 67 01 23 45 67 01 23 45 67
    # bytes:   |           |           |           |
    # pixels:  |  |  |  |  |  |  |  |  |  |  |  |  |
    # chars:   |     |     |     |     |     |     |
    #                       aa bb|aa bb
    #                       cc dd|cc dd
    #                       ee ff|ee ff
    #                       gg hh|gg hh
    #
    # If the second byte was updated, it means four pixels in one pixel row were updated
    # That means two characters were updated (since each character is two pixels wide)
    # Those two characters together cover four pixel columns and four pixel rows
    #
    # 640x200:
    # bits:     0 1 2 3 4 5 6 7 0 1 2 3 4 5 6 7 0 1 2 3 4 5 6 7
    # bytes:   |               |               |               |
    # pixels:  | | | | | | | | | | | | | | | | | | | | | | | | |
    # chars:   |       |       |       |       |       |       |
    #                          |a  |b  |a  |b  |
    #                          |c  |d  |c  |d  |
    #                          |e  |f  |e  |f  |
    #                          |g  |h  |g  |h  |
    #
    # If the second byte was updated, it means eight pixels in one pixel row were updated
    # We can only spare two characters to cover those eight pixels, so we ignore all
    # pixels in odd columns (since each character is just two pixels wide, not four)
    # Those two characters together cover eight pixel columns and four pixel rows
    #
    # We will calculate  memory coordinates of all pixels covered by those two characters,
    # build those two characters from the pixels, then calculate their on-screen coordinates
    # and print them there
    #
    # Calculations for both graphics modes actually result in the same numbers

    # CGA memory is interlaced
    lt  0x1fff, [rb + addr], [rb + tmp]
    mul [rb + tmp], -0x2000, [rb + tmp]
    add [rb + addr], [rb + tmp], [rb + addr]

    # Is the address too large to be on screen?
    lt  [rb + addr], 8000, [rb + tmp]
    jz  [rb + tmp], write_memory_graphics_done

    # We are going to draw, is output enabled?
    jnz [mode_enable_output], write_memory_graphics_enabled

    # Drawing is disabled, screen contents will no longer match CGA memory
    add 1, 0, [screen_needs_redraw]

    jz  0, write_memory_graphics_done

write_memory_graphics_enabled:
    # Calculate text mode row and column from the memory address
    # row = addr / 80, col = addr - row * 80
    add div80, [rb + addr], [ip + 1]
    add [0], 0, [rb + row]

    mul [rb + row], -80, [rb + tmp]
    add [rb + addr], [rb + tmp], [rb + col]

    # These comments are written for the 320x200 mode, with 640x200 values in
    # angle brackets whenever they differ
    #
    # We are going to update two characters, 4x4 [8x4] pixels
    #
    # First, transform the text mode coordinates to pixel coordinates:
    # pixel_row = tm_row * 2 + odd      # apply interlacing
    # pixel_col = tm_col * 4 [8]        # four [eight] pixels per one byte
    #
    # Next calculate terminal character cordinates from CGA pixel coordinates:
    # term_row0 = floor(pixel_row / pixel_rows_per_char) = floor(pixel_row / 4)
    # term_col0 = floor(pixel_col / pixel_cols_per_char) = floor(pixel_col / 2 [4])
    #
    # When put together, the result is the same for both modes:
    # term_row0 = floor((tm_row * 2 + odd) / 4) = floor(tm_row / 2)
    # term_col0 = floor((tm_col * 4 [8]) / 2 [4]) = tm_col * 2

    # Calculate terminal character coordinates
    add shr_1, [rb + row], [ip + 1]
    add [0], 0, [rb + row]
    mul [rb + col], 2, [rb + col]

    # Next calculate the memory address where first of the four pixel rows starts:
    # pixel_row0 = term_row0 * pixel_rows_per_char = term_row0 * 4
    # pixel_col0 = term_col0 * pixel_cols_per_char = term_col0 * 2 [4]
    #
    # Interlaced rows (=2), 80 bytes per row, 4 [8] pixels per byte
    # The first row of each character is always even
    # addr = (pixel_row0 / 2) * 80 + (pixel_col0 / 4 [8])
    #      = term_row0 * 4 / 2 * 80 + term_col0 * 2 [4] / 4 [8]
    #      = (term_row0 * 160) + (term_col0 >> 1)
    #
    # The resulting address is the same for both modes

    mul [rb + row], 160, [rb + addr_row0]
    # TODO this division seems unnecessary, we are multiplying col by 2 a few lines above
    add shr_1, [rb + col], [ip + 1]
    add [0], [rb + addr_row0], [rb + addr_row0]

    # Convert the 8086 address to intcode address
    add [rb + addr_row0], [mem], [rb + addr_row0]
    add [rb + addr_row0], 0xb8000, [rb + addr_row0]         # CGA memory start

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

    # Build and output the two characters
    add [rb + addr_row0], 0, [rb - 1]
    add crumb_3, 0, [rb - 2]
    add crumb_2, 0, [rb - 3]
    arb -3
    call output_character

    add [rb + addr_row0], 0, [rb - 1]
    add crumb_1, 0, [rb - 2]
    add crumb_0, 0, [rb - 3]
    arb -3
    call output_character

    # Reset all attributes
    out 0x1b
    out '['
    out '0'
    out 'm'

    add 0, 0, [screen_needs_redraw]

write_memory_graphics_done:
    arb 4
    ret 2
.ENDFRAME

##########
output_character:
.FRAME addr_row0, table_hi, table_lo; char, tmp, r0c0, r0c1, r1c0, r1c1, r2c0, r2c1, r3c0, r3c1, max01, max23, color_bg, color_fg, mapping
    arb -15

    # Read first row of pixels
    add [rb + addr_row0], 0, [ip + 1]
    add [0], 0, [rb + tmp]

    add [rb + table_hi], [rb + tmp], [ip + 1]
    add [0], 0, [rb + r0c0]
    add [rb + table_lo], [rb + tmp], [ip + 1]
    add [0], 0, [rb + r0c1]

    # Read second row of pixels
    add [rb + addr_row0], 0x2000, [ip + 1]                  # 0x2000 because of interlacing
    add [0], 0, [rb + tmp]

    add [rb + table_hi], [rb + tmp], [ip + 1]
    add [0], 0, [rb + r1c0]
    add [rb + table_lo], [rb + tmp], [ip + 1]
    add [0], 0, [rb + r1c1]

    # Read third row of pixels
    add [rb + addr_row0], 80, [ip + 1]                      # 80 is one row of pixels
    add [0], 0, [rb + tmp]

    add [rb + table_hi], [rb + tmp], [ip + 1]
    add [0], 0, [rb + r2c0]
    add [rb + table_lo], [rb + tmp], [ip + 1]
    add [0], 0, [rb + r2c1]

    # Read fourth row of pixels
    add [rb + addr_row0], 0x2050, [ip + 1]                  # 0x2050 = 0x2000 + 80
    add [0], 0, [rb + tmp]

    add [rb + table_hi], [rb + tmp], [ip + 1]
    add [0], 0, [rb + r3c0]
    add [rb + table_lo], [rb + tmp], [ip + 1]
    add [0], 0, [rb + r3c1]

    # Count which colors are used in this character
    add 0, 0, [colors + 0]
    add 0, 0, [colors + 1]
    add 0, 0, [colors + 2]
    add 0, 0, [colors + 3]

    add colors, [rb + r0c0], [ip + 5]
    add colors, [rb + r0c0], [ip + 3]
    add [0], 1, [0]
    add colors, [rb + r0c1], [ip + 5]
    add colors, [rb + r0c1], [ip + 3]
    add [0], 1, [0]
    add colors, [rb + r1c0], [ip + 5]
    add colors, [rb + r1c0], [ip + 3]
    add [0], 1, [0]
    add colors, [rb + r1c1], [ip + 5]
    add colors, [rb + r1c1], [ip + 3]
    add [0], 1, [0]
    add colors, [rb + r2c0], [ip + 5]
    add colors, [rb + r2c0], [ip + 3]
    add [0], 1, [0]
    add colors, [rb + r2c1], [ip + 5]
    add colors, [rb + r2c1], [ip + 3]
    add [0], 1, [0]
    add colors, [rb + r3c0], [ip + 5]
    add colors, [rb + r3c0], [ip + 3]
    add [0], 1, [0]
    add colors, [rb + r3c1], [ip + 5]
    add colors, [rb + r3c1], [ip + 3]
    add [0], 1, [0]

    # Find two most used colors by sorting the colors array
    lt  [colors + 0], [colors + 1], [rb + max01]
    lt  [colors + 2], [colors + 3], [rb + max23]

    # Find out color_bg
    add colors + 0, [rb + max01], [ip + 5]
    add colors + 2, [rb + max23], [ip + 2]
    lt  [0], [0], [rb + tmp]
    jz  [rb + tmp], output_character_color_bg_01

    # One of colors 2, 3 is color_bg, the other one could still be color_fg
    add [rb + max23], 2, [rb + color_bg]
    eq  [rb + max23], 0, [rb + max23]
    jz  0, output_character_after_color_bg

output_character_color_bg_01:
    # One of colors 0, 1 is color_bg, the other one could still be color_fg
    add [rb + max01], 0, [rb + color_bg]
    eq  [rb + max01], 0, [rb + max01]

output_character_after_color_bg:
    # Find out color_fg
    add colors + 0, [rb + max01], [ip + 5]
    add colors + 2, [rb + max23], [ip + 2]
    lt  [0], [0], [rb + tmp]
    jz  [rb + tmp], output_character_color_fg_01

    # One of colors 2, 3 is color_fg
    add [rb + max23], 2, [rb + color_fg]
    jz  0, output_character_after_color_fg

output_character_color_fg_01:
    # One of colors 0, 1 is color_fg
    add [rb + max01], 0, [rb + color_fg]

output_character_after_color_fg:
    # Find the color mapping based on two most used colors
    mul [rb + color_bg], 4, [rb + tmp]
    add [rb + color_fg], [rb + tmp], [rb + tmp]

    mul [rb + tmp], 4, [rb + tmp]
    add [color_mappings], [rb + tmp], [rb + mapping]

    # Build a characters out of the individual pixels,
    # while mapping each pixel to either background or foreground color
    #
    #      c0 c1 
    # r0 | a  b |
    # r1 | c  d |
    # r2 | e  f |
    # r3 | g  h |
    #
    # char = 0xhgfedcba

    add [rb + mapping], [rb + r3c1], [ip + 1]
    mul [0], 0b10000000, [rb + char]
    add [rb + mapping], [rb + r3c0], [ip + 1]
    mul [0], 0b01000000, [rb + tmp]
    add [rb + char], [rb + tmp], [rb + char]
    add [rb + mapping], [rb + r2c1], [ip + 1]
    mul [0], 0b00100000, [rb + tmp]
    add [rb + char], [rb + tmp], [rb + char]
    add [rb + mapping], [rb + r2c0], [ip + 1]
    mul [0], 0b00010000, [rb + tmp]
    add [rb + char], [rb + tmp], [rb + char]
    add [rb + mapping], [rb + r1c1], [ip + 1]
    mul [0], 0b00001000, [rb + tmp]
    add [rb + char], [rb + tmp], [rb + char]
    add [rb + mapping], [rb + r1c0], [ip + 1]
    mul [0], 0b00000100, [rb + tmp]
    add [rb + char], [rb + tmp], [rb + char]
    add [rb + mapping], [rb + r0c1], [ip + 1]
    mul [0], 0b00000010, [rb + tmp]
    add [rb + char], [rb + tmp], [rb + char]
    add [rb + mapping], [rb + r0c0], [ip + 1]
    add [0], [rb + char], [rb + char]

    # Set foreground and background color
    out 0x1b
    out '['

    out '3'
    out '8'
    out ';'
    out '2'
    out ';'

    mul [rb + color_fg], 3, [rb + tmp]

    add [palette_graphics], [rb + tmp], [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call printb
    out ';'

    add [rb + tmp], 1, [rb + tmp]
    add [palette_graphics], [rb + tmp], [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call printb
    out ';'

    add [rb + tmp], 1, [rb + tmp]
    add [palette_graphics], [rb + tmp], [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call printb

    out ';'
    out '4'
    out '8'
    out ';'
    out '2'
    out ';'

    mul [rb + color_bg], 3, [rb + tmp]

    add [palette_graphics], [rb + tmp], [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call printb
    out ';'

    add [rb + tmp], 1, [rb + tmp]
    add [palette_graphics], [rb + tmp], [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call printb
    out ';'

    add [rb + tmp], 1, [rb + tmp]
    add [palette_graphics], [rb + tmp], [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call printb

    out 'm'

    # Print the character
    add blocks_4x2_0, [rb + char], [ip + 1]
    out [0]

    add blocks_4x2_1, [rb + char], [ip + 1]
    jz  [0], output_character_done
    add blocks_4x2_1, [rb + char], [ip + 1]
    out [0]

    add blocks_4x2_2, [rb + char], [ip + 1]
    jz  [0], output_character_done
    add blocks_4x2_2, [rb + char], [ip + 1]
    out [0]

    add blocks_4x2_3, [rb + char], [ip + 1]
    jz  [0], output_character_done
    add blocks_4x2_3, [rb + char], [ip + 1]
    out [0]

output_character_done:
    arb 15
    ret 3

colors:
    ds  4, 0
.ENDFRAME

.EOF
