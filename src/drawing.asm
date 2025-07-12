%include "symbols.asm"



section .bss
	extern gameboard_ptr

	extern term_rows
	extern term_cols

	extern gameboard_size
	
	global simulation_running
	simulation_running: RESB 1

	next_frame_ptr: RESQ 1

section .rodata 
	clear: 		db ESC_CHAR, "[2J", 0
	reset:		db ESC_CHAR, "[0m", 0
	resetLen:	equ $-reset-1
	global resetLen

	home_cursor:	db ESC_CHAR, "[H", 0

	statusbar:	db ESC_CHAR, "[32;100m", "Use arrow keys to move cursor, enter to invert cell j/k to change simulation speed, p to       simulation", 0
	START_STOP_pos: equ $-statusbar-17
	
	
	start_str:	db "START", 0
	stop_str:	db "STOP ", 0

	alive_switch_statement:
		dq step_simulation.die; 0
		dq step_simulation.die; 1
		dq step_simulation.live; 2
		dq step_simulation.live; 3
		dq step_simulation.die; 4
		dq step_simulation.die; 5
		dq step_simulation.die; 6
		dq step_simulation.die; 7
		dq step_simulation.die; 8


section .text 
extern print_str
extern string_copy
extern memory_set
extern memory_copy
extern alloc

global init_gameboard
init_gameboard:
	xor rax, rax
	xor rcx, rcx

	
	mov rdi, [gameboard_ptr]
	push rdi
	mov rsi, 0x20; set rsi to SPACE character
	mov rdx, [gameboard_size]
	push rdx
	add rdx, ESC_chars_compensation_Len; I dont know how this work but it works so i wont touch it
	call memory_set
	

	pop rdx
	pop rdi
	add rdi, rdx; get pointer to last char on screen
	push rdx
	push rdi
	add rdi, ESC_chars_compensation_Len
	lea rsi, [reset]

	call string_copy
	pop rdi
	xor rax, rax
	mov ax, [term_cols]
	sub rdi, rax
	lea rsi, [statusbar]
	call string_copy

	pop rdi 
	call alloc
	mov [next_frame_ptr], rax
	ret
	
global print_game_ui
print_game_ui:
	lea rdi, [home_cursor]
	call print_str

	mov qword rdi, [gameboard_ptr]
	push rdi
	add rdi, [gameboard_size]
	sub di, [term_cols]
	add rdi, START_STOP_pos
	
	mov cl, [simulation_running]
	test cl,cl; test if simulation is running 
	jz .simulation_not_running
	lea rsi, [stop_str]
	jmp .end_simulation_running_check
	.simulation_not_running:
	lea rsi, [start_str]
	.end_simulation_running_check:
	call string_copy

	pop rdi
	call print_str
	
	
	ret

%macro check_if_hashtag 2
	cmp %1, r8
	jl .no_count_%2
	cmp %1, r9
	ja .no_count_%2
	mov r11b, [%1]
	cmp r11b, '#' 
	jne .no_count_%2
	inc dl
	.no_count_%2:
%endmacro

global step_simulation:
step_simulation:
	mov rdi, [next_frame_ptr]; destination
	mov rsi, [gameboard_ptr]; source 
	mov rcx, [gameboard_size]; number of iterations
	
	mov r8, rsi; store lowest address posible so we are not checking out of bounds
	mov r9, rsi
	add r9, rcx; store higest address posible so we are not checking out of bounds

	xor r10, r10
	mov r10w, [term_cols]
	;mov r11, [term_rows] this register has been confiscated since i cannot use ah because of error: cannot use high byte register in rex instruction

	sub rcx, r10; remove status bar

	xor rax, rax; this shouldn't be needed but just to be sure
	xor r11, r11
	xor rdx, rdx; we will use dl as # counter 
	.for_every_column_on_gameboard:
	xor dl, dl
	mov al, [rsi]; NOTE to self if i need extra register i can shift this to ah and free up r11
	
	
	inc rsi
	check_if_hashtag rsi, 1; check column to the to the right
	dec rsi

	dec rsi
	check_if_hashtag rsi, 2; check the one to the left
	inc rsi

	add rsi, r10
	
	check_if_hashtag rsi, 3; check the one to the down

	inc rsi
	check_if_hashtag rsi, 4; check the one to the down-right
	dec rsi

	dec rsi
	check_if_hashtag rsi, 5; check the one to the down-left
	inc rsi

	sub rsi, r10


	sub rsi, r10	
	check_if_hashtag rsi, 6; check the one to the up

	inc rsi
	check_if_hashtag rsi, 7; check the one to the up-right
	dec rsi

	dec rsi
	check_if_hashtag rsi, 8; check the one to the up-left
	inc rsi

	add rsi, r10

	cmp al, '#'
	jne .dead_cell

	jmp [alive_switch_statement+(rdx*8)]

	.die:
	mov byte [rdi], 0x20; SPACE
	jmp .end_check

	.live:
	mov byte [rdi], '#'
	jmp .end_check

	.dead_cell:
	cmp dl, 3 
	jne .fill_space_there
	mov byte [rdi], '#'
	jmp .end_check
	.fill_space_there:
	mov byte [rdi], 0x20; SPACE

	.end_check:
	dec rcx
	inc rdi
	inc rsi
	test rcx, rcx
	jnz .for_every_column_on_gameboard

	mov rsi, [next_frame_ptr]; source
	mov rdi, [gameboard_ptr]; destination 
	mov rdx, [gameboard_size]; number of iterations
	sub rdx, r10; remove statusbar

	call memory_copy

	ret
