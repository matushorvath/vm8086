.EXPORT init_fdc

# From devices.s
.IMPORT register_ports

# From error.s
.IMPORT report_error

# From obj/bits.s
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

    # Convert value to bits
    mul [rb + value], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + value_bits]

    # Store individual bits
    add [rb + value_bits], 0, [ip + 1]
    add [0], 0, [fdc_drive_a_select]

    # TODO we should probably perform a reset, not store the value, also reset is probably active low
    add [rb + value_bits], 2, [ip + 1]
    add [0], 0, [fdc_reset]

    add [rb + value_bits], 3, [ip + 1]
    add [0], 0, [fdc_enable_dma]

    add [rb + value_bits], 4, [ip + 1]
    add [0], 0, [fdc_enable_motor_a]

    add [rb + value_bits], 5, [ip + 1]
    add [0], 0, [fdc_enable_motor_b]

    # TODO "A channel reset clears all bits." in the manual, find out what they mean

    arb 2
    ret 2
.ENDFRAME

##########
fdc_status_read:
.FRAME addr; value
    arb -1

    # TODO

    # Bit 7 Request for Master (RQM)- The data register is ready to send or receive data to or from the processor.
    # Bit 6 Data Input/Output (DIO)-The direction of data transfer between the diskette controller and the processor.
    #       If this bit is aI, transfer is from the diskette controller's data register to the processor; if it is a 0, the opposite is true.
    # Bit 5 Non-DMA Mode (NDM)-The diskette controller is in the non-DMA mode.
    # Bit 4 Diskette Controller Busy (CB)- A Read or Write command is being executed.
    # Bit 3 Reserved
    # Bit 2 Reserved
    # Bit 1 Diskette Drive B Busy (DBB)- Diskette drive B is in the seek mode.
    # Bit 0 Diskette Drive A Busy (DAB)- Diskette drive A is in the seek mode.

    arb 1
    ret 1
.ENDFRAME

##########
fdc_data_write:
.FRAME addr, value;
    # TODO

    ret 2
.ENDFRAME

##########
fdc_data_read:
.FRAME addr; value
    arb -1

    # TODO

    arb 1
    ret 1
.ENDFRAME

##########
fdc_control_write:
.FRAME addr, value;
    # TODO

    # Bits 7-2 Reserved
    # Bits 2-0 Diskette Data Rate (00 500000, 01 300000, 10 250000, 11 125000)

    ret 2
.ENDFRAME

##########
fdc_dir_read:
.FRAME addr; value
    arb -1

    # TODO

    # Bit 7 Diskette Change
    # Rest of bits applies to fixed disks only

    arb 1
    ret 1
.ENDFRAME

##########
fdc_drive_a_select:
    db  0
fdc_reset:
    db  0
fdc_enable_dma:
    db  0
fdc_enable_motor_a:
    db  0
fdc_enable_motor_b:
    db  0

.EOF
