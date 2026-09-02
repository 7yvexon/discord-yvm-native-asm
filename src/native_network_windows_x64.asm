bits 64
default rel

global yul_native_network_start
global yul_native_network_probe
global yul_native_network_rest_json
global yul_native_network_ws_open
global yul_native_network_ws_send_text
global yul_native_network_ws_recv
global yul_native_network_ws_close
global yul_native_network_sleep
global network_response
global network_response_length
global network_status
global network_gateway_response
global network_gateway_response_length
global network_push_response
global network_push_response_length
global network_push_ws_url_override

extern GetProcAddress
extern LoadLibraryA
extern Sleep
extern runtime_validate_gateway_url
extern runtime_validate_push_url

section .text

yul_native_network_start:
    push rbx
    push r12
    sub rsp, 0x28
    cmp qword [rel winhttp_module], 0
    jne native_network_start_ready
    lea rcx, [rel winhttp_name]
    call LoadLibraryA
    test rax, rax
    jz native_network_start_fail
    mov [rel winhttp_module], rax
    mov r12, rax
    lea rdx, [rel name_winhttp_open]
    call native_network_resolve
    mov [rel fn_winhttp_open], rax
    lea rdx, [rel name_winhttp_connect]
    call native_network_resolve
    mov [rel fn_winhttp_connect], rax
    lea rdx, [rel name_winhttp_open_request]
    call native_network_resolve
    mov [rel fn_winhttp_open_request], rax
    lea rdx, [rel name_winhttp_send_request]
    call native_network_resolve
    mov [rel fn_winhttp_send_request], rax
    lea rdx, [rel name_winhttp_receive_response]
    call native_network_resolve
    mov [rel fn_winhttp_receive_response], rax
    lea rdx, [rel name_winhttp_query_headers]
    call native_network_resolve
    mov [rel fn_winhttp_query_headers], rax
    lea rdx, [rel name_winhttp_query_data_available]
    call native_network_resolve
    mov [rel fn_winhttp_query_data_available], rax
    lea rdx, [rel name_winhttp_read_data]
    call native_network_resolve
    mov [rel fn_winhttp_read_data], rax
    lea rdx, [rel name_winhttp_add_headers]
    call native_network_resolve
    mov [rel fn_winhttp_add_headers], rax
    lea rdx, [rel name_winhttp_close_handle]
    call native_network_resolve
    mov [rel fn_winhttp_close_handle], rax
    lea rdx, [rel name_winhttp_set_timeouts]
    call native_network_resolve
    mov [rel fn_winhttp_set_timeouts], rax
    lea rdx, [rel name_winhttp_set_option]
    call native_network_resolve
    mov [rel fn_winhttp_set_option], rax
    lea rdx, [rel name_winhttp_complete_upgrade]
    call native_network_resolve
    mov [rel fn_winhttp_complete_upgrade], rax
    lea rdx, [rel name_winhttp_websocket_send]
    call native_network_resolve
    mov [rel fn_winhttp_websocket_send], rax
    lea rdx, [rel name_winhttp_websocket_receive]
    call native_network_resolve
    mov [rel fn_winhttp_websocket_receive], rax
    lea rdx, [rel name_winhttp_websocket_close]
    call native_network_resolve
    mov [rel fn_winhttp_websocket_close], rax
    mov rax, [rel fn_winhttp_open]
    test rax, rax
    jz native_network_start_fail
    mov rax, [rel fn_winhttp_connect]
    test rax, rax
    jz native_network_start_fail
    mov rax, [rel fn_winhttp_open_request]
    test rax, rax
    jz native_network_start_fail
    mov rax, [rel fn_winhttp_send_request]
    test rax, rax
    jz native_network_start_fail
    mov rax, [rel fn_winhttp_receive_response]
    test rax, rax
    jz native_network_start_fail
    mov rax, [rel fn_winhttp_query_headers]
    test rax, rax
    jz native_network_start_fail
    mov rax, [rel fn_winhttp_query_data_available]
    test rax, rax
    jz native_network_start_fail
    mov rax, [rel fn_winhttp_read_data]
    test rax, rax
    jz native_network_start_fail
    mov rax, [rel fn_winhttp_add_headers]
    test rax, rax
    jz native_network_start_fail
    mov rax, [rel fn_winhttp_close_handle]
    test rax, rax
    jz native_network_start_fail
    mov rax, [rel fn_winhttp_set_timeouts]
    test rax, rax
    jz native_network_start_fail
    mov rax, [rel fn_winhttp_set_option]
    test rax, rax
    jz native_network_start_fail
    mov rax, [rel fn_winhttp_complete_upgrade]
    test rax, rax
    jz native_network_start_fail
    mov rax, [rel fn_winhttp_websocket_send]
    test rax, rax
    jz native_network_start_fail
    mov rax, [rel fn_winhttp_websocket_receive]
    test rax, rax
    jz native_network_start_fail
    mov rax, [rel fn_winhttp_websocket_close]
    test rax, rax
    jz native_network_start_fail
native_network_start_ready:
    xor eax, eax
    jmp native_network_start_return
native_network_start_fail:
    mov eax, 1
native_network_start_return:
    add rsp, 0x28
    pop r12
    pop rbx
    ret

native_network_resolve:
    mov rcx, r12
    sub rsp, 0x28
    call GetProcAddress
    add rsp, 0x28
    ret

yul_native_network_probe:
    push rbx
    sub rsp, 0x20
    mov rbx, rcx
    test rbx, rbx
    jz native_probe_push
    cmp byte [rbx], 0
    je native_probe_push
    lea rcx, [rel discord_rest_url]
    lea rdx, [rel method_get]
    mov r8, rbx
    xor r9d, r9d
    call yul_native_network_rest_json
    test eax, eax
    jnz native_probe_return
native_probe_push:
    mov rbx, rdx
    test rbx, rbx
    jz native_probe_success
    cmp byte [rbx], 0
    je native_probe_success
    lea rcx, [rel push_rest_url]
    lea rdx, [rel method_get]
    mov r8, rbx
    xor r9d, r9d
    call yul_native_network_rest_json
native_probe_return:
    add rsp, 0x20
    pop rbx
    ret
native_probe_success:
    xor eax, eax
    jmp native_probe_return

yul_native_network_rest_json:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 0x20
    mov r12, rcx
    mov r13, rdx
    mov r14, r8
    mov r15, r9
    call native_transport_acquire
    call yul_native_network_start
    test eax, eax
    jnz native_rest_return
    mov rcx, r12
    mov rdx, r13
    call native_parse_url
    test eax, eax
    jnz native_rest_return
    lea rcx, [rel network_host_ascii]
    lea rdx, [rel network_host_wide]
    mov r8d, 512
    call native_ascii_to_wide
    lea rcx, [rel network_path_ascii]
    lea rdx, [rel network_path_wide]
    mov r8d, 4096
    call native_ascii_to_wide
    lea rcx, [rel network_method_ascii]
    lea rdx, [rel network_method_wide]
    mov r8d, 64
    call native_ascii_to_wide
    sub rsp, 0x20
    lea rcx, [rel user_agent_wide]
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    mov qword [rsp + 0x20], 0
    call [rel fn_winhttp_open]
    add rsp, 0x20
    test rax, rax
    jz native_rest_return_fail
    mov rbx, rax
    sub rsp, 0x20
    mov rcx, rbx
    lea rdx, [rel network_host_wide]
    mov r8d, 443
    xor r9d, r9d
    call [rel fn_winhttp_connect]
    add rsp, 0x20
    test rax, rax
    jz native_rest_close_connect_fail
    mov rsi, rax
    sub rsp, 0x40
    mov rcx, rsi
    lea rdx, [rel network_method_wide]
    lea r8, [rel network_path_wide]
    xor r9d, r9d
    mov qword [rsp + 0x20], 0
    mov qword [rsp + 0x28], 0
    mov qword [rsp + 0x30], 0x00800000
    call [rel fn_winhttp_open_request]
    add rsp, 0x40
    test rax, rax
    jz native_rest_close_session_fail
    mov rdi, rax
    sub rsp, 0x20
    mov rcx, rdi
    mov edx, 15000
    mov r8d, 15000
    mov r9d, 15000
    mov dword [rsp + 0x20], 15000
    call [rel fn_winhttp_set_timeouts]
    add rsp, 0x20
    test eax, eax
    jz native_rest_close_request_fail
    mov rcx, r14
    call native_build_rest_headers
    test eax, eax
    jnz native_rest_close_request_fail
    sub rsp, 0x40
    mov rcx, rdi
    lea rdx, [rel network_header_wide]
    mov r8d, -1
    mov r9, r15
    test r15, r15
    jz native_rest_no_body
    mov rcx, r15
    call native_cstring_length
    mov r9, rax
    jmp native_rest_body_ready
native_rest_no_body:
    xor r9d, r9d
native_rest_body_ready:
    mov [rsp + 0x20], r9
    mov [rsp + 0x28], r9
    mov qword [rsp + 0x30], 0
    call [rel fn_winhttp_send_request]
    add rsp, 0x40
    test eax, eax
    jz native_rest_close_request_fail
    sub rsp, 0x20
    mov rcx, rdi
    xor edx, edx
    call [rel fn_winhttp_receive_response]
    add rsp, 0x20
    test eax, eax
    jz native_rest_close_request_fail
    call native_query_status
    test eax, eax
    jnz native_rest_close_request_fail
    call native_capture_response
    test eax, eax
    jnz native_rest_close_request_fail
    mov rcx, rdi
    sub rsp, 0x20
    call [rel fn_winhttp_close_handle]
    add rsp, 0x20
    mov rcx, rsi
    sub rsp, 0x20
    call [rel fn_winhttp_close_handle]
    add rsp, 0x20
    mov rcx, rbx
    sub rsp, 0x20
    call [rel fn_winhttp_close_handle]
    add rsp, 0x20
    mov eax, [rel network_status]
    cmp eax, 200
    jb native_rest_status_fail
    cmp eax, 300
    jae native_rest_status_fail
    xor eax, eax
    jmp native_rest_return
native_rest_status_fail:
    mov eax, 1
    jmp native_rest_return
native_rest_close_request_fail:
    mov rcx, rdi
    sub rsp, 0x20
    call [rel fn_winhttp_close_handle]
    add rsp, 0x20
native_rest_close_session_fail:
    mov rcx, rsi
    sub rsp, 0x20
    call [rel fn_winhttp_close_handle]
    add rsp, 0x20
    jmp native_rest_close_connect_fail
native_rest_close_connect_fail:
    mov rcx, rbx
    sub rsp, 0x20
    call [rel fn_winhttp_close_handle]
    add rsp, 0x20
native_rest_return_fail:
    mov eax, 1
native_rest_return:
    mov dword [rel network_transport_busy], 0
    add rsp, 0x20
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

yul_native_network_ws_open:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 0x20
    mov r12d, ecx
    mov r13, rdx
    call native_transport_acquire
    cmp r12d, 0
    jne native_ws_validate_push
    test r13, r13
    jz native_ws_validate_done
    cmp byte [r13], 0
    je native_ws_validate_done
    mov rcx, r13
    call runtime_validate_gateway_url
    test eax, eax
    jnz native_ws_open_return_fail
    jmp native_ws_validate_done
native_ws_validate_push:
    mov rax, [rel network_push_ws_url_override]
    test rax, rax
    jz native_ws_validate_done
    mov rcx, rax
    call runtime_validate_push_url
    test eax, eax
    jnz native_ws_open_return_fail
native_ws_validate_done:
    call yul_native_network_start
    test eax, eax
    jnz native_ws_open_return
    mov ecx, r12d
    call yul_native_network_ws_close
    cmp r12d, 0
    jne native_ws_select_push
    test r13, r13
    jz native_ws_select_gateway_default
    cmp byte [r13], 0
    je native_ws_select_gateway_default
    mov rcx, r13
    lea rdx, [rel method_get]
    call native_parse_url
    test eax, eax
    jnz native_ws_open_return_fail
    jmp native_ws_select_wide
native_ws_select_gateway_default:
    lea rcx, [rel discord_ws_path_ascii]
    lea rdx, [rel network_path_ascii]
    call native_copy_cstring
    lea rsi, [rel discord_ws_host_ascii]
    jmp native_ws_select_host
native_ws_select_push:
    mov rax, [rel network_push_ws_url_override]
    test rax, rax
    jz native_ws_select_push_default
    mov rcx, rax
    lea rdx, [rel method_get]
    call native_parse_url
    lea rcx, [rel push_ws_token_separator_ascii]
    lea rdx, [rel network_path_ascii]
    call native_append_cstring
    mov rcx, r13
    lea rdx, [rel network_path_ascii]
    call native_append_cstring
    jmp native_ws_select_host_parsed
native_ws_select_push_default:
    lea rcx, [rel push_ws_path_prefix_ascii]
    lea rdx, [rel network_path_ascii]
    call native_copy_cstring
    mov rcx, r13
    lea rdx, [rel network_path_ascii]
    call native_append_cstring
    lea rsi, [rel push_ws_host_ascii]
native_ws_select_host:
    lea rcx, [rel network_host_ascii]
    mov rdx, rsi
    call native_copy_cstring
native_ws_select_host_parsed:
native_ws_select_wide:
    lea rcx, [rel network_host_ascii]
    lea rdx, [rel network_host_wide]
    mov r8d, 512
    call native_ascii_to_wide
    lea rcx, [rel network_path_ascii]
    lea rdx, [rel network_path_wide]
    mov r8d, 4096
    call native_ascii_to_wide
    sub rsp, 0x20
    lea rcx, [rel user_agent_wide]
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    mov qword [rsp + 0x20], 0
    call [rel fn_winhttp_open]
    add rsp, 0x20
    test rax, rax
    jz native_ws_open_return_fail
    mov rbx, rax
    sub rsp, 0x20
    mov rcx, rbx
    lea rdx, [rel network_host_wide]
    mov r8d, 443
    xor r9d, r9d
    call [rel fn_winhttp_connect]
    add rsp, 0x20
    test rax, rax
    jz native_ws_close_connect_fail
    mov rsi, rax
    sub rsp, 0x40
    mov rcx, rsi
    lea rdx, [rel get_wide]
    lea r8, [rel network_path_wide]
    xor r9d, r9d
    mov qword [rsp + 0x20], 0
    mov qword [rsp + 0x28], 0
    mov qword [rsp + 0x30], 0x00800000
    call [rel fn_winhttp_open_request]
    add rsp, 0x40
    test rax, rax
    jz native_ws_close_session_fail
    mov rdi, rax
    sub rsp, 0x20
    mov rcx, rdi
    mov edx, 114
    xor r8d, r8d
    xor r9d, r9d
    call [rel fn_winhttp_set_option]
    add rsp, 0x20
    test eax, eax
    jz native_ws_close_request_fail
    sub rsp, 0x40
    mov rcx, rdi
    xor edx, edx
    xor r8d, r8d
    xor r9d, r9d
    mov qword [rsp + 0x20], 0
    mov qword [rsp + 0x28], 0
    mov qword [rsp + 0x30], 0
    mov qword [rsp + 0x38], 0
    call [rel fn_winhttp_send_request]
    add rsp, 0x40
    test eax, eax
    jz native_ws_close_request_fail
    sub rsp, 0x20
    mov rcx, rdi
    xor edx, edx
    call [rel fn_winhttp_receive_response]
    add rsp, 0x20
    test eax, eax
    jz native_ws_close_request_fail
    sub rsp, 0x20
    mov rcx, rdi
    xor edx, edx
    call [rel fn_winhttp_complete_upgrade]
    add rsp, 0x20
    test rax, rax
    jz native_ws_close_request_fail
    cmp r12d, 0
    jne native_ws_store_push_handle
    mov [rel network_ws_handle_gateway], rax
    jmp native_ws_store_handle_done
native_ws_store_push_handle:
    mov [rel network_ws_handle_push], rax
native_ws_store_handle_done:
    mov rcx, rdi
    sub rsp, 0x20
    call [rel fn_winhttp_close_handle]
    add rsp, 0x20
    mov rcx, rsi
    sub rsp, 0x20
    call [rel fn_winhttp_close_handle]
    add rsp, 0x20
    mov rcx, rbx
    sub rsp, 0x20
    call [rel fn_winhttp_close_handle]
    add rsp, 0x20
    xor eax, eax
    jmp native_ws_open_return
native_ws_close_request_fail:
    mov rcx, rdi
    sub rsp, 0x20
    call [rel fn_winhttp_close_handle]
    add rsp, 0x20
native_ws_close_session_fail:
    mov rcx, rsi
    sub rsp, 0x20
    call [rel fn_winhttp_close_handle]
    add rsp, 0x20
    jmp native_ws_close_connect_fail
native_ws_close_connect_fail:
    mov rcx, rbx
    sub rsp, 0x20
    call [rel fn_winhttp_close_handle]
    add rsp, 0x20
native_ws_open_return_fail:
    mov eax, 1
native_ws_open_return:
    mov dword [rel network_transport_busy], 0
    add rsp, 0x20
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

yul_native_network_ws_send_text:
    push rbx
    push r12
    sub rsp, 0x28
    mov rbx, rcx
    mov r12d, r8d
    mov rax, rdx
    test rax, rax
    jnz native_ws_send_length_ready
    call native_cstring_length
    mov rdx, rax
native_ws_send_length_ready:
    mov ecx, r12d
    call native_ws_get_handle
    mov rcx, rax
    test rcx, rcx
    jz native_ws_send_fail
    mov r8, rbx
    mov r9, rdx
    mov edx, 2
    sub rsp, 0x30
    mov qword [rsp + 0x20], 0
    call [rel fn_winhttp_websocket_send]
    add rsp, 0x30
    test eax, eax
    jz native_ws_send_ok
native_ws_send_fail:
    mov eax, 1
    jmp native_ws_send_return
native_ws_send_ok:
    xor eax, eax
native_ws_send_return:
    add rsp, 0x28
    pop r12
    pop rbx
    ret

yul_native_network_ws_recv:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 0x20
    mov r12d, ecx
    mov ecx, r12d
    call native_ws_get_handle
    mov rbx, rax
    test rbx, rbx
    jz native_ws_recv_fail
    cmp r12d, 0
    jne native_ws_recv_select_push
    lea r13, [rel network_gateway_response_length]
    lea r14, [rel network_ws_gateway_buffer]
    lea r15, [rel network_gateway_response]
    lea rsi, [rel network_ws_gateway_read]
    lea rdi, [rel network_ws_gateway_type]
    jmp native_ws_recv_select_done
native_ws_recv_select_push:
    lea r13, [rel network_push_response_length]
    lea r14, [rel network_ws_push_buffer]
    lea r15, [rel network_push_response]
    lea rsi, [rel network_ws_push_read]
    lea rdi, [rel network_ws_push_type]
native_ws_recv_select_done:
    mov qword [r13], 0
native_ws_recv_loop:
    mov qword [rsi], 0
    mov dword [rdi], 0
    mov rcx, rbx
    mov rdx, r14
    mov r8d, 65536
    mov r9, rsi
    sub rsp, 0x30
    mov [rsp + 0x20], rdi
    call [rel fn_winhttp_websocket_receive]
    add rsp, 0x30
    test eax, eax
    jnz native_ws_recv_fail
    mov eax, [rdi]
    cmp eax, 4
    je native_ws_recv_fail
    mov rax, [r13]
    mov rdx, [rsi]
    mov r10, rax
    add r10, rdx
    cmp r10, 65535
    ja native_ws_recv_fail
    lea rcx, [r15 + rax]
    mov r11, rdx
    mov rdx, r14
    mov r8, r11
    mov [r13], r10
    call native_copy_bytes
    mov r10, [r13]
    mov byte [r15 + r10], 0
    mov eax, [rdi]
    cmp eax, 1
    je native_ws_recv_loop
    cmp eax, 3
    je native_ws_recv_loop
    xor eax, eax
    jmp native_ws_recv_return
native_ws_recv_fail:
    mov eax, 1
native_ws_recv_return:
    add rsp, 0x20
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

yul_native_network_ws_close:
    push rbx
    push r12
    sub rsp, 0x28
    mov r12d, ecx
    mov ecx, r12d
    call native_ws_get_handle
    mov rbx, rax
    test rbx, rbx
    jz native_ws_close_done
    mov rcx, rbx
    mov edx, 1000
    xor r8d, r8d
    xor r9d, r9d
    sub rsp, 0x20
    mov qword [rsp + 0x20], 0
    call [rel fn_winhttp_websocket_close]
    add rsp, 0x20
native_ws_close_done:
    cmp r12d, 0
    jne native_ws_clear_push_handle
    mov qword [rel network_ws_handle_gateway], 0
    jmp native_ws_clear_handle_done
native_ws_clear_push_handle:
    mov qword [rel network_ws_handle_push], 0
native_ws_clear_handle_done:
    add rsp, 0x28
    pop r12
    pop rbx
    xor eax, eax
    ret

native_ws_get_handle:
    test ecx, ecx
    jnz native_ws_get_push_handle
    mov rax, [rel network_ws_handle_gateway]
    ret
native_ws_get_push_handle:
    mov rax, [rel network_ws_handle_push]
    ret

yul_native_network_sleep:
    sub rsp, 0x28
    call Sleep
    add rsp, 0x28
    ret

native_transport_acquire:
    sub rsp, 0x28
native_transport_acquire_loop:
    xor eax, eax
    mov edx, 1
    lock cmpxchg [rel network_transport_busy], edx
    je native_transport_acquire_done
    mov ecx, 1
    call Sleep
    jmp native_transport_acquire_loop
native_transport_acquire_done:
    add rsp, 0x28
    ret

native_parse_url:
    push rbx
    push rsi
    push rdi
    push r12
    sub rsp, 0x20
    mov rsi, rcx
    mov r12, rdx
    lea rdi, [rel network_host_ascii]
    cmp byte [rsi], 'h'
    jne native_parse_url_ws
    cmp byte [rsi + 1], 't'
    jne native_parse_url_ws
    cmp byte [rsi + 2], 't'
    jne native_parse_url_ws
    cmp byte [rsi + 3], 'p'
    jne native_parse_url_ws
    cmp byte [rsi + 4], 's'
    jne native_parse_url_ws
    add rsi, 8
    jmp native_parse_url_host
native_parse_url_ws:
    cmp byte [rsi], 'w'
    jne native_parse_url_host
    cmp byte [rsi + 1], 's'
    jne native_parse_url_host
    cmp byte [rsi + 2], 's'
    je native_parse_url_wss
    cmp byte [rsi + 2], ':'
    jne native_parse_url_host
    cmp byte [rsi + 3], '/'
    jne native_parse_url_host
    cmp byte [rsi + 4], '/'
    jne native_parse_url_host
    add rsi, 5
    jmp native_parse_url_host
native_parse_url_wss:
    cmp byte [rsi + 3], ':'
    jne native_parse_url_host
    cmp byte [rsi + 4], '/'
    jne native_parse_url_host
    cmp byte [rsi + 5], '/'
    jne native_parse_url_host
    add rsi, 6
native_parse_url_host:
native_parse_url_host_loop:
    mov al, [rsi]
    test al, al
    jz native_parse_url_host_done
    cmp al, '/'
    je native_parse_url_host_done
    cmp al, '?'
    je native_parse_url_host_done
    mov [rdi], al
    inc rdi
    inc rsi
    jmp native_parse_url_host_loop
native_parse_url_host_done:
    mov byte [rdi], 0
    cmp byte [rsi], 0
    jne native_parse_url_nonempty_path
    lea rcx, [rel discord_ws_path_ascii]
    lea rdx, [rel network_path_ascii]
    call native_copy_cstring
    jmp native_parse_url_method
native_parse_url_nonempty_path:
    cmp byte [rsi], '?'
    je native_parse_url_query
    jmp native_parse_url_path
native_parse_url_path:
    lea rdi, [rel network_path_ascii]
    xor r8d, r8d
native_parse_url_path_loop:
    mov al, [rsi]
    mov [rdi], al
    inc rdi
    inc rsi
    test al, al
    jz native_parse_url_path_done
    cmp al, '?'
    jne native_parse_url_path_loop
    mov r8d, 1
    jmp native_parse_url_path_loop
native_parse_url_path_done:
    test r8d, r8d
    jnz native_parse_url_method
    lea rcx, [rel discord_ws_query_suffix_ascii]
    lea rdx, [rel network_path_ascii]
    call native_append_cstring
    jmp native_parse_url_method
native_parse_url_query:
    lea rdi, [rel network_path_ascii]
    mov byte [rdi], '/'
    inc rdi
native_parse_url_query_loop:
    mov al, [rsi]
    mov [rdi], al
    inc rdi
    inc rsi
    test al, al
    jnz native_parse_url_query_loop
native_parse_url_method:
    mov rsi, r12
    lea rdi, [rel network_method_ascii]
native_parse_url_method_loop:
    mov al, [rsi]
    mov [rdi], al
    inc rdi
    inc rsi
    test al, al
    jnz native_parse_url_method_loop
    cmp byte [rel network_host_ascii], 'd'
    jne native_parse_url_push_host
    mov dword [rel network_is_discord], 1
    jmp native_parse_url_done
native_parse_url_push_host:
    mov dword [rel network_is_discord], 0
native_parse_url_done:
    xor eax, eax
    add rsp, 0x20
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

native_ascii_to_wide:
    push rbx
    push rsi
    push rdi
    mov rsi, rcx
    mov rdi, rdx
    mov rbx, r8
    xor r8, r8
native_ascii_to_wide_loop:
    cmp r8, rbx
    jae native_ascii_to_wide_done
    movzx eax, byte [rsi + r8]
    mov [rdi + r8 * 2], ax
    inc r8
    test al, al
    jnz native_ascii_to_wide_loop
native_ascii_to_wide_done:
    pop rdi
    pop rsi
    pop rbx
    ret

native_build_rest_headers:
    push rbx
    push rsi
    push rdi
    mov rsi, rcx
    lea rdi, [rel network_header_wide]
    cmp dword [rel network_is_discord], 0
    je native_build_headers_push
    lea rbx, [rel discord_header_prefix_ascii]
    jmp native_build_headers_prefix
native_build_headers_push:
    lea rbx, [rel push_header_prefix_ascii]
native_build_headers_prefix:
    movzx eax, byte [rbx]
    inc rbx
    mov [rdi], ax
    add rdi, 2
    test al, al
    jnz native_build_headers_prefix
native_build_headers_token:
    movzx eax, byte [rsi]
    inc rsi
    mov [rdi], ax
    add rdi, 2
    test al, al
    jnz native_build_headers_token
    lea rbx, [rel content_header_ascii]
native_build_headers_content:
    movzx eax, byte [rbx]
    inc rbx
    mov [rdi], ax
    add rdi, 2
    test al, al
    jnz native_build_headers_content
    xor eax, eax
    pop rdi
    pop rsi
    pop rbx
    ret

native_query_status:
    sub rsp, 0x38
    mov dword [rel network_status], 0
    mov dword [rel network_status_length], 4
    mov rcx, rdi
    mov edx, 0x20000013
    xor r8d, r8d
    lea r9, [rel network_status]
    lea rax, [rel network_status_length]
    mov [rsp + 0x20], rax
    mov qword [rsp + 0x28], 0
    call [rel fn_winhttp_query_headers]
    test eax, eax
    jz native_query_status_fail
    xor eax, eax
    add rsp, 0x38
    ret
native_query_status_fail:
    mov eax, 1
    add rsp, 0x38
    ret

native_capture_response:
    push rbx
    sub rsp, 0x20
    xor ebx, ebx
    mov [rel network_response_length], rbx
native_capture_loop:
    mov rcx, rdi
    lea rdx, [rel network_io_size]
    sub rsp, 0x20
    call [rel fn_winhttp_query_data_available]
    add rsp, 0x20
    test eax, eax
    jz native_capture_fail
    mov eax, [rel network_io_size]
    test eax, eax
    jz native_capture_done
    mov ecx, 65535
    sub ecx, ebx
    cmp eax, ecx
    jbe native_capture_size_ready
    jmp native_capture_overflow
native_capture_size_ready:
    mov r8d, eax
    mov rcx, rdi
    lea rdx, [rel network_response]
    add rdx, rbx
    lea r9, [rel network_io_size]
    sub rsp, 0x20
    call [rel fn_winhttp_read_data]
    add rsp, 0x20
    test eax, eax
    jz native_capture_fail
    mov eax, [rel network_io_size]
    test eax, eax
    jz native_capture_fail
    add ebx, eax
    jmp native_capture_loop
native_capture_done:
    mov [rel network_response_length], rbx
    lea rax, [rel network_response]
    mov byte [rax + rbx], 0
    xor eax, eax
    add rsp, 0x20
    pop rbx
    ret
native_capture_fail:
    mov eax, 1
    add rsp, 0x20
    pop rbx
    ret
native_capture_overflow:
    mov qword [rel network_response_length], 0
    jmp native_capture_fail

native_copy_cstring:
    push rbx
    push rsi
    push rdi
    mov rsi, rcx
    mov rdi, rdx
    xor r8, r8
native_copy_cstring_loop:
    cmp r8, 4095
    jae native_copy_cstring_done
    mov al, [rsi + r8]
    mov [rdi + r8], al
    inc r8
    test al, al
    jnz native_copy_cstring_loop
native_copy_cstring_done:
    pop rdi
    pop rsi
    pop rbx
    ret

native_append_cstring:
    push rbx
    push rsi
    push rdi
    mov rsi, rcx
    mov rdi, rdx
    xor rbx, rbx
native_append_find_end:
    cmp byte [rdi + rbx], 0
    je native_append_copy
    inc rbx
    cmp rbx, 4095
    jb native_append_find_end
native_append_copy:
    lea r10, [rdi + rbx]
    xor r8, r8
native_append_loop:
    mov al, [rsi + r8]
    mov [r10 + r8], al
    inc r8
    test al, al
    jnz native_append_loop
    pop rdi
    pop rsi
    pop rbx
    ret

native_copy_bytes:
    push rdi
    push rsi
    mov rdi, rcx
    mov rsi, rdx
    test r8, r8
    jz native_copy_bytes_restore
    mov rcx, r8
    cld
    rep movsb
native_copy_bytes_restore:
    pop rsi
    pop rdi
    ret

native_cstring_length:
    xor rax, rax
native_cstring_length_loop:
    cmp byte [rcx + rax], 0
    je native_cstring_length_done
    inc rax
    jmp native_cstring_length_loop
native_cstring_length_done:
    ret

section .data
winhttp_name db "winhttp.dll", 0
name_winhttp_open db "WinHttpOpen", 0
name_winhttp_connect db "WinHttpConnect", 0
name_winhttp_open_request db "WinHttpOpenRequest", 0
name_winhttp_send_request db "WinHttpSendRequest", 0
name_winhttp_receive_response db "WinHttpReceiveResponse", 0
name_winhttp_query_headers db "WinHttpQueryHeaders", 0
name_winhttp_query_data_available db "WinHttpQueryDataAvailable", 0
name_winhttp_read_data db "WinHttpReadData", 0
name_winhttp_add_headers db "WinHttpAddRequestHeaders", 0
name_winhttp_close_handle db "WinHttpCloseHandle", 0
name_winhttp_set_timeouts db "WinHttpSetTimeouts", 0
name_winhttp_set_option db "WinHttpSetOption", 0
name_winhttp_complete_upgrade db "WinHttpWebSocketCompleteUpgrade", 0
name_winhttp_websocket_send db "WinHttpWebSocketSend", 0
name_winhttp_websocket_receive db "WinHttpWebSocketReceive", 0
name_winhttp_websocket_close db "WinHttpWebSocketClose", 0
method_get db "GET", 0
discord_rest_url db "https://discord.com/api/v10/gateway", 0
push_rest_url db "https://api.pushbullet.com/v2/users/me", 0
discord_ws_host_ascii db "gateway.discord.gg", 0
discord_ws_path_ascii db "/?v=10&encoding=json", 0
discord_ws_query_suffix_ascii db "?v=10&encoding=json", 0
push_ws_host_ascii db "stream.pushbullet.com", 0
push_ws_path_prefix_ascii db "/websocket/", 0
push_ws_token_separator_ascii db "/", 0
user_agent_wide dw 0x0079,0x0075,0x006c,0x002d,0x0076,0x0065,0x006e,0x0064,0x0069,0x006e,0x0067,0x002d,0x006d,0x0061,0x0063,0x0068,0x0069,0x006e,0x0065,0x002f,0x0031,0
get_wide dw 0x0047,0x0045,0x0054,0
discord_header_prefix_ascii db "Authorization: Bot ", 0
push_header_prefix_ascii db "Access-Token: ", 0
content_header_ascii db 13,10,"Content-Type: application/json",13,10,0

section .bss
winhttp_module resq 1
fn_winhttp_open resq 1
fn_winhttp_connect resq 1
fn_winhttp_open_request resq 1
fn_winhttp_send_request resq 1
fn_winhttp_receive_response resq 1
fn_winhttp_query_headers resq 1
fn_winhttp_query_data_available resq 1
fn_winhttp_read_data resq 1
fn_winhttp_add_headers resq 1
fn_winhttp_close_handle resq 1
fn_winhttp_set_timeouts resq 1
fn_winhttp_set_option resq 1
fn_winhttp_complete_upgrade resq 1
fn_winhttp_websocket_send resq 1
fn_winhttp_websocket_receive resq 1
fn_winhttp_websocket_close resq 1
network_host_ascii resb 512
network_path_ascii resb 4096
network_method_ascii resb 64
network_host_wide resw 512
network_path_wide resw 4096
network_method_wide resw 64
network_header_wide resw 4096
network_response resb 65536
network_response_length resq 1
network_status resd 1
network_status_length resd 1
network_io_size resd 1
network_is_discord resd 1
network_transport_busy resd 1
network_ws_handle_gateway resq 1
network_ws_handle_push resq 1
network_push_ws_url_override resq 1
network_gateway_response resb 65536
network_gateway_response_length resq 1
network_push_response resb 65536
network_push_response_length resq 1
network_ws_gateway_buffer resb 65536
network_ws_gateway_read resq 1
network_ws_gateway_type resd 1
network_ws_push_buffer resb 65536
network_ws_push_read resq 1
network_ws_push_type resd 1
network_ws_handle resq 1
network_ws_buffer resb 65536
network_ws_read resq 1
network_ws_type resd 1
