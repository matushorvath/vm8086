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

palette_16:
palette_text_fg:
palette_text_bg_light:
    db  "0,0,0"    ,0,0,0,0,0,0,0       # Black
    db  "0,0,170"      ,0,0,0,0,0       # Blue
    db  "0,170,0"      ,0,0,0,0,0       # Green
    db  "0,170,170"        ,0,0,0       # Cyan
    db  "170,0,0"      ,0,0,0,0,0       # Red
    db  "170,0,170"        ,0,0,0       # Magenta
    db  "170,85,0"       ,0,0,0,0       # Brown
    db  "170,170,170"          ,0       # Light Gray
    db  "85,85,85"       ,0,0,0,0       # Dark Gray
    db  "85,85,255"        ,0,0,0       # Light Blue
    db  "85,255,85"        ,0,0,0       # Light Green
    db  "85,255,255"         ,0,0       # Light Cyan
    db  "255,85,85"        ,0,0,0       # Light Red
    db  "255,85,255"         ,0,0       # Light Magenta
    db  "255,255,85"         ,0,0       # Yellow
    db  "255,255,255"          ,0       # White

palette_text_bg_blink:
    db  "0,0,0"    ,0,0,0,0,0,0,0       # Black
    db  "0,0,170"      ,0,0,0,0,0       # Blue
    db  "0,170,0"      ,0,0,0,0,0       # Green
    db  "0,170,170"        ,0,0,0       # Cyan
    db  "170,0,0"      ,0,0,0,0,0       # Red
    db  "170,0,170"        ,0,0,0       # Magenta
    db  "170,85,0"       ,0,0,0,0       # Brown
    db  "170,170,170"          ,0       # Light Gray
    db  "0,0,0"    ,0,0,0,0,0,0,0       # Black
    db  "0,0,170"      ,0,0,0,0,0       # Blue
    db  "0,170,0"      ,0,0,0,0,0       # Green
    db  "0,170,170"        ,0,0,0       # Cyan
    db  "170,0,0"      ,0,0,0,0,0       # Red
    db  "170,0,170"        ,0,0,0       # Magenta
    db  "170,85,0"       ,0,0,0,0       # Brown
    db  "170,170,170"          ,0       # Light Gray

.EOF
