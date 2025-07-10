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

	statusbar:	db ESC_CHAR, "[30;100m", "Use arrow keys to move cursor, enter to invert cell j/k to change simulation speed, p to       simulation", 0
	START_STOP_pos: equ $-statusbar-17
	
	
	start_str:	db "START", 0
	stop_str:	db "STOP ", 0

section .text 
extern print_str
extern string_copy
extern memory_set
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

%macro check_if_hashtag 1
	cmp r8, %1
	jl +7
	cmp r9, %1 
	ja +5
	mov r11b, [%1]
	cmp r11b, '#' 
	jne +2 
	inc dl
%endmacro

global step_simulation:
step_simultion:
	mov rdi, [next_frame_ptr]; destination
	mov rsi, [gameboard_ptr]; source 
	mov rcx, [gameboard_size]; number of iterations

	mov r8, rsi; store lowest address posible so we are not checking out of bounds
	mov r9, rsi
	add r9, rcx; store higest address posible so we are not checking out of bounds

	mov r10, [term_cols]
	;mov r11, [term_rows] this register has been confiscated since i cannot use ah because of error: cannot use high byte register in rex instruction

	xor rax, rax; this shouldn't be needed but just to be sure
	xor r11, r11
	xor rdx, rdx; we will use dl as # counter 
	.for_every_column_on_gameboard:
	mov al, [rdi]; NOTE to self if i need extra register i can shift this to ah and free up r11
	
	
	inc rdi
	check_if_hashtag rdi
	dec rdi

	check_if_hashtag rdi-1


	add rdi, r10
	
	check_if_hashtag rdi

	inc rdi
	check_if_hashtag rdi
	dec rdi

	check_if_hashtag rdi-1

	sub rdi, r10


	sub rdi, r10	
	check_if_hashtag rdi

	inc rdi
	check_if_hashtag rdi
	dec rdi

	check_if_hashtag rdi-1

	add rdi, r10


	; TODO create jump table

	ret
