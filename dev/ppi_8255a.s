.EXPORT init_ppi_8255a

# From devices.s
.IMPORT register_ports

# From error.s
.IMPORT report_error

# From obj/bits.s
.IMPORT bits

# From pit_8253_ch2.s
.IMPORT pit_set_gate_ch2
.IMPORT pit_gate_ch2
.IMPORT pit_output_ch2

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
    jnz [rb + tmp], ppi_mode_write_done

    add ppi_mode_write_error, 0, [rb - 1]
    arb -1
    call report_error

ppi_mode_write_done:
    arb 1
    ret 2

ppi_mode_write_error:
    db  "PPI WR: MC Error,", " requested mode is not supported", 0
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
.FRAME addr, value; value_bits
    arb -1

    # Supported bits:
    # 0: 8253 channel 2 gate
    # 3: read high switches/low switches

    add bits, [rb + value], [rb + value_bits]

    # Set/reset PIT channel 2 gate
    add [rb + value_bits], 0, [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call pit_set_gate_ch2

    # Save the "read high switches" flag
    add [rb + value_bits], 3, [ip + 1]
    add [0], 0, [ppi_read_high_switches]

    # Save the other bits so we can return them later
    add [rb + value_bits], 1, [ip + 1]
    add [0], 0, [ppi_b_bit_1]
    add [rb + value_bits], 2, [ip + 1]
    add [0], 0, [ppi_b_bit_2]
    add [rb + value_bits], 4, [ip + 1]
    add [0], 0, [ppi_b_bit_4]
    add [rb + value_bits], 5, [ip + 1]
    add [0], 0, [ppi_b_bit_5]
    add [rb + value_bits], 6, [ip + 1]
    add [0], 0, [ppi_b_bit_6]
    add [rb + value_bits], 7, [ip + 1]
    add [0], 0, [ppi_b_bit_7]

    arb 1
    ret 2
.ENDFRAME

##########
ppi_port_c_read:
.FRAME addr; value
    arb -1

    # Upper four bits don't depend on ppi_read_high_switches
    mul [pit_output_ch2], 0b00100000, [rb + value]

    jz  [ppi_read_high_switches], ppi_port_c_read_high_switches

    # 0   : loop on post - 0 no
    # 1   : coprocessor installed - 0 no
    # 2, 3: RAM size - 11 640kB
    add [rb + value], 0b00001100, [rb + value]

    jz  0, ppi_port_c_read_done

ppi_port_c_read_high_switches:

    # 0, 1: Display - 10 color 80x25
    # 2, 3: Number of drives - 00 1 drive
    add [rb + value], 0b00000010, [rb + value]

ppi_port_c_read_done:
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

.EOF
