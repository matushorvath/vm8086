.EXPORT handle_keyboard

# From scancode.s
.IMPORT scancode

# From dev/pic_8259a_execute.s
.IMPORT interrupt_request

# From dev/ppi_8255a.s
.IMPORT ppi_a

# TODO what should happen if keys are pressed faster than BIOS can receive them?
# TODO avoid pressing and releasing shift unless necessary (remember shift state)
# TODO support repeating a key while it's held
# TODO consider moving outside of dev/ to kbd/
# TODO check why keyboard doesn't work in Arcade Volleyball


# TODO remove
# 1b 5b 31 35 3b 33 7e
# 1b 5b 31 37 3b 33 7e
# 1b 5b 31 38 3b 33 7e
# 1b 5b 31 39 3b 33 7e
# 
# 1b 5b 32 30 3b 33 7e
# 1b 5b 32 31 3b 33 7e
# 1b 5b 32 33 3b 33 7e
# 1b 5b 32 34 3b 33 7e


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

    jz  0, .generic_make_break_cas

.initial_uppercase:
    # Output make and break code for current character, with shift pressed
    add scancode + 1, [rb + char_x2], [ip + 1]
    add [0], 0, [current_make_code]

    jz  0, .generic_make_break_caS


.initial_escape:
    # Escape character, process an escape sequence
    add .esc, 0, [keyboard_state]
    jz  0, .done

.esc:
    # Read next character if available
    db  213, char                       # ina [rb + char]
    eq  [rb + char], -1, [rb + tmp]
    jnz [rb + tmp], .esc_nothing

    # Continue the escape sequence
    eq  [rb + char], 0x4f, [rb + tmp]
    jnz [rb + tmp], .esc_4f_wait
    eq  [rb + char], 0x5b, [rb + tmp]
    jnz [rb + tmp], .esc_5b_wait

    jz  0, .done

.esc_nothing:
    # Escape followed by nothing, press the escape key
    add 0x01, 0, [current_make_code]
    jz  0, .generic_make_break_cas

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
    jz  0, .generic_make_break_cas


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

    eq  [rb + char], 0x33, [rb + tmp]
    jnz [rb + tmp], .delete_wait
    eq  [rb + char], 0x35, [rb + tmp]
    jnz [rb + tmp], .pgup_wait
    eq  [rb + char], 0x36, [rb + tmp]
    jnz [rb + tmp], .pgdn_wait

    eq  [rb + char], 0x41, [rb + tmp]
    jnz [rb + tmp], .arrow_up
    eq  [rb + char], 0x42, [rb + tmp]
    jnz [rb + tmp], .arrow_down
    eq  [rb + char], 0x43, [rb + tmp]
    jnz [rb + tmp], .arrow_right
    eq  [rb + char], 0x44, [rb + tmp]
    jnz [rb + tmp], .arrow_left

    eq  [rb + char], 0x45, [rb + tmp]
    jnz [rb + tmp], .numpad_5
    eq  [rb + char], 0x46, [rb + tmp]
    jnz [rb + tmp], .end
    eq  [rb + char], 0x48, [rb + tmp]
    jnz [rb + tmp], .home

    eq  [rb + char], 0x45, [rb + tmp]
    jnz [rb + tmp], .numpad_5

    jz  0, .done

.esc_5b_31_wait:
    add .esc_5b_31, 0, [keyboard_state]
    jz  0, .done

.esc_5b_32_wait:
    add .esc_5b_32, 0, [keyboard_state]
    jz  0, .done

.delete_wait:
    add 0x53, 0, [current_make_code]

    # Wait for 7e, then make and break with the code we just prepared
    add .7e_make_break, 0, [keyboard_state]
    jz  0, .done

.pgup_wait:
    add 0x49, 0, [current_make_code]

    # Wait for 7e, then make and break with the code we just prepared
    add .7e_make_break, 0, [keyboard_state]
    jz  0, .done

.pgdn_wait:
    add 0x51, 0, [current_make_code]

    # Wait for 7e, then make and break with the code we just prepared
    add .7e_make_break, 0, [keyboard_state]
    jz  0, .done

.arrow_up:
    add 0x48, 0, [current_make_code]
    jz  0, .generic_make_break_cas

.arrow_down:
    add 0x50, 0, [current_make_code]
    jz  0, .generic_make_break_cas

.arrow_right:
    add 0x4d, 0, [current_make_code]
    jz  0, .generic_make_break_cas

.arrow_left:
    add 0x4b, 0, [current_make_code]
    jz  0, .generic_make_break_cas

.numpad_5:
    add 0x4c, 0, [current_make_code]
    jz  0, .generic_make_break_cas

.end:
    add 0x4f, 0, [current_make_code]
    jz  0, .generic_make_break_cas

.home:
    add 0x47, 0, [current_make_code]
    jz  0, .generic_make_break_cas


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

    eq  [rb + char], 0x3b, [rb + tmp]
    jnz [rb + tmp], .esc_5b_31_3b_wait

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

.esc_5b_31_3b_wait:
    add .esc_5b_31_3b, 0, [keyboard_state]
    jz  0, .done


.esc_5b_31_3b:
    # Read next character if available
    db  213, char                       # ina [rb + char]
    eq  [rb + char], -1, [rb + tmp]
    jnz [rb + tmp], .done

    # Continue the escape sequence
    eq  [rb + char], 0x33, [rb + tmp]
    jnz [rb + tmp], .esc_5b_31_3b_33_wait

    jz  0, .done

.esc_5b_31_3b_33_wait:
    add .esc_5b_31_3b_33, 0, [keyboard_state]
    jz  0, .done


.esc_5b_31_3b_33:
    # Read next character if available
    db  213, char                       # ina [rb + char]
    eq  [rb + char], -1, [rb + tmp]
    jnz [rb + tmp], .done

    # Continue the escape sequence
    eq  [rb + char], 0x50, [rb + tmp]
    jnz [rb + tmp], .alt_function_1_to_4_wait
    eq  [rb + char], 0x51, [rb + tmp]
    jnz [rb + tmp], .alt_function_1_to_4_wait
    eq  [rb + char], 0x52, [rb + tmp]
    jnz [rb + tmp], .alt_function_1_to_4_wait
    eq  [rb + char], 0x53, [rb + tmp]
    jnz [rb + tmp], .alt_function_1_to_4_wait

    jz  0, .done

.alt_function_1_to_4_wait:
    # Alt + function keys F1 to F4; char 0x50-0x53 maps to make code 0x3b-0x3e
    add [rb + char], -0x15, [current_make_code]
    jz  0, .generic_make_break_cAs


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

    eq  [rb + char], 0x7e, [rb + tmp]
    jnz [rb + tmp], .insert

    jz  0, .done

.function_9_10_wait:
    # Function keys F9 and F10; char 0x30-0x31 maps to make code 0x43-0x44
    add [rb + char], 0x13, [current_make_code]

    # Wait for 7e, then make and break with the code we just prepared
    add .7e_make_break, 0, [keyboard_state]
    jz  0, .done

.insert:
    add 0x52, 0, [current_make_code]
    jz  0, .generic_make_break_cas


.7e_make_break:
    # Read next character if available
    db  213, char                       # ina [rb + char]
    eq  [rb + char], -1, [rb + tmp]
    jnz [rb + tmp], .done

    # Expect to receive 7e, then make and break the prepared character
    eq  [rb + char], 0x7e, [rb + tmp]
    jnz [rb + tmp], .generic_make_break_cas

    jz  0, .done


# c/C = Ctrl state
# a/A = Alt state
# s/S = Shift state

.generic_make_break_cas:
    # Do we need to change ctrl state?
    jz  [ctrl_pressed], .generic_make_break_as

    # Yes, output break code for ctrl
    add 0x9d, 0, [ppi_a]
    add 0, 0, [ctrl_pressed]

    # Continue outputting current character afterwards
    add .generic_make_break_as, 0, [keyboard_state]
    jz  0, .raise_irq1

.generic_make_break_caS:
    # Do we need to change ctrl state?
    jz  [ctrl_pressed], .generic_make_break_aS

    # Yes, output break code for ctrl
    add 0x9d, 0, [ppi_a]
    add 0, 0, [ctrl_pressed]

    # Continue outputting current character afterwards
    add .generic_make_break_aS, 0, [keyboard_state]
    jz  0, .raise_irq1

.generic_make_break_cAs:
    # Do we need to change ctrl state?
    jz  [ctrl_pressed], .generic_make_break_As

    # Yes, output break code for ctrl
    add 0x9d, 0, [ppi_a]
    add 0, 0, [ctrl_pressed]

    # Continue outputting current character afterwards
    add .generic_make_break_As, 0, [keyboard_state]
    jz  0, .raise_irq1

.generic_make_break_cAS:
    # Do we need to change ctrl state?
    jz  [ctrl_pressed], .generic_make_break_AS

    # Yes, output break code for ctrl
    add 0x9d, 0, [ppi_a]
    add 0, 0, [ctrl_pressed]

    # Continue outputting current character afterwards
    add .generic_make_break_AS, 0, [keyboard_state]
    jz  0, .raise_irq1


.generic_make_break_Cas:
    # Do we need to change ctrl state?
    jnz [ctrl_pressed], .generic_make_break_as

    # Yes, output make code for ctrl
    add 0x1d, 0, [ppi_a]
    add 1, 0, [ctrl_pressed]

    # Continue outputting current character afterwards
    add .generic_make_break_as, 0, [keyboard_state]
    jz  0, .raise_irq1

.generic_make_break_CaS:
    # Do we need to change ctrl state?
    jnz [ctrl_pressed], .generic_make_break_aS

    # Yes, output make code for ctrl
    add 0x1d, 0, [ppi_a]
    add 1, 0, [ctrl_pressed]

    # Continue outputting current character afterwards
    add .generic_make_break_aS, 0, [keyboard_state]
    jz  0, .raise_irq1

.generic_make_break_CAs:
    # Do we need to change ctrl state?
    jnz [ctrl_pressed], .generic_make_break_As

    # Yes, output make code for ctrl
    add 0x1d, 0, [ppi_a]
    add 1, 0, [ctrl_pressed]

    # Continue outputting current character afterwards
    add .generic_make_break_As, 0, [keyboard_state]
    jz  0, .raise_irq1

.generic_make_break_CAS:
    # Do we need to change ctrl state?
    jnz [ctrl_pressed], .generic_make_break_AS

    # Yes, output make code for ctrl
    add 0x1d, 0, [ppi_a]
    add 1, 0, [ctrl_pressed]

    # Continue outputting current character afterwards
    add .generic_make_break_AS, 0, [keyboard_state]
    jz  0, .raise_irq1


.generic_make_break_as:
    # Do we need to change alt state?
    jz  [alt_pressed], .generic_make_break_s

    # Yes, output break code for alt
    add 0xb8, 0, [ppi_a]
    add 0, 0, [alt_pressed]

    # Continue outputting current character afterwards
    add .generic_make_break_s, 0, [keyboard_state]
    jz  0, .raise_irq1

.generic_make_break_aS:
    # Do we need to change alt state?
    jz  [alt_pressed], .generic_make_break_S

    # Yes, output break code for alt
    add 0xb8, 0, [ppi_a]
    add 0, 0, [alt_pressed]

    # Continue outputting current character afterwards
    add .generic_make_break_S, 0, [keyboard_state]
    jz  0, .raise_irq1

.generic_make_break_As:
    # Do we need to change alt state?
    jnz [alt_pressed], .generic_make_break_s

    # Yes, output make code for alt
    add 0x38, 0, [ppi_a]
    add 1, 0, [alt_pressed]

    # Continue outputting current character afterwards
    add .generic_make_break_s, 0, [keyboard_state]
    jz  0, .raise_irq1

.generic_make_break_AS:
    # Do we need to change alt state?
    jnz [alt_pressed], .generic_make_break_S

    # Yes, output make code for alt
    add 0x38, 0, [ppi_a]
    add 1, 0, [alt_pressed]

    # Continue outputting current character afterwards
    add .generic_make_break_S, 0, [keyboard_state]
    jz  0, .raise_irq1


.generic_make_break_s:
    # Do we need to change shift state?
    jz  [shift_pressed], .generic_make_break

    # Yes, output break code for right shift
    add 0xb6, 0, [ppi_a]
    add 0, 0, [shift_pressed]

    # Continue outputting current character afterwards
    add .generic_make_break, 0, [keyboard_state]
    jz  0, .raise_irq1

.generic_make_break_S:
    # Do we need to change shift state?
    jnz [shift_pressed], .generic_make_break

    # Yes, output make code for right shift
    add 0x36, 0, [ppi_a]
    add 1, 0, [shift_pressed]

    # Continue outputting current character afterwards
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

ctrl_pressed:
    db  0
alt_pressed:
    db  0
shift_pressed:
    db  0

.EOF
