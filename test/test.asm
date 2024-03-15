[map test.map]

cpu 8086

; Main code
section .text start=0xe0000     ; needs to match simple_test_header.s

init:
    nop

; CPU starts execution here
section boot start=0xffff0
    nop
;    jmp 0x8000:init
