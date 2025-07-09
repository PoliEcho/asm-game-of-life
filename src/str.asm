%include "symbols.asm"

section .text

global print_str
print_str: ; takes pointer to string in rdi and retuns in rax
    push rsi
    push rdx
    mov rsi, rdi
    xor rdx, rdx

.count_loop:
    cmp byte [rsi+rdx], 0
    je .print
    inc rdx
    jmp .count_loop

.print:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    syscall
    pop rdx
    pop rsi
    ret

global unsigned_int_to_ascii
unsigned_int_to_ascii: ; takes pointer to array in rdi and value stored in rsi DOES NOT BOUNDS CHECK
    xor r11, r11
    mov rcx, 10
    mov rax, rsi

.count_loop:
    inc r11
    cmp rax, 10
    jl .loop_count_exit
    xor rdx, rdx
    div rcx
    push rdx
    jmp .count_loop

.loop_count_exit:
    push rax

    xor rcx, rcx

.store_loop: ; basicly for loop
    cmp rcx, r11
    jnl .loop_store_exit

    pop rax
    add rax, ASCII_ZERO
    mov byte [rdi + rcx], al
    inc rcx

    jmp .store_loop

.loop_store_exit:

    mov rax, r11

    ret

global string_copy
string_copy:; takes pointer to destination in rdi and pointer to source in rsi
	
	xor rax, rax
	xor rcx, rcx
	.copy_next_byte:
	mov byte cl, [rsi+rax]
	test cl, cl
	jz .exit
	mov [rdi+rax], cl
	inc rax
	jmp .copy_next_byte

	.exit:
	ret

global memory_set:
memory_set:; takes  destination in rdi, byte in sil and lenght in rdx
	; first check if value is 16 byte alligned

	xor r8, r8

	mov r9, rdi; move destination to r9

	mov r11, 0x0101010101010101; to extend across whoule register
	movzx rsi, sil
	imul r11, rsi; to extend across whoule register

	cmp rdx, 16
	jnl .write_16_or_more_bytes 
	mov r8b, dl
	jmp .write_less_than_16_bytes
	.write_16_or_more_bytes:
	mov rax, rdi; move destination to rax
	and rax, 0xF; offset is stored in rax

	
	test al, al; check if resault is 0
	jz .addr_is_16_Byte_alligned
	

	mov r8b, 16
	sub r8b, al; now offset to first higher 16 byte alligned address is stored in r8

	mov rax, r11

	.write_less_than_16_bytes:
	sub rdx, r8; we will write these bytes now
	
		;add rdi, rdx
	; we know that rdi has initial address and rdx offset so well fill just add to it
	mov rcx, 1; we will allwais copy only once
	

	cmp r8b, 8
	jl .check_dword
	rep stosq
	sub r8b, 8

	.check_dword:
	cmp r8b, 4
	jl .check_word
	rep stosd
	sub r8b, 4

	.check_word:
	cmp r8b, 2
	jl .check_byte
	rep stosw
	sub r8b, 2

	.check_byte:
	test r8b, r8b; check if offset is 1 or 0
	jz .addr_is_16_Byte_alligned
	rep stosb
	dec r8b	

	.addr_is_16_Byte_alligned:
	mov rcx, rdx
	shr rcx, 4; set it to how many 128bit(16Byte) chunk we need 
	test rcx, rcx; check if we need to write aditional 16 bytes at all
	jz .function_exit
		
	%ifdef AVX512
		vpbroadcastq xmm8, r11
	%else
		movq xmm8, r11
		shufpd xmm8, xmm8, 0x00
	%endif

	.move_16_bytes:
	movdqa [rdi], xmm8
	add rdi, 16
	sub rdx, 16

	cmp rdx, 16; test if rdx is less than 16
	jge .move_16_bytes

	.function_exit:

	test rdx, rdx; test if rdx is 0
	jz .true_function_exit
	mov r8b, dl
	jmp .write_less_than_16_bytes

	.true_function_exit:
	mov rax, r9; return pointer to memory area same as memset in libc
	ret	
