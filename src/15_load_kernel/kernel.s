%include       "../include/define.s"
%include       "../include/macro.s"

    ORG      KERNEL_LOAD

[BITS 32]

; エントリーポイント

kernel:
    
    jmp     $   

; パディング

    times  KERNEL_SIZE -($ - $$)    db 0
    
