bits 64
default rel

global yul_add_support_total

section .text

yul_add_support_total:
    test r8, r8
    jz .invalid
    test rdx, rdx
    jz .invalid
    mov r9, 0x7fffffffffffffff
    cmp rcx, r9
    ja .overflow
    mov r10, r9
    sub r10, rcx
    cmp rdx, r10
    ja .overflow
    lea rax, [rcx + rdx]
    mov [r8], rax
    xor eax, eax
    ret
.invalid:
    mov eax, 1
    ret
.overflow:
    mov eax, 2
    ret
