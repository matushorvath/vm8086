.EXPORT init_fdc
.EXPORT init_fdd

# From control.s
.IMPORT fdc_dor_write
.IMPORT fdc_status_read
.IMPORT fdc_dir_read
.IMPORT fdc_control_write

# From drives.s
.IMPORT fdc_medium_changed_units
.IMPORT fdc_medium_cylinders_units
.IMPORT fdc_medium_heads_units
.IMPORT fdc_medium_sectors_units
.IMPORT fdc_image_units
.IMPORT fdc_image_index_units

# From state_machine.s
.IMPORT fdc_data_read
.IMPORT fdc_data_write

# From cpu/ports.s
.IMPORT register_ports

# From img/images.s
.IMPORT floppy_data
.IMPORT floppy_size

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
.FRAME image_index_a, image_index_b;
    # Register I/O ports
    add fdc_ports, 0, [rb - 1]
    arb -1
    call register_ports

    # Initialize both drive units
    add 0, 0, [rb - 1]
    add [rb + image_index_a], 0, [rb - 2]
    arb -2
    call init_fdd

    add 1, 0, [rb - 1]
    add [rb + image_index_b], 0, [rb - 2]
    arb -2
    call init_fdd

    ret 2
.ENDFRAME

##########
init_fdd:
.FRAME unit, image_index; data, size, tmp
    arb -3

    # Initialize floppy parameters based on inserted floppy type

    # Load image information
    add floppy_data, [rb + image_index], [ip + 1]
    add [0], 0, [rb + data]
    add floppy_size, [rb + image_index], [ip + 1]
    add [0], 0, [rb + size]

    # Skip zero images
    # TODO remove disk from the drive for zero images
    jz  [rb + data], .done

    # Set the medium changed flag
    add fdc_medium_changed_units, [rb + unit], [ip + 3]
    add 1, 0, [0]

    # Save image index
    add fdc_image_index_units, [rb + unit], [ip + 3]
    add [rb + image_index], 0, [0]

    # Save pointer to floppy image
    add fdc_image_units, [rb + unit], [ip + 3]
    add [rb + data], 0, [0]

    # Set medium parameters based on floppy image size
    eq  [rb + size], 1474560, [rb + tmp]
    jnz [rb + tmp], .floppy_1440
    eq  [rb + size], 1228800, [rb + tmp]
    jnz [rb + tmp], .floppy_1200
    eq  [rb + size], 737280, [rb + tmp]
    jnz [rb + tmp], .floppy_720
    eq  [rb + size], 368640, [rb + tmp]
    jnz [rb + tmp], .floppy_360
    eq  [rb + size], 184320, [rb + tmp]
    jnz [rb + tmp], .floppy_180

    add .error, 0, [rb - 1]
    arb -1
    call report_error

.error:
    db  "fdc: unsupported floppy image size", 0

    # Floppy geometry:
    #           heads   tracks  sectors bytes   capacity    type
    # 5.25"     1       40      9       512      184320     12
    # 5.25"     2       40      9       512      368640     14
    # 5.25"     2       80      15      512     1228800     17
    # 3.5"      2       80      9       512      737280     24
    # 3.5"      2       80      18      512     1474560     25

.floppy_1440:
    # Floppy parameters for 1.44MB 3.5"
    add fdc_medium_cylinders_units, [rb + unit], [ip + 3]
    add 80, 0, [0]
    add fdc_medium_heads_units, [rb + unit], [ip + 3]
    add 2, 0, [0]
    add fdc_medium_sectors_units, [rb + unit], [ip + 3]
    add 18, 0, [0]

    jz  0, .done

.floppy_1200:
    # Floppy parameters for 1.2MB 5.25"
    add fdc_medium_cylinders_units, [rb + unit], [ip + 3]
    add 80, 0, [0]
    add fdc_medium_heads_units, [rb + unit], [ip + 3]
    add 2, 0, [0]
    add fdc_medium_sectors_units, [rb + unit], [ip + 3]
    add 15, 0, [0]

    jz  0, .done

.floppy_720:
    # Floppy parameters for 720kB 3.5"
    add fdc_medium_cylinders_units, [rb + unit], [ip + 3]
    add 80, 0, [0]
    add fdc_medium_heads_units, [rb + unit], [ip + 3]
    add 2, 0, [0]
    add fdc_medium_sectors_units, [rb + unit], [ip + 3]
    add 9, 0, [0]

    jz  0, .done

.floppy_360:
    # Floppy parameters for 360kB 5.25"
    add fdc_medium_cylinders_units, [rb + unit], [ip + 3]
    add 40, 0, [0]
    add fdc_medium_heads_units, [rb + unit], [ip + 3]
    add 2, 0, [0]
    add fdc_medium_sectors_units, [rb + unit], [ip + 3]
    add 9, 0, [0]

    jz  0, .done

.floppy_180:
    # Floppy parameters for 180kB 5.25"
    add fdc_medium_cylinders_units, [rb + unit], [ip + 3]
    add 40, 0, [0]
    add fdc_medium_heads_units, [rb + unit], [ip + 3]
    add 1, 0, [0]
    add fdc_medium_sectors_units, [rb + unit], [ip + 3]
    add 9, 0, [0]

    jz  0, .done

.done:
    arb 3
    ret 2
.ENDFRAME

.EOF
