.EXPORT config_enable_tracing
.EXPORT config_flags_as_286
.EXPORT config_io_port_debugging
.EXPORT config_bcd_as_bochs
.EXPORT config_de_fault_as_286

# Tracing (0 - disable tracing, -1 - trace always, >0 - tracing past given address)
config_enable_tracing:
    db  0

# Make flags behave like a real 8086/8088
config_flags_as_286:
    db  0

# Disable debug output when accessing I/O ports
config_io_port_debugging:
    db  0

# Make bcd behave like a real 8086/8088
config_bcd_as_bochs:
    db  0

# Make #DE push address after the failing DIV/IDIV
config_de_fault_as_286:
    db  0

.EOF
