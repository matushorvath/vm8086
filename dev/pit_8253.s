.EXPORT init_pit_8253
.EXPORT config_vm_callback

# From devices.s
.IMPORT register_ports

# From util/error.s
.IMPORT report_error

# From obj/bits.s
.IMPORT bits

# From pit_8253_ch0.s
.IMPORT pit_data_read_ch0
.IMPORT pit_data_write_ch0
.IMPORT pit_mode_command_write_ch0
.IMPORT pit_vm_callback_ch0

# From pit_8253_ch2.s
.IMPORT pit_data_read_ch2
.IMPORT pit_data_write_ch2
.IMPORT pit_mode_command_write_ch2
.IMPORT pit_vm_callback_ch2

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

##########
pit_ports:
    db  0x40, 0x00, pit_data_read_ch0, pit_data_write_ch0   # Channel 0 data
    db  0x42, 0x00, pit_data_read_ch2, pit_data_write_ch2   # Channel 2 data
    db  0x43, 0x00, 0, pit_mode_command_write               # Mode/Command register

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
    db  pit_vm_callback

##########
pit_vm_callback:
.FRAME continue                         # returns continue
    arb -1

    add 1, 0, [rb + continue]

    # Run the timer every N instructions
    jnz [vm_callback_counter], pit_vm_callback_decrement
    add 0x100, 0, [vm_callback_counter]

    call pit_vm_callback_ch0
    call pit_vm_callback_ch2

pit_vm_callback_decrement:
    add [vm_callback_counter], -1, [vm_callback_counter]

    arb 1
    ret 0
.ENDFRAME

##########
pit_mode_command_write:
.FRAME addr, value; value_bits, channel, handler, tmp
    arb -4

    # Split value to components
    mul [rb + value], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + value_bits]

    # Read the channel
    add [rb + value_bits], 7, [ip + 1]
    add [0], 0, [rb + channel]
    mul [rb + channel], 2, [rb + channel]
    add [rb + value_bits], 6, [ip + 1]
    add [0], [rb + channel], [rb + channel]

    add pit_mode_command_write_table, [rb + channel], [ip + 1]
    add [0], 0, [rb + handler]

    add [rb + value], 0, [rb - 1]
    arb -1
    call [rb + handler + 1]

    arb 4
    ret 2

pit_mode_command_write_table:
    db  pit_mode_command_write_ch0
    db  pit_mode_command_write_ch1
    db  pit_mode_command_write_ch2
    db  pit_mode_command_write_read_back
.ENDFRAME

##########
pit_mode_command_write_ch1:
.FRAME
    # Channel 1 is silently ignored
    ret 1
.ENDFRAME

##########
pit_mode_command_write_read_back:
.FRAME
    # Read back is not supported
    add pit_mode_command_write_read_back_error, 0, [rb - 1]
    arb -1
    call report_error

pit_mode_command_write_read_back_error:
    db  "PIT WR: MC Error, read-back ", "command is not supported", 0
.ENDFRAME

##########
vm_callback_counter:
    db  0

.EOF
