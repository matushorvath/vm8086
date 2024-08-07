    ; test CALL MEM16 (NEAR), CALL MEM16 (FAR)

bss_seg     equ 0x8000

    mov ax, bss_seg
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
    mov word [call_offset], far_absolute_2_mem
    mov word [call_segment], extra_seg
    call far [call_offset]
    dump_state                          ; 5f

    jmp test_end_mem

    ; far target in .text segment
far_absolute_1_mem:
    dump_state                          ; 3f
    retf 2

test_end_mem:


    ; far target in extra segment
[section far_target start=extra_addr]

far_absolute_2_mem:
    dump_state                          ; 2f
    push ax
    mov word [call_offset], far_absolute_1_mem
    mov word [call_segment], text_seg
    call far [call_offset]
    dump_state                          ; 4f
    retf 0

__?SECT?__


    ; storage for the pointer we jump to
[section .bss start=(bss_seg * 0x10)]

call_offset:
    resw 1
call_segment:
    resw 1

__?SECT?__
