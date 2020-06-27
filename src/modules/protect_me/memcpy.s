memcpy:

        push    bp
        mov     bp,sp

        push    cx
        push    si
        push    di

        cld
        mov     di, [bp + 8]
        mov     si, [bp + 12]
        mov     cx, [bp + 16]

        rep movsb

        pop     di
        pop     si
        pop     cx

        mov     sp, bp
        pop     bp

        ret