        BOOT_LOAD       equ     0x7C00  ;ブートプログラムのロードアドレス
        ORG     BOOT_LOAD               ;アセンブラに指示  
                                        ;これがないと0x0000にロードされることになってしまうが
                                        ;BIOSそこはがすでに使っている領域である

;マクロ

%include        "../include/macro.s"

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

        mov     [BOOT.DRIVE], dl  ;ブートドライブの保存

;文字列を表示
        cdecl   puts, .s0        

;次の512バイトを読み込む
        mov     ah, 0x02                ; 読み込み命令
        mov     al, 1                   ; 読み込みセクタ数
        mov     cx, 0x0002              ; シリンダ/セクタ
        mov     dh, 0x00                ; ヘッド位置
        mov     dl, [BOOT.DRIVE]        ; ドライブ番号
        mov     bx, 0x7C00 + 512        ; オフセット
        int     0x13                    ; BIOS(0x13, 0x02)
.10Q:   jnc     .10E
.10T:   cdecl   puts, .e0
        call    reboot

.10E:
        jmp     stage_2    ;次のステージへ移行

        
;処理をループすることによって停止させる
        jmp     $

;データ
.s0     db      "Booting...", 0x0A, 0x0D, 0
.e0     db      "Error:sector read", 0

ALIGN 2, db 0
BOOT:
 .DRIVE:        dw 0    ;ブートのドライブ番号

; モジュール

%include    "../modules/real/puts.s"
%include    "../modules/real/itoa.s"
%include    "../modules/real/reboot.s"

;ブートフラグ

        times 510 - ($ - $$) db 0x00    ;先頭512バイトの最後を0x55AAにすることでブートプログラムである条件を満たす
        db 0x55, 0xAA    

; ブート処理第二のステージ
stage_2:

        cdecl puts, .s0    ;文字列を表示

        jmp     $    ;ループ

.s0     db      "2nd stage...", 0x0A, 0x0D, 0

;パディング（8kByteのファイルにする）
        times (1024 * 8) - ($ - $$)  db 0
