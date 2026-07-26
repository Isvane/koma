section .data
    msg db "Hello, World!", 10
    msg_len equ $ - msg
    yes db "Yes, it is 100!", 10
    yes_len equ $ - yes
    no db "No, it isn't 100!", 10
    no_len equ $ - no

section .bss
    input: resb 64

section .text
    global _start

_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 64
    syscall

    mov rdx, rax
    mov rsi, input
    mov rax, 1
    mov rdi, 1
    syscall

    mov rax, 100
    cmp rax, 100
    je is_equal

not_equal:
    mov rax, 1
    mov rdi, 1
    mov rsi, no
    mov rdx, no_len
    syscall

    jmp exit_program

is_equal:
    mov rax, 1
    mov rdi, 1
    mov rsi, yes
    mov rdx, yes_len
    syscall

exit_program:
    mov rdi, 42
    mov rax, 60
    syscall
