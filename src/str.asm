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

	mov r9, rdi; move destination to r9

	mov r11, 0x0101010101010101; to extend across whoule register
	movzx rsi, sil
	imul r11, rsi; to extend across whoule register

	cmp rdx, 16
	jnl .write_16_or_more_bytes 
	mov rcx, rdx 
	jmp .write_less_than_16_bytes
	.write_16_or_more_bytes:
	mov rax, rdi; move destination to rax
	and rax, 0xF; offset is stored in rax

	
	test al, al; check if resault is 0
	jz .addr_is_16_Byte_alligned
	

	mov cl, 16
	sub cl, al; now offset to first higher 16 byte alligned address is stored in r8
	movzx rcx, cl; remove ani posible garbage
	

	.write_less_than_16_bytes:
	mov rax, r11
	sub rdx, rcx; we will write these bytes now
	
	rep stosb

	.addr_is_16_Byte_alligned:
	mov r10, rdx
	shr r10, 4; set it to how many 128bit(16Byte) chunk we need 
	test r10, r10; check if we need to write aditional 16 bytes at all
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
	mov cl, dl
	jmp .write_less_than_16_bytes

	.true_function_exit:
	mov rax, r9; return pointer to memory area same as memset in libc
	ret	







global memory_copy:
memory_copy:; takes  destination in rdi, source in rsi and lenght in rdx
	; first check if value is 16 byte alligned

	mov r9, rdi

	cmp rdx, 16
	jnl .write_16_or_more_bytes 
	mov rcx, rdx 
	jmp .write_less_than_16_bytes
	.write_16_or_more_bytes:
	mov rax, rdi; move destination to rax
	and rax, 0xF; offset is stored in rax

	
	test al, al; check if resault is 0
	jz .addr_is_16_Byte_alligned
	

	mov cl, 16
	sub cl, al; now offset to first higher 16 byte alligned address is stored in r8
	movzx rcx, cl; remove ani posible garbage
	

	.write_less_than_16_bytes:
	sub rdx, rcx; we will write these bytes now
	
	rep movsb

	.addr_is_16_Byte_alligned:
	mov r10, rdx
	shr r10, 4; set it to how many 128bit(16Byte) chunk we need 
	test r10, r10; check if we need to write aditional 16 bytes at all
	jz .function_exit
		
	.move_16_bytes:
	movdqa xmm8, [rsi]
	movdqa [rdi], xmm8
	add rdi, 16
	add rsi, 16
	sub rdx, 16

	cmp rdx, 16; test if rdx is less than 16
	jge .move_16_bytes

	.function_exit:

	test rdx, rdx; test if rdx is 0
	jz .true_function_exit
	movzx rcx, dl
	jmp .write_less_than_16_bytes

	.true_function_exit:
	mov rax, r9; return pointer to memory area same as memset in libc
	ret	
