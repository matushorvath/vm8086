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
    call 0xe600:far_absolute_2 - 0x6000                     ; TODO the segment isn't a round number
    out 0x42, al                        ; 5f


    ; far target in another segment
[section far_target_1 start=0xe4000]

far_absolute_1:
    out 0x42, al                        ; 3f
    retf 2

__?SECT?__

    ; far target in yet another segment
[section far_target_2 start=0xe6000]

far_absolute_2:
    out 0x42, al                        ; 2f
    push ax
    call 0xe400:far_absolute_1 - 0x4000                     ; TODO the segment isn't a round number
    out 0x42, al                        ; 4f
    retf 0

__?SECT?__
