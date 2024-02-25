.EXPORT execute_asl
.EXPORT execute_asl_a
#.EXPORT execute_lsr
#.EXPORT execute_lsr_a
.EXPORT execute_rol
.EXPORT execute_rol_a
#.EXPORT execute_ror
#.EXPORT execute_ror_a

# From memory.s
.IMPORT read
.IMPORT write

# From state.s
.IMPORT flag_carry
.IMPORT flag_negative
.IMPORT flag_zero
.IMPORT reg_a

# Intcode does not have a convenient way to access individual bits of a byte.
# For speed and convenience we will sacrifice 256 * 8 = 2048 bytes and memoize the operation.
# The table for that is generated using gen_bits.s and can be found in file bits.s.

##########
.FRAME addr; value, increment, tmp
    # Multiple entry points for this function, to share the common code without having to add
    # a parameter (which would not work with the exec.s instructions table mechanism).

execute_rol:
    arb -3

    # ROL will add old carry to the value
    add [flag_carry], 0, [rb + increment]

    jz  0, execute_asl_ror_generic

execute_asl:
    arb -3

    # ASL does not add old carry to the value
    add 0, 0, [rb + increment]

execute_asl_ror_generic:
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
    lt  [rb + value], 256, [rb + tmp]
    jnz [rb + tmp], execute_asl_ror_no_carry

    add 1, 0, [flag_carry]
    add [rb + value], -256, [rb + value]

execute_asl_ror_no_carry:
    # Update flags
    lt  127, [rb + value], [flag_negative]
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
    lt  [reg_a], 256, [rb + tmp]
    jnz [rb + tmp], execute_asl_a_no_carry

    add 1, 0, [flag_carry]
    add [reg_a], -256, [reg_a]

execute_asl_a_no_carry:
    # Update flags
    lt  127, [reg_a], [flag_negative]
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
    lt  [reg_a], 256, [rb + tmp]
    jnz [rb + tmp], execute_rol_a_no_carry

    add 1, 0, [flag_carry]
    add [reg_a], -256, [reg_a]

execute_rol_a_no_carry:
    # Update flags
    lt  127, [reg_a], [flag_negative]
    eq  [reg_a], 0, [flag_zero]

    arb 1
    ret 0
.ENDFRAME

.EOF

TODO instructions

execute_lsr
execute_lsr_a
execute_ror
execute_ror_a

    lsr(addr) {
        const alg = (val) => {
            this.carry = (val & 0b0000_0001) !== 0;
            val = val >>> 1;
            this.updateNegativeZero(val);
            return val;
        };

        if (addr === undefined) {
            this.a = alg(this.a);
        } else {
            this.write(addr, alg(this.read(addr)));
        }
    }

    ror(addr) {
        const alg = (val) => {
            const newCarry = (val & 0b0000_0001) !== 0;
            val = (val >>> 1) | (this.carry ? 0b1000_0000 : 0);
            this.carry = newCarry;
            this.updateNegativeZero(val);
            return val;
        };

        if (addr === undefined) {
            this.a = alg(this.a);
        } else {
            this.write(addr, alg(this.read(addr)));
        }
    }
