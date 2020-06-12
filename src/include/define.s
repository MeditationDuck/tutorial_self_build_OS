BOOT_LOAD       equ     0x7c00                  ;ブートプログラムのロード位置
                                                ;これがないと0x0000にロードされることになってしまうが
                                                ;BIOSそこはがすでに使っている領域である

BOOT_SIZE       equ     (1024 * 8)              ;ブートコードサイズ
SECT_SIZE       equ     (512)                   ;セクタサイズ
BOOT_SECT       equ     (BOOT_SIZE/SECT_SIZE)   ;ブートプログラムのセクタサイズ

E820_RECORD_SIZE    equ     20
