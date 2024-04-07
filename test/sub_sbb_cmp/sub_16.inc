; ADC 16-bit, no input carry
; TODO

;     clc
;     mov bx, 0x0000
;     mov cx, 0x0000
;     add bx, cx
;     pushf

;     stc
;     mov cx, 0x0012
;     mov dx, 0x0034
;     add cx, dx
;     pushf

;     clc
;     mov dx, 0x0050
;     mov bp, 0x002f
;     add dx, bp
;     pushf

;     stc
;     mov bp, 0x0075
;     mov si, 0x000b
;     add bp, si
;     pushf

;     clc
;     mov si, 0x0061
;     mov di, 0x0035
;     add si, di
;     pushf

;     dump_state

;     stc
;     mov bx, 0x0081
;     mov cx, 0x002a
;     add bx, cx
;     pushf

;     clc
;     mov cx, 0x007d
;     mov dx, 0x0082
;     add cx, dx
;     pushf

;     stc
;     mov dx, 0x00a9
;     mov bp, 0x0057
;     add dx, bp
;     pushf

;     clc
;     mov bp, 0x00ec
;     mov si, 0x003b
;     add bp, si
;     pushf

;     stc
;     mov si, 0x00ba
;     mov di, 0x0089
;     add si, di
;     pushf

;     dump_state

;     clc
;     mov bx, 0x00ff
;     mov cx, 0x0080
;     add bx, cx
;     pushf

;     stc
;     mov cx, 0x00ec
;     mov dx, 0x00db
;     add cx, dx
;     pushf

;     clc
;     mov dx, 0x1234
;     mov bp, 0x5678
;     add dx, bp
;     pushf

;     stc
;     mov bp, 0x5050
;     mov si, 0x2faf
;     add bp, si
;     pushf

;     clc
;     mov si, 0x7ff0
;     mov di, 0x0010
;     add si, di
;     pushf

;     dump_state

;     stc
;     mov bx, 0x6789
;     mov cx, 0x4567
;     add bx, cx
;     pushf

;     clc
;     mov cx, 0x89ab
;     mov dx, 0x2345
;     add cx, dx
;     pushf

;     stc
;     mov dx, 0x9abc
;     mov bp, 0x6543
;     add dx, bp
;     pushf

;     clc
;     mov bp, 0xedcb
;     mov si, 0x5432
;     add bp, si
;     pushf

;     stc
;     mov si, 0xa987
;     mov di, 0x8765
;     add si, di
;     pushf

;     dump_state

;     clc
;     mov bx, 0x8003
;     mov cx, 0xfffc
;     add bx, cx
;     pushf

;     stc
;     mov cx, 0xffff
;     mov dx, 0xffff
;     add cx, dx
;     pushf

;     dump_state
