.EXPORT mc6845_address_read
.EXPORT mc6845_address_write
.EXPORT mc6845_data_read
.EXPORT mc6845_data_write
.EXPORT mode_control_write
.EXPORT color_control_write
.EXPORT status_read

# From obj/bits.s
.IMPORT bits

# From libxib.a
.IMPORT print_num_radix
.IMPORT print_str

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
    add [0], 0, [mode_blinking]

    # TODO remove
    call dump_cga_state

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

    # TODO remove
    call dump_cga_state

    arb 2
    ret 2
.ENDFRAME

##########
status_read:
.FRAME port; value                      # returns value
    arb -1

    # There is no danger of visual snow, so we will always report 'display enable'
    # and 'vertical retrace' as 1, hoping that does not break anything.
    # There is no light pen support, which is represented by the two corresponding
    # bits being set to 1.

    add 0b00001111, 0, [rb + value]

    arb 1
    ret 1
.ENDFRAME

##########
dump_cga_state:
.FRAME
    add dump_cga_state_separator, 0, [rb - 1]
    arb -1
    call print_str

    add dump_cga_state_high_res_text, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_high_res_text], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    add dump_cga_state_graphics, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_graphics], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    add dump_cga_state_back_and_white, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_back_and_white], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    add dump_cga_state_enable_output, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_enable_output], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    add dump_cga_state_high_res_graphics, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_high_res_graphics], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    add dump_cga_state_blinking, 0, [rb - 1]
    arb -1
    call print_str

    add [mode_blinking], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    add dump_cga_state_color_selected, 0, [rb - 1]
    arb -1
    call print_str

    add [color_selected], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    add dump_cga_state_bright, 0, [rb - 1]
    arb -1
    call print_str

    add [color_bright], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    add dump_cga_state_palette, 0, [rb - 1]
    arb -1
    call print_str

    add [color_palette], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    ret 0

dump_cga_state_separator:
    db  "----------", 0
dump_cga_state_high_res_text:
    db  10, "high res text: ", 0
dump_cga_state_graphics:
    db  10, "graphics: ", 0
dump_cga_state_back_and_white:
    db  10, "black and white: ", 0
dump_cga_state_enable_output:
    db  10, "enable output: ", 0
dump_cga_state_high_res_graphics:
    db  10, "high res graphics: ", 0
dump_cga_state_blinking:
    db  10, "blinking: ", 0
dump_cga_state_color_selected:
    db  10, "selected: ", 0
dump_cga_state_bright:
    db  10, "bright: ", 0
dump_cga_state_palette:
    db  10, "palette: ", 0
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
mode_blinking:
    db  0

color_selected:
    db  0
color_bright:
    db  0
color_palette:
    db  0

.EOF
