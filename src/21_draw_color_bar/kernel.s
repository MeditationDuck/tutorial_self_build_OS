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

        ;文字の表示

		cdecl	draw_char, 0, 0, 0x010F, 'A'
		cdecl	draw_char, 1, 0, 0x010F, 'B'
		cdecl	draw_char, 2, 0, 0x010F, 'C'

		cdecl	draw_char, 0, 0, 0x0402, '0'
		cdecl	draw_char, 1, 0, 0x0212, '1'
		cdecl	draw_char, 2, 0, 0x0212, '_'

        cdecl   draw_font, 63, 13

        cdecl   draw_str, 25, 14, 0x010F, .s0


        jmp     $

.s0         db  " Hello, Kernel! ", 0

ALIGN 4, db 0
FONT_ADR: dd 0
;   モジュール
%include	"../modules/protect/vga.s"
%include	"../modules/protect/draw_char.s"
%include	"../modules/protect/draw_font.s"
%include	"../modules/protect/draw_str.s"

; パディング

    times KERNEL_SIZE - ($ - $$) db 0x00
    
