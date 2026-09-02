.text
.global yul_add_support_total
.type yul_add_support_total, %function

yul_add_support_total:
    cbz x2, .invalid
    cbz x1, .invalid
    mov x4, #0xffff
    movk x4, #0xffff, lsl #16
    movk x4, #0xffff, lsl #32
    movk x4, #0x7fff, lsl #48
    cmp x0, x4
    b.hi .overflow
    sub x5, x4, x0
    cmp x1, x5
    b.hi .overflow
    add x5, x0, x1
    str x5, [x2]
    mov w0, wzr
    ret
.invalid:
    mov w0, #1
    ret
.overflow:
    mov w0, #2
    ret
.size yul_add_support_total, .-yul_add_support_total
