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
	
	global running_in_tty
	running_in_tty: RESB 1
	
section .rodata
	extern resetLen

	hide_cursor: db ESC_CHAR, "[?25l", 0
	show_cursor: db ESC_CHAR, "[?25h", 0

	help_text: db "asm-game-of-life [args]",0xA,"-h	display this help menu",0xA,"Controls:",0xA,"use arrow keys to move around",0xA,"ENTER to invert cell",0xA,"p     to START/STOP simulation",0xA,"k     to increase simulation speed",0xA,"j     to decrese simulation speed",0xA, 0

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
	pop rax; get rid of program name arugument
	cmp rcx, 1 
	jle .no_arguments_provided
	dec rcx
	.handle_arg:
	pop rax
	mov word di, [rax]

	cmp di, 0x682D; check if -h was passed
	jne .next_arg
	lea rdi, [help_text]
	call print_str
	jmp .exit_program

	.next_arg:
	dec rcx
	test rcx, rcx
	jnz .handle_arg
	
	.no_arguments_provided:

	
	pop rax; get rid of null termination of argv 
	; handle enviroment vars

	.handle_env:
	pop rax
	test rax, rax; test if we reached end of envs
	jz .no_envs

	mov dword edi, [rax]
	cmp edi, 0x4D524554; check for "TERM" inverted becose endiannes
	jne .handle_env
	mov qword rdi, [rax+5]; remove the TERM= part this should never segfault since there sould allwas be other data behind enviroment vars and i dont mind garbage 
	mov rsi, 0xffffffffff
	and rdi, rsi
	mov rsi, 0x78756e696c
	cmp rdi, rsi; check for "linux"
	jne .no_envs
	mov byte [running_in_tty], 1

	.no_envs:


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

	call print_game_ui

	call handle_user_input

	call reset_terminal

	lea rdi, [show_cursor]
	call print_str

	.exit_program:
	mov rax, SYS_EXIT
    	mov rdi, 0             ; return code
    	syscall

	

