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
    db  13, last_char                   # ina [last_char]
    eq  [last_char], -1, [rb + tmp]
    jnz [rb + tmp], .done

    mul [last_char], 3, [last_char_x3]

    # There is a character, should we simulate a pressed shift?
    add scancode + 0, [last_char_x3], [ip + 1]
    jz  [0], .initial_make

    # Yes, output the left right shift scan code
    add 0x36, 0, [ppi_a]

    # Follow up with make code, break code and release shift
    add .output_make_break_shift, 0, [keyboard_state]
    jz  0, .raise_irq1

.initial_make:
    # No shift, output the make code
    add scancode + 1, [last_char_x3], [ip + 1]
    add [0], 0, [ppi_a]

    # Follow up with break code
    add .output_break, 0, [keyboard_state]
    jz  0, .raise_irq1

.output_break:
    # Output the break code for the last character
    add scancode + 2, [last_char_x3], [ip + 1]
    add [0], 0, [ppi_a]

    # We are done with this character
    add .initial, 0, [keyboard_state]
    jz  0, .raise_irq1

.output_make_break_shift:
    # Output the make code for the last character
    add scancode + 1, [last_char_x3], [ip + 1]
    add [0], 0, [ppi_a]

    # Follow up with the break code and then release shift
    add .output_break_shift, 0, [keyboard_state]
    jz  0, .raise_irq1

.output_break_shift:
    # Output the break code for the last character
    add scancode + 2, [last_char_x3], [ip + 1]
    add [0], 0, [ppi_a]

    # Follow up with releasing shift
    add .output_release_shift, 0, [keyboard_state]
    jz  0, .raise_irq1

.output_release_shift:
    # Output the break code for right shift
    add 0xb6, 0, [ppi_a]

    # We are done with this character
    add .initial, 0, [keyboard_state]
    jz  0, .raise_irq1

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
last_char:
    db  -1
last_char_x3:
    db  -1

.EOF
