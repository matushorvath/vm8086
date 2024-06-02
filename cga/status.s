.EXPORT post_status_write
.EXPORT redraw_vm_status

# From libxib.a
.IMPORT print_num_radix

# This file support reporting VM status on screen while the CGA is active

##########
post_status_write:
.FRAME port, value;
    # Save the new value
    add [rb + value], 0, [post_status]

    # POST codes are not performance critical, just redraw the whole status line
    call redraw_vm_status
    ret 2
.ENDFRAME

##########
redraw_vm_status:
.FRAME
    # Assume that we have a 25 row text mode during POST

    # Position the cursor to column 1, row 26 (just below the lower left corner of the screen)
    out 0x1b
    out '['
    out '2'
    out '6'
    out ';'
    out '1'
    out 'H'

    # Clear current line
    out 0x1b
    out '['
    out '2'
    out 'K'

    # Print the POST status code, unless it's 00
    jz  [post_status], redraw_vm_status_after_post

    add [post_status], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

redraw_vm_status_after_post:
    ret 0
.ENDFRAME

##########
post_status:
    db  0

.EOF
