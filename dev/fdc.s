.EXPORT init_fdc

# From cpu/devices.s
.IMPORT register_ports

# From cpu/error.s
.IMPORT report_error

# From cpu/interrupt.s
.IMPORT interrupt

# From util/bits.s
.IMPORT bits

##########
fdc_ports:
    db  0xf2, 0x03, 0, fdc_dor_write                        # Digital Output Register
    db  0xf4, 0x03, fdc_status_read, 0                      # Main Status Register
    db  0xf5, 0x03, fdc_data_read, fdc_data_write           # Diskette Data Register
    db  0xf7, 0x03, fdc_dir_read, fdc_control_write         # Digital Input Register/Diskette Control Register

    db  -1, -1, -1, -1

##########
init_fdc:
.FRAME
    # Register I/O ports
    add fdc_ports, 0, [rb - 1]
    arb -1
    call register_ports

    ret 0
.ENDFRAME

##########
fdc_dor_write:
.FRAME addr, value; value_bits, tmp
    arb -2

    out 'A' # TODO remove
    out ' '

    # Convert value to bits
    mul [rb + value], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + value_bits]

    # Save the original fdc_dor_reset value before changing it
    eq  [fdc_dor_reset], 0, [rb + tmp]
    add [rb + value_bits], 2, [ip + 1]
    add [0], 0, [fdc_dor_reset]
    add [fdc_dor_reset], [rb + tmp], [rb + tmp]

    # If fdc_dor_reset was low and now is high, reset the floppy controller
    eq  [rb + tmp], 2, [rb + tmp]
    jz  [rb + tmp], fdc_dor_write_after_reset
    call fdc_d765ac_reset

fdc_dor_write_after_reset:
    # Save the other bits
    add [rb + value_bits], 0, [ip + 1]
    add [0], 0, [fdc_dor_drive_a_select]

    add [rb + value_bits], 3, [ip + 1]
    add [0], 0, [fdc_dor_enable_dma]

    add [rb + value_bits], 4, [ip + 1]
    add [0], 0, [fdc_dor_enable_motor_a]

    add [rb + value_bits], 5, [ip + 1]
    add [0], 0, [fdc_dor_enable_motor_b]

    arb 2
    ret 2
.ENDFRAME

##########
fdc_status_read:
.FRAME addr; value
    arb -1

    out 'S' # TODO remove
    out ' '

    # Following bits have fixed values, since seeking, reading and writing is immediate,
    # we only support DMA mode, and the FDC is always ready:
    # Bit 0 DAB - FDD A is busy seeking
    # Bit 1 DBB - FDD B is busy seeking
    # Bit 2 reserved
    # Bit 3 reserved
    # Bit 4 CB  - Controller is busy reading or writing
    # Bit 5 NDM - non-DMA mode
    # Bit 7 RQM - data register is ready for data transfer

    # Data transfer direction is CPU to FDC in command phase, FDC to CPU in result phase
    # Bit 6 DIO - data input/output, 0 - from CPU to FDC, 1 - from FDC to CPU

    mul [fdc_result_phase], 0b01000000, [rb + value]
    add [rb + value], 0b10000000, [rb + value]

    arb 1
    ret 1
.ENDFRAME

##########
fdc_data_write:
.FRAME addr, value;
    # TODO

    out 'D' # TODO remove
    out 'w'
    out ' '

    ret 2
.ENDFRAME

##########
fdc_data_read:
.FRAME addr; value
    arb -1

    # TODO

    out 'D' # TODO remove
    out 'r'
    out ' '

    arb 1
    ret 1
.ENDFRAME

##########
fdc_control_write:
.FRAME addr, value;
    # TODO

    out 'C' # TODO remove
    out ' '

    # Bits 7-2 Reserved
    # Bits 2-0 Diskette Data Rate (00 500000, 01 300000, 10 250000, 11 125000)

    ret 2
.ENDFRAME

##########
fdc_dir_read:
.FRAME addr; value
    arb -1

    # The only bit related to floppy operation is bit 7 - diskette change
    # We don't support changing the diskette, so return all zeros
    add 0, 0, [rb + value]

    arb 1
    ret 1
.ENDFRAME

##########
fdc_d765ac_reset:
.FRAME
    # TODO reset D765AC registers to zero, but don't touch the DOR,
    # also don't touch SRT HUT HLT in Specify command

    # Raise INT 0e = IRQ6 if the FDD is ready, which we assume it always is
    # TODO if the motor is off, is the FDD ready?
    add 0x0e, 0, [rb - 1]
    arb -1
    call interrupt

    out 'I' # TODO remove
    out ' '

    ret 0
.ENDFRAME

##########
fdc_dor_drive_a_select:                 # 0 = drive A selected, 1 = drive B selected
    db  0
fdc_dor_reset:                          # 0 = reset
    db  0
fdc_dor_enable_dma:
    db  0
fdc_dor_enable_motor_a:
    db  0
fdc_dor_enable_motor_b:
    db  0

fdc_result_phase:
    db  0

.EOF
