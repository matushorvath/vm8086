.EXPORT post_status_write

.EXPORT set_disk_active
.EXPORT set_disk_inactive

.EXPORT set_speaker_active
.EXPORT set_speaker_inactive

.EXPORT redraw_status_bar
.EXPORT question

# From the linked binary
.IMPORT extended_vm

# From screen.s
.IMPORT screen_width_chars
.IMPORT screen_height_chars

# From util/printb.s
.IMPORT printb

# From libxib.a
.IMPORT print_num_radix
.IMPORT print_str

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
#
# Extended VM:
#
# E2 9A A1    = U+26A1  High Voltage Sign ⚡
# F0 9F 94 A5 = U+1F525 Fire 🔥
# F0 9F 94 B7 = U+1F537 Large Blue Diamond 🔷
# F0 9F 94 B9 = U+1F539 Small Blue Diamond 🔹

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

    # Print the extended VM symbol if running under an extended VM
    jz  [extended_vm], .after_extended_vm

    # Draw the symbol
    out 0xe2
    out 0x9a
    out 0xa1
    out ' '

.after_extended_vm:
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
question:
.FRAME message, response, response_size; index, char, tmp
    arb -3

    # Display a question in the status bar and wait for input

    # Position the cursor one row below the screen, right side
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

    # Print the message
    add [rb + message], 0, [rb - 1]
    arb -1
    call print_str

    out ' '

    # Read the response into the provided buffer
    add 0, 0, [rb + index]

.loop:
    # Write at most response_size bytes to the buffer (including zero termination)
    add [rb + response_size], -1, [rb + response_size]
    lt  0, [rb + response_size], [rb + tmp]
    jz  [rb + tmp], .done

    # Read next character
    in  [rb + char]

    # Stop reading on Enter
    eq  [rb + char], 13, [rb + tmp]
    jnz [rb + tmp], .done

    # Output the character
    out [rb + char]

    # Save the character
    add [rb + response], [rb + index], [ip + 3]
    add [rb + char], 0, [0]

    add [rb + index], 1, [rb + index]
    jz  0, .loop

.done:
    # Zero terminate the response
    add [rb + response], [rb + index], [ip + 3]
    add 0, 0, [0]

    # Redraw the status bar
    call redraw_status_bar

    arb 3
    ret 3
.ENDFRAME

##########
post_status:
    db  0

disk_active:
    db  0

speaker_active:
    db  0

.EOF
