.EXPORT question

# From screen.s
.IMPORT screen_width_chars
.IMPORT screen_height_chars

# From status_bar.s
.IMPORT redraw_status_bar

# From util/error.s
.IMPORT report_error

# From util/printb.s
.IMPORT printb

# From libxib.a
.IMPORT print_str

.SYMBOL KEY_ENTER   0
.SYMBOL KEY_RIGHT   1
.SYMBOL KEY_LEFT    2

##########
question:
.FRAME message, options, option_count, default; selected, tmp                   # returns selected
    arb -2

    # Display a question in the status bar and wait for answer

    # At most 16 options are supported
    lt  0, [rb + option_count], [rb + tmp]
    jz  [rb + tmp], .error_count
    lt  16, [rb + option_count], [rb + tmp]
    jnz [rb + tmp], .error_count

    add [rb + default], 0, [rb + selected]

.loop:
    # Redraw the question
    add [rb + message], 0, [rb - 1]
    add [rb + options], 0, [rb - 2]
    add [rb + option_count], 0, [rb - 3]
    add [rb + selected], 0, [rb - 4]
    arb -4
    call redraw_question

    # Process input
    call process_question_input

    eq  [rb - 2], KEY_ENTER, [rb + tmp]
    jnz [rb + tmp], .done
    eq  [rb - 2], KEY_RIGHT, [rb + tmp]
    jnz [rb + tmp], .input_right
    eq  [rb - 2], KEY_LEFT, [rb + tmp]
    jnz [rb + tmp], .input_left

.input_right:
    # Move the cursor right if possible
    add [rb + selected], 1, [rb + selected]

    eq  [rb + selected], [rb + option_count], [rb + tmp]
    jz  [rb + tmp], .loop

    add [rb + option_count], -1, [rb + selected]
    jz  0, .loop

.input_left:
    # Move the cursor left if possible
    add [rb + selected], -1, [rb + selected]

    eq  [rb + selected], -1, [rb + tmp]
    jz  [rb + tmp], .loop

    add 0, 0, [rb + selected]
    jz  0, .loop

.done:
    # Redraw the status bar
    call redraw_status_bar

    # Return selected item
    arb 2
    ret 4

.error_count:
    add .error_count_msg, 0, [rb - 1]
    arb -1
    call report_error

.error_count_msg:
    db  "expected 1 to 16 question options", 0
.ENDFRAME

##########
redraw_question:
.FRAME message, options, option_count, selected; index, tmp     # returns result
    arb -2

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

    # Draw all options
    add 0, 0, [rb + index]

.loop:
    # Space between options
    out ' '

    # Is currently drawn option selected?
    eq  [rb + selected], [rb + index], [rb + tmp]
    jz  [rb + tmp], .after_color

    # Yes, set color to black on light gray
    add .tty_selected_color, 0, [rb - 1]
    arb -1
    call print_str

.after_color:
    # Print one option
    out ' '
    add [rb + options], [rb + index], [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call print_str
    out ' '

    # Reset color
    add .tty_reset_color, 0, [rb - 1]
    arb -1
    call print_str

    # Loop to next option
    add [rb + index], 1, [rb + index]
    eq  [rb + index], [rb + option_count], [rb + tmp]

    jz  [rb + tmp], .loop

    arb 2
    ret 4

.tty_selected_color:
    # Selected option, draw black on white
    db  0x1b, "[38;2;0;0;0;48;2;170;170;170m", 0
.tty_reset_color:
    # Reset all attributes
    db  0x1b, "[0m", 0
.ENDFRAME

##########
process_question_input:
.FRAME result, char, tmp                # returns result
    arb -3

    # Process input searching for supported key presses

.loop:
    in  [rb + char]

    eq  [rb + char], 0x0d, [rb + tmp]
    jnz [rb + tmp], .enter
    eq  [rb + char], 0x1b, [rb + tmp]
    jnz [rb + tmp], .esc

    # Unsupported character
    jz  0, .loop

.enter:
    add KEY_ENTER, 0, [rb + result]
    jz  0, .done

.esc:
    in  [rb + char]

    eq  [rb + char], 0x5b, [rb + tmp]
    jnz [rb + tmp], .esc_5b

    # Unsupported character
    jz  0, .loop

.esc_5b:
    in  [rb + char]

    eq  [rb + char], 0x43, [rb + tmp]
    jnz [rb + tmp], .arrow_right
    eq  [rb + char], 0x44, [rb + tmp]
    jnz [rb + tmp], .arrow_left

    # Unsupported character
    jz  0, .loop

.arrow_right:
    add KEY_RIGHT, 0, [rb + result]
    jz  0, .done

.arrow_left:
    add KEY_LEFT, 0, [rb + result]
    jz  0, .done

.done:
    # Return the result
    arb 3
    ret 0
.ENDFRAME

.EOF
