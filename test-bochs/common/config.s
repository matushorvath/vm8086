.EXPORT config_enable_tracing
.EXPORT config_tracing_cs
.EXPORT config_tracing_ip
.EXPORT config_vm_callback
.EXPORT config_flags_as_286
.EXPORT config_bcd_as_bochs
.EXPORT config_de_fault_as_286

.EXPORT config_log_cs_change
.EXPORT config_log_int
.EXPORT config_log_fdc

# Tracing (0 - disabled, 1 - enabled)
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

# Make flags behave like the later processors, to match how bochs handles them
config_flags_as_286:
    db  1

# Make bcd behave like bochs, which is probably incorrect but needed to pass bochs tests
config_bcd_as_bochs:
    db  1

# Make #DE push address of the failing DIV/IDIV, instead of the address after
config_de_fault_as_286:
    db  1

# Logging configuration
config_log_cs_change:
    db  0
config_log_fdc:
    db  0
config_log_int:
    db  0

.EOF
