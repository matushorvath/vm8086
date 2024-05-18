.EXPORT config_enable_tracing
.EXPORT config_flags_as_286

# Tracing (0 - disable tracing, -1 - trace always, >0 - tracing past given address)
config_enable_tracing:
    db  0

# Make flags behave like a real 8086/8088
config_flags_as_286:
    db  0

.EOF
