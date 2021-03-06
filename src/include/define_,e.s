
BOOT_SIZE       equ     (1024 * 8)              ;ブートコードサイズ
KERNEL_SIZE     equ     (1024 * 8)   
BOOT_LOAD       equ     0x7c00                  ;ブートプログラムのロード位置
                                                ;これがないと0x0000にロードされることになってしまうが
                                                ;BIOSそこはがすでに使っている領域である

BOOT_END        equ     (BOOT_LOAD + BOOT_SIZE)
SECT_SIZE       equ     (512)                   ;セクタサイズ
BOOT_SECT       equ     (BOOT_SIZE/SECT_SIZE)   ;ブートプログラムのセクタサイズ
KERNEL_SECT     equ     (KERNEL_SIZE/SECT_SIZE)

E820_RECORD_SIZE    equ     20

KERNEL_LOAD     equ     0x0010_1000

VECT_BASE			equ		0x0010_0000		;	0010_0000:0010_07FF