SYS_WRITE equ 1
STDOUT equ 1
ASCII_ZERO 	equ 48

section .text

global print_str
print_str: ; takes pointer to string in rdi and retuns in rax
    push rsi
    push rdx
    mov rsi, rdi
    mov rdx, 0

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
    mov r11, 0
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

    mov rcx, 0

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

