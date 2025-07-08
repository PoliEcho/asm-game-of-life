%include "symbols.asm"

section .bss
	brk_pointer: RESQ 1
section .text 

global init_alloc
init_alloc:; initialize allocator, optionaly return brk pointer in rax
	mov rax, SYS_BRK
	xor rdi, rdi
	syscall
	mov [brk_pointer], rax
	ret

global alloc
alloc:; Takes lenght of data in rdi and returns pointer in rax
	mov rax, SYS_BRK
	mov qword rcx, [brk_pointer]
	add rdi, rcx; calculate new BRK address
	push rcx
	syscall
	mov [brk_pointer], rax
	pop rax
	ret

