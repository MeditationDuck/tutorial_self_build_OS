%include       "../include/define.s"
%include       "../include/macro.s"

    ORG      KERNEL_LOAD

[BITS 32]

; エントリーポイント

kernel:
    
    ; フォントアドレスを取得
        mov     esi, BOOT_LOAD + SECT_SIZE
        movzx   eax, word [esi + 0]
        movzx   ebx, word [esi + 2]
        shl     eax, 4
        add     eax, ebx
        mov     [FONT_ADR], eax

    ; 8ビットの横線
        mov     ah, 0x07        ; 書き込みプレーン
        mov     al, 0x02        ; マップマスクレジスタ
        mov     dx, 0x03c4      ; シーケンサー制御ポート
        out     dx, ax          ; ポート出力

        mov     [0x000A_0000 + 0], byte 0xFF  ; 書き込み

        mov     ah, 0x04    
        out     dx, ax
        mov     [0x000A_0000 + 1], byte 0xFF 

        mov     ah, 0x02
        out     dx, ax
        mov     [0x000A_0000 + 2], byte 0xFF 

        mov     ah, 0x01
        out     dx, ax
        mov     [0x000A_0000 + 3], byte 0xFF 

    ;画面を横切る線

        mov     ah, 0x02
        out     dx, ax

        lea     edi, [0x000A_0000 + 80]
        mov     ecx, 80
        mov     al, 0xFF
        rep stosb
    
    ;四角い
	mov		edi, 1							; EDI  = 行数;

	shl		edi, 8							; EDI *= 256;
	lea		edi, [edi * 4 + edi + 0xA_0000]	; EDI  = VRAMアドレス;

	mov		[edi + (80 * 0)], word 0xFF
	mov		[edi + (80 * 1)], word 0xFF
	mov		[edi + (80 * 2)], word 0xFF
	mov		[edi + (80 * 3)], word 0xFF
	mov		[edi + (80 * 4)], word 0xFF
	mov		[edi + (80 * 5)], word 0xFF
	mov		[edi + (80 * 6)], word 0xFF
	mov		[edi + (80 * 7)], word 0xFF

        ;3行目に文字を描画
        mov     esi, 'A'
        shl     esi, 4
        add     esi, [FONT_ADR] 
        mov     edi,   2
        shl     edi, 8
        lea     edi, [edi * 4 + edi + 0xA_0000]

        mov     ecx, 16

.10L:
        movsb
        add     edi, 80 - 1
        loop    .10L

        jmp     $

ALIGN 4, db 0
FONT_ADR: dd 0
; パディング

    times KERNEL_SIZE - ($ - $$) db 0x00
    
