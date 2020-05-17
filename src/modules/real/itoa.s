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

        mov     ax, [bp + 4]
        mov     si, [bp + 6]
        mov     cx, [bp + 8]

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
        cmp     ax,