.EXPORT config_enable_tracing
.EXPORT config_tracing_cs
.EXPORT config_tracing_ip
.EXPORT config_vm_callback
.EXPORT config_flags_as_286
.EXPORT config_bcd_as_bochs
.EXPORT config_de_fault_as_286
.EXPORT config_boot_80x25
.EXPORT config_log_fdc

# Tracing (0 - disable tracing, -1 - trace always, >0 - tracing past given address)
config_enable_tracing:
    db  0

# Tracing trigger address (0 - always trace, >0 - trace after the address was reached)
config_tracing_cs:
    db  0
config_tracing_ip:
    db  0

# Optional callback function to call before each instruction, zero if not used
config_vm_callback:
    db  0

# Make flags behave like a real 8086/8088
config_flags_as_286:
    db  0

# Make bcd behave like a real 8086/8088
config_bcd_as_bochs:
    db  0

# Make #DE behave like a real 8086/8088
config_de_fault_as_286:
    db  0

# Boot in CGA 80x25 text mode
config_boot_80x25:
    db  1

# Logging configuration
config_log_fdc:
    db  0

.EOF
