;************************************************************************
;	FACPテーブルの検索
;------------------------------------------------------------------------
;	4バイトのデータを検索する
;========================================================================
;■書式		: DWORD acpi_find(address, size, word);
;
;■引数
;	address	: アドレス
;	size	: サイズ
;	word	: 検索データ
;
;■戻り値	: 見つかったアドレス、見つからなかった場合は0
;************************************************************************
acpi_find:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												; ------|--------
												;    +16| テーブル名
												;    +12| サイズ
												;    + 8| アドレス
												; ------|--------
												;    + 4| EIP（戻り番地）
		push	ebp								; EBP+ 0| EBP（元の値）
		mov		ebp, esp						; ------+--------

		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	ebx
		push	ecx
		push	edi

		;---------------------------------------
		; 引数を取得
		;---------------------------------------
		mov		edi, [ebp + 8]					; EDI  = アドレス;
		mov		ecx, [ebp +12]					; ECX  = 長さ;
		mov		eax, [ebp +16]					; EAX  = 検索データ;

		;---------------------------------------
		; 名前の検索
		;---------------------------------------
		cld										; // DFクリア（+方向）
.10L:											; for ( ; ; )
												; {
		repne	scasb							;   while (AL != *EDI) EDI++;
												;   
		cmp		ecx, 0							;   if (0 == ECX)
		jnz		.11E							;   {
		mov		eax, 0							;     EAX = 0; // 見つからない
		jmp		.10E							;     break;
.11E:											;   }
												;   
		cmp		eax, [es:edi - 1]				;   if (EAX != *EDI) // 4文字分一致？
		jne		.10L							;     continue;      // （不一致）
												;   
		dec		edi								;   EAX = EDI - 1;
		mov		eax, edi						;   
.10E:											; }

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		edi
		pop		ecx
		pop		ebx

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret