# This the header for the 8086 binary.

.EXPORT rom_load_address

# Load address of the binary in 8086 memory
rom_load_address:
    db  0xf0000

# Symbols binary_count, binary_size and binary_data are provided by the binary

.EOF
