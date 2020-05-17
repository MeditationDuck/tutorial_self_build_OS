read_chs:
                            
        push    bp
        mov     bp, sp
        push    3           ; リトライ回数
        push    0           ; 読み込みセクタ数

        push    bx
        push    cx
        push    dx
        push    es
        push    si

        mov     si, [bp + 4]    ;si = srcバッファ

; cxレジスタの設定

        mov     ch, [si + drive.cyln + 0]   ; ch = シリンダ番号（上位バイト）
        mov     cl, [si + drive.cyln + 1]   ; cl = シリンダ番号（下位バイト）
        shl     cl, 6                       ; cl <<=6 最上位２ビットにシフト
        or      cl, [si + drive.sect]       ;セクタ番号

; セクタ読み込み
        mov     dh, [si + drive.head]       ;dh = ヘッド番号
        mov     dl, [si + 0]                ;dl = ドライブ番号
        mov     ax, 0x0000                  
        mov     es, ax
        mov     bx, [bp + 8]                ; コピー先
.10L:

        mov     ah, 0x02                    ; セクタ読み込み
        mov     al, [bp + 6]                ; セクタ数

        int     0x13           
        jnc     .11E

        mov     al, 0                       
        jmp     .10E

.11E:                                           ; うまく行かなかったときのループ

        cmp     al, 0   
        jne     .10E

        mov     ax, 0
        dec     word [bp - 2]                   ;リトライ回数を１引く
        jnz     .10L

.10E:    
        mov     ah, 0                          


        pop     si
        pop     es
        pop     dx
        pop     cx
        pop     bx

        mov     sp, bp
        pop     bp

        ret
