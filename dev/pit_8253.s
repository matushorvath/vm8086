.EXPORT init_pit_8253

# From cpu/ports.s
.IMPORT register_ports

# From util/error.s
.IMPORT report_error

# From util/bits.s
.IMPORT bit_6
.IMPORT bit_7

# From pit_8253_ch0.s
.IMPORT pit_data_read_ch0
.IMPORT pit_data_write_ch0
.IMPORT pit_mode_command_write_ch0

# From pit_8253_ch2.s
.IMPORT pit_data_read_ch2
.IMPORT pit_data_write_ch2
.IMPORT pit_mode_command_write_ch2

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
# This is what more recent computers do anyway.
#
# Channel 2:
#  - mode: B6h - 10 11 011 0: lo+hi byte, mode 3
#    data: out pic_freq/400, pic_freq/554, pic_freq/277, pic_freq/370
#              pic_freq/277, pic_freq/415, 1193 (= ~1000Hz)
#    pic_freq = 1193182

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
pit_mode_command_write:
.FRAME addr, value; channel, handler, tmp
    arb -3

    # Read the channel
    add bit_7, [rb + value], [ip + 1]
    add [0], 0, [rb + channel]
    mul [rb + channel], 2, [rb + channel]
    add bit_6, [rb + value], [ip + 1]
    add [0], [rb + channel], [rb + channel]

    add .table, [rb + channel], [ip + 1]
    add [0], 0, [rb + handler]

    add [rb + value], 0, [rb - 1]
    arb -1
    call [rb + handler + 1]

    arb 3
    ret 2

.table:
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
    add .read_back_error, 0, [rb - 1]
    arb -1
    call report_error

.read_back_error:
    db  "PIT WR: MC Error, read-back command is not supported", 0
.ENDFRAME

.EOF
