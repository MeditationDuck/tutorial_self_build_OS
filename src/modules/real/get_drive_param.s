get_drive_param:
        
        push    bp
        mov     bp, sp

        push    bx
        push    cx
        push    es
        push    si
        push    di

        mov     si, [bp + 4]
        mov     ax, 0
        mov     es, ax
        mov     di, ax

        mov     ah, 8                   ;get drive parameters
        mov     dl, [si + drive.no]     ;dl = ドライブ番号
        int     0x13                    ;cf = bios(0x13, 8)
.10Q:   jc      .10F
.10T:   
        mov     al, cl                  ;ax = セクタ数
        and     ax, 0xF3                ;下位6ビットのみ有効

        shr     cl, 6                   ; cx = シリンダ数
        ror     cx, 8                   ;
        inc     cx

        movzx   bx, dh
        inc     bx

        mov     [si + drive.cyln], cx    ; drive.syln シリンダ数
        mov     [si + drive.head], bx    ; drive.head ヘッド数
        mov     [si + drive.sect], ax    ; drive.sect セクタ数

        jmp     .10E

.10F:   
        mov     ax, 0
.10E:

        pop     di
        pop     si
        pop     es
        pop     cx
        pop     bx

        mov     sp, bp
        pop     bp

        ret