; DIV/IDIV 16-bit various operand modes
; TODO implement

;     clc
;     mov bl, 0x00
;     mov byte [test_ds_8], 0x00
;     add bl, [test_ds_8]
;     pushf

;     stc
;     mov bh, 0x12
;     mov byte [test_ds_16], 0x34
;     add bh, [test_ds_16]
;     pushf

;     clc
;     mov cl, 0x50
;     mov di, test_ds_16
;     mov byte [di], 0x2f
;     add cl, [di]
;     pushf

;     stc
;     mov ch, 0x75
;     mov byte [test_ds_8], 0x0a
;     adc ch, [test_ds_8]
;     pushf

;     clc
;     mov dl, 0x61
;     mov byte [test_ds_16], 0x35
;     adc dl, [test_ds_16]
;     pushf

;     stc
;     mov dl, 0x81
;     mov di, test_ds_16
;     mov byte [di], 0x29
;     adc dl, [di]
;     pushf

;     dump_state
