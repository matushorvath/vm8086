.EXPORT initialize_text_palette

.EXPORT palette_16
.EXPORT palette_text_fg
.EXPORT palette_text_bg_ptr

# From registers.s
.IMPORT mode_not_blinking

##########
initialize_text_palette:
.FRAME
    # Select background palette
    add .data, [mode_not_blinking], [ip + 1]
    add [0],0, [palette_text_bg_ptr]

    ret 0

.data:
    db  palette_text_bg_blink
    db  palette_text_bg_light
.ENDFRAME

##########
palette_text_bg_ptr:
    db  palette_text_bg_light

##########
# 24-bit color palettes

# Each palette record is 12 characters long
#    1: string length L
# 11-L: zero bytes
#    L: palette string

TODO L should be multiplied by 6, since add + out are 6 bytes, and we can actually also add .palette_out to it
TODO do it programatically, on initialization of vm
TODO also, first profile whether this actually helps
TODO also, don't forget about the background color for graphics (probably best to save a palette index, not to copy strings)

palette_16:
palette_text_fg:
palette_text_bg_light:
    db   5, 0,0,0,0,0,0,    "0,0,0"     # Black
    db   7, 0,0,0,0,      "0,0,170"     # Blue
    db   7, 0,0,0,0,      "0,170,0"     # Green
    db   9, 0,0,        "0,170,170"     # Cyan
    db   7, 0,0,0,0,      "170,0,0"     # Red
    db   9, 0,0,        "170,0,170"     # Magenta
    db   8, 0,0,0,       "170,85,0"     # Brown
    db  11,,          "170,170,170"     # Light Gray
    db   8, 0,0,0,       "85,85,85"     # Dark Gray
    db   9, 0,0,        "85,85,255"     # Light Blue
    db   9, 0,0,        "85,255,85"     # Light Green
    db  10, 0,         "85,255,255"     # Light Cyan
    db   9, 0,0,        "255,85,85"     # Light Red
    db  10, 0,         "255,85,255"     # Light Magenta
    db  10, 0,         "255,255,85"     # Yellow
    db  11,,          "255,255,255"     # White

palette_text_bg_blink:
    db   5, 0,0,0,0,0,0,    "0,0,0"     # Black
    db   7, 0,0,0,0,      "0,0,170"     # Blue
    db   7, 0,0,0,0,      "0,170,0"     # Green
    db   9, 0,0,        "0,170,170"     # Cyan
    db   7, 0,0,0,0,      "170,0,0"     # Red
    db   9, 0,0,        "170,0,170"     # Magenta
    db   8, 0,0,0,       "170,85,0"     # Brown
    db  11,           "170,170,170"     # Light Gray
    db   5, 0,0,0,0,0,0,    "0,0,0"     # Black
    db   7, 0,0,0,0,      "0,0,170"     # Blue
    db   7, 0,0,0,0,      "0,170,0"     # Green
    db   9, 0,0,        "0,170,170"     # Cyan
    db   7, 0,0,0,0,      "170,0,0"     # Red
    db   9, 0,0,        "170,0,170"     # Magenta
    db   8, 0,0,0,       "170,85,0"     # Brown
    db  11,           "170,170,170"     # Light Gray

.EOF
