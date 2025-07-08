%include "symbols.asm"

section .bss
	multipurpuse_buf: RESB 8
	
	global term_rows
	term_rows: RESW 1
	global term_cols
	term_cols: RESW 1
	
	global gameboard_ptr
	gameboard_ptr: RESQ 1

	extern cursor_rows
	extern cursor_cols

	
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

	

