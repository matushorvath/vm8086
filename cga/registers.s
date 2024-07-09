.EXPORT mc6845_address_write
.EXPORT mc6845_data_read
.EXPORT mc6845_data_write

.EXPORT mode_control_write
.EXPORT color_control_write
.EXPORT status_read

.EXPORT mode_high_res_text
.EXPORT mode_graphics
.EXPORT mode_back_and_white
.EXPORT mode_enable_output
.EXPORT mode_high_res_graphics
.EXPORT mode_not_blinking

.EXPORT color_selected
.EXPORT color_bright
.EXPORT color_palette

# From the config file
.IMPORT config_log_cga_debug
.IMPORT config_log_cga_trace

# From log.s
.IMPORT mc6845_address_read_log
.IMPORT mc6845_address_write_log

.IMPORT mc6845_data_read_log
.IMPORT mc6845_data_write_log

.IMPORT mode_control_write_log_1
.IMPORT mode_control_write_log_2
.IMPORT color_control_write_log
.IMPORT status_read_log

# From screen.s
.IMPORT initialize_screen
.IMPORT redraw_screen
.IMPORT enable_disable_screen

# From util/bits.s
.IMPORT bit_0
.IMPORT bit_1
.IMPORT bit_2
.IMPORT bit_3
.IMPORT bit_4
.IMPORT bit_5

##########
mc6845_address_write:
.FRAME addr, value; tmp
    arb -1

    # CGA logging
    jz  [config_log_cga_trace], mc6845_address_write_after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call mc6845_address_write_log

mc6845_address_write_after_log:
    # Select one of 18 MC6845 registers to access
    lt  [rb + value], 18, [rb + tmp]
    jz  [rb + tmp], mc6845_address_write_done

    add [rb + value], 0, [mc6845_address]

mc6845_address_write_done:
    arb 1
    ret 2
.ENDFRAME

##########
mc6845_data_read:
.FRAME port; value                      # returns value
    arb -1

    # Read value from a MC6845 register
    add mc6845_registers, [mc6845_address], [ip + 1]
    add [0], 0, [rb + value]

    # CGA logging
    jz  [config_log_cga_trace], mc6845_data_read_after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call mc6845_data_read_log

mc6845_data_read_after_log:
    arb 1
    ret 1
.ENDFRAME

##########
mc6845_data_write:
.FRAME addr, value;
    # CGA logging
    jz  [config_log_cga_trace], mc6845_data_write_after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call mc6845_data_write_log

mc6845_data_write_after_log:
    # Write value to a MC6845 register
    add mc6845_registers, [mc6845_address], [ip + 3]
    add [rb + value], 0, [0]

    ret 2
.ENDFRAME

##########
mode_control_write:
.FRAME addr, value; reinitialize, redraw, enable, tmp
    arb -4

    # CGA logging
    jz  [config_log_cga_debug], mode_control_write_start

    add [rb + value], 0, [rb - 1]
    arb -1
    call mode_control_write_log_1

mode_control_write_start:
    # Save text/graphics mode setting
    add [mode_graphics], 0, [rb + tmp]
    add bit_1, [rb + value], [ip + 1]
    add [0], 0, [mode_graphics]

    # If text/graphics mode has changed, reinitialize the screen
    eq  [rb + tmp], [mode_graphics], [rb + tmp]
    eq  [rb + tmp], 0, [rb + reinitialize]

    # Save the enable output setting
    add [mode_enable_output], 0, [rb + tmp]
    add bit_3, [rb + value], [ip + 1]
    add [0], 0, [mode_enable_output]

    # When the output is enabled/disabled, enable/disable the output
    eq  [rb + tmp], [mode_enable_output], [rb + tmp]
    eq  [rb + tmp], 0, [rb + enable]

    # Save the black and white setting (which is actually palette 3 setting)
    add [mode_back_and_white], 0, [rb + tmp]
    add bit_2, [rb + value], [ip + 1]
    add [0], 0, [mode_back_and_white]

    # When setting palette 3 in graphics mode, redraw the screen
    eq  [rb + tmp], [mode_back_and_white], [rb + tmp]
    eq  [rb + tmp], 0, [rb + tmp]
    mul [rb + tmp], [mode_graphics], [rb + redraw]

    # Save the high res graphics setting
    add [mode_high_res_graphics], 0, [rb + tmp]
    add bit_4, [rb + value], [ip + 1]
    add [0], 0, [mode_high_res_graphics]

    # When switching high res graphics in graphics mode, reinitialize the screen
    eq  [rb + tmp], [mode_high_res_graphics], [rb + tmp]
    eq  [rb + tmp], 0, [rb + tmp]
    mul [rb + tmp], [mode_graphics], [rb + tmp]
    add [rb + reinitialize], [rb + tmp], [rb + reinitialize]

    # Save the high res text setting
    add [mode_high_res_text], 0, [rb + tmp]
    add bit_0, [rb + value], [ip + 1]
    add [0], 0, [mode_high_res_text]

    # When switching high res text in text mode, reinitialize the screen
    eq  [rb + tmp], [mode_high_res_text], [rb + tmp]
    add [rb + tmp], [mode_graphics], [rb + tmp]
    eq  [rb + tmp], 0, [rb + tmp]
    add [rb + reinitialize], [rb + tmp], [rb + reinitialize]

    # Save the blinking setting
    add [mode_not_blinking], 0, [rb + tmp]
    add bit_5, [rb + value], [ip + 1]
    add [0], 0, [mode_not_blinking]

    # When switching blinking in text mode, redraw the screen
    eq  [rb + tmp], [mode_not_blinking], [rb + tmp]
    add [rb + tmp], [mode_graphics], [rb + tmp]
    eq  [rb + tmp], 0, [rb + tmp]
    add [rb + redraw], [rb + tmp], [rb + redraw]

    # Do we need to reinitialize the terminal?
    jz  [rb + reinitialize], mode_control_write_redraw

    call initialize_screen
    jz  0, mode_control_write_done

mode_control_write_redraw:
    # No need to reinitialize, do we need to redraw?
    jz  [rb + redraw], mode_control_write_enable

    call redraw_screen
    jz  0, mode_control_write_done

mode_control_write_enable:
    # No need to redraw, do we need to enable output?
    jz  [rb + enable], mode_control_write_done

    call enable_disable_screen

mode_control_write_done:
    # CGA logging
    jz  [config_log_cga_debug], mode_control_write_after_log

    add [rb + reinitialize], 0, [rb - 1]
    add [rb + redraw], 0, [rb - 2]
    add [rb + enable], 0, [rb - 3]
    arb -3
    call mode_control_write_log_2

mode_control_write_after_log:
    arb 4
    ret 2
.ENDFRAME

##########
color_control_write:
.FRAME addr, value; redraw, tmp
    arb -2

    # Store selected color
    add [color_selected], 0, [rb + tmp]
    add bit_3, [rb + value], [ip + 1]
    mul [0], 2, [color_selected]

    add bit_2, [rb + value], [ip + 1]
    add [0], [color_selected], [color_selected]
    mul [color_selected], 2, [color_selected]

    add bit_1, [rb + value], [ip + 1]
    add [0], [color_selected], [color_selected]
    mul [color_selected], 2, [color_selected]

    add bit_0, [rb + value], [ip + 1]
    add [0], [color_selected], [color_selected]

    # When changing selected color, redraw the screen
    eq  [rb + tmp], [color_selected], [rb + tmp]
    eq  [rb + tmp], 0, [rb + redraw]

    # Store the regular/bright palette setting
    add [color_bright], 0, [rb + tmp]
    add bit_4, [rb + value], [ip + 1]
    add [0], 0, [color_bright]

    # When changing regular/bright setting, redraw the screen
    eq  [rb + tmp], [color_selected], [rb + tmp]
    eq  [rb + tmp], 0, [rb + tmp]
    add [rb + redraw], [rb + tmp], [rb + redraw]

    # Store the palette 1/palette 2 setting
    add [color_palette], 0, [rb + tmp]
    add bit_5, [rb + value], [ip + 1]
    add [0], 0, [color_palette]

    # When changing regular/bright setting, redraw the screen
    eq  [rb + tmp], [color_palette], [rb + tmp]
    eq  [rb + tmp], 0, [rb + tmp]
    add [rb + redraw], [rb + tmp], [rb + redraw]

    # All these settings only affect the graphics mode
    mul [rb + redraw], [mode_graphics], [rb + redraw]
    jz  [rb + redraw], color_control_write_done

    call redraw_screen

color_control_write_done:
    # CGA logging
    jz  [config_log_cga_debug], color_control_write_after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call color_control_write_log

color_control_write_after_log:
    arb 2
    ret 2
.ENDFRAME

##########
status_read:
.FRAME port; value                      # returns value
    arb -1

    # There is no danger of visual snow, but some BIOSes expect the horizontal/vertical retrace
    # to change between 0 and 1. We will very roughly simulate that using two counters.
    # There is no light pen support, which is represented by the two corresponding
    # bits being always set to 1.
    add 0b00000110, 0, [rb + value]

    # Is it time for simulated horizontal retrace?
    jnz [horizontal_retrace_counter], status_read_after_horizontal

    # Yes, report horizontal retrace
    add [rb + value], 0b00000001, [rb + value]
    add 16, 0, [horizontal_retrace_counter]

status_read_after_horizontal:
    add [horizontal_retrace_counter], -1, [horizontal_retrace_counter]

    # Is it time for simulated vertical retrace?
    jnz [vertical_retrace_counter], status_read_after_vertical

    # Yes, report vertical retrace
    add [rb + value], 0b00001000, [rb + value]
    add 16, 0, [vertical_retrace_counter]

status_read_after_vertical:
    add [vertical_retrace_counter], -1, [vertical_retrace_counter]

    # CGA logging
    jz  [config_log_cga_trace], status_read_after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call status_read_log

status_read_after_log:
    arb 1
    ret 1
.ENDFRAME

##########
mc6845_address:
    db  0
mc6845_registers:
    ds  18, 0

mode_high_res_text:
    db  0
mode_graphics:
    db  0
mode_back_and_white:
    db  0
mode_enable_output:
    db  0
mode_high_res_graphics:
    db  0
mode_not_blinking:
    db  1

color_selected:
    db  0
color_bright:
    db  0
color_palette:
    db  0

horizontal_retrace_counter:
    db  0
vertical_retrace_counter:
    db  0

.EOF
