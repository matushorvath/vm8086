# This the header for the 6502 functional tests binary.
# It needs to be linked immediately after binary.o and immediately before the functional tests binary itself.

# The binary is available in git repository https://github.com/Klaus2m5/6502_65C02_functional_tests

# Start address for the functional tests binary
# Can be found using bin_files/6502_functional_test.lst, Search for "Program start address is at".
    db  1024        # 0x0400

# Load address for the functional tests binary
    db  0

# Enable tracing
    db  1

# Callback address TODO
    db  0

# TODO tracing for 6502
# TODO print hexa numbers from 6502, add print_num_hex to libxib
# TODO detect successful/failed tests
#
# Test success address
# Can be found using bin_files/6502_functional_test.lst. Search for "test passed, no errors".
#    db  13417       # 0x3469

.EOF
