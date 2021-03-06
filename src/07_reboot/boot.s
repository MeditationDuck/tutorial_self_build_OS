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

        mov     ax, 0x0000        ;それぞれ0を代入
        mov     ds, ax            ;セグメントレジスタの値を設定
        mov     es, ax
        mov     ss, ax
        mov     sp, BOOT_LOAD

        sti                    ;割込み禁止解除

        mov     [BOOT.DRIVE], dl  ;ブートドライブの保存

;文字列を表示
        cdecl   puts, .s0              
        cdecl   itoa, 8086, .s1, 8, 10, 0b0001
        cdecl   puts, .s1

        cdecl   reboot

        
;処理をループすることによって停止させる
        jmp     $

;データ
.s0     db      "Booting...", 0x0A, 0x0D, 0
.s1     db      "--------", 0x0A, 0x0D, 0

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