.text
.global yul_sqlite_runtime_load
.global yul_sqlite_runtime_unload
.global yul_sqlite_open
.global yul_sqlite_close
.global yul_sqlite_exec
.global yul_sqlite_prepare
.global yul_sqlite_bind_text
.global yul_sqlite_bind_int64
.global yul_sqlite_bind_null
.global yul_sqlite_step
.global yul_sqlite_finalize
.global yul_sqlite_column_int64
.global yul_sqlite_column_text
.global yul_sqlite_errmsg
.extern dlopen
.extern dlsym
.extern dlclose

.section .rodata
sqlite_dll: .asciz "libsqlite3.so.0"
name_open: .asciz "sqlite3_open_v2"
name_close: .asciz "sqlite3_close"
name_exec: .asciz "sqlite3_exec"
name_prepare: .asciz "sqlite3_prepare_v2"
name_bind_text: .asciz "sqlite3_bind_text"
name_bind_int64: .asciz "sqlite3_bind_int64"
name_bind_null: .asciz "sqlite3_bind_null"
name_step: .asciz "sqlite3_step"
name_finalize: .asciz "sqlite3_finalize"
name_column_int64: .asciz "sqlite3_column_int64"
name_column_text: .asciz "sqlite3_column_text"
name_errmsg: .asciz "sqlite3_errmsg"

.text
.type yul_sqlite_runtime_load, %function
yul_sqlite_runtime_load:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x16, sqlite_module
    add x16, x16, :lo12:sqlite_module
    ldr x17, [x16]
    cbnz x17, .success
    adrp x0, sqlite_dll
    add x0, x0, :lo12:sqlite_dll
    mov x1, #2
    bl dlopen
    cbz x0, .failure
    adrp x16, sqlite_module
    add x16, x16, :lo12:sqlite_module
    str x0, [x16]
    adrp x1, name_open
    add x1, x1, :lo12:name_open
    adrp x0, sqlite_module
    add x0, x0, :lo12:sqlite_module
    ldr x0, [x0]
    bl dlsym
    cbz x0, .failure_loaded
    adrp x16, fn_open
    add x16, x16, :lo12:fn_open
    str x0, [x16]
    adrp x0, sqlite_module
    add x0, x0, :lo12:sqlite_module
    ldr x0, [x0]
    adrp x1, name_close
    add x1, x1, :lo12:name_close
    bl dlsym
    cbz x0, .failure_loaded
    adrp x16, fn_close
    add x16, x16, :lo12:fn_close
    str x0, [x16]
    adrp x0, sqlite_module
    add x0, x0, :lo12:sqlite_module
    ldr x0, [x0]
    adrp x1, name_exec
    add x1, x1, :lo12:name_exec
    bl dlsym
    cbz x0, .failure_loaded
    adrp x16, fn_exec
    add x16, x16, :lo12:fn_exec
    str x0, [x16]
    adrp x0, sqlite_module
    add x0, x0, :lo12:sqlite_module
    ldr x0, [x0]
    adrp x1, name_prepare
    add x1, x1, :lo12:name_prepare
    bl dlsym
    cbz x0, .failure_loaded
    adrp x16, fn_prepare
    add x16, x16, :lo12:fn_prepare
    str x0, [x16]
    adrp x0, sqlite_module
    add x0, x0, :lo12:sqlite_module
    ldr x0, [x0]
    adrp x1, name_bind_text
    add x1, x1, :lo12:name_bind_text
    bl dlsym
    cbz x0, .failure_loaded
    adrp x16, fn_bind_text
    add x16, x16, :lo12:fn_bind_text
    str x0, [x16]
    adrp x0, sqlite_module
    add x0, x0, :lo12:sqlite_module
    ldr x0, [x0]
    adrp x1, name_bind_int64
    add x1, x1, :lo12:name_bind_int64
    bl dlsym
    cbz x0, .failure_loaded
    adrp x16, fn_bind_int64
    add x16, x16, :lo12:fn_bind_int64
    str x0, [x16]
    adrp x0, sqlite_module
    add x0, x0, :lo12:sqlite_module
    ldr x0, [x0]
    adrp x1, name_bind_null
    add x1, x1, :lo12:name_bind_null
    bl dlsym
    cbz x0, .failure_loaded
    adrp x16, fn_bind_null
    add x16, x16, :lo12:fn_bind_null
    str x0, [x16]
    adrp x0, sqlite_module
    add x0, x0, :lo12:sqlite_module
    ldr x0, [x0]
    adrp x1, name_step
    add x1, x1, :lo12:name_step
    bl dlsym
    cbz x0, .failure_loaded
    adrp x16, fn_step
    add x16, x16, :lo12:fn_step
    str x0, [x16]
    adrp x0, sqlite_module
    add x0, x0, :lo12:sqlite_module
    ldr x0, [x0]
    adrp x1, name_finalize
    add x1, x1, :lo12:name_finalize
    bl dlsym
    cbz x0, .failure_loaded
    adrp x16, fn_finalize
    add x16, x16, :lo12:fn_finalize
    str x0, [x16]
    adrp x0, sqlite_module
    add x0, x0, :lo12:sqlite_module
    ldr x0, [x0]
    adrp x1, name_column_int64
    add x1, x1, :lo12:name_column_int64
    bl dlsym
    cbz x0, .failure_loaded
    adrp x16, fn_column_int64
    add x16, x16, :lo12:fn_column_int64
    str x0, [x16]
    adrp x0, sqlite_module
    add x0, x0, :lo12:sqlite_module
    ldr x0, [x0]
    adrp x1, name_column_text
    add x1, x1, :lo12:name_column_text
    bl dlsym
    cbz x0, .failure_loaded
    adrp x16, fn_column_text
    add x16, x16, :lo12:fn_column_text
    str x0, [x16]
    adrp x0, sqlite_module
    add x0, x0, :lo12:sqlite_module
    ldr x0, [x0]
    adrp x1, name_errmsg
    add x1, x1, :lo12:name_errmsg
    bl dlsym
    cbz x0, .failure_loaded
    adrp x16, fn_errmsg
    add x16, x16, :lo12:fn_errmsg
    str x0, [x16]
.success:
    mov w0, wzr
    b .load_return
.load_return:
    ldp x29, x30, [sp], #16
    ret
.failure_loaded:
    adrp x0, sqlite_module
    add x0, x0, :lo12:sqlite_module
    ldr x0, [x0]
    bl dlclose
    adrp x16, sqlite_module
    add x16, x16, :lo12:sqlite_module
    str xzr, [x16]
    bl .sqlite_clear_functions
.failure:
    mov w0, #1
    b .load_return
    ret

.type yul_sqlite_runtime_unload, %function
yul_sqlite_runtime_unload:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x16, sqlite_module
    add x16, x16, :lo12:sqlite_module
    ldr x0, [x16]
    cbz x0, .unload_done
    bl dlclose
    adrp x16, sqlite_module
    add x16, x16, :lo12:sqlite_module
    str xzr, [x16]
.unload_done:
    bl .sqlite_clear_functions
    mov w0, wzr
    ldp x29, x30, [sp], #16
    ret

.sqlite_clear_functions:
    adrp x16, fn_open
    add x16, x16, :lo12:fn_open
    str xzr, [x16]
    adrp x16, fn_close
    add x16, x16, :lo12:fn_close
    str xzr, [x16]
    adrp x16, fn_exec
    add x16, x16, :lo12:fn_exec
    str xzr, [x16]
    adrp x16, fn_prepare
    add x16, x16, :lo12:fn_prepare
    str xzr, [x16]
    adrp x16, fn_bind_text
    add x16, x16, :lo12:fn_bind_text
    str xzr, [x16]
    adrp x16, fn_bind_int64
    add x16, x16, :lo12:fn_bind_int64
    str xzr, [x16]
    adrp x16, fn_bind_null
    add x16, x16, :lo12:fn_bind_null
    str xzr, [x16]
    adrp x16, fn_step
    add x16, x16, :lo12:fn_step
    str xzr, [x16]
    adrp x16, fn_finalize
    add x16, x16, :lo12:fn_finalize
    str xzr, [x16]
    adrp x16, fn_column_int64
    add x16, x16, :lo12:fn_column_int64
    str xzr, [x16]
    adrp x16, fn_column_text
    add x16, x16, :lo12:fn_column_text
    str xzr, [x16]
    adrp x16, fn_errmsg
    add x16, x16, :lo12:fn_errmsg
    str xzr, [x16]
    ret

.type yul_sqlite_open, %function
yul_sqlite_open:
    adrp x16, fn_open
    add x16, x16, :lo12:fn_open
    ldr x16, [x16]
    cbz x16, .unavailable
    mov x2, #6
    mov x3, xzr
    br x16

.type yul_sqlite_close, %function
yul_sqlite_close:
    adrp x16, fn_close
    add x16, x16, :lo12:fn_close
    ldr x16, [x16]
    cbz x16, .unavailable
    br x16

.type yul_sqlite_exec, %function
yul_sqlite_exec:
    adrp x16, fn_exec
    add x16, x16, :lo12:fn_exec
    ldr x16, [x16]
    cbz x16, .unavailable
    mov x2, xzr
    mov x3, xzr
    mov x4, xzr
    br x16

.type yul_sqlite_prepare, %function
yul_sqlite_prepare:
    adrp x16, fn_prepare
    add x16, x16, :lo12:fn_prepare
    ldr x16, [x16]
    cbz x16, .unavailable
    mov x3, x2
    mov x2, #-1
    mov x4, xzr
    br x16

.type yul_sqlite_bind_text, %function
yul_sqlite_bind_text:
    adrp x16, fn_bind_text
    add x16, x16, :lo12:fn_bind_text
    ldr x16, [x16]
    cbz x16, .unavailable
    mov x4, #-1
    br x16

.type yul_sqlite_bind_int64, %function
yul_sqlite_bind_int64:
    adrp x16, fn_bind_int64
    add x16, x16, :lo12:fn_bind_int64
    ldr x16, [x16]
    cbz x16, .unavailable
    br x16

.type yul_sqlite_bind_null, %function
yul_sqlite_bind_null:
    adrp x16, fn_bind_null
    add x16, x16, :lo12:fn_bind_null
    ldr x16, [x16]
    cbz x16, .unavailable
    br x16

.type yul_sqlite_step, %function
yul_sqlite_step:
    adrp x16, fn_step
    add x16, x16, :lo12:fn_step
    ldr x16, [x16]
    cbz x16, .unavailable
    br x16

.type yul_sqlite_finalize, %function
yul_sqlite_finalize:
    adrp x16, fn_finalize
    add x16, x16, :lo12:fn_finalize
    ldr x16, [x16]
    cbz x16, .unavailable
    br x16

.type yul_sqlite_column_int64, %function
yul_sqlite_column_int64:
    adrp x16, fn_column_int64
    add x16, x16, :lo12:fn_column_int64
    ldr x16, [x16]
    cbz x16, .unavailable
    br x16

.type yul_sqlite_column_text, %function
yul_sqlite_column_text:
    adrp x16, fn_column_text
    add x16, x16, :lo12:fn_column_text
    ldr x16, [x16]
    cbz x16, .unavailable
    br x16

.type yul_sqlite_errmsg, %function
yul_sqlite_errmsg:
    adrp x16, fn_errmsg
    add x16, x16, :lo12:fn_errmsg
    ldr x16, [x16]
    cbz x16, .unavailable
    br x16

.unavailable:
    mov w0, #1
    ret

.bss
.align 3
sqlite_module: .skip 8
fn_open: .skip 8
fn_close: .skip 8
fn_exec: .skip 8
fn_prepare: .skip 8
fn_bind_text: .skip 8
fn_bind_int64: .skip 8
fn_bind_null: .skip 8
fn_step: .skip 8
fn_finalize: .skip 8
fn_column_int64: .skip 8
fn_column_text: .skip 8
fn_errmsg: .skip 8
