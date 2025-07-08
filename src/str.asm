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

	mov r9, rdi

	mov rax, rdi
	and rax, 0xF; offset is stored in rax
	test al, al; check if resault is 0
	jz .addr_is_16_Byte_alligned
	mov r8b, 16
	sub r8b, al; now offset to first higher 16 byte alligned address is stored in r8
	sub rdx, r8; we will write these bytes now
	
	movzx rax, sil
	imul rax, 0x01010101; to extend across whoule register
	shl rax, 32; to extend across whoule register

	;add rdi, rdx
	; we know that rdi has initial address and rdx offset so well fill just add to it
	mov rcx, 1; we will allwais copy only once
	

	.check_qword:; check if offset is more than qword
	cmp r8b, 8
	jl .check_dword
	rep stosq

	.check_dword:
	cmp r8b, 4
	jl .check_word
	rep stosd

	.check_word:
	cmp r8b, 2
	jl .check_byte
	rep stosw

	.check_byte:
	test r8b, r8b; check if offset is 1 or 0
	jz .addr_is_16_Byte_alligned
	rep stosb
	
	
	.addr_is_16_Byte_alligned:
	shr rdx, 4; set it to how many 128bit(16Byte) chunk we need 
	
	%ifdef AVX2
		vpbroadcastq xmm8, rax
	%else
		movq xmm8, rax
		shufpd xmm8, xmm8, 0x00
	%endif

	.move_16_bytes:
	movdqa [rdi], xmm8
	add rdi, 16
	dec rdx

	test rdx,rdx; test if rdx is zero 
	jnz .move_16_bytes
	
	mov rax, r9; return pointer to memory area same as memset in libc
	ret	
