; TODO carry from low byte (reg_ip low byte + short pointer is more than 0x100)
; TODO borrow to low byte (reg_ip low byte + short pointer is less than 0)
; TODO overflow (reg_ip + short pointer is more than 0x1000)
; TODO underflow (reg_ip + short pointer is less than 0)

    ; test JMP MEM16 (NEAR), JMP MEM16 (FAR)

    ; if we execute anything we shouldn't, ax will be set to 0
    mov ax, 1
    dump_state


test_near_mem:
    mov word [jmp_offset], near_forward_mem
    jmp [jmp_offset]                    ; 1n
    mov ax, 0

near_backward_mem:
    dump_state                        ; 3n
    mov word [jmp_offset], test_far_mem
    jmp [jmp_offset]
    mov ax, 0

    ; make sure the distance requires a NEAR jump
    db  256 dup 0

near_forward_mem:
    dump_state                        ; 2n
    mov word [jmp_offset], near_backward_mem
    jmp [jmp_offset]
    mov ax, 0


test_far_mem:
    ; TODO the segment isn't a round number
    mov word [jmp_offset], far_absolute_mem - 0x4000        ; 1f
    mov word [jmp_segment], 0xe400
    jmp far [jmp_offset]
    mov ax, 0

test_end_mem:
    dump_state                        ; 3f


    ; far target in another segment, then resume current segment
[section far_target start=0xe4000]

far_absolute_mem:
    dump_state                        ; 2f
    mov word [jmp_offset], test_end_mem
    mov word [jmp_segment], 0xd000
    jmp far [jmp_offset]
    mov ax, 0

__?SECT?__


    ; storage for the pointer we jump to
[section .data start=0xe0000]

jmp_offset:
    dw  0
jmp_segment:
    dw  0

__?SECT?__
