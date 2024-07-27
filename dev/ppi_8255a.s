.EXPORT init_ppi_8255a
.EXPORT speaker_activity_callback

# From cpu/ports.s
.IMPORT register_ports

# From cpu/error.s
.IMPORT report_error

# From util/bits.s
.IMPORT bit_0
.IMPORT bit_1
.IMPORT bit_2
.IMPORT bit_3
.IMPORT bit_4
.IMPORT bit_5
.IMPORT bit_6
.IMPORT bit_7

# From the config file
.IMPORT config_boot_80x25

# From pit_8253_ch2.s
.IMPORT pit_set_gate_ch2
.IMPORT pit_gate_ch2
.IMPORT pit_output_ch2

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
.FRAME
    # Register I/O ports
    add ppi_ports, 0, [rb - 1]
    arb -1
    call register_ports

    ret 0
.ENDFRAME

##########
ppi_mode_write:
.FRAME addr, value; tmp
    arb -1

    # We only support one value
    eq  [rb + value], 0b10011001, [rb + tmp]
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

    arb 1
    ret 1
.ENDFRAME

##########
ppi_port_a_read:
.FRAME addr; value
    arb -1

    # TODO keyboard support
    add  0xff, 0, [rb + value]

    arb 1
    ret 1
.ENDFRAME

##########
ppi_port_b_read:
.FRAME addr; value
    arb -1

    # Build the value from bits
    mul [ppi_b_bit_7], 2, [rb + value]
    add [rb + value], [ppi_b_bit_6], [rb + value]
    mul [rb + value], 2, [rb + value]
    add [rb + value], [ppi_b_bit_5], [rb + value]
    mul [rb + value], 2, [rb + value]
    add [rb + value], [ppi_b_bit_4], [rb + value]
    mul [rb + value], 2, [rb + value]
    add [rb + value], [ppi_read_high_switches], [rb + value]
    mul [rb + value], 2, [rb + value]
    add [rb + value], [ppi_b_bit_2], [rb + value]
    mul [rb + value], 2, [rb + value]
    add [rb + value], [ppi_b_bit_1], [rb + value]
    mul [rb + value], 2, [rb + value]
    add [rb + value], [pit_gate_ch2], [rb + value]

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

    # Save the other bits so we can return them later
    # TODO probably these are not the correct values to read from port b
    add bit_1, [rb + value], [ip + 1]
    add [0], 0, [ppi_b_bit_1]
    add bit_2, [rb + value], [ip + 1]
    add [0], 0, [ppi_b_bit_2]
    add bit_4, [rb + value], [ip + 1]
    add [0], 0, [ppi_b_bit_4]
    add bit_5, [rb + value], [ip + 1]
    add [0], 0, [ppi_b_bit_5]
    add bit_6, [rb + value], [ip + 1]
    add [0], 0, [ppi_b_bit_6]
    add bit_7, [rb + value], [ip + 1]
    add [0], 0, [ppi_b_bit_7]

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
    # 0, 1: display: 01 - color 40x25, 10 - color 80x25
    # 2, 3: number of drives: 00 - 1 drive
    add [rb + value], 0b00000001, [rb + value]
    add [rb + value], [config_boot_80x25], [rb + value]

.done:
    arb 1
    ret 1
.ENDFRAME

##########
ppi_read_high_switches:
    db  0

ppi_b_bit_1:
    db  0
ppi_b_bit_2:
    db  0
ppi_b_bit_4:
    db  0
ppi_b_bit_5:
    db  0
ppi_b_bit_6:
    db  0
ppi_b_bit_7:
    db  0

speaker_activity_callback:
    db  0

.EOF
