%include "symbols.asm"

section .bss
	cursor_rows: RESW 1; TODO DONT FORGET TO INICIALIZE
	cursor_cols: RESW 1

	extern multipurpuse_buf

	extern term_rows
	extern term_cols

	extern gameboard_ptr

	extern simulation_running

section .rodata

	cursor_up: db ESC_CHAR, "[1A", 0
	cursor_down: db ESC_CHAR, "[1B", 0
	cursor_right: db ESC_CHAR, "[1C", 0
	cursor_left: db ESC_CHAR, "[1D", 0
	

	arrow_switch_statement:
		dq handle_user_input.arrow_up
		dq handle_user_input.arrow_down
		dq handle_user_input.arrow_right
		dq handle_user_input.arrow_left

section .text

extern print_str

global handle_user_input
handle_user_input:; main loop of the program

	.main_loop:

	xor rax, rax
	mov qword [multipurpuse_buf], rax; zeroout the buffer

	mov rax, SYS_POLL
	mov rdi, STDIN
	mov rsi, 1; only one file descriptor is provided
	mov rdx, 0; no timeout. maybe use this for final sleep but run if user inputs something TODO
	syscall

	test rax, rax; SYS_POLL returns 0 when no change happens within timeout
	jz .no_input 
	
	mov rax, SYS_READ
	mov rdi, STDIN
	lea rsi, [multipurpuse_buf]
	mov rdx, 8; size of multipurpuse buffer
	syscall; read user input

	mov rax, [multipurpuse_buf]
	shr rax, 5; we need only 3 bytes for this inpus sceame

	cmp eax, 0x001B5B44; check if input is more than left arrow
	ja .handle_single_byte_chars

	sub eax, 0x1B5B41
	jmp [arrow_switch_statement+(rax*8)]; lets hope this works

	.arrow_up:
	dec word [cursor_rows]
	lea rdi, [cursor_up]
	call print_str
	jmp .no_input
	.arrow_down:
	inc word [cursor_rows]
	lea rdi, [cursor_down]
	call print_str
	jmp .no_input
	.arrow_right:
 	inc word [cursor_cols]
	lea rdi, [cursor_right]
	call print_str
	jmp .no_input
	.arrow_left:
	dec word [cursor_cols]
	lea rdi, [cursor_left]
	call print_str
	jmp .no_input

	.handle_single_byte_chars:

	shr eax, 2; get the char to al 

	cmp al, 0xa; NEWLINE (enter key)
	jne .check_p

	xor rax, rax; zeroout rax
	mov ax, [cursor_rows]
	mul dword [term_cols]
	add rax, [cursor_cols]
	
	lea rdi, [gameboard_ptr+rax]
	mov cl, [rdi]
	cmp cl, '#'
	je .hashtag_present

	mov byte [rdi], '#'
	jmp .no_input

	.hashtag_present:

	mov byte [rdi], ' '
	jmp .no_input

	.check_p:
	cmp al, 'p'
	jne .check_j

	xor byte [simulation_running], 0x01; switch simulation on or off

	jmp .no_input

	.check_j:
	cmp al, 'j'
	jne .check_k

	; TODO implement simulation speed

	jmp .no_input

	.check_k:
	cmp al, 'k'
	jne .no_input

	; TODO implement simulation speed

	.no_input:

		
	jmp .main_loop

	ret
	
	
