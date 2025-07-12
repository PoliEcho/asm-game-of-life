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
TCGETS		equ 0x5401
TCSETS		equ 0x5402
F_SETFL		equ 4 
O_NONBLOCK	equ 2048
POLLIN		equ 0x0100; compensate for litle endian

NOT_ECHO	equ -9
NOT_ICANON	equ -3

EAGAIN		equ -11

ASCII_ZERO 	equ 48
ESC_CHAR 	equ 27

ESC_chars_compensation_Len equ 9; i have to compensate for escape sequences that dont get printed why 11 exactly, I dont know
