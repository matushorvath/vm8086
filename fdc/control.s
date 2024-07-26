.EXPORT fdc_dor_write
.EXPORT fdc_status_read
.EXPORT fdc_dir_read
.EXPORT fdc_control_write

.EXPORT fdc_dor_enable_motor_units
.EXPORT fdc_interrupt_pending

# From the config file
.IMPORT config_log_fdc

# From fdc_init.s
.IMPORT fdc_error_non_dma

# From fdc_fsm.s
.IMPORT fdc_cmd_state
.IMPORT fdc_cmd_result_phase
.IMPORT fdc_cmd_st0

# From pic_8259a_execute.s
.IMPORT interrupt_request

# From cpu/error.s
.IMPORT report_error

# From util/bits.s
.IMPORT bit_0
.IMPORT bit_2
.IMPORT bit_3
.IMPORT bit_4
.IMPORT bit_5

# From util/log.s
.IMPORT log_start

# From libxib.a
.IMPORT print_str
.IMPORT print_num_2_b

##########
fdc_dor_write:
.FRAME addr, value; tmp
    arb -1

    # Floppy controller logging
    jz  [config_log_fdc], .after_log_fdc

    add [rb + value], 0, [rb - 1]
    arb -1
    call fdc_dor_write_log_fdc

.after_log_fdc:
    # Save the original fdc_dor_reset value before changing it
    eq  [fdc_dor_reset], 0, [rb + tmp]
    add bit_2, [rb + value], [ip + 1]
    add [0], 0, [fdc_dor_reset]
    add [fdc_dor_reset], [rb + tmp], [rb + tmp]

    # If fdc_dor_reset was low and now is high, reset the floppy controller
    eq  [rb + tmp], 2, [rb + tmp]
    jz  [rb + tmp], .after_reset
    call fdc_d765ac_reset

.after_reset:
    # Save the other bits
    add bit_0, [rb + value], [ip + 1]
    add [0], 0, [fdc_dor_drive_a_select]

    add bit_3, [rb + value], [ip + 1]
    jnz [0], .dma_enabled

    add fdc_error_non_dma, 0, [rb - 1]
    arb -1
    call report_error

.dma_enabled:
    add bit_4, [rb + value], [ip + 1]
    add [0], 0, [fdc_dor_enable_motor_unit0]

    add bit_5, [rb + value], [ip + 1]
    add [0], 0, [fdc_dor_enable_motor_unit1]

    arb 1
    ret 2
.ENDFRAME

##########
fdc_dor_write_log_fdc:
.FRAME value;
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10
    ret 1

.msg:
    db  "fdc dor write, value ", 0
.ENDFRAME

##########
fdc_status_read:
.FRAME addr; value, tmp
    arb -2

    # Controller is busy in non-idle command state
    # Bit 4 CB  - Controller is busy reading or writing
    lt  0, [fdc_cmd_state], [rb + tmp]
    mul [rb + tmp], 0b00010000, [rb + value]

    # Data transfer direction is CPU to FDC in command phase, FDC to CPU in result phase
    # Bit 6 DIO - data input/output, 0 - from CPU to FDC, 1 - from FDC to CPU
    mul [fdc_cmd_result_phase], 0b01000000, [rb + tmp]
    add [rb + value], [rb + tmp], [rb + value]

    # Following bits have fixed values, since seeking, reading and writing is immediate,
    # and we only support DMA mode:
    # Bit 0 DAB - FDD A is busy seeking
    # Bit 1 DBB - FDD B is busy seeking
    # Bit 2 reserved
    # Bit 3 reserved
    # Bit 5 NDM - non-DMA mode
    # Bit 7 RQM - data register is ready for data transfer
    add [rb + value], 0b10000000, [rb + value]

    # Floppy controller logging
    jz  [config_log_fdc], .after_log_fdc

    add [rb + value], 0, [rb - 1]
    arb -1
    call fdc_status_read_log_fdc

.after_log_fdc:
    arb 2
    ret 1
.ENDFRAME

##########
fdc_status_read_log_fdc:
.FRAME value;
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10
    ret 1

.msg:
    db  "fdc status read, value ", 0
.ENDFRAME

##########
fdc_control_write:
.FRAME addr, value;
    # TODO this is I think used to detect floppy type
    # if yes, we need to return errors (when reading?) unless the speed is set correctly

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

    # Floppy controller logging
    jz  [config_log_fdc], .after_log_fdc
    call fdc_d765ac_reset_log_fdc

.after_log_fdc:
    # After reset both units have changed ready status, following sense interrupt status
    # will return ST0 with bits 6 and 7 set
    add 0b11000000, 0, [fdc_cmd_st0]

    # Trigger IRQ6 if the FDD is ready, which we assume it always is
    # TODO if the motor is off, is the FDD ready? also, the FDD may not be present
    add 1, 0, [fdc_interrupt_pending]

    add 6, 0, [rb - 1]
    arb -1
    call interrupt_request

    ret 0
.ENDFRAME

##########
fdc_d765ac_reset_log_fdc:
.FRAME
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    out 10
    ret 0

.msg:
    db  "fdc reset controller", 0
.ENDFRAME

##########
fdc_dor_drive_a_select:                 # 0 = drive A selected, 1 = drive B selected
    db  0
fdc_dor_reset:                          # 0 = reset
    db  0

fdc_dor_enable_motor_units:
fdc_dor_enable_motor_unit0:
    db  0
fdc_dor_enable_motor_unit1:
    db  0

fdc_interrupt_pending:
    db  0

.EOF
