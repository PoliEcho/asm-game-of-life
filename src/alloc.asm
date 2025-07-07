%include "symbols.asm"

section .bss
	brk_pointer: RESQ 1
section .text 

global init_alloc
init_alloc:; initialize allocator, optionaly return brk pointer in rax
	mov rax, SYS_BRK
	mov rdi, 0
	syscall
	mov [brk_pointer], rax
	ret

global alloc
alloc:; Takes lenght of data in rdi and returns pointer in rax
	mov rax, SYS_BRK
	mov rcx, [brk_pointer]
	push rcx
	syscall; size already in rdi
	mov [brk_pointer], rax
	pop rax
	ret
