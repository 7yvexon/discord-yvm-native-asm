bits 64
default rel

global yul_vending_machine_native_entry
extern ExitProcess
extern GetCommandLineW
extern WideCharToMultiByte
extern yul_native_runtime_main

section .text

yul_vending_machine_native_entry:
    sub rsp, 0x68
    call GetCommandLineW
    mov r8, rax
    mov ecx, 65001
    xor edx, edx
    mov r9d, -1
    lea rax, [rel command_line_utf8]
    mov [rsp + 0x20], rax
    mov dword [rsp + 0x28], 65536
    mov qword [rsp + 0x30], 0
    mov qword [rsp + 0x38], 0
    call WideCharToMultiByte
    lea rcx, [rel command_line_utf8]
    call yul_native_runtime_main
    mov ecx, eax
    call ExitProcess
    int3

section .bss
command_line_utf8 resb 65536
