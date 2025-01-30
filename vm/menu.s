.EXPORT init_menu

# From cga/question.s
.IMPORT question

# From dev/keyboard.s
.IMPORT keyboard_callback

# From fdc/drives.s
.IMPORT fdc_image_index_units

# From fdc/init.s
.IMPORT init_fdd

# From img/images.s
.IMPORT floppy_data
.IMPORT floppy_size

##########
init_menu:
.FRAME
    add menu_callback, 0, [keyboard_callback]
    ret 0
.ENDFRAME

##########
menu_callback:
.FRAME drive, image_index
    arb -2

    # Ask which drive to change
    add drive_msg, 0, [rb - 1]
    add drive_options, 0, [rb - 2]
    add [drive_option_count], 0, [rb - 3]
    add 0, 0, [rb - 4]
    arb -4
    call question

    add [rb - 6], 0, [rb + drive]

    # Ask which image to select
    # TODO build list of images at runtime
    add image_msg, 0, [rb - 1]
    add image_options, 0, [rb - 2]
    add [image_option_count], 0, [rb - 3]
    add fdc_image_index_units, [rb + drive], [ip + 1]
    add [0], 0, [rb - 4]
    arb -4
    call question

    add [rb - 6], 0, [rb + image_index]

    # TODO validate image actually exists
    # TODO allow removing disk from a drive without replacement

    add [rb + drive], 0, [rb - 1]
    add [rb + image_index], 0, [rb - 2]
    arb -2
    call init_fdd

    arb 2
    ret 0
.ENDFRAME

##########
drive_msg:
    db  "Drive:", 0

drive_options:
    db  drive_option_a, drive_option_b
drive_option_count:
    db  2

drive_option_a:
    db  "A:", 0
drive_option_b:
    db  "B:", 0

image_msg:
    db  "Image:", 0

image_options:
    db  image_option_00, image_option_01, image_option_02, image_option_03, image_option_04
    db  image_option_05, image_option_06, image_option_07, image_option_08, image_option_09
    db  image_option_10, image_option_11, image_option_12, image_option_13, image_option_14
    db  image_option_15
image_option_count:
    db  16

image_option_00:
    db  "0", 0
image_option_01:
    db  "1", 0
image_option_02:
    db  "2", 0
image_option_03:
    db  "3", 0
image_option_04:
    db  "4", 0
image_option_05:
    db  "5", 0
image_option_06:
    db  "6", 0
image_option_07:
    db  "7", 0
image_option_08:
    db  "8", 0
image_option_09:
    db  "9", 0
image_option_10:
    db  "10", 0
image_option_11:
    db  "11", 0
image_option_12:
    db  "12", 0
image_option_13:
    db  "13", 0
image_option_14:
    db  "14", 0
image_option_15:
    db  "15", 0

.EOF
