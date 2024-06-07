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
    out 'D' # TODO remove
    out 'w'
    out ' '

    # Is the FDC in the middle of processing a command?
    jz  [fdc_command_state], fdc_data_write_idle

    # Yes, is this the command phase?
    jnz [fdc_result_phase], fdc_data_write_invalid

    # Yes, use the state as a label to jump to
    jz  0, [fdc_command_state]

fdc_data_write_idle:
    # Accept a new command

    # MT MF SK 0 0 1 1 0: cmd = read_data; save MT MF SK; -> _hd_us
    # MT MF SK 0 1 1 0 0: cmd = read_deleted_data; save MT MF SK; -> _hd_us
    # MT MF  0 0 0 1 0 1: cmd = write_data; save MT MF; -> _hd_us
    # MT MF  0 0 1 0 0 1: cmd = write_deleted_data; save MT MF; -> _hd_us
    #  0 MF SK 0 0 0 1 0: cmd = read_track; save MF SK; -> _hd_us
    #  0 MF  0 0 1 0 1 0: cmd = read_id; save MF; -> _hd_us
    #  0 MF  0 0 1 1 0 0: cmd = format_track; save MF; -> _hd_us
    # MT MF SK 1 0 0 0 1: cmd = scan_equal; save MT MF SK; -> _hd_us
    # MT MF SK 1 1 0 0 1: cmd = scan_low_or_equal; save MT MF SK; -> _hd_us
    # MT MF SK 1 1 1 0 1: cmd = scan_high_or_equal; save MT MF SK; -> _hd_us
    #  0  0  0 0 0 1 1 1: cmd = recalibrate; -> _hd_us
    #  0  0  0 0 1 0 0 0: cmd = sense_interrupt_status; -> execute, _st0 (or separate satus for SIS)
    #  0  0  0 0 0 0 1 1: cmd = specify; -> _specify_srt_hut
    #  0  0  0 0 0 0 1 1: cmd = sense_driver_status; -> _hd_us
    #  0  0  0 0 1 1 1 1: cmd = seek; -> _hd_us
    # other             : cmd = invalid; -> _hd_us

_hd_us
    # X X X X X HD US1 US0: save head (HD), save drive (US0);
        -> _c (default); execute,
        execute, -> _st0 (cmd=read_id);
        -> _n (cmd=format_track);
        execute, -> idle (cmd=recalibrate)
        execute, -> _st3 (cmd=sense_driver_status)
        execute, -> _ncn (cmd=seek)
        execute, -> _st0 (cmd=invalid)

_c
    # C: save cylinder (C); -> _h

_h
    # H: verify that H === HD (from first byte); -> _r

_r
    # R: save sector (record, R); -> _n

_n
    # N: save number of bytes in sector (?) perhaps size to read/write?; -> _eot (default); _sc (cmd=format_track, or separate state for format?)

_eot
    # EOT: end of track, final sector number on a cylinder (does it need saving?); -> _gpl

_gpl
    # GPL: gap 3 length (spacing between sectors) perhaps just verify it is correct?; -> _dtl (default); _d (cmd=format_track or separate state for format)

_dtl
    # DTL data length; if N is 0, DTL is the length to read/write to a sector (save/verify with N); result phase = 1, execute, -> _st0

_sc
    # SC: number of sectors per cylinder; -> _gpl (or separate state for format?)

_d
    # D: data pattern to be written to a sector; execute, -> _st0

_specify_srt_hut
    # SRT 4b, HUT 4b: read -> _specify_hlt_nd

_specify_hlt_nd
    # HLT 7b ND 1b: read -> idle

_ncn
    # NCN: -> idle

fdc_data_write_invalid:
    # in: X X X X X HD US1 US0
    # out ST0

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

_st0
    # read ST0 -> _st1 (default); idle (cmd=invalid); _pcn (cmd=sense_interrupt_status)

_st1
    # read ST1 -> _c (cmd=read_data, read_deleted_data); -> _st2 (default)

_st2
    # read ST2 -> _c

_c
    # read C -> _h

_h
    # read H -> _r

_r
    # read R (sector) -> _n

_n
    # read N (number of bytes) -> idle

_pcn
    # read PCN (present cylinder number) position of the head -> idle

_st3
    # read ST3 -> idle

    arb 1
    ret 1
.ENDFRAME

##########
fdc_control_write:
.FRAME addr, value;
    # TODO this is I think used to detect floppy type
    # if yes, we need to return errors (when reading?) unless the speed is set correctly

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

fdc_command_state:
    db  0

.EOF
