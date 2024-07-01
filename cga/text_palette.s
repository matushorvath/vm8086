.EXPORT reinitialize_text_palette

.EXPORT palette_text_fg
.EXPORT palette_text_bg_ptr

# From registers.s
.IMPORT mode_not_blinking

##########
reinitialize_text_palette:
.FRAME
    # Select background palette
    add reinitialize_text_palette_data, [mode_not_blinking], [ip + 1]
    add [0], 0, [palette_text_bg_ptr]

    ret 0

reinitialize_text_palette_data:
    db  palette_text_bg_blink
    db  palette_text_bg_light
.ENDFRAME

##########
palette_text_bg_ptr:
    db  palette_text_bg_light

##########
# 24-bit color palettes

palette_text_fg:
palette_text_bg_light:
    db    0,   0,   0                   # Black
    db    0,   0, 170                   # Blue
    db    0, 170,   0                   # Green
    db    0, 170, 170                   # Cyan
    db  170,   0,   0                   # Red
    db  170,   0, 170                   # Magenta
    db  170,  85,   0                   # Brown
    db  170, 170, 170                   # Light Gray
    db   85,  85,  85                   # Dark Gray
    db   85,  85, 255                   # Light Blue
    db   85, 255,  85                   # Light Green
    db   85, 255, 255                   # Light Cyan
    db  255,  85,  85                   # Light Red
    db  255,  85, 255                   # Light Magenta
    db  255, 255,  85                   # Yellow
    db  255, 255, 255                   # White

palette_text_bg_blink:
    db    0,   0,   0                   # Black
    db    0,   0, 170                   # Blue
    db    0, 170,   0                   # Green
    db    0, 170, 170                   # Cyan
    db  170,   0,   0                   # Red
    db  170,   0, 170                   # Magenta
    db  170,  85,   0                   # Brown
    db  170, 170, 170                   # Light Gray
    db    0,   0,   0                   # Black
    db    0,   0, 170                   # Blue
    db    0, 170,   0                   # Green
    db    0, 170, 170                   # Cyan
    db  170,   0,   0                   # Red
    db  170,   0, 170                   # Magenta
    db  170,  85,   0                   # Brown
    db  170, 170, 170                   # Light Gray

.EOF
