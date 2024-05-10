%include "common.inc"


section .text
    dump_state

    ; wait should not return without a coprocessor on an 8086, but it
    ; does return on later processors, so we emulate it that way
    fwait

    dump_state

    ; detect the 8087, should result in nothing detected
    ; this uses some esc instructions as a side effect
    mov bp, sp
    xor ax, ax
    push ax

    fninit
    fnstcw [word bp - 2]

    pop ax

    ; ah should be 0 if no 8087, 3 if 8087 was detected
    ; bochs has an 8087, vm8086 does not, so we accept both values

    pushf
    test ax, ax
    jnz .skip_fake_8087
    mov ax, 0x037f
.skip_fake_8087
    popf

    dump_state

    call power_off
