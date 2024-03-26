    ; test CALL NEAR/FAR, RET 0 NEAR/FAR, RET N NEAR/FAR

    out 0x42, al                        ; 1n
    call near near_forward

    out 0x42, al                        ; 5n
    jmp test_far

near_backward:
    out 0x42, al                        ; 3n
    retn 2

near_forward:
    out 0x42, al                        ; 2n
    push ax
    call near near_backward
    out 0x42, al                        ; 4n
    retn

test_far:
    out 0x42, al                        ; 1f
    call 0xa000:far_absolute_a000
    out 0x42, al                        ; 5f


    ; far target in another segment
[section far_target start=0x90000]

far_absolute_9000:
    out 0x42, al                        ; 3f
    retf 2

__?SECT?__

    ; far target in yet another segment
[section far_target_2 start=0xa0000]

far_absolute_a000:
    out 0x42, al                        ; 2f
    push ax
    call 0x9000:far_absolute_9000
    out 0x42, al                        ; 4f
    retf 0

__?SECT?__
