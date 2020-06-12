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
; リアルモード時に取得した情報
FONT:
.seg:   dw  0
.off:   dw  0
ACPI_DATA:
.adr:   dd  0
.len:   dd  0


;モジュール 先頭512バイト以降に配置 

%include    "../modules/real/itoa.s"
%include    "../modules/real/get_drive_param.s"
%include    "../modules/real/get_font_adr.s"
%include    "../modules/real/get_mem_info.s"


; ブート処理第二のステージ
stage_2:

        cdecl   puts, .s0    ;文字列を表示

        ;ドライブ情報を取得
        cdecl   get_drive_param, BOOT   ;get_drive_param(DX, BOOT.CYLN);
        cmp     ax, 0
.10Q:   jne     .10E
.10T:   cdecl   puts, .e0
        call    reboot
.10E:
        ;取得したドライブ情報を表示
        mov     ax, [BOOT + drive.no]   ;ドライブ ナンバー を表示
        cdecl   itoa, ax, .p1, 2, 16, 0b0100
        mov     ax, [BOOT + drive.cyln]         ;シリンダ数
        cdecl   itoa, ax, .p2, 4, 16, 0b0100
        mov     ax, [BOOT + drive.head]         ;ヘッダ数
        cdecl   itoa, ax, .p3, 2, 16, 0b0100
        mov     ax, [BOOT + drive.sect]         ;シリンダ数
        cdecl   itoa, ax, .p4, 2, 16, 0b0100
        cdecl   puts, .s1


        jmp     stage_3rd    ;次のステージへ

.s0     db      "2nd stage...", 0x0A, 0x0D, 0
.s1     db      "Drive:0x"
.p1     db      "  , C:0x"
.p2     db      "    , H:0x"
.p3     db      "  , S:0x"
.p4     db      "  ", 0x0A, 0x0D, 0

.e0     db      "Can't get drive parameter.", 0

;ブート処理第3のステージ
stage_3rd:

        ;文字列の表示
        cdecl   puts, .s0

        ;プロテクトモードでもBIOS内蔵フォントを使う
        cdecl   get_font_adr, FONT

        cdecl   itoa, word [FONT.seg], .p1, 4, 16, 0b0100

        cdecl   itoa, word [FONT.off], .p2, 4, 16, 0b0100
        cdecl   puts, .s1

        ; メモリ情報の取得と表示
        cdecl   get_mem_info, ACPI_DATA         ;get_mem_info

        mov     eax, [ACPI_DATA.adr]
        cmp     eax, 0                          ; ACPIのデータがないつまりアドレスがなかったらジャンプ
        je      .10E

        cdecl   itoa, ax, .p4, 4, 16, 0b0100    ;下位アドレスの変換
        shr     eax, 16                         ;シフトして上位アドレスに持ってくる
        cdecl   itoa, ax, .p3, 4, 16, 0b0100    ;下位アドレスの変換
        cdecl   puts, .s2                       ; アドレスを表示
.10E:

        jmp     $       ;ループ

.s0:     db      "3rd stage...", 0x0A, 0x0D, 0

.s1:    db      " Font Address="
.p1:    db      "ZZZZ:"
.p2:    db      "ZZZZ", 0x0A, 0x0D, 0
        db      0x0A, 0x0D, 0

.s2     db      " ACPI data="
.p3     db      "ZZZZ"
.p4     db      "ZZZZ", 0x0A, 0x0D, 0

;パディング     ブートファイルのサイズを定義したとおりにする
        times BOOT_SIZE - ($ - $$)  db 0
