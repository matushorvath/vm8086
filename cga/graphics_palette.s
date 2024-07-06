.EXPORT reinitialize_graphics_palette

.EXPORT palette_graphics
.EXPORT color_mappings

# From registers.s
.IMPORT mode_back_and_white
.IMPORT color_bright
.IMPORT color_palette
.IMPORT color_selected

##########
reinitialize_graphics_palette:
.FRAME tmp
    arb -1

    # Select graphics palette
    # tmp = 0b_<bright>_<b&w>_<palette>
    mul [color_bright], 2, [rb + tmp]
    add [rb + tmp], [mode_back_and_white], [rb + tmp]
    mul [rb + tmp], 2, [rb + tmp]
    add [rb + tmp], [color_palette], [rb + tmp]

    add reinitialize_graphics_palette_data, [rb + tmp], [ip + 1]
    add [0], 0, [palette_graphics]

    # TODO set also color_mappings

    # TODO color_selected 4 bits to select background color (3=intensity, 210=RGB)

    arb 1
    ret 0

reinitialize_graphics_palette_data:
    db  palette_graphics_lo_0           # lo, default, palette0
    db  palette_graphics_lo_1           # lo, default, palette1
    db  palette_graphics_lo_2           # lo, palette2, *
    db  palette_graphics_lo_2           # lo, palette2, *
    db  palette_graphics_hi_0           # hi, default, palette0
    db  palette_graphics_hi_1           # hi, default, palette1
    db  palette_graphics_hi_2           # hi, palette2, *
    db  palette_graphics_hi_2           # hi, palette2, *
.ENDFRAME

##########
palette_graphics:
    db  palette_graphics_lo_1

color_mappings:
    db  color_mappings_palette_1

##########
# 24-bit color palettes

# TODO verify RGB values for palette 0 and 2
palette_graphics_lo_0:
    db    0,   0,   0                   # <background>
    db  170,   0,   0                   # Red
    db    0, 170,   0                   # Green
    db  170, 170,   0                   # Yellow

palette_graphics_hi_0:
    db    0,   0,   0                   # <background>
    db  255,  85,  85                   # Red
    db   85, 255,  85                   # Green
    db  255, 255,  85                   # Yellow

palette_graphics_lo_1:
    db    0,   0,   0                   # <background>
    db  170,   0, 170                   # Magenta
    db    0, 170, 170                   # Cyan
    db  170, 170, 170                   # White

palette_graphics_hi_1:
    db    0,   0,   0                   # <background>
    db  255,  85, 255                   # Magenta
    db   85, 255, 255                   # Cyan
    db  255, 255, 255                   # White

palette_graphics_lo_2:
    db    0,   0,   0                   # <background>
    db  170,   0,   0                   # Red
    db    0, 170, 170                   # Cyan
    db  170, 170, 170                   # White

palette_graphics_hi_2:
    db    0,   0,   0                   # <background>
    db  255,  85,  85                   # Red
    db   85, 255, 255                   # Cyan
    db  255, 255, 255                   # White

# Every terminal character can have two colors at most, but it contains 8 pixels
# If those pixels use more than two colors, we need to map them to a different color
#
# The first input into this mapping are the two colors that will be used as
# foreground and background color for a terminal character
# The array index is calculated as index = (color_bg << 2 + color_fg)
#
# The second input into this mapping is the pixel color that we need to map to
# either the foreground or the background color
#
# The output is 0 for the background color and 1 for the foreground color,
# and it is calculated as output = color_mappings_palette_?[index][pixel_color]

# TODO create color_mappings_palette_0 and color_mappings_palette_2

color_mappings_palette_1:
    #    B   M   C   W                    b,f    bbff  i
    db  -1, -1, -1, -1                  # 0,0          0
    db   0,  1,  1,  1                  # 0,1 0b_0001  1
    db   0,  1,  1,  1                  # 0,2 0b_0010  2
    db   0,  1,  1,  1                  # 0,3 0b_0011  3
    db   1,  0,  0,  0                  # 1,0 0b_0100  4
    db  -1, -1, -1, -1                  # 1,1          5
    db   1,  0,  1,  1                  # 1,2 0b_0110  6
    db   0,  0,  1,  1                  # 1,3 0b_0111  7
    db   1,  0,  0,  0                  # 2,0 0b_1000  8
    db   0,  1,  0,  0                  # 2,1 0b_1001  9
    db  -1, -1, -1, -1                  # 2,2         10
    db   0,  1,  0,  1                  # 2,3 0b_1011 11
    db   1,  0,  0,  0                  # 3,0 0b_1100 12
    db   1,  1,  0,  0                  # 3,1 0b_1101 13
    db   1,  0,  1,  0                  # 3,2 0b_1110 14
    db  -1, -1, -1, -1                  # 3,3         15

.EOF
