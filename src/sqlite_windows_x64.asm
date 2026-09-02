bits 64
default rel

global yul_sqlite_runtime_load
global yul_sqlite_runtime_unload
global yul_sqlite_open
global yul_sqlite_close
global yul_sqlite_exec
global yul_sqlite_prepare
global yul_sqlite_bind_text
global yul_sqlite_bind_int64
global yul_sqlite_bind_null
global yul_sqlite_step
global yul_sqlite_finalize
global yul_sqlite_column_int64
global yul_sqlite_column_text
global yul_sqlite_errmsg

extern FreeLibrary
extern GetProcAddress
extern LoadLibraryA

section .text

yul_sqlite_runtime_load:
    push r12
    cmp qword [rel sqlite_module], 0
    jne .success
    sub rsp, 0x20
    lea rcx, [rel sqlite_dll]
    call LoadLibraryA
    add rsp, 0x20
    test rax, rax
    jz .failure
    mov [rel sqlite_module], rax
    mov r12, rax
    lea rdx, [rel name_open]
    call .resolve
    test rax, rax
    jz .failure_loaded
    mov [rel fn_open], rax
    lea rdx, [rel name_close]
    call .resolve
    test rax, rax
    jz .failure_loaded
    mov [rel fn_close], rax
    lea rdx, [rel name_exec]
    call .resolve
    test rax, rax
    jz .failure_loaded
    mov [rel fn_exec], rax
    lea rdx, [rel name_prepare]
    call .resolve
    test rax, rax
    jz .failure_loaded
    mov [rel fn_prepare], rax
    lea rdx, [rel name_bind_text]
    call .resolve
    test rax, rax
    jz .failure_loaded
    mov [rel fn_bind_text], rax
    lea rdx, [rel name_bind_int64]
    call .resolve
    test rax, rax
    jz .failure_loaded
    mov [rel fn_bind_int64], rax
    lea rdx, [rel name_bind_null]
    call .resolve
    test rax, rax
    jz .failure_loaded
    mov [rel fn_bind_null], rax
    lea rdx, [rel name_step]
    call .resolve
    test rax, rax
    jz .failure_loaded
    mov [rel fn_step], rax
    lea rdx, [rel name_finalize]
    call .resolve
    test rax, rax
    jz .failure_loaded
    mov [rel fn_finalize], rax
    lea rdx, [rel name_column_int64]
    call .resolve
    test rax, rax
    jz .failure_loaded
    mov [rel fn_column_int64], rax
    lea rdx, [rel name_column_text]
    call .resolve
    test rax, rax
    jz .failure_loaded
    mov [rel fn_column_text], rax
    lea rdx, [rel name_errmsg]
    call .resolve
    test rax, rax
    jz .failure_loaded
    mov [rel fn_errmsg], rax
.success:
    xor eax, eax
    pop r12
    ret
.resolve:
    mov rcx, r12
    sub rsp, 0x20
    call GetProcAddress
    add rsp, 0x20
    ret
.failure_loaded:
    mov rcx, r12
    sub rsp, 0x20
    call FreeLibrary
    add rsp, 0x20
    mov qword [rel sqlite_module], 0
    mov qword [rel fn_open], 0
    mov qword [rel fn_close], 0
    mov qword [rel fn_exec], 0
    mov qword [rel fn_prepare], 0
    mov qword [rel fn_bind_text], 0
    mov qword [rel fn_bind_int64], 0
    mov qword [rel fn_bind_null], 0
    mov qword [rel fn_step], 0
    mov qword [rel fn_finalize], 0
    mov qword [rel fn_column_int64], 0
    mov qword [rel fn_column_text], 0
    mov qword [rel fn_errmsg], 0
.failure:
    mov eax, 1
    pop r12
    ret

yul_sqlite_runtime_unload:
    mov rcx, [rel sqlite_module]
    test rcx, rcx
    jz .done
    sub rsp, 0x28
    call FreeLibrary
    add rsp, 0x28
    mov qword [rel sqlite_module], 0
    mov qword [rel fn_open], 0
    mov qword [rel fn_close], 0
    mov qword [rel fn_exec], 0
    mov qword [rel fn_prepare], 0
    mov qword [rel fn_bind_text], 0
    mov qword [rel fn_bind_int64], 0
    mov qword [rel fn_bind_null], 0
    mov qword [rel fn_step], 0
    mov qword [rel fn_finalize], 0
    mov qword [rel fn_column_int64], 0
    mov qword [rel fn_column_text], 0
    mov qword [rel fn_errmsg], 0
.done:
    xor eax, eax
    ret

yul_sqlite_open:
    mov r10, [rel fn_open]
    test r10, r10
    jz sqlite_unavailable
    mov r8d, 6
    xor r9d, r9d
    sub rsp, 0x28
    call r10
    add rsp, 0x28
    ret
sqlite_unavailable:
    mov eax, 1
    ret

yul_sqlite_close:
    mov r10, [rel fn_close]
    test r10, r10
    jz sqlite_unavailable
    sub rsp, 0x28
    call r10
    add rsp, 0x28
    ret

yul_sqlite_exec:
    mov r10, [rel fn_exec]
    test r10, r10
    jz sqlite_unavailable
    xor r8d, r8d
    xor r9d, r9d
    sub rsp, 0x38
    mov qword [rsp + 0x20], 0
    call r10
    add rsp, 0x38
    ret

yul_sqlite_prepare:
    mov r10, [rel fn_prepare]
    test r10, r10
    jz sqlite_unavailable
    mov r9, r8
    mov r8, -1
    sub rsp, 0x38
    mov qword [rsp + 0x20], 0
    call r10
    add rsp, 0x38
    ret

yul_sqlite_bind_text:
    mov r10, [rel fn_bind_text]
    test r10, r10
    jz sqlite_unavailable
    sub rsp, 0x38
    mov qword [rsp + 0x20], -1
    call r10
    add rsp, 0x38
    ret

yul_sqlite_bind_int64:
    mov r10, [rel fn_bind_int64]
    test r10, r10
    jz sqlite_unavailable
    sub rsp, 0x28
    call r10
    add rsp, 0x28
    ret

yul_sqlite_bind_null:
    mov r10, [rel fn_bind_null]
    test r10, r10
    jz sqlite_unavailable
    sub rsp, 0x28
    call r10
    add rsp, 0x28
    ret

yul_sqlite_step:
    mov r10, [rel fn_step]
    test r10, r10
    jz sqlite_unavailable
    sub rsp, 0x28
    call r10
    add rsp, 0x28
    ret

yul_sqlite_finalize:
    mov r10, [rel fn_finalize]
    test r10, r10
    jz sqlite_unavailable
    sub rsp, 0x28
    call r10
    add rsp, 0x28
    ret

yul_sqlite_column_int64:
    mov r10, [rel fn_column_int64]
    test r10, r10
    jz sqlite_unavailable
    sub rsp, 0x28
    call r10
    add rsp, 0x28
    ret

yul_sqlite_column_text:
    mov r10, [rel fn_column_text]
    test r10, r10
    jz sqlite_unavailable
    sub rsp, 0x28
    call r10
    add rsp, 0x28
    ret

yul_sqlite_errmsg:
    mov r10, [rel fn_errmsg]
    test r10, r10
    jz sqlite_unavailable
    sub rsp, 0x28
    call r10
    add rsp, 0x28
    ret

    mov eax, 1
    ret

section .data
sqlite_dll db "sqlite3.dll", 0
name_open db "sqlite3_open_v2", 0
name_close db "sqlite3_close", 0
name_exec db "sqlite3_exec", 0
name_prepare db "sqlite3_prepare_v2", 0
name_bind_text db "sqlite3_bind_text", 0
name_bind_int64 db "sqlite3_bind_int64", 0
name_bind_null db "sqlite3_bind_null", 0
name_step db "sqlite3_step", 0
name_finalize db "sqlite3_finalize", 0
name_column_int64 db "sqlite3_column_int64", 0
name_column_text db "sqlite3_column_text", 0
name_errmsg db "sqlite3_errmsg", 0

section .bss
sqlite_module resq 1
fn_open resq 1
fn_close resq 1
fn_exec resq 1
fn_prepare resq 1
fn_bind_text resq 1
fn_bind_int64 resq 1
fn_bind_null resq 1
fn_step resq 1
fn_finalize resq 1
fn_column_int64 resq 1
fn_column_text resq 1
fn_errmsg resq 1
