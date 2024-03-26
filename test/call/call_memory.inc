    ; test CALL MEM16 (NEAR), CALL MEM16 (FAR)

    out 0x42, al                        ; 1n
    mov word [call_offset], near_forward_mem
    call [call_offset]

    out 0x42, al                        ; 5n
    jmp test_far_mem

near_backward_mem:
    out 0x42, al                        ; 3n
    retn 2

near_forward_mem:
    out 0x42, al                        ; 2n
    push ax
    mov word [call_offset], near_backward_mem
    call [call_offset]
    out 0x42, al                        ; 4n
    retn

test_far_mem:
    out 0x42, al                        ; 1f
    mov word [call_offset], far_absolute_a000_mem
    mov word [call_segment], 0xa000
    call far [call_offset]
    out 0x42, al                        ; 5f


    ; far target in another segment
[section far_target start=0x90000]

far_absolute_9000_mem:
    out 0x42, al                        ; 3f
    retf 2

__?SECT?__

    ; far target in yet another segment
[section far_target_2 start=0xa0000]

far_absolute_a000_mem:
    out 0x42, al                        ; 2f
    push ax
    mov word [call_offset], far_absolute_9000_mem
    mov word [call_segment], 0x9000
    call far [call_offset]
    out 0x42, al                        ; 4f
    retf 0

__?SECT?__


    ; storage for the pointer we jump to
[section .data start=0x10000]

call_offset:
    dw  0
call_segment:
    dw  0

__?SECT?__
