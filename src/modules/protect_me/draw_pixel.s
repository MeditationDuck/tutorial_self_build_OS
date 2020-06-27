;************************************************************************
;	ピクセルの描画
;========================================================================
;■書式		: void draw_pixel(X, Y, color);
;
;■引数
;	X		: X座標
;	Y		: Y座標
;	color	: 描画色
;
;■戻り値	: 無し
;************************************************************************
draw_pixel:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												; ------|--------
												; EBP+16| 色
												; EBP+12| Y
												; EBP+ 8| X
												; ------|--------
		push	ebp								; EBP+ 4| EIP（戻り番地）
		mov		ebp, esp						; EBP+ 0| EBP（元の値）
												; ------+--------
		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	eax
		push	ebx
		push	ecx
		push	edi
        
		;---------------------------------------
		; Y座標を80倍する（640/8）
		;---------------------------------------

        mov     edi, [ebp +12]
        shl     edi, 4
        lea     edi, [edi * 4 + edi + 0xA_0000]

        mov     ebx, [ebp + 8]
        mov     ecx, ebx
        shr     ebx, 3
        add     edi, ebx

        and     ecx, 0x07
        mov     ebx, 0x80
        shr     ebx, cl

        mov     ecx, [ebp +16]

%ifdef	USE_TEST_AND_SET
		cdecl	test_and_set, IN_USE			; TEST_AND_SET(IN_USE); // リソースの空き待ち
%endif

		;---------------------------------------
		; プレーン毎に出力
		;---------------------------------------
		cdecl	vga_set_read_plane, 0x03		; // 輝度(I)プレーンを選択
		cdecl	vga_set_write_plane, 0x08		; // 輝度(I)プレーンを選択
		cdecl	vram_bit_copy, ebx, edi, 0x08, ecx

		cdecl	vga_set_read_plane, 0x02		; // 赤(R)プレーンを選択
		cdecl	vga_set_write_plane, 0x04		; // 赤(R)プレーンを選択
		cdecl	vram_bit_copy, ebx, edi, 0x04, ecx

		cdecl	vga_set_read_plane, 0x01		; // 緑(G)プレーンを選択
		cdecl	vga_set_write_plane, 0x02		; // 緑(G)プレーンを選択
		cdecl	vram_bit_copy, ebx, edi, 0x02, ecx

		cdecl	vga_set_read_plane, 0x00		; // 青(B)プレーンを選択
		cdecl	vga_set_write_plane, 0x01		; // 青(B)プレーンを選択
		cdecl	vram_bit_copy, ebx, edi, 0x01, ecx


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
		pop		ecx
		pop		ebx
		pop		eax

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret

