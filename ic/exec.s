.EXPORT execute

# From arithmetic.s
.IMPORT execute_adc
.IMPORT execute_sbc

.IMPORT execute_cmp
.IMPORT execute_cpx
.IMPORT execute_cpy

# From branch.s
.IMPORT execute_brk
.IMPORT execute_jmp
.IMPORT execute_jsr
.IMPORT execute_rti
.IMPORT execute_rts

.IMPORT execute_bcc
.IMPORT execute_bcs
.IMPORT execute_bne
.IMPORT execute_beq
.IMPORT execute_bpl
.IMPORT execute_bmi
.IMPORT execute_bvc
.IMPORT execute_bvs

# From error.s
.IMPORT report_error

# From flags.s
.IMPORT execute_clc
.IMPORT execute_cld
.IMPORT execute_cli
.IMPORT execute_clv

.IMPORT execute_sec
.IMPORT execute_sed
.IMPORT execute_sei

# From incdec.s
.IMPORT execute_inc
.IMPORT execute_inx
.IMPORT execute_iny

.IMPORT execute_dec
.IMPORT execute_dex
.IMPORT execute_dey

# From loadstore.s
.IMPORT execute_lda
.IMPORT execute_ldx
.IMPORT execute_ldy

.IMPORT execute_sta
.IMPORT execute_stx
.IMPORT execute_sty

.IMPORT execute_tax
.IMPORT execute_tay
.IMPORT execute_txa
.IMPORT execute_tya
.IMPORT execute_txs
.IMPORT execute_tsx

# From memory.s
.IMPORT read

# From params.s
.IMPORT immediate
.IMPORT zeropage
.IMPORT zeropage_x
.IMPORT zeropage_y
.IMPORT absolute
.IMPORT absolute_x
.IMPORT absolute_y
.IMPORT indirect8_x
.IMPORT indirect8_y
.IMPORT indirect16
.IMPORT relative

# From pushpull.s
.IMPORT execute_php
.IMPORT execute_plp
.IMPORT execute_pha
.IMPORT execute_pla

# From state.s
.IMPORT reg_pc

# From util.s
.IMPORT incpc

##########
execute:
.FRAME tmp, op, exec_fn, param_fn
    arb -4

execute_loop:
    # Read op code
    add [reg_pc], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + op]

    # Increase pc
    call incpc

    # Process hlt
    eq  [rb + op], 2, [rb + tmp]
    jnz [rb + tmp], execute_hlt

    # Find exec and param functions for this instruction
    mul [rb + op], 2, [rb + tmp]

    add instructions, [rb + tmp], [ip + 1]
    add [0], 0, [rb + exec_fn]

    add [rb + tmp], 1, [rb + tmp]
    add instructions, [rb + tmp], [ip + 1]
    add [0], 0, [rb + param_fn]

    # If there is a param_fn, call it; then call exec_fn with the result as a parameter
    jz  [rb + param_fn], execute_no_param_fn

    call [rb + param_fn]
    add [rb - 2], 0, [rb - 1]
    arb -1
    call [rb + exec_fn + 1]     # +1 to compensate for arb -1

    jz  0, execute_loop

execute_no_param_fn:
    # No param_fn, just call exec_fn with no parameters
    call [rb + exec_fn]

    jz  0, execute_loop

execute_hlt:
    arb 4
    ret 0
.ENDFRAME

##########
execute_nop:
.FRAME
    ret 0
.ENDFRAME

##########
invalid_opcode:
.FRAME
    arb -0

    add invalid_opcode_message, 0, [rb - 1]
    arb -1
    call report_error

invalid_opcode_message:
    db  "invalid opcode", 0
.ENDFRAME

##########
not_implemented:                        # TODO remove this function
.FRAME
    arb -0

    add not_implemented_message, 0, [rb - 1]
    arb -1
    call report_error

not_implemented_message:
    db  "opcode not implemented", 0
.ENDFRAME

##########
# instruction decoding table
instructions:
    db  execute_brk, 0                                      # 00
    db  not_implemented, 0        #    db  execute_ora, indirect8_x                            # 01
    db  invalid_opcode, 0                                   # 02
    db  invalid_opcode, 0                                   # 03
    db  invalid_opcode, 0                                   # 04
    db  not_implemented, 0        #    db  execute_ora, zeropage                               # 05
    db  not_implemented, 0        #    db  execute_asl, zeropage                               # 06
    db  invalid_opcode, 0                                   # 07
    db  execute_php, 0                                      # 08
    db  not_implemented, 0        #    db  execute_ora, immediate                              # 09
    db  not_implemented, 0        #    db  execute_asl_a, 0                                    # 0a
    db  invalid_opcode, 0                                   # 0b
    db  invalid_opcode, 0                                   # 0c
    db  not_implemented, 0        #    db  execute_ora, absolute                               # 0d
    db  not_implemented, 0        #    db  execute_asl, absolute                               # 0e
    db  invalid_opcode, 0                                   # 0f

    db  execute_bpl, relative                               # 10 Branch on PLus
    db  not_implemented, 0        #    db  execute_ora, indirect8_y                            # 11
    db  invalid_opcode, 0                                   # 12
    db  invalid_opcode, 0                                   # 13
    db  invalid_opcode, 0                                   # 14
    db  not_implemented, 0        #    db  execute_ora, zeropage_x                             # 15
    db  not_implemented, 0        #    db  execute_asl, zeropage_x                             # 16
    db  invalid_opcode, 0                                   # 17
    db  execute_clc, 0                                      # 18 CLear Carry
    db  not_implemented, 0        #    db  execute_ora, absolute_y                             # 19
    db  invalid_opcode, 0                                   # 1a
    db  invalid_opcode, 0                                   # 1b
    db  invalid_opcode, 0                                   # 1c
    db  not_implemented, 0        #    db  execute_ora, absolute_x                             # 1d
    db  not_implemented, 0        #    db  execute_asl, absolute_x                             # 1e
    db  invalid_opcode, 0                                   # 1f

    db  execute_jsr, absolute                               # 20
    db  not_implemented, 0        #    db  execute_and, indirect8_x                            # 21
    db  invalid_opcode, 0                                   # 22
    db  invalid_opcode, 0                                   # 23
    db  not_implemented, 0        #    db  execute_bit, zeropage                               # 24
    db  not_implemented, 0        #    db  execute_and, zeropage                               # 25
    db  not_implemented, 0        #    db  execute_rol, zeropage                               # 26
    db  invalid_opcode, 0                                   # 27
    db  execute_plp, 0                                      # 28
    db  not_implemented, 0        #    db  execute_and, immediate                              # 29
    db  not_implemented, 0        #    db  execute_rol_a, 0                                    # 2a
    db  invalid_opcode, 0                                   # 2b
    db  not_implemented, 0        #    db  execute_bit, absolute                               # 2c
    db  not_implemented, 0        #    db  execute_and, absolute                               # 2d
    db  not_implemented, 0        #    db  execute_rol, absolute                               # 2e
    db  invalid_opcode, 0                                   # 2f

    db  execute_bmi, relative                               # 30 Branch on MInus
    db  not_implemented, 0        #    db  execute_and, indirect8_y                            # 31
    db  invalid_opcode, 0                                   # 32
    db  invalid_opcode, 0                                   # 33
    db  invalid_opcode, 0                                   # 34
    db  not_implemented, 0        #    db  execute_and, zeropage_x                             # 35
    db  not_implemented, 0        #    db  execute_rol, zeropage_x                             # 36
    db  invalid_opcode, 0                                   # 37
    db  execute_sec, 0                                      # 38 SEt Carry
    db  not_implemented, 0        #    db  execute_and, absolute_y                             # 39
    db  invalid_opcode, 0                                   # 3a
    db  invalid_opcode, 0                                   # 3b
    db  invalid_opcode, 0                                   # 3c
    db  not_implemented, 0        #    db  execute_and, absolute_x                             # 3d
    db  not_implemented, 0        #    db  execute_rol, absolute_x                             # 3e
    db  invalid_opcode, 0                                   # 3f

    db  execute_rti, 0                                      # 40
    db  not_implemented, 0        #    db  execute_eor, indirect8_x                            # 41
    db  invalid_opcode, 0                                   # 42
    db  invalid_opcode, 0                                   # 43
    db  invalid_opcode, 0                                   # 44
    db  not_implemented, 0        #    db  execute_eor, zeropage                               # 45
    db  not_implemented, 0        #    db  execute_lsr, zeropage                               # 46
    db  invalid_opcode, 0                                   # 47
    db  execute_pha, 0                                      # 48
    db  not_implemented, 0        #    db  execute_eor, immediate                              # 49
    db  not_implemented, 0        #    db  execute_lsr_a, 0                                    # 4a
    db  invalid_opcode, 0                                   # 4b
    db  execute_jmp, absolute                               # 4c
    db  not_implemented, 0        #    db  execute_eor, absolute                               # 4d
    db  not_implemented, 0        #    db  execute_lsr, absolute                               # 4e
    db  invalid_opcode, 0                                   # 4f

    db  execute_bvc, relative                               # 50 Branch on oVerflow Clear
    db  not_implemented, 0        #    db  execute_eor, indirect8_y                            # 51
    db  invalid_opcode, 0                                   # 52
    db  invalid_opcode, 0                                   # 53
    db  invalid_opcode, 0                                   # 54
    db  not_implemented, 0        #    db  execute_eor, zeropage_x                             # 55
    db  not_implemented, 0        #    db  execute_lsr, zeropage_x                             # 56
    db  invalid_opcode, 0                                   # 57
    db  execute_cli, 0                                      # 58 CLear Interrupt
    db  not_implemented, 0        #    db  execute_eor, absolute_y                             # 59
    db  invalid_opcode, 0                                   # 5a
    db  invalid_opcode, 0                                   # 5b
    db  invalid_opcode, 0                                   # 5c
    db  not_implemented, 0        #    db  execute_eor, absolute_x                             # 5d
    db  not_implemented, 0        #    db  execute_lsr, absolute_x                             # 5e
    db  invalid_opcode, 0                                   # 5f

    db  execute_rts, 0                                      # 60
    db  execute_adc, indirect8_x                            # 61
    db  invalid_opcode, 0                                   # 62
    db  invalid_opcode, 0                                   # 63
    db  invalid_opcode, 0                                   # 64
    db  execute_adc, zeropage                               # 65
    db  not_implemented, 0        #    db  execute_ror, zeropage                               # 66
    db  invalid_opcode, 0                                   # 67
    db  execute_pla, 0                                      # 68
    db  execute_adc, immediate                              # 69
    db  not_implemented, 0        #    db  execute_ror_a, 0                                    # 6a
    db  invalid_opcode, 0                                   # 6b
    db  execute_jmp, indirect16                             # 6c
    db  execute_adc, absolute                               # 6d
    db  not_implemented, 0        #    db  execute_ror, absolute                               # 6e
    db  invalid_opcode, 0                                   # 6f

    db  execute_bvs, relative                               # 70 Branch on oVerflow Set
    db  execute_adc, indirect8_y                            # 71
    db  invalid_opcode, 0                                   # 72
    db  invalid_opcode, 0                                   # 73
    db  invalid_opcode, 0                                   # 74
    db  execute_adc, zeropage_x                             # 75
    db  not_implemented, 0        #    db  execute_ror, zeropage_x                             # 76
    db  invalid_opcode, 0                                   # 77
    db  execute_sei, 0                                      # 78 SEt Interrupt
    db  execute_adc, absolute_y                             # 79
    db  invalid_opcode, 0                                   # 7a
    db  invalid_opcode, 0                                   # 7b
    db  invalid_opcode, 0                                   # 7c
    db  execute_adc, absolute_x                             # 7d
    db  not_implemented, 0        #    db  execute_ror, absolute_x                             # 7e
    db  invalid_opcode, 0                                   # 7f

    db  invalid_opcode, 0                                   # 80
    db  execute_sta, indirect8_x                            # 81
    db  invalid_opcode, 0                                   # 82
    db  invalid_opcode, 0                                   # 83
    db  execute_sty, zeropage                               # 84
    db  execute_sta, zeropage                               # 85
    db  execute_stx, zeropage                               # 86
    db  invalid_opcode, 0                                   # 87
    db  execute_dey, 0                                      # 88
    db  invalid_opcode, 0                                   # 89
    db  execute_txa, 0                                      # 8a
    db  invalid_opcode, 0                                   # 8b
    db  execute_sty, absolute                               # 8c
    db  execute_sta, absolute                               # 8d
    db  execute_stx, absolute                               # 8e
    db  invalid_opcode, 0                                   # 8f

    db  execute_bcc, relative                               # 90 Branch on Carry Clear
    db  execute_sta, indirect8_y                            # 91
    db  invalid_opcode, 0                                   # 92
    db  invalid_opcode, 0                                   # 93
    db  execute_sty, zeropage_x                             # 94
    db  execute_sta, zeropage_x                             # 95
    db  execute_stx, zeropage_y                             # 96
    db  invalid_opcode, 0                                   # 97
    db  execute_tya, 0                                      # 98
    db  execute_sta, absolute_y                             # 99
    db  execute_txs, 0                                      # 9a
    db  invalid_opcode, 0                                   # 9b
    db  invalid_opcode, 0                                   # 9c
    db  execute_sta, absolute_x                             # 9d
    db  invalid_opcode, 0                                   # 9e
    db  invalid_opcode, 0                                   # 9f

    db  execute_ldy, immediate                              # a0
    db  execute_lda, indirect8_x                            # a1
    db  execute_ldx, immediate                              # a2
    db  invalid_opcode, 0                                   # a3
    db  execute_ldy, zeropage                               # a4
    db  execute_lda, zeropage                               # a5
    db  execute_ldx, zeropage                               # a6
    db  invalid_opcode, 0                                   # a7
    db  execute_tay, 0                                      # a8
    db  execute_lda, immediate                              # a9
    db  execute_tax, 0                                      # aa
    db  invalid_opcode, 0                                   # ab
    db  execute_ldy, absolute                               # ac
    db  execute_lda, absolute                               # ad
    db  execute_ldx, absolute                               # ae
    db  invalid_opcode, 0                                   # af

    db  execute_bcs, relative                               # b0 Branch on Carry Set
    db  execute_lda, indirect8_y                            # b1
    db  invalid_opcode, 0                                   # b2
    db  invalid_opcode, 0                                   # b3
    db  execute_ldy, zeropage_x                             # b4
    db  execute_lda, zeropage_x                             # b5
    db  execute_ldx, zeropage_y                             # b6
    db  invalid_opcode, 0                                   # b7
    db  execute_clv, 0                                      # b8 CLear oVerflow
    db  execute_lda, absolute_y                             # b9
    db  execute_tsx, 0                                      # ba
    db  invalid_opcode, 0                                   # bb
    db  execute_ldy, absolute_x                             # bc
    db  execute_lda, absolute_x                             # bd
    db  execute_ldx, absolute_y                             # be
    db  invalid_opcode, 0                                   # bf

    db  execute_cpy, immediate                              # c0
    db  execute_cmp, indirect8_x                            # c1
    db  invalid_opcode, 0                                   # c2
    db  invalid_opcode, 0                                   # c3
    db  execute_cpy, zeropage                               # c4
    db  execute_cmp, zeropage                               # c5
    db  execute_dec, zeropage                               # c6
    db  invalid_opcode, 0                                   # c7
    db  execute_iny, 0                                      # c8
    db  execute_cmp, immediate                              # c9
    db  execute_dex, 0                                      # ca
    db  invalid_opcode, 0                                   # cb
    db  execute_cpy, absolute                               # cc
    db  execute_cmp, absolute                               # cd
    db  execute_dec, absolute                               # ce
    db  invalid_opcode, 0                                   # cf

    db  execute_bne, relative                               # d0 Branch on Not Equal
    db  execute_cmp, indirect8_y                            # d1
    db  invalid_opcode, 0                                   # d2
    db  invalid_opcode, 0                                   # d3
    db  invalid_opcode, 0                                   # d4
    db  execute_cmp, zeropage_x                             # d5
    db  execute_dec, zeropage_x                             # d6
    db  invalid_opcode, 0                                   # d7
    db  execute_cld, 0                                      # d8 CLear Decimal
    db  execute_cmp, absolute_y                             # d9
    db  invalid_opcode, 0                                   # da
    db  invalid_opcode, 0                                   # db
    db  invalid_opcode, 0                                   # dc
    db  execute_cmp, absolute_x                             # dd
    db  execute_dec, absolute_x                             # de
    db  invalid_opcode, 0                                   # df

    db  execute_cpx, immediate                              # e0
    db  execute_sbc, indirect8_x                            # e1
    db  invalid_opcode, 0                                   # e2
    db  invalid_opcode, 0                                   # e3
    db  execute_cpx, zeropage                               # e4
    db  execute_sbc, zeropage                               # e5
    db  execute_inc, zeropage                               # e6
    db  invalid_opcode, 0                                   # e7
    db  execute_inx, 0                                      # e8
    db  execute_sbc, immediate                              # e9
    db  execute_nop, 0                                      # ea
    db  invalid_opcode, 0                                   # eb
    db  execute_cpx, absolute                               # ec
    db  execute_sbc, absolute                               # ed
    db  execute_inc, absolute                               # ee
    db  invalid_opcode, 0                                   # ef

    db  execute_beq, relative                               # f0 Branch on EQual
    db  execute_sbc, indirect8_y                            # f1
    db  invalid_opcode, 0                                   # f2
    db  invalid_opcode, 0                                   # f3
    db  invalid_opcode, 0                                   # f4
    db  execute_sbc, zeropage_x                             # f5
    db  execute_inc, zeropage_x                             # f6
    db  invalid_opcode, 0                                   # f7
    db  execute_sed, 0                                      # f8 SEt Decimal
    db  execute_sbc, absolute_y                             # f9
    db  invalid_opcode, 0                                   # fa
    db  invalid_opcode, 0                                   # fb
    db  invalid_opcode, 0                                   # fc
    db  execute_sbc, absolute_x                             # fd
    db  execute_inc, absolute_x                             # fe
    db  invalid_opcode, 0                                   # ff

.EOF
