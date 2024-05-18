.EXPORT config_enable_tracing
.EXPORT config_vm_callback

# Tracing (0 - disable tracing, -1 - trace always, >0 - tracing past given address)
config_enable_tracing:
    db  0

# Optional callback function to call before each instruction, zero if not used
config_vm_callback:
    db  0

.EOF
