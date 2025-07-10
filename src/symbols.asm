SYS_EXIT 	equ 60
SYS_IOCTL	equ 16
SYS_READ 	equ 0
SYS_WRITE 	equ 1
SYS_BRK		equ 12
SYS_FCNTL	equ 72
SYS_POLL	equ 7

STDIN		equ 0
STDOUT		equ 1

TIOCGWINSZ	equ 0x5413
POLLIN		equ 1 
F_SETFL		equ 4 
O_NONBLOCK	equ 2048

ASCII_ZERO 	equ 48
ESC_CHAR 	equ 27

ESC_chars_compensation_Len equ 9; i have to compensate for escape sequences that dont get printed why 11 exactly, I dont know
