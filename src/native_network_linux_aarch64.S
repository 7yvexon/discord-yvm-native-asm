.text
.global yul_native_network_start
.global yul_native_network_probe
.global yul_native_network_run
.global native_ws_open_url
.global native_ws_build_upgrade
.global native_ws_build_upgrade_url
.global native_ws_close
.global native_ws_send_text
.global native_ws_send_frame
.global native_ws_recv_message
.global native_pushbullet_poll
.global native_ws_build_identify
.global native_ws_build_heartbeat
.global native_json_find_pattern
.global native_json_find_root_pattern
.global native_json_find_number
.global native_json_find_root_number
.global native_parse_decimal_scaled
.global native_json_find_decimal_scaled
.global native_json_find_root_decimal_scaled
.global native_scaled_u64_to_ascii
.global native_json_validate_structure
.global native_bytes_find_pattern
.global yul_native_network_rest_json
.global ws_json_buffer
.global ws_json_length
.global ws_cursor
.global ws_cursor_candidate
.global ws_poll_has_pushes
.global ws_sequence
.global ws_sequence_valid
.global ws_heartbeat_interval
.global ws_identify_intents
.global ws_error_code
.global ws_stage
.global rest_status
.global rest_error_code
.global discord_gateway_url
.global discord_ws_host
.global discord_ws_path
.global json_key_heartbeat_interval
.global json_key_op
.global json_key_s
.global json_key_ready
.global json_key_type_push
.global json_key_type_push_space
.global json_key_type_tickle
.global json_key_type_tickle_space
.global pushbullet_ws_host
.global pushbullet_ws_path_prefix
.global pushbullet_stream_prefix
.global ws_http_path
.global ws_stream_url
.type yul_native_network_start, %function
.type yul_native_network_probe, %function
.type yul_native_network_run, %function
.extern dlopen
.extern dlsym
.extern rt_json_buffer
.extern rt_json_length
.extern rt_service_cursor
.extern rt_validate_gateway_url

.section .rodata
curl_library: .asciz "libcurl.so.4"
name_curl_global_init: .asciz "curl_global_init"
name_curl_easy_init: .asciz "curl_easy_init"
name_curl_easy_setopt: .asciz "curl_easy_setopt"
name_curl_easy_perform: .asciz "curl_easy_perform"
name_curl_easy_cleanup: .asciz "curl_easy_cleanup"
name_curl_easy_getinfo: .asciz "curl_easy_getinfo"
name_curl_slist_append: .asciz "curl_slist_append"
name_curl_slist_free_all: .asciz "curl_slist_free_all"
name_curl_easy_send: .asciz "curl_easy_send"
name_curl_easy_recv: .asciz "curl_easy_recv"
discord_url: .asciz "https://discord.com/api/v10/gateway"
pushbullet_url: .asciz "https://api.pushbullet.com/v2/users/me"
discord_gateway_url: .asciz "https://gateway.discord.gg/?v=10&encoding=json"
pushbullet_stream_prefix: .asciz "https://stream.pushbullet.com/websocket/"
pushbullet_poll_prefix: .asciz "https://api.pushbullet.com/v2/pushes?modified_after="
pushbullet_poll_cursor_prefix: .asciz "https://api.pushbullet.com/v2/pushes?cursor="
pushbullet_poll_suffix: .asciz "&limit=50"
user_agent: .asciz "yul-vending-machine/1"
discord_header_prefix: .asciz "Authorization: Bot "
pushbullet_header_prefix: .asciz "Access-Token: "
content_type_header: .asciz "Content-Type: application/json"
json_identify_prefix: .asciz "{\"op\":2,\"d\":{\"token\":\""
json_identify_mid: .asciz "\",\"intents\":"
json_identify_suffix: .asciz ",\"properties\":{\"os\":\"linux\",\"browser\":\"yul-vending-machine\",\"device\":\"yul-vending-machine\"}}}"
json_heartbeat_prefix: .asciz "{\"op\":1,\"d\":"
json_heartbeat_null: .asciz "null"
json_heartbeat_suffix: .asciz "}"
json_key_op: .asciz "\"op\":"
json_key_s: .asciz "\"s\":"
json_key_heartbeat_interval: .asciz "\"heartbeat_interval\":"
json_key_modified: .asciz "\"modified\":"
json_key_type_push: .asciz "\"type\":\"push\""
json_key_type_push_space: .asciz "\"type\": \"push\""
json_key_type_tickle: .asciz "\"type\":\"tickle\""
json_key_type_tickle_space: .asciz "\"type\": \"tickle\""
json_key_ready: .asciz "\"t\":\"READY\""
http_get_prefix: .asciz "GET "
http_host_separator: .asciz " HTTP/1.1\r\nHost: "
http_upgrade_prefix: .asciz "\r\nConnection: Upgrade\r\nUpgrade: websocket\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Key: "
http_connection_header: .ascii "Connection: Upgrade"
http_upgrade_header: .ascii "Upgrade: websocket"
http_accept_header_prefix: .ascii "Sec-WebSocket-Accept:"
ws_accept_guid: .ascii "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
ws_base64_alphabet: .asciz "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
discord_ws_host: .asciz "gateway.discord.gg"
discord_ws_path: .asciz "/?v=10&encoding=json"
discord_ws_query_suffix: .asciz "?v=10&encoding=json"
http_url_prefix: .asciz "http://"
https_url_prefix: .asciz "https://"
pushbullet_ws_host: .asciz "stream.pushbullet.com"
pushbullet_ws_path_prefix: .asciz "/websocket/"
http_end: .asciz "\r\n\r\n"
http_status_101: .asciz "HTTP/1.1 101"
ws_sleep_timespec_value: .quad 0, 10000000

.text
yul_native_network_start:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    mov x29, sp
    adrp x16, curl_module
    add x16, x16, :lo12:curl_module
    ldr x17, [x16]
    cbnz x17, .start_success
    adrp x0, curl_library
    add x0, x0, :lo12:curl_library
    mov x1, #1
    bl dlopen
    cbz x0, .start_failure
    adrp x16, curl_module
    add x16, x16, :lo12:curl_module
    str x0, [x16]
    mov x19, x0
    adrp x17, ws_stage
    add x17, x17, :lo12:ws_stage
    mov w1, #1
    str w1, [x17]
    adrp x1, name_curl_global_init
    add x1, x1, :lo12:name_curl_global_init
    bl dlsym
    cbz x0, .start_failure_loaded
    adrp x16, fn_global_init
    add x16, x16, :lo12:fn_global_init
    str x0, [x16]
    adrp x1, name_curl_easy_init
    add x1, x1, :lo12:name_curl_easy_init
    mov x0, x19
    bl dlsym
    cbz x0, .start_failure_loaded
    adrp x16, fn_easy_init
    add x16, x16, :lo12:fn_easy_init
    str x0, [x16]
    adrp x1, name_curl_easy_setopt
    add x1, x1, :lo12:name_curl_easy_setopt
    mov x0, x19
    bl dlsym
    cbz x0, .start_failure_loaded
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    str x0, [x16]
    adrp x1, name_curl_easy_perform
    add x1, x1, :lo12:name_curl_easy_perform
    mov x0, x19
    bl dlsym
    cbz x0, .start_failure_loaded
    adrp x16, fn_easy_perform
    add x16, x16, :lo12:fn_easy_perform
    str x0, [x16]
    adrp x1, name_curl_easy_cleanup
    add x1, x1, :lo12:name_curl_easy_cleanup
    mov x0, x19
    bl dlsym
    cbz x0, .start_failure_loaded
    adrp x16, fn_easy_cleanup
    add x16, x16, :lo12:fn_easy_cleanup
    str x0, [x16]
    adrp x1, name_curl_easy_getinfo
    add x1, x1, :lo12:name_curl_easy_getinfo
    mov x0, x19
    bl dlsym
    cbz x0, .start_failure_loaded
    adrp x16, fn_easy_getinfo
    add x16, x16, :lo12:fn_easy_getinfo
    str x0, [x16]
    adrp x1, name_curl_slist_append
    add x1, x1, :lo12:name_curl_slist_append
    mov x0, x19
    bl dlsym
    cbz x0, .start_failure_loaded
    adrp x16, fn_slist_append
    add x16, x16, :lo12:fn_slist_append
    str x0, [x16]
    adrp x1, name_curl_slist_free_all
    add x1, x1, :lo12:name_curl_slist_free_all
    mov x0, x19
    bl dlsym
    cbz x0, .start_failure_loaded
    adrp x16, fn_slist_free_all
    add x16, x16, :lo12:fn_slist_free_all
    str x0, [x16]
    adrp x1, name_curl_easy_send
    add x1, x1, :lo12:name_curl_easy_send
    mov x0, x19
    bl dlsym
    cbz x0, .start_failure_loaded
    adrp x16, fn_easy_send
    add x16, x16, :lo12:fn_easy_send
    str x0, [x16]
    adrp x1, name_curl_easy_recv
    add x1, x1, :lo12:name_curl_easy_recv
    mov x0, x19
    bl dlsym
    cbz x0, .start_failure_loaded
    adrp x16, fn_easy_recv
    add x16, x16, :lo12:fn_easy_recv
    str x0, [x16]
    adrp x16, fn_global_init
    add x16, x16, :lo12:fn_global_init
    ldr x16, [x16]
    mov x0, #3
    blr x16
    cbnz w0, .start_failure_loaded
.start_success:
    mov w0, wzr
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
.start_failure_loaded:
    adrp x16, curl_module
    add x16, x16, :lo12:curl_module
    str xzr, [x16]
.start_failure:
    mov w0, #1
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

yul_native_network_probe:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    mov x29, sp
    mov x19, x0
    mov x20, x1
    cbz x19, .probe_check_push
    ldrb w0, [x19]
    cbnz w0, .probe_start
.probe_check_push:
    cbz x20, .probe_success
    ldrb w0, [x20]
    cbz w0, .probe_success
    b .probe_start
.probe_start:
    bl yul_native_network_start
    cbnz w0, .probe_failure
    cbz x19, .probe_request_pushbullet
    ldrb w0, [x19]
    cbz w0, .probe_request_pushbullet
.probe_request_discord:
    adrp x0, discord_url
    add x0, x0, :lo12:discord_url
    mov x1, x19
    adrp x2, discord_header_prefix
    add x2, x2, :lo12:discord_header_prefix
    bl native_curl_get
    cbnz w0, .probe_failure
    adrp x0, rest_status
    add x0, x0, :lo12:rest_status
    ldr w0, [x0]
    cmp w0, #200
    b.lo .probe_failure
    cmp w0, #300
    b.hs .probe_failure
    cbz x20, .probe_success
    ldrb w0, [x20]
    cbz w0, .probe_success
.probe_request_pushbullet:
    adrp x0, pushbullet_url
    add x0, x0, :lo12:pushbullet_url
    mov x1, x20
    adrp x2, pushbullet_header_prefix
    add x2, x2, :lo12:pushbullet_header_prefix
    bl native_curl_get
    cbnz w0, .probe_failure
    adrp x0, rest_status
    add x0, x0, :lo12:rest_status
    ldr w0, [x0]
    cmp w0, #200
    b.lo .probe_failure
    cmp w0, #300
    b.hs .probe_failure
.probe_success:
    mov w0, wzr
    b .probe_return
.probe_failure:
    cmp w0, #0
    b.ne .probe_return
    mov w0, #1
.probe_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

yul_native_network_run:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    cbz x19, .run_linux_check_push
    ldrb w0, [x19]
    cbz w0, .run_linux_check_push
    bl yul_native_network_start
    cbz w0, .run_linux_gateway_ready
    mov w0, #102
    b .run_linux_failure
.run_linux_gateway_ready:
    mov x0, x19
    bl native_ws_gateway
    cbz w0, .run_linux_check_push
    cmp w0, #1
    b.hi .run_linux_failure
    mov w0, #103
    b .run_linux_failure
.run_linux_check_push:
    cbz x20, .run_linux_success
    ldrb w0, [x20]
    cbz w0, .run_linux_success
    bl yul_native_network_start
    cbz w0, .run_linux_push_ready
    mov w0, #102
    b .run_linux_failure
.run_linux_push_ready:
    mov x0, x20
    bl native_ws_pushbullet
    cbz w0, .run_linux_success
    cmp w0, #1
    b.hi .run_linux_failure
    mov w0, #104
    b .run_linux_failure
.run_linux_success:
    mov w0, wzr
    b .run_linux_return
.run_linux_failure:
    cmp w0, #1
    b.hi .run_linux_return
    adrp x16, ws_error_code
    add x16, x16, :lo12:ws_error_code
    ldr w0, [x16]
    cbnz w0, .run_linux_return
    mov w0, #1
.run_linux_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

native_ws_open_url:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    adrp x0, ws_transport_url
    add x0, x0, :lo12:ws_transport_url
    mov x1, x19
    bl native_ws_prepare_url
    mov x19, x0
    adrp x17, ws_error_code
    add x17, x17, :lo12:ws_error_code
    str wzr, [x17]
    adrp x17, ws_open_ok
    add x17, x17, :lo12:ws_open_ok
    str wzr, [x17]
    adrp x16, ws_http_request_length
    add x16, x16, :lo12:ws_http_request_length
    ldr x0, [x16]
    cbz x0, .ws_open_failure
    adrp x16, fn_easy_init
    add x16, x16, :lo12:fn_easy_init
    ldr x16, [x16]
    blr x16
    mov x20, x0
    adrp x17, ws_stage
    add x17, x17, :lo12:ws_stage
    mov w1, #2
    str w1, [x17]
    mov x0, x20
    cbz x0, .ws_open_failure
    mov x20, x0
    mov x0, x20
    mov x1, #10002
    mov x2, x19
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    adrp x17, ws_stage
    add x17, x17, :lo12:ws_stage
    mov w1, #3
    str w1, [x17]
    adrp x17, ws_error_code
    add x17, x17, :lo12:ws_error_code
    str w0, [x17]
    cbnz w0, .ws_open_cleanup
    mov x0, x20
    mov x1, #84
    mov x2, #2
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    adrp x17, ws_error_code
    add x17, x17, :lo12:ws_error_code
    str w0, [x17]
    cbnz w0, .ws_open_cleanup
    mov x0, x20
    mov x1, #10018
    adrp x2, user_agent
    add x2, x2, :lo12:user_agent
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    adrp x17, ws_stage
    add x17, x17, :lo12:ws_stage
    mov w1, #4
    str w1, [x17]
    adrp x17, ws_error_code
    add x17, x17, :lo12:ws_error_code
    str w0, [x17]
    cbnz w0, .ws_open_cleanup
    mov x0, x20
    mov x1, #141
    mov x2, #1
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    adrp x17, ws_stage
    add x17, x17, :lo12:ws_stage
    mov w1, #5
    str w1, [x17]
    adrp x17, ws_error_code
    add x17, x17, :lo12:ws_error_code
    str w0, [x17]
    cbnz w0, .ws_open_cleanup
    mov x0, x20
    mov x1, #156
    mov x2, #20000
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    adrp x17, ws_stage
    add x17, x17, :lo12:ws_stage
    mov w1, #6
    str w1, [x17]
    adrp x17, ws_error_code
    add x17, x17, :lo12:ws_error_code
    str w0, [x17]
    cbnz w0, .ws_open_cleanup
    mov x0, x20
    adrp x16, fn_easy_perform
    add x16, x16, :lo12:fn_easy_perform
    ldr x16, [x16]
    mov x0, x20
    adrp x17, ws_stage
    add x17, x17, :lo12:ws_stage
    mov w1, #7
    str w1, [x17]
    blr x16
    adrp x17, ws_error_code
    add x17, x17, :lo12:ws_error_code
    str w0, [x17]
    cbnz w0, .ws_open_cleanup
    mov x0, x20
    bl native_ws_http_upgrade
    cbz w0, .ws_open_upgrade_ok
    mov w1, #150
    adrp x17, ws_error_code
    add x17, x17, :lo12:ws_error_code
    str w1, [x17]
    b .ws_open_cleanup
.ws_open_upgrade_ok:
    adrp x17, ws_stage
    add x17, x17, :lo12:ws_stage
    mov w1, #8
    str w1, [x17]
    adrp x17, ws_open_ok
    add x17, x17, :lo12:ws_open_ok
    mov w1, #1
    str w1, [x17]
    mov x0, x20
    b .ws_open_return
.ws_open_cleanup:
    mov x0, x20
    adrp x16, fn_easy_cleanup
    add x16, x16, :lo12:fn_easy_cleanup
    ldr x16, [x16]
    blr x16
.ws_open_failure:
    mov x0, xzr
.ws_open_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

native_ws_prepare_url:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    ldrb w2, [x20]
    cmp w2, #119
    b.ne .ws_prepare_copy
    ldrb w2, [x20, #1]
    cmp w2, #115
    b.ne .ws_prepare_copy
    ldrb w2, [x20, #2]
    cmp w2, #115
    b.eq .ws_prepare_wss
    cmp w2, #58
    b.ne .ws_prepare_copy
    ldrb w2, [x20, #3]
    cmp w2, #47
    b.ne .ws_prepare_copy
    ldrb w2, [x20, #4]
    cmp w2, #47
    b.ne .ws_prepare_copy
    add x20, x20, #5
    mov x0, x19
    adrp x1, http_url_prefix
    add x1, x1, :lo12:http_url_prefix
    bl native_append_cstr
    mov x1, x20
    bl native_append_cstr
    mov x0, x19
    b .ws_prepare_return
.ws_prepare_wss:
    ldrb w2, [x20, #3]
    cmp w2, #58
    b.ne .ws_prepare_copy
    ldrb w2, [x20, #4]
    cmp w2, #47
    b.ne .ws_prepare_copy
    ldrb w2, [x20, #5]
    cmp w2, #47
    b.ne .ws_prepare_copy
    add x20, x20, #6
    mov x0, x19
    adrp x1, https_url_prefix
    add x1, x1, :lo12:https_url_prefix
    bl native_append_cstr
    mov x1, x20
    bl native_append_cstr
    mov x0, x19
    b .ws_prepare_return
.ws_prepare_copy:
    mov x0, x19
    mov x1, x20
    bl native_append_cstr
    mov x0, x19
.ws_prepare_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

native_ws_close:
    cbz x0, .ws_close_done
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    adrp x1, ws_empty
    add x1, x1, :lo12:ws_empty
    mov x2, xzr
    mov w3, #8
    mov x0, x19
    bl native_ws_send_frame
    mov x0, x19
    adrp x16, fn_easy_cleanup
    add x16, x16, :lo12:fn_easy_cleanup
    ldr x16, [x16]
    blr x16
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
.ws_close_done:
    ret

native_getrandom:
    mov x9, x0
    mov x10, x1
.random_loop:
    mov x0, x9
    mov x1, x10
    mov x2, xzr
    mov x8, #278
    svc #0
    cmp x0, #0
    b.le .random_failure
    add x9, x9, x0
    sub x10, x10, x0
    cbnz x10, .random_loop
    mov w0, wzr
    ret
.random_failure:
    mov w0, #1
    ret

native_make_ws_key:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    adrp x0, ws_random_bytes
    add x0, x0, :lo12:ws_random_bytes
    mov x1, #16
    bl native_getrandom
    cbnz w0, .ws_key_failure
    adrp x19, ws_random_bytes
    add x19, x19, :lo12:ws_random_bytes
    adrp x20, ws_key_base64
    add x20, x20, :lo12:ws_key_base64
    adrp x21, ws_base64_alphabet
    add x21, x21, :lo12:ws_base64_alphabet
    mov x22, xzr
    mov x23, xzr
.ws_key_groups:
    add x24, x19, x22
    ldrb w5, [x24]
    ldrb w6, [x24, #1]
    ldrb w7, [x24, #2]
    lsr w8, w5, #2
    and w9, w5, #3
    lsl w9, w9, #4
    lsr w10, w6, #4
    orr w9, w9, w10
    and w10, w6, #15
    lsl w10, w10, #2
    lsr w11, w7, #6
    orr w10, w10, w11
    and w11, w7, #63
    add x24, x20, x23
    ldrb w8, [x21, x8]
    strb w8, [x24]
    ldrb w9, [x21, x9]
    strb w9, [x24, #1]
    ldrb w10, [x21, x10]
    strb w10, [x24, #2]
    ldrb w11, [x21, x11]
    strb w11, [x24, #3]
    add x22, x22, #3
    add x23, x23, #4
    cmp x22, #15
    b.lo .ws_key_groups
    add x24, x19, #15
    ldrb w5, [x24]
    lsr w8, w5, #2
    and w9, w5, #3
    lsl w9, w9, #4
    add x24, x20, x23
    ldrb w8, [x21, x8]
    strb w8, [x24]
    ldrb w9, [x21, x9]
    strb w9, [x24, #1]
    mov w8, #61
    strb w8, [x24, #2]
    strb w8, [x24, #3]
    strb wzr, [x24, #4]
    mov w0, wzr
    b .ws_key_return
.ws_key_failure:
    mov w0, #1
.ws_key_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

native_ws_compute_accept:
    stp x29, x30, [sp, #-96]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x29, sp
    adrp x19, ws_sha1_block
    add x19, x19, :lo12:ws_sha1_block
    mov x20, xzr
.ws_accept_zero_loop:
    cmp x20, #128
    b.hs .ws_accept_copy_key
    strb wzr, [x19, x20]
    add x20, x20, #1
    b .ws_accept_zero_loop
.ws_accept_copy_key:
    adrp x21, ws_key_base64
    add x21, x21, :lo12:ws_key_base64
    mov x20, xzr
.ws_accept_key_loop:
    cmp x20, #24
    b.hs .ws_accept_copy_guid
    ldrb w0, [x21, x20]
    strb w0, [x19, x20]
    add x20, x20, #1
    b .ws_accept_key_loop
.ws_accept_copy_guid:
    add x0, x19, #24
    adrp x21, ws_accept_guid
    add x21, x21, :lo12:ws_accept_guid
    mov x20, xzr
.ws_accept_guid_copy_fixed:
    cmp x20, #36
    b.hs .ws_accept_padding_ready
    ldrb w1, [x21, x20]
    strb w1, [x0, x20]
    add x20, x20, #1
    b .ws_accept_guid_copy_fixed
.ws_accept_padding_ready:
    mov w0, #128
    strb w0, [x19, #60]
    mov w0, #1
    strb w0, [x19, #126]
    mov w0, #224
    strb w0, [x19, #127]
    movz w23, #0x2301
    movk w23, #0x6745, lsl #16
    movz w24, #0xab89
    movk w24, #0xefcd, lsl #16
    movz w25, #0xdcfe
    movk w25, #0x98ba, lsl #16
    movz w26, #0x5476
    movk w26, #0x1032, lsl #16
    movz w27, #0xe1f0
    movk w27, #0xc3d2, lsl #16
    mov x21, xzr
.ws_sha1_block_loop:
    adrp x20, ws_sha1_schedule
    add x20, x20, :lo12:ws_sha1_schedule
    mov x22, xzr
.ws_sha1_schedule_initial:
    cmp x22, #16
    b.hs .ws_sha1_schedule_expand
    add x0, x19, x21
    add x0, x0, x22, lsl #2
    ldrb w1, [x0]
    ldrb w2, [x0, #1]
    ldrb w3, [x0, #2]
    ldrb w4, [x0, #3]
    lsl w1, w1, #24
    lsl w2, w2, #16
    lsl w3, w3, #8
    orr w1, w1, w2
    orr w1, w1, w3
    orr w1, w1, w4
    add x0, x20, x22, lsl #2
    str w1, [x0]
    add x22, x22, #1
    b .ws_sha1_schedule_initial
.ws_sha1_schedule_expand:
    cmp x22, #80
    b.hs .ws_sha1_round_start
    sub x0, x22, #3
    ldr w1, [x20, x0, lsl #2]
    sub x0, x22, #8
    ldr w2, [x20, x0, lsl #2]
    sub x0, x22, #14
    ldr w3, [x20, x0, lsl #2]
    sub x0, x22, #16
    ldr w4, [x20, x0, lsl #2]
    eor w1, w1, w2
    eor w1, w1, w3
    eor w1, w1, w4
    ror w1, w1, #31
    str w1, [x20, x22, lsl #2]
    add x22, x22, #1
    b .ws_sha1_schedule_expand
.ws_sha1_round_start:
    mov w8, w23
    mov w9, w24
    mov w10, w25
    mov w11, w26
    mov w12, w27
    mov x22, xzr
.ws_sha1_round:
    cmp x22, #80
    b.hs .ws_sha1_round_done
    ldr w15, [x20, x22, lsl #2]
    cmp x22, #20
    b.lo .ws_sha1_round_0
    cmp x22, #40
    b.lo .ws_sha1_round_1
    cmp x22, #60
    b.lo .ws_sha1_round_2
    eor w13, w9, w10
    eor w13, w13, w11
    movz w14, #0xc1d6
    movk w14, #0xca62, lsl #16
    b .ws_sha1_round_f_done
.ws_sha1_round_0:
    and w13, w9, w10
    mvn w0, w9
    and w0, w0, w11
    orr w13, w13, w0
    movz w14, #0x7999
    movk w14, #0x5a82, lsl #16
    b .ws_sha1_round_f_done
.ws_sha1_round_1:
    eor w13, w9, w10
    eor w13, w13, w11
    movz w14, #0xeba1
    movk w14, #0x6ed9, lsl #16
    b .ws_sha1_round_f_done
.ws_sha1_round_2:
    and w13, w9, w10
    and w0, w9, w11
    orr w13, w13, w0
    and w0, w10, w11
    orr w13, w13, w0
    movz w14, #0xbcdc
    movk w14, #0x8f1b, lsl #16
.ws_sha1_round_f_done:
    ror w0, w8, #27
    add w0, w0, w13
    add w0, w0, w12
    add w0, w0, w14
    add w0, w0, w15
    mov w12, w11
    mov w11, w10
    ror w10, w9, #2
    mov w9, w8
    mov w8, w0
    add x22, x22, #1
    b .ws_sha1_round
.ws_sha1_round_done:
    add w23, w23, w8
    add w24, w24, w9
    add w25, w25, w10
    add w26, w26, w11
    add w27, w27, w12
    add x21, x21, #64
    cmp x21, #128
    b.lo .ws_sha1_block_loop
    adrp x20, ws_accept_digest
    add x20, x20, :lo12:ws_accept_digest
    rev w0, w23
    str w0, [x20]
    rev w0, w24
    str w0, [x20, #4]
    rev w0, w25
    str w0, [x20, #8]
    rev w0, w26
    str w0, [x20, #12]
    rev w0, w27
    str w0, [x20, #16]
    adrp x21, ws_accept_digest
    add x21, x21, :lo12:ws_accept_digest
    adrp x22, ws_accept_expected
    add x22, x22, :lo12:ws_accept_expected
    adrp x23, ws_base64_alphabet
    add x23, x23, :lo12:ws_base64_alphabet
    mov x24, xzr
    mov x25, xzr
.ws_accept_base64_full:
    cmp x24, #18
    b.hs .ws_accept_base64_tail
    add x28, x21, x24
    ldrb w0, [x28]
    ldrb w1, [x28, #1]
    ldrb w2, [x28, #2]
    lsr w3, w0, #2
    and w4, w0, #3
    lsl w4, w4, #4
    lsr w5, w1, #4
    orr w4, w4, w5
    and w5, w1, #15
    lsl w5, w5, #2
    lsr w6, w2, #6
    orr w5, w5, w6
    and w6, w2, #63
    ldrb w3, [x23, x3]
    ldrb w4, [x23, x4]
    ldrb w5, [x23, x5]
    ldrb w6, [x23, x6]
    add x28, x22, x25
    strb w3, [x28]
    strb w4, [x28, #1]
    strb w5, [x28, #2]
    strb w6, [x28, #3]
    add x24, x24, #3
    add x25, x25, #4
    b .ws_accept_base64_full
.ws_accept_base64_tail:
    ldrb w0, [x21, #18]
    ldrb w1, [x21, #19]
    lsr w3, w0, #2
    and w4, w0, #3
    lsl w4, w4, #4
    lsr w5, w1, #4
    orr w4, w4, w5
    and w5, w1, #15
    lsl w5, w5, #2
    ldrb w3, [x23, x3]
    ldrb w4, [x23, x4]
    ldrb w5, [x23, x5]
    add x28, x22, x25
    strb w3, [x28]
    strb w4, [x28, #1]
    strb w5, [x28, #2]
    mov w0, #61
    strb w0, [x28, #3]
    strb wzr, [x22, #28]
    mov w0, wzr
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret

native_ws_send_text:
    mov w3, #1
    b native_ws_send_frame

native_ws_send_frame:
    stp x29, x30, [sp, #-80]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov w22, w3
    mov x23, #0
    mov x24, #0
    mov x25, #65535
    cmp x21, x25
    b.hi .ws_frame_failure
    adrp x0, ws_mask_key
    add x0, x0, :lo12:ws_mask_key
    mov x1, #4
    bl native_getrandom
    cbnz w0, .ws_frame_failure
    adrp x24, ws_frame_buffer
    add x24, x24, :lo12:ws_frame_buffer
    orr w4, w22, #0x80
    strb w4, [x24]
    cmp x21, #126
    b.hs .ws_frame_extended
    orr x5, x21, #0x80
    strb w5, [x24, #1]
    add x23, x24, #6
    adrp x5, ws_mask_key
    add x5, x5, :lo12:ws_mask_key
    mov x6, #0
    ldrb w7, [x5]
    strb w7, [x24, #2]
    ldrb w7, [x5, #1]
    strb w7, [x24, #3]
    ldrb w7, [x5, #2]
    strb w7, [x24, #4]
    ldrb w7, [x5, #3]
    strb w7, [x24, #5]
    b .ws_frame_copy
.ws_frame_extended:
    mov w5, #0xfe
    strb w5, [x24, #1]
    lsr x5, x21, #8
    strb w5, [x24, #2]
    strb w21, [x24, #3]
    add x23, x24, #8
    adrp x5, ws_mask_key
    add x5, x5, :lo12:ws_mask_key
    ldrb w7, [x5]
    strb w7, [x24, #4]
    ldrb w7, [x5, #1]
    strb w7, [x24, #5]
    ldrb w7, [x5, #2]
    strb w7, [x24, #6]
    ldrb w7, [x5, #3]
    strb w7, [x24, #7]
.ws_frame_copy:
    mov x6, xzr
    adrp x5, ws_mask_key
    add x5, x5, :lo12:ws_mask_key
.ws_frame_copy_loop:
    cmp x6, x21
    b.hs .ws_frame_send
    ldrb w7, [x20, x6]
    and x8, x6, #3
    ldrb w9, [x5, x8]
    eor w7, w7, w9
    strb w7, [x23, x6]
    add x6, x6, #1
    b .ws_frame_copy_loop
.ws_frame_send:
    cmp x21, #126
    b.lo .ws_frame_short_total
    add x2, x21, #8
    b .ws_frame_send_call
.ws_frame_short_total:
    add x2, x21, #6
.ws_frame_send_call:
    mov x0, x19
    mov x1, x24
    bl native_raw_send_all
    b .ws_frame_return
.ws_frame_failure:
    mov w0, #1
.ws_frame_return:
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret

native_ws_recv_message:
    stp x29, x30, [sp, #-96]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x29, sp
    mov x19, x0
    adrp x20, ws_message_length
    add x20, x20, :lo12:ws_message_length
    str xzr, [x20]
    adrp x16, ws_fragment_active
    add x16, x16, :lo12:ws_fragment_active
    str wzr, [x16]
    adrp x16, ws_recv_budget
    add x16, x16, :lo12:ws_recv_budget
    mov x17, #100
    str x17, [x16]
    adrp x21, ws_buffer
    add x21, x21, :lo12:ws_buffer
.ws_raw_next_frame:
    adrp x1, ws_frame_header
    add x1, x1, :lo12:ws_frame_header
    mov x0, x19
    mov x2, #2
    bl native_raw_recv_exact
    cmp w0, #2
    b.eq .ws_raw_timeout
    cbnz w0, .ws_raw_failure
    adrp x22, ws_frame_header
    add x22, x22, :lo12:ws_frame_header
    ldrb w23, [x22]
    tst w23, #0x70
    b.ne .ws_raw_failure
    and w24, w23, #0x0f
    ldrb w25, [x22, #1]
    and w26, w25, #0x7f
    cmp w24, #8
    b.eq .ws_raw_failure
    cmp w24, #9
    b.eq .ws_raw_control_frame
    cmp w24, #10
    b.eq .ws_raw_control_frame
    cmp w24, #1
    b.eq .ws_raw_text_frame
    cbz w24, .ws_raw_continuation_frame
    cbnz w24, .ws_raw_failure
    b .ws_raw_payload_length
.ws_raw_text_frame:
    adrp x16, ws_fragment_active
    add x16, x16, :lo12:ws_fragment_active
    ldr w0, [x16]
    cbnz w0, .ws_raw_failure
    b .ws_raw_payload_length
.ws_raw_continuation_frame:
    adrp x16, ws_fragment_active
    add x16, x16, :lo12:ws_fragment_active
    ldr w0, [x16]
    cbz w0, .ws_raw_failure
    b .ws_raw_payload_length
.ws_raw_control_frame:
    tbz w23, #7, .ws_raw_failure
    cmp w26, #126
    b.hs .ws_raw_failure
    b .ws_raw_payload_length
.ws_raw_payload_length:
    cmp w26, #126
    b.lo .ws_raw_short_length
    b.eq .ws_raw_medium_length
    b .ws_raw_long_length
.ws_raw_short_length:
    uxtw x27, w26
    b .ws_raw_mask
.ws_raw_medium_length:
    adrp x1, ws_frame_header_ext
    add x1, x1, :lo12:ws_frame_header_ext
    mov x0, x19
    mov x2, #2
    bl native_raw_recv_exact
    cmp w0, #2
    b.eq .ws_raw_timeout
    cbnz w0, .ws_raw_failure
    adrp x1, ws_frame_header_ext
    add x1, x1, :lo12:ws_frame_header_ext
    ldrb w2, [x1]
    ldrb w3, [x1, #1]
    lsl x27, x2, #8
    add x27, x27, x3
    b .ws_raw_mask
.ws_raw_long_length:
    adrp x1, ws_frame_header_ext
    add x1, x1, :lo12:ws_frame_header_ext
    mov x0, x19
    mov x2, #8
    bl native_raw_recv_exact
    cmp w0, #2
    b.eq .ws_raw_timeout
    cbnz w0, .ws_raw_failure
    adrp x1, ws_frame_header_ext
    add x1, x1, :lo12:ws_frame_header_ext
    ldrb w2, [x1]
    cbnz w2, .ws_raw_failure
    ldrb w2, [x1, #1]
    cbnz w2, .ws_raw_failure
    ldrb w2, [x1, #2]
    cbnz w2, .ws_raw_failure
    ldrb w2, [x1, #3]
    cbnz w2, .ws_raw_failure
    ldrb w2, [x1, #4]
    cbnz w2, .ws_raw_failure
    ldrb w2, [x1, #5]
    cbnz w2, .ws_raw_failure
    ldrb w2, [x1, #6]
    ldrb w3, [x1, #7]
    lsl x27, x2, #8
    add x27, x27, x3
.ws_raw_mask:
    tbz w25, #7, .ws_raw_payload
    adrp x1, ws_frame_mask
    add x1, x1, :lo12:ws_frame_mask
    mov x0, x19
    mov x2, #4
    bl native_raw_recv_exact
    cmp w0, #2
    b.eq .ws_raw_timeout
    cbnz w0, .ws_raw_failure
.ws_raw_payload:
    mov x28, #65535
    cmp x27, x28
    b.hi .ws_raw_failure
    adrp x1, ws_frame_payload
    add x1, x1, :lo12:ws_frame_payload
    mov x0, x19
    mov x2, x27
    bl native_raw_recv_exact
    cmp w0, #2
    b.eq .ws_raw_timeout
    cbnz w0, .ws_raw_failure
    tbz w25, #7, .ws_raw_unmasked
    adrp x1, ws_frame_payload
    add x1, x1, :lo12:ws_frame_payload
    adrp x2, ws_frame_mask
    add x2, x2, :lo12:ws_frame_mask
    mov x3, #0
.ws_raw_unmask_loop:
    cmp x3, x27
    b.hs .ws_raw_unmasked
    ldrb w4, [x1, x3]
    and x5, x3, #3
    ldrb w6, [x2, x5]
    eor w4, w4, w6
    strb w4, [x1, x3]
    add x3, x3, #1
    b .ws_raw_unmask_loop
.ws_raw_unmasked:
    cmp w24, #9
    b.eq .ws_raw_ping
    cmp w24, #10
    b.eq .ws_raw_pong
    ldr x3, [x20]
    mov x4, #65535
    sub x4, x4, x3
    cmp x27, x4
    b.hi .ws_raw_failure
    adrp x0, ws_frame_payload
    add x0, x0, :lo12:ws_frame_payload
    mov x1, x27
    add x2, x21, x3
    bl native_copy_bytes
    ldr x3, [x20]
    add x3, x3, x27
    str x3, [x20]
    tbz w23, #7, .ws_raw_message_fragment
    adrp x16, ws_fragment_active
    add x16, x16, :lo12:ws_fragment_active
    str wzr, [x16]
    adrp x0, ws_buffer
    add x0, x0, :lo12:ws_buffer
    mov x1, x3
    bl native_event_queue_push
    cbnz w0, .ws_raw_failure
    bl native_event_queue_pop
    b .ws_raw_return
.ws_raw_ping:
    adrp x1, ws_frame_payload
    add x1, x1, :lo12:ws_frame_payload
    mov x0, x19
    mov x2, x27
    mov w3, #10
    bl native_ws_send_frame
    cbnz w0, .ws_raw_failure
    b .ws_raw_next_frame
.ws_raw_pong:
    b .ws_raw_next_frame
.ws_raw_message_fragment:
    adrp x16, ws_fragment_active
    add x16, x16, :lo12:ws_fragment_active
    mov w0, #1
    str w0, [x16]
    b .ws_raw_next_frame
.ws_raw_failure:
    mov x0, xzr
    mov x1, xzr
    b .ws_raw_return
.ws_raw_timeout:
    mov x0, #2
    mov x1, xzr
.ws_raw_return:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret

native_raw_send_all:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, xzr
    mov x23, xzr
.raw_send_loop:
    cmp x22, x21
    b.hs .raw_send_success
    add x1, x20, x22
    sub x2, x21, x22
    adrp x3, ws_io_size
    add x3, x3, :lo12:ws_io_size
    str xzr, [x3]
    mov x0, x19
    adrp x16, fn_easy_send
    add x16, x16, :lo12:fn_easy_send
    ldr x16, [x16]
    blr x16
    cbz w0, .raw_send_progress
    cmp w0, #81
    b.ne .raw_send_failure
.raw_send_no_progress:
    add x23, x23, #1
    cmp x23, #200
    b.hs .raw_send_failure
    bl native_ws_sleep
    b .raw_send_loop
.raw_send_progress:
    adrp x3, ws_io_size
    add x3, x3, :lo12:ws_io_size
    ldr x3, [x3]
    cbz x3, .raw_send_no_progress
    add x22, x22, x3
    mov x23, xzr
    b .raw_send_loop
.raw_send_success:
    mov w0, wzr
    b .raw_send_return
.raw_send_failure:
    mov w0, #1
.raw_send_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

native_raw_recv_exact:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, xzr
    mov x23, xzr
.raw_recv_loop:
    cmp x22, x21
    b.hs .raw_recv_success
    add x0, x20, x22
    sub x1, x21, x22
    bl native_pending_take
    cbz x0, .raw_recv_socket
    add x22, x22, x0
    b .raw_recv_loop
.raw_recv_socket:
    adrp x1, ws_socket_buffer
    add x1, x1, :lo12:ws_socket_buffer
    mov x2, #65535
    adrp x3, ws_io_size
    add x3, x3, :lo12:ws_io_size
    str xzr, [x3]
    mov x0, x19
    adrp x16, fn_easy_recv
    add x16, x16, :lo12:fn_easy_recv
    ldr x16, [x16]
    blr x16
    cbz w0, .raw_recv_progress
    cmp w0, #81
    b.ne .raw_recv_failure
.raw_recv_no_progress:
    add x23, x23, #1
    cmp x23, #400
    b.hs .raw_recv_failure
    adrp x5, ws_recv_budget
    add x5, x5, :lo12:ws_recv_budget
    ldr x6, [x5]
    cbz x6, .raw_recv_timeout
    sub x6, x6, #1
    str x6, [x5]
    bl native_ws_sleep
    b .raw_recv_loop
.raw_recv_progress:
    adrp x3, ws_io_size
    add x3, x3, :lo12:ws_io_size
    ldr x3, [x3]
    cbz x3, .raw_recv_no_progress
    mov x24, x3
    sub x25, x21, x22
    cmp x24, x25
    csel x26, x24, x25, lo
    adrp x0, ws_socket_buffer
    add x0, x0, :lo12:ws_socket_buffer
    mov x1, x26
    add x2, x20, x22
    bl native_copy_bytes
    add x22, x22, x26
    cmp x24, x26
    b.ls .raw_recv_store_done
    sub x27, x24, x26
    adrp x0, ws_socket_buffer
    add x0, x0, :lo12:ws_socket_buffer
    add x0, x0, x26
    mov x28, x0
    adrp x0, ws_pending_buffer
    add x0, x0, :lo12:ws_pending_buffer
    mov x2, x0
    mov x0, x28
    mov x1, x27
    bl native_copy_bytes
    adrp x0, ws_pending_length
    add x0, x0, :lo12:ws_pending_length
    str x27, [x0]
.raw_recv_store_done:
    mov x23, xzr
    b .raw_recv_loop
.raw_recv_success:
    mov w0, wzr
    b .raw_recv_return
.raw_recv_failure:
    mov w0, #1
    b .raw_recv_return
.raw_recv_timeout:
    mov w0, #2
.raw_recv_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

native_pending_take:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    adrp x1, ws_pending_length
    add x1, x1, :lo12:ws_pending_length
    ldr x2, [x1]
    cbz x2, .pending_take_none
    cmp x2, x20
    csel x3, x2, x20, lo
    adrp x0, ws_pending_buffer
    add x0, x0, :lo12:ws_pending_buffer
    mov x1, x3
    mov x2, x19
    bl native_copy_bytes
    adrp x4, ws_pending_length
    add x4, x4, :lo12:ws_pending_length
    ldr x5, [x4]
    sub x5, x5, x3
    cbz x5, .pending_take_clear
    adrp x0, ws_pending_buffer
    add x0, x0, :lo12:ws_pending_buffer
    add x1, x0, x3
    mov x2, x0
    mov x6, x5
.pending_shift_loop:
    cbz x6, .pending_shift_done
    ldrb w7, [x1], #1
    strb w7, [x2], #1
    sub x6, x6, #1
    b .pending_shift_loop
.pending_shift_done:
    str x5, [x4]
    mov x0, x3
    b .pending_take_return
.pending_take_clear:
    str xzr, [x4]
    mov x0, x3
    b .pending_take_return
.pending_take_none:
    mov x0, xzr
.pending_take_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

native_ws_build_upgrade:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    adrp x1, ws_http_request_length
    add x1, x1, :lo12:ws_http_request_length
    str xzr, [x1]
    bl native_make_ws_key
    cbnz w0, .ws_upgrade_build_failure
    adrp x0, ws_http_request
    add x0, x0, :lo12:ws_http_request
    adrp x1, http_get_prefix
    add x1, x1, :lo12:http_get_prefix
    bl native_append_cstr
    mov x1, x20
    bl native_append_cstr
    adrp x1, http_host_separator
    add x1, x1, :lo12:http_host_separator
    bl native_append_cstr
    mov x1, x19
    bl native_append_cstr
    adrp x1, http_upgrade_prefix
    add x1, x1, :lo12:http_upgrade_prefix
    bl native_append_cstr
    adrp x1, ws_key_base64
    add x1, x1, :lo12:ws_key_base64
    bl native_append_cstr
    adrp x1, http_end
    add x1, x1, :lo12:http_end
    bl native_append_cstr
    strb wzr, [x0]
    adrp x1, ws_http_request
    add x1, x1, :lo12:ws_http_request
    sub x0, x0, x1
    adrp x1, ws_http_request_length
    add x1, x1, :lo12:ws_http_request_length
    str x0, [x1]
    b .ws_upgrade_build_return
.ws_upgrade_build_failure:
    mov x0, xzr
.ws_upgrade_build_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

native_ws_build_upgrade_url:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x0, x19
    bl rt_validate_gateway_url
    cbnz w0, .ws_upgrade_url_failure
    mov x20, x19
    ldrb w0, [x20]
    cmp w0, #119
    b.ne .ws_upgrade_url_failure
    ldrb w0, [x20, #1]
    cmp w0, #115
    b.ne .ws_upgrade_url_failure
    ldrb w0, [x20, #2]
    cmp w0, #115
    b.eq .ws_upgrade_url_wss
    cmp w0, #58
    b.ne .ws_upgrade_url_failure
    ldrb w0, [x20, #3]
    cmp w0, #47
    b.ne .ws_upgrade_url_failure
    ldrb w0, [x20, #4]
    cmp w0, #47
    b.ne .ws_upgrade_url_failure
    add x20, x20, #5
    b .ws_upgrade_url_host
.ws_upgrade_url_wss:
    ldrb w0, [x20, #3]
    cmp w0, #58
    b.ne .ws_upgrade_url_failure
    ldrb w0, [x20, #4]
    cmp w0, #47
    b.ne .ws_upgrade_url_failure
    ldrb w0, [x20, #5]
    cmp w0, #47
    b.ne .ws_upgrade_url_failure
    add x20, x20, #6
.ws_upgrade_url_host:
    adrp x21, ws_url_host
    add x21, x21, :lo12:ws_url_host
    mov x22, xzr
.ws_upgrade_url_host_loop:
    cmp x22, #1023
    b.hs .ws_upgrade_url_failure
    ldrb w0, [x20, x22]
    cbz w0, .ws_upgrade_url_host_end
    cmp w0, #47
    b.eq .ws_upgrade_url_path
    cmp w0, #63
    b.eq .ws_upgrade_url_query
    strb w0, [x21, x22]
    add x22, x22, #1
    b .ws_upgrade_url_host_loop
.ws_upgrade_url_host_end:
    cbz x22, .ws_upgrade_url_failure
    strb wzr, [x21, x22]
    adrp x0, ws_url_host
    add x0, x0, :lo12:ws_url_host
    adrp x1, discord_ws_path
    add x1, x1, :lo12:discord_ws_path
    bl native_ws_build_upgrade
    b .ws_upgrade_url_return
.ws_upgrade_url_path:
    cbz x22, .ws_upgrade_url_failure
    strb wzr, [x21, x22]
    add x20, x20, x22
    adrp x23, ws_url_path
    add x23, x23, :lo12:ws_url_path
    mov w0, #47
    strb w0, [x23]
    mov x25, xzr
    mov x24, #1
.ws_upgrade_url_path_loop:
    cmp x24, #4095
    b.hs .ws_upgrade_url_failure
    ldrb w0, [x20, x24]
    strb w0, [x23, x24]
    cmp w0, #63
    b.ne .ws_upgrade_url_path_advance
    mov x25, #1
.ws_upgrade_url_path_advance:
    add x24, x24, #1
    cbnz w0, .ws_upgrade_url_path_loop
    cbnz x25, .ws_upgrade_url_build
    sub x24, x24, #1
    add x0, x23, x24
    adrp x1, discord_ws_query_suffix
    add x1, x1, :lo12:discord_ws_query_suffix
    bl native_append_cstr
    strb wzr, [x0]
    b .ws_upgrade_url_build
.ws_upgrade_url_query:
    cbz x22, .ws_upgrade_url_failure
    strb wzr, [x21, x22]
    add x20, x20, x22
    adrp x23, ws_url_path
    add x23, x23, :lo12:ws_url_path
    mov w0, #47
    strb w0, [x23]
    mov x24, #1
.ws_upgrade_url_query_loop:
    cmp x24, #4095
    b.hs .ws_upgrade_url_failure
    ldrb w0, [x20]
    strb w0, [x23, x24]
    add x20, x20, #1
    add x24, x24, #1
    cbnz w0, .ws_upgrade_url_query_loop
.ws_upgrade_url_build:
    adrp x0, ws_url_host
    add x0, x0, :lo12:ws_url_host
    adrp x1, ws_url_path
    add x1, x1, :lo12:ws_url_path
    bl native_ws_build_upgrade
    b .ws_upgrade_url_return
.ws_upgrade_url_failure:
    mov x0, xzr
.ws_upgrade_url_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

native_ws_http_upgrade:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    adrp x1, ws_pending_length
    add x1, x1, :lo12:ws_pending_length
    str xzr, [x1]
    adrp x1, ws_http_request
    add x1, x1, :lo12:ws_http_request
    adrp x2, ws_http_request_length
    add x2, x2, :lo12:ws_http_request_length
    ldr x2, [x2]
    cbz x2, .http_upgrade_failure
    mov x0, x19
    bl native_raw_send_all
    cbnz w0, .http_upgrade_failure
    adrp x20, ws_http_response
    add x20, x20, :lo12:ws_http_response
    mov x21, xzr
    mov x22, #2000
.http_upgrade_recv:
    mov x0, x19
    add x1, x20, x21
    mov x2, #4095
    sub x2, x2, x21
    adrp x3, ws_io_size
    add x3, x3, :lo12:ws_io_size
    str xzr, [x3]
    adrp x16, fn_easy_recv
    add x16, x16, :lo12:fn_easy_recv
    ldr x16, [x16]
    blr x16
    cbz w0, .http_upgrade_recv_data
    cmp w0, #81
    b.ne .http_upgrade_failure
    subs x22, x22, #1
    b.eq .http_upgrade_failure
    bl native_ws_sleep
    b .http_upgrade_recv
.http_upgrade_recv_data:
    adrp x3, ws_io_size
    add x3, x3, :lo12:ws_io_size
    ldr x3, [x3]
    cbz x3, .http_upgrade_recv
    add x21, x21, x3
    mov x0, x20
    mov x1, x21
    adrp x2, http_end
    add x2, x2, :lo12:http_end
    mov x3, #4
    bl native_bytes_find_pattern
    cbnz x0, .http_upgrade_headers_done
    cmp x21, #4095
    b.lo .http_upgrade_recv
    b .http_upgrade_failure
.http_upgrade_headers_done:
    sub x5, x0, x20
    add x5, x5, #4
    cmp x5, x21
    b.hs .http_upgrade_no_pending
    sub x6, x21, x5
    adrp x0, ws_http_response
    add x0, x0, :lo12:ws_http_response
    add x0, x0, x5
    mov x2, x0
    adrp x0, ws_pending_buffer
    add x0, x0, :lo12:ws_pending_buffer
    mov x1, x6
    bl native_copy_bytes
    adrp x1, ws_pending_length
    add x1, x1, :lo12:ws_pending_length
    str x6, [x1]
.http_upgrade_no_pending:
    cmp x21, #12
    b.lo .http_upgrade_failure
    mov x22, xzr
.http_upgrade_status_loop:
    cmp x22, #12
    b.hs .http_upgrade_status_done
    adrp x0, http_status_101
    add x0, x0, :lo12:http_status_101
    ldrb w1, [x20, x22]
    ldrb w2, [x0, x22]
    cmp w1, w2
    b.ne .http_upgrade_failure
    add x22, x22, #1
    b .http_upgrade_status_loop
.http_upgrade_status_done:
    cmp x21, #13
    b.lo .http_upgrade_failure
    ldrb w0, [x20, #12]
    cmp w0, #32
    b.ne .http_upgrade_failure
    mov x0, x20
    mov x1, x21
    bl native_ws_validate_accept
    cbnz w0, .http_upgrade_failure
    mov w0, wzr
    b .http_upgrade_return
.http_upgrade_failure:
    mov w0, #1
.http_upgrade_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

native_ws_validate_accept:
    stp x29, x30, [sp, #-96]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x0, x19
    mov x1, x20
    adrp x2, http_end
    add x2, x2, :lo12:http_end
    mov x3, #4
    bl native_bytes_find_pattern
    cbz x0, .ws_accept_failure
    mov x28, x0
    mov x0, x19
    mov x1, x20
    adrp x2, http_connection_header
    add x2, x2, :lo12:http_connection_header
    mov x3, #19
    bl native_bytes_find_pattern_ci
    cbz x0, .ws_accept_failure
    add x1, x0, #19
    cmp x1, x28
    b.hs .ws_accept_failure
    ldrb w2, [x1]
    cmp w2, #13
    b.eq .ws_accept_connection_boundary
    cmp w2, #10
    b.eq .ws_accept_connection_boundary
    cmp w2, #32
    b.eq .ws_accept_connection_boundary
    cmp w2, #9
    b.eq .ws_accept_connection_boundary
    cmp w2, #44
    b.ne .ws_accept_failure
.ws_accept_connection_boundary:
    sub x27, x0, x19
    cbz x27, .ws_accept_failure
    sub x27, x27, #1
    ldrb w1, [x19, x27]
    cmp w1, #10
    b.ne .ws_accept_failure
    cmp x0, x28
    b.hs .ws_accept_failure
    mov x0, x19
    mov x1, x20
    adrp x2, http_upgrade_header
    add x2, x2, :lo12:http_upgrade_header
    mov x3, #18
    bl native_bytes_find_pattern_ci
    cbz x0, .ws_accept_failure
    add x1, x0, #18
    cmp x1, x28
    b.hs .ws_accept_failure
    ldrb w2, [x1]
    cmp w2, #13
    b.eq .ws_accept_upgrade_boundary
    cmp w2, #10
    b.eq .ws_accept_upgrade_boundary
    cmp w2, #32
    b.eq .ws_accept_upgrade_boundary
    cmp w2, #9
    b.eq .ws_accept_upgrade_boundary
    cmp w2, #44
    b.ne .ws_accept_failure
.ws_accept_upgrade_boundary:
    sub x27, x0, x19
    cbz x27, .ws_accept_failure
    sub x27, x27, #1
    ldrb w1, [x19, x27]
    cmp w1, #10
    b.ne .ws_accept_failure
    cmp x0, x28
    b.hs .ws_accept_failure
    mov x0, x19
    mov x1, x20
    adrp x2, http_accept_header_prefix
    add x2, x2, :lo12:http_accept_header_prefix
    mov x3, #21
    bl native_bytes_find_pattern_ci
    cbz x0, .ws_accept_failure
    sub x27, x0, x19
    cbz x27, .ws_accept_failure
    sub x27, x27, #1
    ldrb w1, [x19, x27]
    cmp w1, #10
    b.ne .ws_accept_failure
    cmp x0, x28
    b.hs .ws_accept_failure
    add x21, x0, #21
    mov x22, x21
.ws_accept_value_space:
    cmp x22, x28
    b.hs .ws_accept_failure
    ldrb w0, [x22]
    cmp w0, #32
    b.eq .ws_accept_value_space_one
    cmp w0, #9
    b.ne .ws_accept_value_start
.ws_accept_value_space_one:
    add x22, x22, #1
    b .ws_accept_value_space
.ws_accept_value_start:
    mov x23, x22
.ws_accept_value_end:
    cmp x23, x28
    b.hs .ws_accept_failure
    ldrb w0, [x23]
    cmp w0, #13
    b.eq .ws_accept_value_trim
    cmp w0, #10
    b.eq .ws_accept_value_trim
    add x23, x23, #1
    b .ws_accept_value_end
.ws_accept_value_trim:
    sub x24, x23, x22
.ws_accept_trim_loop:
    cbz x24, .ws_accept_failure
    sub x25, x22, x24
    add x25, x25, x24
    sub x25, x23, #1
    ldrb w0, [x25]
    cmp w0, #32
    b.eq .ws_accept_trim_one
    cmp w0, #9
    b.ne .ws_accept_value_length
.ws_accept_trim_one:
    sub x23, x23, #1
    sub x24, x24, #1
    b .ws_accept_trim_loop
.ws_accept_value_length:
    cmp x24, #28
    b.ne .ws_accept_failure
    bl native_ws_compute_accept
    adrp x26, ws_accept_expected
    add x26, x26, :lo12:ws_accept_expected
    mov x27, xzr
.ws_accept_compare:
    cmp x27, #28
    b.hs .ws_accept_success
    ldrb w0, [x22, x27]
    ldrb w1, [x26, x27]
    cmp w0, w1
    b.ne .ws_accept_failure
    add x27, x27, #1
    b .ws_accept_compare
.ws_accept_success:
    mov w0, wzr
    b .ws_accept_return
.ws_accept_failure:
    mov w0, #1
.ws_accept_return:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret

native_ws_gateway:
    stp x29, x30, [sp, #-80]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    mov x29, sp
    mov x19, x0
    adrp x0, discord_ws_host
    add x0, x0, :lo12:discord_ws_host
    adrp x1, discord_ws_path
    add x1, x1, :lo12:discord_ws_path
    bl native_ws_build_upgrade
    adrp x0, discord_gateway_url
    add x0, x0, :lo12:discord_gateway_url
    bl native_ws_open_url
    cbz x0, .ws_gateway_failure
    mov x20, x0
    mov x0, x20
    bl native_ws_recv_message
    cbz x0, .ws_gateway_close_failure
    mov x21, x0
    mov x22, x1
    mov x0, x21
    mov x1, x22
    bl native_json_validate_structure
    cbnz w0, .ws_gateway_close_failure
    mov x0, x21
    mov x1, x22
    adrp x2, json_key_op
    add x2, x2, :lo12:json_key_op
    mov x3, #5
    bl native_json_find_root_number
    cmp x0, #10
    b.ne .ws_gateway_close_failure
    mov x0, x21
    mov x1, x22
    adrp x2, json_key_heartbeat_interval
    add x2, x2, :lo12:json_key_heartbeat_interval
    mov x3, #21
    bl native_json_find_number
    cmp x0, #0
    b.le .ws_gateway_default_heartbeat
    adrp x16, ws_heartbeat_interval
    add x16, x16, :lo12:ws_heartbeat_interval
    str x0, [x16]
    b .ws_gateway_identify
.ws_gateway_default_heartbeat:
    adrp x16, ws_heartbeat_interval
    add x16, x16, :lo12:ws_heartbeat_interval
    mov x0, #30000
    str x0, [x16]
.ws_gateway_identify:
    mov x0, x19
    bl native_ws_build_identify
    mov x2, x1
    mov x1, x0
    mov x0, x20
    bl native_ws_send_text
    cbnz w0, .ws_gateway_close_failure
    mov x0, x20
    bl native_ws_recv_message
    cbz x0, .ws_gateway_close_failure
    mov x21, x0
    mov x22, x1
    mov x0, x21
    mov x1, x22
    bl native_json_validate_structure
    cbnz w0, .ws_gateway_close_failure
    mov x0, x21
    mov x1, x22
    adrp x2, json_key_ready
    add x2, x2, :lo12:json_key_ready
    mov x3, #11
    bl native_json_find_root_pattern
    cbz x0, .ws_gateway_close_failure
    mov x0, x21
    mov x1, x22
    adrp x2, json_key_op
    add x2, x2, :lo12:json_key_op
    mov x3, #5
    bl native_json_find_root_number
    cmp x0, #0
    b.ne .ws_gateway_close_failure
    adrp x16, ws_sequence
    add x16, x16, :lo12:ws_sequence
    mov x0, x21
    mov x1, x22
    adrp x2, json_key_s
    add x2, x2, :lo12:json_key_s
    mov x3, #4
    bl native_json_find_root_number
    cmp x0, #0
    b.lt .ws_gateway_heartbeat
    str x0, [x16]
    adrp x0, ws_sequence_valid
    add x0, x0, :lo12:ws_sequence_valid
    mov w1, #1
    str w1, [x0]
.ws_gateway_heartbeat:
    bl native_ws_build_heartbeat
    mov x2, x1
    mov x1, x0
    mov x0, x20
    bl native_ws_send_text
    cbnz w0, .ws_gateway_close_failure
    mov x0, x20
    bl native_ws_recv_message
    cbz x0, .ws_gateway_success
    mov x21, x0
    mov x22, x1
    mov x0, x21
    mov x1, x22
    bl native_json_validate_structure
    cbnz w0, .ws_gateway_close_failure
    mov x0, x21
    mov x1, x22
    adrp x2, json_key_op
    add x2, x2, :lo12:json_key_op
    mov x3, #5
    bl native_json_find_root_number
    cmp x0, #11
    b.eq .ws_gateway_success
    cmp x0, #1
    b.eq .ws_gateway_success
    b .ws_gateway_success
.ws_gateway_close_failure:
    mov x0, x20
    bl native_ws_close
.ws_gateway_failure:
    adrp x16, ws_error_code
    add x16, x16, :lo12:ws_error_code
    ldr w0, [x16]
    cbnz w0, .ws_gateway_return
    adrp x16, ws_open_ok
    add x16, x16, :lo12:ws_open_ok
    ldr w0, [x16]
    cbz w0, .ws_gateway_failure_default
    mov w0, #100
    b .ws_gateway_return
.ws_gateway_failure_default:
    adrp x16, ws_stage
    add x16, x16, :lo12:ws_stage
    ldr w0, [x16]
    add w0, w0, #110
    b .ws_gateway_return
.ws_gateway_success:
    mov x0, x20
    bl native_ws_close
    mov w0, wzr
.ws_gateway_return:
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret

native_ws_pushbullet:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    adrp x0, ws_stream_url
    add x0, x0, :lo12:ws_stream_url
    adrp x1, pushbullet_stream_prefix
    add x1, x1, :lo12:pushbullet_stream_prefix
    bl native_append_cstr
    mov x1, x19
    bl native_append_cstr
    strb wzr, [x0]
    adrp x0, ws_http_path
    add x0, x0, :lo12:ws_http_path
    adrp x1, pushbullet_ws_path_prefix
    add x1, x1, :lo12:pushbullet_ws_path_prefix
    bl native_append_cstr
    mov x1, x19
    bl native_append_cstr
    strb wzr, [x0]
    adrp x0, pushbullet_ws_host
    add x0, x0, :lo12:pushbullet_ws_host
    adrp x1, ws_http_path
    add x1, x1, :lo12:ws_http_path
    bl native_ws_build_upgrade
    adrp x0, ws_stream_url
    add x0, x0, :lo12:ws_stream_url
    bl native_ws_open_url
    cbz x0, .ws_push_failure
    mov x20, x0
    mov x0, x20
    bl native_ws_recv_message
    cbz x0, .ws_push_success
    mov x21, x0
    mov x22, x1
    mov x0, x21
    mov x1, x22
    bl native_json_validate_structure
    cbnz w0, .ws_push_close_failure
    mov x0, x21
    mov x1, x22
    adrp x2, json_key_type_tickle
    add x2, x2, :lo12:json_key_type_tickle
    mov x3, #15
    bl native_json_find_root_pattern
    cbnz x0, .ws_push_poll
    mov x0, x21
    mov x1, x22
    adrp x2, json_key_type_tickle_space
    add x2, x2, :lo12:json_key_type_tickle_space
    mov x3, #16
    bl native_json_find_root_pattern
    cbnz x0, .ws_push_poll
    mov x0, x21
    mov x1, x22
    adrp x2, json_key_type_push
    add x2, x2, :lo12:json_key_type_push
    mov x3, #13
    bl native_json_find_root_pattern
    cbnz x0, .ws_push_poll
    mov x0, x21
    mov x1, x22
    adrp x2, json_key_type_push_space
    add x2, x2, :lo12:json_key_type_push_space
    mov x3, #14
    bl native_json_find_root_pattern
    cbz x0, .ws_push_success
.ws_push_poll:
    mov x0, x19
    bl native_pushbullet_poll
    cbnz w0, .ws_push_close_failure
.ws_push_success:
    mov x0, x20
    bl native_ws_close
    mov w0, wzr
    b .ws_push_return
.ws_push_close_failure:
    mov x0, x20
    bl native_ws_close
.ws_push_failure:
    mov w0, #1
.ws_push_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

native_pushbullet_poll:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x29, sp
    mov x19, x0
    adrp x2, ws_poll_has_pushes
    add x2, x2, :lo12:ws_poll_has_pushes
    str wzr, [x2]
    adrp x0, ws_poll_url
    add x0, x0, :lo12:ws_poll_url
    adrp x20, rt_service_cursor
    add x20, x20, :lo12:rt_service_cursor
    ldrb w1, [x20]
    cbnz w1, .push_poll_page_cursor
    adrp x1, pushbullet_poll_prefix
    add x1, x1, :lo12:pushbullet_poll_prefix
    bl native_append_cstr
    strb wzr, [x0]
    adrp x1, ws_cursor
    add x1, x1, :lo12:ws_cursor
    ldr x0, [x1]
    adrp x1, ws_decimal
    add x1, x1, :lo12:ws_decimal
    bl native_scaled_u64_to_ascii
    adrp x0, ws_poll_url
    add x0, x0, :lo12:ws_poll_url
    bl native_cstr_length
    mov x2, x0
    adrp x0, ws_poll_url
    add x0, x0, :lo12:ws_poll_url
    add x0, x0, x2
    adrp x1, ws_decimal
    add x1, x1, :lo12:ws_decimal
    bl native_append_cstr
    b .push_poll_append_limit
.push_poll_page_cursor:
    adrp x1, pushbullet_poll_cursor_prefix
    add x1, x1, :lo12:pushbullet_poll_cursor_prefix
    bl native_append_cstr
    mov x1, x20
    bl native_append_cstr
    strb wzr, [x0]
.push_poll_append_limit:
    adrp x0, ws_poll_url
    add x0, x0, :lo12:ws_poll_url
    bl native_cstr_length
    mov x2, x0
    adrp x0, ws_poll_url
    add x0, x0, :lo12:ws_poll_url
    add x0, x0, x2
    adrp x1, pushbullet_poll_suffix
    add x1, x1, :lo12:pushbullet_poll_suffix
    bl native_append_cstr
    strb wzr, [x0]
    adrp x0, ws_poll_url
    add x0, x0, :lo12:ws_poll_url
    mov x1, x19
    adrp x2, pushbullet_header_prefix
    add x2, x2, :lo12:pushbullet_header_prefix
    adrp x3, ws_json_buffer
    add x3, x3, :lo12:ws_json_buffer
    mov x4, #65535
    bl native_curl_get_capture
    mov w21, w0
    cbnz w21, .push_poll_return
    adrp x0, rest_status
    add x0, x0, :lo12:rest_status
    ldr w0, [x0]
    cmp w0, #200
    b.lo .push_poll_http_failure
    cmp w0, #300
    b.hs .push_poll_http_failure
    adrp x0, capture_length
    add x0, x0, :lo12:capture_length
    ldr x0, [x0]
    adrp x1, ws_json_length
    add x1, x1, :lo12:ws_json_length
    str x0, [x1]
    adrp x1, ws_json_buffer
    add x1, x1, :lo12:ws_json_buffer
    strb wzr, [x1, x0]
.push_poll_success:
    mov w21, wzr
    b .push_poll_return
.push_poll_http_failure:
    mov w21, #1
.push_poll_return:
    mov w0, w21
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

native_ws_build_identify:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    adrp x20, ws_identify
    add x20, x20, :lo12:ws_identify
    mov x0, x20
    adrp x1, json_identify_prefix
    add x1, x1, :lo12:json_identify_prefix
    bl native_append_cstr
    mov x1, x19
    bl native_append_cstr
    adrp x1, json_identify_mid
    add x1, x1, :lo12:json_identify_mid
    bl native_append_cstr
    adrp x1, ws_identify_intents
    add x1, x1, :lo12:ws_identify_intents
    ldr x0, [x1]
    cbnz x0, .identify_intents_ready
    mov x0, #1
    str x0, [x1]
.identify_intents_ready:
    adrp x1, ws_decimal
    add x1, x1, :lo12:ws_decimal
    bl native_u64_to_ascii
    adrp x1, ws_identify
    add x1, x1, :lo12:ws_identify
    mov x0, x1
    bl native_cstr_length
    adrp x1, ws_identify
    add x1, x1, :lo12:ws_identify
    add x0, x1, x0
    adrp x1, ws_decimal
    add x1, x1, :lo12:ws_decimal
    bl native_append_cstr
    adrp x1, json_identify_suffix
    add x1, x1, :lo12:json_identify_suffix
    bl native_append_cstr
    strb wzr, [x0]
    sub x1, x0, x20
    mov x0, x20
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

native_ws_build_heartbeat:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    adrp x19, ws_json_buffer
    add x19, x19, :lo12:ws_json_buffer
    mov x0, x19
    adrp x1, json_heartbeat_prefix
    add x1, x1, :lo12:json_heartbeat_prefix
    bl native_append_cstr
    adrp x1, ws_sequence_valid
    add x1, x1, :lo12:ws_sequence_valid
    ldr w1, [x1]
    cbz w1, .heartbeat_null
    mov x20, x0
    adrp x1, ws_sequence
    add x1, x1, :lo12:ws_sequence
    ldr x0, [x1]
    adrp x1, ws_decimal
    add x1, x1, :lo12:ws_decimal
    bl native_u64_to_ascii
    mov x0, x20
    adrp x1, ws_decimal
    add x1, x1, :lo12:ws_decimal
    bl native_append_cstr
    adrp x1, json_heartbeat_suffix
    add x1, x1, :lo12:json_heartbeat_suffix
    bl native_append_cstr
    b .heartbeat_done
.heartbeat_null:
    adrp x1, json_heartbeat_null
    add x1, x1, :lo12:json_heartbeat_null
    bl native_append_cstr
    adrp x1, json_heartbeat_suffix
    add x1, x1, :lo12:json_heartbeat_suffix
    bl native_append_cstr
.heartbeat_done:
    strb wzr, [x0]
    sub x1, x0, x19
    mov x0, x19
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

native_append_cstr:
.append_loop:
    ldrb w2, [x1], #1
    cbz w2, .append_done
    strb w2, [x0], #1
    b .append_loop
.append_done:
    ret

native_cstr_length:
    mov x1, x0
.length_loop:
    ldrb w2, [x1], #1
    cbnz w2, .length_loop
    sub x0, x1, x0
    sub x0, x0, #1
    ret

native_event_queue_push:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x4, #131068
    cmp x1, x4
    b.hi .queue_push_failure
    mov x3, x0
    adrp x2, event_queue
    add x2, x2, :lo12:event_queue
    str w1, [x2]
    add x0, x3, #0
    mov x3, x1
    add x2, x2, #4
    mov x1, x3
    bl native_copy_bytes
    adrp x2, event_queue_length
    add x2, x2, :lo12:event_queue_length
    add x1, x1, #4
    str x1, [x2]
    mov w0, wzr
    b .queue_push_done
.queue_push_failure:
    mov w0, #1
    ldp x29, x30, [sp], #16
    ret
.queue_push_done:
    ldp x29, x30, [sp], #16
    ret

native_event_queue_pop:
    adrp x2, event_queue
    add x2, x2, :lo12:event_queue
    ldr w1, [x2]
    add x0, x2, #4
    ret

native_copy_bytes:
    mov x3, xzr
.copy_bytes_loop:
    cmp x3, x1
    b.hs .copy_bytes_done
    ldrb w4, [x0, x3]
    strb w4, [x2, x3]
    add x3, x3, #1
    b .copy_bytes_loop
.copy_bytes_done:
    ret

native_json_find_pattern:
    stp x29, x30, [sp, #-96]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, xzr
    mov x25, xzr
    mov x26, xzr
    mov x27, xzr
    cbz x22, .json_pattern_no
    adrp x28, ws_json_structure_stack
    add x28, x28, :lo12:ws_json_structure_stack
.json_pattern_outer:
    cmp x23, x20
    b.hs .json_pattern_no
    ldrb w0, [x19, x23]
    cbnz x25, .json_pattern_string
    mov x24, xzr
    sub x1, x20, x23
    cmp x1, x22
    b.lo .json_pattern_structural
.json_pattern_compare:
    cmp x24, x22
    b.hs .json_pattern_yes
    add x1, x23, x24
    ldrb w2, [x19, x1]
    ldrb w3, [x21, x24]
    cmp w2, w3
    b.ne .json_pattern_structural
    add x24, x24, #1
    b .json_pattern_compare
.json_pattern_structural:
    cmp w0, #123
    b.eq .json_pattern_open
    cmp w0, #91
    b.eq .json_pattern_open
    cmp w0, #125
    b.eq .json_pattern_close
    cmp w0, #93
    b.eq .json_pattern_close
    cmp w0, #34
    b.eq .json_pattern_string_start
    add x23, x23, #1
    b .json_pattern_outer
.json_pattern_string_start:
    mov x25, #1
    mov x26, xzr
    add x23, x23, #1
    b .json_pattern_outer
.json_pattern_string:
    cbnz x26, .json_pattern_string_escaped
    cmp w0, #92
    b.eq .json_pattern_string_escape
    cmp w0, #34
    b.eq .json_pattern_string_closed
    add x23, x23, #1
    b .json_pattern_outer
.json_pattern_escape:
.json_pattern_string_escape:
    mov x26, #1
    add x23, x23, #1
    b .json_pattern_outer
.json_pattern_string_escaped:
    mov x26, xzr
    add x23, x23, #1
    b .json_pattern_outer
.json_pattern_string_closed:
    mov x25, xzr
    add x23, x23, #1
    b .json_pattern_outer
.json_pattern_open:
    cmp x27, #255
    b.hs .json_pattern_no
    strb w0, [x28, x27]
    add x27, x27, #1
    add x23, x23, #1
    b .json_pattern_outer
.json_pattern_close:
    cbz x27, .json_pattern_no
    sub x24, x27, #1
    ldrb w1, [x28, x24]
    cmp w0, #125
    b.ne .json_pattern_close_bracket
    cmp w1, #123
    b.ne .json_pattern_no
    b .json_pattern_close_pop
.json_pattern_close_bracket:
    cmp w1, #91
    b.ne .json_pattern_no
.json_pattern_close_pop:
    sub x27, x27, #1
    add x23, x23, #1
    b .json_pattern_outer
.json_pattern_yes:
    add x0, x19, x23
    b .json_pattern_return
.json_pattern_no:
    mov x0, xzr
.json_pattern_return:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret

native_json_find_root_pattern:
    stp x29, x30, [sp, #-112]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    stp x16, x17, [sp, #96]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, xzr
    mov x24, xzr
    mov x25, xzr
    mov x28, xzr
    cbz x22, .json_root_pattern_no
    adrp x26, ws_json_structure_stack
    add x26, x26, :lo12:ws_json_structure_stack
.json_root_pattern_loop:
    cmp x23, x20
    b.hs .json_root_pattern_no
    ldrb w0, [x19, x23]
    cbnz x25, .json_root_pattern_string
    cmp w0, #32
    b.eq .json_root_pattern_next
    cmp w0, #9
    b.eq .json_root_pattern_next
    cmp w0, #10
    b.eq .json_root_pattern_next
    cmp w0, #13
    b.eq .json_root_pattern_next
    cbz x24, .json_root_pattern_outside
    cmp x24, #1
    b.ne .json_root_pattern_structural
    cmp w0, #34
    b.ne .json_root_pattern_structural
    sub x27, x20, x23
    cmp x27, x22
    b.lo .json_root_pattern_string_start
    mov x27, xzr
.json_root_pattern_compare:
    cmp x27, x22
    b.hs .json_root_pattern_boundary
    add x0, x23, x27
    ldrb w1, [x19, x0]
    ldrb w2, [x21, x27]
    cmp w1, w2
    b.ne .json_root_pattern_string_start
    add x27, x27, #1
    b .json_root_pattern_compare
.json_root_pattern_boundary:
    sub x27, x22, #1
    ldrb w1, [x21, x27]
    cmp w1, #58
    b.eq .json_root_pattern_yes
    add x27, x23, x22
    cmp x27, x20
    b.hs .json_root_pattern_yes
    ldrb w1, [x19, x27]
    cmp w1, #32
    b.eq .json_root_pattern_yes
    cmp w1, #9
    b.eq .json_root_pattern_yes
    cmp w1, #10
    b.eq .json_root_pattern_yes
    cmp w1, #13
    b.eq .json_root_pattern_yes
    cmp w1, #58
    b.eq .json_root_pattern_yes
    cmp w1, #44
    b.eq .json_root_pattern_yes
    cmp w1, #125
    b.eq .json_root_pattern_yes
    cmp w1, #93
    b.eq .json_root_pattern_yes
    b .json_root_pattern_string_start
.json_root_pattern_outside:
    cbnz x28, .json_root_pattern_no
    cmp w0, #123
    b.eq .json_root_pattern_open
    b .json_root_pattern_no
.json_root_pattern_structural:
    cmp w0, #34
    b.eq .json_root_pattern_string_start
    cmp w0, #123
    b.eq .json_root_pattern_open
    cmp w0, #91
    b.eq .json_root_pattern_open
    cmp w0, #125
    b.eq .json_root_pattern_close
    cmp w0, #93
    b.eq .json_root_pattern_close
    b .json_root_pattern_next
.json_root_pattern_string_start:
    mov x25, #1
    add x23, x23, #1
    b .json_root_pattern_loop
.json_root_pattern_string:
    cmp w0, #92
    b.eq .json_root_pattern_escape
    cmp w0, #34
    b.eq .json_root_pattern_string_end
    add x23, x23, #1
    b .json_root_pattern_loop
.json_root_pattern_escape:
    add x23, x23, #2
    b .json_root_pattern_loop
.json_root_pattern_string_end:
    mov x25, xzr
    add x23, x23, #1
    b .json_root_pattern_loop
.json_root_pattern_open:
    cmp x24, #255
    b.hs .json_root_pattern_no
    strb w0, [x26, x24]
    add x24, x24, #1
    add x23, x23, #1
    b .json_root_pattern_loop
.json_root_pattern_close:
    cbz x24, .json_root_pattern_no
    sub x27, x24, #1
    ldrb w1, [x26, x27]
    cmp w0, #125
    b.ne .json_root_pattern_close_bracket
    cmp w1, #123
    b.ne .json_root_pattern_no
    b .json_root_pattern_close_pop
.json_root_pattern_close_bracket:
    cmp w1, #91
    b.ne .json_root_pattern_no
.json_root_pattern_close_pop:
    sub x24, x24, #1
    cbnz x24, .json_root_pattern_next
    mov x28, #1
.json_root_pattern_next:
    add x23, x23, #1
    b .json_root_pattern_loop
.json_root_pattern_yes:
    add x0, x19, x23
    b .json_root_pattern_return
.json_root_pattern_no:
    mov x0, xzr
.json_root_pattern_return:
    ldp x16, x17, [sp, #96]
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #112
    ret

native_json_validate_structure:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x0, #65535
    cmp x20, x0
    b.hi .json_validate_fail
    adrp x23, rt_json_buffer
    add x23, x23, :lo12:rt_json_buffer
    mov x22, xzr
.json_validate_copy:
    cmp x22, x20
    b.hs .json_validate_copy_done
    ldrb w0, [x19, x22]
    strb w0, [x23, x22]
    add x22, x22, #1
    b .json_validate_copy
.json_validate_copy_done:
    strb wzr, [x23, x20]
    adrp x24, rt_json_length
    add x24, x24, :lo12:rt_json_length
    str x20, [x24]
    bl rt_json_validate_structure
    b .json_validate_return
.json_validate_fail:
    mov w0, #1
.json_validate_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

native_bytes_find_pattern:
    mov x4, xzr
.bytes_pattern_outer:
    cmp x4, x1
    b.hs .bytes_pattern_no
    sub x5, x1, x4
    cmp x5, x3
    b.lo .bytes_pattern_no
    mov x6, xzr
.bytes_pattern_inner:
    cmp x6, x3
    b.hs .bytes_pattern_yes
    add x9, x0, x4
    ldrb w7, [x9, x6]
    ldrb w8, [x2, x6]
    cmp w7, w8
    b.ne .bytes_pattern_next
    add x6, x6, #1
    b .bytes_pattern_inner
.bytes_pattern_next:
    add x4, x4, #1
    b .bytes_pattern_outer
.bytes_pattern_yes:
    add x0, x0, x4
    ret
.bytes_pattern_no:
    mov x0, xzr
    ret

native_bytes_find_pattern_ci:
    mov x4, xzr
.bytes_pattern_ci_outer:
    cmp x4, x1
    b.hs .bytes_pattern_ci_no
    sub x5, x1, x4
    cmp x5, x3
    b.lo .bytes_pattern_ci_no
    mov x6, xzr
.bytes_pattern_ci_inner:
    cmp x6, x3
    b.hs .bytes_pattern_ci_yes
    add x9, x0, x4
    ldrb w7, [x9, x6]
    ldrb w8, [x2, x6]
    cmp w7, #65
    b.lo .bytes_pattern_ci_hay_ready
    cmp w7, #90
    b.hi .bytes_pattern_ci_hay_ready
    add w7, w7, #32
.bytes_pattern_ci_hay_ready:
    cmp w8, #65
    b.lo .bytes_pattern_ci_pattern_ready
    cmp w8, #90
    b.hi .bytes_pattern_ci_pattern_ready
    add w8, w8, #32
.bytes_pattern_ci_pattern_ready:
    cmp w7, w8
    b.ne .bytes_pattern_ci_next
    add x6, x6, #1
    b .bytes_pattern_ci_inner
.bytes_pattern_ci_next:
    add x4, x4, #1
    b .bytes_pattern_ci_outer
.bytes_pattern_ci_yes:
    add x0, x0, x4
    ret
.bytes_pattern_ci_no:
    mov x0, xzr
    ret

native_json_find_number:
    mov x4, xzr
    b .native_json_find_number_entry
native_json_find_root_number:
    mov x4, #1
.native_json_find_number_entry:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x3
    mov x24, x4
    cbz x24, .find_number_pattern_general
    bl native_json_find_root_pattern
    b .find_number_pattern_done
.find_number_pattern_general:
    bl native_json_find_pattern
.find_number_pattern_done:
    cbz x0, .find_number_failure
    sub x0, x0, x19
    add x0, x0, x21
    cmp x0, x20
    b.hs .find_number_failure
    add x1, x19, x0
    mov x2, xzr
    mov x3, #10
    mov x7, xzr
.find_number_space:
    cmp x0, x20
    b.hs .find_number_failure
    ldrb w4, [x1]
    cmp w4, #32
    b.eq .find_number_space_one
    cmp w4, #9
    b.eq .find_number_space_one
    cmp w4, #10
    b.eq .find_number_space_one
    cmp w4, #13
    b.ne .find_number_loop
.find_number_space_one:
    add x0, x0, #1
    add x1, x1, #1
    b .find_number_space
.find_number_loop:
    cmp x0, x20
    b.hs .find_number_done
    ldrb w4, [x1], #1
    cmp w4, #48
    b.lo .find_number_non_digit
    cmp w4, #57
    b.hi .find_number_non_digit
    sub w4, w4, #48
    mul x5, x2, x3
    umulh x6, x2, x3
    cbnz x6, .find_number_failure
    add x5, x5, x4
    cmp x5, x2
    b.lo .find_number_failure
    mov x2, x5
    add x7, x7, #1
    add x0, x0, #1
    b .find_number_loop
.find_number_non_digit:
    cbz x7, .find_number_failure
    cmp w4, #32
    b.eq .find_number_trailing_space
    cmp w4, #9
    b.eq .find_number_trailing_space
    cmp w4, #10
    b.eq .find_number_trailing_space
    cmp w4, #13
    b.eq .find_number_trailing_space
    cmp w4, #44
    b.eq .find_number_done
    cmp w4, #125
    b.eq .find_number_done
    cmp w4, #93
    b.eq .find_number_done
    b .find_number_failure
.find_number_trailing_space:
    cmp x0, x20
    b.hs .find_number_done
    ldrb w4, [x1], #1
    add x0, x0, #1
    cmp w4, #32
    b.eq .find_number_trailing_space
    cmp w4, #9
    b.eq .find_number_trailing_space
    cmp w4, #10
    b.eq .find_number_trailing_space
    cmp w4, #13
    b.eq .find_number_trailing_space
    cmp w4, #44
    b.eq .find_number_done
    cmp w4, #125
    b.eq .find_number_done
    cmp w4, #93
    b.eq .find_number_done
    b .find_number_failure
.find_number_done:
    mov x0, x2
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x29, x30, [sp], #64
    ret
.find_number_failure:
    mov x0, #-1
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x29, x30, [sp], #64
    ret

native_parse_decimal_scaled:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    bl native_cstr_length
    mov x1, x0
    mov x0, x19
    bl native_parse_decimal_scaled_span
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

native_json_find_decimal_scaled:
    mov x4, xzr
    b .native_json_find_decimal_scaled_entry
native_json_find_root_decimal_scaled:
    mov x4, #1
.native_json_find_decimal_scaled_entry:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x24, x4
    cbnz x24, .native_json_find_decimal_scaled_root
    bl native_json_find_pattern
    b .native_json_find_decimal_scaled_found
.native_json_find_decimal_scaled_root:
    bl native_json_find_root_pattern
.native_json_find_decimal_scaled_found:
    cbz x0, .native_json_find_decimal_scaled_failure
    add x0, x0, x22
    sub x23, x0, x19
    sub x1, x20, x23
    bl native_parse_decimal_scaled_span
    b .native_json_find_decimal_scaled_return
.native_json_find_decimal_scaled_failure:
    mov x0, #-1
.native_json_find_decimal_scaled_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

native_parse_decimal_scaled_span:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, xzr
    mov x22, xzr
    mov x23, xzr
    mov x24, xzr
    mov x25, #10
.scaled_span_leading_space:
    cmp x21, x20
    b.hs .scaled_span_failure
    ldrb w0, [x19, x21]
    cmp w0, #32
    b.eq .scaled_span_leading_one
    cmp w0, #9
    b.eq .scaled_span_leading_one
    cmp w0, #10
    b.eq .scaled_span_leading_one
    cmp w0, #13
    b.ne .scaled_span_integer
.scaled_span_leading_one:
    add x21, x21, #1
    b .scaled_span_leading_space
.scaled_span_integer:
    mov x26, xzr
.scaled_span_integer_loop:
    cmp x21, x20
    b.hs .scaled_span_integer_done
    ldrb w0, [x19, x21]
    cmp w0, #48
    b.lo .scaled_span_integer_done
    cmp w0, #57
    b.hi .scaled_span_integer_done
    sub w0, w0, #48
    mov x1, #0x9999
    movk x1, #0x9999, lsl #16
    movk x1, #0x9999, lsl #32
    movk x1, #0x1999, lsl #48
    cmp x22, x1
    b.hi .scaled_span_failure
    b.lo .scaled_span_integer_step
    cmp w0, #5
    b.hi .scaled_span_failure
.scaled_span_integer_step:
    madd x22, x22, x25, x0
    add x21, x21, #1
    add x26, x26, #1
    b .scaled_span_integer_loop
.scaled_span_integer_done:
    cbz x26, .scaled_span_failure
    cmp w0, #46
    b.ne .scaled_span_scale
    add x21, x21, #1
    mov x23, xzr
    mov x24, xzr
.scaled_span_fraction_loop:
    cmp x21, x20
    b.hs .scaled_span_fraction_done
    ldrb w0, [x19, x21]
    cmp w0, #48
    b.lo .scaled_span_fraction_done
    cmp w0, #57
    b.hi .scaled_span_fraction_done
    cmp x24, #6
    b.hs .scaled_span_failure
    sub w0, w0, #48
    madd x23, x23, x25, x0
    add x21, x21, #1
    add x24, x24, #1
    b .scaled_span_fraction_loop
.scaled_span_fraction_done:
    cbz x24, .scaled_span_failure
.scaled_span_scale:
    mov x4, #0x4240
    movk x4, #0xf, lsl #16
    umulh x5, x22, x4
    cbnz x5, .scaled_span_failure
    mul x22, x22, x4
    mov x4, #10
.scaled_span_fraction_scale:
    cmp x24, #6
    b.hs .scaled_span_add_fraction
    mul x23, x23, x4
    add x24, x24, #1
    b .scaled_span_fraction_scale
.scaled_span_add_fraction:
    adds x22, x22, x23
    b.cs .scaled_span_failure
.scaled_span_trailing:
    cmp x21, x20
    b.eq .scaled_span_done
    ldrb w0, [x19, x21]
    cmp w0, #32
    b.eq .scaled_span_trailing_one
    cmp w0, #9
    b.eq .scaled_span_trailing_one
    cmp w0, #10
    b.eq .scaled_span_trailing_one
    cmp w0, #13
    b.eq .scaled_span_trailing_one
    cmp w0, #44
    b.eq .scaled_span_done
    cmp w0, #125
    b.eq .scaled_span_done
    cmp w0, #93
    b.eq .scaled_span_done
    b .scaled_span_failure
.scaled_span_trailing_one:
    add x21, x21, #1
    b .scaled_span_trailing
.scaled_span_done:
    mov x0, x22
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
.scaled_span_failure:
    mov x0, #-1
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

native_ws_sleep:
    adrp x0, ws_sleep_timespec_value
    add x0, x0, :lo12:ws_sleep_timespec_value
    mov x1, xzr
    mov x8, #101
    svc #0
    ret

native_u64_to_ascii:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    adrp x2, ws_decimal_tmp
    add x2, x2, :lo12:ws_decimal_tmp
    mov x3, xzr
    cbnz x19, .u64_digits
    mov w4, #48
    strb w4, [x2]
    mov x3, #1
    b .u64_reverse
.u64_digits:
    mov x5, #10
.u64_digit_loop:
    udiv x6, x19, x5
    msub x7, x6, x5, x19
    add w7, w7, #48
    strb w7, [x2, x3]
    add x3, x3, #1
    mov x19, x6
    cbnz x19, .u64_digit_loop
.u64_reverse:
    mov x4, xzr
.u64_reverse_loop:
    cmp x4, x3
    b.hs .u64_done
    sub x5, x3, x4
    sub x5, x5, #1
    ldrb w6, [x2, x5]
    strb w6, [x20, x4]
    add x4, x4, #1
    b .u64_reverse_loop
.u64_done:
    strb wzr, [x20, x3]
    mov x0, x3
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

native_scaled_u64_to_ascii:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x4, #0x4240
    movk x4, #0xf, lsl #16
    udiv x0, x19, x4
    msub x21, x0, x4, x19
    mov x1, x20
    bl native_u64_to_ascii
    mov x22, x0
    cbz x21, .scaled_ascii_done
    mov w0, #46
    strb w0, [x20, x22]
    mov x23, x22
    add x22, x22, #1
    mov x24, #0x86a0
    movk x24, #1, lsl #16
    mov x4, #10
.scaled_ascii_fraction_loop:
    udiv x0, x21, x24
    msub x21, x0, x24, x21
    add w0, w0, #48
    strb w0, [x20, x22]
    add x22, x22, #1
    udiv x24, x24, x4
    cbnz x24, .scaled_ascii_fraction_loop
    sub x5, x22, #1
.scaled_ascii_trim_loop:
    cmp x5, x23
    b.ls .scaled_ascii_trim_dot
    ldrb w6, [x20, x5]
    cmp w6, #48
    b.ne .scaled_ascii_trim_done
    sub x5, x5, #1
    b .scaled_ascii_trim_loop
.scaled_ascii_trim_dot:
    cmp x5, x23
    b.ne .scaled_ascii_trim_done
    mov x22, x23
    b .scaled_ascii_finish
.scaled_ascii_trim_done:
    add x22, x5, #1
.scaled_ascii_finish:
    strb wzr, [x20, x22]
.scaled_ascii_done:
    mov x0, x22
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

yul_native_network_rest_json:
    stp x29, x30, [sp, #-96]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, x4
    mov x24, x5
    mov x25, x6
    adrp x16, capture_buffer
    add x16, x16, :lo12:capture_buffer
    str x24, [x16]
    adrp x16, capture_capacity
    add x16, x16, :lo12:capture_capacity
    str x25, [x16]
    mov x25, x7
    adrp x16, capture_length
    add x16, x16, :lo12:capture_length
    str xzr, [x16]
    adrp x16, capture_overflow
    add x16, x16, :lo12:capture_overflow
    str wzr, [x16]
    adrp x16, capture_enabled
    add x16, x16, :lo12:capture_enabled
    mov w0, #1
    str w0, [x16]
    adrp x16, rest_status
    add x16, x16, :lo12:rest_status
    str wzr, [x16]
    adrp x16, rest_error_code
    add x16, x16, :lo12:rest_error_code
    str wzr, [x16]
    mov w28, #1
    adrp x16, fn_easy_init
    add x16, x16, :lo12:fn_easy_init
    ldr x16, [x16]
    blr x16
    mov x26, x0
    cbz x26, .rest_failure
    mov x0, x26
    mov x1, #10002
    mov x2, x19
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .rest_cleanup
    mov x0, x26
    mov x1, #10036
    mov x2, x20
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .rest_cleanup
    mov x0, x26
    mov x1, #10018
    adrp x2, user_agent
    add x2, x2, :lo12:user_agent
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .rest_cleanup
    mov x0, x26
    mov x1, #20011
    adrp x2, native_curl_capture
    add x2, x2, :lo12:native_curl_capture
    adrp x3, capture_context
    add x3, x3, :lo12:capture_context
    ldr x3, [x3]
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .rest_cleanup
    mov x0, x26
    mov x1, #10001
    adrp x2, capture_context
    add x2, x2, :lo12:capture_context
    mov x2, xzr
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .rest_cleanup
    mov x0, x26
    mov x1, #45
    mov x2, xzr
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .rest_cleanup
    mov x0, x26
    mov x1, #64
    mov x2, #1
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .rest_cleanup
    mov x0, x26
    mov x1, #81
    mov x2, #2
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .rest_cleanup
    mov x0, x26
    mov x1, #155
    mov x2, x25
    cbnz x2, .rest_timeout_ready
    mov x2, #20000
.rest_timeout_ready:
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .rest_cleanup
    adrp x0, network_header
    add x0, x0, :lo12:network_header
    adrp x1, discord_header_prefix
    add x1, x1, :lo12:discord_header_prefix
    mov x2, x21
    bl native_build_header
    mov x19, x0
    adrp x0, network_header2
    add x0, x0, :lo12:network_header2
    adrp x1, content_type_header
    add x1, x1, :lo12:content_type_header
    bl native_copy_cstr_network
    mov x0, xzr
    adrp x1, network_header
    add x1, x1, :lo12:network_header
    adrp x16, fn_slist_append
    add x16, x16, :lo12:fn_slist_append
    ldr x16, [x16]
    blr x16
    mov x27, x0
    cbz x27, .rest_cleanup
    mov x0, x27
    adrp x1, network_header2
    add x1, x1, :lo12:network_header2
    adrp x16, fn_slist_append
    add x16, x16, :lo12:fn_slist_append
    ldr x16, [x16]
    blr x16
    mov x27, x0
    cbz x27, .rest_free_headers
    mov x0, x26
    mov x1, #10023
    mov x2, x27
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .rest_free_headers
    cbz x23, .rest_perform
    mov x0, x26
    mov x1, #10015
    mov x2, x22
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .rest_free_headers
    mov x0, x26
    mov x1, #60
    mov x2, x23
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .rest_free_headers
.rest_perform:
    mov x0, x26
    adrp x16, fn_easy_perform
    add x16, x16, :lo12:fn_easy_perform
    ldr x16, [x16]
    blr x16
    mov w28, w0
    adrp x16, rest_error_code
    add x16, x16, :lo12:rest_error_code
    str w28, [x16]
    cbnz w28, .rest_free_headers
    mov x0, x26
    mov w1, #2
    movk w1, #0x20, lsl #16
    adrp x2, rest_status
    add x2, x2, :lo12:rest_status
    adrp x16, fn_easy_getinfo
    add x16, x16, :lo12:fn_easy_getinfo
    ldr x16, [x16]
    blr x16
    mov w28, w0
    adrp x16, rest_error_code
    add x16, x16, :lo12:rest_error_code
    str w28, [x16]
.rest_free_headers:
    mov x0, x27
    adrp x16, fn_slist_free_all
    add x16, x16, :lo12:fn_slist_free_all
    ldr x16, [x16]
    blr x16
.rest_cleanup:
    mov x0, x26
    adrp x16, fn_easy_cleanup
    add x16, x16, :lo12:fn_easy_cleanup
    ldr x16, [x16]
    blr x16
    adrp x16, capture_enabled
    add x16, x16, :lo12:capture_enabled
    str wzr, [x16]
    mov w0, w28
    b .rest_return
.rest_failure:
    mov w28, #1
    b .rest_cleanup_no_handle
.rest_failure_no_handle:
    mov x0, x27
    adrp x16, fn_slist_free_all
    add x16, x16, :lo12:fn_slist_free_all
    ldr x16, [x16]
    blr x16
.rest_cleanup_no_handle:
    adrp x16, capture_enabled
    add x16, x16, :lo12:capture_enabled
    str wzr, [x16]
    mov w0, w28
.rest_return:
    adrp x16, capture_length
    add x16, x16, :lo12:capture_length
    ldr x1, [x16]
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret

native_copy_cstr_network:
    mov x2, x0
.copy_cstr_network_loop:
    ldrb w3, [x1], #1
    strb w3, [x2], #1
    cbnz w3, .copy_cstr_network_loop
    ret

native_curl_get:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    adrp x16, rest_status
    add x16, x16, :lo12:rest_status
    str wzr, [x16]
    adrp x16, fn_easy_init
    add x16, x16, :lo12:fn_easy_init
    ldr x16, [x16]
    blr x16
    cbz x0, .curl_get_failure
    mov x22, x0
    mov x0, x22
    mov x1, #10002
    mov x2, x19
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .curl_get_cleanup
    mov x0, x22
    mov x1, #10018
    adrp x2, user_agent
    add x2, x2, :lo12:user_agent
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .curl_get_cleanup
    mov x0, x22
    mov x1, #20011
    adrp x3, capture_enabled
    add x3, x3, :lo12:capture_enabled
    ldr w3, [x3]
    cbnz w3, .curl_get_capture_callback
    adrp x2, native_curl_discard
    add x2, x2, :lo12:native_curl_discard
    mov x3, xzr
    b .curl_get_set_callback
.curl_get_capture_callback:
    adrp x2, native_curl_capture
    add x2, x2, :lo12:native_curl_capture
    adrp x3, capture_context
    add x3, x3, :lo12:capture_context
.curl_get_set_callback:
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .curl_get_cleanup
    mov x0, x22
    mov x1, #10001
    adrp x2, capture_context
    add x2, x2, :lo12:capture_context
    adrp x3, capture_enabled
    add x3, x3, :lo12:capture_enabled
    ldr w3, [x3]
    cbnz w3, .curl_get_set_userdata
    mov x2, xzr
.curl_get_set_userdata:
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .curl_get_cleanup
    mov x0, x22
    mov x1, #45
    mov x2, #1
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .curl_get_cleanup
    mov x0, x22
    mov x1, #64
    mov x2, #1
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .curl_get_cleanup
    mov x0, x22
    mov x1, #81
    mov x2, #2
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .curl_get_cleanup
    mov x0, x22
    mov x1, #155
    mov x2, #20000
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .curl_get_cleanup
    mov x24, xzr
    cbz x20, .curl_get_perform
    ldrb w0, [x20]
    cbz w0, .curl_get_perform
    adrp x0, network_header
    add x0, x0, :lo12:network_header
    mov x1, x21
    mov x2, x20
    bl native_build_header
    mov x0, xzr
    adrp x1, network_header
    add x1, x1, :lo12:network_header
    adrp x16, fn_slist_append
    add x16, x16, :lo12:fn_slist_append
    ldr x16, [x16]
    blr x16
    cbz x0, .curl_get_cleanup
    mov x24, x0
    mov x0, x22
    mov x1, #10023
    mov x2, x24
    adrp x16, fn_easy_setopt
    add x16, x16, :lo12:fn_easy_setopt
    ldr x16, [x16]
    blr x16
    cbnz w0, .curl_get_free_headers
.curl_get_perform:
    mov x0, x22
    adrp x16, fn_easy_perform
    add x16, x16, :lo12:fn_easy_perform
    ldr x16, [x16]
    blr x16
    mov w23, w0
    cbnz w23, .curl_get_free_headers
    mov x0, x22
    mov w1, #2
    movk w1, #0x20, lsl #16
    adrp x2, rest_status
    add x2, x2, :lo12:rest_status
    adrp x16, fn_easy_getinfo
    add x16, x16, :lo12:fn_easy_getinfo
    ldr x16, [x16]
    blr x16
    mov w23, w0
    cbnz w23, .curl_get_free_headers
    mov x0, x22
    adrp x16, fn_easy_cleanup
    add x16, x16, :lo12:fn_easy_cleanup
    ldr x16, [x16]
    blr x16
    cbz x24, .curl_get_success
    mov x0, x24
    adrp x16, fn_slist_free_all
    add x16, x16, :lo12:fn_slist_free_all
    ldr x16, [x16]
    blr x16
.curl_get_success:
    mov w0, wzr
    b .curl_get_return
.curl_get_free_headers:
    cbz x24, .curl_get_cleanup
    mov x0, x24
    adrp x16, fn_slist_free_all
    add x16, x16, :lo12:fn_slist_free_all
    ldr x16, [x16]
    blr x16
.curl_get_cleanup:
    mov x0, x22
    adrp x16, fn_easy_cleanup
    add x16, x16, :lo12:fn_easy_cleanup
    ldr x16, [x16]
    blr x16
.curl_get_failure:
    mov w0, #1
.curl_get_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

native_curl_get_capture:
    stp x29, x30, [sp, #-80]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, x4
    adrp x16, capture_buffer
    add x16, x16, :lo12:capture_buffer
    str x22, [x16]
    adrp x16, capture_capacity
    add x16, x16, :lo12:capture_capacity
    str x23, [x16]
    adrp x16, capture_length
    add x16, x16, :lo12:capture_length
    str xzr, [x16]
    adrp x16, capture_overflow
    add x16, x16, :lo12:capture_overflow
    str wzr, [x16]
    adrp x16, capture_enabled
    add x16, x16, :lo12:capture_enabled
    mov w0, #1
    str w0, [x16]
    mov x0, x19
    mov x1, x20
    mov x2, x21
    bl native_curl_get
    mov w24, w0
    adrp x16, capture_enabled
    add x16, x16, :lo12:capture_enabled
    str wzr, [x16]
    mov w0, w24
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret

native_build_header:
    mov x3, xzr
.header_prefix_loop:
    ldrb w4, [x1, x3]
    strb w4, [x0, x3]
    add x3, x3, #1
    cbnz w4, .header_prefix_loop
    sub x3, x3, #1
.header_token_loop:
    ldrb w4, [x2], #1
    strb w4, [x0, x3]
    add x3, x3, #1
    cbnz w4, .header_token_loop
    sub x3, x3, #1
    strb wzr, [x0, x3]
    ret

native_curl_discard:
    mul x0, x1, x2
    ret

native_curl_capture:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    mul x4, x1, x2
    str x4, [sp, #16]
    adrp x5, capture_length
    add x5, x5, :lo12:capture_length
    ldr x6, [x5]
    adrp x7, capture_capacity
    add x7, x7, :lo12:capture_capacity
    ldr x7, [x7]
    cmp x6, x7
    b.hs .capture_overflow
    sub x8, x7, x6
    cmp x4, x8
    b.hi .capture_overflow
    cbz x4, .capture_success
    adrp x9, capture_buffer
    add x9, x9, :lo12:capture_buffer
    ldr x9, [x9]
    add x2, x9, x6
    mov x1, x4
    bl native_copy_bytes
    ldr x4, [sp, #16]
    add x6, x6, x4
    str x6, [x5]
.capture_success:
    ldr x4, [sp, #16]
    mov x0, x4
    ldp x29, x30, [sp], #32
    ret
.capture_overflow:
    adrp x9, capture_overflow
    add x9, x9, :lo12:capture_overflow
    mov w10, #1
    str w10, [x9]
    mov x0, xzr
    ldp x29, x30, [sp], #32
    ret

.section .bss
.align 3
curl_module: .skip 8
fn_global_init: .skip 8
fn_easy_init: .skip 8
fn_easy_setopt: .skip 8
fn_easy_perform: .skip 8
fn_easy_cleanup: .skip 8
fn_easy_getinfo: .skip 8
fn_slist_append: .skip 8
fn_slist_free_all: .skip 8
fn_easy_send: .skip 8
fn_easy_recv: .skip 8
network_header: .skip 8192
network_header2: .skip 256
ws_empty: .skip 1
ws_io_size: .skip 8
ws_meta: .skip 8
ws_message_length: .skip 8
ws_fragment_active: .skip 4
ws_buffer: .skip 65536
ws_frame_buffer: .skip 65544
ws_frame_payload: .skip 65536
ws_frame_header: .skip 2
ws_frame_header_ext: .skip 8
ws_frame_mask: .skip 4
ws_random_bytes: .skip 16
ws_key_base64: .skip 25
ws_accept_input: .skip 64
ws_sha1_block: .skip 128
ws_sha1_schedule: .skip 320
ws_accept_digest: .skip 20
ws_accept_expected: .skip 32
ws_mask_key: .skip 4
ws_http_request: .skip 8192
ws_http_request_length: .skip 8
ws_http_path: .skip 4096
ws_url_host: .skip 1024
ws_url_path: .skip 4096
ws_http_response: .skip 4096
ws_pending_buffer: .skip 65536
ws_pending_length: .skip 8
ws_socket_buffer: .skip 65536
event_queue_length: .skip 8
event_queue: .skip 131072
ws_identify: .skip 4096
ws_stream_url: .skip 4096
ws_transport_url: .skip 4096
ws_poll_url: .skip 4096
ws_decimal: .skip 64
ws_decimal_tmp: .skip 64
ws_json_buffer: .skip 65536
ws_json_length: .skip 8
ws_json_structure_stack: .skip 256
ws_cursor: .skip 8
ws_cursor_candidate: .skip 8
ws_poll_has_pushes: .skip 4
ws_sequence: .skip 8
ws_sequence_valid: .skip 4
ws_heartbeat_interval: .skip 8
ws_identify_intents: .skip 8
ws_error_code: .skip 4
ws_open_ok: .skip 4
ws_stage: .skip 4
ws_recv_budget: .skip 8
rest_status: .skip 8
rest_error_code: .skip 4
capture_enabled: .skip 4
capture_buffer: .skip 8
capture_capacity: .skip 8
capture_length: .skip 8
capture_overflow: .skip 4
.align 3
capture_context: .skip 8
