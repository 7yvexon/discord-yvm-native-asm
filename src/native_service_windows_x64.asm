bits 64
default rel

global yul_native_service_run
global service_find_root_timestamp
global service_number_value
global service_interaction_id
global service_interaction_id_length

extern runtime_db_open
extern runtime_db_close
extern runtime_create_order
extern runtime_process_push_buffer
extern runtime_support_total
extern runtime_config_value
extern runtime_json_value
extern runtime_json_validate_structure
extern runtime_write
extern yul_platform_now_unix
extern yul_native_network_start
extern yul_native_network_rest_json
extern yul_native_network_ws_open
extern yul_native_network_ws_send_text
extern yul_native_network_ws_recv
extern yul_native_network_ws_close
extern yul_native_network_sleep
extern network_response
extern network_response_length
extern network_status
extern network_gateway_response
extern network_gateway_response_length
extern network_push_response
extern network_push_response_length
extern network_push_ws_url_override
extern yul_sqlite_prepare
extern yul_sqlite_bind_text
extern yul_sqlite_bind_int64
extern yul_sqlite_step
extern yul_sqlite_finalize
extern yul_sqlite_exec
extern yul_sqlite_column_text
extern CreateThread
extern WaitForSingleObject
extern CloseHandle
extern SetConsoleCtrlHandler

extern service_mode
extern service_buffer_mode
extern service_message
extern service_message_length
extern argument_ptrs
extern argument_lengths
extern argument_count
extern command_index
extern config_value
extern db_handle
extern statement_handle
extern json_buffer
extern json_length
extern discord_token
extern discord_token_length
extern pushbullet_token
extern pushbullet_token_length
extern push_id_buffer
extern push_id_length
extern credit_order_id
extern credit_order_id_length
extern credit_discord_id
extern credit_discord_id_length
extern order_id_buffer
extern amount_value
extern order_dm_required

section .text

yul_native_service_run:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 0x20
    mov dword [rel service_mode], 1
    mov dword [rel service_stop], 0
    mov dword [rel service_event_busy], 0
    mov dword [rel service_heartbeat_active], 0
    mov qword [rel service_message_length], 0
    call service_load_config
    cmp qword [rel service_stream_length], 0
    je service_run_stream_default
    lea rax, [rel service_stream]
    mov [rel network_push_ws_url_override], rax
    jmp service_run_stream_ready
service_run_stream_default:
    mov qword [rel network_push_ws_url_override], 0
service_run_stream_ready:
    call runtime_db_open
    test eax, eax
    jnz service_run_fail
    call runtime_db_close
    call service_load_cursor
    call service_load_gateway_state
    call service_load_panel_message
    sub rsp, 0x20
    lea rcx, [rel service_console_handler]
    mov edx, 1
    call SetConsoleCtrlHandler
    add rsp, 0x20
    call yul_native_network_start
    test eax, eax
    jnz service_run_fail
    cmp qword [rel discord_token_length], 0
    je service_run_no_gateway_setup
    call service_register_commands
    call service_publish_panel
    call service_retry_pending_dms
service_run_no_gateway_setup:
    cmp qword [rel pushbullet_token_length], 0
    je service_run_push_open_done
    call service_push_open_once
service_run_push_open_done:
    cmp qword [rel discord_token_length], 0
    je service_run_no_gateway
    sub rsp, 0x40
    xor ecx, ecx
    xor edx, edx
    lea r8, [rel service_gateway_thread]
    xor r9d, r9d
    mov dword [rsp + 0x20], 0
    lea rax, [rel service_gateway_thread_id]
    mov [rsp + 0x28], rax
    call CreateThread
    add rsp, 0x40
    mov [rel service_gateway_thread_handle], rax
    test rax, rax
    jnz service_run_no_gateway
    call service_console_handler
    jmp service_run_fail
service_run_no_gateway:
    cmp qword [rel pushbullet_token_length], 0
    jne service_run_push_ready
    jmp service_run_wait_gateway
service_run_push_ready:
    call service_push_loop
    jmp service_run_wait_gateway
service_run_idle:
    call service_idle_loop
service_run_wait_gateway:
    mov rcx, [rel service_gateway_thread_handle]
    test rcx, rcx
    jz service_run_success
    mov edx, 0xffffffff
    sub rsp, 0x20
    call WaitForSingleObject
    add rsp, 0x20
service_run_success:
    mov dword [rel service_mode], 0
    xor eax, eax
    jmp service_run_return
service_run_fail:
    mov dword [rel service_mode], 0
    mov eax, 1
service_run_return:
    add rsp, 0x20
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

service_idle_loop:
    sub rsp, 0x28
service_idle_wait:
    cmp dword [rel service_stop], 0
    jne service_idle_done
    mov ecx, 1000
    call yul_native_network_sleep
    jmp service_idle_wait
service_idle_done:
    add rsp, 0x28
    ret

service_event_lock:
    sub rsp, 0x28
service_event_lock_loop:
    xor eax, eax
    mov edx, 1
    lock cmpxchg [rel service_event_busy], edx
    je service_event_lock_done
    mov ecx, 1
    call yul_native_network_sleep
    jmp service_event_lock_loop
service_event_lock_done:
    add rsp, 0x28
    ret

service_event_unlock:
    mov dword [rel service_event_busy], 0
    ret

service_console_handler:
    mov dword [rel service_stop], 1
    mov dword [rel service_heartbeat_active], 0
    xor ecx, ecx
    call yul_native_network_ws_close
    mov ecx, 1
    call yul_native_network_ws_close
    mov eax, 1
    ret

service_load_config:
    sub rsp, 0x28
    mov qword [rel service_application_length], 0
    mov qword [rel service_guild_length], 0
    mov qword [rel service_panel_length], 0
    mov qword [rel service_admin_length], 0
    mov qword [rel service_gateway_length], 0
    mov qword [rel service_stream_length], 0
    mov qword [rel service_intents], 1
    mov qword [rel service_session_id_length], 0
    mov qword [rel service_resume_url_length], 0
    mov qword [rel service_sequence], 0
    mov dword [rel service_sequence_valid], 0
    lea rcx, [rel key_application]
    mov edx, key_application_end-key_application-1
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz service_load_guild
    lea rcx, [rel config_value]
    lea rdx, [rel service_application]
    mov r8d, 128
    call service_copy_cstring
    mov [rel service_application_length], rax
service_load_guild:
    lea rcx, [rel key_guild]
    mov edx, key_guild_end-key_guild-1
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz service_load_panel
    lea rcx, [rel config_value]
    lea rdx, [rel service_guild]
    mov r8d, 128
    call service_copy_cstring
    mov [rel service_guild_length], rax
service_load_panel:
    lea rcx, [rel key_panel]
    mov edx, key_panel_end-key_panel-1
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz service_load_admin
    lea rcx, [rel config_value]
    lea rdx, [rel service_panel]
    mov r8d, 128
    call service_copy_cstring
    mov [rel service_panel_length], rax
service_load_admin:
    lea rcx, [rel key_admin]
    mov edx, key_admin_end-key_admin-1
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz service_load_intents
    lea rcx, [rel config_value]
    lea rdx, [rel service_admin]
    mov r8d, 128
    call service_copy_cstring
    mov [rel service_admin_length], rax
service_load_intents:
    lea rcx, [rel key_intents]
    mov edx, key_intents_end-key_intents-1
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz service_load_stream
    lea rcx, [rel config_value]
    call service_parse_decimal
    test rax, rax
    jz service_load_stream
    mov [rel service_intents], rax
service_load_stream:
    lea rcx, [rel key_gateway]
    mov edx, key_gateway_end-key_gateway-1
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz service_load_gateway_default
    lea rcx, [rel config_value]
    lea rdx, [rel service_gateway_url]
    mov r8d, 2048
    call service_copy_cstring
    mov [rel service_gateway_length], rax
    jmp service_load_stream_config
service_load_gateway_default:
    lea rcx, [rel gateway_ws_url]
    lea rdx, [rel service_gateway_url]
    call service_copy_cstring
    mov [rel service_gateway_length], rax
service_load_stream_config:
    lea rcx, [rel key_stream]
    mov edx, key_stream_end-key_stream-1
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz service_load_done
    lea rcx, [rel config_value]
    lea rdx, [rel service_stream]
    mov r8d, 4096
    call service_copy_cstring
    mov [rel service_stream_length], rax
service_load_done:
    add rsp, 0x28
    ret

service_load_cursor:
    sub rsp, 0x28
    lea rcx, [rel setting_push_cursor]
    mov edx, setting_push_cursor_end-setting_push_cursor-1
    lea r8, [rel service_decimal_tmp]
    mov r9d, 64
    call service_load_setting
    test eax, eax
    jnz service_load_cursor_return
    lea rcx, [rel service_decimal_tmp]
    call service_parse_decimal
    mov [rel service_cursor], rax
service_load_cursor_return:
    add rsp, 0x28
    ret

service_save_cursor:
    sub rsp, 0x28
    lea rdi, [rel service_decimal_tmp]
    mov rax, [rel service_cursor]
    call service_append_u64
    mov byte [rdi], 0
    mov rax, rdi
    lea rcx, [rel service_decimal_tmp]
    sub rax, rcx
    mov [rel service_value_length], rax
    lea rcx, [rel setting_push_cursor]
    mov edx, setting_push_cursor_end-setting_push_cursor-1
    lea r8, [rel service_decimal_tmp]
    mov r9, [rel service_value_length]
    call service_save_setting
    add rsp, 0x28
    ret

service_load_gateway_state:
    sub rsp, 0x28
    lea rcx, [rel setting_gateway_session]
    mov edx, setting_gateway_session_end-setting_gateway_session-1
    lea r8, [rel service_session_id]
    mov r9d, 256
    call service_load_setting
    test eax, eax
    jnz service_load_gateway_resume
    mov rax, [rel service_value_length]
    mov [rel service_session_id_length], rax
service_load_gateway_resume:
    lea rcx, [rel setting_gateway_resume]
    mov edx, setting_gateway_resume_end-setting_gateway_resume-1
    lea r8, [rel service_resume_url]
    mov r9d, 1024
    call service_load_setting
    test eax, eax
    jnz service_load_gateway_sequence
    mov rax, [rel service_value_length]
    mov [rel service_resume_url_length], rax
service_load_gateway_sequence:
    lea rcx, [rel setting_gateway_sequence]
    mov edx, setting_gateway_sequence_end-setting_gateway_sequence-1
    lea r8, [rel service_decimal_tmp]
    mov r9d, 64
    call service_load_setting
    test eax, eax
    jnz service_load_gateway_state_return
    lea rcx, [rel service_decimal_tmp]
    call service_parse_decimal
    mov [rel service_sequence], rax
    cmp rax, 0
    je service_load_gateway_state_return
    mov dword [rel service_sequence_valid], 1
service_load_gateway_state_return:
    add rsp, 0x28
    ret

service_save_gateway_state:
    sub rsp, 0x28
    cmp qword [rel service_session_id_length], 0
    je service_save_gateway_sequence
    lea rcx, [rel setting_gateway_session]
    mov edx, setting_gateway_session_end-setting_gateway_session-1
    lea r8, [rel service_session_id]
    mov r9, [rel service_session_id_length]
    call service_save_setting
    cmp qword [rel service_resume_url_length], 0
    je service_save_gateway_sequence
    lea rcx, [rel setting_gateway_resume]
    mov edx, setting_gateway_resume_end-setting_gateway_resume-1
    lea r8, [rel service_resume_url]
    mov r9, [rel service_resume_url_length]
    call service_save_setting
service_save_gateway_sequence:
    cmp dword [rel service_sequence_valid], 0
    je service_save_gateway_state_return
    lea rdi, [rel service_decimal_tmp]
    mov rax, [rel service_sequence]
    call service_append_u64
    mov byte [rdi], 0
    mov rax, rdi
    lea rcx, [rel service_decimal_tmp]
    sub rax, rcx
    mov [rel service_value_length], rax
    lea rcx, [rel setting_gateway_sequence]
    mov edx, setting_gateway_sequence_end-setting_gateway_sequence-1
    lea r8, [rel service_decimal_tmp]
    mov r9, [rel service_value_length]
    call service_save_setting
service_save_gateway_state_return:
    add rsp, 0x28
    ret

service_load_panel_message:
    sub rsp, 0x28
    mov qword [rel service_panel_message_length], 0
    mov byte [rel service_panel_message], 0
    lea rcx, [rel setting_panel_message]
    mov edx, setting_panel_message_end-setting_panel_message-1
    lea r8, [rel service_panel_message]
    mov r9d, 256
    call service_load_setting
    test eax, eax
    jnz service_load_panel_message_return
    mov rax, [rel service_value_length]
    mov [rel service_panel_message_length], rax
service_load_panel_message_return:
    add rsp, 0x28
    ret

service_load_setting:
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 0x28
    mov r12, rcx
    mov r13, rdx
    mov r14, r8
    mov r15, r9
    mov qword [rel service_number_value], 1
    call runtime_db_open
    test eax, eax
    jnz service_load_setting_return
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_get_setting]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz service_load_setting_close
    mov rcx, [rel statement_handle]
    mov edx, 1
    mov r8, r12
    mov r9, r13
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 100
    jne service_load_setting_finalize
    mov rcx, [rel statement_handle]
    xor edx, edx
    call yul_sqlite_column_text
    test rax, rax
    jz service_load_setting_finalize
    mov rsi, rax
    mov rdi, r14
    xor rcx, rcx
service_load_setting_copy:
    cmp rcx, r15
    jae service_load_setting_copy_fail
    mov al, [rsi + rcx]
    mov [rdi + rcx], al
    inc rcx
    test al, al
    jnz service_load_setting_copy
    dec rcx
    mov [rel service_value_length], rcx
    mov qword [rel service_number_value], 0
    jmp service_load_setting_finalize
service_load_setting_copy_fail:
    mov byte [rdi], 0
service_load_setting_finalize:
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
service_load_setting_close:
    call runtime_db_close
    mov rax, [rel service_number_value]
service_load_setting_return:
    add rsp, 0x28
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    ret

service_save_setting:
    push r12
    push r13
    push r14
    push r15
    sub rsp, 0x28
    mov r12, rcx
    mov r13, rdx
    mov r14, r8
    mov r15, r9
    mov qword [rel service_number_value], 1
    call runtime_db_open
    test eax, eax
    jnz service_save_setting_return
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_set_setting]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz service_save_setting_close
    mov rcx, [rel statement_handle]
    mov edx, 1
    mov r8, r12
    mov r9, r13
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 2
    mov r8, r14
    mov r9, r15
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 101
    jne service_save_setting_finalize
    mov qword [rel service_number_value], 0
service_save_setting_finalize:
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
service_save_setting_close:
    call runtime_db_close
    mov rax, [rel service_number_value]
service_save_setting_return:
    add rsp, 0x28
    pop r15
    pop r14
    pop r13
    pop r12
    ret

service_register_commands:
    sub rsp, 0x28
    cmp qword [rel service_application_length], 0
    je service_register_return
    cmp qword [rel service_guild_length], 0
    je service_register_return
    lea rcx, [rel service_url]
    lea rdx, [rel discord_api_prefix]
    call service_copy_cstring
    lea rcx, [rel path_applications]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel service_application]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel path_guilds]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel service_guild]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel path_commands]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel service_url]
    lea rdx, [rel method_put]
    lea r8, [rel discord_token]
    lea r9, [rel commands_body]
    call yul_native_network_rest_json
service_register_return:
    add rsp, 0x28
    ret

service_publish_panel:
    sub rsp, 0x28
    cmp qword [rel service_panel_length], 0
    je service_publish_return
    lea rcx, [rel service_url]
    lea rdx, [rel discord_api_prefix]
    call service_copy_cstring
    lea rcx, [rel path_channels]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel service_panel]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel path_messages]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel service_url]
    lea rdx, [rel method_post]
    lea r8, [rel discord_token]
    lea r9, [rel panel_body]
    call yul_native_network_rest_json
    test eax, eax
    jnz service_publish_return
    lea rcx, [rel network_response]
    lea rdx, [rel json_id_key]
    lea r8, [rel service_panel_message]
    mov r9d, 256
    call service_find_root_string
    test eax, eax
    jnz service_publish_return
    mov rax, [rel service_value_length]
    test rax, rax
    jz service_publish_fail
    mov [rel service_panel_message_length], rax
    lea rcx, [rel setting_panel_message]
    mov edx, setting_panel_message_end-setting_panel_message-1
    lea r8, [rel service_panel_message]
    mov r9, [rel service_panel_message_length]
    call service_save_setting
    jmp service_publish_return
service_publish_fail:
    mov eax, 1
service_publish_return:
    add rsp, 0x28
    ret

service_gateway_thread:
    sub rsp, 8
    call service_gateway_loop
    add rsp, 8
    xor eax, eax
    ret

service_gateway_loop:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 0x20
service_gateway_reconnect:
    cmp dword [rel service_stop], 0
    jne service_gateway_done
    cmp qword [rel service_session_id_length], 0
    je service_gateway_initial_url
    cmp dword [rel service_sequence_valid], 0
    je service_gateway_initial_url
    cmp qword [rel service_resume_url_length], 0
    je service_gateway_initial_url
    mov r12d, 1
    lea rdx, [rel service_resume_url]
    jmp service_gateway_open
service_gateway_initial_url:
    xor r12d, r12d
    lea rdx, [rel service_gateway_url]
service_gateway_open:
    xor ecx, ecx
    call yul_native_network_ws_open
    test eax, eax
    jz service_gateway_connected
    test r12d, r12d
    jz service_gateway_retry
    xor r12d, r12d
    lea rdx, [rel service_gateway_url]
    jmp service_gateway_open
service_gateway_connected:
    mov dword [rel service_gateway_ready], 0
    mov dword [rel service_heartbeat_active], 0
service_gateway_messages:
    cmp dword [rel service_stop], 0
    jne service_gateway_close
    xor ecx, ecx
    call yul_native_network_ws_recv
    test eax, eax
    jnz service_gateway_close
    lea rcx, [rel network_gateway_response]
    mov rdx, [rel network_gateway_response_length]
    call service_validate_json
    test eax, eax
    jnz service_gateway_close
    call service_event_lock
    call service_update_sequence
    call service_gateway_dispatch
    mov ebx, eax
    call service_event_unlock
    mov eax, ebx
    test eax, eax
    jnz service_gateway_close
    jmp service_gateway_messages
service_gateway_close:
    mov dword [rel service_heartbeat_active], 0
    mov rcx, [rel service_heartbeat_thread_handle]
    test rcx, rcx
    jz service_gateway_save
    mov edx, 0xffffffff
    sub rsp, 0x20
    call WaitForSingleObject
    add rsp, 0x20
    mov rcx, [rel service_heartbeat_thread_handle]
    sub rsp, 0x20
    call CloseHandle
    add rsp, 0x20
    mov qword [rel service_heartbeat_thread_handle], 0
service_gateway_save:
    call service_event_lock
    call service_save_gateway_state
    call service_event_unlock
    xor ecx, ecx
    call yul_native_network_ws_close
service_gateway_retry:
    mov ecx, 5000
    call yul_native_network_sleep
    jmp service_gateway_reconnect
service_gateway_done:
    add rsp, 0x20
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

service_gateway_dispatch:
    push rbx
    sub rsp, 0x20
    lea rcx, [rel network_gateway_response]
    lea rdx, [rel json_op_pattern]
    call service_find_root_number
    test eax, eax
    jnz service_gateway_dispatch_invalid
    mov eax, [rel service_number_value]
    cmp eax, 0
    je service_gateway_check_ready
    cmp eax, 10
    je service_gateway_dispatch_hello
    cmp eax, 1
    je service_gateway_dispatch_heartbeat
    cmp eax, 11
    je service_gateway_dispatch_ok
    cmp eax, 7
    je service_gateway_dispatch_reconnect
    cmp eax, 9
    je service_gateway_dispatch_invalid
    jmp service_gateway_dispatch_ok
service_gateway_dispatch_hello:
    call service_gateway_hello
    jmp service_gateway_dispatch_return
service_gateway_dispatch_heartbeat:
    call service_gateway_send_heartbeat_locked
    jmp service_gateway_dispatch_return
service_gateway_check_ready:
    lea rcx, [rel network_gateway_response]
    lea rdx, [rel json_ready_pattern]
    call service_root_contains
    test eax, eax
    jz service_gateway_check_event
    call service_gateway_store_ready
    xor eax, eax
    jmp service_gateway_dispatch_return
service_gateway_check_event:
    lea rcx, [rel network_gateway_response]
    lea rdx, [rel json_interaction_pattern]
    call service_root_contains
    test eax, eax
    jnz service_gateway_interaction
    lea rcx, [rel network_gateway_response]
    lea rdx, [rel json_interaction_pattern_spaced]
    call service_root_contains
    test eax, eax
    jz service_gateway_dispatch_ok
service_gateway_interaction:
    call service_handle_interaction
    xor eax, eax
    jmp service_gateway_dispatch_return
service_gateway_check_reconnect:
    mov qword [rel service_session_id_length], 0
    mov qword [rel service_resume_url_length], 0
    mov qword [rel service_sequence], 0
    mov dword [rel service_sequence_valid], 0
    mov eax, 1
    jmp service_gateway_dispatch_return
service_gateway_check_reconnect_requested:
    mov eax, 1
    jmp service_gateway_dispatch_return
service_gateway_dispatch_invalid:
    jmp service_gateway_check_reconnect
service_gateway_dispatch_reconnect:
    jmp service_gateway_check_reconnect_requested
service_gateway_dispatch_ok:
    xor eax, eax
service_gateway_dispatch_return:
    add rsp, 0x20
    pop rbx
    ret

service_gateway_hello:
    lea rcx, [rel network_gateway_response]
    lea rdx, [rel json_heartbeat_interval_key]
    call service_find_number
    test eax, eax
    jnz service_gateway_hello_default
    mov rax, [rel service_number_value]
    mov [rel service_heartbeat_interval], rax
service_gateway_hello_default:
    cmp qword [rel service_heartbeat_interval], 0
    jne service_gateway_hello_send
    mov qword [rel service_heartbeat_interval], 45000
service_gateway_hello_send:
    cmp qword [rel service_session_id_length], 0
    je service_gateway_build_identify
    cmp dword [rel service_sequence_valid], 0
    je service_gateway_build_identify
    call service_build_resume
    jmp service_gateway_send_hello_payload
service_gateway_build_identify:
    call service_build_identify
service_gateway_send_hello_payload:
    lea rcx, [rel service_body]
    mov rdx, [rel service_body_length]
    mov r8d, 0
    sub rsp, 8
    call yul_native_network_ws_send_text
    add rsp, 8
    test eax, eax
    jnz service_gateway_hello_fail
    mov dword [rel service_heartbeat_active], 1
    sub rsp, 0x38
    xor ecx, ecx
    xor edx, edx
    lea r8, [rel service_heartbeat_thread]
    xor r9d, r9d
    mov dword [rsp + 0x20], 0
    lea rax, [rel service_heartbeat_thread_id]
    mov [rsp + 0x28], rax
    call CreateThread
    add rsp, 0x38
    mov [rel service_heartbeat_thread_handle], rax
    test rax, rax
    jz service_gateway_hello_fail
    xor eax, eax
    ret
service_gateway_hello_fail:
    mov dword [rel service_heartbeat_active], 0
    mov eax, 1
    ret

service_heartbeat_thread:
    sub rsp, 8
service_heartbeat_loop:
    cmp dword [rel service_heartbeat_active], 0
    je service_heartbeat_done
    mov ecx, [rel service_heartbeat_interval]
    call yul_native_network_sleep
    cmp dword [rel service_heartbeat_active], 0
    je service_heartbeat_done
    call service_gateway_send_heartbeat
    test eax, eax
    jz service_heartbeat_loop
    mov dword [rel service_heartbeat_active], 0
    xor ecx, ecx
    call yul_native_network_ws_close
    mov eax, 1
    jmp service_heartbeat_done
service_heartbeat_done:
    add rsp, 8
    xor eax, eax
    ret

service_gateway_send_heartbeat:
    call service_event_lock
    call service_gateway_send_heartbeat_locked
    call service_event_unlock
    ret

service_gateway_send_heartbeat_locked:
    call service_build_heartbeat
    lea rcx, [rel service_body]
    mov rdx, [rel service_body_length]
    mov r8d, 0
    sub rsp, 8
    call yul_native_network_ws_send_text
    add rsp, 8
    ret

service_build_identify:
    lea rdi, [rel service_body]
    lea rsi, [rel identify_prefix]
    call service_append_from_source
    lea rsi, [rel discord_token]
    call service_append_from_source
    lea rsi, [rel identify_mid]
    call service_append_from_source
    mov rax, [rel service_intents]
    call service_append_u64
    lea rsi, [rel identify_suffix]
    call service_append_from_source
    mov rax, rdi
    lea rcx, [rel service_body]
    sub rax, rcx
    mov [rel service_body_length], rax
    ret

service_build_resume:
    lea rdi, [rel service_body]
    lea rsi, [rel resume_prefix]
    call service_append_from_source
    lea rsi, [rel discord_token]
    call service_append_from_source
    lea rsi, [rel resume_session_mid]
    call service_append_from_source
    lea rsi, [rel service_session_id]
    call service_append_json_quoted
    lea rsi, [rel resume_sequence_mid]
    call service_append_from_source
    mov rax, [rel service_sequence]
    call service_append_u64
    lea rsi, [rel resume_suffix]
    call service_append_from_source
    mov rax, rdi
    lea rcx, [rel service_body]
    sub rax, rcx
    mov [rel service_body_length], rax
    ret

service_build_heartbeat:
    lea rdi, [rel service_body]
    lea rsi, [rel heartbeat_prefix]
    call service_append_from_source
    cmp dword [rel service_sequence_valid], 0
    je service_build_heartbeat_null
    mov rax, [rel service_sequence]
    call service_append_u64
    jmp service_build_heartbeat_done
service_build_heartbeat_null:
    lea rsi, [rel null_text]
    call service_append_from_source
service_build_heartbeat_done:
    lea rsi, [rel heartbeat_suffix]
    call service_append_from_source
    mov rax, rdi
    lea rcx, [rel service_body]
    sub rax, rcx
    mov [rel service_body_length], rax
    ret

service_update_sequence:
    lea rcx, [rel network_gateway_response]
    lea rdx, [rel json_sequence_key]
    call service_find_root_number
    test eax, eax
    jnz service_update_sequence_done
    mov rax, [rel service_number_value]
    mov [rel service_sequence], rax
    mov dword [rel service_sequence_valid], 1
service_update_sequence_done:
    ret

service_gateway_store_ready:
    sub rsp, 0x28
    mov qword [rel service_session_id_length], 0
    mov qword [rel service_resume_url_length], 0
    lea rcx, [rel network_gateway_response]
    lea rdx, [rel json_data_key]
    call service_find_object
    test eax, eax
    jnz service_gateway_store_ready_save
    lea rcx, [rel json_buffer]
    lea rdx, [rel json_session_key]
    lea r8, [rel service_session_id]
    mov r9d, 256
    call service_find_root_string
    test eax, eax
    jnz service_gateway_store_ready_resume
    mov rax, [rel service_value_length]
    mov [rel service_session_id_length], rax
service_gateway_store_ready_resume:
    lea rcx, [rel json_buffer]
    lea rdx, [rel json_resume_key]
    lea r8, [rel service_resume_url]
    mov r9d, 1024
    call service_find_root_string
    test eax, eax
    jnz service_gateway_store_ready_save
    mov rax, [rel service_value_length]
    mov [rel service_resume_url_length], rax
service_gateway_store_ready_save:
    call service_save_gateway_state
    add rsp, 0x28
    ret

service_handle_interaction:
    sub rsp, 0x28
    mov qword [rel service_interaction_id_length], 0
    mov qword [rel service_interaction_token_length], 0
    mov qword [rel service_user_length], 0
    lea rcx, [rel network_gateway_response]
    lea rdx, [rel service_json]
    mov r8, [rel network_gateway_response_length]
    call service_copy_bytes
    mov [rel service_json_length], r8
    lea rax, [rel service_json]
    mov byte [rax + r8], 0
    call service_validate_interaction_scope
    test eax, eax
    jnz service_interaction_return
    lea rcx, [rel service_json]
    lea rdx, [rel json_id_key]
    lea r8, [rel service_interaction_id]
    mov r9d, 256
    call service_find_root_string
    test eax, eax
    jnz service_interaction_return
    mov rax, [rel service_value_length]
    mov [rel service_interaction_id_length], rax
    lea rcx, [rel service_json]
    lea rdx, [rel json_token_key]
    lea r8, [rel service_interaction_token]
    mov r9d, 512
    call service_find_root_string
    test eax, eax
    jnz service_interaction_return
    mov rax, [rel service_value_length]
    mov [rel service_interaction_token_length], rax
    lea rcx, [rel service_json]
    lea rdx, [rel json_user_pattern]
    lea r8, [rel service_user]
    mov r9d, 256
    call service_find_pattern_string
    test eax, eax
    jz service_interaction_user_found
    lea rcx, [rel service_json]
    lea rdx, [rel json_user_pattern_spaced]
    lea r8, [rel service_user]
    mov r9d, 256
    call service_find_pattern_string
    test eax, eax
    jnz service_interaction_return
service_interaction_user_found:
    mov rax, [rel service_value_length]
    mov [rel service_user_length], rax
    lea rcx, [rel service_json]
    lea rdx, [rel json_type_key]
    call service_find_root_number
    test eax, eax
    jnz service_interaction_return
    mov eax, [rel service_number_value]
    cmp eax, 3
    je service_interaction_component
    cmp eax, 5
    je service_interaction_modal
    cmp eax, 2
    je service_interaction_command
    jmp service_interaction_return

service_interaction_component:
    call service_validate_button_message
    test eax, eax
    jnz service_interaction_return
    call service_select_interaction_data
    test eax, eax
    jnz service_interaction_return
    lea rcx, [rel service_json]
    lea rdx, [rel json_custom_id_key]
    lea r8, [rel service_custom_id]
    mov r9d, 256
    call service_find_string
    test eax, eax
    jnz service_interaction_return
    lea rcx, [rel service_custom_id]
    lea rdx, [rel button_id]
    call service_bytes_equal_cstring
    test eax, eax
    jz service_interaction_return
    call service_build_modal
    call service_reply_interaction
    jmp service_interaction_return

service_interaction_modal:
    call service_select_interaction_data
    test eax, eax
    jnz service_interaction_return
    lea rcx, [rel service_json]
    lea rdx, [rel component_name_pattern]
    lea r8, [rel service_name]
    mov r9d, 512
    call service_find_component_value
    test eax, eax
    jnz service_interaction_return
    mov rax, [rel service_value_length]
    mov [rel service_name_length], rax
    lea rcx, [rel service_json]
    lea rdx, [rel component_amount_pattern]
    lea r8, [rel service_amount]
    mov r9d, 64
    call service_find_component_value
    test eax, eax
    jnz service_interaction_return
    mov rax, [rel service_value_length]
    mov [rel service_amount_length], rax
    call service_prepare_order_args
    call runtime_create_order
    test eax, eax
    jnz service_interaction_order_fail
    mov qword [rel service_order_id_length], 23
    lea rsi, [rel order_reply_body]
    call service_copy_cstring_to_body
    call service_reply_interaction
    cmp dword [rel order_dm_required], 0
    je service_interaction_return
    call service_send_dm
    jmp service_interaction_return
service_interaction_order_fail:
    lea rsi, [rel order_error_body]
    call service_copy_cstring_to_body
    call service_reply_interaction
    jmp service_interaction_return

service_interaction_command:
    call service_select_interaction_data
    test eax, eax
    jnz service_interaction_return
    lea rcx, [rel service_json]
    lea rdx, [rel json_command_name_key]
    lea r8, [rel service_command]
    mov r9d, 256
    call service_find_string
    test eax, eax
    jnz service_interaction_return
    lea rcx, [rel service_command]
    lea rdx, [rel command_support]
    call service_bytes_equal_cstring
    test eax, eax
    jnz service_interaction_support
    lea rcx, [rel service_command]
    lea rdx, [rel command_panel]
    call service_bytes_equal_cstring
    test eax, eax
    jnz service_interaction_panel
    lea rcx, [rel service_command]
    lea rdx, [rel command_review]
    call service_bytes_equal_cstring
    test eax, eax
    jnz service_interaction_review
    lea rcx, [rel service_command]
    lea rdx, [rel command_ledger]
    call service_bytes_equal_cstring
    test eax, eax
    jnz service_interaction_ledger
    jmp service_interaction_return
service_interaction_support:
    call service_query_total
    call service_build_support_reply
    call service_reply_interaction
    jmp service_interaction_return
service_interaction_panel:
    call service_publish_panel
    lea rsi, [rel panel_reply_body]
    call service_copy_cstring_to_body
    call service_reply_interaction
    jmp service_interaction_return
service_interaction_review:
    lea rsi, [rel review_reply_body]
    call service_copy_cstring_to_body
    call service_reply_interaction
    jmp service_interaction_return
service_interaction_ledger:
    lea rsi, [rel ledger_reply_body]
    call service_copy_cstring_to_body
    call service_reply_interaction
service_interaction_return:
    add rsp, 0x28
    ret

service_validate_interaction_scope:
    sub rsp, 0x28
    cmp qword [rel service_application_length], 0
    je service_validate_interaction_scope_fail
    lea rcx, [rel service_json]
    lea rdx, [rel json_application_id_key]
    lea r8, [rel service_channel]
    mov r9d, 256
    call service_find_root_string
    test eax, eax
    jnz service_validate_interaction_scope_fail
    cmp qword [rel service_value_length], 0
    je service_validate_interaction_scope_fail
    lea rcx, [rel service_channel]
    lea rdx, [rel service_application]
    call service_bytes_equal_cstring
    test eax, eax
    jz service_validate_interaction_scope_fail
    cmp qword [rel service_guild_length], 0
    je service_validate_interaction_scope_fail
    lea rcx, [rel service_json]
    lea rdx, [rel json_guild_id_key]
    lea r8, [rel service_channel]
    mov r9d, 256
    call service_find_root_string
    test eax, eax
    jnz service_validate_interaction_scope_fail
    cmp qword [rel service_value_length], 0
    je service_validate_interaction_scope_fail
    lea rcx, [rel service_channel]
    lea rdx, [rel service_guild]
    call service_bytes_equal_cstring
    test eax, eax
    jz service_validate_interaction_scope_fail
    cmp qword [rel service_panel_length], 0
    je service_validate_interaction_scope_fail
    lea rcx, [rel service_json]
    lea rdx, [rel json_channel_id_key]
    lea r8, [rel service_channel]
    mov r9d, 256
    call service_find_root_string
    test eax, eax
    jnz service_validate_interaction_scope_fail
    cmp qword [rel service_value_length], 0
    je service_validate_interaction_scope_fail
    lea rcx, [rel service_channel]
    lea rdx, [rel service_panel]
    call service_bytes_equal_cstring
    test eax, eax
    jz service_validate_interaction_scope_fail
    xor eax, eax
    add rsp, 0x28
    ret
service_validate_interaction_scope_fail:
    mov eax, 1
    add rsp, 0x28
    ret

service_validate_button_message:
    sub rsp, 0x28
    cmp qword [rel service_panel_message_length], 0
    je service_validate_button_message_fail
    lea rcx, [rel service_json]
    lea rdx, [rel json_message_key]
    call service_find_object
    test eax, eax
    jnz service_validate_button_message_fail
    lea rcx, [rel json_buffer]
    lea rdx, [rel json_id_key]
    lea r8, [rel service_channel]
    mov r9d, 256
    call service_find_root_string
    test eax, eax
    jnz service_validate_button_message_fail
    cmp qword [rel service_value_length], 0
    je service_validate_button_message_fail
    lea rcx, [rel service_channel]
    lea rdx, [rel service_panel_message]
    call service_bytes_equal_cstring
    test eax, eax
    jz service_validate_button_message_fail
    xor eax, eax
    add rsp, 0x28
    ret
service_validate_button_message_fail:
    mov eax, 1
    add rsp, 0x28
    ret

service_select_interaction_data:
    sub rsp, 0x28
    lea rcx, [rel service_json]
    lea rdx, [rel json_data_key]
    call service_find_object
    test eax, eax
    jnz service_select_interaction_data_fail
    lea rcx, [rel json_buffer]
    lea rdx, [rel service_json]
    mov r8, [rel json_length]
    call service_copy_bytes
    mov [rel service_json_length], r8
    lea rax, [rel service_json]
    mov byte [rax + r8], 0
    xor eax, eax
    add rsp, 0x28
    ret
service_select_interaction_data_fail:
    mov eax, 1
    add rsp, 0x28
    ret

service_prepare_order_args:
    lea rax, [rel service_user]
    mov [rel argument_ptrs + 8], rax
    lea rax, [rel service_name]
    mov [rel argument_ptrs + 16], rax
    lea rax, [rel service_amount]
    mov [rel argument_ptrs + 24], rax
    mov rax, [rel service_user_length]
    mov [rel argument_lengths + 8], rax
    mov rax, [rel service_name_length]
    mov [rel argument_lengths + 16], rax
    mov rax, [rel service_amount_length]
    mov [rel argument_lengths + 24], rax
    mov dword [rel argument_count], 4
    mov dword [rel command_index], 0
    mov qword [rel service_message_length], 0
    ret

service_build_modal:
    lea rsi, [rel modal_body]
    jmp service_copy_cstring_to_body

service_copy_cstring_to_body:
    lea rdi, [rel service_body]
    call service_append_from_source
    mov rax, rdi
    lea rcx, [rel service_body]
    sub rax, rcx
    mov [rel service_body_length], rax
    ret

service_reply_interaction:
    sub rsp, 0x28
    lea rcx, [rel service_url]
    lea rdx, [rel discord_api_prefix]
    call service_copy_cstring
    lea rcx, [rel path_interactions]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel service_interaction_id]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel path_interaction_token]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel service_interaction_token]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel path_callback]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel service_url]
    lea rdx, [rel method_post]
    lea r8, [rel discord_token]
    lea r9, [rel service_body]
    call yul_native_network_rest_json
    add rsp, 0x28
    ret

service_send_dm:
    sub rsp, 0x28
    lea rdi, [rel service_body]
    lea rsi, [rel dm_channel_prefix]
    call service_append_from_source
    lea rsi, [rel service_user]
    call service_append_json_quoted
    lea rsi, [rel dm_channel_suffix]
    call service_append_from_source
    mov rax, rdi
    lea rcx, [rel service_body]
    sub rax, rcx
    mov [rel service_body_length], rax
    lea rcx, [rel service_url]
    lea rdx, [rel discord_api_prefix]
    call service_copy_cstring
    lea rcx, [rel path_users_me_channels]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel service_url]
    lea rdx, [rel method_post]
    lea r8, [rel discord_token]
    lea r9, [rel service_body]
    call yul_native_network_rest_json
    test eax, eax
    jnz service_dm_failed
    lea rcx, [rel network_response]
    lea rdx, [rel json_id_key]
    lea r8, [rel service_channel]
    mov r9d, 256
    call service_find_root_string
    test eax, eax
    jnz service_dm_failed
    lea rdi, [rel service_body]
    lea rsi, [rel dm_message_prefix]
    call service_append_from_source
    lea rsi, [rel order_id_buffer]
    call service_append_json_quoted
    lea rsi, [rel dm_message_suffix]
    call service_append_from_source
    mov rax, rdi
    lea rcx, [rel service_body]
    sub rax, rcx
    mov [rel service_body_length], rax
    lea rcx, [rel service_url]
    lea rdx, [rel discord_api_prefix]
    call service_copy_cstring
    lea rcx, [rel path_channels]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel service_channel]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel path_messages]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel service_url]
    lea rdx, [rel method_post]
    lea r8, [rel discord_token]
    lea r9, [rel service_body]
    call yul_native_network_rest_json
    test eax, eax
    jnz service_dm_failed
    lea rcx, [rel status_sent]
    call service_update_dm_status
    xor eax, eax
    jmp service_send_dm_return
service_dm_failed:
    lea rcx, [rel status_failed]
    call service_update_dm_status
    mov eax, 1
service_send_dm_return:
    add rsp, 0x28
    ret

service_update_dm_status:
    push rbx
    sub rsp, 0x20
    mov rbx, rcx
    call runtime_db_open
    test eax, eax
    jnz service_update_dm_return
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_update_dm]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz service_update_dm_close
    mov rcx, [rel statement_handle]
    mov edx, 1
    mov r8, rbx
    cmp byte [rbx], 'S'
    jne service_update_dm_status_failed_length
    mov r9d, 4
    jmp service_update_dm_status_bind
service_update_dm_status_failed_length:
    mov r9d, 6
service_update_dm_status_bind:
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 2
    lea r8, [rel order_id_buffer]
    mov r9, [rel service_order_id_length]
    test r9, r9
    jnz service_update_dm_bind_order
    mov r9d, 23
service_update_dm_bind_order:
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
service_update_dm_close:
    call runtime_db_close
service_update_dm_return:
    add rsp, 0x20
    pop rbx
    ret

service_update_payment_dm_status:
    push rbx
    sub rsp, 0x20
    mov rbx, rcx
    call runtime_db_open
    test eax, eax
    jnz service_update_payment_dm_return
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_update_payment_dm]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz service_update_payment_dm_close
    mov rcx, [rel statement_handle]
    mov edx, 1
    mov r8, rbx
    cmp byte [rbx], 'S'
    jne service_update_payment_dm_failed_length
    mov r9d, 4
    jmp service_update_payment_dm_bind
service_update_payment_dm_failed_length:
    mov r9d, 6
service_update_payment_dm_bind:
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 2
    lea r8, [rel credit_order_id]
    mov r9, [rel credit_order_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
service_update_payment_dm_close:
    call runtime_db_close
service_update_payment_dm_return:
    add rsp, 0x20
    pop rbx
    ret

service_retry_pending_dms:
    sub rsp, 0x28
    mov qword [rel service_order_id_length], 0
    cmp qword [rel discord_token_length], 0
    je service_retry_pending_dms_return
    call runtime_db_open
    test eax, eax
    jnz service_retry_pending_dms_return
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_pending_dm]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz service_retry_pending_dms_close
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 100
    jne service_retry_pending_dms_finalize
    mov rcx, [rel statement_handle]
    xor edx, edx
    call yul_sqlite_column_text
    test rax, rax
    jz service_retry_pending_dms_finalize
    mov rcx, rax
    lea rdx, [rel order_id_buffer]
    call service_copy_cstring
    mov [rel service_order_id_length], rax
    mov rcx, [rel statement_handle]
    mov edx, 1
    call yul_sqlite_column_text
    test rax, rax
    jz service_retry_pending_dms_finalize
    mov rcx, rax
    lea rdx, [rel service_user]
    call service_copy_cstring
    mov [rel service_user_length], rax
service_retry_pending_dms_finalize:
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
service_retry_pending_dms_close:
    call runtime_db_close
    cmp qword [rel service_order_id_length], 0
    je service_retry_pending_dms_return
    call service_send_dm
service_retry_pending_dms_return:
    add rsp, 0x28
    ret

service_query_total:
    sub rsp, 0x28
    lea rax, [rel service_user]
    mov [rel argument_ptrs + 8], rax
    mov rax, [rel service_user_length]
    mov [rel argument_lengths + 8], rax
    mov dword [rel argument_count], 2
    mov dword [rel command_index], 0
    mov qword [rel service_message_length], 0
    call runtime_support_total
    cmp qword [rel service_message_length], 0
    je service_query_total_done
    mov rax, [rel service_message_length]
    dec rax
    lea rdx, [rel service_message]
    cmp byte [rdx + rax], 10
    jne service_query_total_done
    mov [rel service_message_length], rax
    mov byte [rdx + rax], 0
service_query_total_done:
    add rsp, 0x28
    ret

service_build_support_reply:
    lea rdi, [rel service_body]
    lea rsi, [rel support_reply_prefix]
    call service_append_from_source
    lea rsi, [rel service_message]
    call service_append_from_source
    lea rsi, [rel support_reply_suffix]
    call service_append_from_source
    mov rax, rdi
    lea rcx, [rel service_body]
    sub rax, rcx
    mov [rel service_body_length], rax
    ret

service_push_loop:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 0x20
service_push_reconnect:
    cmp dword [rel service_stop], 0
    jne service_push_done
    cmp dword [rel service_push_opened], 0
    jne service_push_messages
    mov ecx, 1
    lea rdx, [rel pushbullet_token]
    call yul_native_network_ws_open
    test eax, eax
    jnz service_push_retry
    mov dword [rel service_push_opened], 1
service_push_messages:
    cmp dword [rel service_stop], 0
    jne service_push_close
    mov ecx, 1
    call yul_native_network_ws_recv
    test eax, eax
    jnz service_push_close
    lea rcx, [rel network_push_response]
    mov rdx, [rel network_push_response_length]
    call service_validate_json
    test eax, eax
    jnz service_push_close
    lea rcx, [rel network_push_response]
    lea rdx, [rel push_type_pattern]
    call service_root_contains
    test eax, eax
    jnz service_push_process
    lea rcx, [rel network_push_response]
    lea rdx, [rel push_type_pattern_spaced]
    call service_root_contains
    test eax, eax
    jnz service_push_process
    lea rcx, [rel network_push_response]
    lea rdx, [rel tickle_type_pattern]
    call service_root_contains
    test eax, eax
    jnz service_push_tickle
    lea rcx, [rel network_push_response]
    lea rdx, [rel tickle_type_pattern_spaced]
    call service_root_contains
    test eax, eax
    jnz service_push_tickle
    jmp service_push_messages
service_push_process:
    call service_event_lock
    call service_process_push_message
    call service_event_unlock
    jmp service_push_messages
service_push_tickle:
    call service_event_lock
    call service_poll_pushes
    call service_event_unlock
    jmp service_push_messages
service_push_close:
    mov ecx, 1
    call yul_native_network_ws_close
    mov dword [rel service_push_opened], 0
service_push_retry:
    mov ecx, 5000
    call yul_native_network_sleep
    jmp service_push_reconnect
service_push_done:
    add rsp, 0x20
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

service_push_open_once:
    sub rsp, 8
    mov ecx, 1
    lea rdx, [rel pushbullet_token]
    call yul_native_network_ws_open
    add rsp, 8
    test eax, eax
    jnz service_push_open_once_return
    mov dword [rel service_push_opened], 1
service_push_open_once_return:
    ret

service_process_push_message:
    sub rsp, 0x28
    lea rcx, [rel network_push_response]
    lea rdx, [rel push_object_pattern]
    call service_find_object
    test eax, eax
    jnz service_process_push_return
    call service_process_push_object
service_process_push_return:
    add rsp, 0x28
    ret

service_process_push_object:
    sub rsp, 0x28
    mov qword [rel service_message_length], 0
    mov qword [rel credit_order_id_length], 0
    call runtime_process_push_buffer
    mov [rel service_processing_result], eax
    cmp dword [rel service_processing_result], 0
    jne service_process_push_object_done
    lea rcx, [rel service_message]
    lea rdx, [rel consumed_pattern]
    call service_contains
    test eax, eax
    jz service_process_push_object_done
    cmp qword [rel credit_order_id_length], 0
    je service_process_push_object_done
    call service_send_payment_dm
    mov qword [rel credit_order_id_length], 0
service_process_push_object_done:
    mov eax, [rel service_processing_result]
    add rsp, 0x28
    ret

service_send_payment_dm:
    sub rsp, 0x28
    lea rcx, [rel credit_discord_id]
    lea rdx, [rel service_user]
    call service_copy_cstring
    mov [rel service_user_length], rax
    lea rcx, [rel service_url]
    lea rdx, [rel discord_api_prefix]
    call service_copy_cstring
    lea rcx, [rel path_channels]
    lea rdx, [rel service_url]
    call service_append_cstring
    call service_lookup_dm_channel
    test eax, eax
    jnz service_payment_failed
    lea rdi, [rel service_body]
    lea rsi, [rel payment_message_prefix]
    call service_append_from_source
    lea rsi, [rel credit_order_id]
    call service_append_json_quoted
    lea rsi, [rel payment_message_middle]
    call service_append_from_source
    lea rsi, [rel push_id_buffer]
    call service_append_json_quoted
    lea rsi, [rel payment_message_suffix]
    call service_append_from_source
    mov rax, rdi
    lea rcx, [rel service_body]
    sub rax, rcx
    mov [rel service_body_length], rax
    lea rcx, [rel service_url]
    lea rdx, [rel discord_api_prefix]
    call service_copy_cstring
    lea rcx, [rel path_channels]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel service_channel]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel path_messages]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rcx, [rel service_url]
    lea rdx, [rel method_post]
    lea r8, [rel discord_token]
    lea r9, [rel service_body]
    call yul_native_network_rest_json
    test eax, eax
    jnz service_payment_failed
    lea rcx, [rel status_sent]
    call service_update_payment_dm_status
    xor eax, eax
    jmp service_payment_return
service_payment_failed:
    lea rcx, [rel status_failed]
    call service_update_payment_dm_status
    mov eax, 1
service_payment_return:
    add rsp, 0x28
    ret

service_lookup_dm_channel:
    sub rsp, 0x28
    lea rcx, [rel service_url]
    lea rdx, [rel discord_api_prefix]
    call service_copy_cstring
    lea rcx, [rel path_users_me_channels]
    lea rdx, [rel service_url]
    call service_append_cstring
    lea rdi, [rel service_body]
    lea rsi, [rel dm_channel_prefix]
    call service_append_from_source
    lea rsi, [rel service_user]
    call service_append_json_quoted
    lea rsi, [rel dm_channel_suffix]
    call service_append_from_source
    mov rax, rdi
    lea rcx, [rel service_body]
    sub rax, rcx
    mov [rel service_body_length], rax
    lea rcx, [rel service_url]
    lea rdx, [rel method_post]
    lea r8, [rel discord_token]
    lea r9, [rel service_body]
    call yul_native_network_rest_json
    test eax, eax
    jnz service_lookup_dm_fail
    lea rcx, [rel network_response]
    lea rdx, [rel json_id_key]
    lea r8, [rel service_channel]
    mov r9d, 256
    call service_find_root_string
    add rsp, 0x28
    ret
service_lookup_dm_fail:
    mov eax, 1
    add rsp, 0x28
    ret

service_poll_pushes:
    sub rsp, 0x28
    mov rax, [rel service_cursor]
    mov [rel service_cursor_candidate], rax
    mov dword [rel service_poll_has_pushes], 0
    mov dword [rel service_poll_page_count], 0
    mov dword [rel service_poll_seen_count], 0
    mov qword [rel service_poll_cursor_length], 0
service_poll_page:
    mov dword [rel service_poll_page_push_count], 0
    lea rdi, [rel service_url]
    cmp qword [rel service_poll_cursor_length], 0
    jne service_poll_cursor_url
    lea rsi, [rel push_poll_prefix]
    call service_append_from_source
    mov rax, [rel service_cursor]
    call service_append_u64
    jmp service_poll_url_suffix
service_poll_cursor_url:
    lea rsi, [rel push_poll_cursor_prefix]
    call service_append_from_source
    lea rsi, [rel service_poll_cursor]
    mov rcx, [rel service_poll_cursor_length]
    call service_append_url_cursor
    test eax, eax
    jnz service_poll_error
service_poll_url_suffix:
    lea rsi, [rel push_poll_suffix]
    call service_append_from_source
    lea rcx, [rel service_url]
    lea rdx, [rel method_get]
    lea r8, [rel pushbullet_token]
    xor r9d, r9d
    call yul_native_network_rest_json
    test eax, eax
    jnz service_poll_return
    call service_process_poll_response
    test eax, eax
    jnz service_poll_error
    inc dword [rel service_poll_page_count]
    cmp qword [rel service_poll_cursor_length], 0
    je service_poll_finalize
    cmp dword [rel service_poll_page_count], 100
    jae service_poll_error
    call service_store_seen_cursor
    test eax, eax
    jnz service_poll_error
    jmp service_poll_page
service_poll_finalize:
    cmp dword [rel service_poll_has_pushes], 0
    je service_poll_return
    mov rax, [rel service_cursor_candidate]
    cmp rax, [rel service_cursor]
    jbe service_poll_return
    mov [rel service_cursor], rax
    call service_save_cursor
    jmp service_poll_return
service_poll_error:
    mov eax, 1
service_poll_return:
    add rsp, 0x28
    ret

service_process_poll_response:
    sub rsp, 0x28
    lea rcx, [rel network_response]
    mov rdx, [rel network_response_length]
    call service_validate_json
    test eax, eax
    jnz service_poll_response_error
    lea rcx, [rel network_response]
    lea rdx, [rel pushes_array_pattern]
    call service_find_root_after
    test eax, eax
    jz service_poll_response_error
    mov rsi, rax
service_poll_array_colon:
    mov al, [rsi]
    test al, al
    jz service_poll_response_error
    cmp al, ':'
    je service_poll_array_start
    inc rsi
    jmp service_poll_array_colon
service_poll_array_start:
    inc rsi
service_poll_array_start_space:
    mov al, [rsi]
    cmp al, 32
    je service_poll_array_start_space_one
    cmp al, 9
    je service_poll_array_start_space_one
    cmp al, 10
    je service_poll_array_start_space_one
    cmp al, 13
    je service_poll_array_start_space_one
    cmp al, '['
    jne service_poll_response_error
    inc rsi
service_poll_array_loop:
    mov al, [rsi]
    test al, al
    jz service_poll_response_error
    cmp al, 32
    je service_poll_array_loop_space
    cmp al, 9
    je service_poll_array_loop_space
    cmp al, 10
    je service_poll_array_loop_space
    cmp al, 13
    je service_poll_array_loop_space
    cmp al, ','
    je service_poll_array_loop_space
    cmp al, ']'
    je service_poll_array_done
    cmp al, '{'
    jne service_poll_response_error
service_poll_object_start:
    mov rcx, rsi
    call service_copy_balanced_object
    test eax, eax
    jnz service_poll_response_error
    call service_process_poll_object
    test eax, eax
    jnz service_poll_response_error
    add rsi, [rel service_object_length]
    jmp service_poll_array_loop
service_poll_array_start_space_one:
    inc rsi
    jmp service_poll_array_start_space
service_poll_array_loop_space:
    inc rsi
    jmp service_poll_array_loop
service_poll_array_done:
    call service_extract_poll_cursor
    test eax, eax
    jnz service_poll_response_error
    cmp qword [rel service_poll_cursor_length], 0
    jne service_poll_response_return
service_poll_response_return:
    xor eax, eax
    add rsp, 0x28
    ret
service_poll_response_error:
    mov eax, 1
    add rsp, 0x28
    ret

service_process_poll_object:
    sub rsp, 0x28
    call service_process_push_object
    test eax, eax
    jnz service_poll_object_error
    mov dword [rel service_poll_has_pushes], 1
    inc dword [rel service_poll_page_push_count]
    lea rcx, [rel json_buffer]
    lea rdx, [rel json_modified_key]
    call service_find_root_timestamp
    test eax, eax
    jnz service_poll_object_success
    mov rax, [rel service_number_value]
    cmp rax, [rel service_cursor_candidate]
    jbe service_poll_object_success
    mov [rel service_cursor_candidate], rax
service_poll_object_success:
    xor eax, eax
    jmp service_poll_object_return
service_poll_object_error:
    mov eax, 1
service_poll_object_return:
    add rsp, 0x28
    ret

service_extract_poll_cursor:
    push rbx
    push rsi
    push rdi
    mov qword [rel service_poll_cursor_length], 0
    mov byte [rel service_poll_cursor], 0
    lea rcx, [rel network_response]
    lea rdx, [rel json_cursor_key]
    call service_find_root_after
    test rax, rax
    jz service_extract_poll_cursor_success
    mov rsi, rax
service_extract_poll_cursor_colon:
    mov al, [rsi]
    test al, al
    jz service_extract_poll_cursor_error
    cmp al, ':'
    je service_extract_poll_cursor_value
    inc rsi
    jmp service_extract_poll_cursor_colon
service_extract_poll_cursor_value:
    inc rsi
service_extract_poll_cursor_space:
    mov al, [rsi]
    cmp al, 32
    je service_extract_poll_cursor_space_one
    cmp al, 9
    je service_extract_poll_cursor_space_one
    cmp al, 10
    je service_extract_poll_cursor_space_one
    cmp al, 13
    je service_extract_poll_cursor_space_one
    cmp al, 'n'
    je service_extract_poll_cursor_null
    cmp al, '"'
    jne service_extract_poll_cursor_error
    inc rsi
    lea rdi, [rel service_poll_cursor]
    xor ebx, ebx
service_extract_poll_cursor_string:
    mov al, [rsi]
    test al, al
    jz service_extract_poll_cursor_error
    cmp al, '"'
    je service_extract_poll_cursor_string_done
    cmp al, '\'
    je service_extract_poll_cursor_error
    cmp al, 32
    jb service_extract_poll_cursor_error
    cmp ebx, 256
    jae service_extract_poll_cursor_error
    mov [rdi + rbx], al
    inc rbx
    inc rsi
    jmp service_extract_poll_cursor_string
service_extract_poll_cursor_string_done:
    test ebx, ebx
    jz service_extract_poll_cursor_error
    mov byte [rdi + rbx], 0
    mov [rel service_poll_cursor_length], rbx
    inc rsi
    call service_validate_poll_cursor_tail
    test eax, eax
    jnz service_extract_poll_cursor_error
service_extract_poll_cursor_success:
    xor eax, eax
    jmp service_extract_poll_cursor_return
service_extract_poll_cursor_null:
    cmp byte [rsi + 1], 'u'
    jne service_extract_poll_cursor_error
    cmp byte [rsi + 2], 'l'
    jne service_extract_poll_cursor_error
    cmp byte [rsi + 3], 'l'
    jne service_extract_poll_cursor_error
    add rsi, 4
    call service_validate_poll_cursor_tail
    test eax, eax
    jnz service_extract_poll_cursor_error
    jmp service_extract_poll_cursor_success
service_extract_poll_cursor_space_one:
    inc rsi
    jmp service_extract_poll_cursor_space
service_extract_poll_cursor_error:
    mov qword [rel service_poll_cursor_length], 0
    mov byte [rel service_poll_cursor], 0
    mov eax, 1
service_extract_poll_cursor_return:
    pop rdi
    pop rsi
    pop rbx
    ret

service_validate_poll_cursor_tail:
service_validate_poll_cursor_tail_space:
    mov al, [rsi]
    cmp al, 32
    je service_validate_poll_cursor_tail_space_one
    cmp al, 9
    je service_validate_poll_cursor_tail_space_one
    cmp al, 10
    je service_validate_poll_cursor_tail_space_one
    cmp al, 13
    je service_validate_poll_cursor_tail_space_one
    cmp al, ','
    je service_validate_poll_cursor_tail_success
    cmp al, '}'
    je service_validate_poll_cursor_tail_success
    test al, al
    jz service_validate_poll_cursor_tail_success
    mov eax, 1
    ret
service_validate_poll_cursor_tail_space_one:
    inc rsi
    jmp service_validate_poll_cursor_tail_space
service_validate_poll_cursor_tail_success:
    xor eax, eax
    ret

service_store_seen_cursor:
    push rbx
    push rsi
    push rdi
    push r12
    mov r12d, [rel service_poll_seen_count]
    xor ebx, ebx
service_store_seen_cursor_check:
    cmp ebx, r12d
    jae service_store_seen_cursor_new
    mov eax, ebx
    imul eax, eax, 257
    lea rcx, [rel service_poll_seen_cursors]
    add rcx, rax
    lea rdx, [rel service_poll_cursor]
    call service_bytes_equal_cstring
    test eax, eax
    jnz service_store_seen_cursor_error
    inc ebx
    jmp service_store_seen_cursor_check
service_store_seen_cursor_new:
    cmp r12d, 100
    jae service_store_seen_cursor_error
    mov eax, r12d
    imul eax, eax, 257
    lea rdi, [rel service_poll_seen_cursors]
    add rdi, rax
    lea rsi, [rel service_poll_cursor]
service_store_seen_cursor_copy:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    test al, al
    jnz service_store_seen_cursor_copy
    inc dword [rel service_poll_seen_count]
    xor eax, eax
    jmp service_store_seen_cursor_return
service_store_seen_cursor_error:
    mov eax, 1
service_store_seen_cursor_return:
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

service_append_url_cursor:
    push rbx
    xor ebx, ebx
service_append_url_cursor_loop:
    cmp rbx, rcx
    jae service_append_url_cursor_success
    movzx eax, byte [rsi + rbx]
    cmp al, 'A'
    jb service_append_url_cursor_digit
    cmp al, 'Z'
    jbe service_append_url_cursor_plain
    cmp al, 'a'
    jb service_append_url_cursor_punctuation
    cmp al, 'z'
    jbe service_append_url_cursor_plain
service_append_url_cursor_digit:
    cmp al, '0'
    jb service_append_url_cursor_punctuation
    cmp al, '9'
    jbe service_append_url_cursor_plain
service_append_url_cursor_punctuation:
    cmp al, '-'
    je service_append_url_cursor_plain
    cmp al, '.'
    je service_append_url_cursor_plain
    cmp al, '_'
    je service_append_url_cursor_plain
    cmp al, '~'
    je service_append_url_cursor_plain
    mov byte [rdi], '%'
    mov edx, eax
    shr eax, 4
    and eax, 15
    lea r8, [rel url_hex_digits]
    mov al, [r8 + rax]
    mov [rdi + 1], al
    mov eax, edx
    and eax, 15
    mov al, [r8 + rax]
    mov [rdi + 2], al
    add rdi, 3
    jmp service_append_url_cursor_next
service_append_url_cursor_plain:
    mov [rdi], al
    inc rdi
service_append_url_cursor_next:
    inc rbx
    jmp service_append_url_cursor_loop
service_append_url_cursor_success:
    xor eax, eax
    pop rbx
    ret

service_find_object:
    push rbx
    push rsi
    push rdi
    push r12
    mov r12, rcx
    mov rbx, rdx
    call service_find_root_after
    test eax, eax
    jz service_find_object_fail
    mov rsi, rax
service_find_object_colon:
    mov al, [rsi]
    cmp al, ':'
    je service_find_object_colon_found
    test al, al
    jz service_find_object_fail
    inc rsi
    jmp service_find_object_colon
service_find_object_colon_found:
    inc rsi
service_find_object_space:
    cmp byte [rsi], 32
    je service_find_object_space_one
    cmp byte [rsi], 9
    je service_find_object_space_one
    cmp byte [rsi], 10
    je service_find_object_space_one
    cmp byte [rsi], 13
    jne service_find_object_open
service_find_object_space_one:
    inc rsi
    jmp service_find_object_space
service_find_object_open:
    cmp byte [rsi], '{'
    jne service_find_object_fail
    mov rcx, rsi
    call service_copy_balanced_object
    test eax, eax
    jnz service_find_object_fail
    xor eax, eax
    jmp service_find_object_return
service_find_object_fail:
    mov eax, 1
service_find_object_return:
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

service_copy_balanced_object:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    mov rsi, rcx
    lea rdi, [rel json_buffer]
    xor rbx, rbx
    xor r12d, r12d
    xor r13d, r13d
    xor r14d, r14d
service_copy_object_loop:
    mov al, [rsi + rbx]
    mov [rdi + rbx], al
    cmp r13d, 0
    jne service_copy_object_string
    cmp al, '"'
    jne service_copy_object_open
    mov r13d, 1
    jmp service_copy_object_next
service_copy_object_open:
    cmp al, '{'
    je service_copy_object_open_inc
    cmp al, '['
    jne service_copy_object_close
service_copy_object_open_inc:
    inc r12d
    jmp service_copy_object_next
service_copy_object_close:
    cmp al, '}'
    je service_copy_object_close_dec
    cmp al, ']'
    jne service_copy_object_next
service_copy_object_close_dec:
    dec r12d
    jmp service_copy_object_next
service_copy_object_string:
    cmp r14d, 0
    je service_copy_object_string_normal
    xor r14d, r14d
    jmp service_copy_object_next
service_copy_object_string_normal:
    cmp al, '\'
    jne service_copy_object_string_quote
    mov r14d, 1
    jmp service_copy_object_next
service_copy_object_string_quote:
    cmp al, '"'
    jne service_copy_object_next
    xor r13d, r13d
service_copy_object_next:
    inc rbx
    cmp r12d, 0
    je service_copy_object_done
    cmp rbx, 65534
    jb service_copy_object_loop
    jmp service_copy_object_fail
service_copy_object_done:
    mov byte [rdi + rbx], 0
    mov [rel service_object_length], rbx
    mov [rel json_length], rbx
    xor eax, eax
    jmp service_copy_object_return
service_copy_object_fail:
    mov eax, 1
service_copy_object_return:
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

service_copy_bytes:
    push rdi
    push rsi
    mov r10, r8
    mov rsi, rcx
    mov rdi, rdx
    mov rcx, r10
    rep movsb
    mov r8, r10
    pop rsi
    pop rdi
    ret

service_copy_cstring:
    push rsi
    push rdi
    mov rsi, rcx
    mov rdi, rdx
    xor rax, rax
service_copy_cstring_loop:
    mov r8b, [rsi + rax]
    mov [rdi + rax], r8b
    inc rax
    test r8b, r8b
    jnz service_copy_cstring_loop
    dec rax
    pop rdi
    pop rsi
    ret

service_append_cstring:
    push rbx
    push rsi
    mov rsi, rcx
    mov rbx, rdx
    xor rax, rax
service_append_find_end:
    cmp byte [rbx + rax], 0
    je service_append_cstring_copy
    inc rax
    jmp service_append_find_end
service_append_cstring_copy:
    lea r10, [rbx + rax]
    xor r8, r8
service_append_cstring_loop:
    mov dl, [rsi + r8]
    mov [r10 + r8], dl
    inc r8
    test dl, dl
    jnz service_append_cstring_loop
    pop rsi
    pop rbx
    ret

service_append_from_source:
service_append_from_source_loop:
    mov al, [rsi]
    inc rsi
    mov [rdi], al
    inc rdi
    test al, al
    jnz service_append_from_source_loop
    dec rdi
    ret

service_append_json_quoted:
    mov byte [rdi], '"'
    inc rdi
service_append_json_quoted_loop:
    mov al, [rsi]
    inc rsi
    test al, al
    jz service_append_json_quoted_done
    cmp al, '"'
    je service_append_json_quoted_escape
    cmp al, '\'
    jne service_append_json_quoted_store
service_append_json_quoted_escape:
    mov byte [rdi], '\'
    inc rdi
service_append_json_quoted_store:
    mov [rdi], al
    inc rdi
    jmp service_append_json_quoted_loop
service_append_json_quoted_done:
    mov byte [rdi], '"'
    inc rdi
    ret

service_append_u64:
    push rbx
    push rsi
    mov rbx, rax
    lea rsi, [rel service_decimal_tmp + 64]
    xor ecx, ecx
    test rbx, rbx
    jnz service_append_u64_loop
    mov byte [rdi], '0'
    inc rdi
    jmp service_append_u64_done
service_append_u64_loop:
    xor edx, edx
    mov r8d, 10
    mov rax, rbx
    div r8
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc ecx
    mov rbx, rax
    test rbx, rbx
    jnz service_append_u64_loop
service_append_u64_copy:
    mov al, [rsi]
    inc rsi
    mov [rdi], al
    inc rdi
    loop service_append_u64_copy
service_append_u64_done:
    pop rsi
    pop rbx
    ret

service_validate_json:
    push rbx
    sub rsp, 0x20
    mov rbx, rdx
    lea rdx, [rel json_buffer]
    mov r8, rbx
    call service_copy_bytes
    mov [rel json_length], r8
    lea rax, [rel json_buffer]
    mov byte [rax + r8], 0
    call runtime_json_validate_structure
    add rsp, 0x20
    pop rbx
    ret

service_contains:
    call service_find_after
    test rax, rax
    setnz al
    movzx eax, al
    ret

service_root_contains:
    call service_find_root_after
    test rax, rax
    setnz al
    movzx eax, al
    ret

service_find_root_after:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    mov r12, rcx
    mov rbx, rdx
    xor rdi, rdi
    xor r13, r13
service_find_root_start:
    mov al, [r12 + rdi]
    cmp al, 32
    je service_find_root_start_space
    cmp al, 9
    je service_find_root_start_space
    cmp al, 10
    je service_find_root_start_space
    cmp al, 13
    je service_find_root_start_space
    cmp al, '{'
    jne service_find_root_missing
    mov r13, 1
    inc rdi
    jmp service_find_root_outer
service_find_root_start_space:
    inc rdi
    jmp service_find_root_start
service_find_root_outer:
    mov al, [r12 + rdi]
    test al, al
    jz service_find_root_missing
    cmp al, '{'
    je service_find_root_open
    cmp al, '['
    je service_find_root_open
    cmp al, '}'
    je service_find_root_close
    cmp al, ']'
    je service_find_root_close
    cmp al, '"'
    jne service_find_root_next_byte
    mov r14, rdi
    inc rdi
service_find_root_scan_string:
    mov al, [r12 + rdi]
    test al, al
    jz service_find_root_missing
    cmp al, '\'
    je service_find_root_escape
    cmp al, '"'
    je service_find_root_closed
    inc rdi
    jmp service_find_root_scan_string
service_find_root_escape:
    inc rdi
    cmp byte [r12 + rdi], 0
    je service_find_root_missing
    inc rdi
    jmp service_find_root_scan_string
service_find_root_closed:
    lea rsi, [rdi + 1]
service_find_root_space:
    mov al, [r12 + rsi]
    cmp al, 32
    je service_find_root_space_one
    cmp al, 9
    je service_find_root_space_one
    cmp al, 10
    je service_find_root_space_one
    cmp al, 13
    je service_find_root_space_one
    cmp al, ':'
    jne service_find_root_next
    cmp r13, 1
    jne service_find_root_next
    xor r15, r15
service_find_root_pattern_length:
    cmp byte [rbx + r15], 0
    je service_find_root_pattern_compare
    inc r15
    jmp service_find_root_pattern_length
service_find_root_pattern_compare:
    lea rsi, [r12 + r14]
    xor rcx, rcx
service_find_root_compare_loop:
    cmp rcx, r15
    jae service_find_root_pattern_boundary
    mov al, [rsi + rcx]
    cmp al, [rbx + rcx]
    jne service_find_root_next
    inc rcx
    jmp service_find_root_compare_loop
service_find_root_pattern_boundary:
    mov al, [rbx + r15 - 1]
    cmp al, ':'
    je service_find_root_found
    lea rax, [r12 + r14]
    add rax, r15
    mov al, [rax]
    test al, al
    je service_find_root_found
    cmp al, ':'
    je service_find_root_found
    cmp al, 32
    je service_find_root_found
    cmp al, 9
    je service_find_root_found
    cmp al, 10
    je service_find_root_found
    cmp al, 13
    je service_find_root_found
    cmp al, ','
    je service_find_root_found
    cmp al, '}'
    je service_find_root_found
    cmp al, ']'
    je service_find_root_found
    jmp service_find_root_next
service_find_root_space_one:
    inc rsi
    jmp service_find_root_space
service_find_root_next:
    lea rdi, [r14 + 1]
    jmp service_find_root_outer
service_find_root_next_byte:
    inc rdi
    jmp service_find_root_outer
service_find_root_open:
    inc r13
    inc rdi
    jmp service_find_root_outer
service_find_root_close:
    test r13, r13
    jz service_find_root_missing
    dec r13
    inc rdi
    jz service_find_root_missing
    jmp service_find_root_outer
service_find_root_found:
    lea rax, [r12 + r14]
    jmp service_find_root_return
service_find_root_missing:
    xor eax, eax
service_find_root_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

service_find_after:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    mov r12, rcx
    mov rbx, rdx
    xor rdi, rdi
    xor r13, r13
    cmp byte [r12], '"'
    jne service_find_after_outer
    mov r13, 1
service_find_after_outer:
    mov al, [r12 + rdi]
    test al, al
    jz service_find_after_missing
    cmp al, '{'
    je service_find_after_open
    cmp al, '['
    je service_find_after_open
    cmp al, '}'
    je service_find_after_close
    cmp al, ']'
    je service_find_after_close
    cmp al, '"'
    jne service_find_after_next_byte
    test r13, r13
    jz service_find_after_next_byte
    mov rsi, rdi
    inc rdi
service_find_after_string:
    mov al, [r12 + rdi]
    test al, al
    jz service_find_after_missing
    cmp al, '\'
    je service_find_after_escape
    cmp al, '"'
    je service_find_after_closed
    inc rdi
    jmp service_find_after_string
service_find_after_escape:
    inc rdi
    cmp byte [r12 + rdi], 0
    je service_find_after_missing
    inc rdi
    jmp service_find_after_string
service_find_after_closed:
    lea r14, [rdi + 1]
    mov r15, r14
service_find_after_space:
    mov al, [r12 + r15]
    cmp al, 32
    je service_find_after_space_one
    cmp al, 9
    je service_find_after_space_one
    cmp al, 10
    je service_find_after_space_one
    cmp al, 13
    jne service_find_after_colon
service_find_after_space_one:
    inc r15
    jmp service_find_after_space
service_find_after_colon:
    cmp al, ':'
    jne service_find_after_next
    xor r15, r15
service_find_after_pattern_length:
    cmp byte [rbx + r15], 0
    je service_find_after_compare
    inc r15
    jmp service_find_after_pattern_length
service_find_after_compare:
    xor rcx, rcx
service_find_after_compare_loop:
    cmp rcx, r15
    jae service_find_after_found
    lea r10, [r12 + rsi]
    mov al, [r10 + rcx]
    cmp al, [rbx + rcx]
    jne service_find_after_next
    inc rcx
    jmp service_find_after_compare_loop
service_find_after_next_byte:
    inc rdi
    jmp service_find_after_outer
service_find_after_next:
    mov rdi, r14
    jmp service_find_after_outer
service_find_after_open:
    inc r13
    inc rdi
    jmp service_find_after_outer
service_find_after_close:
    test r13, r13
    jz service_find_after_missing
    dec r13
    inc rdi
    jmp service_find_after_outer
service_find_after_found:
    lea rax, [r12 + rsi]
    jmp service_find_after_return
service_find_after_missing:
    xor eax, eax
service_find_after_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

service_find_string:
    push rbx
    push rsi
    push rdi
    push r12
    mov r12, r8
    mov rbx, r9
    call service_find_after
    test rax, rax
    jz service_find_string_fail
    mov rsi, rax
service_find_string_skip:
    mov al, [rsi]
    cmp al, ':'
    je service_find_string_colon
    test al, al
    jz service_find_string_fail
    inc rsi
    jmp service_find_string_skip
service_find_string_colon:
    inc rsi
service_find_string_space:
    cmp byte [rsi], 32
    jne service_find_string_quote
    inc rsi
    jmp service_find_string_space
service_find_string_quote:
    cmp byte [rsi], '"'
    jne service_find_string_fail
    inc rsi
    mov rdi, r12
    xor rcx, rcx
service_find_string_copy:
    cmp rcx, rbx
    jae service_find_string_fail
    mov al, [rsi + rcx]
    cmp al, '"'
    je service_find_string_done
    mov [rdi + rcx], al
    inc rcx
    jmp service_find_string_copy
service_find_string_done:
    mov byte [rdi + rcx], 0
    mov [rel service_value_length], rcx
    xor eax, eax
    jmp service_find_string_return
service_find_string_fail:
    mov eax, 1
service_find_string_return:
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

service_find_root_string:
    push rbx
    push rsi
    push rdi
    push r12
    mov r12, r8
    mov rbx, r9
    call service_find_root_after
    test rax, rax
    jz service_find_root_string_fail
    mov rsi, rax
service_find_root_string_skip:
    mov al, [rsi]
    cmp al, ':'
    je service_find_root_string_colon
    test al, al
    jz service_find_root_string_fail
    inc rsi
    jmp service_find_root_string_skip
service_find_root_string_colon:
    inc rsi
service_find_root_string_space:
    cmp byte [rsi], 32
    je service_find_root_string_space_one
    cmp byte [rsi], 9
    je service_find_root_string_space_one
    cmp byte [rsi], 10
    je service_find_root_string_space_one
    cmp byte [rsi], 13
    je service_find_root_string_space_one
    cmp byte [rsi], '"'
    jne service_find_root_string_fail
    inc rsi
    mov rdi, r12
    xor rcx, rcx
service_find_root_string_copy:
    cmp rcx, rbx
    jae service_find_root_string_fail
    mov al, [rsi + rcx]
    cmp al, '"'
    je service_find_root_string_done
    mov [rdi + rcx], al
    inc rcx
    jmp service_find_root_string_copy
service_find_root_string_done:
    mov byte [rdi + rcx], 0
    mov [rel service_value_length], rcx
    xor eax, eax
    jmp service_find_root_string_return
service_find_root_string_space_one:
    inc rsi
    jmp service_find_root_string_space
service_find_root_string_fail:
    mov eax, 1
service_find_root_string_return:
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

service_find_pattern_string:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    mov r12, r8
    mov r13, r9
    mov rbx, rdx
    call service_find_after
    test rax, rax
    jz service_find_pattern_fail
    mov rsi, rax
    xor rcx, rcx
service_find_pattern_skip:
    cmp byte [rbx + rcx], 0
    je service_find_pattern_value
    inc rcx
    jmp service_find_pattern_skip
service_find_pattern_value:
    add rsi, rcx
    mov rdi, r12
    xor rcx, rcx
service_find_pattern_copy:
    cmp rcx, r13
    jae service_find_pattern_fail
    mov al, [rsi + rcx]
    cmp al, '"'
    je service_find_pattern_done
    mov [rdi + rcx], al
    inc rcx
    jmp service_find_pattern_copy
service_find_pattern_done:
    mov byte [rdi + rcx], 0
    mov [rel service_value_length], rcx
    xor eax, eax
    jmp service_find_pattern_return
service_find_pattern_fail:
    mov eax, 1
service_find_pattern_return:
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

service_find_component_value:
    push rbx
    mov rbx, rdx
    call service_find_after
    test rax, rax
    jz service_find_component_fail
    mov rcx, rax
    lea rdx, [rel json_value_key]
    call service_find_string
    jmp service_find_component_return
service_find_component_fail:
    mov eax, 1
service_find_component_return:
    pop rbx
    ret

service_find_number:
    xor r8d, r8d
    jmp service_find_number_entry
service_find_root_number:
    mov r8d, 1
service_find_number_entry:
    push rbx
    push rsi
    mov rbx, rdx
    test r8d, r8d
    jz service_find_number_general
    call service_find_root_after
    jmp service_find_number_found
service_find_number_general:
    call service_find_after
service_find_number_found:
    test rax, rax
    jz service_find_number_fail
    mov rsi, rax
service_find_number_colon:
    mov al, [rsi]
    cmp al, ':'
    je service_find_number_start
    test al, al
    jz service_find_number_fail
    inc rsi
    jmp service_find_number_colon
service_find_number_start:
    inc rsi
service_find_number_space:
    cmp byte [rsi], 32
    jne service_find_number_digits
    inc rsi
    jmp service_find_number_space
service_find_number_digits:
    xor rax, rax
    xor ecx, ecx
service_find_number_digit_loop:
    mov dl, [rsi + rcx]
    cmp dl, '0'
    jb service_find_number_done
    cmp dl, '9'
    ja service_find_number_done
    imul rax, rax, 10
    jo service_find_number_fail
    movzx edx, dl
    sub edx, '0'
    add rax, rdx
    jc service_find_number_fail
    inc rcx
    jmp service_find_number_digit_loop
service_find_number_done:
    test rcx, rcx
    jz service_find_number_fail
    cmp dl, 32
    je service_find_number_trailing_space
    cmp dl, 9
    je service_find_number_trailing_space
    cmp dl, 10
    je service_find_number_trailing_space
    cmp dl, 13
    je service_find_number_trailing_space
    cmp dl, ','
    je service_find_number_store
    cmp dl, '}'
    je service_find_number_store
    cmp dl, ']'
    je service_find_number_store
    test dl, dl
    jne service_find_number_fail
service_find_number_store:
    mov [rel service_number_value], rax
    xor eax, eax
    jmp service_find_number_return
service_find_number_trailing_space:
    inc rcx
service_find_number_trailing_space_loop:
    mov dl, [rsi + rcx]
    cmp dl, 32
    je service_find_number_trailing_space_one
    cmp dl, 9
    je service_find_number_trailing_space_one
    cmp dl, 10
    je service_find_number_trailing_space_one
    cmp dl, 13
    je service_find_number_trailing_space_one
    cmp dl, ','
    je service_find_number_store
    cmp dl, '}'
    je service_find_number_store
    cmp dl, ']'
    je service_find_number_store
    test dl, dl
    je service_find_number_store
    jmp service_find_number_fail
service_find_number_trailing_space_one:
    inc rcx
    jmp service_find_number_trailing_space_loop
service_find_number_fail:
    mov eax, 1
service_find_number_return:
    pop rsi
    pop rbx
    ret

service_find_root_timestamp:
    push rbx
    push rsi
    push rdi
    call service_find_root_after
    test rax, rax
    jz service_find_root_timestamp_missing
    mov rsi, rax
service_find_root_timestamp_colon:
    mov al, [rsi]
    cmp al, ':'
    je service_find_root_timestamp_start
    test al, al
    jz service_find_root_timestamp_invalid
    inc rsi
    jmp service_find_root_timestamp_colon
service_find_root_timestamp_start:
    inc rsi
service_find_root_timestamp_space:
    mov al, [rsi]
    cmp al, 32
    je service_find_root_timestamp_space_one
    cmp al, 9
    je service_find_root_timestamp_space_one
    cmp al, 10
    je service_find_root_timestamp_space_one
    cmp al, 13
    jne service_find_root_timestamp_digits
service_find_root_timestamp_space_one:
    inc rsi
    jmp service_find_root_timestamp_space
service_find_root_timestamp_digits:
    xor rax, rax
    xor ecx, ecx
service_find_root_timestamp_digit_loop:
    mov dl, [rsi + rcx]
    cmp dl, '0'
    jb service_find_root_timestamp_integer_done
    cmp dl, '9'
    ja service_find_root_timestamp_integer_done
    imul rax, rax, 10
    jo service_find_root_timestamp_invalid
    movzx edi, dl
    sub edi, '0'
    add rax, rdi
    jc service_find_root_timestamp_invalid
    inc rcx
    jmp service_find_root_timestamp_digit_loop
service_find_root_timestamp_integer_done:
    test rcx, rcx
    jz service_find_root_timestamp_invalid
    cmp dl, '.'
    jne service_find_root_timestamp_trailing
    inc rcx
    xor ebx, ebx
service_find_root_timestamp_fraction_loop:
    mov dl, [rsi + rcx]
    cmp dl, '0'
    jb service_find_root_timestamp_fraction_done
    cmp dl, '9'
    ja service_find_root_timestamp_fraction_done
    inc ebx
    cmp ebx, 6
    ja service_find_root_timestamp_invalid
    inc rcx
    jmp service_find_root_timestamp_fraction_loop
service_find_root_timestamp_fraction_done:
    test ebx, ebx
    jz service_find_root_timestamp_invalid
service_find_root_timestamp_trailing:
    cmp dl, 32
    je service_find_root_timestamp_trailing_space
    cmp dl, 9
    je service_find_root_timestamp_trailing_space
    cmp dl, 10
    je service_find_root_timestamp_trailing_space
    cmp dl, 13
    je service_find_root_timestamp_trailing_space
    cmp dl, ','
    je service_find_root_timestamp_store
    cmp dl, '}'
    je service_find_root_timestamp_store
    cmp dl, ']'
    je service_find_root_timestamp_store
    test dl, dl
    jne service_find_root_timestamp_invalid
    jmp service_find_root_timestamp_store
service_find_root_timestamp_trailing_space:
    inc rcx
service_find_root_timestamp_trailing_space_loop:
    mov dl, [rsi + rcx]
    cmp dl, 32
    je service_find_root_timestamp_trailing_space_one
    cmp dl, 9
    je service_find_root_timestamp_trailing_space_one
    cmp dl, 10
    je service_find_root_timestamp_trailing_space_one
    cmp dl, 13
    je service_find_root_timestamp_trailing_space_one
    cmp dl, ','
    je service_find_root_timestamp_store
    cmp dl, '}'
    je service_find_root_timestamp_store
    cmp dl, ']'
    je service_find_root_timestamp_store
    test dl, dl
    jne service_find_root_timestamp_invalid
    jmp service_find_root_timestamp_store
service_find_root_timestamp_trailing_space_one:
    inc rcx
    jmp service_find_root_timestamp_trailing_space_loop
service_find_root_timestamp_store:
    mov [rel service_number_value], rax
    xor eax, eax
    jmp service_find_root_timestamp_return
service_find_root_timestamp_missing:
    mov eax, 1
    jmp service_find_root_timestamp_return
service_find_root_timestamp_invalid:
    mov eax, 2
service_find_root_timestamp_return:
    pop rdi
    pop rsi
    pop rbx
    ret

service_parse_decimal:
    xor rax, rax
    xor r8, r8
service_parse_decimal_loop:
    mov dl, [rcx + r8]
    cmp dl, '0'
    jb service_parse_decimal_done
    cmp dl, '9'
    ja service_parse_decimal_done
    imul rax, rax, 10
    movzx edx, dl
    sub edx, '0'
    add rax, rdx
    inc r8
    jmp service_parse_decimal_loop
service_parse_decimal_done:
    ret

service_bytes_equal_cstring:
    xor r8, r8
service_bytes_equal_loop:
    mov al, [rcx + r8]
    mov dl, [rdx + r8]
    cmp al, dl
    jne service_bytes_equal_no
    test al, al
    jz service_bytes_equal_yes
    inc r8
    jmp service_bytes_equal_loop
service_bytes_equal_yes:
    mov eax, 1
    ret
service_bytes_equal_no:
    xor eax, eax
    ret

section .data
key_application db "DISCORD_APPLICATION_ID", 0
key_application_end:
key_guild db "DISCORD_GUILD_ID", 0
key_guild_end:
key_panel db "DISCORD_PANEL_CHANNEL_ID", 0
key_panel_end:
key_admin db "DISCORD_ADMIN_USER_ID", 0
key_admin_end:
key_intents db "DISCORD_INTENTS", 0
key_intents_end:
key_gateway db "DISCORD_GATEWAY_URL", 0
key_gateway_end:
key_stream db "PUSHBULLET_STREAM_URL", 0
key_stream_end:
discord_api_prefix db "https://discord.com/api/v10", 0
gateway_ws_url db "wss://gateway.discord.gg/?v=10&encoding=json", 0
path_applications db "/applications/", 0
path_guilds db "/guilds/", 0
path_commands db "/commands", 0
path_channels db "/channels/", 0
path_messages db "/messages", 0
path_users_me_channels db "/users/@me/channels", 0
path_interactions db "/interactions/", 0
path_interaction_token db "/", 0
path_callback db "/callback", 0
method_get db "GET", 0
method_post db "POST", 0
method_put db "PUT", 0
commands_body db '[{"name":"후원금액","description":"누적 후원금 확인","type":1},{"name":"입금패널","description":"입금 주문 패널 게시","type":1},{"name":"검토목록","description":"입금 검토목록","type":1},{"name":"지급원장","description":"지급 원장","type":1}]', 0
panel_body db '{"embeds":[{"title":"💳 입금 후원 안내","description":"후원할 금액과 입금자명을 등록하면 입금 알림을 확인해 자동으로 반영합니다.","color":5793266,"fields":[{"name":"📝 신청 방법","value":"1. **입금 신청** 버튼을 눌러요.\n2. 입금자명과 금액을 입력해요.\n3. 안내된 계좌로 정확히 입금해요.","inline":false},{"name":"⏱️ 처리 안내","value":"입금 알림 반영까지 잠시 걸릴 수 있어요.","inline":true},{"name":"🔐 자동 확인 조건","value":"입금자명과 금액이 신청 정보와 모두 일치해야 해요.","inline":false}]}],"components":[{"type":1,"components":[{"type":2,"style":1,"label":"입금 신청","custom_id":"vending:deposit:v1"}]}]}', 0
modal_body db '{"type":9,"data":{"custom_id":"vending:deposit:v1","title":"입금 신청","components":[{"type":1,"components":[{"type":4,"custom_id":"vending:deposit:name","style":1,"label":"입금자명","required":true}]},{"type":1,"components":[{"type":4,"custom_id":"vending:deposit:amount","style":1,"label":"금액","required":true}]}]}}', 0
order_reply_body db '{"type":4,"data":{"content":"입금 주문이 생성되었습니다. 안내 DM을 확인하세요."}}', 0
order_error_body db '{"type":4,"data":{"content":"입금 주문을 생성하지 못했습니다. 입력값을 확인하세요."}}', 0
support_reply_body db '{"type":4,"data":{"content":"누적 후원금은 native DB에서 확인되었습니다."}}', 0
support_reply_prefix db '{"type":4,"data":{"content":"누적 후원금: ', 0
support_reply_suffix db ' KRW"}}', 0
panel_reply_body db '{"type":4,"data":{"content":"입금 패널 게시를 요청했습니다."}}', 0
review_reply_body db '{"type":4,"data":{"content":"검토목록은 운영자 CLI에서 확인하세요."}}', 0
ledger_reply_body db '{"type":4,"data":{"content":"지급원장은 운영자 CLI에서 확인하세요."}}', 0
dm_channel_prefix db '{"recipient_id":', 0
dm_channel_suffix db '}', 0
dm_channel_body db '{"recipient_id":""}', 0
dm_message_prefix db '{"content":"입금 주문이 생성되었습니다. 주문 ID: ', 0
dm_message_suffix db '"}', 0
payment_message_prefix db '{"content":"입금이 확인되었습니다. 주문 ID: ', 0
payment_message_middle db ', 알림 ID: ', 0
payment_message_suffix db '"}', 0
identify_prefix db '{"op":2,"d":{"token":"', 0
identify_mid db '","intents":', 0
identify_suffix db ',"properties":{"os":"windows","browser":"yul-vending-machine","device":"yul-vending-machine"}}}', 0
resume_prefix db '{"op":6,"d":{"token":"', 0
resume_session_mid db '","session_id":"', 0
resume_sequence_mid db '","seq":', 0
resume_suffix db '}}', 0
heartbeat_prefix db '{"op":1,"d":', 0
heartbeat_suffix db '}', 0
null_text db 'null', 0
json_op_pattern db '"op":', 0
json_op_hello_pattern db '"op":10', 0
json_op_heartbeat_pattern db '"op":1', 0
json_ready_pattern db '"t":"READY"', 0
json_invalid_session_pattern db '"op":9', 0
json_interaction_pattern db '"t":"INTERACTION_CREATE"', 0
json_interaction_pattern_spaced db '"t": "INTERACTION_CREATE"', 0
json_reconnect_pattern db '"op":7', 0
json_sequence_key db '"s"', 0
json_data_key db '"d"', 0
json_message_key db '"message"', 0
json_session_key db '"session_id"', 0
json_resume_key db '"resume_gateway_url"', 0
json_heartbeat_interval_key db '"heartbeat_interval"', 0
json_type_key db '"type"', 0
json_id_key db '"id"', 0
json_application_id_key db '"application_id"', 0
json_guild_id_key db '"guild_id"', 0
json_channel_id_key db '"channel_id"', 0
json_push_id_key db '"iden":', 0
json_token_key db '"token"', 0
json_custom_id_key db '"custom_id"', 0
json_command_name_key db '"name"', 0
json_value_key db '"value"', 0
json_modified_key db '"modified"', 0
json_cursor_key db '"cursor"', 0
json_user_pattern db '"user":{"id":"', 0
json_user_pattern_spaced db '"user": {"id": "', 0
component_name_pattern db '"custom_id":"vending:deposit:name"', 0
component_amount_pattern db '"custom_id":"vending:deposit:amount"', 0
button_id db 'vending:deposit:v1', 0
command_support db '후원금액', 0
command_panel db '입금패널', 0
command_review db '검토목록', 0
command_ledger db '지급원장', 0
push_type_pattern db '"type":"push"', 0
push_type_pattern_spaced db '"type": "push"', 0
tickle_type_pattern db '"type":"tickle"', 0
tickle_type_pattern_spaced db '"type": "tickle"', 0
push_object_pattern db '"push"', 0
pushes_array_pattern db '"pushes"', 0
push_poll_prefix db 'https://api.pushbullet.com/v2/pushes?modified_after=', 0
push_poll_cursor_prefix db 'https://api.pushbullet.com/v2/pushes?cursor=', 0
push_poll_suffix db '&limit=50', 0
url_hex_digits db '0123456789ABCDEF', 0
consumed_pattern db '"status":"CONSUMED"', 0
status_sent db 'SENT', 0
status_failed db 'FAILED', 0
sql_update_dm db "UPDATE deposit_orders SET dm_status=?1 WHERE order_id=?2;", 0
sql_get_setting db "SELECT value FROM settings WHERE key=?1 LIMIT 1;", 0
sql_set_setting db "INSERT INTO settings(key,value) VALUES(?1,?2) ON CONFLICT(key) DO UPDATE SET value=excluded.value;", 0
sql_update_payment_dm db "UPDATE deposit_orders SET payment_dm_status=?1 WHERE order_id=?2;", 0
sql_pending_dm db "SELECT order_id,discord_id FROM deposit_orders WHERE dm_status IN ('PENDING','FAILED') ORDER BY created_at ASC LIMIT 1;", 0
setting_gateway_session db "discord.gateway_session_id", 0
setting_gateway_session_end:
setting_gateway_resume db "discord.gateway_resume_url", 0
setting_gateway_resume_end:
setting_gateway_sequence db "discord.gateway_sequence", 0
setting_gateway_sequence_end:
setting_push_cursor db "pushbullet.last_modified", 0
setting_push_cursor_end:
setting_panel_message db "discord.panel_message_id", 0
setting_panel_message_end:

section .bss
service_stop resd 1
service_event_busy resd 1
service_push_opened resd 1
service_processing_result resd 1
service_gateway_ready resd 1
service_heartbeat_active resd 1
service_sequence_valid resd 1
service_gateway_thread_id resd 1
service_heartbeat_thread_id resd 1
service_gateway_thread_handle resq 1
service_heartbeat_thread_handle resq 1
service_heartbeat_interval resq 1
service_sequence resq 1
service_cursor resq 1
service_cursor_candidate resq 1
service_poll_has_pushes resd 1
service_poll_page_count resd 1
service_poll_page_push_count resd 1
service_poll_seen_count resd 1
service_poll_cursor_length resq 1
service_poll_cursor resb 257
service_poll_seen_cursors resb 25700
service_session_id resb 256
service_session_id_length resq 1
service_resume_url resb 1024
service_resume_url_length resq 1
service_number_value resq 1
service_value_length resq 1
service_object_length resq 1
service_body_length resq 1
service_json_length resq 1
service_application resb 128
service_application_length resq 1
service_guild resb 128
service_guild_length resq 1
service_panel resb 128
service_panel_length resq 1
service_panel_message resb 256
service_panel_message_length resq 1
service_admin resb 128
service_admin_length resq 1
service_gateway_url resb 2048
service_gateway_length resq 1
service_stream resb 4096
service_stream_length resq 1
service_intents resq 1
service_url resb 8192
service_body resb 65536
service_json resb 65536
service_interaction_id resb 256
service_interaction_id_length resq 1
service_interaction_token resb 512
service_interaction_token_length resq 1
service_user resb 256
service_user_length resq 1
service_name resb 512
service_name_length resq 1
service_amount resb 64
service_amount_length resq 1
service_custom_id resb 256
service_command resb 256
service_channel resb 256
service_order_id_length resq 1
service_decimal_tmp resb 64
