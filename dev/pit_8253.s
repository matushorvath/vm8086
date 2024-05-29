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

# Operating modes:
#
# Mode 0:
#  - when mode set: output low, stop
#  - when reload start: output low, stop
#  - when reload done: set value to reload, run (if gate)
#  - when dec from 1 to 0: output high, keep run (if gate)
#
# Mode 1:
#  - when mode set: output high, stop
#  - when reload start: do nothing
#  - when reload done: do nothing
#  - when gate lo->hi: output low, set value to reload, run (if gate)
#  - when dec from 1 to 0: output high, keep run (if gate)
#
# Mode 2:
#  - when mode set: output high, stop
#  - when reload done: if stopped only: set value to reload, run (if gate)
#  - when dec from 2 to 1: output pulse low, set value to reload, keep run (if gate)
#  - when gate hi->lo: output high (which it normally is anyway), stop
#  - when gate lo->hi: set value to reload, run (if gate)
#
# Mode 3, same as mode 2 except:
#  - decrement by 2 instead of 1
#  - mode 2 output change flips a flip-flop, real output comes from the flip-flop
#  - when dec from 2 to 1 -> dec from 2 to 0
#  - when setting value from reload, mask off the 0 bit (not the exact behavior, but close enough)
#    or maybe tweak the condition - when value changes from 2 or 1 (to 0 or -1)
#
# Mode 4:
#  - when mode set: output high, stop
#  - when reload start: stop (not 100% right)
#  - when reload done: set value to reload, run (if gate)
#  - when dec from 1 to 0: output pulse low, keep run (if gate)
#
# Mode 5, same as mode 4 except:
#  - when mode set: output high, stop
#  - when reload start: do nothing
#  - when reload done: do nothing
#  - when dec from 1 to 0: output pulse low, keep run (if gate)
#  - when gate lo->hi: set value to reload, run (if gate)

# TODO
#  - IRQ0 is generated when channel 0 transitions low to high
#  - only run channel 2 if gate is enabled (port 0x63 bit 0)
#  - mode 3 output comes from the flip-flop

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

    # TODO decrement counters

    arb 1
    ret 0
.ENDFRAME

##########

# The order of these variables is important. We use pointer arithmetics to access them, by adding
# channel number to a base pointer. Because of this, each pair of ch0 and ch2 variables needs to
# be exactly 2 bytes apart.
#
# access mode = pit_access + channel
# Channel 0: = pit_access + 0 = pit_access_ch0
# Channel 2: = pit_access + 2 = pit_access_ch2
#
# The order of lo/hi bytes is also important, we use pointer arithmetics with pit_read_hi_byte_next
# to determine whether to access the lo or hi byte of a value.
#
# channel value = pit_value + channel + [pit_read_hi_byte_next + channel]
# Channel 0, access lo: pit_value + 0 + [pit_read_hi_byte_next + 0]
#     = pit_value + [pit_read_hi_byte_next_ch0] = pit_value + 0 = pit_value_lo_ch0
# Channel 0, access hi: pit_value + 0 + [pit_read_hi_byte_next + 0]
#     = pit_value + [pit_read_hi_byte_next_ch0] = pit_value + 1 = pit_value_hi_ch0
# Channel 2, access lo: pit_value + 2 + [pit_read_hi_byte_next + 2]
#     = pit_value + 2 + [pit_read_hi_byte_next_ch2] = pit_value + 2 + 0 = pit_value_lo_ch2
# Channel 2, access hi: pit_value + 0 + [pit_read_hi_byte_next + 2]
#     = pit_value + 2 + [pit_read_hi_byte_next_ch2] = pit_value + 2 + 1 = pit_value_hi_ch2

pit_mode:
pit_mode_ch0:
    db  0
pit_access:
pit_access_ch0:
    db  0
pit_mode_ch2:
    db  0
pit_access_ch2:
    db  0

pit_reload:
pit_reload_lo:
pit_reload_lo_ch0:
    db  0
pit_reload_hi:
pit_reload_hi_ch0:
    db  0
pit_reload_lo_ch2:
    db  0
pit_reload_hi_ch2:
    db  0

pit_value:
pit_value_lo:
pit_value_lo_ch0:
    db  0
pit_value_hi:
pit_value_hi_ch0:
    db  0
pit_value_lo_ch2:
    db  0
pit_value_hi_ch2:
    db  0

pit_latch:
pit_latch_lo:
pit_latch_lo_ch0:
    db  0
pit_latch_hi:
pit_latch_hi_ch0:
    db  0
pit_latch_lo_ch2:
    db  0
pit_latch_hi_ch2:
    db  0

pit_running:
pit_running_ch0:
    db  0
pit_output:
pit_output_ch0:
    db  0
pit_running_ch2:
    db  0
pit_output_ch2:
    db  0

# In 16-bit access mode, is the next byte to be accessed hi or low?
pit_read_hi_byte_next:
pit_read_hi_byte_next_ch0:
    db  0
pit_write_hi_byte_next:
pit_write_hi_byte_next_ch0:
    db  0
pit_read_hi_byte_next_ch2:
    db  0
pit_write_hi_byte_next_ch2:
    db  0

##########
mode_command_write:
.FRAME addr, value; value_bits, channel, mode, access, orig_output, tmp
    arb -6

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

    # Read the access mode
    add [rb + value_bits], 5, [ip + 1]
    add [0], 0, [rb + access]
    mul [rb + access], 2, [rb + access]
    add [rb + value_bits], 4, [ip + 1]
    add [0], [rb + access], [rb + access]

    # Handle latch command
    jz  [rb + access], mode_command_write_latch_command

    # Read the operating mode
    add [rb + value_bits], 3, [ip + 1]
    add [0], 0, [rb + mode]
    mul [rb + mode], 2, [rb + mode]
    add [rb + value_bits], 2, [ip + 1]
    add [0], [rb + mode], [rb + mode]
    mul [rb + mode], 2, [rb + mode]
    add [rb + value_bits], 1, [ip + 1]
    add [0], [rb + mode], [rb + mode]

    # Operations 0b110 and 0b111 are aliases for 0b010 and 0b011
    lt  [rb + mode], 0b110, [rb + tmp]
    jnz [rb + tmp], mode_command_write_after_aliases
    add [rb + mode], -0b100, [rb + mode]

mode_command_write_after_aliases:
    # Reset the channel to initial state, which depends on mode
    add pit_read_hi_byte_next, [rb + channel], [ip + 3]
    add 0, 0, [0]
    add pit_write_hi_byte_next, [rb + channel], [ip + 3]
    add 0, 0, [0]

    # Mode 0: output low, stop; mode >0: output high, stop
    add pit_output, [rb + channel], [ip + 1]
    add [0], 0, [rb + orig_output]
    add pit_output, [rb + channel], [ip + 3]
    lt  0, [rb + mode], [0]
    add pit_running, [rb + channel], [ip + 3]
    add 0, 0, [0]

    # Reset the latch
    add pit_latch_lo, [rb + channel], [ip + 3]
    add -1, 0, [0]
    add pit_latch_hi, [rb + channel], [ip + 3]
    add -1, 0, [0]

    # Save the access mode and operating mode
    add pit_access, [rb + channel], [ip + 3]
    add [rb + access], 0, [0]

    add pit_mode, [rb + channel], [ip + 3]
    add [rb + mode], 0, [0]

    # If output goes hi from lo, trigger INT0 for channel 0
    jnz [rb + channel], mode_command_write_after_int0

    add pit_output, [rb + channel], [ip + 1]
    eq  [0], 0, [rb + tmp]
    add [rb + tmp], [rb + orig_output], [rb + tmp]
    jnz [rb + tmp], mode_command_write_after_int0

    # TODO trigger INT0 here (probably delay after instruction finished?)

mode_command_write_after_int0:

    # Log parsed values
    out ' '
    out 'M'
    out ' '

    add [rb + mode], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 1, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ' '
    out 'A'
    out ' '

    add [rb + access], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 1, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ' '
    out 'C'
    out ' '

    add [rb + channel], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 1, 0, [rb - 3]
    arb -3
    call print_num_radix

    jz  0, mode_command_write_done

mode_command_write_latch_command:
    # Don't re-latch an already latched value
    add pit_value_lo, [rb + channel], [ip + 1]
    eq  [0], -1, [rb + tmp]
    jnz [rb + tmp], mode_command_write_done

    # Latch the current value
    add pit_value_lo, [rb + channel], [ip + 5]
    add pit_latch_lo, [rb + channel], [ip + 3]
    add [0], 0, [0]

    add pit_value_hi, [rb + channel], [ip + 5]
    add pit_latch_hi, [rb + channel], [ip + 3]
    add [0], 0, [0]

mode_command_write_done:
    # Line end after the log
    out 10

    arb 6
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

mode_command_write_message:
    db  "PIT WR: MC ", 0
mode_command_write_bcd_error:
    db  "PIT WR: MC Error, BCD mode is not supported", 0
mode_command_write_read_back_error:
    db  "PIT WR: MC Error, read-back ", "command is not supported", 0
.ENDFRAME

##########
.FRAME addr, value; channel, position, reload_start, reload_stop, mode, tmp
    # Function with multiple entry points

channel_0_write:
    arb -6
    add 0, 0, [rb + channel]
    jz  0, channel_write

channel_2_write:
    arb -6
    add 2, 0, [rb + channel]

channel_write:
    # Log access
    # TODO remove log
    add channel_write_message, 0, [rb - 1]
    arb -1
    call print_str

    out 'C'
    add '0', [rb + channel], [rb + tmp]
    out [rb + tmp]
    out ' '

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    # Decide what to return based on access mode
    add channel_write_table, [pit_access_ch0], [ip + 2]
    jz  0, [0]

channel_write_table:
    db  channel_write_done
    db  channel_write_lo
    db  channel_write_hi
    db  channel_write_lo_hi

channel_write_lo:
    # Write lo byte to the value
    add pit_reload_lo, [rb + channel], [ip + 3]
    add [rb + value], 0, [0]

    add 0, 0, [rb + reload_start]
    add 0, 0, [rb + reload_stop]

    jz  0, channel_write_handle_reload

channel_write_hi:
    # Write hi byte to the value
    add pit_reload_hi, [rb + channel], [ip + 3]
    add [rb + value], 0, [0]

    add 0, 0, [rb + reload_start]
    add 0, 0, [rb + reload_stop]

    jz  0, channel_write_handle_reload

channel_write_lo_hi:
    # Write lo/hi byte to the value
    add pit_write_hi_byte_next, [rb + channel], [ip + 1]
    add [0], [rb + channel], [rb + position]
    eq  [pit_write_hi_byte_next], 0, [pit_write_hi_byte_next]

    add pit_reload, [rb + position], [ip + 3]
    add [rb + value], 0, [0]

    eq  [pit_write_hi_byte_next], 0, [rb + reload_start]
    eq  [pit_write_hi_byte_next], 1, [rb + reload_stop]

channel_write_handle_reload:
    add pit_mode, [rb + channel], [ip + 1]
    add [0], 0, [rb + mode]

    # React to the reload start, if it happened
    jnz [rb + reload_start], channel_write_handle_reload_stop

    # Is it mode 0?
    jnz [rb + mode], channel_write_handle_reload_after_output_low

    # Set output low for mode 0
    add pit_output, [rb + channel], [ip + 3]
    add 0, 0, [0]

channel_write_handle_reload_after_output_low:
    # Is it mode 0 and 4?
    jz  [rb + mode], channel_write_handle_reload_timer
    eq  [rb + mode], 4, [rb + tmp]
    jnz [rb + tmp], channel_write_handle_reload_timer

    jz  0, channel_write_handle_reload_stop

channel_write_handle_reload_timer:
    # Stop the timer for mode 0 and 4
    add pit_running, [rb + channel], [ip + 3]
    add 0, 0, [0]

channel_write_handle_reload_stop:
    # React to the reload stop, if it happened
    jnz [rb + reload_start], channel_write_done

    # Is it mode 0, 4; or stopped in mode 2, 3?
    jz  [rb + mode], channel_write_handle_reload_update_value
    eq  [rb + mode], 4, [rb + tmp]
    jnz [rb + tmp], channel_write_handle_reload_update_value

    add pit_running, [rb + channel], [ip + 1]
    jnz [0], channel_write_done

    eq  [rb + mode], 2, [rb + tmp]
    jnz [rb + tmp], channel_write_handle_reload_update_value
    eq  [rb + mode], 3, [rb + tmp]
    jnz [rb + tmp], channel_write_handle_reload_update_value

    jz  0, channel_write_done

channel_write_handle_reload_update_value:
    # Yes, set reload to value, start the timer
    add pit_reload_lo, [rb + channel], [ip + 5]
    add pit_value_lo, [rb + channel], [ip + 3]
    add [0], 0, [0]

    add pit_reload_hi, [rb + channel], [ip + 5]
    add pit_value_hi, [rb + channel], [ip + 3]
    add [0], 0, [0]

    add pit_running, [rb + channel], [ip + 3]
    add 1, 0, [0]

channel_write_done:
    arb 6
    ret 2

channel_write_message:
    db  "PIT WR: ", 0
.ENDFRAME

##########
.FRAME port; value, channel, position, tmp                  # returns value
    # Function with multiple entry points

channel_0_read:
    arb -4
    add 0, 0, [rb + channel]

    jz  0, channel_read

channel_2_read:
    arb -4
    add 2, 0, [rb + channel]

channel_read:
    # Log access
    # TODO remove log
    add channel_read_message, 0, [rb - 1]
    arb -1
    call print_str

    out 'C'
    add '0', [rb + channel], [rb + tmp]
    out [rb + tmp]

    # Decide what to return based on access mode
    add channel_read_table, [pit_access_ch0], [ip + 2]
    jz  0, [0]

channel_read_table:
    db  channel_read_invalid_mode
    db  channel_read_lo
    db  channel_read_hi
    db  channel_read_lo_hi

channel_read_invalid_mode:
    # This can only happen before the counter is used the first time
    add 0xff, 0, [rb + value]
    jz  0, channel_read_clear_latch

channel_read_lo:
    # Read lo byte from the latch/value
    add pit_latch_lo, [rb + channel], [ip + 1]
    add [0], 0, [rb + value]

    eq  [rb + value], -1, [rb + tmp]
    jz  [rb + tmp], channel_read_clear_latch

    add pit_value_lo, [rb + channel], [ip + 1]
    add [0], 0, [rb + value]

    jz  0, channel_read_done

channel_read_hi:
    # Read hi byte from the latch/value
    add pit_latch_hi, [rb + channel], [ip + 1]
    add [0], 0, [rb + value]

    eq  [rb + value], -1, [rb + tmp]
    jz  [rb + tmp], channel_read_clear_latch

    add pit_value_hi, [rb + channel], [ip + 1]
    add [0], 0, [rb + value]

    jz  0, channel_read_done

channel_read_lo_hi:
    # Read lo/hi byte from the latch/value
    add pit_read_hi_byte_next, [rb + channel], [ip + 1]
    add [0], [rb + channel], [rb + position]
    eq  [pit_read_hi_byte_next], 0, [pit_read_hi_byte_next]

    add pit_latch, [rb + position], [ip + 1]
    add [0], 0, [rb + value]

    eq  [rb + value], -1, [rb + tmp]
    jz  [rb + tmp], channel_read_clear_latch_if_lo_byte_next

    add pit_value, [rb + position], [ip + 1]
    add [0], 0, [rb + value]

    jz  0, channel_read_done

channel_read_clear_latch_if_lo_byte_next:
    # Only reset the latch after reading the hi byte
    jz  [pit_read_hi_byte_next], channel_read_done

channel_read_clear_latch:
    add pit_latch_lo, [rb + channel], [ip + 3]
    add -1, 0, [rb + value]
    add pit_latch_hi, [rb + channel], [ip + 3]
    add -1, 0, [rb + value]

channel_read_done:
    # Finish the log message
    out ' '

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    arb 4
    ret 1

channel_read_message:
    db  "PIT RD: ", 0
.ENDFRAME

.EOF

# TODO
#
# Mode 0:
#  - when dec from 1 to 0: output high, keep run (if gate)
#
# Mode 1:
#  - when gate lo->hi: output low, set value to reload, run (if gate)
#  - when dec from 1 to 0: output high, keep run (if gate)
#
# Mode 2:
#  - when dec from 2 to 1: output pulse low, set value to reload, keep run (if gate)
#  - when gate hi->lo: output high (which it normally is anyway), stop
#  - when gate lo->hi: set value to reload, run (if gate)
#
# Mode 3, same as mode 2 except:
#  - decrement by 2 instead of 1
#  - when dec from 2 to 1 -> dec from 2 to 0
#  - when setting value from reload, handle odd/even by checking when value changes from 2 or 1 (to 0 or -1)
#  - mode 2 output changes a flip-flop, real mode 3 output comes from the flip-flop
#
# Mode 4:
#  - when dec from 1 to 0: output pulse low, keep run (if gate)
#
# Mode 5, same as mode 4 except:
#  - when dec from 1 to 0: output pulse low, keep run (if gate)
#  - when gate lo->hi: set value to reload, run (if gate)
