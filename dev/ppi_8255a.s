.EXPORT init_ppi_8255a
.EXPORT ppi_a
.EXPORT speaker_activity_callback

# From the config file
.IMPORT config_log_ppi
.IMPORT config_boot_80x25

# From pit_8253_ch2.s
.IMPORT pit_set_gate_ch2
.IMPORT pit_gate_ch2
.IMPORT pit_output_ch2

# From ppi_8255a_log.s
.IMPORT ppi_mode_write_log
.IMPORT ppi_mode_read_log
.IMPORT ppi_port_a_read_log
.IMPORT ppi_port_b_read_log
.IMPORT ppi_port_b_write_log
.IMPORT ppi_port_c_read_log

# From cpu/ports.s
.IMPORT register_ports

# From util/bits.s
.IMPORT bit_0
.IMPORT bit_1
.IMPORT bit_2
.IMPORT bit_3
.IMPORT bit_4
.IMPORT bit_5
.IMPORT bit_6
.IMPORT bit_7

# From util/error.s
.IMPORT report_error

# PC Speaker
# - bit 0 port 0x61: write, 1 = speaker is controlled by PIT channel 2
#                    (controls 8253 gate input for channel 2 only)
# - bit 1 port 0x61: write, controls speaker directly
# - bit 5 port 0x61: read, output of PIT channel 2

# See IBM_5155_5160_Technical_Reference_6280089_MAR86.pdf, page 1-27

##########
ppi_ports:
    db  0x60, 0x00, ppi_port_a_read, 0                      # Keyboard scan code/switch settings
    db  0x61, 0x00, ppi_port_b_read, ppi_port_b_write       # Misc output bits
    db  0x62, 0x00, ppi_port_c_read, 0                      # Misc input bits
    db  0x63, 0x00, ppi_mode_read, ppi_mode_write           # Command/mode register

    db  -1, -1, -1, -1

##########
init_ppi_8255a:
.FRAME floppy_count;
    # Register I/O ports
    add ppi_ports, 0, [rb - 1]
    arb -1
    call register_ports

    # Prepare floppy drive count in the format used by port C
    # bits 2 and 3: floppy drive count - 1
    add [rb + floppy_count], -1, [ppi_port_c_floppy_bits]
    mul [ppi_port_c_floppy_bits], 4, [ppi_port_c_floppy_bits]

    ret 1
.ENDFRAME

##########
ppi_mode_write:
.FRAME addr, value; tmp
    arb -1

    # PPI logging
    jz  [config_log_ppi], .after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call ppi_mode_write_log

.after_log:
    # The only supported value is 0x10011001
    # However, Phoenix BIOS briefly sets mode to 0x10001001, so we also allow that
    eq  [rb + value], 0b10011001, [rb + tmp]
    jnz [rb + tmp], .done
    eq  [rb + value], 0b10001001, [rb + tmp]
    jnz [rb + tmp], .done

    add .error, 0, [rb - 1]
    arb -1
    call report_error

.done:
    arb 1
    ret 2

.error:
    db  "PPI WR: MC Error, requested mode is not supported", 0
.ENDFRAME

##########
ppi_mode_read:
.FRAME addr; value
    arb -1

    # We only support one value
    add  0b10011001, 0, [rb + value]

    # PPI logging
    jz  [config_log_ppi], .after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call ppi_mode_read_log

.after_log:
    arb 1
    ret 1
.ENDFRAME

##########
ppi_port_a_read:
.FRAME addr; value
    arb -1

    # Return port A value, the keyboard character buffer
    add [ppi_a], 0, [rb + value]

    # PPI logging
    jz  [config_log_ppi], .after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call ppi_port_a_read_log

.after_log:
    arb 1
    ret 1
.ENDFRAME

##########
ppi_port_b_read:
.FRAME addr; value
    arb -1

    # Return the port B value
    add [ppi_b], 0, [rb + value]

    # PPI logging
    jz  [config_log_ppi], .after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call ppi_port_b_read_log

.after_log:
    arb 1
    ret 1
.ENDFRAME

##########
ppi_port_b_write:
.FRAME addr, value;
    # Supported bits:
    # 0: 8253 channel 2 gate
    # 1: control the PC speaker
    # 3: read high switches/low switches
    # 7: clear keyboard

    # PPI logging
    jz  [config_log_ppi], .after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call ppi_port_b_write_log

.after_log:
    # Save the value, so we can return it when reading port B
    # TODO this is probably not the correct value to read from port B
    add [rb + value], 0, [ppi_b]

    # Set/reset PIT channel 2 gate
    add bit_0, [rb + value], [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call pit_set_gate_ch2

    # Set speaker active if bit 1 is set
    jz  [speaker_activity_callback], .after_speaker
    add bit_1, [rb + value], [ip + 1]
    jz  [0], .after_speaker

    call [speaker_activity_callback]

.after_speaker:
    # Save the "read high switches" flag
    add bit_3, [rb + value], [ip + 1]
    add [0], 0, [ppi_read_high_switches]

    # Clear the keyboard buffer if requested
    add bit_7, [rb + value], [ip + 1]
    jz  [0], .after_clear_keyboard
    add 0, 0, [ppi_a]

.after_clear_keyboard:
    ret 2
.ENDFRAME

##########
ppi_port_c_read:
.FRAME addr; value
    arb -1

    # Upper four bits don't depend on ppi_read_high_switches
    mul [pit_output_ch2], 0b00100000, [rb + value]

    jnz [ppi_read_high_switches], .high_switches

    # 0   : loop on post: 0 - no
    # 1   : coprocessor installed: 0 - no
    # 2, 3: RAM size: 11 - 640kB
    add [rb + value], 0b00001100, [rb + value]

    jz  0, .done

.high_switches:
    # bits 0, 1: display: 01 - color 40x25, 10 - color 80x25
    add [rb + value], 0b00000001, [rb + value]
    add [rb + value], [config_boot_80x25], [rb + value]

    # bits 2, 3: number of drives minus 1
    add [rb + value], [ppi_port_c_floppy_bits], [rb + value]

.done:
    # PPI logging
    jz  [config_log_ppi], .after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call ppi_port_c_read_log

.after_log:
    arb 1
    ret 1
.ENDFRAME

##########
ppi_a:
    db  0
ppi_b:
    db  0

ppi_read_high_switches:
    db  0

ppi_port_c_floppy_bits:
    db  0

speaker_activity_callback:
    db  0

.EOF
