.EXPORT init_menu

# From cga/status_bar.s
.IMPORT question

# From dev/keyboard.s
.IMPORT keyboard_callback

# From fdc/init.s
.IMPORT init_fdd

# From img/images.s
.IMPORT floppy_data
.IMPORT floppy_size

# From libxib
.IMPORT atoi

##########
init_menu:
.FRAME
    add menu_callback, 0, [keyboard_callback]
    ret 0
.ENDFRAME

##########
menu_callback:
.FRAME drive, image
    arb -2

    # TODO POC
    # Swap disk in floppy drive 1

    # Ask which drive to change
    add .drive_msg, 0, [rb - 1]
    add .response, 0, [rb - 2]
    add 16, 0, [rb - 3]
    arb -3
    call question

    # Parse the answer
    add .response, 0, [rb - 1]
    arb -1
    call atoi
    add [rb - 3], 0, [rb + drive]

    # TODO validate drive is 0 or 1

    # Ask which image to select
    add .image_msg, 0, [rb - 1]
    add .response, 0, [rb - 2]
    add 16, 0, [rb - 3]
    arb -3
    call question

    # Parse the answer
    add .response, 0, [rb - 1]
    arb -1
    call atoi
    add [rb - 3], 0, [rb + image]

    # TODO validate image actually exists
    # TODO allow removing disk from a drive without replacement

    add [rb + drive], 0, [rb - 1]
    add [rb + image], 0, [rb - 2]
    arb -2
    call init_fdd

    arb 2
    ret 0

.drive_msg:
    db  "Floppy drive:", 0

.image_msg:
    db  "Image index:", 0

.response:
    ds  16, 0
.ENDFRAME

.EOF
