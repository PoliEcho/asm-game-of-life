SYS_EXIT 	equ 60
SYS_IOCTL	equ 16
SYS_WRITE 	equ 1
SYS_BRK		equ 12

STDOUT		equ 1
TIOCGWINSZ	equ 0x5413

ASCII_ZERO 	equ 48
ESC_CHAR 	equ 27

ESC_chars_compensation_Len equ 13; i have to compensate for escape sequences that dont get printed why 11 exactly, I dont know
