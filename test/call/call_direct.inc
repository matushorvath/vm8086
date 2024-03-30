    ; test CALL NEAR/FAR, RET 0 NEAR/FAR, RET N NEAR/FAR

    dump_state                          ; 1n
    call near near_forward

    dump_state                          ; 5n
    jmp test_far

near_backward:
    dump_state                          ; 3n
    retn 2

near_forward:
    dump_state                          ; 2n
    push ax
    call near near_backward
    dump_state                          ; 4n
    retn

test_far:
    dump_state                          ; 1f
    call extra_seg:far_absolute_2
    dump_state                          ; 5f

    jmp test_end

    ; far target in .text segment
far_absolute_1:
    dump_state                          ; 3f
    retf 2

test_end:


    ; far target in extra segment
[section far_target start=extra_addr]

far_absolute_2:
    ; TODO this does not work in bochs, it needs a far call
    dump_state                          ; 2f
    ; TODO remove db  3 dup 0x90
    push ax
    call text_seg:far_absolute_1
    dump_state                          ; 4f
    ; TODO remove db  3 dup 0x90
    retf 0

__?SECT?__
