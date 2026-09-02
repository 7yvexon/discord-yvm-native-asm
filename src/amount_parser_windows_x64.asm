bits 64
default rel

global yul_parse_amount_ascii

section .text

yul_parse_amount_ascii:
    test rcx, rcx
    jz .invalid
    test rdx, rdx
    jz .invalid
    test r8, r8
    jz .invalid
    xor rax, rax
    xor r9d, r9d
    mov r11, 922337203685477580
.loop:
    movzx r10d, byte [rcx + r9]
    cmp r10d, 48
    jb .invalid
    cmp r10d, 57
    ja .invalid
    cmp rax, r11
    ja .overflow
    jne .multiply
    cmp r10d, 55
    ja .overflow
.multiply:
    imul rax, rax, 10
    sub r10d, 48
    add rax, r10
    inc r9
    cmp r9, rdx
    jb .loop
    test rax, rax
    jz .invalid
    mov [r8], rax
    xor eax, eax
    ret
.invalid:
    mov eax, 1
    ret
.overflow:
    mov eax, 2
    ret
