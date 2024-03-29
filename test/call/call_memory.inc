    ; test CALL MEM16 (NEAR), CALL MEM16 (FAR)

    mov ax, 0xe000
    mov ds, ax

    dump_state                          ; 1n
    mov word [call_offset], near_forward_mem
    call [call_offset]

    dump_state                          ; 5n
    jmp test_far_mem

near_backward_mem:
    dump_state                          ; 3n
    retn 2

near_forward_mem:
    dump_state                          ; 2n
    push ax
    mov word [call_offset], near_backward_mem
    call [call_offset]
    dump_state                          ; 4n
    retn

test_far_mem:
    dump_state                          ; 1f
    mov word [call_offset], far_absolute_2_mem - 0x6000     ; TODO the segment isn't a round number
    mov word [call_segment], 0xe600
    call far [call_offset]
    dump_state                          ; 5f


    ; far target in another segment
[section far_target_1 start=0xe4000]

far_absolute_1_mem:
    dump_state                          ; 3f
    retf 2

__?SECT?__

    ; far target in yet another segment
[section far_target_2 start=0xe6000]

far_absolute_2_mem:
    dump_state                          ; 2f
    push ax
    mov word [call_offset], far_absolute_1_mem - 0x4000     ; TODO the segment isn't a round number
    mov word [call_segment], 0xe400
    call far [call_offset]
    dump_state                          ; 4f
    retf 0

__?SECT?__


    ; storage for the pointer we jump to
[section .data start=0xe0000]

call_offset:
    dw  0
call_segment:
    dw  0

__?SECT?__
