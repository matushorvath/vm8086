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
.IMPORT reset_screen
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
.FRAME addr, value; reset, enable_disable, tmp
    arb -3

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

    # If text/graphics mode has changed, reset the screen
    eq  [rb + tmp], [mode_graphics], [rb + tmp]
    eq  [rb + tmp], 0, [rb + reset]

    # Save the enable output setting
    add [mode_enable_output], 0, [rb + tmp]
    add bit_3, [rb + value], [ip + 1]
    add [0], 0, [mode_enable_output]

    # When the output is disabled/enabled, just do a screen redraw
    eq  [rb + tmp], [mode_enable_output], [rb + tmp]
    eq  [rb + tmp], 0, [rb + enable_disable]

    # Save the black and white setting (which is actually palette 3 setting)
    add [mode_back_and_white], 0, [rb + tmp]
    add bit_2, [rb + value], [ip + 1]
    add [0], 0, [mode_back_and_white]

    # When setting palette 3 in graphics mode, reset the screen
    eq  [rb + tmp], [mode_back_and_white], [rb + tmp]
    eq  [rb + tmp], 0, [rb + tmp]
    mul [rb + tmp], [mode_graphics], [rb + tmp]
    add [rb + reset], [rb + tmp], [rb + reset]

    # Save the high res graphics setting
    add [mode_high_res_graphics], 0, [rb + tmp]
    add bit_4, [rb + value], [ip + 1]
    add [0], 0, [mode_high_res_graphics]

    # When switching high res graphics in graphics mode, reset the screen
    eq  [rb + tmp], [mode_high_res_graphics], [rb + tmp]
    eq  [rb + tmp], 0, [rb + tmp]
    mul [rb + tmp], [mode_graphics], [rb + tmp]
    add [rb + reset], [rb + tmp], [rb + reset]

    # Save the high res text setting
    add [mode_high_res_text], 0, [rb + tmp]
    add bit_0, [rb + value], [ip + 1]
    add [0], 0, [mode_high_res_text]

    # When switching high res text in text mode, reset the screen
    eq  [rb + tmp], [mode_high_res_text], [rb + tmp]
    add [rb + tmp], [mode_graphics], [rb + tmp]
    eq  [rb + tmp], 0, [rb + tmp]
    add [rb + reset], [rb + tmp], [rb + reset]

    # Save the blinking setting
    add [mode_not_blinking], 0, [rb + tmp]
    add bit_5, [rb + value], [ip + 1]
    add [0], 0, [mode_not_blinking]

    # When switching blinking in text mode, reset the screen
    eq  [rb + tmp], [mode_not_blinking], [rb + tmp]
    add [rb + tmp], [mode_graphics], [rb + tmp]
    eq  [rb + tmp], 0, [rb + tmp]
    add [rb + reset], [rb + tmp], [rb + reset]

    # Reset the terminal if needed
    jz  [rb + reset], mode_control_write_after_reset
    call reset_screen

    # Don't worry about enable/disable if we did a full reset
    jz  0, mode_control_write_done

mode_control_write_after_reset:
    # Reset was not needed, do we need to process an enable/disable?
    jz  [rb + enable_disable], mode_control_write_done
    call enable_disable_screen

mode_control_write_done:
    # CGA logging
    jz  [config_log_cga_debug], mode_control_write_after_log

    add [rb + reset], 0, [rb - 1]
    add [rb + enable_disable], 0, [rb - 2]
    arb -2
    call mode_control_write_log_2

mode_control_write_after_log:
    arb 3
    ret 2
.ENDFRAME

##########
color_control_write:
.FRAME addr, value;
    # Store selected color
    # TODO use color_selected
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

    # Store the other bits
    add bit_4, [rb + value], [ip + 1]
    add [0], 0, [color_bright]

    add bit_5, [rb + value], [ip + 1]
    add [0], 0, [color_palette]

    # TODO don't reset the terminal unless it's needed, it breaks nc in pcxtbios
    call reset_screen

    # CGA logging
    jz  [config_log_cga_debug], color_control_write_after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call color_control_write_log

color_control_write_after_log:
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
