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
%include    "../modules/real/kbc.s"
%include    "../modules/real/lba_chs.s"
%include    "../modules/real/read_lba.s"

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
        cdecl   get_mem_info         ;get_mem_info

        mov     eax, [ACPI_DATA.adr]
        cmp     eax, 0                          ; ACPIのデータがないつまりアドレスがなかったらジャンプ
        je      .10E

        cdecl   itoa, ax, .p4, 4, 16, 0b0100    ;下位アドレスの変換
        shr     eax, 16                         ;シフトして上位アドレスに持ってくる
        cdecl   itoa, ax, .p3, 4, 16, 0b0100    ;下位アドレスの変換
        cdecl   puts, .s2                       ; アドレスを表示
.10E:

        jmp     stage_4

.s0:     db      "3rd stage...", 0x0A, 0x0D, 0

.s1:    db      " Font Address="
.p1:    db      "ZZZZ:"
.p2:    db      "ZZZZ", 0x0A, 0x0D, 0
        db      0x0A, 0x0D, 0

.s2     db      " ACPI data="
.p3     db      "ZZZZ"
.p4     db      "ZZZZ", 0x0A, 0x0D, 0

stage_4:

        cdecl   puts, .s0

        ;A20ゲートの有効化
        cli                             ; 割込み禁止             
        cdecl   KBC_Cmd_Write, 0xAD     ; キーボード無効化
        cdecl   KBC_Cmd_Write, 0xD0     ; 出力ポート読み出しコマンド
        cdecl   KBC_Data_Read, .key     ; 出力ポート

        mov     bl, [.key]              ; bl = key
        or      bl, 0x02                ; bl |= 0x02  A20ゲート有効化

        cdecl   KBC_Cmd_Write, 0xD1     ; 出力ポート書き込みコマンド
        cdecl   KBC_Data_Write, bx      ;さっきのbxの設定からA20ゲート有効 

        cdecl   KBC_Cmd_Write, 0xAE     ; キーボード有効化

        sti                             ;割り込み許可

        cdecl	puts, .s1

        ;キーボードLEDテスト  
	cdecl	puts, .s2					
	mov	bx, 0							
.10L:											
	mov	ah, 0x00						
	int	0x16							
 
        cmp	al, '1'							
	jb	.10E							 
	cmp	al, '3'							
	ja	.10E							
	mov	cl, al							
	dec	cl							
	and	cl, 0x03						
	mov	ax, 0x0001						
        shl	ax, cl
	xor	bx, ax							

	
	cli										 
	cdecl	KBC_Cmd_Write, 0xAD				

	cdecl	KBC_Data_Write, 0xED		
	cdecl	KBC_Data_Read, .key			

	cmp	[.key], byte 0xFA				
	jne	.11F						
	cdecl	KBC_Data_Write, bx				
	jmp	.11E							
.11F:										
	cdecl	itoa, word [.key], .e1, 2, 16, 0b0100
	cdecl	puts, .e0					
.11E:										 
	cdecl	KBC_Cmd_Write, 0xAE				  
	sti								
	jmp		.10L						
.10E:
	
	cdecl	puts, .s3

	jmp     stage_5							

.s0:	db	"4th stage...", 0x0A, 0x0D, 0
.s1:	db	" A20 Gate Enabled.", 0x0A, 0x0D, 0
.s2:	db	" Keyboard LED Test...", 0
.s3:	db	" (done)", 0x0A, 0x0D, 0
.e0:	db	"["
.e1:	db	"ZZ]", 0

.key:	dw	0

stage_5:
        cdecl   puts, .s0

        ; カーネルの読み込み！
        cdecl   read_lba, BOOT, BOOT_SECT, KERNEL_SECT, BOOT_END

        cmp     ax, KERNEL_SECT
.10Q:   jz      .10E
.10T:   cdecl   puts, .e0
        call    reboot
.10E:
        jmp     stage_6  

.s0     db      "5th stage...", 0x0A, 0x0D, 0
.e0     db      "Failure load kernel...", 0x0A, 0x0D, 0

stage_6:
        cdecl   puts, .s0

        ;ユーザーからの入力待ち
.10L:   
        mov     ah, 0x00
        int     0x16            ; キー入力待ち
        cmp     al, ' '
        jne     .10L

        ; ビデオモードの設定
        mov     ax, 0x0012      ; vga 640x480
        int     0x10            ;ビデオモードの設定

        jmp     stage_7

.s0	db	"6th stage...", 0x0A, 0x0D, 0x0A, 0x0D
	db	" [Push SPACE key to protect mode...]", 0x0A, 0x0D, 0      

; セグメントディスクリプタの配列

ALIGN 4, db 0
GDT:            dq      0x00_0_0_0_0_000000_0000        ;NULL
.cs:            dq      0x00_C_F_9_A_000000_FFFF        ;CODE 4G
.ds:            dq      0x00_C_F_9_2_000000_FFFF        ;DATA 4G
.gdt_end:

; セレクタ
SEL_CODE        equ .cs - GDT                       ; コード用セレクタ
SEL_DATA        equ .ds - GDT                       ; データ用

; GDT
GDTR:           dw      GDT.gdt_end - GDT - 1           ; ディスクリプタテーブルのリミット
                dd      GDT                             ; ディスクリプタテーブルのアドレス
;IDT    ; 割り込みディスクリプタテーブル
IDTR:           dw      0               ; リミット
                dd      0               ; アドレス

stage_7:
        cli
        ; GDT ロード
        lgdt    [GDTR]
        lidt    [IDTR]

        ; プロテクトモードに移行

        mov     eax, cr0
        or      ax, 1
        mov     cr0, eax

        jmp     $ + 2

[BITS 32]
        DB      0x66                    ; オペランドサイズオーバーライドプレフィックス
        jmp     SEL_CODE:CODE_32

; 32ビットコード開始
CODE_32:
        ;セレクタを初期化
        mov     ax, SEL_CODE
        mov     ds, ax
        mov     es, ax
        mov     fs, ax
        mov     gs, ax
        mov     ss, ax
        
        ; カーネル部をコピー
        mov     ecx, (KERNEL_SIZE) / 4          ; 4バイトごと
        mov     esi, BOOT_END                   ;0X0000_9C00
        mov     edi, KERNEL_LOAD                ;0X0010_1000
        cld                                     ;dfクリア
        rep movsd                               ;while (--ecx) 

        jmp     KERNEL_LOAD



;パディング     ブートファイルのサイズを定義したとおりにする
        times BOOT_SIZE - ($ - $$)  db 0
