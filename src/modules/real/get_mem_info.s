get_mem_info:

        push    eax
        push    ebx
        push    ecx
        push    edx
        push    si
        push    di
        push    bp

        mov     bp, 0                   ; lines = 0 //行数
        mov     ebx, 0                  ; index = 0
.10L:

        mov    eax, 0x0000E820          ; EAX = 0xE820

        mov     ecx, E820_RECORD_SIZE   ;ebx = インデックス
        mov     edx, 'PAMS'             ; ecx = サイズ
        mov     di, .b0                 ; edx = 'SMAP'
        int     0x15                    ; es:di = バッファ

        cmp     eax, 'PAMS'
        je      .12E
        jmp     .10E
.12E:
        jnc     .14E
        jmp     .10E

.14E:
        cdecl   put_mem_info, di       ; 1レコード分のメモリ情報を表示

        ; acpi data のアドレスを取得

        mov     eax, [di + 16]          ; eax = レコードタイプ
        mov     eax, 3                  ; 3 の時 acpiデータが有る
        jne     .15E

        mov     eax, [di + 0]
        mov     [ACPI_DATA.adr], eax         

        mov     eax, [di + 8]
        mov     [ACPI_DATA.len], eax 
.15E:
        cmp     ebx, 0              ;   if(ebx != 0) // 最終レコードを取得するとebx に0が入る
        jz      .16E

        inc     bp                  ;line++
        and     bp, 0x07            ;lines &= 0x07
        jnz     .16E                ;if lines==0

        cdecl   puts, .s2

        mov     ah, 0x10            ; al = bios(0x16, 0x10) キー入力待ち
        int     0x16

        cdecl   puts, .s3
.16E:
        cmp     ebx, 0
        jne     .10L
.10E:
	pop	bp
	pop	di
	pop	si
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	ret


.s2:    db "<more...>", 0
.s3:    db 0x0D, "         ", 0x0D, 0


.b0:	times E820_RECORD_SIZE db 0

put_mem_info:
        
        push    bp
        mov     bp, sp

        push    bx
        push    si

        mov     si, [bp + 4]

        cdecl   itoa, word [si + 6], .p2 + 0, 4, 16, 0b0100
        cdecl   itoa, word [si + 4], .p2 + 4, 4, 16, 0b0100
        cdecl   itoa, word [si + 2], .p3 + 0, 4, 16, 0b0100
        cdecl   itoa, word [si + 0], .p3 + 4, 4, 16, 0b0100

        cdecl   itoa, word [si + 14], .p4 + 0, 4, 16, 0b0100
        cdecl   itoa, word [si + 12], .p4 + 4, 4, 16, 0b0100
        cdecl   itoa, word [si + 10], .p5 + 0, 4, 16, 0b0100
        cdecl   itoa, word [si + 8], .p5 + 4, 4, 16, 0b0100

        cdecl   itoa, word [si + 6], .p2 + 0, 4, 16, 0b0100
        cdecl   itoa, word [si + 6], .p2 + 0, 4, 16, 0b0100

        cdecl   puts, .s1

        mov     bx, [si + 16]   ;Type文字列を表示したい
        and     bx, 0x07                
        shl     bx, 1
        add     bx, .t0         ;テーブルの先頭アドレスを加算
        cdecl   puts, word[bx]

        pop     si
	pop	bx

	mov	sp, bp
	pop	bp

	ret



.s1:	db " "
.p2:	db "ZZZZZZZZ_"
.p3:	db "ZZZZZZZZ "
.p4:	db "ZZZZZZZZ_"
.p5:	db "ZZZZZZZZ "
.p6:	db "ZZZZZZZZ", 0

.s4:	db " (Unknown)", 0x0A, 0x0D, 0
.s5:	db " (usable)", 0x0A, 0x0D, 0
.s6:	db " (reserved)", 0x0A, 0x0D, 0
.s7:	db " (ACPI data)", 0x0A, 0x0D, 0
.s8:	db " (ACPI NVS)", 0x0A, 0x0D, 0
.s9:	db " (bad memory)", 0x0A, 0x0D, 0

.t0:	dw .s4, .s5, .s6, .s7, .s8, .s9, .s4, .s4

        