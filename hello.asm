section .data
    msg db "Hello, World!", 10
    msg_len equ $ - msg

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

    mov rdi, 42
    mov rax, 60
    syscall
