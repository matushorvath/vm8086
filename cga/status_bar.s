.EXPORT post_status_write

.EXPORT set_disk_active
.EXPORT set_disk_inactive

.EXPORT set_speaker_active
.EXPORT set_speaker_inactive

.EXPORT redraw_status_bar

# From screen.s
.IMPORT screen_width_chars
.IMPORT screen_height_chars

# From util/printb.s
.IMPORT printb

# From libxib.a
.IMPORT print_num_radix

# Unicode icons
#
# Disk:
#
# These work on Windows only:
# F0 9F 96 AB = U+1F5AB White Hard Shell Floppy Disk 🖫
# F0 9F 96 AC = U+1F5AC Soft Shell Floppy Disk 🖬
# F0 9F 96 B4 = U+1F5B4 Hard Disk 🖴
#
# These work on both Windows and Mac:
# F0 9F 92 BE = U+1F4BE Floppy Disk Emoji 💾
# E2 9B 81    = U+26C1  White Draughts King ⛁
# E2 9B 83 	  = U+26C3  Black Draughts King ⛃
#
# Speaker:
#
# F0 9F 94 8A = U+1F50A Speaker with Three Sound Waves 🔊

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
.FRAME
    # Do nothing if already active
    jnz [disk_active], .done

    # Save the new value
    add 1, 0, [disk_active]

    # Redraw just the disk activity
    call redraw_disk_activity

.done:
    ret 0
.ENDFRAME

##########
set_disk_inactive:
.FRAME
    # Do nothing if already inactive
    jz  [disk_active], .done

    # Save the new value
    add 0, 0, [disk_active]

    # Redraw just the disk activity
    call redraw_disk_activity

.done:
    ret 0
.ENDFRAME

##########
set_speaker_active:
.FRAME
    # Do nothing if already active
    jnz [speaker_active], .done

    # Save the new value
    add 1, 0, [speaker_active]

    # Redraw just the speaker activity
    call redraw_speaker_activity

.done:
    ret 0
.ENDFRAME

##########
set_speaker_inactive:
.FRAME
    # Do nothing if already inactive
    jz  [speaker_active], .done

    # Save the new value
    add 0, 0, [speaker_active]

    # Redraw just the speaker activity
    call redraw_speaker_activity

.done:
    ret 0
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
    jz  [post_status], .icons

    add [post_status], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

.icons:
    # Position the cursor one row below the screen, right side
    out 0x1b
    out '['

    add [screen_height_chars], 1, [rb - 1]
    arb -1
    call printb

    out ';'

    add [screen_width_chars], -3, [rb - 1]
    arb -1
    call printb

    out 'H'

    # Is the speaker active?
    jz  [speaker_active], .speaker_blank

    # Draw a speaker icon
    out 0xf0
    out 0x9f
    out 0x94
    out 0x8a

    jz  0, .after_speaker

.speaker_blank:
    # Draw a blank space for no speaker activity
    out ' '

.after_speaker:
    # The icons are double width, so we need a space between them
    out ' '

    # Is the disk active?
    jz  [disk_active], .disk_blank

    # Draw a diskette icon
    out 0xf0
    out 0x9f
    out 0x92
    out 0xbe

    jz  0, .after_disk

.disk_blank:
    # Draw a blank space for no disk activity
    out ' '

.after_disk:
    ret 0
.ENDFRAME

##########
redraw_disk_activity:
.FRAME
    # Position the cursor one row below the screen, right side
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

    # Is the disk active?
    jz  [disk_active], .blank

    # Draw a diskette icon
    out 0xf0
    out 0x9f
    out 0x92
    out 0xbe

    jz  0, .done

.blank:
    # Draw a blank space for no disk activity
    out ' '

.done:
    ret 0
.ENDFRAME

##########
redraw_speaker_activity:
.FRAME
    # Position the cursor one row below the screen, right side
    out 0x1b
    out '['

    add [screen_height_chars], 1, [rb - 1]
    arb -1
    call printb

    out ';'

    add [screen_width_chars], -3, [rb - 1]
    arb -1
    call printb

    out 'H'

    # Is the speaker active?
    jz  [speaker_active], .blank

    # Draw a speaker icon
    out 0xf0
    out 0x9f
    out 0x94
    out 0x8a

    jz  0, .done

.blank:
    # Draw a blank space for no speaker activity
    out ' '

.done:
    ret 0
.ENDFRAME

##########
post_status:
    db  0

disk_active:
    db  0

speaker_active:
    db  0

.EOF
