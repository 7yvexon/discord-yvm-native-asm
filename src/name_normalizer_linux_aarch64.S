.text
.global yul_normalize_name_utf8
.type yul_normalize_name_utf8, %function

yul_normalize_name_utf8:
    mov x5, x0
    mov x6, x1
    mov x7, x2
    mov x8, x3
    mov x9, x4
    cbz x5, .invalid
    cbz x6, .invalid
    cbz x7, .invalid
    cbz x8, .invalid
    cbz x9, .invalid
    mov x10, xzr
    mov x11, xzr
    mov x12, xzr
    mov x13, xzr
.next:
    cmp x10, x6
    b.hs .finish
    ldrb w0, [x5, x10]
    cmp w0, #0x80
    b.lo .ascii
    cmp w0, #0xc2
    b.lo .invalid
    cmp w0, #0xdf
    b.ls .two
    cmp w0, #0xef
    b.ls .three
    cmp w0, #0xf4
    b.ls .four
    b .invalid
.ascii:
    mov x1, #1
    b .codepoint
.two:
    sub x16, x6, x10
    cmp x16, #2
    b.lo .invalid
    add x16, x5, x10
    ldrb w2, [x16, #1]
    cmp w2, #0x80
    b.lo .invalid
    cmp w2, #0xbf
    b.hi .invalid
    and w0, w0, #0x1f
    lsl w0, w0, #6
    and w2, w2, #0x3f
    orr w0, w0, w2
    mov x1, #2
    b .codepoint
.three:
    sub x16, x6, x10
    cmp x16, #3
    b.lo .invalid
    add x16, x5, x10
    ldrb w2, [x16, #1]
    ldrb w3, [x16, #2]
    cmp w2, #0x80
    b.lo .invalid
    cmp w2, #0xbf
    b.hi .invalid
    cmp w3, #0x80
    b.lo .invalid
    cmp w3, #0xbf
    b.hi .invalid
    cmp w0, #0xe0
    b.ne .three_not_e0
    cmp w2, #0xa0
    b.lo .invalid
.three_not_e0:
    cmp w0, #0xed
    b.ne .three_build
    cmp w2, #0x9f
    b.hi .invalid
.three_build:
    and w4, w0, #0x0f
    lsl w4, w4, #12
    and w2, w2, #0x3f
    lsl w2, w2, #6
    orr w4, w4, w2
    and w3, w3, #0x3f
    orr w0, w4, w3
    mov x1, #3
    b .codepoint
.four:
    sub x16, x6, x10
    cmp x16, #4
    b.lo .invalid
    add x16, x5, x10
    ldrb w2, [x16, #1]
    ldrb w3, [x16, #2]
    ldrb w4, [x16, #3]
    cmp w2, #0x80
    b.lo .invalid
    cmp w2, #0xbf
    b.hi .invalid
    cmp w3, #0x80
    b.lo .invalid
    cmp w3, #0xbf
    b.hi .invalid
    cmp w4, #0x80
    b.lo .invalid
    cmp w4, #0xbf
    b.hi .invalid
    cmp w0, #0xf0
    b.ne .four_not_f0
    cmp w2, #0x90
    b.lo .invalid
.four_not_f0:
    cmp w0, #0xf4
    b.ne .four_build
    cmp w2, #0x8f
    b.hi .invalid
.four_build:
    and w16, w0, #0x07
    lsl w16, w16, #18
    and w2, w2, #0x3f
    lsl w2, w2, #12
    orr w16, w16, w2
    and w3, w3, #0x3f
    lsl w3, w3, #6
    orr w16, w16, w3
    and w4, w4, #0x3f
    orr w0, w16, w4
    mov x1, #4
.codepoint:
    cmp w0, #0x1f
    b.ls .invalid
    cmp w0, #0x7f
    b.eq .invalid
    cmp w0, #0x80
    b.lo .not_control
    cmp w0, #0x9f
    b.ls .invalid
.not_control:
    cmp w0, #0x20
    b.eq .whitespace
    cmp w0, #0xa0
    b.eq .whitespace
    mov w16, #0x1680
    cmp w0, w16
    b.eq .whitespace
    mov w16, #0x2000
    cmp w0, w16
    b.lo .not_whitespace
    mov w16, #0x200a
    cmp w0, w16
    b.ls .whitespace
    mov w16, #0x2028
    cmp w0, w16
    b.eq .whitespace
    mov w16, #0x2029
    cmp w0, w16
    b.eq .whitespace
    mov w16, #0x202f
    cmp w0, w16
    b.eq .whitespace
    mov w16, #0x205f
    cmp w0, w16
    b.eq .whitespace
    mov w16, #0x3000
    cmp w0, w16
    b.eq .whitespace
.not_whitespace:
    cbz x12, .copy
    cmp x11, x8
    b.hs .too_long
    mov w16, #0x20
    strb w16, [x7, x11]
    add x11, x11, #1
    mov x12, xzr
.copy:
    add x16, x11, x1
    cmp x16, x11
    b.lo .too_long
    cmp x16, x8
    b.hi .too_long
    mov x17, x1
.copy_loop:
    cbz x17, .copied
    ldrb w4, [x5, x10]
    strb w4, [x7, x11]
    add x10, x10, #1
    add x11, x11, #1
    sub x17, x17, #1
    b .copy_loop
.copied:
    mov x13, #1
    b .next
.whitespace:
    cbz x13, .skip_whitespace
    mov x12, #1
.skip_whitespace:
    add x10, x10, x1
    b .next
.finish:
    cbz x13, .invalid
    str x11, [x9]
    mov w0, wzr
    ret
.too_long:
    mov w0, #2
    b .return_error
.invalid:
    mov w0, #1
.return_error:
    cbz x9, .return
    str xzr, [x9]
.return:
    ret
.size yul_normalize_name_utf8, .-yul_normalize_name_utf8
