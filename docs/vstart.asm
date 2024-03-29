org 0x18000

section test start=0x18000 vstart=0x10000
test_0:
    db  0x42
test_1:
    db  0x43

section main start=0x20000
    align 16
    dd  test_0
    align 16
    dd  test_1

    align 16
    dw  test_0
    align 16
    dw  test_1
