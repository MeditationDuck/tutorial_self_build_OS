get_font_adr:     
                            ;    +4|  フォントアドレス格納場所        
        push    bp          ;    +2|   IP戻り値
        mov     bp, sp      ;  BP+0|   BP


        push    ax
        push    bx
        push    si
        push    es
        push    bp

        mov     si, [bp + 4]        ;引数であるフォントアドレス格納場所を取得
        
        mov     ax, 0x1130       ;BIOS から フォントアドレスを取得するためのもの
        mov     bh, 0x06           ;サイズの指定 8x16 font (vga/mcga)
        int     10h

        mov     [si + 0], es      ;dst[0] = セグメント
        mov     [si + 2], bp      ;dst[1] = オフセット

        pop     bp 
        pop     es
        pop     si
        pop     bx
        pop     ax

        mov     sp, bp
        pop     bp

        ret