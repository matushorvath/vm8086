.EXPORT config_enable_tracing
.EXPORT config_vm_callback
.EXPORT config_flags_as_286
.EXPORT config_io_port_debugging
.EXPORT config_bcd_as_bochs
.EXPORT config_de_fault_as_bochs

# Tracing (0 - disable tracing, -1 - trace always, >0 - tracing past given address)
config_enable_tracing:
    db  0

# Optional callback function to call before each instruction, zero if not used
config_vm_callback:
    db  0

# Make flags behave like the later processors, to match how bochs handles them
config_flags_as_286:
    db  1

# Enable debug output when accessing I/O ports
config_io_port_debugging:
    db  1

# Make bcd behave like bochs, which is probably incorrect but needed to pass bochs tests
config_bcd_as_bochs:
    db  1

# Make #DE push address of the failing DIV/IDIV, instead of the address after
config_de_fault_as_bochs:
    db  1

.EOF
