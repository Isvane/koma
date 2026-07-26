section .data
    msg db "Hello, World!", 10
    msg_len equ $ - msg
    yes db "Yes, it is 100!", 10
    yes_len equ $ - yes
    no db "No, it isn't 100!", 10
    no_len equ $ - no
    lol db "The answer to the ultimate question of life!", 10
    lol_len equ $ - lol

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

    mov rsi, input
    xor rax, rax

convert:
    movzx rbx, byte [rsi]
    cmp rbx, 10
    je done_convert
    cmp rbx, '0'
    jl done_convert
    cmp rbx, '9'
    jg done_convert

    sub rbx, '0'
    imul rax, rax, 10
    add rax, rbx

    inc rsi
    jmp convert

done_convert:
    cmp rax, 100
    je is_equal
    cmp rax, 42
    je special

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

    jmp exit_program

special:
    mov rax, 1
    mov rdi, 1
    mov rsi, lol
    mov rdx, lol_len
    syscall

exit_program:
    mov rdi, 42
    mov rax, 60
    syscall
