# This the header for the 6502 functional tests binary.
# It needs to be linked immediately after binary.o and immediately before the functional tests binary itself.

# The binary is available in git repository https://github.com/Klaus2m5/6502_65C02_functional_tests

# Start address for the functional tests binary
# Can be found using bin_files/6502_functional_test.lst, search for "Program start address is at"
    db  1024        # 0x0400

# Load address for the functional tests binary
    db  0

# Disable tracing
# TODO -1 = trace always; >0 = start tracing once VM passes that address
    db  0

# Callback address
.IMPORT func_tests_callback
    db  func_tests_callback

.EOF
