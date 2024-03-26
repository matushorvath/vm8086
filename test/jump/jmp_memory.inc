; TODO carry from low byte (reg_ip low byte + short pointer is more than 0x100)
; TODO borrow to low byte (reg_ip low byte + short pointer is less than 0)
; TODO overflow (reg_ip + short pointer is more than 0x1000)
; TODO underflow (reg_ip + short pointer is less than 0)

    ; test JMP MEM16 (NEAR), JMP MEM16 (FAR)

    ; if we execute anything we shouldn't, ax will be set to 0
    mov ax, 1
    out 0x42, al


test_near_mem:
    mov word [jmp_offset], near_forward_mem
    jmp [jmp_offset]                    ; 1n
    mov ax, 0

near_backward_mem:
    out 0x42, al                        ; 3n
    mov word [jmp_offset], test_far_mem
    jmp [jmp_offset]
    mov ax, 0

    ; make sure the distance requires a NEAR jump
    db  256 dup 0

near_forward_mem:
    out 0x42, al                        ; 2n
    mov word [jmp_offset], near_backward_mem
    jmp [jmp_offset]
    mov ax, 0


test_far_mem:
    mov word [jmp_offset], far_absolute_mem  ; 1f
    mov word [jmp_segment], 0x9000
    jmp far [jmp_offset]
    mov ax, 0

test_end_mem:
    out 0x42, al                        ; 3f


    ; far target in another segment, then resume current segment
[section far_target start=0x90000]

far_absolute_mem:
    out 0x42, al                        ; 2f
    mov word [jmp_offset], test_end_mem
    mov word [jmp_segment], 0x8000
    jmp far [jmp_offset]
    mov ax, 0

__?SECT?__


    ; storage for the pointer we jump to
[section .data start=0x10000]

jmp_offset:
    dw  0
jmp_segment:
    dw  0

__?SECT?__
