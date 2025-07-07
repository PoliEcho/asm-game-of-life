SYS_EXIT 	equ 60
SYS_IOCTL	equ 16

STDOUT		equ 1
TIOCGWINSZ	equ 0x5413

section .bss

	str_buf: resb 4

section .data

section .text
global _start
extern print_str
extern unsigned_int_to_ascii

_start:
	
