.EXPORT init_fdc

# From cpu/devices.s
.IMPORT register_ports

# From cpu/error.s
.IMPORT report_error

# From cpu/interrupt.s
.IMPORT interrupt

# From util/bits.s
.IMPORT bits

# From util/nibbles.s
.IMPORT nibbles

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

    mul [fdc_cmd_result_phase], 0b01000000, [rb + value]
    add [rb + value], 0b10000000, [rb + value]

    arb 1
    ret 1
.ENDFRAME

##########
fdc_data_write:
.FRAME addr, value; value_bits, value_x8, tmp
    arb -X

    out 'D' # TODO remove
    out 'w'
    out ' '

    # Is the FDC in the middle of processing a command?
    jz  [fdc_cmd_state], fdc_data_write_idle

    # Yes, is this the command phase?
    jnz [fdc_cmd_result_phase], fdc_data_write_invalid

    # Yes, use the state as a label to jump to
    jz  0, [fdc_cmd_state]

fdc_data_write_idle:
    # Parse the first byte of a new command
    # MT MF SK CMD_CODE(5)
    mul [rb + value], 8, [rb + value_x8]

    # Save MT, MF, SK
    add value_bits + 7, [rb + value_x8], [ip + 1]
    add [0], 0, [fdc_cmd_multi_track] # TODO execute multitrack operation

    add value_bits + 6, [rb + value_x8], [ip + 1]
    add [0], 0, [fdc_cmd_mfm] # TODO validate that FM/MFM encoding matches the disk

    add value_bits + 5, [rb + value_x8], [ip + 1]
    add [0], 0, [fdc_cmd_skip_deleted] # TODO execute support for skip deleted data

    # Read bottom 5 bits as the command code
    add value_bits + 4, [rb + value_x8], [ip + 1]
    mul [0], 0b00010000, [fdc_cmd_code]

    mul [rb + value], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], [fdc_cmd_code], [fdc_cmd_code]

    # We are now in command phase
    add 0, 0, [fdc_cmd_result_phase]

    # Handle the state transition
    add fdc_data_write_idle_table, [fdc_cmd_code], [ip + 2]
    jz  0, [0]

fdc_data_write_idle_table:
    db  fdc_data_write_invalid                              #          00000
    db  fdc_data_write_invalid                              #          00001
    db  fdc_data_write_idle_to_hd_us                        #  0 MF SK 00010: read_track
    db  fdc_data_write_idle_to_srt_hut                      #  0  0  0 00011: specify
    db  fdc_data_write_idle_to_hd_us                        #  0  0  0 00100: sense_drive_status
    db  fdc_data_write_idle_to_hd_us                        # MT MF  0 00101: write_data
    db  fdc_data_write_idle_to_hd_us                        # MT MF SK 00110: read_data
    db  fdc_data_write_idle_to_hd_us                        #  0  0  0 00111: recalibrate
    db  fdc_data_write_exec_sense_interrupt_status          #  0  0  0 01000: sense_interrupt_status
    db  fdc_data_write_idle_to_hd_us                        # MT MF  0 01001: write_deleted_data
    db  fdc_data_write_idle_to_hd_us                        #  0 MF  0 01010: read_id
    db  fdc_data_write_invalid                              #          01011
    db  fdc_data_write_idle_to_hd_us                        # MT MF SK 01100: read_deleted_data
    db  fdc_data_write_idle_to_hd_us                        #  0 MF  0 01101: format_track
    db  fdc_data_write_invalid                              #          01110
    db  fdc_data_write_idle_to_hd_us                        #  0  0  0 01111: seek
    db  fdc_data_write_invalid                              #          10000
    db  fdc_data_write_idle_to_hd_us                        # MT MF SK 10001: scan_equal
    db  fdc_data_write_invalid                              #          10010
    db  fdc_data_write_invalid                              #          10011
    db  fdc_data_write_invalid                              #          10100
    db  fdc_data_write_invalid                              #          10101
    db  fdc_data_write_invalid                              #          10110
    db  fdc_data_write_invalid                              #          10111
    db  fdc_data_write_invalid                              #          11000
    db  fdc_data_write_idle_to_hd_us                        # MT MF SK 11001: scan_low_or_equal
    db  fdc_data_write_invalid                              #          11010
    db  fdc_data_write_invalid                              #          11011
    db  fdc_data_write_invalid                              #          11100
    db  fdc_data_write_idle_to_hd_us                        # MT MF SK 11101: scan_high_or_equal
    db  fdc_data_write_invalid                              #          11110
    db  fdc_data_write_invalid                              #          11111

fdc_data_write_idle_to_hd_us:
    # Next state is write HD US
    add fdc_data_write_hd_us, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_idle_to_srt_hut:
    # Next state is write SRT HUT
    add fdc_data_write_srt_hut, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_exec_sense_interrupt_status:
    # Execute sense interrupt status, next state is read ST0
    # Bits 5, 6, 7 have already been set up by previous seek or recalibrate command
    add 1, 0, [fdc_cmd_result_phase]
    add fdc_data_read_st0, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_hd_us:
    # Parse head and unit select information
    # X X X X X HD US(2)

    mul [rb + value], 8, [rb + value_x8]

    # Save HD and US
    add value_bits + 2, [rb + value_x8], [ip + 1]
    add [0], 0, [fdc_cmd_head]

    add value_bits + 1, [rb + value_x8], [ip + 1]
    mul [0], 0x00000010, [fdc_cmd_unit_select]
    add value_bits + 0, [rb + value_x8], [ip + 1]
    add [0], [fdc_cmd_unit_select], [fdc_cmd_unit_select]

    # Handle the state transition
    add fdc_data_write_hd_us_table, [fdc_cmd_code], [ip + 2]
    jz  0, [0]

fdc_data_write_hd_us_table:
    db  fdc_data_write_invalid                              # 00000
    db  fdc_data_write_invalid                              # 00001
    db  fdc_data_write_hd_us_to_c                           # 00010: read_track
    db  fdc_data_write_invalid                              # 00011: specify
    db  fdc_data_write_exec_sense_drive_status              # 00100: sense_drive_status
    db  fdc_data_write_hd_us_to_c                           # 00101: write_data
    db  fdc_data_write_hd_us_to_c                           # 00110: read_data
    db  fdc_data_write_exec_recalibrate                     # 00111: recalibrate
    db  fdc_data_write_invalid                              # 01000: sense_interrupt_status
    db  fdc_data_write_hd_us_to_c                           # 01001: write_deleted_data
    db  fdc_data_write_exec_read_id                         # 01010: read_id
    db  fdc_data_write_invalid                              # 01011
    db  fdc_data_write_hd_us_to_c                           # 01100: read_deleted_data
    db  fdc_data_write_hd_us_to_n                           # 01101: format_track
    db  fdc_data_write_invalid                              # 01110
    db  fdc_data_write_hd_us_to_ncn                         # 01111: seek
    db  fdc_data_write_invalid                              # 10000
    db  fdc_data_write_hd_us_to_c                           # 10001: scan_equal
    db  fdc_data_write_invalid                              # 10010
    db  fdc_data_write_invalid                              # 10011
    db  fdc_data_write_invalid                              # 10100
    db  fdc_data_write_invalid                              # 10101
    db  fdc_data_write_invalid                              # 10110
    db  fdc_data_write_invalid                              # 10111
    db  fdc_data_write_invalid                              # 11000
    db  fdc_data_write_hd_us_to_c                           # 11001: scan_low_or_equal
    db  fdc_data_write_invalid                              # 11010
    db  fdc_data_write_invalid                              # 11011
    db  fdc_data_write_invalid                              # 11100
    db  fdc_data_write_hd_us_to_c                           # 11101: scan_high_or_equal
    db  fdc_data_write_invalid                              # 11110
    db  fdc_data_write_invalid                              # 11111

fdc_data_write_hd_us_to_c:
    # Next state is write C
    add fdc_data_write_c, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_exec_read_id:
    # Execute read id
    # TODO

    # Next state is read ST0
    add 1, 0, [fdc_cmd_result_phase]
    add fdc_data_read_st0, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_hd_us_to_n:
    # Next state is write N
    add fdc_data_write_n, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_exec_recalibrate:
    # Execute recalibrate
    # TODO

    # Next state is idle
    add 0, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_exec_sense_drive_status:
    # Execute sense drive status
    # TODO

    # Next state is read ST3
    add 1, 0, [fdc_cmd_result_phase]
    add fdc_data_read_st3, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done

fdc_data_write_hd_us_to_ncn:
    # Next state is write NCN
    add fdc_data_write_ncn, 0, [fdc_cmd_state]
    jz  0, fdc_data_write_done



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
    # Whatever was received is discarded, return status of 0x80
    add 0x80, 0, [fdc_cmd_st0]

    # Current command code is invalid, next state is read ST0
    add 0, 0, [fdc_cmd_code]
    add 1, 0, [fdc_cmd_result_phase]
    add fdc_data_read_st0, 0, [fdc_cmd_state]

fdc_data_write_done:
    ret 2
.ENDFRAME

    # TODO after the execution phase, interrupt will occur

##########
fdc_data_read:
.FRAME addr; value
    arb -1

    # TODO

    out 'D' # TODO remove
    out 'r'
    out ' '

_st0
    # read ST0 -> _st1 (default); idle (cmd=invalid; docs say ST0 = 80); _pcn (cmd=sense_interrupt_status)

_st1
    # read ST1 -> _st2

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

fdc_cmd_result_phase:
    db  0

fdc_cmd_state:
    db  0

.EOF
