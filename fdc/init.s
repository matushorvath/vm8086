.EXPORT init_fdc

# From control.s
.IMPORT fdc_dor_write
.IMPORT fdc_status_read
.IMPORT fdc_dir_read
.IMPORT fdc_control_write

# From drives.s
.IMPORT fdc_medium_cylinders_units
.IMPORT fdc_medium_heads_units
.IMPORT fdc_medium_sectors_units
.IMPORT fdc_image_units

# From state_machine.s
.IMPORT fdc_data_read
.IMPORT fdc_data_write

# From cpu/ports.s
.IMPORT register_ports

# From util/error.s
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

# TODO bug the B: floppy seems to be accessible even when no image is present (probably overwriting memory at 0)

##########
fdc_ports:
    db  0xf2, 0x03, 0, fdc_dor_write                        # Digital Output Register
    db  0xf4, 0x03, fdc_status_read, 0                      # Main Status Register
    db  0xf5, 0x03, fdc_data_read, fdc_data_write           # Diskette Data Register
    db  0xf7, 0x03, fdc_dir_read, fdc_control_write         # Digital Input Register/Diskette Control Register

    db  -1, -1, -1, -1

##########
init_fdc:
.FRAME floppy_a, floppy_b;
    # Register I/O ports
    add fdc_ports, 0, [rb - 1]
    arb -1
    call register_ports

    # Initialize both drive units
    add 0, 0, [rb - 1]
    add [rb + floppy_a], 0, [rb - 2]
    arb -2
    call init_unit

    add 1, 0, [rb - 1]
    add [rb + floppy_b], 0, [rb - 2]
    arb -2
    call init_unit

    ret 2
.ENDFRAME

##########
init_unit:
.FRAME unit, image;
    # Initialize floppy parameters based on inserted floppy types
    # Currently we only support 3.5" 1.44MB floppies

    # Floppy geometry:
    #           heads   tracks  sectors bytes   capacity    type
    # 5.25"     1       40      9       512      184320     12
    # 5.25"     2       80      9       512      368640     14
    # 5.25"     2       80      15      512     1228800     17
    # 3.5"      2       80      9       512      737280     24
    # 3.5"      2       80      18      512     1474560     25

    # Skip units without a floppy image
    jz  [rb + image], .done

    # Fill in floppy parameters; currently only 1.44MB 3.5" (type 25) floppies are supported
    # TODO support more floppy types
    add fdc_medium_cylinders_units, [rb + unit], [ip + 3]
    add 80, 0, [0]
    add fdc_medium_heads_units, [rb + unit], [ip + 3]
    add 2, 0, [0]
    add fdc_medium_sectors_units, [rb + unit], [ip + 3]
    add 18, 0, [0]

    # Save pointer to floppy image
    add fdc_image_units, [rb + unit], [ip + 3]
    add [rb + image], 0, [0]

.done:
    ret 2
.ENDFRAME

.EOF
