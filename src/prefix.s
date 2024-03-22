.EXPORT execute_lock

.EXPORT execute_segment_prefix_cs
.EXPORT execute_segment_prefix_ds
.EXPORT execute_segment_prefix_ss
.EXPORT execute_segment_prefix_es

.EXPORT execute_repz
.EXPORT execute_repnz

.EXPORT prefix_valid
.EXPORT ds_segment_prefix
.EXPORT ss_segment_prefix
.EXPORT rep_prefix

# TODO actually implement REPZ/REPNZ

# From state.s
.IMPORT reg_cs
.IMPORT reg_ds
.IMPORT reg_ss
.IMPORT reg_es

##########
# 0: prefixes not valid
# 1: prefixes are valid for current instruction
# 2: prefixes are valid for the instruction after this one
prefix_valid:
    db  0

# intcode address of the first byte of the segment register to use for ds and ss
ds_segment_prefix:
    db  reg_ds
ss_segment_prefix:
    db  reg_ss

# 'Z' for REP/REPE/REPZ, 'N' for REPNE/REPNZ
rep_prefix:
    db  0

##########
execute_lock:
.FRAME
    # We don't do anything special for LOCK, except it extends the lifetime of any previous prefixes
    add 2, 0, [prefix_valid]
    ret 0
.ENDFRAME

##########
execute_segment_prefix_cs:
.FRAME
    add reg_cs + 0, 0, [ds_segment_prefix]
    add reg_cs + 0, 0, [ss_segment_prefix]
    add 2, 0, [prefix_valid]
    ret 0
.ENDFRAME

##########
execute_segment_prefix_ds:
.FRAME
    add reg_ds + 0, 0, [ds_segment_prefix]
    add reg_ds + 0, 0, [ss_segment_prefix]
    add 2, 0, [prefix_valid]
    ret 0
.ENDFRAME

##########
execute_segment_prefix_ss:
.FRAME
    add reg_ss + 0, 0, [ds_segment_prefix]
    add reg_ss + 0, 0, [ss_segment_prefix]
    add 2, 0, [prefix_valid]
    ret 0
.ENDFRAME

##########
execute_segment_prefix_es:
.FRAME
    add reg_es + 0, 0, [ds_segment_prefix]
    add reg_es + 0, 0, [ss_segment_prefix]
    add 2, 0, [prefix_valid]
    ret 0
.ENDFRAME

##########
execute_repz:
.FRAME
    add 'Z', 0, [rep_prefix]
    add 2, 0, [prefix_valid]
    ret 0
.ENDFRAME

##########
execute_repnz:
.FRAME
    add 'N', 0, [rep_prefix]
    add 2, 0, [prefix_valid]
    ret 0
.ENDFRAME

.EOF
