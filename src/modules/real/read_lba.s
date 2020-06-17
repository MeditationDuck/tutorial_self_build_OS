read_lba:

        push    bp
        mov     bp, sp
        push    si

        mov     si, [bp + 4]        ; ドライブ情報

        mov     ax, [bp + 6]        ; LBA
        cdecl   lba_chs, si, .chs, ax; lba_chs(drive, .chs, ax);

        mov     al, [si + drive.no]
        mov     [.chs + drive.no], al; ドライブ番号

        cdecl   read_chs, .chs, word [bp + 8], word [bp + 10] ; ax = read_chs(.chs, セクタ数, ofs)

        pop     si
        mov     sp, bp
        pop     bp

        ret

ALIGN 2
.chs:   times drive_size        db  0
