[map test.map]

cpu 8086

section interrupts start=0x00000
    dw  0x0000, 0x0000
    dw  0x0000, 0x0000
    dw  0x0000, 0x0000
    dw  0x0000, 0x8000          ; INT3: IP, CS

section .text start=0x80000
    ; INT 3 handler
    nop
    hlt

section boot start=0xffff0     ; needs to match simple_test_header.s
    int3
