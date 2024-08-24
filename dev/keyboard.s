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
    add 0, 0, [ctrl_needed]
    add 0, 0, [alt_needed]
    add 0, 0, [shift_needed]

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

    jz  0, .generic_make_break

.initial_uppercase:
    # Output make and break code for current character, with shift pressed
    add scancode + 1, [rb + char_x2], [ip + 1]
    add [0], 0, [current_make_code]
    add 1, 0, [shift_needed]

    jz  0, .generic_make_break


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
    jz  0, .generic_make_break

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
    jz  0, .generic_make_break


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
    add .xx_xx_7e_trailer, 0, [keyboard_state]
    jz  0, .done

.pgup_wait:
    add 0x49, 0, [current_make_code]

    # Wait for 7e, then make and break with the code we just prepared
    add .xx_xx_7e_trailer, 0, [keyboard_state]
    jz  0, .done

.pgdn_wait:
    add 0x51, 0, [current_make_code]

    # Wait for 7e, then make and break with the code we just prepared
    add .xx_xx_7e_trailer, 0, [keyboard_state]
    jz  0, .done

.arrow_up:
    add 0x48, 0, [current_make_code]
    jz  0, .generic_make_break

.arrow_down:
    add 0x50, 0, [current_make_code]
    jz  0, .generic_make_break

.arrow_right:
    add 0x4d, 0, [current_make_code]
    jz  0, .generic_make_break

.arrow_left:
    add 0x4b, 0, [current_make_code]
    jz  0, .generic_make_break

.numpad_5:
    add 0x4c, 0, [current_make_code]
    jz  0, .generic_make_break

.end:
    add 0x4f, 0, [current_make_code]
    jz  0, .generic_make_break

.home:
    add 0x47, 0, [current_make_code]
    jz  0, .generic_make_break


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
    add .xx_xx_7e_trailer, 0, [keyboard_state]
    jz  0, .done

.function_6_to_8_wait:
    # Function keys F6 to F8; char 0x37-0x39 maps to make code 0x40-0x42
    add [rb + char], 0x9, [current_make_code]

    # Wait for 7e, then make and break with the code we just prepared
    add .xx_xx_7e_trailer, 0, [keyboard_state]
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
    eq  [rb + char], 0x32, [rb + tmp]
    jnz [rb + tmp], .esc_5b_31_3b_32_wait
    eq  [rb + char], 0x33, [rb + tmp]
    jnz [rb + tmp], .esc_5b_31_3b_33_wait
    eq  [rb + char], 0x34, [rb + tmp]
    jnz [rb + tmp], .esc_5b_31_3b_34_wait
    eq  [rb + char], 0x35, [rb + tmp]
    jnz [rb + tmp], .esc_5b_31_3b_35_wait
    eq  [rb + char], 0x36, [rb + tmp]
    jnz [rb + tmp], .esc_5b_31_3b_36_wait
    eq  [rb + char], 0x37, [rb + tmp]
    jnz [rb + tmp], .esc_5b_31_3b_37_wait
    eq  [rb + char], 0x38, [rb + tmp]
    jnz [rb + tmp], .esc_5b_31_3b_38_wait

    jz  0, .done

.esc_5b_31_3b_32_wait:
    # Press the modifiers, continue with the base F1 to F4 sequence
    add 1, 0, [shift_needed]

    add .esc_4f, 0, [keyboard_state]
    jz  0, .done

.esc_5b_31_3b_33_wait:
    # Press the modifiers, continue with the base F1 to F4 sequence
    add 1, 0, [alt_needed]

    add .esc_4f, 0, [keyboard_state]
    jz  0, .done

.esc_5b_31_3b_34_wait:
    # Press the modifiers, continue with the base F1 to F4 sequence
    add 1, 0, [alt_needed]
    add 1, 0, [shift_needed]

    add .esc_4f, 0, [keyboard_state]
    jz  0, .done

.esc_5b_31_3b_35_wait:
    # Press the modifiers, continue with the base F1 to F4 sequence
    add 1, 0, [ctrl_needed]

    add .esc_4f, 0, [keyboard_state]
    jz  0, .done

.esc_5b_31_3b_36_wait:
    # Press the modifiers, continue with the base F1 to F4 sequence
    add 1, 0, [ctrl_needed]
    add 1, 0, [shift_needed]

    add .esc_4f, 0, [keyboard_state]
    jz  0, .done

.esc_5b_31_3b_37_wait:
    # Press the modifiers, continue with the base F1 to F4 sequence
    add 1, 0, [ctrl_needed]
    add 1, 0, [alt_needed]

    add .esc_4f, 0, [keyboard_state]
    jz  0, .done

.esc_5b_31_3b_38_wait:
    # Press the modifiers, continue with the base F1 to F4 sequence
    add 1, 0, [ctrl_needed]
    add 1, 0, [alt_needed]
    add 1, 0, [shift_needed]

    add .esc_4f, 0, [keyboard_state]
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

    eq  [rb + char], 0x7e, [rb + tmp]
    jnz [rb + tmp], .insert

    jz  0, .done

.function_9_10_wait:
    # Function keys F9 and F10; char 0x30-0x31 maps to make code 0x43-0x44
    add [rb + char], 0x13, [current_make_code]

    # Wait for 7e, then make and break with the code we just prepared
    add .xx_xx_7e_trailer, 0, [keyboard_state]
    jz  0, .done

.insert:
    add 0x52, 0, [current_make_code]
    jz  0, .generic_make_break


.xx_xx_7e_trailer:
    # Read next character if available
    db  213, char                       # ina [rb + char]
    eq  [rb + char], -1, [rb + tmp]
    jnz [rb + tmp], .done

    # The trailer could be one of:
    # 7e: no ctrl, no alt, no shift
    # 3b xx 7e, where xx is 32 - 38: combinations of ctrl, alt and shift are pressed

    eq  [rb + char], 0x7e, [rb + tmp]
    jnz [rb + tmp], .generic_make_break
    eq  [rb + char], 0x3b, [rb + tmp]
    jnz [rb + tmp], .3b_xx_7e_trailer_wait

    jz  0, .done

.3b_xx_7e_trailer_wait:
    add .3b_xx_7e_trailer, 0, [keyboard_state]
    jz  0, .done


.3b_xx_7e_trailer:
    # Read next character if available
    db  213, char                       # ina [rb + char]
    eq  [rb + char], -1, [rb + tmp]
    jnz [rb + tmp], .done

    # Continue the escape sequence
    eq  [rb + char], 0x32, [rb + tmp]
    jnz [rb + tmp], .3b_32_7e_trailer_wait
    eq  [rb + char], 0x33, [rb + tmp]
    jnz [rb + tmp], .3b_33_7e_trailer_wait
    eq  [rb + char], 0x34, [rb + tmp]
    jnz [rb + tmp], .3b_34_7e_trailer_wait
    eq  [rb + char], 0x35, [rb + tmp]
    jnz [rb + tmp], .3b_35_7e_trailer_wait
    eq  [rb + char], 0x36, [rb + tmp]
    jnz [rb + tmp], .3b_36_7e_trailer_wait
    eq  [rb + char], 0x37, [rb + tmp]
    jnz [rb + tmp], .3b_37_7e_trailer_wait
    eq  [rb + char], 0x38, [rb + tmp]
    jnz [rb + tmp], .3b_38_7e_trailer_wait

    jz  0, .done

.3b_32_7e_trailer_wait:
    # Press the modifiers, then expect a 7e
    add 1, 0, [shift_needed]

    add .7e_trailer, 0, [keyboard_state]
    jz  0, .done

.3b_33_7e_trailer_wait:
    # Press the modifiers, then expect a 7e
    add 1, 0, [alt_needed]

    add .7e_trailer, 0, [keyboard_state]
    jz  0, .done

.3b_34_7e_trailer_wait:
    # Press the modifiers, then expect a 7e
    add 1, 0, [alt_needed]
    add 1, 0, [shift_needed]

    add .7e_trailer, 0, [keyboard_state]
    jz  0, .done

.3b_35_7e_trailer_wait:
    # Press the modifiers, then expect a 7e
    add 1, 0, [ctrl_needed]

    add .7e_trailer, 0, [keyboard_state]
    jz  0, .done

.3b_36_7e_trailer_wait:
    # Press the modifiers, then expect a 7e
    add 1, 0, [ctrl_needed]
    add 1, 0, [shift_needed]

    add .7e_trailer, 0, [keyboard_state]
    jz  0, .done

.3b_37_7e_trailer_wait:
    # Press the modifiers, then expect a 7e
    add 1, 0, [ctrl_needed]
    add 1, 0, [alt_needed]

    add .7e_trailer, 0, [keyboard_state]
    jz  0, .done

.3b_38_7e_trailer_wait:
    # Press the modifiers, then expect a 7e
    add 1, 0, [ctrl_needed]
    add 1, 0, [alt_needed]
    add 1, 0, [shift_needed]

    add .7e_trailer, 0, [keyboard_state]
    jz  0, .done


.7e_trailer:
    # Read next character if available
    db  213, char                       # ina [rb + char]
    eq  [rb + char], -1, [rb + tmp]
    jnz [rb + tmp], .done

    # Expect to receive 7e, then make and break the prepared character
    eq  [rb + char], 0x7e, [rb + tmp]
    jnz [rb + tmp], .generic_make_break

    jz  0, .done


.generic_make_break:
    # Do we need to change ctrl state?
    eq  [ctrl_pressed], [ctrl_needed], [rb + tmp]
    jnz [rb + tmp], .generic_make_break_have_ctrl

    # Yes, output make/break code for ctrl
    mul [ctrl_needed], -0x80, [ppi_a]
    add [ppi_a], 0x9d, [ppi_a]
    add [ctrl_needed], 0, [ctrl_pressed]

    # Plan the follow up action and raise IRQ1
    add .generic_make_break_have_ctrl, 0, [keyboard_state]
    jz  0, .raise_irq1

.generic_make_break_have_ctrl:
    # Do we need to change alt state?
    eq  [alt_pressed], [alt_needed], [rb + tmp]
    jnz [rb + tmp], .generic_make_break_have_alt

    # Yes, output make/break code for alt
    mul [alt_needed], -0x80, [ppi_a]
    add [ppi_a], 0xb8, [ppi_a]
    add [alt_needed], 0, [alt_pressed]

    # Plan the follow up action and raise IRQ1
    add .generic_make_break_have_alt, 0, [keyboard_state]
    jz  0, .raise_irq1

.generic_make_break_have_alt:
    # Do we need to change shift state?
    eq  [shift_pressed], [shift_needed], [rb + tmp]
    jnz [rb + tmp], .generic_make_break_have_shift

    # Yes, output make/break code for right shift
    mul [shift_needed], -0x80, [ppi_a]
    add [ppi_a], 0xb6, [ppi_a]
    add [shift_needed], 0, [shift_pressed]

    # Plan the follow up action and raise IRQ1
    add .generic_make_break_have_shift, 0, [keyboard_state]
    jz  0, .raise_irq1

.generic_make_break_have_shift:
    # Output the pre-calculated make code
    add [current_make_code], 0, [ppi_a]

    # Plan to follow up with break code and raise IRQ1
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

ctrl_needed:
    db  0
alt_needed:
    db  0
shift_needed:
    db  0

.EOF
