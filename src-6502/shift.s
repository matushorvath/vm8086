.EXPORT execute_asl
.EXPORT execute_asl_a
.EXPORT execute_lsr
.EXPORT execute_lsr_a
.EXPORT execute_rol
.EXPORT execute_rol_a
.EXPORT execute_ror
.EXPORT execute_ror_a

# From obj/bits.s
.IMPORT bits

# From memory.s
.IMPORT read
.IMPORT write

# From state.s
.IMPORT flag_carry
.IMPORT flag_negative
.IMPORT flag_zero
.IMPORT reg_a

##########
.FRAME addr; value, increment, tmp
    # Multiple entry points for this function, to share the common code without having to add
    # a parameter (which would not work with the exec.s instructions table mechanism).

execute_rol:
    arb -3

    # ROL will add old carry to the value
    add [flag_carry], 0, [rb + increment]

    jz  0, execute_asl_rol_generic

execute_asl:
    arb -3

    # ASL does not add old carry to the value
    add 0, 0, [rb + increment]

execute_asl_rol_generic:
    # Read the input
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + value]

    # Multiply by 2 for left shift
    mul [rb + value], 2, [rb + value]
    # Add the old carry if ROL
    add [rb + value], [rb + increment], [rb + value]

    # Determine new carry
    add 0, 0, [flag_carry]
    lt  [rb + value], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_asl_rol_no_carry

    add 1, 0, [flag_carry]
    add [rb + value], -0x100, [rb + value]

execute_asl_rol_no_carry:
    # Update flags
    lt  0x7f, [rb + value], [flag_negative]
    eq  [rb + value], 0, [flag_zero]

    # Write back to memory
    add [rb + addr], 0, [rb - 1]
    add [rb + value], 0, [rb - 2]
    arb -2
    call write

    arb 3
    ret 1
.ENDFRAME

##########
execute_asl_a:
.FRAME tmp
    arb -1

    # Multiply by 2 for left shift
    mul [reg_a], 2, [reg_a]

    # Determine new carry
    add 0, 0, [flag_carry]
    lt  [reg_a], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_asl_a_no_carry

    add 1, 0, [flag_carry]
    add [reg_a], -0x100, [reg_a]

execute_asl_a_no_carry:
    # Update flags
    lt  0x7f, [reg_a], [flag_negative]
    eq  [reg_a], 0, [flag_zero]

    arb 1
    ret 0
.ENDFRAME

##########
execute_rol_a:
.FRAME tmp
    arb -1

    # Multiply by 2 for left shift, add old carry
    mul [reg_a], 2, [reg_a]
    add [reg_a], [flag_carry], [reg_a]

    # Determine new carry
    add 0, 0, [flag_carry]
    lt  [reg_a], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_rol_a_no_carry

    add 1, 0, [flag_carry]
    add [reg_a], -0x100, [reg_a]

execute_rol_a_no_carry:
    # Update flags
    lt  0x7f, [reg_a], [flag_negative]
    eq  [reg_a], 0, [flag_zero]

    arb 1
    ret 0
.ENDFRAME

##########
execute_ror:
.FRAME addr;
    # Read the input
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb - 1]                               # read() -> param0

    # Call the generic shift right algorithm; it updates flags inside
    add [flag_carry], 0, [rb - 2]                           # use the carry flag for ROR
    arb -2
    call shift_right

    # Write back to memory
    add [rb + addr], 0, [rb - 1]
    add [rb - 4], 0, [rb - 2]                               # shift_right() -> param1
    arb -2
    call write

    ret 1
.ENDFRAME

##########
execute_ror_a:
.FRAME
    # Call the generic shift right algorithm; it updates flags inside
    add [reg_a], 0, [rb - 1]
    add [flag_carry], 0, [rb - 2]                           # use the carry flag for ROR
    arb -2
    call shift_right

    add [rb - 4], 0, [reg_a]

    ret 0
.ENDFRAME

##########
execute_lsr:
.FRAME addr;
    # Read the input
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb - 1]                               # read() -> param0

    # Call the generic shift right algorithm; it updates flags inside
    add 0, 0, [rb - 2]                                      # don't use the carry flag for LSR
    arb -2
    call shift_right

    # Write back to memory
    add [rb + addr], 0, [rb - 1]
    add [rb - 4], 0, [rb - 2]                               # shift_right() -> param1
    arb -2
    call write

    ret 1
.ENDFRAME

##########
execute_lsr_a:
.FRAME
    # Call the generic shift right algorithm; it updates flags inside
    add [reg_a], 0, [rb - 1]
    add 0, 0, [rb - 2]                                      # don't use the carry flag for LSR
    arb -2
    call shift_right

    add [rb - 4], 0, [reg_a]

    ret 0
.ENDFRAME

##########
shift_right:
.FRAME old_value, new_value; value_bits                     # returns new value in value_bits
    arb -1

    # Find old_value in bits
    mul [rb + old_value], 8, [rb + value_bits]              # offset of old_value in bits -> value_bits
    add bits, [rb + value_bits], [rb + value_bits]          # address of old_value bits -> value_bits

    # Build the new value from individual bits
    mul [rb + new_value], 2, [rb + new_value]               # new_value *= 2
    add [rb + value_bits], 7, [ip + 1]
    add [0], [rb + new_value], [rb + new_value]             # new_value += old_value bit 7

    mul [rb + new_value], 2, [rb + new_value]               # new_value *= 2
    add [rb + value_bits], 6, [ip + 1]
    add [0], [rb + new_value], [rb + new_value]             # new_value += old_value bit 6

    mul [rb + new_value], 2, [rb + new_value]               # new_value *= 2
    add [rb + value_bits], 5, [ip + 1]
    add [0], [rb + new_value], [rb + new_value]             # new_value += old_value bit 5

    mul [rb + new_value], 2, [rb + new_value]               # new_value *= 2
    add [rb + value_bits], 4, [ip + 1]
    add [0], [rb + new_value], [rb + new_value]             # new_value += old_value bit 4

    mul [rb + new_value], 2, [rb + new_value]               # new_value *= 2
    add [rb + value_bits], 3, [ip + 1]
    add [0], [rb + new_value], [rb + new_value]             # new_value += old_value bit 3

    mul [rb + new_value], 2, [rb + new_value]               # new_value *= 2
    add [rb + value_bits], 2, [ip + 1]
    add [0], [rb + new_value], [rb + new_value]             # new_value += old_value bit 2

    mul [rb + new_value], 2, [rb + new_value]               # new_value *= 2
    add [rb + value_bits], 1, [ip + 1]
    add [0], [rb + new_value], [rb + new_value]             # new_value += old_value bit 1

    # Set new carry to bit 0 of the old value
    add [rb + value_bits], 0, [ip + 1]
    add [0], 0, [flag_carry]                                # flag_carry = old_value bit 0

    # Update flags
    lt  0x7f, [rb + new_value], [flag_negative]
    eq  [rb + new_value], 0, [flag_zero]

    # Return new_value (using value_bits)
    add [rb + new_value], 0, [rb + value_bits]

    arb 1
    ret 2
.ENDFRAME

.EOF
