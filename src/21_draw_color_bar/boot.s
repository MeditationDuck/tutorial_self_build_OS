;************************************************************************
;	BIOS�Ń��[�h�����ŏ��̃Z�N�^
;	
;	�v���O�����S�̂�ʂ��āA�Z�O�����g�̒l��0x0000�Ƃ���B
;	(DS==ES==0)
;	
;************************************************************************

;************************************************************************
;	�}�N��
;************************************************************************
%include	"../include/define.s"
%include	"../include/macro.s"

		ORG		BOOT_LOAD						; ���[�h�A�h���X���A�Z���u���Ɏw��

;************************************************************************
;	�G���g���|�C���g
;************************************************************************
entry:
		;---------------------------------------
		; BPB(BIOS Parameter Block)
		;---------------------------------------
		jmp		ipl								; IPL�փW�����v
		times	90 - ($ - $$) db 0x90			; 

		;---------------------------------------
		; IPL(Initial Program Loader)
		;---------------------------------------
ipl:
		cli										; // ���荞�݋֎~

		mov		ax, 0x0000						; AX = 0x0000;
		mov		ds, ax							; DS = 0x0000;
		mov		es, ax							; ES = 0x0000;
		mov		ss, ax							; SS = 0x0000;
		mov		sp, BOOT_LOAD					; SP = 0x7C00;

		sti										; // ���荞�݋���

		mov		[BOOT + drive.no], dl			; �u�[�g�h���C�u��ۑ�

		;---------------------------------------
		; �������\��
		;---------------------------------------
		cdecl	puts, .s0						; puts(.s0);

		;---------------------------------------
		; �c��̃Z�N�^��S�ēǂݍ���
		;---------------------------------------
		mov		bx, BOOT_SECT - 1				; BX = �c��̃u�[�g�Z�N�^��;
		mov		cx, BOOT_LOAD + SECT_SIZE		; CX = ���̃��[�h�A�h���X;

		cdecl	read_chs, BOOT, bx, cx			; AX = read_chs(.chs, bx, cx);

		cmp		ax, bx							; if (AX != �c��̃Z�N�^��)
.10Q:	jz		.10E							; {
.10T:	cdecl	puts, .e0						;   puts(.e0);
		call	reboot							;   reboot(); // �ċN��
.10E:											; }

		;---------------------------------------
		; ���̃X�e�[�W�ֈڍs
		;---------------------------------------
		jmp		stage_2							; �u�[�g�����̑�2�X�e�[�W

		;---------------------------------------
		; �f�[�^
		;---------------------------------------
.s0		db	"Booting...", 0x0A, 0x0D, 0
.e0		db	"Error:sector read", 0

;************************************************************************
;	�u�[�g�h���C�u�Ɋւ�����
;************************************************************************
ALIGN 2, db 0
BOOT:											; �u�[�g�h���C�u�Ɋւ�����
	istruc	drive
		at	drive.no,		dw	0				; �h���C�u�ԍ�
		at	drive.cyln,		dw	0				; C:�V�����_
		at	drive.head,		dw	0				; H:�w�b�h
		at	drive.sect,		dw	2				; S:�Z�N�^
	iend

;************************************************************************
;	���W���[��
;************************************************************************
%include	"../modules/real/puts.s"
%include	"../modules/real/reboot.s"
%include	"../modules/real/read_chs.s"

;************************************************************************
;	�u�[�g�t���O�i�擪512�o�C�g�̏I���j
;************************************************************************
		times	510 - ($ - $$) db 0x00
		db	0x55, 0xAA

;************************************************************************
;	���A�����[�h���Ɏ擾�������
;************************************************************************
FONT:											; �t�H���g
.seg:	dw	0
.off:	dw	0
ACPI_DATA:										; ACPI data
.adr:	dd	0									; ACPI data address
.len:	dd	0									; ACPI data length

;************************************************************************
;	���W���[���i�擪512�o�C�g�ȍ~�ɔz�u�j
;************************************************************************
%include	"../modules/real/itoa.s"
%include	"../modules/real/get_drive_param.s"
%include	"../modules/real/get_font_adr.s"
%include	"../modules/real/get_mem_info.s"
%include	"../modules/real/kbc.s"
%include	"../modules/real/lba_chs.s"
%include	"../modules/real/read_lba.s"

;************************************************************************
;	�u�[�g�����̑�2�X�e�[�W
;************************************************************************
stage_2:
		;---------------------------------------
		; �������\��
		;---------------------------------------
		cdecl	puts, .s0						; puts(.s0);

		;---------------------------------------
		; �h���C�u�����擾
		;---------------------------------------
		cdecl	get_drive_param, BOOT			; get_drive_param(DX, BOOT.CYLN);
		cmp		ax, 0							; if (0 == AX)
.10Q:	jne		.10E							; {
.10T:	cdecl	puts, .e0						;   puts(.e0);
		call	reboot							;   reboot(); // �ċN��
.10E:											; }

		;---------------------------------------
		; �h���C�u����\��
		;---------------------------------------
		mov		ax, [BOOT + drive.no]			; AX = �u�[�g�h���C�u;
		cdecl	itoa, ax, .p1, 2, 16, 0b0100	; 
		mov		ax, [BOOT + drive.cyln]			; 
		cdecl	itoa, ax, .p2, 4, 16, 0b0100	; 
		mov		ax, [BOOT + drive.head]			; AX = �w�b�h��;
		cdecl	itoa, ax, .p3, 2, 16, 0b0100	; 
		mov		ax, [BOOT + drive.sect]			; AX = �g���b�N������̃Z�N�^��;
		cdecl	itoa, ax, .p4, 2, 16, 0b0100	; 
		cdecl	puts, .s1

		;---------------------------------------
		; ���̃X�e�[�W�ֈڍs
		;---------------------------------------
		jmp		stage_3rd						; ���̃X�e�[�W�ֈڍs

		;---------------------------------------
		; �f�[�^
		;---------------------------------------
.s0		db	"2nd stage...", 0x0A, 0x0D, 0

.s1		db	" Drive:0x"
.p1		db	"  , C:0x"
.p2		db	"    , H:0x"
.p3		db	"  , S:0x"
.p4		db	"  ", 0x0A, 0x0D, 0

.e0		db	"Can't get drive parameter.", 0

;************************************************************************
;	�u�[�g�����̑�3�X�e�[�W
;************************************************************************
stage_3rd:
		;---------------------------------------
		; �������\��
		;---------------------------------------
		cdecl	puts, .s0

		;---------------------------------------
		; �v���e�N�g���[�h�Ŏg�p����t�H���g�́A
		; BIOS�ɓ������ꂽ���̂𗬗p����
		;---------------------------------------
		cdecl	get_font_adr, FONT				; // BIOS�̃t�H���g�A�h���X���擾

		;---------------------------------------
		; �t�H���g�A�h���X�̕\��
		;---------------------------------------
		cdecl	itoa, word [FONT.seg], .p1, 4, 16, 0b0100
		cdecl	itoa, word [FONT.off], .p2, 4, 16, 0b0100
		cdecl	puts, .s1

		;---------------------------------------
		; ���������̎擾�ƕ\��
		;---------------------------------------
		cdecl	get_mem_info					; get_mem_info();

		mov		eax, [ACPI_DATA.adr]			; EAX = ACPI_DATA.adr;
		cmp		eax, 0							; if (EAX)
		je		.10E							; {

		cdecl	itoa, ax, .p4, 4, 16, 0b0100	;   itoa(AX); // ���ʃA�h���X��ϊ�
		shr		eax, 16							;   EAX >>= 16;
		cdecl	itoa, ax, .p3, 4, 16, 0b0100	;   itoa(AX); // ��ʃA�h���X��ϊ�

		cdecl	puts, .s2						;   puts(.s2); // �A�h���X��\��
.10E:											; }

		;---------------------------------------
		; ���̃X�e�[�W�ֈڍs
		;---------------------------------------
		jmp		stage_4							; ���̃X�e�[�W�ֈڍs

		;---------------------------------------
		; �f�[�^
		;---------------------------------------
.s0:	db	"3rd stage...", 0x0A, 0x0D, 0

.s1:	db	" Font Address="
.p1:	db	"ZZZZ:"
.p2:	db	"ZZZZ", 0x0A, 0x0D, 0
		db	0x0A, 0x0D, 0

.s2:	db	" ACPI data="
.p3:	db	"ZZZZ"
.p4:	db	"ZZZZ", 0x0A, 0x0D, 0

;************************************************************************
;	�u�[�g�����̑�4�X�e�[�W
;************************************************************************
stage_4:
		;---------------------------------------
		; �������\��
		;---------------------------------------
		cdecl	puts, .s0

		;---------------------------------------
		; A20�Q�[�g�̗L����
		;---------------------------------------
		cli										;   // ���荞�݋֎~
												;   
		cdecl	KBC_Cmd_Write, 0xAD				;   // �L�[�{�[�h������
												;   
		cdecl	KBC_Cmd_Write, 0xD0				;   // �o�̓|�[�g�ǂݏo���R�}���h
		cdecl	KBC_Data_Read, .key				;   // �o�̓|�[�g�f�[�^
												;   
		mov		bl, [.key]						;   BL  = key;
		or		bl, 0x02						;   BL |= 0x02; // A20�Q�[�g�L����
												;   
		cdecl	KBC_Cmd_Write, 0xD1				;   // �o�̓|�[�g�������݃R�}���h
		cdecl	KBC_Data_Write, bx				;   // �o�̓|�[�g�f�[�^
												;   
		cdecl	KBC_Cmd_Write, 0xAE				;   // �L�[�{�[�h�L����
												;   
		sti										;   // ���荞�݋���

		;---------------------------------------
		; �������\��
		;---------------------------------------
		cdecl	puts, .s1

		;---------------------------------------
		; �L�[�{�[�hLED�̃e�X�g
		;---------------------------------------
		cdecl	puts, .s2						; 

		mov		bx, 0							; CX = LED�̏����l;
.10L:											; do
												; {
		mov		ah, 0x00						;   // �L�[���͑҂�
		int		0x16							;   AL = BIOS(0x16, 0x00);
												;   
		cmp		al, '1'							;   if (AL < '1')
		jb		.10E							;     break;
												;   
		cmp		al, '3'							;   if ('3' < AL)
		ja		.10E							;     break;
												;   
		mov		cl, al							;   CL   = �L�[����;
		dec		cl								;   CL  -= 1;       // 1���Z
		and		cl, 0x03						;   CL  &= 0x03;    // 0�`2�ɐ���
		mov		ax, 0x0001						;   AX   = 0x0001;  // �r�b�g�ϊ��p
		shl		ax, cl							;   AX <<= CL;      // 0�`2�r�b�g���V�t�g
		xor		bx, ax							;   BX  ^= AX;      // �r�b�g���]

		;---------------------------------------
		; LED�R�}���h�̑��M
		;---------------------------------------
		cli										;   // ���荞�݋֎~
												;   
		cdecl	KBC_Cmd_Write, 0xAD				;   // �L�[�{�[�h������
												;   
		cdecl	KBC_Data_Write, 0xED			;   // LED�R�}���h
		cdecl	KBC_Data_Read, .key				;   // ��M����
												;   
		cmp		[.key], byte 0xFA				;   if (0xFA == key)
		jne		.11F							;   {
												;     
		cdecl	KBC_Data_Write, bx				;     // LED�f�[�^�o��
												;   }
		jmp		.11E							;   else
.11F:											;   {
		cdecl	itoa, word [.key], .e1, 2, 16, 0b0100
		cdecl	puts, .e0						;     // ��M�R�[�h��\��
.11E:											;   }
												;   
		cdecl	KBC_Cmd_Write, 0xAE				;   // �L�[�{�[�h�L����
												;   
		sti										;   // ���荞�݋���
												;   
		jmp		.10L							; } while (1);
.10E:

		;---------------------------------------
		; �������\��
		;---------------------------------------
		cdecl	puts, .s3

		;---------------------------------------
		; ���̃X�e�[�W�ֈڍs
		;---------------------------------------
		jmp		stage_5							; ���̃X�e�[�W�ֈڍs

.s0:	db	"4th stage...", 0x0A, 0x0D, 0
.s1:	db	" A20 Gate Enabled.", 0x0A, 0x0D, 0
.s2:	db	" Keyboard LED Test...", 0
.s3:	db	" (done)", 0x0A, 0x0D, 0
.e0:	db	"["
.e1:	db	"ZZ]", 0

.key:	dw	0

;************************************************************************
;	�u�[�g�����̑�5�X�e�[�W
;************************************************************************
stage_5:
		;---------------------------------------
		; �������\��
		;---------------------------------------
		cdecl	puts, .s0

		;---------------------------------------
		; �J�[�l����ǂݍ���
		;---------------------------------------
		cdecl	read_lba, BOOT, BOOT_SECT, KERNEL_SECT, BOOT_END
												; AX = read_lba(.lba, ...);
		cmp		ax, KERNEL_SECT					; if (AX != CX)
.10Q:	jz		.10E							; {
.10T:	cdecl	puts, .e0						;   puts(.e0);
		call	reboot							;   reboot(); // �ċN��
.10E:											; }
												; 

		;---------------------------------------
		; ���̃X�e�[�W�ֈڍs
		;---------------------------------------
		jmp		stage_6							; ���̃X�e�[�W�ֈڍs

.s0		db	"5th stage...", 0x0A, 0x0D, 0
.e0		db	" Failure load kernel...", 0x0A, 0x0D, 0

;************************************************************************
;	�u�[�g�����̑�6�X�e�[�W
;************************************************************************
stage_6:
		;---------------------------------------
		; �������\��
		;---------------------------------------
		cdecl	puts, .s0

		;---------------------------------------
		; ���[�U�[����̓��͑҂�
		;---------------------------------------
.10L:											; do
												; {
		mov		ah, 0x00						;   // �L�[���͑҂�
		int		0x16							;   AL = BIOS(0x16, 0x00);
		cmp		al, ' '							;   ZF = AL == ' ';
		jne		.10L							; } while (!ZF);
												; 

		;---------------------------------------
		; �r�f�I���[�h�̐ݒ�
		;---------------------------------------
		mov		ax, 0x0012						; VGA 640x480
		int		0x10							; BIOS(0x10, 0x12); // �r�f�I���[�h�̐ݒ�

		;---------------------------------------
		; ���̃X�e�[�W�ֈڍs
		;---------------------------------------
		jmp		stage_7							; ���̃X�e�[�W�ֈڍs

.s0		db	"6th stage...", 0x0A, 0x0D, 0x0A, 0x0D
		db	" [Push SPACE key to protect mode...]", 0x0A, 0x0D, 0

;************************************************************************
;	GLOBAL DESCRIPTOR TABLE
;	(�Z�O�����g�f�B�X�N���v�^�̔z��)
;************************************************************************
;
;   �Z�O�����g�f�B�X�N���v�^
;
;        +--------+-----------------: Base (0xBBbbbbbb)
;        |   +----|--------+--------: Limit(0x000Lllll)
;        |   |    |        |
;       +--+--+--+--+--+--+--+--+
;       |B |FL|f |b       |l    |
;       +--+--+--+--+--+--+--+--+
;           |  |                         76543210
;           |  +--------------------: f:PDDSTTTA
;           |                          P:Exist
;           |                          D:DPL(����)
;           |                          S:(DT)0=�V�X�e��or�Q�[�g, 1=�f�[�^�Z�O�����g
;           |                          T:Type
;           |                            000(0)=R/- DATA
;           |                            001(1)=R/W DATA
;           |                            010(2)=R/- STACK
;           |                            011(3)=R/W STACK
;           |                            100(4)=R/- CODE
;           |                            101(5)=R/W CODE
;           |                            110(6)=R/- CONFORM
;           |                            111(7)=R/W CONFORM
;           |                          A:Accessed
;           |                       
;           +-----------------------: F:GD0ALLLL
;                                      G:Limit Scale(0=1, 1=4K)
;                                      D:Data/BandDown(0=16, 1=32Bit �Z�O�����g)
;                                      A:any
;                                      L:Limit[19:16]
ALIGN 4, db 0
;					  B_ F L f T b_____ l___
GDT:			dq	0x00_0_0_0_0_000000_0000	; NULL
.cs:			dq	0x00_C_F_9_A_000000_FFFF	; CODE 4G
.ds:			dq	0x00_C_F_9_2_000000_FFFF	; DATA 4G
.gdt_end:

;===============================================
;	�Z���N�^
;===============================================
SEL_CODE	equ	.cs - GDT						; �R�[�h�p�Z���N�^
SEL_DATA	equ	.ds - GDT						; �f�[�^�p�Z���N�^

;===============================================
;	GDT
;===============================================
GDTR:	dw 		GDT.gdt_end - GDT - 1			; �f�B�X�N���v�^�e�[�u���̃��~�b�g
		dd 		GDT								; �f�B�X�N���v�^�e�[�u���̃A�h���X

;===============================================
;	IDT�i�^���F���荞�݋֎~�ɂ���ׁj
;===============================================
IDTR:	dw 		0								; idt_limit
		dd 		0								; idt location

;************************************************************************
;	�u�[�g�����̑�7�X�e�[�W
;************************************************************************
stage_7:
		cli										; // ���荞�݋֎~

		;---------------------------------------
		; GDT���[�h
		;---------------------------------------
		lgdt	[GDTR]							; // �O���[�o���f�B�X�N���v�^�e�[�u�������[�h
		lidt	[IDTR]							; // ���荞�݃f�B�X�N���v�^�e�[�u�������[�h

		;---------------------------------------
		; �v���e�N�g���[�h�ֈڍs
		;---------------------------------------
		mov		eax,cr0							; // PE�r�b�g���Z�b�g
		or		ax, 1							; CR0 |= 1;
		mov		cr0,eax							; 

		jmp		$ + 2							; ��ǂ݂��N���A

		;---------------------------------------
		; �Z�O�����g�ԃW�����v
		;---------------------------------------
[BITS 32]
		DB		0x66							; �I�y�����h�T�C�Y�I�[�o�[���C�h�v���t�B�b�N�X
		jmp		SEL_CODE:CODE_32

;************************************************************************
;	32�r�b�g�R�[�h�J�n
;************************************************************************
CODE_32:

		;---------------------------------------
		; �Z���N�^��������
		;---------------------------------------
		mov		ax, SEL_DATA					;
		mov		ds, ax							;
		mov		es, ax							;
		mov		fs, ax							;
		mov		gs, ax							;
 		mov		ss, ax							;

		;---------------------------------------
		; �J�[�l�������R�s�[
		;---------------------------------------
		mov		ecx, (KERNEL_SIZE) / 4			; ECX = 4�o�C�g�P�ʂŃR�s�[;
		mov		esi, BOOT_END					; ESI = 0x0000_9C00; // �J�[�l����
		mov		edi, KERNEL_LOAD				; EDI = 0x0010_1000; // ��ʃ�����
		cld										; // DF�N���A�i+�����j
		rep movsd								; while (--ECX) *EDI++ = *ESI++;

		;---------------------------------------
		; �J�[�l�������Ɉڍs
		;---------------------------------------
		jmp		KERNEL_LOAD						; �J�[�l���̐擪�ɃW�����v


;************************************************************************
;	�p�f�B���O
;************************************************************************
		times BOOT_SIZE - ($ - $$)		db	0	; �p�f�B���O

