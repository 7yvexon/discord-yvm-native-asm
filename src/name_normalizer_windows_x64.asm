bits 64
default rel

global yul_normalize_name_utf8

section .text

yul_normalize_name_utf8:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    mov rbx, [rsp + 0x60]
    mov r12, rcx
    mov r13, rdx
    mov r14, r8
    mov r15, r9
    test r12, r12
    jz .invalid
    test r13, r13
    jz .invalid
    test r14, r14
    jz .invalid
    test r15, r15
    jz .invalid
    xor r10d, r10d
    xor r11d, r11d
    xor r8d, r8d
    xor r9d, r9d
.next:
    cmp r10, r13
    jae .finish
    movzx eax, byte [r12 + r10]
    cmp eax, 0x80
    jb .ascii
    cmp eax, 0xc2
    jb .invalid
    cmp eax, 0xdf
    jbe .two
    cmp eax, 0xef
    jbe .three
    cmp eax, 0xf4
    jbe .four
    jmp .invalid
.ascii:
    mov edx, 1
    jmp .codepoint
.two:
    mov rcx, r13
    sub rcx, r10
    cmp rcx, 2
    jb .invalid
    movzx ecx, byte [r12 + r10 + 1]
    cmp ecx, 0x80
    jb .invalid
    cmp ecx, 0xbf
    ja .invalid
    and eax, 0x1f
    shl eax, 6
    and ecx, 0x3f
    or eax, ecx
    mov edx, 2
    jmp .codepoint
.three:
    mov rcx, r13
    sub rcx, r10
    cmp rcx, 3
    jb .invalid
    movzx ecx, byte [r12 + r10 + 1]
    movzx esi, byte [r12 + r10 + 2]
    cmp ecx, 0x80
    jb .invalid
    cmp ecx, 0xbf
    ja .invalid
    cmp esi, 0x80
    jb .invalid
    cmp esi, 0xbf
    ja .invalid
    cmp al, 0xe0
    jne .three_not_e0
    cmp ecx, 0xa0
    jb .invalid
.three_not_e0:
    cmp al, 0xed
    jne .three_build
    cmp ecx, 0x9f
    ja .invalid
.three_build:
    mov edi, eax
    and edi, 0x0f
    shl edi, 12
    and ecx, 0x3f
    shl ecx, 6
    or edi, ecx
    and esi, 0x3f
    or edi, esi
    mov eax, edi
    mov edx, 3
    jmp .codepoint
.four:
    mov rcx, r13
    sub rcx, r10
    cmp rcx, 4
    jb .invalid
    movzx ecx, byte [r12 + r10 + 1]
    movzx esi, byte [r12 + r10 + 2]
    movzx edi, byte [r12 + r10 + 3]
    cmp ecx, 0x80
    jb .invalid
    cmp ecx, 0xbf
    ja .invalid
    cmp esi, 0x80
    jb .invalid
    cmp esi, 0xbf
    ja .invalid
    cmp edi, 0x80
    jb .invalid
    cmp edi, 0xbf
    ja .invalid
    cmp al, 0xf0
    jne .four_not_f0
    cmp ecx, 0x90
    jb .invalid
.four_not_f0:
    cmp al, 0xf4
    jne .four_build
    cmp ecx, 0x8f
    ja .invalid
.four_build:
    mov edx, eax
    and edx, 0x07
    shl edx, 18
    and ecx, 0x3f
    shl ecx, 12
    or edx, ecx
    and esi, 0x3f
    shl esi, 6
    or edx, esi
    and edi, 0x3f
    or edx, edi
    mov eax, edx
    mov edx, 4
.codepoint:
    cmp eax, 0x1f
    jbe .invalid
    cmp eax, 0x7f
    je .invalid
    cmp eax, 0x80
    jb .not_control
    cmp eax, 0x9f
    jbe .invalid
.not_control:
    cmp eax, 0x20
    je .whitespace
    cmp eax, 0xa0
    je .whitespace
    cmp eax, 0x1680
    je .whitespace
    cmp eax, 0x2000
    jb .not_whitespace
    cmp eax, 0x200a
    jbe .whitespace
    cmp eax, 0x2028
    je .whitespace
    cmp eax, 0x2029
    je .whitespace
    cmp eax, 0x202f
    je .whitespace
    cmp eax, 0x205f
    je .whitespace
    cmp eax, 0x3000
    je .whitespace
.not_whitespace:
    test r9d, r9d
    jz .copy
    cmp r11, r15
    jae .too_long
    mov byte [r14 + r11], 0x20
    inc r11
    xor r9d, r9d
.copy:
    mov rcx, r11
    add rcx, rdx
    jc .too_long
    cmp rcx, r15
    ja .too_long
    mov rcx, rdx
    lea rsi, [r12 + r10]
    lea rdi, [r14 + r11]
    rep movsb
    add r10, rdx
    add r11, rdx
    mov r8d, 1
    jmp .next
.whitespace:
    test r8d, r8d
    jz .skip_whitespace
    mov r9d, 1
.skip_whitespace:
    add r10, rdx
    jmp .next
.finish:
    test r8d, r8d
    jz .invalid
    mov [rbx], r11
    xor eax, eax
    jmp .return
.too_long:
    mov eax, 2
    jmp .return_error
.invalid:
    mov eax, 1
.return_error:
    test rbx, rbx
    jz .return
    mov qword [rbx], 0
.return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret
