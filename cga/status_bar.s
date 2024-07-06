.EXPORT post_status_write
.EXPORT set_disk_active
.EXPORT redraw_status_bar

# From screen.s
.IMPORT screen_width_chars
.IMPORT screen_height_chars

# From util/printb.s
.IMPORT printb

# From libxib.a
.IMPORT print_num_radix

##########
post_status_write:
.FRAME port, value;
    # Save the new value
    add [rb + value], 0, [post_status]

    # POST codes are not performance critical, just redraw the whole status bar
    call redraw_status_bar

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
redraw_status_bar:
.FRAME
    # Position the cursor to column 1, one row below the screen
    out 0x1b
    out '['

    add [screen_height_chars], 1, [rb - 1]
    arb -1
    call printb

    out ';'
    out '1'
    out 'H'

    # Clear current line
    out 0x1b
    out '['
    out '2'
    out 'K'

    # Print the POST status code, unless it's 00
    jz  [post_status], redraw_status_bar_after_post

    add [post_status], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

redraw_status_bar_after_post:
    call redraw_disk_activity

    ret 0
.ENDFRAME

##########
redraw_disk_activity:
.FRAME
    # Position the cursor to column 79, one row below the screen
    out 0x1b
    out '['

    add [screen_height_chars], 1, [rb - 1]
    arb -1
    call printb

    out ';'

    add [screen_width_chars], -1, [rb - 1]
    arb -1
    call printb

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
