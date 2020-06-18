lba_chs:
;■書式		: void lba_chs(drive, drv_chs, lba);
;
;■引数
;	drive	: drive構造体のアドレス
;			:（ドライブパラメータが格納されている）
;	drv_chs	: drive構造体のアドレス
;			:（変換後のシリンダ番号、ヘッド番号そしてセクタ番号を保存する）
;	lba		: LBA
;
;■戻り値	: 成功(0以外)、失敗(0)

        push    bp
        mov     bp, sp

        push    ax
        push    bx 
        push    dx
        push    si
        push    di

        mov     si, [bp + 4]
        mov     di, [bp + 6]

        mov     al, [si + drive.head]       ;最大ヘッド数
        mul     byte [si + drive.sect]      ; 上 * 最大シリンダ数 
        mov     bx, ax
        mov     dx, 0                       ;LBA上位2バイト
        mov     ax, [bp + 8]                ; 下位バイト
        div     bx                          ; dx:ax % bx ; 残り
                                            ; dx:ax / bx ; シリンダ番号
        mov     [di + drive.cyln], ax       ; シリンダ番号

        mov     ax, dx
        div     byte [si + drive.sect]      ; ah = ax % 最大セクタ数

        movzx   dx, ah                      ; dx = セクタ番号
        inc     dx                              ; 自然数にするため

        mov     ah, 0x00                    ; AX = ヘッド位置

        mov     [di + drive.head], ax       ;  ヘッダ番号
        mov     [di + drive.sect], dx       ; drv_chs.sect = セクタ番号

        pop     di
        pop     si
        pop     dx
        pop     bx
        pop     ax

        mov     sp, bp
        pop     bp

        ret