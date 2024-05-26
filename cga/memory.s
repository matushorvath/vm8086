.EXPORT write_memory_b8000
.EXPORT read_memory_bc000
.EXPORT write_memory_bc000

##########
write_memory_b8000:
.FRAME addr, value;
    ret 2
.ENDFRAME

##########
read_memory_bc000:
.FRAME addr; value                      # returns value
    arb -1

    arb 1
    ret 1
.ENDFRAME

##########
write_memory_bc000:
.FRAME addr, value;
    ret 2
.ENDFRAME

.EOF
