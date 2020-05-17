puts:
        push    bp
        mov     bp, sp

        push    ax
        push    bx
        push    si

        mov     si, [bp + 4]

        mov     ah, 0x0e
        mov     bx, 0x0000
        cld
.10L:

        lodsb

        cmp     al, 0
        je      .10E

        int     0x10
        jmp     .10L
.10E:

        pop     si
        pop     bx
        pop     ax

        mov     sp, bp
        pop     bp

        ret