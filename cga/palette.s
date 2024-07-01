.EXPORT reinitialize_palette

.EXPORT palette_4b_text_fg
.EXPORT palette_4b_text_bg_ptr
.EXPORT palette_24b_text_fg
.EXPORT palette_24b_text_bg_ptr

# From the config file
.IMPORT config_color_mode

# From registers.s
.IMPORT mode_not_blinking

##########
reinitialize_palette:
.FRAME
    # Select background palette based on CGA mode and terminal features
    jnz [config_color_mode], reinitialize_palette_24b

    # 4-bit palette
    add reinitialize_palette_4b_data, [mode_not_blinking], [ip + 1]
    add [0], 0, [palette_4b_text_bg_ptr]

    jz  0, reinitialize_palette_done

reinitialize_palette_24b:
    # 24-bit palette
    add reinitialize_palette_24b_data, [mode_not_blinking], [ip + 1]
    add [0], 0, [palette_24b_text_bg_ptr]

reinitialize_palette_done:
    ret 0

reinitialize_palette_4b_data:
    db  palette_4b_text_bg_blink
    db  palette_4b_text_bg_light

reinitialize_palette_24b_data:
    db  palette_24b_text_bg_blink
    db  palette_24b_text_bg_light
.ENDFRAME

##########
palette_4b_text_bg_ptr:
    db  palette_4b_text_bg_light

palette_24b_text_bg_ptr:
    db  palette_24b_text_bg_light

##########
# 4-bit color palettes; these are often supported, but don't match real CGA colors very well

palette_4b_text_fg:
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

palette_4b_text_bg_light:
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

palette_4b_text_bg_blink:
    db  49                              # Black (49 for default color or 40 for explicitly black)
    db  44                              # Blue
    db  42                              # Green
    db  46                              # Cyan
    db  41                              # Red
    db  45                              # Magenta
    db  43                              # Brown
    db  47                              # Light Gray
    db  49                              # Black
    db  44                              # Blue
    db  42                              # Green
    db  46                              # Cyan
    db  41                              # Red
    db  45                              # Magenta
    db  43                              # Brown
    db  47                              # Light Gray

##########
# 24-bit color palettes; may not be supported by all terminals, but the colors are exact

palette_24b_text_fg:
palette_24b_text_bg_light:
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

palette_24b_text_bg_blink:
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
