.text
.global _start
.type _start, %function
.extern yul_native_runtime_main

_start:
    mov x0, sp
    ldr x0, [x0]
    add x1, sp, #8
    bl yul_native_runtime_main
    mov x8, #93
    svc #0
    b .
.size _start, .-_start
