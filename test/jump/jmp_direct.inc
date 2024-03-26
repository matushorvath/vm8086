; TODO carry from low byte (reg_ip low byte + short pointer is more than 0x100)
; TODO borrow to low byte (reg_ip low byte + short pointer is less than 0)
; TODO overflow (reg_ip + short pointer is more than 0x1000)
; TODO underflow (reg_ip + short pointer is less than 0)

    ; test JMP SHORT, JMP NEAR, JMP FAR

    ; if we execute anything we shouldn't, ax will be set to 0
    mov ax, 1
    out 0x42, al


    jmp short_forward                   ; 1s
    mov ax, 0

short_backward:
    out 0x42, al                        ; 3s
    jmp test_near
    mov ax, 0

short_forward:
    out 0x42, al                        ; 2s
    jmp short_backward
    mov ax, 0


test_near:
    jmp near_forward                    ; 1n
    mov ax, 0

near_backward:
    out 0x42, al                        ; 3n
    jmp test_far
    mov ax, 0

    ; make sure the distance requires a NEAR jump
    db  256 dup 0

near_forward:
    out 0x42, al                        ; 2n
    jmp near_backward
    mov ax, 0


test_far:
    jmp 0x9000:far_absolute             ; 1f
    mov ax, 0

test_end:
    out 0x42, al                        ; 3f


    ; far target in another segment, then resume current segment
[section far_target start=0x90000]

far_absolute:
    out 0x42, al                        ; 2f
    jmp 0x8000:test_end
    mov ax, 0

__?SECT?__
