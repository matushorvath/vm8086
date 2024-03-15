[map test.map]

cpu 8086

section .text start=0xffff0     ; needs to match simple_test_header.s
    nop
    hlt
