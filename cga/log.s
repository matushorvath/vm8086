.EXPORT mc6845_address_read_log
.EXPORT mc6845_address_write_log

.EXPORT mc6845_data_read_log
.EXPORT mc6845_data_write_log

.EXPORT mode_control_write_log_1
.EXPORT mode_control_write_log_2
.EXPORT color_control_write_log
.EXPORT status_read_log

.EXPORT redraw_screen_graphics_log

# From registers.s
.IMPORT mode_high_res_text
.IMPORT mode_graphics
.IMPORT mode_back_and_white
.IMPORT mode_enable_output
.IMPORT mode_high_res_graphics
.IMPORT mode_not_blinking

.IMPORT color_selected
.IMPORT color_bright
.IMPORT color_palette

# From util/log.s
.IMPORT log_start

# From libxib.a
.IMPORT print_str
.IMPORT print_num
.IMPORT print_num_2_b

##########
mc6845_address_read_log:
.FRAME value;
    call log_start

    add mc6845_address_read_log_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10
    ret 1

mc6845_address_read_log_start:
    db  "cga address read: value ", 0
.ENDFRAME

##########
mc6845_address_write_log:
.FRAME value;
    call log_start

    add mc6845_address_write_log_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10
    ret 1

mc6845_address_write_log_start:
    db  "cga address write: value ", 0
.ENDFRAME

##########
mc6845_data_read_log:
.FRAME value;
    call log_start

    add mc6845_data_read_log_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10
    ret 1

mc6845_data_read_log_start:
    db  "cga data read: value ", 0
.ENDFRAME

##########
mc6845_data_write_log:
.FRAME value;
    call log_start

    add mc6845_data_write_log_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10
    ret 1

mc6845_data_write_log_start:
    db  "cga data write: value ", 0
.ENDFRAME

##########
mode_control_write_log_1:
.FRAME value;
    call log_start

    add mode_control_write_log_1_value, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10

    ret 1

mode_control_write_log_1_value:
    db  "cga mode write: value ", 0
.ENDFRAME

##########
mode_control_write_log_2:
.FRAME reset, enable_disable;
    call log_start

    add mode_control_write_log_2_reset, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + reset], 0, [rb - 1]
    arb -1
    call print_num

    add mode_control_write_log_2_enable, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + enable_disable], 0, [rb - 1]
    arb -1
    call print_num

    out 10

    call dump_cga_state

    ret 2

mode_control_write_log_2_reset:
    db  "cga mode write: reset ", 0
mode_control_write_log_2_enable:
    db  " enable/disable ", 0
.ENDFRAME

##########
color_control_write_log:
.FRAME value;
    call log_start

    add color_control_write_log_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10

    call dump_cga_state

    ret 1

color_control_write_log_start:
    db  "cga color write: value ", 0
.ENDFRAME

##########
status_read_log:
.FRAME value;
    call log_start

    add status_read_log_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10
    ret 1

status_read_log_start:
    db  "cga status read: value ", 0
.ENDFRAME

##########
redraw_screen_graphics_log:
.FRAME
    call log_start

    add redraw_screen_graphics_log_msg, 0, [rb - 1]
    arb -1
    call print_str

    out 10
    ret 0

redraw_screen_graphics_log_msg:
    db  "cga screen redraw, graphics", 0
.ENDFRAME

##########
dump_cga_state:
.FRAME
    call log_start

    add dump_cga_state_start, 0, [rb - 1]
    arb -1
    call print_str

    add dump_cga_state_high_res_text, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_high_res_text], 0, [rb - 1]
    arb -1
    call print_num

    add dump_cga_state_graphics, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_graphics], 0, [rb - 1]
    arb -1
    call print_num

    add dump_cga_state_back_and_white, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_back_and_white], 0, [rb - 1]
    arb -1
    call print_num

    add dump_cga_state_enable_output, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_enable_output], 0, [rb - 1]
    arb -1
    call print_num

    add dump_cga_state_high_res_graphics, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_high_res_graphics], 0, [rb - 1]
    arb -1
    call print_num

    add dump_cga_state_blinking, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_not_blinking], 0, [rb - 1]
    arb -1
    call print_num

    add dump_cga_state_color_selected, 0, [rb - 1]
    arb -1
    call print_str

    add [color_selected], 0, [rb - 1]
    arb -1
    call print_num

    add dump_cga_state_bright, 0, [rb - 1]
    arb -1
    call print_str

    add [color_bright], 0, [rb - 1]
    arb -1
    call print_num

    add dump_cga_state_palette, 0, [rb - 1]
    arb -1
    call print_str

    add [color_palette], 0, [rb - 1]
    arb -1
    call print_num

    out 10

    ret 0

dump_cga_state_start:
    db  "cga state:", 0
dump_cga_state_high_res_text:
    db  " hi-text ", 0
dump_cga_state_graphics:
    db  " gr ", 0
dump_cga_state_back_and_white:
    db  " mono ", 0
dump_cga_state_enable_output:
    db  " output ", 0
dump_cga_state_high_res_graphics:
    db  " hi-gr ", 0
dump_cga_state_blinking:
    db  " blink ", 0
dump_cga_state_color_selected:
    db  " select ", 0
dump_cga_state_bright:
    db  " bright ", 0
dump_cga_state_palette:
    db  " palette ", 0
.ENDFRAME

.EOF
