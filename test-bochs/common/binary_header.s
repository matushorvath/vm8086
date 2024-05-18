# This the header for the 8086 test binary.
# It needs to be linked immediately before the test binary itself.

.EXPORT binary_start_address_cs
.EXPORT binary_start_address_ip
.EXPORT binary_load_address

# Initial cs value, use the default
binary_start_address_cs:
    db  0xff, 0xff

# Initial ip value, use the default
binary_start_address_ip:
    db  0x00, 0x00

# Load address of the simple test binary in 8086 memory
binary_load_address:
    db  0xca000

# Symbols binary_count, binary_size and binary_data are provided by the test binary

.EOF
