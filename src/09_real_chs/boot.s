;マクロ
%include        "../include/define.s"
%include        "../include/macro.s"

        ORG     BOOT_LOAD               ;アセンブラに指示 

;エントリーポイント

entry:
;BPB(Bios Parameter Block)
        jmp     ipl
        times 90 - ($ - $$) db 0x90
;IPL(Initial Program Loader)

ipl:
        cli                     ;割込み禁止

        mov     ax, 0x0000        ;セグメントレジスタの値を設定
        mov     ds, ax            
        mov     es, ax
        mov     ss, ax
        mov     sp, BOOT_LOAD

        sti                    ;割込み禁止解除

        mov     [BOOT + drive.no], dl  ;ブートドライブの保存

;文字列を表示
        cdecl   puts, .s0        

;次の512バイトを読み込む

        mov     bx, BOOT_SECT - 1           ;bx = 残りのぶーとセクタ数
        mov     cx, BOOT_LOAD + SECT_SIZE   ;cx = 次のロードアドレス

        cdecl   read_chs, BOOT, bx, cx      ;ax = read_chs(BOOT, bx, cx)

        cmp     ax, bx
.10Q:   jz      .10E
.10T:   cdecl   puts, .e0
        call    reboot

.10E:
        jmp     stage_2    ;次のステージへ移行

;データ
.s0     db      "Booting...", 0x0A, 0x0D, 0
.e0     db      "Error:sector read", 0

ALIGN 2, db 0
BOOT:                   ;ブートドライブに関する情報
    istruc  drive
        at  drive.no,       dw  0       ; ドライブ番号
        at  drive.cyln,     dw  0       ; C:シリンダ
        at  drive.head,     dw  0       ; H:ヘッド
        at  drive.sect,     dw  2       ; S:セクタ
    iend

; モジュール

%include    "../modules/real/puts.s"
%include    "../modules/real/reboot.s"
%include    "../modules/real/read_chs.s"

;ブートフラグ

        times 510 - ($ - $$) db 0x00    ;先頭512バイトの最後を0x55AAにすることでブートプログラムである条件を満たす
        db 0x55, 0xAA    

; ブート処理第二のステージ
stage_2:

        cdecl puts, .s0    ;文字列を表示

        jmp     $    ;ループ

.s0     db      "2nd stage...", 0x0A, 0x0D, 0

;パディング     ブートファイルのサイズを定義したとおりにする
        times BOOT_SIZE - ($ - $$)  db 0
