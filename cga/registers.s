.EXPORT mc6845_address_read
.EXPORT mc6845_address_write
.EXPORT mc6845_data_read
.EXPORT mc6845_data_write
.EXPORT mode_control_write
.EXPORT color_control_write
.EXPORT status_read

# From obj/bits.s
.IMPORT bits

##########
mc6845_address_read:
.FRAME port; value                      # returns value
    arb -1

    arb 1
    ret 1
.ENDFRAME

##########
mc6845_address_write:
.FRAME addr, value;
    ret 2
.ENDFRAME

##########
mc6845_data_read:
.FRAME port; value                      # returns value
    arb -1

    arb 1
    ret 1
.ENDFRAME

##########
mc6845_data_write:
.FRAME addr, value;
    ret 2
.ENDFRAME

##########
.SYMBOL MODE_TEXT_40_25                 0
.SYMBOL MODE_TEXT_80_25                 1
.SYMBOL MODE_GRAPHICS_320_200           2
.SYMBOL MODE_GRAPHICS_640_200           3

mode:
    db  MODE_TEXT_80_25

.SYMBOL PALETTE_RGY     0
.SYMBOL PALETTE_MCW     1
.SYMBOL PALETTE_RCW     2

palette:
    db  PALETTE_RGY

enable_output:
    db  0

enable_blinking:
    db  0

##########
mode_control_write:
.FRAME addr, value; value_bits, tmp
    arb -2

    # Convert value to bits
    mul [rb + value], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + value_bits]

    # Enable video output?
    add [rb + value_bits], 3, [ip + 1]
    add [0], 0, [enable_output]

    # Text mode or graphics mode?
    add [rb + value_bits], 1, [ip + 1]
    jnz [0], mode_control_write_graphics

    # Text mode; enable blinking?
    add [rb + value_bits], 5, [ip + 1]
    add [0], 0, [enable_blinking]

    # Text mode; 40 columns or 80 columns?
    add [rb + value_bits], 0, [ip + 1]
    jnz [0], mode_control_write_text_80

    add MODE_TEXT_40_25, 0, [mode]
    jz  0, mode_control_write_redraw

mode_control_write_text_80:
    add MODE_TEXT_80_25, 0, [mode]
    jz  0, mode_control_write_redraw

mode_control_write_graphics:
    # Graphics mode; which resolution?
    add [rb + value_bits], 4, [ip + 1]
    jnz [0], mode_control_write_graphics_640

    add MODE_GRAPHICS_320_200, 0, [mode]

    # Graphics mode, 320x200; use the special palette?
    add [rb + value_bits], 2, [ip + 1]
    jz  [0], mode_control_write_skip_palette_2

    # Palette 2 overrides palette set using the color control register
    add PALETTE_RCW, 0, [palette]

mode_control_write_skip_palette_2:
    jz  0, mode_control_write_redraw

mode_control_write_graphics_640:
    # Graphics mode, 640x200
    add MODE_GRAPHICS_640_200, 0, [mode]
    jz  0, mode_control_write_redraw

mode_control_write_redraw:
    # TODO redraw screen after updating mode

    out 'M'
    add '0', [mode], [rb + tmp]
    out [rb + tmp]
    out ' '
    out 'P'
    add '0', [palette], [rb + tmp]
    out [rb + tmp]
    out ' '
    out 'O'
    add '0', [enable_output], [rb + tmp]
    out [rb + tmp]
    out ' '
    out 'B'
    add '0', [enable_blinking], [rb + tmp]
    out [rb + tmp]
    out 10

    arb 2
    ret 2
.ENDFRAME

##########
color_control_write:
.FRAME addr, value;
    ret 2
.ENDFRAME

##########
status_read:
.FRAME port; value                      # returns value
    arb -1

    arb 1
    ret 1
.ENDFRAME

.EOF
