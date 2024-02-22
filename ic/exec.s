.EXPORT execute

##########
execute:
.FRAME tmp, op
    arb -2

execute_loop:
    # Read op code
    add MEM, [reg_pc], [ip + 1]
    add [0], 0, [rb + op]

    # Increase pc
    add [reg_pc], 1, [reg_pc]

    # Process hlt
    eq  [rb + op], 2, [rb + tmp]
    jnz [rb + tmp], execute_hlt

    switch(op)
    {
        default: throw new Error(`invalid opcode ${format8(op)} at ${format16((pc - 1 + 0x10000) % 0x10000)}`);
    }

    jz  execute_loop
execute_hlt:

    arb 2
    ret 0
.ENDFRAME

##########
# instruction decoding table
decode:
    # 00
    db  execute_brk
    db  0

    # 01
    db  execute_ora
    db  indirect8_x

    # 05
    db  execute_ora
    db  zeropage

    # 06
    db  execute_asl
    db  zeropage

    # 08 PHP
    db  execute_push_sr
    db  0

    # 09
    db  execute_ora
    db  immediate

    # 0a
    db  execute_asl_a
    db  0

    # 0d
    db  execute_ora
    db  absolute

    # 0e
    db  execute_asl
    db  absolute


    # 10 BPL (Branch on PLus)
    db  execute_branch_positive
    db  relative

    # 11
    db  execute_ora
    db  indirect8_y

    # 15
    db  execute_ora
    db  zeropage_x

    # 16
    db  execute_asl
    db  zeropage_x

    # 18 CLC (CLear Carry)
    db  execute_clear_carry
    db  0

    # 19
    db  execute_ora
    db  absolute_y

    # 1d
    db  execute_ora
    db  absolute_x

    # 1e
    db  execute_asl
    db  absolute_x


    # 20
    db  execute_jsr
    db  absolute

    # 21
    db  execute_and
    db  indirect8_x

    # 24
    db  execute_bit
    db  zeropage

    # 25
    db  execute_and
    db  zeropage

    # 26
    db  execute_rol
    db  zeropage

    # 28 PLP
    db  execute_pull_sr
    db  0

    # 29
    db  execute_and
    db  immediate

    # 2a
    db  execute_rol_a
    db  0

    # 2c
    db  execute_bit
    db  absolute

    # 2d
    db  execute_and
    db  absolute

    # 2e
    db  execute_rol
    db  absolute


    # 30 BMI (Branch on MInus)
    db  execute_branch_negative
    db  relative

    # 31
    db  execute_and
    db  indirect8_y

    # 35
    db  execute_and
    db  zeropage_x

    # 36
    db  execute_rol
    db  zeropage_x

    # 38 SEC (SEt Carry)
    db  execute_set_carry
    db  0

    # 39
    db  execute_and
    db  absolute_y

    # 3d
    db  execute_and
    db  absolute_x

    # 3e
    db  execute_rol
    db  absolute_x


    # 40
    db  execute_rti
    db  0

    # 41
    db  execute_eor
    db  indirect8_x

    # 45
    db  execute_eor
    db  zeropage

    # 46
    db  execute_lsr
    db  zeropage

    # 48 PHA
    db  execute_push_a
    db  0

    # 49
    db  execute_eor
    db  immediate

    # 4a
    db  execute_lsr_a
    db  0

    # 4c
    db  execute_jmp
    db  absolute

    # 4d
    db  execute_eor
    db  absolute

    # 4e
    db  execute_lsr
    db  absolute


    # 50 BVC (Branch on oVerflow Clear)
    db  execute_branch_not_overflow
    db  relative

    # 51
    db  execute_eor
    db  indirect8_y

    # 55
    db  execute_eor
    db  zeropage_x

    # 56
    db  execute_lsr
    db  zeropage_x

    # 58 CLI (CLear Interrupt)
    db  execute_clear_interrupt
    db  0

    # 59
    db  execute_eor
    db  absolute_y

    # 5d
    db  execute_eor
    db  absolute_x

    # 5e
    db  execute_lsr
    db  absolute_x


    # 60
    db  execute_rts()
    db  0

    # 61
    db  execute_adc
    db  indirect8_x

    # 65
    db  execute_adc
    db  zeropage

    # 66
    db  execute_ror
    db  zeropage

    # 68 PLA
    db  execute_pull_a                  # a = pull(); updateNegativeZero(reg_a)
    db  0

    # 69
    db  execute_adc
    db  immediate

    # 6a
    db  execute_ror_a
    db  0

    # 6c
    db  execute_jmp
    db  indirect16

    # 6d
    db  execute_adc
    db  absolute

    # 6e
    db  execute_ror
    db  absolute


    # 70 BVS (Branch on oVerflow Set)
    db  execute_branch_overflow
    db  relative

    # 71
    db  execute_adc
    db  indirect8_y

    # 75
    db  execute_adc
    db  zeropage_x

    # 76
    db  execute_ror
    db  zeropage_x

    # 78 SEI (SEt Interrupt)
    db  execute_set_interrupt
    db  0

    # 79
    db  execute_adc
    db  absolute_y

    # 7d
    db  execute_adc
    db  absolute_x

    # 7e
    db  execute_ror
    db  absolute_x


    # 81 STA
    db  execute_sta
    db  indirect8_x

    # 84 STY
    db  execute_sty
    db  zeropage

    # 85 STA
    db  execute_sta
    db  zeropage

    # 86 STX
    db  execute_stx
    db  zeropage

    # 88 DEY
    db  execute_dey
    db  0

    # 8a TXA
    db  execute_txa                     # a = reg_x; updateNegativeZero(reg_a)
    db  0

    # 8c STY
    db  execute_sty
    db  absolute

    # 8d STA
    db  execute_sta
    db  absolute

    # 8e STX
    db  execute_stx
    db  absolute


    # 90 BCC (Branch on Carry Clear)
    db  execute_branch_not_carry
    db  relative

    # 91 STA
    db  execute_sta
    db  indirect8_y

    # 94 STY
    db  execute_sty
    db  zeropage_x

    # 95 STA
    db  execute_sta
    db  zeropage_x

    # 96 STX
    db  execute_stx
    db  zeropage_y

    # 98 TYA
    db  execute_tya                     # a = reg_y; updateNegativeZero(reg_a)
    db  0

    # 99 STA
    db  execute_sta
    db  absolute_y

    # 9a TXS
    db  execute_tsx                     # sp = reg_x
    db  0

    # 9d STA
    db  execute_sta
    db  absolute_x


    # a0
    db  execute_ldy
    db  immediate

    # a1
    db  execute_lda
    db  indirect8_x

    # a2
    db  execute_ldx
    db  immediate

    # a4
    db  execute_ldy
    db  zeropage

    # a5
    db  execute_lda
    db  zeropage

    # a6
    db  execute_ldx
    db  zeropage

    # a8 TAY
    db  execute_tay                     # y = reg_a; updateNegativeZero(reg_y)
    db  0

    # a9
    db  execute_lda
    db  immediate

    # aa TAX
    db  execute_tax                     # x = reg_a; updateNegativeZero(reg_x)
    db  0

    # ac
    db  execute_ldy
    db  absolute

    # ad
    db  execute_lda
    db  absolute

    # ae
    db  execute_ldx
    db  absolute


    # b0 BCS (Branch on Carry Set)
    db  execute_branch_carry
    db  relative

    # b1
    db  execute_lda
    db  indirect8_y

    # b4
    db  execute_ldy
    db  zeropage_x

    # b5
    db  execute_lda
    db  zeropage_x

    # b6
    db  execute_ldx
    db  zeropage_y

    # b8 CLV (CLear oVerflow)
    db  execute_clear_overflow
    db  0

    # b9
    db  execute_lda
    db  absolute_y

    # ba TSX
    db  execute_tsx                     # x = sp; updateNegativeZero(reg_x)
    db  0

    # bc
    db  execute_ldy
    db  absolute_x

    # bd
    db  execute_lda
    db  absolute_x

    # be
    db  execute_ldx
    db  absolute_y


    # c0 CPY
    db  execute_cpy
    db  immediate

    # c1
    db  execute_cmp
    db  indirect8_x

    # c4 CPY
    db  execute_cpy
    db  zeropage

    # c5
    db  execute_cmp
    db  zeropage

    # c6
    db  execute_dec
    db  zeropage

    # c8 INY
    db  execute_iny                     #  y = inr(reg_y)
    db  0

    # c9
    db  execute_cmp
    db  immediate

    # ca DEX
    db  execute_dex                     # x = der(reg_x)
    db  0

    # cc CPY
    db  execute_cpy
    db  absolute

    # cd
    db  execute_cmp
    db  absolute

    # ce
    db  execute_dec
    db  absolute


    # d0 BNE (Branch on Not Equal)
    db  execute_branch_not_zero
    db  relative

    # d1
    db  execute_cmp
    db  indirect8_y

    # d5
    db  execute_cmp
    db  zeropage_x

    # d6
    db  execute_dec
    db  zeropage_x

    # d8 CLD (CLear Decimal)
    db  execute_clear_decimal
    db  0

    # d9
    db  execute_cmp
    db  absolute_y

    # dd
    db  execute_cmp
    db  absolute_x

    # de
    db  execute_dec
    db  absolute_x


    # e0 CPX
    db  execute_cpx
    db  immediate

    # e1
    db  execute_sbc
    db  indirect8_x

    # e4 CPX
    db  execute_cpx
    db  zeropage

    # e5
    db  execute_sbc
    db  zeropage

    # e6
    db  execute_inc
    db  zeropage

    # e8 INX
    db  execute_inx                     # x = inr(reg_x)
    db  0

    # e9
    db  execute_sbc
    db  immediate

    # ea: NOP
    db  execute_nop
    db  0

    # ec CPX
    db  execute_cpx
    db  absolute

    # ed
    db  execute_sbc
    db  absolute

    # ee
    db  execute_inc
    db  absolute


    # f0 BEQ (Branch on EQual)
    db  execute_branch_zero
    db  relative

    # f1
    db  execute_sbc
    db  indirect8_y

    # f5
    db  execute_sbc
    db  zeropage_x

    # f6
    db  execute_inc
    db  zeropage_x

    # f8 SED (SEt Decimal)
    db  execute_set_decimal
    db  0

    # fd
    db  execute_sbc
    db  absolute_x

    # f9
    db  execute_sbc
    db  absolute_y

    # fe
    db  execute_inc
    db  absolute_x
