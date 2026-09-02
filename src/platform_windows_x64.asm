bits 64
default rel

global yul_platform_windows_probe
global yul_resolve_kernel_export
global yul_platform_now_unix
global yul_platform_process_id

extern GetSystemTimeAsFileTime
extern GetCurrentProcessId

section .text

yul_platform_windows_probe:
    xor eax, eax
    ret

yul_platform_now_unix:
    sub rsp, 0x28
    lea rcx, [rel platform_filetime]
    call GetSystemTimeAsFileTime
    mov rax, [rel platform_filetime]
    mov rdx, 116444736000000000
    sub rax, rdx
    xor edx, edx
    mov r8, 10000000
    div r8
    add rsp, 0x28
    ret

yul_platform_process_id:
    sub rsp, 0x28
    call GetCurrentProcessId
    add rsp, 0x28
    ret

yul_resolve_kernel_export:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    mov rbx, rcx
    mov rsi, rdx
    mov eax, [rbx + 0x3c]
    add rax, rbx
    mov eax, [rax + 0x88]
    test eax, eax
    jz .not_found
    lea rdi, [rbx + rax]
    mov r12d, [rdi + 0x18]
    mov eax, [rdi + 0x20]
    lea r13, [rbx + rax]
    mov eax, [rdi + 0x24]
    lea r14, [rbx + rax]
    mov eax, [rdi + 0x1c]
    lea r15, [rbx + rax]
    xor r10d, r10d
.name_loop:
    cmp r10d, r12d
    jae .not_found
    mov eax, [r13 + r10 * 4]
    lea r8, [rbx + rax]
    mov r9, rsi
.compare_loop:
    mov al, [r8]
    cmp al, [r9]
    jne .next_name
    test al, al
    jz .name_found
    inc r8
    inc r9
    jmp .compare_loop
.next_name:
    inc r10d
    jmp .name_loop
.name_found:
    movzx eax, word [r14 + r10 * 2]
    mov eax, [r15 + rax * 4]
    add rax, rbx
    jmp .done
.not_found:
    xor eax, eax
.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

section .bss
platform_filetime resq 1
