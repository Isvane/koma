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
    xor rax, rax        ; RAX = 0 (Accumulator for parsed integer)

; ==============================================================================
; LABEL: convert (ASCII String -> Integer / atoi)
; TRICKY CONCEPTS:
;   1. ASCII conversion: '5' (ASCII 53) - '0' (ASCII 48) = integer 5.
;   2. Left-shifting base-10: (RAX * 10) shifts existing digits left so the new
;      digit can be added into the ones place (e.g. 12 * 10 = 120 -> + 3 = 123).
; RAX TRACKING: Holds the running total integer.
; ==============================================================================
convert:
    movzx rbx, byte [rsi]
    cmp rbx, 10
    je done_convert
    cmp rbx, '0'
    jl exit_program
    cmp rbx, '9'
    jg exit_program

    sub rbx, '0'        ; Convert ASCII byte ('0'-'9') to integer (0-9)
    imul rax, rax, 10   ; Shift accumulated digits left by 1 decimal place
    add rax, rbx        ; Add current digit to ones place

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

; ==============================================================================
; LABEL: push_loop (Integer -> ASCII / itoa part 1)
; TRICKY CONCEPTS:
;   1. 64-bit DIV divides [RDX:RAX] by RBX. You MUST zero out RDX (`xor rdx, rdx`)
;      before `div`, or leftover bits cause a Floating Point Exception crash.
;   2. Division extracts digits in REVERSE order (ones, tens, hundreds).
;      We push digits to the stack (LIFO) so popping them later flips them
;      back into left-to-right reading order.
; RAX TRACKING:
;   - Before div: RAX = remaining dividend.
;   - After div:  RAX = quotient, RDX = remainder (the single digit extracted).
; ==============================================================================
push_loop:
    xor rdx, rdx        ; CRITICAL: Clear high bits before 64-bit DIV [RDX:RAX / RBX]
    div rbx             ; RAX = quotient (RAX/10), RDX = remainder (RAX%10)
    add rdx, '0'        ; Convert integer remainder back to ASCII char
    push rdx            ; Push to stack to reverse digit order
    inc rcx             ; Digit count (controls pop_loop iterations)
    test rax, rax       ; Is quotient 0?
    jnz push_loop

    mov rdi, out_buf
    mov r8, rcx

; ==============================================================================
; LABEL: pop_loop (Integer -> ASCII / itoa part 2)
; TRICKY CONCEPTS:
;   1. STOSB implicitly writes the byte in AL to memory address [RDI], then
;      automatically increments RDI to point to the next buffer byte.
;   2. LOOP implicitly uses RCX as counter, decrementing RCX until 0.
; RAX TRACKING: `pop rax` loads each digit into RAX/AL for `stosb`.
; ==============================================================================
pop_loop:
    pop rax             ; Pop left-most ASCII digit into RAX
    stosb               ; Write AL to [RDI] and auto-increment RDI
    loop pop_loop       ; Decrement RCX and loop if RCX > 0

    mov byte [rdi], 10  ; Append newline ('\n')
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
