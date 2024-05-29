.EXPORT init_pit_8253
.EXPORT config_vm_callback

# From devices.s
.IMPORT register_ports

# From error.s
.IMPORT report_error

# From obj/bits.s
.IMPORT bits

# From libxib.a
# TODO remove
.IMPORT print_num_radix
.IMPORT print_str

# How 8086_bios uses the channels (MACHINE_XT):
#
# Channel 0:
#  - mode: 00h - 00 00 000 0: latch, mode 0
#    data: in
#    used by delay_15us
#  - mode: 36h - 00 11 011 0: lo+hi byte, mode 3
#    data: out 0x0000
#    used to set up the clock signal
#
# Channel 1:
#  - mode: 54h - 01 01 010 0: lo byte, mode 2
#    data: out 0x12 = 15ms
#    enables DRAM refresh
# We just ignore this channel, don't even set up the callbacks.
# This is what later computers do anyway.
#
# Channel 2:
#  - mode: B6h - 10 11 011 0: lo+hi byte, mode 3
#    data: out pic_freq/400, pic_freq/554, pic_freq/277, pic_freq/370
#              pic_freq/277, pic_freq/415, 1193 (= ~1000Hz)
#    pic_freq = 1193182
#
# PC Speaker
# - bit 0 port 0x61: write, 1 = speaker is controlled by PIT channel 2
#                    (controls 8253 gate input for channel 2 only)
# - bit 1 port 0x61: write, controls speaker directly
# - bit 5 port 0x61: read, output of PIT channel 2

# TODO
#  - need latch for delay_15us
#  - strictly need just modes 0 and 3; and mode 2 for DRAM refresh should not crash
#  - use 0 to represent 65536
#  - IRQ0 is generated when channel 0 transitions low to high
#  - if mode requires we decrement after reload, the decrement is not on the reload cycle, but one cycle after
#  - only run channel 2 if gate is enabled (port 0x63 bit 0)

##########
pit_ports:
    db  0x40, 0x00, channel_0_read, channel_0_write         # Channel 0 data
    db  0x42, 0x00, channel_2_read, channel_2_write         # Channel 2 data
    db  0x43, 0x00, 0, mode_command_write                   # Mode/Command register

    db  -1, -1, -1, -1

##########
init_pit_8253:
.FRAME
    # Register I/O ports
    add pit_ports, 0, [rb - 1]
    arb -1
    call register_ports

    ret 0
.ENDFRAME

##########
config_vm_callback:
    db  pit_8253_vm_callback

##########
pit_8253_vm_callback:
.FRAME continue                         # returns continue
    arb -1

    add 1, 0, [rb + continue]

    arb 1
    ret 0
.ENDFRAME

##########
pit_operation:
pit_operation_ch0:
    db  0
pit_operation_ch2:
    db  0

pit_access:
pit_access_ch0:
    db  0
pit_access_ch2:
    db  0

pit_reload_lo_ch0:
    db  0
pit_reload_hi_ch0:
    db  0
pit_reload_lo_ch2:
    db  0
pit_reload_hi_ch2:
    db  0

pit_value_lo_ch0:
    db  0
pit_value_hi_ch0:
    db  0
pit_value_lo_ch2:
    db  0
pit_value_hi_ch2:
    db  0

##########
mode_command_write:
.FRAME addr, value; value_bits, channel, operation, access, tmp
    arb -5

    # Log access
    # TODO remove log
    add mode_command_write_message, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    # Split value to components
    mul [rb + value], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + value_bits]

    # Check for BCD mode, which is not supported
    add [rb + value_bits], 0, [ip + 1]
    jnz [0], mode_command_write_bcd

    # Read the channel
    add [rb + value_bits], 7, [ip + 1]
    add [0], 0, [rb + channel]
    mul [rb + channel], 2, [rb + channel]
    add [rb + value_bits], 6, [ip + 1]
    add [0], [rb + channel], [rb + channel]

    # No support for read-back
    eq  [rb + channel], 3, [rb + tmp]
    jnz [rb + tmp], mode_command_write_read_back

    # Channel 1 is silently ignored
    eq  [rb + channel], 1, [rb + tmp]
    jnz [rb + tmp], mode_command_write_done

    # Read the operation
    add [rb + value_bits], 3, [ip + 1]
    add [0], 0, [rb + operation]
    mul [rb + operation], 2, [rb + operation]
    add [rb + value_bits], 2, [ip + 1]
    add [0], [rb + operation], [rb + operation]
    mul [rb + operation], 2, [rb + operation]
    add [rb + value_bits], 1, [ip + 1]
    add [0], [rb + operation], [rb + operation]

    # Operations 0b110 and 0b111 are aliases for 0b010 and 0b011
    lt  [rb + operation], 0b110, [rb + tmp]
    jnz [rb + tmp], mode_command_write_after_aliases
    add [rb + operation], -0b100, [rb + operation]

mode_command_write_after_aliases:
    # Only operations 0 and 3 are implemented.
    jz  [rb + operation], mode_command_write_supported_operation
    eq  [rb + operation], 3, [rb + tmp]
    jnz [rb + tmp], mode_command_write_supported_operation

    jz  0, mode_command_write_bad_operation

mode_command_write_supported_operation:
    # Save the operation
    eq  [rb + channel], 2, [rb + tmp]
    add [pit_operation], [rb + tmp], [ip + 3]
    add [rb + operation], 0, [0]

    # Read the access mode
    add [rb + value_bits], 5, [ip + 1]
    add [0], 0, [rb + access]
    mul [rb + access], 2, [rb + access]
    add [rb + value_bits], 4, [ip + 1]
    add [0], [rb + access], [rb + access]

    # Save the access mode
    eq  [rb + access], 2, [rb + tmp]
    add [pit_access], [rb + tmp], [ip + 3]
    add [rb + access], 0, [0]

    # TODO reset the channel to initial state, which depends on mode

    # Log parsed values
    out ' '
    out 'o'
    out ' '

    add [rb + operation], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 1, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ' '
    out 'a'
    out ' '

    add [rb + access], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 1, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ' '
    out 'c'
    out ' '

    add [rb + channel], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 1, 0, [rb - 3]
    arb -3
    call print_num_radix

mode_command_write_done:
    # Line end after the log
    out 10

    arb 5
    ret 2

mode_command_write_bcd:
    out 10
    add mode_command_write_bcd_error, 0, [rb - 1]
    arb -1
    call report_error

mode_command_write_read_back:
    out 10
    add mode_command_write_read_back_error, 0, [rb - 1]
    arb -1
    call report_error

mode_command_write_bad_operation:
    out 10
    add mode_command_write_bad_operation_error, 0, [rb - 1]
    arb -1
    call report_error

mode_command_write_message:
    db  "PIT M/C WR: ", 0
mode_command_write_bcd_error:
    db  "PIT M/C WR: Error, BCD mode is not supported", 0
mode_command_write_read_back_error:
    db  "PIT M/C WR: Error, read-back ", "command is not supported", 0
mode_command_write_bad_operation_error:
    db  "PIT M/C WR: Error, ", "operating mode is not supported", 0
.ENDFRAME

##########
channel_0_write:
.FRAME addr, value;
    # Log access
    # TODO remove log
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
channel_0_read:
.FRAME port; value                      # returns value
    arb -1

    # Log access
    # TODO remove log
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
channel_2_write:
.FRAME addr, value;
    # Log access
    add channel_2_write_message, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    # TODO implement channel 2 properly

    ret 2

channel_2_write_message:
    db  "PIT CH2 WR: ", 0
.ENDFRAME

##########
channel_2_read:
.FRAME port; value                      # returns value
    arb -1

    # Log access
    # TODO remove log
    add channel_2_read_message, 0, [rb - 1]
    arb -1
    call print_str

    out 10

    # Return a dummy value
    # TODO implement channel 2 properly
    add 0xff, 0, [rb + value]

    arb 1
    ret 1

channel_2_read_message:
    db  "PIT CH2 RD", 0
.ENDFRAME

.EOF
