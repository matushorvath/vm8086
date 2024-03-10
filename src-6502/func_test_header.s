# This the header for the 8086 functional test binary.
# It needs to be linked immediately after binary.o and immediately before the functional test binary itself.

# The binary is available in git repository https://github.com/Klaus2m5/8086_65C02_functional_tests

# Start address for the functional test binary
# Can be found using bin_files/8086_functional_test.lst, search for "Program start address is at"
    db  1024        # 0x0400
TODO cs:ip

# Load address for the functional test binary
    db  0

# Set up tracing
#  0 - disable tracing
# -1 - trace always
# >0 - start tracing after passing that address
    db  0

# Callback address
.IMPORT func_test_callback
    db  func_test_callback

.EOF
