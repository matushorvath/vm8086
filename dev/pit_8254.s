.EXPORT init_pit_8254

# From devices.s
.IMPORT register_ports

# From obj/bits.s
.IMPORT bits

# From libxib.a
# TODO remove
.IMPORT print_num_radix
.IMPORT print_str

##########
pit_8254_ports:
    db  0x40, 0x00, channel_0_read, channel_0_write         # Channel 0 data
    db  0x41, 0x00, channel_1_read, channel_1_write         # Channel 1 data
    db  0x42, 0x00, channel_2_read, channel_2_write         # Channel 2 data
    db  0x43, 0x00, 0, mode_command_write                   # Mode/Command register

    db  -1, -1, -1, -1

##########
init_pit_8254:
.FRAME
    # Register I/O ports
    add pit_8254_ports, 0, [rb - 1]
    arb -1
    call register_ports

    ret 0
.ENDFRAME

##########
channel_0_read:
.FRAME port; value                      # returns value
    arb -1
    add channel_0_read_message, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    arb 1
    ret 1

channel_0_read_message:
    db  "PIT CH0 RD: ", 0
.ENDFRAME

##########
channel_0_write:
.FRAME addr, value;
    add channel_0_write_message, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    ret 2

channel_0_write_message:
    db  "PIT CH0 WR: ", 0
.ENDFRAME

##########
channel_1_read:
.FRAME port; value                      # returns value
    arb -1
    add channel_1_read_message, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    arb 1
    ret 1

channel_1_read_message:
    db  "PIT CH1 RD: ", 0
.ENDFRAME

##########
channel_1_write:
.FRAME addr, value;
    add channel_1_write_message, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    ret 2

channel_1_write_message:
    db  "PIT CH1 WR: ", 0
.ENDFRAME

##########
channel_2_read:
.FRAME port; value                      # returns value
    arb -1
    add channel_2_read_message, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    arb 1
    ret 1

channel_2_read_message:
    db  "PIT CH2 RD: ", 0
.ENDFRAME

##########
channel_2_write:
.FRAME addr, value;
    add channel_2_write_message, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    ret 2

channel_2_write_message:
    db  "PIT CH2 WR: ", 0
.ENDFRAME

##########
mode_command_write:
.FRAME addr, value;
    add mode_command_write_message, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    ret 2

mode_command_write_message:
    db  "PIT M/C WR: ", 0
.ENDFRAME

.EOF
