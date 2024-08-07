.EXPORT execute_immed_b
.EXPORT execute_immed_w

# From add.s
.IMPORT execute_add_b
.IMPORT execute_add_w
.IMPORT execute_adc_b
.IMPORT execute_adc_w
.IMPORT execute_sub_b
.IMPORT execute_sub_w
.IMPORT execute_sbb_b
.IMPORT execute_sbb_w
.IMPORT execute_cmp_b
.IMPORT execute_cmp_w

# From bitwise.s
.IMPORT execute_and_b
.IMPORT execute_and_w
.IMPORT execute_or_b
.IMPORT execute_or_w
.IMPORT execute_xor_b
.IMPORT execute_xor_w

# Group "immediate" instructions, first byte is MOD xxx R/M, where xxx is:
# 000 ADD, 001 OR, 010 ADC, 011 SBB, 100 AND, 101 SUB, 110 XOR, 111 CMP
#
# Opcodes:
# 0x80 <op> REG8/MEM8, IMMED8
# 0x81 <op> REG16/MEM16, IMMED16
# 0x82 <op> REG8/MEM8, IMMED8
# 0x83 <op> REG16/MEM16, IMMED8 (sign extend)

# Note: Opcodes 0x82 and 0x83 on Intel 8086 are not documented to include OR, AND and XOR.
# However, NASM will generate '83 f0 ff' for 'xor ax, word 0xffff' even with 'cpu 8086'.
# So, to make life easier, we support those operations even for opcodes 0x82 and 0x83.
# https://bugzilla.nasm.us/show_bug.cgi?id=3392642

##########
execute_immed_b:
.FRAME op, lseg_src, loff_src, lseg_dst, loff_dst;
    # Prepare the arguments on stack
    add [rb + lseg_src], 0, [rb - 1]
    add [rb + loff_src], 0, [rb - 2]
    add [rb + lseg_dst], 0, [rb - 3]
    add [rb + loff_dst], 0, [rb - 4]

    # Execute the operation
    add .table, [rb + op], [ip + 2]
    jz  0, [0]

.table:
    # Map each OP value to the label that handles it
    db  .add
    db  .or
    db  .adc
    db  .sbb
    db  .and
    db  .sub
    db  .xor
    db  .cmp

.add:
    arb -4
    call execute_add_b
    jz  0, .end

.or:
    arb -4
    call execute_or_b
    jz  0, .end

.adc:
    arb -4
    call execute_adc_b
    jz  0, .end

.sbb:
    arb -4
    call execute_sbb_b
    jz  0, .end

.and:
    arb -4
    call execute_and_b
    jz  0, .end

.sub:
    arb -4
    call execute_sub_b
    jz  0, .end

.xor:
    arb -4
    call execute_xor_b
    jz  0, .end

.cmp:
    arb -4
    call execute_cmp_b

.end:
    ret 5
.ENDFRAME

##########
execute_immed_w:
.FRAME op, lseg_src, loff_src, lseg_dst, loff_dst;
    # Prepare the arguments on stack
    add [rb + lseg_src], 0, [rb - 1]
    add [rb + loff_src], 0, [rb - 2]
    add [rb + lseg_dst], 0, [rb - 3]
    add [rb + loff_dst], 0, [rb - 4]

    # Execute the operation
    add .table, [rb + op], [ip + 2]
    jz  0, [0]

.table:
    # Map each OP value to the label that handles it
    db  .add
    db  .or
    db  .adc
    db  .sbb
    db  .and
    db  .sub
    db  .xor
    db  .cmp

.add:
    arb -4
    call execute_add_w
    jz  0, .end

.or:
    arb -4
    call execute_or_w
    jz  0, .end

.adc:
    arb -4
    call execute_adc_w
    jz  0, .end

.sbb:
    arb -4
    call execute_sbb_w
    jz  0, .end

.and:
    arb -4
    call execute_and_w
    jz  0, .end

.sub:
    arb -4
    call execute_sub_w
    jz  0, .end

.xor:
    arb -4
    call execute_xor_w
    jz  0, .end

.cmp:
    arb -4
    call execute_cmp_w

.end:
    ret 5
.ENDFRAME

.EOF
