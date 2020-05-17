entry:
        jmp     ipl
        times 90 - ($ - $$) db 0x90
        db 0x55, 0xAA

ipl:
        jmp     $
        times 510 - ($ - $$) db 0x00
        db 0x55, 0xAA        