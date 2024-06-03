.EXPORT palette_text_fg
.EXPORT palette_text_bg_ptr
.EXPORT select_palette_text_bg

# From registers.s
.IMPORT mode_not_blinking

##########
palette_text_fg:
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

palette_text_bg_light:
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

palette_text_bg_blink:
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

palette_text_bg_ptr:
    db  palette_text_bg_light

##########
select_palette_text_bg:
.FRAME
    add select_palette_text_bg_data, [mode_not_blinking], [ip + 1]
    add [0], 0, [palette_text_bg_ptr]
    ret 0

select_palette_text_bg_data:
    db  palette_text_bg_blink
    db  palette_text_bg_light
.ENDFRAME

.EOF
