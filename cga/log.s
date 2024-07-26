.EXPORT mc6845_address_read_log
.EXPORT mc6845_address_write_log

.EXPORT mc6845_data_read_log
.EXPORT mc6845_data_write_log

.EXPORT mode_control_write_log_1
.EXPORT mode_control_write_log_2
.EXPORT color_control_write_log
.EXPORT status_read_log

.EXPORT redraw_screen_text_log
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

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10
    ret 1

.msg:
    db  "cga address read: value ", 0
.ENDFRAME

##########
mc6845_address_write_log:
.FRAME value;
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10
    ret 1

.msg:
    db  "cga address write: value ", 0
.ENDFRAME

##########
mc6845_data_read_log:
.FRAME value;
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10
    ret 1

.msg:
    db  "cga data read: value ", 0
.ENDFRAME

##########
mc6845_data_write_log:
.FRAME value;
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10
    ret 1

.msg:
    db  "cga data write: value ", 0
.ENDFRAME

##########
mode_control_write_log_1:
.FRAME value;
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10

    ret 1

.msg:
    db  "cga mode write: value ", 0
.ENDFRAME

##########
mode_control_write_log_2:
.FRAME reinitialize, redraw, enable;
    call log_start

    add .reinitialize_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + reinitialize], 0, [rb - 1]
    arb -1
    call print_num

    add .redraw_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + redraw], 0, [rb - 1]
    arb -1
    call print_num

    add .enable_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + enable], 0, [rb - 1]
    arb -1
    call print_num

    out 10

    call dump_cga_state

    ret 3

.reinitialize_msg:
    db  "cga mode write: reinitialize ", 0
.redraw_msg:
    db  " redraw ", 0
.enable_msg:
    db  " enable/disable ", 0
.ENDFRAME

##########
color_control_write_log:
.FRAME value;
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10

    call dump_cga_state

    ret 1

.msg:
    db  "cga color write: value ", 0
.ENDFRAME

##########
status_read_log:
.FRAME value;
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10
    ret 1

.msg:
    db  "cga status read: value ", 0
.ENDFRAME

##########
redraw_screen_text_log:
.FRAME
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    out 10
    ret 0

.msg:
    db  "cga screen redraw, text", 0
.ENDFRAME

##########
redraw_screen_graphics_log:
.FRAME
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    out 10
    ret 0

.msg:
    db  "cga screen redraw, graphics", 0
.ENDFRAME

##########
dump_cga_state:
.FRAME
    call log_start

    add .start_msg, 0, [rb - 1]
    arb -1
    call print_str

    add .high_res_text_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_high_res_text], 0, [rb - 1]
    arb -1
    call print_num

    add .graphics_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_graphics], 0, [rb - 1]
    arb -1
    call print_num

    add .back_and_white_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_back_and_white], 0, [rb - 1]
    arb -1
    call print_num

    add .enable_output_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_enable_output], 0, [rb - 1]
    arb -1
    call print_num

    add .high_res_graphics_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_high_res_graphics], 0, [rb - 1]
    arb -1
    call print_num

    add .blinking_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_not_blinking], 0, [rb - 1]
    arb -1
    call print_num

    add .color_selected_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [color_selected], 0, [rb - 1]
    arb -1
    call print_num

    add .bright_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [color_bright], 0, [rb - 1]
    arb -1
    call print_num

    add .palette_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [color_palette], 0, [rb - 1]
    arb -1
    call print_num

    out 10

    ret 0

.start_msg:
    db  "cga state:", 0
.high_res_text_msg:
    db  " hi-text ", 0
.graphics_msg:
    db  " gr ", 0
.back_and_white_msg:
    db  " mono ", 0
.enable_output_msg:
    db  " output ", 0
.high_res_graphics_msg:
    db  " hi-gr ", 0
.blinking_msg:
    db  " blink ", 0
.color_selected_msg:
    db  " select ", 0
.bright_msg:
    db  " bright ", 0
.palette_msg:
    db  " palette ", 0
.ENDFRAME

.EOF
