.EXPORT execute_mul_b

# From location.s
.IMPORT read_location_b
.IMPORT write_location_b
#.IMPORT read_location_w
#.IMPORT write_location_w

# From state.s
.IMPORT reg_al
.IMPORT reg_ah

.IMPORT flag_carry
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow

# From util.s
.IMPORT split_16_8_8

##########
execute_mul_b:
.FRAME loc_type, loc_addr; val
    arb -1

    # Read the value
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + val]

    # Calculate the result and split it into AL and AH
    mul [rb + val], [reg_al], [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_al]
    add [rb - 4], 0, [reg_ah]

    # Update flags
    eq  [reg_ah], 0, [flag_carry]
    eq  [flag_carry], 0, [flag_carry]
    add [flag_carry], 0, [flag_overflow]

    add 0, 0, [flag_auxiliary_carry]
    add 0, 0, [flag_parity]
    add 0, 0, [flag_sign]
    add 0, 0, [flag_zero]

    arb 1
    ret 2
.ENDFRAME

.EOF
