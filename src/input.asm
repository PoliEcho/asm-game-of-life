%include "symbols.asm"

section .bss
	alignb 16
	termios: RESZ 1; 60 bytes is needed i use 64 for alligment and it is easier to work with

	extern multipurpuse_buf

	extern term_rows
	extern term_cols

	extern gameboard_ptr

	extern simulation_running
section .data 
	cursor_rows: dw 1
	cursor_cols: dw 1
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
extern step_simulation
extern unsigned_int_to_ascii
extern print_game_ui

global handle_user_input
handle_user_input:; main loop of the program
	push r12

	lea r12, [multipurpuse_buf]

	.main_loop:

	; put the cursor where it should be 
	mov rdi, r12; multipurpuse_buf pointer is in r12
	mov word [rdi], 0x5B1B; will store ESC_CHAR, '[' they have to be in reverse order here due to little endian
	add rdi, 2
	push rdi
	xor rsi, rsi
	mov si, [cursor_rows]
	call unsigned_int_to_ascii
	pop rdi
	add rdi, rax; add lenght of string to pointer 
	mov byte [rdi], ';'
	inc rdi
	push rdi
	mov si, [cursor_cols]
	call unsigned_int_to_ascii
	pop rdi
	add rdi, rax
	mov byte [rdi], 'H'
	inc rdi
	mov byte [rdi], 0; null terminate

	mov rdi, r12; multipurpuse_buf pointer is in r12
	call print_str

	

	xor rax, rax
	mov qword [r12], rax; zeroout the buffer

	mov rax, SYS_POLL
	mov dword [r12], STDIN; create pollfd struct
	mov word [r12+4], POLLIN
	mov rdi, r12
	mov rsi, 1; only one file descriptor is provided
	mov rdx, 500; no timeout. maybe use this for final sleep but run if user inputs something TODO
	syscall

	test rax, rax; SYS_POLL returns 0 when no change happens within timeout
	jz .no_input

	xor rax, rax
	mov qword [r12], rax; zeroout the buffer
	
	mov rax, SYS_READ
	mov rdi, STDIN
	lea rsi, [r12]
	mov rdx, 8; size of multipurpuse buffer
	syscall; read user input

	cmp rax, EAGAIN
	je .no_input

	mov rax, [r12]
	
	cmp eax, 0x00415B1B; check if input is more than left arrow
	jl .handle_single_byte_chars

	bswap eax

	sub eax, 0x1B5B4100
	shr eax, 8
	cmp al, 3
	ja .no_input

	mov r9w, [term_rows]
	dec r9w
	mov r10w, [term_cols]

	jmp [arrow_switch_statement+(rax*8)]; lets hope this works

	.arrow_up:
	dec word [cursor_rows]
	jnz .move_cursor_up
	inc word [cursor_rows]
	jmp .no_input
	.move_cursor_up:
	lea rdi, [cursor_up]
	call print_str
	jmp .no_input

	.arrow_down:
	mov r8w, [cursor_rows]
	inc r8w
	cmp word r8w, r9w
	ja .no_input
	mov word [cursor_rows], r8w
	lea rdi, [cursor_down]
	call print_str
	jmp .no_input

	.arrow_right:
 	mov r8w, [cursor_cols]
	inc r8w
	cmp word r8w, r10w
	ja .no_input
	mov word [cursor_cols], r8w
	lea rdi, [cursor_right]
	call print_str
	jmp .no_input

	.arrow_left:
	dec word [cursor_cols]
	jnz .move_cursor_left 
	inc word [cursor_cols]
	jmp .no_input
	.move_cursor_left:
	lea rdi, [cursor_left]
	call print_str
	jmp .no_input

	.handle_single_byte_chars:


	cmp al, 0xa; NEWLINE (enter key)
	jne .check_p

	xor rax, rax; zeroout rax
	mov ax, [cursor_rows]
	dec ax
	mul word [term_cols]
	mov cx, [cursor_cols]
	dec cx
	add ax, cx
	
	mov rdi, [gameboard_ptr]
	add rdi, rax
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
	jne .check_q

	; TODO implement simulation speed

	.check_q:
	cmp al, 'q'
	jne .no_input
	pop r12
	ret; exit if q pressed

	.no_input:

	mov al, [simulation_running]
	test al, al
	jz .dont_step
	call step_simulation
	.dont_step:
	call print_game_ui
	jmp .main_loop

	pop r12
	ret

	
global disable_canonical_mode_and_echo
disable_canonical_mode_and_echo:
	
	mov rax, SYS_IOCTL
	mov rdi, STDIN
	mov rsi, TCGETS
	lea rdx, [termios]
	syscall 

	; save original termios struct
	%ifdef AVX2
		%ifdef AVX512
			vmovdqa64 zmm0, [termios]
		%else
			vmovdqa ymm0, [termios]
			vmovdqa ymm1, [termios+32]						
		%endif 
	%else
		vmovdqa xmm0, [termios]
		vmovdqa xmm1, [termios+16]
		vmovdqa xmm2, [termios+32]
		vmovdqa xmm3, [termios+64]
	%endif

	
	mov eax, [termios+12]; get c_lflag
	and eax, NOT_ECHO; disable ECHO
	and eax, NOT_ICANON; disable ICANON
	mov [termios+12], eax

	mov rax, SYS_IOCTL
	mov rdi, STDIN
	mov rsi, TCSETS
	lea rdx, [termios]
	syscall 


	; load original termios struct
	%ifdef AVX2
		%ifdef AVX512
			vmovdqa64 [termios], zmm0
		%else
			vmovdqa [termios], ymm0
			vmovdqa [termios+32], ymm1						
		%endif 
	%else
		vmovdqa [termios], xmm0
		vmovdqa [termios+16], xmm1
		vmovdqa [termios+32], xmm2
		vmovdqa [termios+64], xmm3
	%endif


	ret

global reset_terminal
reset_terminal:
	mov rax, SYS_IOCTL
	mov rdi, STDIN
	mov rsi, TCSETS
	lea rdx, [termios]
	syscall 
	ret
	
	
