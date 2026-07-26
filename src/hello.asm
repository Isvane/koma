section .data
    msg db "Hello, World!", 10
    msg_len equ $ - msg
    yes db "Yes, it is 100!", 10
    yes_len equ $ - yes
    lol db "The answer to the ultimate question of life!", 10
    lol_len equ $ - lol

section .bss
    input resb 64
    out_buf resb 32
    parsed_val resq 1

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

    mov r12, rax

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
    jl exit_program
    cmp rbx, '9'
    jg exit_program

    sub rbx, '0'
    imul rax, rax, 10
    add rax, rbx

    inc rsi
    jmp convert

done_convert:
    mov [parsed_val], rax
    cmp rax, 100
    je is_equal
    cmp rax, 42
    je special

not_equal:
    mov rbx, 10
    xor rcx, rcx

push_loop:
    xor rdx, rdx
    div rbx
    add rdx, '0'
    push rdx
    inc rcx
    test rax, rax
    jnz push_loop

    mov rdi, out_buf
    mov r8, rcx

pop_loop:
    pop rax
    stosb
    loop pop_loop

    mov byte [rdi], 10
    inc r8

    mov rax, 1
    mov rdi, 1
    mov rsi, out_buf
    mov rdx, r8
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
