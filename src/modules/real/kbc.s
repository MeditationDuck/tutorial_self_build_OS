KBC_Data_Write:
        push    bp
        mov     bp, sp
        push    cx

        mov     cx, 0
.10L:
        in      al, 0x64        ; AL = inp(0x64) KBCステータス
        test    al, 0x02        ; ZF = AL & 0x02  書き込み可能か？
        loopz  .10L

        cmp     cx, 0
        jz     .20E

        mov     al, [bp + 4]    ; AL = データ
        out     0x60, al        ; outp(0x60, AL) 60番ポートつまりデータとしてpcが解釈
.20E:
        mov     ax, cx
        
        pop     cx
        mov     sp, bp
        pop     bp
        ret                     ;うまくいくとゼロ以外が帰る

KBC_Data_Read:
        push    bp
        mov     bp, sp
        push    cx

        mov     cx, 0
.10L:
        in      al, 0x64        ; AL = inp(0x64) KBCステータス
        test    al, 0x01        ; ZF = AL & 0x01  読み込み可能か？
        loopz  .10L

        cmp     cx, 0
        jz     .20E

        mov     al, 0x00        ; ah = 0x00
        in      al, 0x60        ; al = inp(0x60)

        mov     di, [bp + 4]    ; di = ptr
        mov     [di + 0], ax    ; 
.20E:
        mov     ax, cx
        
        pop     cx
        mov     sp, bp
        pop     bp
        ret

KBC_Cmd_Write:         ; KBC_Data_Writeとほぼ同じ
        push    bp
        mov     bp, sp
        push    cx

        mov     cx, 0
.10L:
        in      al, 0x64        
        test    al, 0x02        
        loopz  .10L

        cmp     cx, 0
        jz     .20E

        mov     al, [bp + 4]   
        out     0x64, al        ; outp(0x64, AL)  64ポート つまり コマンド書き込みとしてPCが解釈
.20E:
        mov     ax, cx
        
        pop     cx
        mov     sp, bp
        pop     bp
        ret
