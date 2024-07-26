.EXPORT init_fdc
.EXPORT fdc_error_non_dma

# From fdc_config.s
.IMPORT fdc_config_connected_units
.IMPORT fdc_config_inserted_units

# From fdc_control.s
.IMPORT fdc_dor_write
.IMPORT fdc_status_read
.IMPORT fdc_dir_read
.IMPORT fdc_control_write

# From fdc_drives.s
.IMPORT fdc_medium_cylinders_units
.IMPORT fdc_medium_heads_units
.IMPORT fdc_medium_sectors_units

# From fdc_state_machine.s
.IMPORT fdc_data_read
.IMPORT fdc_data_write

# From cpu/devices.s
.IMPORT register_ports

# From cpu/error.s
.IMPORT report_error

# TODO fdc should not work while fdc_dor_reset == 0
# TODO fdc should not read/write data or seek etc while the motor is off fdc_dor_enable_motor_unit0/1 and if it is not selected in dor
# TODO set equipment check bit in ST0 if FDD is not connected?

# TODO The bottom 2 bits of DSR match CCR, and setting one of them sets the other.
# TODO relative seek: set the MT bit to 1, to seek up set MFM bit, to seek down clear MFM bit
# TODO read track does not support multitrack, it just reads one side

# TODO command support for multitrack operations
# TODO sector numbers go from 1, not 0 - at least read_id needs to be changed

# TODO separate fsm_?_invalid from unsupported functionality, crash when unsupported

##########
fdc_ports:
    db  0xf2, 0x03, 0, fdc_dor_write                        # Digital Output Register
    db  0xf4, 0x03, fdc_status_read, 0                      # Main Status Register
    db  0xf5, 0x03, fdc_data_read, fdc_data_write           # Diskette Data Register
    db  0xf7, 0x03, fdc_dir_read, fdc_control_write         # Digital Input Register/Diskette Control Register

    db  -1, -1, -1, -1

##########
init_fdc:
.FRAME unit
    # Register I/O ports
    add fdc_ports, 0, [rb - 1]
    arb -1
    call register_ports

    # Initialize both drive units
    add 0, 0, [rb - 1]
    arb -1
    call init_unit

    add 1, 0, [rb - 1]
    arb -1
    call init_unit

    ret 0
.ENDFRAME

##########
init_unit:
.FRAME unit; type, tmp
    arb -2

    # Initialize floppy parameters based on inserted floppy types
    # Currently we only support 3.5" 1.44MB floppies

    # Floppy geometry:
    #           heads   tracks  sectors bytes   capacity    type
    # 5.25"     1       40      9       512      184320     12
    # 5.25"     2       80      9       512      368640     14
    # 5.25"     2       80      15      512     1228800     17
    # 3.5"      2       80      9       512      737280     24
    # 3.5"      2       80      18      512     1474560     25

    # Skip disconnected and empty drives
    add fdc_config_connected_units, [rb + unit], [ip + 1]
    jz  [0], .done
    add fdc_config_inserted_units, [rb + unit], [ip + 1]
    add [0], 0, [rb + type]
    jz  [rb + type], .done

    # Fill in floppy parameters; currently only 1.44MB 3.5" floppies are supported
    eq  [rb + type], 25, [rb + tmp]
    jz  [rb + tmp], .unsupported_type

    # Set floppy parameters based on floppy type
    # TODO support more floppy types
    add fdc_medium_cylinders_units, [rb + unit], [ip + 3]
    add 80, 0, [0]
    add fdc_medium_heads_units, [rb + unit], [ip + 3]
    add 2, 0, [0]
    add fdc_medium_sectors_units, [rb + unit], [ip + 3]
    add 18, 0, [0]

.done:
    arb 2
    ret 1

.unsupported_type:
    add .unsupported_type_message, 0, [rb - 1]
    arb -1
    call report_error

.unsupported_type_message:
    db  "fdd unit type is not supported", 0
.ENDFRAME

##########
fdc_error_non_dma:
    db  "fdc: Non-DMA operation is not supported", 0

.EOF
