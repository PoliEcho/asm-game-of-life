%include "symbols.asm"



section .bss
	global multipurpuse_buf
	multipurpuse_buf: RESB 16
	
	global term_rows
	term_rows: RESW 1
	global term_cols
	term_cols: RESW 1
	
	global gameboard_ptr
	gameboard_ptr: RESQ 1

	global gameboard_size
	gameboard_size: RESQ 1

	extern cursor_rows
	extern cursor_cols

	
section .rodata
	extern resetLen

	hide_cursor: db ESC_CHAR, "[?25l", 0
	show_cursor: db ESC_CHAR, "[?25h", 0

section .text
extern print_str
extern unsigned_int_to_ascii
extern init_alloc
extern alloc

extern init_gameboard
extern print_game_ui

extern handle_user_input

extern disable_canonical_mode_and_echo
extern reset_terminal

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

	xor rax, rax
	xor rcx, rcx

	mov ax, [term_rows]
	mov cx, [term_cols]
	mul rcx
	mov rdi, rax
	mov qword [gameboard_size], rax
	inc rdi; addition byte for NULL BYTE
	lea rax, [resetLen]
	add rdi, rax
	add rdi, ESC_chars_compensation_Len
	call alloc
	mov [gameboard_ptr], rax; stores pointer to gameboard array
	call init_gameboard

	; make stdin non-blocking in case polling somehow fails, or am i stupid
	mov rax, SYS_FCNTL
	mov rdi, STDIN
	mov rsi, F_SETFL
	mov rdx, O_NONBLOCK
	syscall

	lea rdi, [hide_cursor]
	call print_str

	call print_game_ui	

	call disable_canonical_mode_and_echo

	call handle_user_input

	call reset_terminal

	lea rdi, [show_cursor]
	call print_str

	mov rax, SYS_EXIT
    	mov rdi, 0             ; return code
    	syscall

	

