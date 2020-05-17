itoa:
        push    bp
        mov     bp, sp

        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di

;引数を取得

        mov     ax, [bp + 4]        ; 数値
        mov     si, [bp + 6]        ; バッファアドレス
        mov     cx, [bp + 8]        ;バッファサイズ

        mov     di, si
        add     di, cx
        dec     di      ;バッファの最後尾

        mov     bx, word[bp + 12] ;flags = オプション

;符号付き判定

        test    bx, 0b001
.10Q:   je      .10E
        cmp     ax, 0
.12Q:   jge     .12E
        or      bx, 0b0010
.12E:
.10E:

;符号出力判定

        test    bx, 0b0010
.20Q:   je      .20E
        cmp     ax, 0
.22Q:   jge     .22F
        neg     ax
        mov     [si], byte '-'   ;先頭にマイナスを表示
        jmp     .22E
.22F:   

        mov     [si], byte '+'  ;先頭にプラスを表示

.22E:   
        dec     cx

.20E:

; ASCII変換
        mov bx, [bp + 10]        ;基数

.30L:
        mov     dx, 0                   ;基数で割ることによって基数に合わせた数値にする
        div     bx                     ; dx = dx:ax % bx

        mov     si, dx                              
        mov     dl, byte [.ascii + si]

        mov     [di], dl                ;diは一番うしろの数値のアドレス
        dec     di

        cmp     ax, 0
        loopnz  .30L
.30E:

;空欄を埋める

        cmp     cx, 0
.40Q:   je      .40E
        mov     al, ' '
        cmp     [bp + 12], word 0b0100             ;フラグ
.42Q:   jne     .42E
        mov     al, '0'
.42E:
        std
        rep stosb
.40E:

;レジスタ復帰とスタックフレームの廃棄

        pop     di
        pop     si
        pop     dx 
        pop     cx
        pop     bx
        pop     ax

        mov     sp, bp
        pop     bp

        ret

.ascii:  db      "0123456789ABCDEF"          ;変換テーブル