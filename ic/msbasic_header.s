# This the header for the MS Basic binary.
# It needs to be linked immediately after binary.o and immediately before the MS Basic binary itself.

# Start address for the MS Basic binary, set to -1 to use the reset vector.
    db  -1

# Load address for the MS Basic binary, needs to match the BASROM memory region in $(MSBASICDIR)/vm6502.cfg.
    db  49152       # 0xc000

.EOF
