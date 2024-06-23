.EXPORT post_status_write
.EXPORT set_disk_active
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
set_disk_active:
.FRAME active;
    # Save the new value
    add [rb + active], 0, [disk_active]

    # Redraw just the disk activity
    call redraw_disk_activity

    ret 1
.ENDFRAME

##########
redraw_vm_status:
.FRAME
    # Assume that we have a 25 row text mode during POST
    # TODO we now have status after POST, use the real row count

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
    call redraw_disk_activity

    ret 0
.ENDFRAME

##########
redraw_disk_activity:
.FRAME
    # Position the cursor to column 79, row 26 (end of the status line)
    out 0x1b
    out '['
    out '2'
    out '6'
    out ';'
    out '7'
    out '9'
    out 'H'

    # If there is disk activity, set color to black on yellow
    jz  [disk_active], redraw_disk_activity_after_set_color

    out 0x1b
    out '['
    out '3'
    out '0'
    out ';'
    out '1'
    out '0'
    out '3'
    out 'm'

redraw_disk_activity_after_set_color:
    # Draw a diskette icon and a space (the icon is two characters wide)
    # F0 9F 96 AB = U+1F5AB White Hard Shell Floppy Disk 🖫
    # F0 9F 96 AC = U+1F5AC Soft Shell Floppy Disk 🖬
    # F0 9F 96 B4 = U+1F5B4 Hard Disk 🖴

    out 0xf0
    out 0x9f
    out 0x96
    out 0xab
    out ' '

    # Reset text attributes if we have set them above
    jz  [disk_active], redraw_disk_activity_after_reset_color

    out 0x1b
    out '['
    out '0'
    out 'm'

redraw_disk_activity_after_reset_color:
    ret 0
.ENDFRAME

##########
post_status:
    db  0

disk_active:
    db  0

.EOF
