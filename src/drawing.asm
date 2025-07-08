%include "symbols.asm"

section .bss
	extern gameboard_ptr

	extern term_rows
	extern term_cols

	simulation_running: RESB 1

section .rodata 
	clear: 		db ESC_CHAR, "[2J", 0
	reset:		db ESC_CHAR, "[0m", 0

	statusbar:	db ESC_CHAR, "[100m", "Use arrow keys to move cursor, enter to invert cell, p to       simulation", 0 
	
	start_str:	db "START", 0
	stop_str:	db "STOP", 0

section .text 
extern print_str
extern string_copy

init_gameboard:
	mov ax, [term_cols]
	mov cx, [term_rows]
	mul rcx

	mov rdx, rax
	sub rdx, rcx; get pointer to start of last line
	
	lea rdi, [gameboard_ptr]
	add rdi, rax; get end of gameboard 
	
	sub rdi, 5; get space for reset sequence
	
	lea rsi, [reset]

	push rdx
	call string_copy

	pop rdx
	mov rdi, rdx
	lea rsi, [statusbar]
	call string_copy

	ret
	

print_game_ui:
	lea rdi, [clear]
	call print_str



	
	
	ret
