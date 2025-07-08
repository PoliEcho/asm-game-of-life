%include "symbols.asm"

section .bss
	extern gameboard_ptr

	extern term_rows
	extern term_cols

	simulation_running: RESB 1

section .rodata 
	clear: 		db ESC_CHAR, "[2J", 0
	reset:		db ESC_CHAR, "[0m", 0

	home_cursor:	db ESC_CHAR, "[H", 0

	statusbar:	db ESC_CHAR, "[100m", "Use arrow keys to move cursor, enter to invert cell h/j to change simulation speed, p to       simulation", 0
	%define START_STOP_position $-statusbar-16
	
	start_str:	db "START", 0
	stop_str:	db "STOP", 0

section .text 
extern print_str
extern string_copy
extern memory_set

global init_gameboard
init_gameboard:
	xor rax, rax
	xor rcx, rcx

	mov ax, [term_cols]
	mov cx, [term_rows]
	mul rcx
	
	push rax
	push rcx
	mov rdi, [gameboard_ptr]
	mov rsi, 0x20; set rsi to SPACE character
	mov rdx, rax
	call memory_set
	pop rcx
	pop rax

	mov rdx, rax
	sub rdx, rcx; get pointer to start of last line
	
	mov rdi, [gameboard_ptr]
	add rdi, rax; get end of gameboard 
	
	sub rdi, 4; get space for reset sequence
	
	lea rsi, [reset]

	push rdx
	call string_copy


	pop rdx
	mov rdi, rdx
	add rdi, [gameboard_ptr]
	lea rsi, [statusbar]
	call string_copy

	ret
	
global print_game_ui
print_game_ui:
	lea rdi, [home_cursor]
	call print_str
	
	mov qword rdi, [gameboard_ptr]
	call print_str
	
	
	ret
