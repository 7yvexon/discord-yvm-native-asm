.text
.global yul_parse_amount_ascii
.type yul_parse_amount_ascii, %function

yul_parse_amount_ascii:
    cbz x0, .invalid
    cbz x1, .invalid
    cbz x2, .invalid
    mov x3, xzr
    mov x4, xzr
    mov x6, #0xcccc
    movk x6, #0xcccc, lsl #16
    movk x6, #0xcccc, lsl #32
    movk x6, #0x0ccc, lsl #48
.loop:
    ldrb w5, [x0, x3]
    cmp w5, #48
    b.lo .invalid
    cmp w5, #57
    b.hi .invalid
    cmp x4, x6
    b.hi .overflow
    b.ne .multiply
    cmp w5, #55
    b.hi .overflow
.multiply:
    mov x7, #10
    mul x4, x4, x7
    sub w5, w5, #48
    add x4, x4, x5
    add x3, x3, #1
    cmp x3, x1
    b.lo .loop
    cbz x4, .invalid
    str x4, [x2]
    mov w0, wzr
    ret
.invalid:
    mov w0, #1
    ret
.overflow:
    mov w0, #2
    ret
.size yul_parse_amount_ascii, .-yul_parse_amount_ascii
