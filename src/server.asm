section .data
    http_response db "HTTP/1.1 200 OK", 13, 10
                  db "Content-Type: text/html", 13, 10
                  db "Content-Length: 25", 13, 10
                  db 13, 10
                  db "<h1>Isvane was here!</h1>"
    response_len equ $-http_response
    http_post db "HTTP/1.1 200 OK", 13, 10
              db "Content-Type: text/plain", 13, 10
              db "Host: localhost: 8080", 13, 10
              db "Content-Length: 14", 13, 10
              db 13, 10
              db "Goodbye World!"
    post_len equ $-http_post
    serv_addr:
        dw 2
        db 0x26, 0xA0
        dd 0
        times 8 db 0

section .bss
    buffer resb 8192

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
    mov rdx, 8192
    syscall

    test rax, rax
    jle close_conn

    cmp byte [buffer], 'P'
    je serve_post

serve_get:
    mov rsi, http_response
    mov rdx, response_len
    jmp do_write

serve_post:
    mov rsi, http_post
    mov rdx, post_len

do_write:
    mov rax, 1
    mov rdi, r13
    syscall

close_conn:
    mov rax, 3
    mov rdi, r13
    syscall

    jmp accept_loop
