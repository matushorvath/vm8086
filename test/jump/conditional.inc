; TODO conditional jump: JO, JNO, JC, JNC, JZ, JNZ, JA, JNA, JS, JNS, JP, JNP, JL, JNL, JG, JNG, JCXZ (all immediate)
; TODO negative short pointer
; TODO carry from low byte (reg_ip low byte + short pointer is more than 0x100)
; TODO borrot to low byte (reg_ip low byte + short pointer is less than 0)
; TODO overflow (reg_ip + short pointer is more than 0x1000)
; TODO underflow (reg_ip + short pointer is less than 0)

    ; test conditional jumps

    ; overflow
    mov dx, 0b00001000_00000000
    push dx
    popf

    mov ax, 1
    jo  overflow
    mov ax, 0
overflow:
    out 0x42, al

    mov dx, 0
    push dx
    popf
