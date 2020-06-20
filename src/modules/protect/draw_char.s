draw_char:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												; ------|--------
												; EBP+20| 文字
												; EBP+16| 色
												; EBP+12| Y（行）
												; EBP+ 8| X（列）
												; ------+----------------
		push	ebp								; EBP+ 4| EIP（戻り番地）
		mov		ebp, esp						; EBP+ 0| EBP（元の値）
												; ------+----------------

		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	eax
		push	ebx
		push	ecx
		push	edx
		push	esi
		push	edi
		;---------------------------------------
		; テストアンドセット
		;---------------------------------------
%ifdef	USE_TEST_AND_SET
		cdecl	test_and_set, IN_USE			; TEST_AND_SET(IN_USE); // リソースの空き待ち
%endif

        ;コピー元のアドレスを取得
        movzx   esi, byte [ebp +20]
        shl     esi, 4
        add     esi, [FONT_ADR]

        ;コピー先のアドレスを取得
        mov     edi, [ebp +12]
        shl     edi, 8
        lea     edi, [edi * 4 + edi + 0xA0000]
        add     edi, [ebp + 8]

        ;一文字分のフォントを出力
		movzx	ebx, word [ebp +16]				; // 表示色

		cdecl	vga_set_read_plane, 0x03		; // 読み込みプレーン：輝度(I)
		cdecl	vga_set_write_plane, 0x08		; // 書き込みプレーン：輝度(I)
		cdecl	vram_font_copy, esi, edi, 0x08, ebx

		cdecl	vga_set_read_plane, 0x02		; // 読み込みプレーン：赤(R)
		cdecl	vga_set_write_plane, 0x04		; // 書き込みプレーン：赤(R)
		cdecl	vram_font_copy, esi, edi, 0x04, ebx

		cdecl	vga_set_read_plane, 0x01		; // 読み込みプレーン：緑(G)
		cdecl	vga_set_write_plane, 0x02		; // 書き込みプレーン：緑(G)
		cdecl	vram_font_copy, esi, edi, 0x02, ebx

		cdecl	vga_set_read_plane, 0x00		; // 読み込みプレーン：青(B)
		cdecl	vga_set_write_plane, 0x01		; // 書き込みプレーン：青(B)
		cdecl	vram_font_copy, esi, edi, 0x01, ebx

%ifdef	USE_TEST_AND_SET
		;---------------------------------------
		; テストアンドセット
		;---------------------------------------
		mov		[IN_USE], dword 0				; 変数のクリア
%endif

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		edi
		pop		esi
		pop		edx
		pop		ecx
		pop		ebx
		pop		eax

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret

%ifdef USE_TEST_AND_SET
ALIGN 4, db 0
IN_USE:	dd	0
%endif

