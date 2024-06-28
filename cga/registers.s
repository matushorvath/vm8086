.EXPORT mc6845_address_read
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

.IMPORT mode_control_write_log
.IMPORT color_control_write_log
.IMPORT status_read_log

# From screen.s
.IMPORT reset_screen

# From util/bits.s
.IMPORT bits

##########
mc6845_address_read:
.FRAME port; value                      # returns value
    arb -1

    # CGA logging
    jz  [config_log_cga_trace], mc6845_address_read_after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call mc6845_address_read_log

mc6845_address_read_after_log:
    arb 1
    ret 1
.ENDFRAME

##########
mc6845_address_write:
.FRAME addr, value;
    # CGA logging
    jz  [config_log_cga_trace], mc6845_address_write_after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call mc6845_address_write_log

mc6845_address_write_after_log:
    ret 2
.ENDFRAME

##########
mc6845_data_read:
.FRAME port; value                      # returns value
    arb -1

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
    ret 2
.ENDFRAME

##########
mode_control_write:
.FRAME addr, value; value_bits, tmp
    arb -2

    # Convert value to bits
    mul [rb + value], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + value_bits]

    # Store individual bits
    add [rb + value_bits], 0, [ip + 1]
    add [0], 0, [mode_high_res_text]

    add [rb + value_bits], 1, [ip + 1]
    add [0], 0, [mode_graphics]

    add [rb + value_bits], 2, [ip + 1]
    add [0], 0, [mode_back_and_white]

    add [rb + value_bits], 3, [ip + 1]
    add [0], 0, [mode_enable_output]

    add [rb + value_bits], 4, [ip + 1]
    add [0], 0, [mode_high_res_graphics]

    add [rb + value_bits], 5, [ip + 1]
    add [0], 0, [mode_not_blinking]

    call reset_screen

    # CGA logging
    jz  [config_log_cga_debug], mode_control_write_after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call mode_control_write_log

mode_control_write_after_log:
    arb 2
    ret 2
.ENDFRAME

##########
color_control_write:
.FRAME addr, value; value_bits, tmp
    arb -2

    # Convert value to bits
    mul [rb + value], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + value_bits]

    # Store selected color
    add [rb + value_bits], 3, [ip + 1]
    add [0], 0, [color_selected]
    mul [color_selected], 2, [color_selected]

    add [rb + value_bits], 2, [ip + 1]
    add [0], [color_selected], [color_selected]
    mul [color_selected], 2, [color_selected]

    add [rb + value_bits], 1, [ip + 1]
    add [0], [color_selected], [color_selected]
    mul [color_selected], 2, [color_selected]

    add [rb + value_bits], 0, [ip + 1]
    add [0], [color_selected], [color_selected]

    # Store the other bits
    add [rb + value_bits], 4, [ip + 1]
    add [0], 0, [color_bright]

    add [rb + value_bits], 5, [ip + 1]
    add [0], 0, [color_palette]

    call reset_screen

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
