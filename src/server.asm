section .data
    http_response db "HTTP/1.1 200 OK", 13, 10
                  db "Content-Type: text/html", 13, 10
                  db "Content-Length: 28", 13, 10
                  db 13, 10
                  db "<h1>Isvane was here!</h1>"
    response_len equ $-http_response
    serv_addr:
        dw 2
        db 0x26, 0xA0
        dd 0
        times 8 db 0

section .bss
    buffer resb 1024

section .text
    global _start

_start:
    ; Socket
    mov rax, 41
    mov rdi, 2
    mov rsi, 1
    mov rdx, 0
    syscall

    ; Bind
    mov r12, rax
    mov rax, 49
    mov rdi, r12
    mov rsi, serv_addr
    mov rdx, 16
    syscall

    ; Listen
    mov rax, 50
    mov rdi, r12
    mov rsi, 10
    syscall

accept_loop:
    ; Accept
    mov rax, 43
    mov rdi, r12
    mov rsi, 0
    mov rdx, 0
    syscall

    ; Read
    mov r13, rax
    mov rax, 0
    mov rdi, r13
    mov rsi, buffer
    mov rdx, 1024
    syscall

    ; Write
    mov rax, 1
    mov rdi, r13
    mov rsi, http_response
    mov rdx, response_len
    syscall

    ; Close
    mov rax, 3
    mov rdi, r13
    syscall

    jmp accept_loop
