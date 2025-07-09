%include "symbols.asm"



section .bss
	extern gameboard_ptr

	extern term_rows
	extern term_cols

	extern gameboard_size

	simulation_running: RESB 1

section .rodata 
	clear: 		db ESC_CHAR, "[2J", 0
	reset:		db ESC_CHAR, "[0m", 0
	resetLen:	equ $-reset-1
	global resetLen

	home_cursor:	db ESC_CHAR, "[H", 0

	statusbar:	db ESC_CHAR, "[30;100m", "Use arrow keys to move cursor, enter to invert cell h/j to change simulation speed, p to       simulation", 0
	START_STOP_pos: equ $-statusbar-16
	
	
	start_str:	db "START", 0
	stop_str:	db "STOP ", 0

section .text 
extern print_str
extern string_copy
extern memory_set

global init_gameboard
init_gameboard:
	xor rax, rax
	xor rcx, rcx

	
	mov rdi, [gameboard_ptr]
	push rdi
	mov rsi, 0x20; set rsi to SPACE character
	mov rdx, [gameboard_size]
	push rdx
	add rdx, ESC_chars_compensation_Len+2; I dont know how this work but it works so i wont touch it
	call memory_set
	

	pop rdx
	pop rdi
	add rdi, rdx; get pointer to last char on screen
	push rdi
	add rdi, 9; I dont know how this work but it works so i wont touch it
	push rdi
	lea rsi, [reset]

	call string_copy
	pop rax
	mov byte [rax+resetLen], 0; I dont know how this work but it works so i wont touch it

	pop rdi
	xor rax, rax
	mov ax, [term_cols]
	sub rdi, rax
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
