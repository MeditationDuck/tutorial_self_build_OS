;************************************************************************
; 関数呼び出し用マクロ
;
; 使い方：
;	cdecl	func [, param1[, param2[, ...]]]
;
;************************************************************************
%macro  cdecl 1-*.nolist

	%rep  %0 - 1
		push	%{-1:-1}
		%rotate -1
	%endrep 
	%rotate -1

		call	%1

	%if 1 < %0
		add		sp, (__BITS__ >> 3) * (%0 - 1)
	%endif

%endmacro

;************************************************************************
; 割り込みベクタ設定用
;
; 使い方：
;	set_vect	ベクタ番号, 割り込み処理 [, フラグ]
;
;************************************************************************
%macro  set_vect 1-*.nolist
		push	eax
		push	edi

		mov		edi, VECT_BASE + (%1 * 8)		; ベクタアドレス;
		mov		eax, %2

	%if 3 == %0
		mov		[edi + 4], %3					; フラグ
	%endif

		mov		[edi + 0], ax					; 例外アドレス[15: 0]
		shr		eax, 16							; 
		mov		[edi + 6], ax					; 例外アドレス[31:16]

		pop		edi
		pop		eax
%endmacro
;************************************************************************
; ポート出力用
;
; 使い方：
;	outp	ポート番号, 出力値
;
;************************************************************************
%macro  outp 2
		mov		al, %2
		out		%1, al
%endmacro

struc drive
        .no     resw    1
        .cyln   resw    1
        .head   resw    1
        .sect   resw    1
endstruc

