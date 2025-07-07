%include "symbols.asm"

section .bss
	multipurpuse_buf: RESB 8

	term_rows: RESW 1
	term_cols: RESW 1

	gameboard_ptr: RESQ 1

	extern cursor_rows
	extern cursor_cols

section .data
	
section .text
extern print_str
extern unsigned_int_to_ascii
extern init_alloc
extern alloc

global _start
_start:
	; get terminal dimensions
	mov rax, SYS_IOCTL
	mov rdi, STDOUT
	mov rsi, TIOCGWINSZ
	lea rdx, [multipurpuse_buf]
	syscall
	
	mov word ax, [multipurpuse_buf]; rows are stored at offset 0
	mov [term_rows], ax

	mov word ax, [multipurpuse_buf+2]; cols are stored at offset 2
	mov [term_cols], ax

	; handle args
	pop rcx; get argc (number of arguments)
	cmp rcx, 1 
	jle .no_arguments_provided
	; TODO hanndle arguments
	.no_arguments_provided:

	call init_alloc

	mov ax, [term_rows]
	mov cx, [term_cols]
	mul rcx
	mov rdi, rax
	call alloc
	mov [gameboard_ptr], rax; stores pointer to gameboard array




	mov rax, SYS_EXIT
    	mov rdi, 0             ; return code
    	syscall

	

