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
.FRAME tmp
    arb -1

    # Wait until BIOS reads and acknowledges ppi_a by setting bit 7 in ppi_b (which will also clear ppi_a)
    #jnz [ppi_a], .done                 # optimization, this was moved outside of this function

    # State machine to translate stdin characters into keyboard scan codes
    jz  0, [keyboard_state]

.initial:
    # Previous input is fully processed, start from scratch

    # Read a new character, if available
    db  13, current_char                # ina [current_char]
    eq  [current_char], -1, [rb + tmp]
    jnz [rb + tmp], .done

    mul [current_char], 3, [current_char_x3]

    # There is a character, what should we do with it?
    add scancode + 0, [current_char_x3], [ip + 1]
    add [0], .initial_table, [ip + 2]
    jz  0, [0]

.initial_table:
    db  .done                           # 0, ignore this character
    db  .initial_lowercase              # 1, lowercase character, output the make code
    db  .initial_uppercase              # 2, uppercase character, output shift make code
    db  .initial_escape                 # 3, escape, start processing complex input

.initial_lowercase:
    # Output make code for current character
    add scancode + 1, [current_char_x3], [ip + 1]
    add [0], 0, [ppi_a]

    # Follow up with break code
    add .output_break, 0, [keyboard_state]
    jz  0, .raise_irq1

.output_break:
    # Output break code for current character
    add scancode + 2, [current_char_x3], [ip + 1]
    add [0], 0, [ppi_a]

    # We are done with this character
    add .initial, 0, [keyboard_state]
    jz  0, .raise_irq1

.initial_uppercase:
    # Output make code for right shift
    add 0x36, 0, [ppi_a]

    # Follow up with make code, break code and release shift
    add .output_make_break_release_shift, 0, [keyboard_state]
    jz  0, .raise_irq1

.output_make_break_release_shift:
    # Output make code for current character
    add scancode + 1, [current_char_x3], [ip + 1]
    add [0], 0, [ppi_a]

    # Follow up with break code and then release shift
    add .output_break_release_shift, 0, [keyboard_state]
    jz  0, .raise_irq1

.output_break_release_shift:
    # Output break code for current character
    add scancode + 2, [current_char_x3], [ip + 1]
    add [0], 0, [ppi_a]

    # Follow up with releasing shift
    add .output_release_shift, 0, [keyboard_state]
    jz  0, .raise_irq1

.output_release_shift:
    # Output break code for right shift
    add 0xb6, 0, [ppi_a]

    # We are done with this character
    add .initial, 0, [keyboard_state]
    jz  0, .raise_irq1

.initial_escape:
    # Escape character, process an escape sequence
    add .esc, 0, [keyboard_state]
    jz  0, .done

.esc:
    # Read next character in the escape sequence, if available
    db  13, current_char                # ina [current_char]
    eq  [current_char], -1, [rb + tmp]
    jnz [rb + tmp], .done

    eq  [current_char], 0x1b, [rb + tmp]
    jnz [rb + tmp], .esc_esc
#    eq  [current_char], 0x4f, [rb + tmp]
#    jnz [rb + tmp], .esc_4f
#    eq  [current_char], 0x5b, [rb + tmp]
#    jnz [rb + tmp], .esc_5b

    jz  0, .done

.esc_esc:
    # Double escape, output make and break for the escape key
    # TODO do not require two escape key presses to generate the escape
    add 0x01, 0, [ppi_a]

    # Follow up with break code for the escape key
    add .esc_esc_break, 0, [keyboard_state]
    jz  0, .raise_irq1

.esc_esc_break:
    # Output break code for the escape key
    add 0x81, 0, [ppi_a]

    # We are done with this character
    add .initial, 0, [keyboard_state]
    jz  0, .raise_irq1

# TODO function keys
#
# 0x3b-0x44 = f1-f10
#
# 1b 4f 50 = f1
# 1b 4f 51 = f2
# 1b 4f 52 = f3
# 1b 4f 53 = f4
#
# 1b 5b 31 35 7e = f5
# 1b 5b 31 37 7e = f6
# 1b 5b 31 38 7e = f7
# 1b 5b 31 39 7e = f8
#
# 1b 5b 32 30 7e = f9
# 1b 5b 32 31 7e = f10

.raise_irq1:
    add 1, 0, [rb - 1]
    arb -1
    call interrupt_request

.done:
    arb 1
    ret 0
.ENDFRAME

##########
keyboard_state:
    db  handle_keyboard.initial
current_char:
    db  -1
current_char_x3:
    db  -1

.EOF
