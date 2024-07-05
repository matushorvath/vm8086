.EXPORT write_memory_graphics

# From blocks_4x2.s
.IMPORT blocks_4x2_0
.IMPORT blocks_4x2_1
.IMPORT blocks_4x2_2
.IMPORT blocks_4x2_3

# From text_mode.s
.IMPORT address_to_row_col

# From cpu/state.s
.IMPORT mem

# From util/crumbs.s
.IMPORT crumb_0
.IMPORT crumb_1
.IMPORT crumb_2
.IMPORT crumb_3

# From util/printb.s
.IMPORT printb

# From util/shr.s
.IMPORT shr_1

##########
write_memory_graphics:
.FRAME addr, value; odd, row, col, addr_row, char0, char1, tmp
    arb -7

    # Update all characters affected by writing one byte to CGA memory (that's 2 characters for 320x200)
    #
    # bits:     01 23 45 67 01 23 45 67 01 23 45 67 
    # bytes:   |           |           |           |
    # pixels:  |  |  |  |  |  |  |  |  |  |  |  |  |
    # chars:   |     |     |     |     |     |     |
    #                       aa bb aa bb
    #                       cc dd cc dd
    #                       ee ff ee ff
    #                       gg hh gg hh
    #
    # If the second byte was updated, it means four pixels in one pixel row were updated
    # That means two characters were updated (since each character is two pixels wide)
    # Those two characters together cover four pixel columns and four pixel rows
    #
    # We will calculate  memory coordinates of all pixels covered by those two characters,
    # build those two characters from the pixels, then calculate their on-screen coordinates
    # and print them there

    # TODO don't draw if mode_enable_output is 0; redraw whole screen after enabling output
    # TODO precalculate termr, termc (=col, row where we will print), addr_row0

    # CGA memory is interlaced
    lt  0x1fff, [rb + addr], [rb + odd]
    mul [rb + odd], -0x2000, [rb + tmp]
    add [rb + addr], [rb + tmp], [rb + addr]

    # Is the address too large to be on screen?
    lt  [rb + addr], 8000, [rb + tmp]
    jz  [rb + tmp], write_memory_graphics_done

    # Calculate text row and column from the memory address
    # Yes, this is graphics mode, but the algorithm is the same
    add [rb + addr], 0, [rb - 1]
    arb -1
    call address_to_row_col
    add [rb - 3], 0, [rb + row]
    add [rb - 4], 0, [rb + col]

    # We are going to update two characters, that is 4x4 pixels
    #
    # First, transform the text mode coordinates to pixel coordinates:
    # pixel_row = tm_row * 2 + odd      # apply interlacing
    # pixel_col = tm_col * 4            # four pixels per one byte
    #
    # Next calculate terminal character cordinates from CGA pixel coordinates:
    # term_row0 = floor(pixel_row / pixel_rows_per_char) = floor(pixel_row / 4)
    # term_col0 = floor(pixel_col / pixel_cols_per_char) = floor(pixel_col / 2)
    #
    # Together this is:
    # term_row0 = floor((tm_row * 2 + odd) / 4) = floor(tm_row / 2)
    # term_col0 = floor((tm_col * 4) / 2) = tm_col * 2

    # Calculate terminal character coordinates
    add shr_1, [rb + row], [ip + 1]
    add [0], 0, [rb + row]
    mul [rb + col], 2, [rb + col]

    # Next calculate the memory address where first of the four pixel rows starts:
    # pixel_row0 = term_row0 * pixel_rows_per_char = term_row0 * 4
    # pixel_col0 = term_col0 * pixel_cols_per_char = term_col0 * 2
    #
    # Interlaced rows (=2), 80 bytes per row, 4 pixels per byte
    # The first row of each character is always even
    # addr = (pixel_row0 / 2) * 80 + (pixel_col0 / 4)
    #      = term_row0 * 4 / 2 * 80 + term_col0 * 2 / 4
    #      = (term_row0 * 160) + (term_col0 >> 1)

    mul [rb + row], 160, [rb + addr_row]
    add shr_1, [rb + col], [ip + 1]
    add [0], [rb + addr_row], [rb + addr_row]

    # Convert the 8086 address to intcode address
    add [rb + addr_row], [mem], [rb + addr_row]
    add [rb + addr_row], 0xb8000, [rb + addr_row]           # CGA memory start

    # TODO starting from here, create a function that builds one char and call it twice
    # params: addr_row, crumbs3, crumbs2 (or crumbs1, crumbs0)
    # it will keep r?c? internally, count colors, map colors, build char, print char
    # common: set cursor position (before printing chars), reset attributes after

    # Read first row of pixels
    add [rb + addr_row], 0, [ip + 1]
    add [0], 0, [rb + tmp]

    add crumb_3, [rb + tmp], [ip + 1]
    add [0], 0, [r0c0]
    add crumb_2, [rb + tmp], [ip + 1]
    add [0], 0, [r0c1]
    add crumb_1, [rb + tmp], [ip + 1]
    add [0], 0, [r0c2]
    add crumb_0, [rb + tmp], [ip + 1]
    add [0], 0, [r0c3]

    # Read second row of pixels
    add [rb + addr_row], 0x2000, [ip + 1]                   # 0x2000 because of interlacing
    add [0], 0, [rb + tmp]

    add crumb_3, [rb + tmp], [ip + 1]
    add [0], 0, [r1c0]
    add crumb_2, [rb + tmp], [ip + 1]
    add [0], 0, [r1c1]
    add crumb_1, [rb + tmp], [ip + 1]
    add [0], 0, [r1c2]
    add crumb_0, [rb + tmp], [ip + 1]
    add [0], 0, [r1c3]

    # Read third row of pixels
    add [rb + addr_row], 80, [ip + 1]                       # 80 is one row of pixels
    add [0], 0, [rb + tmp]

    add crumb_3, [rb + tmp], [ip + 1]
    add [0], 0, [r2c0]
    add crumb_2, [rb + tmp], [ip + 1]
    add [0], 0, [r2c1]
    add crumb_1, [rb + tmp], [ip + 1]
    add [0], 0, [r2c2]
    add crumb_0, [rb + tmp], [ip + 1]
    add [0], 0, [r2c3]

    # Read fourth row of pixels
    add [rb + addr_row], 0x2050, [ip + 1]                   # 0x2050 = 0x2000 + 80
    add [0], 0, [rb + tmp]

    add crumb_3, [rb + tmp], [ip + 1]
    add [0], 0, [r3c0]
    add crumb_2, [rb + tmp], [ip + 1]
    add [0], 0, [r3c1]
    add crumb_1, [rb + tmp], [ip + 1]
    add [0], 0, [r3c2]
    add crumb_0, [rb + tmp], [ip + 1]
    add [0], 0, [r3c3]

    # TODO select which background and foreground color to use for each character

    # Build two characters from individual pixels
    add 0, 0, [rb + char0]
    add 0, 0, [rb + char1]

    # Map each crumb to either background (0) or foreground (1)
    # TODO map each pixel color to one of the two colors selected
    # TODO for now 0b00 maps to background, 0b01-0b11 to foreground
    lt  0b00, [r0c0], [r0c0]
    lt  0b00, [r0c1], [r0c1]
    lt  0b00, [r0c2], [r0c2]
    lt  0b00, [r0c3], [r0c3]
    lt  0b00, [r1c0], [r1c0]
    lt  0b00, [r1c1], [r1c1]
    lt  0b00, [r1c2], [r1c2]
    lt  0b00, [r1c3], [r1c3]
    lt  0b00, [r2c0], [r2c0]
    lt  0b00, [r2c1], [r2c1]
    lt  0b00, [r2c2], [r2c2]
    lt  0b00, [r2c3], [r2c3]
    lt  0b00, [r3c0], [r3c0]
    lt  0b00, [r3c1], [r3c1]
    lt  0b00, [r3c2], [r3c2]
    lt  0b00, [r3c3], [r3c3]

    # Build two characters out of the individual pixels
    #
    #      c0 c1  c2 c3
    # r0 | a  b | A  B |
    # r1 | c  d | C  D |
    # r2 | e  f | E  F |
    # r3 | g  h | G  H |
    #
    # char0 = 0xhgfedcba
    # char1 = 0xHGFEDCBA

    # First character
    mul [r3c1], 0b10000000, [rb + char0]
    mul [r3c0], 0b01000000, [rb + tmp]
    add [rb + char0], [rb + tmp], [rb + char0]
    mul [r2c1], 0b00100000, [rb + tmp]
    add [rb + char0], [rb + tmp], [rb + char0]
    mul [r2c0], 0b00010000, [rb + tmp]
    add [rb + char0], [rb + tmp], [rb + char0]
    mul [r1c1], 0b00001000, [rb + tmp]
    add [rb + char0], [rb + tmp], [rb + char0]
    mul [r1c0], 0b00000100, [rb + tmp]
    add [rb + char0], [rb + tmp], [rb + char0]
    mul [r0c1], 0b00000010, [rb + tmp]
    add [rb + char0], [rb + tmp], [rb + char0]
    add [rb + char0], [r0c0], [rb + char0]

    # Second character
    mul [r3c3], 0b10000000, [rb + char1]
    mul [r3c2], 0b01000000, [rb + tmp]
    add [rb + char1], [rb + tmp], [rb + char1]
    mul [r2c3], 0b00100000, [rb + tmp]
    add [rb + char1], [rb + tmp], [rb + char1]
    mul [r2c2], 0b00010000, [rb + tmp]
    add [rb + char1], [rb + tmp], [rb + char1]
    mul [r1c3], 0b00001000, [rb + tmp]
    add [rb + char1], [rb + tmp], [rb + char1]
    mul [r1c2], 0b00000100, [rb + tmp]
    add [rb + char1], [rb + tmp], [rb + char1]
    mul [r0c3], 0b00000010, [rb + tmp]
    add [rb + char1], [rb + tmp], [rb + char1]
    add [rb + char1], [r0c2], [rb + char1]

    # Output the two characters
    # TODO consider making this a function, perhaps common with text_mode
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

    # TODO set colors, see text mode for example

    # Print the two characters
    add blocks_4x2_0, [rb + char0], [ip + 1]
    out [0]

    add blocks_4x2_1, [rb + char0], [ip + 1]
    jz  [0], write_memory_graphics_after_char0
    add blocks_4x2_1, [rb + char0], [ip + 1]
    out [0]

    add blocks_4x2_2, [rb + char0], [ip + 1]
    jz  [0], write_memory_graphics_after_char0
    add blocks_4x2_2, [rb + char0], [ip + 1]
    out [0]

    add blocks_4x2_3, [rb + char0], [ip + 1]
    jz  [0], write_memory_graphics_after_char0
    add blocks_4x2_3, [rb + char0], [ip + 1]
    out [0]

write_memory_graphics_after_char0:
    add blocks_4x2_0, [rb + char1], [ip + 1]
    out [0]

    add blocks_4x2_1, [rb + char1], [ip + 1]
    jz  [0], write_memory_graphics_after_char1
    add blocks_4x2_1, [rb + char1], [ip + 1]
    out [0]

    add blocks_4x2_2, [rb + char1], [ip + 1]
    jz  [0], write_memory_graphics_after_char1
    add blocks_4x2_2, [rb + char1], [ip + 1]
    out [0]

    add blocks_4x2_3, [rb + char1], [ip + 1]
    jz  [0], write_memory_graphics_after_char1
    add blocks_4x2_3, [rb + char1], [ip + 1]
    out [0]

write_memory_graphics_after_char1:
    # Reset all attributes
    # TODO only reset when needed
    out 0x1b
    out '['
    out '0'
    out 'm'

write_memory_graphics_done:
    arb 7
    ret 2
.ENDFRAME

##########
r0c0:
    db  0
r0c1:
    db  0
r0c2:
    db  0
r0c3:
    db  0
r1c0:
    db  0
r1c1:
    db  0
r1c2:
    db  0
r1c3:
    db  0
r2c0:
    db  0
r2c1:
    db  0
r2c2:
    db  0
r2c3:
    db  0
r3c0:
    db  0
r3c1:
    db  0
r3c2:
    db  0
r3c3:
    db  0

.EOF
