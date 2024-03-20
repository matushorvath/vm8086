.EXPORT execute_grp1_b
.EXPORT arg_mod_grp1_rm_b

# From error.s
.IMPORT report_error

# From memory.s
.IMPORT read_b

# From split233.s
.IMPORT split233

# From state.s
.IMPORT inc_ip

# Complex instruction opcodes that implement multiple different instructions

##########
arg_mod_grp1_rm_b:
.FRAME addr, mod, reg, rm, tmp          # returns addr
    arb -5

    # Read the MOD REG R/M byte and split it
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read_b TODO cs:ip
    mul [rb - 3], 3, [rb + tmp]

    call inc_ip

    mul [rb + tmp], 3, [rb + tmp]
    add split233 + 0, [rb + tmp], [ip + 1]
    add [0], 0, [rb + rm]
    add split233 + 1, [rb + tmp], [ip + 1]
    add [0], 0, [rb + reg]
    add split233 + 2, [rb + tmp], [ip + 1]
    add [0], 0, [rb + mod]

    # MOD 000 R/M -> INC REG8/MEM8
    eq  [rb + reg], 0b000, [rb + tmp]
    jnz [rb + tmp], arg_mod_grp1_rm_b_inc

    # MOD 000 R/M -> INC REG8/MEM8
    eq  [rb + reg], 0b001, [rb + tmp]
    jnz [rb + tmp], arg_mod_grp1_rm_b_dec

    add arg_mod_grp1_rm_b_invalid_message, 0, [rb - 1]
    arb -1
    call report_error

arg_mod_grp1_rm_b_inc:


arg_mod_grp1_rm_b_dec:


arg_mod_grp1_rm_b_end:


    # <grp1>:
    # 000 INC REG8/MEM8
    # 001 DEC REG8/MEM8
    # (rest not used)
    ds  2, 0 # TODO    db  execute_grp1_b, arg_mod_grp1_rm_b               # 0xfe <grp1> REG8/MEM8


    arb 5
    ret 0

arg_mod_grp1_rm_b_invalid_message:
    db  "invalid group 2 instruction", 0
.ENDFRAME


arg_mod_grp1_rm_b

.EOF
