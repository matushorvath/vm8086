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
.FRAME unit, image_index; data, size, offset, tmp
    arb -4

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

    # Find floppy parameters based on image size
    add 0, 0, [rb + offset]

.loop:
    # Read first field of the record, floppy size in bytes
    add .params + 0, [rb + offset], [ip + 1]
    add [0], 0, [rb + tmp]

    # Zero record terminates the params table
    jz  [rb + tmp], .not_found

    # Does floppy size match the image we have?
    eq  [rb + tmp], [rb + size], [rb + tmp]
    jnz [rb + tmp], .found

    # Floppy size does not match, move to next record
    add [rb + offset], PARAMS_RECORD_SIZE, [rb + offset]
    jz  0, .loop

.found:
    # Found the params record, set medium parameters
    add .params + 1, [rb + offset], [ip + 1]
    add [0], 0, [rb + tmp]
    add fdc_medium_heads_units, [rb + unit], [ip + 3]
    add [rb + tmp], 0, [0]

    add .params + 2, [rb + offset], [ip + 1]
    add [0], 0, [rb + tmp]
    add fdc_medium_cylinders_units, [rb + unit], [ip + 3]
    add [rb + tmp], 0, [0]

    add .params + 3, [rb + offset], [ip + 1]
    add [0], 0, [rb + tmp]
    add fdc_medium_sectors_units, [rb + unit], [ip + 3]
    add [rb + tmp], 0, [0]

.done:
    arb 4
    ret 2

.params:
    #       capacity    heads    tracks   sectors
    db       163840,        1,       40,        8          # 5.25" 160kB
    db       184320,        1,       40,        9          # 5.25" 180kB
    db       327680,        2,       40,        8          # 5.25" 320kB
    db       368640,        2,       40,        9          # 5.25" 360kB
    db       737280,        2,       80,        9          # 3.5" 720kB
    db      1228800,        2,       80,       15          # 5.25" 1.2MB
    db      1474560,        2,       80,       18          # 3.5" 1.44MB
    db      1720320,        2,       80,       21          # 3.5" 1.68MB
    db      1763328,        2,       82,       21          # 3.5" 1.72MB
    db      2949120,        2,       80,       36          # 3.5" 2.88MB
    db            0,        0,        0,        0

.SYMBOL PARAMS_RECORD_SIZE 4

.not_found:
    add .not_found_message, 0, [rb - 1]
    arb -1
    call report_error

.not_found_message:
    db  "fdc: unsupported floppy image size", 0

.ENDFRAME

.EOF
