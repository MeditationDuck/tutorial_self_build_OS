;************************************************************************
;	時刻の表示
;========================================================================
;■書式		: void draw_time(col, row, color, time);
;
;■引数
;	col		: 列
;	row		: 行
;	color	: 描画色
;	time	: 時刻データ
;
;■戻り値	: 無し
;************************************************************************
draw_time:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												; ------|--------
												; EBP+20| 時刻データ
												; EBP+16| 色
												; EBP+12| Y（行）
												; EBP+ 8| X（列）
												; ---------------
		push	ebp								; EBP+ 0| EBP（元の値）
		mov		ebp, esp						; EBP+ 4| EIP（戻り番地）
												; ---------------
		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	eax
		push	ebx

		;---------------------------------------
		; 
		;---------------------------------------
		mov		eax, [ebp +20]					; EAX = 時刻データ;
		cmp		eax, [.last]					; if (今回 != 前回)
		je		.10E							; {
												;   
		mov		[.last], eax					;   // 前回の時刻値を更新
												;   
		mov		ebx, 0							;   EBX = 0;
		mov		bl, al							;   EBX = 秒;
		cdecl	itoa, ebx, .sec, 2, 16, 0b0100	;   // 時刻を文字列に変換

		mov		bl, ah							;   EBX = 分;
		cdecl	itoa, ebx, .min, 2, 16, 0b0100	;   // 時刻を文字列に変換

		shr		eax, 16							;   EBX = 時;
		cdecl	itoa, eax, .hour, 2, 16, 0b0100	;   // 時刻を文字列に変換

												;   // 時刻を表示
		cdecl	draw_str, dword [ebp + 8], dword [ebp +12], dword [ebp +16], .hour
												;     
												;   }
.10E:											; }

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		ebx
		pop		eax

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret

ALIGN 2, db 0
.temp:	dq	0
.last:	dq	0
.hour:	db	"ZZ:"
.min:	db	"ZZ:"
.sec:	db	"ZZ", 0

