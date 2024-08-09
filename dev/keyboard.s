.EXPORT handle_keyboard

# From scancode.s
.IMPORT scancode

# From dev/pic_8259a_execute.s
.IMPORT interrupt_request

# From dev/ppi_8255a.s
.IMPORT ppi_a

# TODO what should happen if keys are pressed faster than BIOS can receive them?
# TODO avoid pressing and releasing shift unless necessary (remember shift state)
# TODO consider moving outside of dev/ to kbd/

##########
handle_keyboard:
.FRAME char, char_x2, tmp
    arb -3

    # Wait until BIOS reads and acknowledges ppi_a by setting bit 7 in ppi_b (which will also clear ppi_a)
    #jnz [ppi_a], .done                 # optimization, this was moved outside of this function

    # State machine to translate stdin characters into keyboard scan codes
    jz  0, [keyboard_state]

.initial:
    # Previous input is fully processed, start from scratch

    # Read a new character, if available
    db  213, char                       # ina [rb + char]
    eq  [rb + char], -1, [rb + tmp]
    jnz [rb + tmp], .done

    mul [rb + char], 2, [rb + char_x2]

    # There is a character, what should we do with it?
    add scancode + 0, [rb + char_x2], [ip + 1]
    add [0], .initial_table, [ip + 2]
    jz  0, [0]

.initial_table:
    db  .done                           # 0, ignore this character
    db  .initial_lowercase              # 1, lowercase character, output the make code
    db  .initial_uppercase              # 2, uppercase character, output shift make code
    db  .initial_escape                 # 3, escape, start processing complex input


.initial_lowercase:
    # Output make and break code for current character, with shift released
    add scancode + 1, [rb + char_x2], [ip + 1]
    add [0], 0, [current_make_code]

    jz  0, .generic_lowercase_make_break

.initial_uppercase:
    # Output make and break code for current character, with shift pressed
    add scancode + 1, [rb + char_x2], [ip + 1]
    add [0], 0, [current_make_code]

    jz  0, .generic_uppercase_make_break


.initial_escape:
    # Escape character, process an escape sequence
    add .esc, 0, [keyboard_state]
    jz  0, .done

.esc:
    # Read next character if available
    db  213, char                       # ina [rb + char]
    eq  [rb + char], -1, [rb + tmp]
    jnz [rb + tmp], .done

    # Continue the escape sequence
    eq  [rb + char], 0x1b, [rb + tmp]
    jnz [rb + tmp], .esc_esc
    eq  [rb + char], 0x4f, [rb + tmp]
    jnz [rb + tmp], .esc_4f_wait
    eq  [rb + char], 0x5b, [rb + tmp]
    jnz [rb + tmp], .esc_5b_wait

    jz  0, .done

.esc_esc:
    # Double escape, simulate pressing the escape key once
    # TODO do not require two escape key presses to generate one escape
    add 0x01, 0, [current_make_code]
    jz  0, .generic_lowercase_make_break

.esc_4f_wait:
    add .esc_4f, 0, [keyboard_state]
    jz  0, .done

.esc_5b_wait:
    add .esc_5b, 0, [keyboard_state]
    jz  0, .done


.esc_4f:
    # Read next character if available
    db  213, char                       # ina [rb + char]
    eq  [rb + char], -1, [rb + tmp]
    jnz [rb + tmp], .done

    # Continue the escape sequence
    eq  [rb + char], 0x50, [rb + tmp]
    jnz [rb + tmp], .function_1_to_4
    eq  [rb + char], 0x51, [rb + tmp]
    jnz [rb + tmp], .function_1_to_4
    eq  [rb + char], 0x52, [rb + tmp]
    jnz [rb + tmp], .function_1_to_4
    eq  [rb + char], 0x53, [rb + tmp]
    jnz [rb + tmp], .function_1_to_4

    jz  0, .done

.function_1_to_4:
    # Function keys F1 to F4; char 0x50-0x53 maps to make code 0x3b-0x3e
    add [rb + char], -0x15, [current_make_code]
    jz  0, .generic_lowercase_make_break


.esc_5b:
    # Read next character if available
    db  213, char                       # ina [rb + char]
    eq  [rb + char], -1, [rb + tmp]
    jnz [rb + tmp], .done

    # Continue the escape sequence
    eq  [rb + char], 0x31, [rb + tmp]
    jnz [rb + tmp], .esc_5b_31_wait
    eq  [rb + char], 0x32, [rb + tmp]
    jnz [rb + tmp], .esc_5b_32_wait

    jz  0, .done

.esc_5b_31_wait:
    add .esc_5b_31, 0, [keyboard_state]
    jz  0, .done

.esc_5b_32_wait:
    add .esc_5b_32, 0, [keyboard_state]
    jz  0, .done


.esc_5b_31:
    # Read next character if available
    db  213, char                       # ina [rb + char]
    eq  [rb + char], -1, [rb + tmp]
    jnz [rb + tmp], .done

    # Continue the escape sequence
    eq  [rb + char], 0x35, [rb + tmp]
    jnz [rb + tmp], .function_5_wait
    eq  [rb + char], 0x37, [rb + tmp]
    jnz [rb + tmp], .function_6_to_8_wait
    eq  [rb + char], 0x38, [rb + tmp]
    jnz [rb + tmp], .function_6_to_8_wait
    eq  [rb + char], 0x39, [rb + tmp]
    jnz [rb + tmp], .function_6_to_8_wait

    jz  0, .done

.function_5_wait:
    # Function key F5
    add 0x3f, 0, [current_make_code]

    # Wait for 7e, then make and break with the code we just prepared
    add .7e_make_break, 0, [keyboard_state]
    jz  0, .done

.function_6_to_8_wait:
    # Function keys F6 to F8; char 0x37-0x39 maps to make code 0x40-0x42
    add [rb + char], 0x9, [current_make_code]

    # Wait for 7e, then make and break with the code we just prepared
    add .7e_make_break, 0, [keyboard_state]
    jz  0, .done


.esc_5b_32:
    # Read next character if available
    db  213, char                       # ina [rb + char]
    eq  [rb + char], -1, [rb + tmp]
    jnz [rb + tmp], .done

    # Continue the escape sequence
    eq  [rb + char], 0x30, [rb + tmp]
    jnz [rb + tmp], .function_9_10_wait
    eq  [rb + char], 0x31, [rb + tmp]
    jnz [rb + tmp], .function_9_10_wait

    jz  0, .done

.function_9_10_wait:
    # Function keys F9 and F10; char 0x30-0x31 maps to make code 0x43-0x44
    add [rb + char], 0x13, [current_make_code]

    # Wait for 7e, then make and break with the code we just prepared
    add .7e_make_break, 0, [keyboard_state]
    jz  0, .done


.7e_make_break:
    # Read next character if available
    db  213, char                       # ina [rb + char]
    eq  [rb + char], -1, [rb + tmp]
    jnz [rb + tmp], .done

    # Expect to receive 7e, then make and break the prepared character
    eq  [rb + char], 0x7e, [rb + tmp]
    jnz [rb + tmp], .generic_lowercase_make_break

    jz  0, .done



# 0x47-0x53 = num pad: 789- 456+ 123 ins del
#
# 1b 5b 41 up
# 1b 5b 42 down
# 1b 5b 44 left
# 1b 5b 43 right
# 1b 5b 48 home
# 1b 5b 46 end
# 1b 5b 45 5
# 1b 5b 35 7e pgup
# 1b 5b 36 7e pgdn
# 1b 5b 32 7e ins
# 1b 5b 33 7e del



.generic_lowercase_make_break:
    # Do we need to change shift status?
    jz  [shift_pressed], .generic_make_break

    # Yes, output break code for right shift
    add 0xb6, 0, [ppi_a]
    add 0, 0, [shift_pressed]

    # Follow up with make and break code for current character
    add .generic_make_break, 0, [keyboard_state]
    jz  0, .raise_irq1

.generic_uppercase_make_break:
    # Do we need to change shift status?
    jnz [shift_pressed], .generic_make_break

    # Yes, output make code for right shift
    add 0x36, 0, [ppi_a]
    add 1, 0, [shift_pressed]

    # Follow up with make and break code for current character
    add .generic_make_break, 0, [keyboard_state]
    jz  0, .raise_irq1

.generic_make_break:
    # Output the pre-calculated make code
    add [current_make_code], 0, [ppi_a]

    # Follow up with break code
    add .generic_break, 0, [keyboard_state]
    jz  0, .raise_irq1

.generic_break:
    # Output the pre-calculated break code
    add [current_make_code], 0x80, [ppi_a]

    # We are done with this character
    add .initial, 0, [keyboard_state]
    jz  0, .raise_irq1


.raise_irq1:
    add 1, 0, [rb - 1]
    arb -1
    call interrupt_request

.done:
    arb 3
    ret 0
.ENDFRAME

##########
keyboard_state:
    db  handle_keyboard.initial

current_make_code:
    db  -1

shift_pressed:
    db  0

.EOF
