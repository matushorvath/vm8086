# This the header for the 8086 test binary.

.EXPORT rom_load_address

# Load address of the simple test binary in 8086 memory
rom_load_address:
    db  0xca000

# Symbols binary_count, binary_size and binary_data are provided by the test binary

.EOF
