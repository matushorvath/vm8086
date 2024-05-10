; TODO carry from low byte (reg_ip low byte + short pointer is more than 0x100)
; TODO borrow to low byte (reg_ip low byte + short pointer is less than 0)
; TODO overflow (reg_ip + short pointer is more than 0x1000)
; TODO underflow (reg_ip + short pointer is less than 0)

    ; test JMP SHORT, JMP NEAR, JMP FAR

    ; if we execute anything we shouldn't, ax will be set to 0
    mov ax, 1
    dump_state


    jmp short_forward                   ; 1s
    mov ax, 0

short_backward:
    dump_state                          ; 3s
    jmp test_near
    mov ax, 0

short_forward:
    dump_state                          ; 2s
    jmp short_backward
    mov ax, 0


test_near:
    jmp near_forward                    ; 1n
    mov ax, 0

near_backward:
    dump_state                          ; 3n
    jmp test_far
    mov ax, 0

    ; make sure the distance requires a NEAR jump
    db  256 dup 0

near_forward:
    dump_state                          ; 2n
    jmp near_backward
    mov ax, 0


test_far:
    jmp extra_seg:far_absolute          ; 1f
    mov ax, 0

test_end:
    dump_state                          ; 3f


    ; far target in extra segment
[section far_target start=extra_addr]

far_absolute:
    dump_state                          ; 2f
    jmp text_seg:test_end
    mov ax, 0

__?SECT?__
