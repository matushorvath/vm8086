# This the header for the 8086 test binary.
# It needs to be linked immediately before the test binary itself.

.EXPORT binary_start_address_cs
.EXPORT binary_start_address_ip
.EXPORT binary_load_address
.EXPORT binary_enable_tracing
.EXPORT binary_vm_callback

# Reference the main function, to make sure it is pulled into the build image.
.IMPORT main
db  main

# Initial cs value, use the default
binary_start_address_cs:
    db  0xff, 0xff

# Initial ip value, use the default
binary_start_address_ip:
    db  0x00, 0x00

# Load address of the simple test binary in 8086 memory
binary_load_address:
    db  0xc8000

# Tracing (0 - disable tracing, -1 - trace always, >0 - tracing past given address)
binary_enable_tracing:
    db  0

# Optional callback function to call before each instruction, zero if not used
binary_vm_callback:
    db  0

# Symbols binary_count, binary_size and binary_data are provided by simple_test_data.o

.EOF
