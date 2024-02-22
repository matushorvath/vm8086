.EXPORT execute

##########
execute:
.FRAME tmp
    arb -1

execute_loop:

            const op = read(incpc());

    switch(op)
    {
            # 02 HLT; not an official instruction, but we need it
        db  return;


            default: throw new Error(`invalid opcode ${format8(op)} at ${format16((pc - 1 + 0x10000) % 0x10000)}`);

    }

    jz  execute_loop

    arb 1
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
    db  execute push(packSr()) TODO
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
    db  execute branch(!negative, relative()) TODO
    db  0

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
    db  execute carry = false   TODO
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
    db  execute unpackSr(pull()) TODO
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
    db  execute branch(negative, relative()) TODO
    db  0

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
    db  execute carry = true TODO
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
    db  execute_rti TODO
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
    db  execute branch(!overflow, relative()) TODO
    db  0

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
    db  execute interrupt = false TODO
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
    db  execute a = pull(); updateNegativeZero(reg_a) TODO
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
    db  execute branch(overflow, relative()) TODO
    db  0

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
    db  execute interrupt = true TODO
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
    db  execute str(reg_a, indirect8(reg_x)) TODO
    db  0

    # 84 STY
    db  execute str(reg_y, zeropage()) TODO
    db  0

    # 85 STA
    db  execute str(reg_a, zeropage()) TODO
    db  0

    # 86 STX
    db  execute str(reg_x, zeropage()) TODO
    db  0

    # 88 DEY
    db  execute y = der(reg_y) TODO
    db  0

    # 8a TXA
    db  execute a = reg_x; updateNegativeZero(reg_a) TODO
    db  0

    # 8c STY
    db  execute str(reg_y, absolute()) TODO
    db  0

    # 8d STA
    db  execute_str(reg_a, absolute()) TODO
    db  0

    # 8e STX
    db  execute_str(reg_x, absolute()) TODO
    db  0


    # 90 BCC (Branch on Carry Clear)
    db  execute branch(!carry, relative()) TODO
    db  0

    # 91 STA
    db  execute str(reg_a, indirect8(0, reg_y)) TODO
    db  0

    # 94 STY
    db  execute str(reg_y, zeropage(reg_x)) TODO
    db  0

    # 95 STA
    db  execute str(reg_a, zeropage(reg_x)) TODO
    db  0

    # 96 STX
    db  execute str(reg_x, zeropage(reg_y)) TODO
    db  0

    # 98 TYA
    db  execute a = reg_y; updateNegativeZero(reg_a) TODO
    db  0

    # 99 STA
    db  execute str(reg_a, absolute(reg_y)) TODO
    db  0

    # 9a TXS
    db  execute sp = reg_x TODO
    db  0

    # 9d STA
    db  execute str(reg_a, absolute(reg_x)) TODO
    db  0


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
    db  execute y = reg_a; updateNegativeZero(reg_y) TODO
    db  0

    # a9
    db  execute_lda
    db  immediate

    # aa TAX
    db  execute x = reg_a; updateNegativeZero(reg_x) TODO
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
    db  execute branch(carry, relative()) TODO
    db  0

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
    db  execute ldx(zeropage(reg_y)) TODO
    db  0

    # b8 CLV (CLear oVerflow)
    db  execute overflow = false TODO
    db  0

    # b9
    db  execute_lda
    db  absolute_y

    # ba TSX
    db  execute x = sp; updateNegativeZero(reg_x) TODO
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
    db  execute cmp(reg_y, immediate()) TODO
    db  0

    # c1
    db  execute cmp(reg_a, indirect8(reg_x)) TODO
    db  0

    # c4 CPY
    db  execute cmp(reg_y, zeropage()) TODO
    db  0

    # c5
    db  execute cmp(reg_a, zeropage()) TODO
    db  0

    # c6
    db  execute_dec
    db  zeropage

    # c8 INY
    db  execute y = inr(reg_y) TODO
    db  0

    # c9
    db  execute cmp(reg_a, immediate()) TODO
    db  0

    # ca DEX
    db  execute x = der(reg_x) TODO
    db  0

    # cc CPY
    db  execute cmp(reg_y, absolute()) TODO
    db  0

    # cd
    db  execute cmp(reg_a, absolute()) TODO
    db  0

    # ce
    db  execute_dec
    db  absolute


    # d0 BNE (Branch on Not Equal)
    db  execute branch(!zero, relative()) TODO
    db  0

    # d1
    db  execute cmp(reg_a, indirect8(0, reg_y)) TODO
    db  0

    # d5
    db  execute cmp(reg_a, zeropage(reg_x)) TODO
    db  0

    # d6
    db  execute_dec
    db  zeropage_x

    # d8 CLD (CLear Decimal)
    db  execute decimal = false TODO
    db  0

    # d9
    db  execute cmp(reg_a, absolute(reg_y)) TODO
    db  0

    # dd
    db  execute cmp(reg_a, absolute(reg_x)) TODO
    db  0

    # de
    db  execute_dec
    db  absolute_x


    # e0 CPX
    db  execute cmp(reg_x, immediate()) TODO
    db  0

    # e1
    db  execute_sbc
    db  indirect8_x

    # e4 CPX
    db  execute cmp(reg_x, zeropage()) TODO
    db  0

    # e5
    db  execute_sbc
    db  zeropage

    # e6
    db  execute_inc
    db  zeropage

    # e8 INX
    db  execute x = inr(reg_x) TODO
    db  0

    # e9
    db  execute_sbc
    db  immediate

    # ea: // NOP
    db  execute nop TODO
    db  0

    # ec CPX
    db  execute cmp(reg_x, absolute()) TODO
    db  0

    # ed
    db  execute_sbc
    db  absolute

    # ee
    db  execute_inc
    db  absolute


    # f0 BEQ (Branch on EQual)
    db  execute branch(zero, relative()) TODO
    db  0

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
    db  execute decimal = true TODO
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
