bits 64
default rel

global yul_native_runtime_main
global runtime_db_open
global runtime_db_close
global runtime_create_order
global runtime_support_total
global runtime_process_push
global runtime_process_push_buffer
global runtime_config_value
global runtime_json_value
global runtime_json_validate_structure
global runtime_write
global runtime_validate_gateway_url
global runtime_validate_push_url
global argument_ptrs
global argument_lengths
global argument_count
global command_index
global config_value
global db_handle
global statement_handle
global json_buffer
global json_length
global discord_token
global discord_token_length
global pushbullet_token
global pushbullet_token_length
global push_id_buffer
global push_id_length
global credit_order_id
global credit_order_id_length
global credit_discord_id
global credit_discord_id_length
global order_id_buffer
global service_message
global service_message_length
global service_mode
global service_buffer_mode
global amount_value
global order_dm_required

extern yul_parse_amount_ascii
extern yul_normalize_name_utf8
extern yul_add_support_total
extern yul_sqlite_runtime_load
extern yul_sqlite_runtime_unload
extern yul_sqlite_open
extern yul_sqlite_close
extern yul_sqlite_exec
extern yul_sqlite_prepare
extern yul_sqlite_bind_text
extern yul_sqlite_bind_int64
extern yul_sqlite_bind_null
extern yul_sqlite_step
extern yul_sqlite_finalize
extern yul_sqlite_column_int64
extern yul_sqlite_column_text
extern yul_platform_now_unix
extern service_find_root_timestamp
extern service_number_value
extern service_interaction_id
extern service_interaction_id_length
extern yul_platform_process_id
extern yul_native_network_probe
extern yul_native_service_run

extern CloseHandle
extern CreateDirectoryA
extern CreateFileA
extern GetFileSize
extern GetStdHandle
extern ReadFile
extern WriteFile

section .text

yul_native_runtime_main:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    call runtime_parse_command_line
    call runtime_load_config
    call runtime_find_command
    cmp dword [rel command_index], -1
    je runtime_usage
    mov ecx, [rel command_index]
    mov rdx, command_init_db
    mov r8d, command_init_db_end-command_init_db
    call runtime_arg_equals
    test eax, eax
    jnz runtime_command_init_db
    mov ecx, [rel command_index]
    mov rdx, command_panel_text
    mov r8d, command_panel_text_end-command_panel_text
    call runtime_arg_equals
    test eax, eax
    jnz runtime_command_panel_text
    mov ecx, [rel command_index]
    mov rdx, command_support_total
    mov r8d, command_support_total_end-command_support_total
    call runtime_arg_equals
    test eax, eax
    jnz runtime_command_support_total
    mov ecx, [rel command_index]
    mov rdx, command_create_order
    mov r8d, command_create_order_end-command_create_order
    call runtime_arg_equals
    test eax, eax
    jnz runtime_command_create_order
    mov ecx, [rel command_index]
    mov rdx, command_process_push
    mov r8d, command_process_push_end-command_process_push
    call runtime_arg_equals
    test eax, eax
    jnz runtime_command_process_push
    mov ecx, [rel command_index]
    mov rdx, command_review_list
    mov r8d, command_review_list_end-command_review_list
    call runtime_arg_equals
    test eax, eax
    jnz runtime_command_review_list
    mov ecx, [rel command_index]
    mov rdx, command_ledger
    mov r8d, command_ledger_end-command_ledger
    call runtime_arg_equals
    test eax, eax
    jnz runtime_command_ledger
    mov ecx, [rel command_index]
    mov rdx, command_run
    mov r8d, command_run_end-command_run
    call runtime_arg_equals
    test eax, eax
    jnz runtime_command_run
    mov ecx, [rel command_index]
    mov rdx, command_validate_config
    mov r8d, command_validate_config_end-command_validate_config
    call runtime_arg_equals
    test eax, eax
    jnz runtime_command_validate_config
runtime_usage:
    lea rdx, [rel usage_text]
    mov r8d, usage_text_end-usage_text
    call runtime_write
    mov eax, 1
    jmp runtime_return
runtime_command_init_db:
    call runtime_init_db
    jmp runtime_return
runtime_command_panel_text:
    lea rdx, [rel panel_text]
    mov r8d, panel_text_end-panel_text
    call runtime_write
    xor eax, eax
    jmp runtime_return
runtime_command_support_total:
    call runtime_support_total
    jmp runtime_return
runtime_command_create_order:
    call runtime_create_order
    jmp runtime_return
runtime_command_process_push:
    call runtime_process_push
    jmp runtime_return
runtime_command_review_list:
    call runtime_review_list
    jmp runtime_return
runtime_command_ledger:
    call runtime_ledger_list
    jmp runtime_return
runtime_command_run:
    call runtime_validate_config
    test eax, eax
    jnz runtime_config_invalid
    call runtime_run
    jmp runtime_return
runtime_command_validate_config:
    call runtime_validate_config
    test eax, eax
    jnz runtime_config_invalid
    lea rdx, [rel config_valid_text]
    mov r8d, config_valid_text_end-config_valid_text
    call runtime_write
    xor eax, eax
    jmp runtime_return
runtime_config_invalid:
    lea rdx, [rel config_invalid_text]
    mov r8d, config_invalid_text_end-config_invalid_text
    call runtime_write
    mov eax, 1
runtime_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

runtime_parse_command_line:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    mov rsi, rcx
    lea rdi, [rel argument_storage]
    xor ebx, ebx
    mov r15d, 1
runtime_parse_skip:
    mov al, [rsi]
    test al, al
    jz runtime_parse_done
    cmp al, 32
    je runtime_parse_skip_one
    cmp al, 9
    jne runtime_parse_start
runtime_parse_skip_one:
    inc rsi
    jmp runtime_parse_skip
runtime_parse_start:
    mov r12, rdi
    xor r13d, r13d
    xor r14d, r14d
    cmp byte [rsi], 34
    jne runtime_parse_copy
    mov r14d, 1
    inc rsi
runtime_parse_copy:
    mov al, [rsi]
    test al, al
    jz runtime_parse_finish
    test r14d, r14d
    jz runtime_parse_unquoted
    cmp al, 34
    je runtime_parse_quote_end
    jmp runtime_parse_store
runtime_parse_unquoted:
    cmp al, 32
    je runtime_parse_finish
    cmp al, 9
    je runtime_parse_finish
runtime_parse_store:
    mov [rdi], al
    inc rdi
    inc rsi
    inc r13
    cmp r13, 4094
    jb runtime_parse_copy
    jmp runtime_parse_done
runtime_parse_quote_end:
    inc rsi
runtime_parse_finish:
    mov byte [rdi], 0
    inc rdi
    cmp r15d, 0
    je runtime_parse_store_arg
    xor r15d, r15d
    jmp runtime_parse_skip
runtime_parse_store_arg:
    cmp ebx, 16
    jae runtime_parse_done
    lea rax, [rel argument_ptrs]
    mov [rax + rbx * 8], r12
    lea rax, [rel argument_lengths]
    mov [rax + rbx * 8], r13
    inc ebx
    jmp runtime_parse_skip
runtime_parse_done:
    mov [rel argument_count], ebx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

runtime_find_command:
    mov dword [rel command_index], -1
    xor ecx, ecx
runtime_find_command_loop:
    cmp ecx, [rel argument_count]
    jae runtime_find_command_done
    lea rdx, [rel command_init_db]
    mov r8d, command_init_db_end-command_init_db
    call runtime_arg_equals
    test eax, eax
    jnz runtime_find_command_found
    lea rdx, [rel command_panel_text]
    mov r8d, command_panel_text_end-command_panel_text
    call runtime_arg_equals
    test eax, eax
    jnz runtime_find_command_found
    lea rdx, [rel command_support_total]
    mov r8d, command_support_total_end-command_support_total
    call runtime_arg_equals
    test eax, eax
    jnz runtime_find_command_found
    lea rdx, [rel command_create_order]
    mov r8d, command_create_order_end-command_create_order
    call runtime_arg_equals
    test eax, eax
    jnz runtime_find_command_found
    lea rdx, [rel command_process_push]
    mov r8d, command_process_push_end-command_process_push
    call runtime_arg_equals
    test eax, eax
    jnz runtime_find_command_found
    lea rdx, [rel command_review_list]
    mov r8d, command_review_list_end-command_review_list
    call runtime_arg_equals
    test eax, eax
    jnz runtime_find_command_found
    lea rdx, [rel command_ledger]
    mov r8d, command_ledger_end-command_ledger
    call runtime_arg_equals
    test eax, eax
    jnz runtime_find_command_found
    lea rdx, [rel command_run]
    mov r8d, command_run_end-command_run
    call runtime_arg_equals
    test eax, eax
    jnz runtime_find_command_found
    lea rdx, [rel command_validate_config]
    mov r8d, command_validate_config_end-command_validate_config
    call runtime_arg_equals
    test eax, eax
    jnz runtime_find_command_found
    inc ecx
    jmp runtime_find_command_loop
runtime_find_command_found:
    mov [rel command_index], ecx
runtime_find_command_done:
    ret

runtime_arg_equals:
    cmp ecx, [rel argument_count]
    jae runtime_arg_not_equal
    lea r10, [rel argument_ptrs]
    mov rax, [r10 + rcx * 8]
    lea r10, [rel argument_lengths]
    mov r9, [r10 + rcx * 8]
    cmp r9, r8
    jne runtime_arg_not_equal
    xor r10d, r10d
runtime_arg_compare:
    cmp r10, r8
    jae runtime_arg_equal
    mov r11b, [rax + r10]
    cmp r11b, [rdx + r10]
    jne runtime_arg_not_equal
    inc r10
    jmp runtime_arg_compare
runtime_arg_equal:
    mov eax, 1
    ret
runtime_arg_not_equal:
    xor eax, eax
    ret

runtime_arg_copy:
    cmp ecx, [rel argument_count]
    jae runtime_arg_copy_failed
    lea r10, [rel argument_ptrs]
    mov rax, [r10 + rcx * 8]
    lea r10, [rel argument_lengths]
    mov r9, [r10 + rcx * 8]
    inc r9
    cmp r9, r8
    ja runtime_arg_copy_failed
    mov rsi, rax
    mov rdi, rdx
    mov rcx, r9
    rep movsb
    mov byte [rdi - 1], 0
    xor eax, eax
    ret
runtime_arg_copy_failed:
    mov eax, 1
    ret

runtime_load_config:
    sub rsp, 0x28
    mov dword [rel config_error], 0
    mov qword [rel order_ttl], 1800
    mov dword [rel auto_credit], 1
    mov dword [rel case_insensitive_latin], 0
    mov qword [rel filter_package_length], 0
    mov qword [rel filter_application_length], 0
    mov qword [rel filter_title_prefix_length], 0
    mov qword [rel filter_title_pattern_length], 0
    mov qword [rel filter_amount_length], 0
    mov qword [rel filter_name_length], 0
    mov qword [rel discord_token_length], 0
    mov qword [rel pushbullet_token_length], 0
    lea rsi, [rel default_db_path]
    lea rdi, [rel db_path]
    mov ecx, default_db_path_end-default_db_path
    rep movsb
    mov byte [rdi + default_db_path_end-default_db_path], 0
    lea rsi, [rel default_config_path]
    lea rdi, [rel config_path]
    mov ecx, default_config_path_end-default_config_path
    rep movsb
    mov byte [rdi + default_config_path_end-default_config_path], 0
    xor ebx, ebx
runtime_config_arg_loop:
    cmp ebx, [rel argument_count]
    jae runtime_config_arg_done
    mov ecx, ebx
    mov rdx, config_option
    mov r8d, config_option_end-config_option
    call runtime_arg_equals
    test eax, eax
    jz runtime_config_arg_next
    inc ebx
    cmp ebx, [rel argument_count]
    jae runtime_config_arg_done
    mov ecx, ebx
    lea rdx, [rel config_path]
    mov r8d, 260
    call runtime_arg_copy
    jmp runtime_config_arg_done
runtime_config_arg_next:
    inc ebx
    jmp runtime_config_arg_loop
runtime_config_arg_done:
    lea rcx, [rel config_path]
    lea rdx, [rel config_buffer]
    mov r8d, 32768
    lea r9, [rel config_length]
    call runtime_read_file
    test eax, eax
    jnz runtime_load_config_missing
    mov rcx, config_key_database
    mov edx, config_key_database_end-config_key_database
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_load_config_ttl
    lea rsi, [rel config_value]
    lea rdi, [rel db_path]
    mov rcx, rax
    mov ecx, 4096
    xor eax, eax
runtime_config_copy_db:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    test al, al
    jnz runtime_config_copy_db
runtime_load_config_ttl:
    mov rcx, config_key_ttl
    mov edx, config_key_ttl_end-config_key_ttl
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_load_config_auto
    lea rcx, [rel config_value]
    call runtime_parse_decimal
    test rax, rax
    jz runtime_load_config_auto
    mov [rel order_ttl], rax
runtime_load_config_auto:
    mov rcx, config_key_auto
    mov edx, config_key_auto_end-config_key_auto
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_load_config_case
    lea rcx, [rel config_value]
    call runtime_parse_bool
    cmp eax, -1
    je runtime_load_config_case
    mov [rel auto_credit], eax
runtime_load_config_case:
    mov rcx, config_key_case
    mov edx, config_key_case_end-config_key_case
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_load_config_filters
    lea rcx, [rel config_value]
    call runtime_parse_bool
    cmp eax, -1
    je runtime_load_config_filters
    mov [rel case_insensitive_latin], eax
runtime_load_config_filters:
    mov rcx, config_key_package
    mov edx, config_key_package_end-config_key_package
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_load_config_filter_application
    mov rcx, config_value
    lea rdx, [rel filter_package]
    mov r8d, 256
    call runtime_copy_cstring
    mov [rel filter_package_length], rax
runtime_load_config_filter_application:
    mov rcx, config_key_application
    mov edx, config_key_application_end-config_key_application
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_load_config_filter_title
    mov rcx, config_value
    lea rdx, [rel filter_application]
    mov r8d, 256
    call runtime_copy_cstring
    mov [rel filter_application_length], rax
runtime_load_config_filter_title:
    mov rcx, config_key_title_prefix
    mov edx, config_key_title_prefix_end-config_key_title_prefix
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_load_config_filter_pattern
    mov rcx, config_value
    lea rdx, [rel filter_title_prefix]
    mov r8d, 1024
    call runtime_copy_cstring
    mov [rel filter_title_prefix_length], rax
runtime_load_config_filter_pattern:
    mov rcx, config_key_title_pattern
    mov edx, config_key_title_pattern_end-config_key_title_pattern
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_load_config_filter_amount
    mov rcx, config_value
    lea rdx, [rel filter_title_pattern]
    mov r8d, 2048
    call runtime_copy_cstring
    mov [rel filter_title_pattern_length], rax
runtime_load_config_filter_amount:
    mov rcx, config_key_amount_pattern
    mov edx, config_key_amount_pattern_end-config_key_amount_pattern
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_load_config_filter_name
    mov rcx, config_value
    lea rdx, [rel filter_amount]
    mov r8d, 4096
    call runtime_copy_cstring
    mov [rel filter_amount_length], rax
runtime_load_config_filter_name:
    mov rcx, config_key_name_pattern
    mov edx, config_key_name_pattern_end-config_key_name_pattern
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_load_config_filter_done
    mov rcx, config_value
    lea rdx, [rel filter_name]
    mov r8d, 4096
    call runtime_copy_cstring
    mov [rel filter_name_length], rax
runtime_load_config_filter_done:
    mov rcx, config_key_discord_token
    mov edx, config_key_discord_token_end-config_key_discord_token
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_load_config_push_token
    mov rcx, config_value
    lea rdx, [rel discord_token]
    mov r8d, 2048
    call runtime_copy_cstring
    mov [rel discord_token_length], rax
runtime_load_config_push_token:
    mov rcx, config_key_pushbullet_token
    mov edx, config_key_pushbullet_token_end-config_key_pushbullet_token
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_load_config_tokens_done
    mov rcx, config_value
    lea rdx, [rel pushbullet_token]
    mov r8d, 2048
    call runtime_copy_cstring
    mov [rel pushbullet_token_length], rax
runtime_load_config_tokens_done:
    mov qword [rel min_amount], 0
    mov qword [rel max_amount], 0
    mov rcx, config_key_min
    mov edx, config_key_min_end-config_key_min
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_load_config_max
    lea rcx, [rel config_value]
    call runtime_parse_decimal
    test rax, rax
    jz runtime_load_config_max
    mov [rel min_amount], rax
runtime_load_config_max:
    mov rcx, config_key_max
    mov edx, config_key_max_end-config_key_max
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_load_config_done
    lea rcx, [rel config_value]
    call runtime_parse_decimal
    test rax, rax
    jz runtime_load_config_done
    mov [rel max_amount], rax
runtime_load_config_done:
    add rsp, 0x28
    ret
runtime_load_config_missing:
    mov dword [rel config_error], 1
    jmp runtime_load_config_done

runtime_validate_required:
    sub rsp, 0x28
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_validate_required_fail
    cmp byte [rel config_value], 0
    je runtime_validate_required_fail
    xor eax, eax
    add rsp, 0x28
    ret
runtime_validate_required_fail:
    mov eax, 1
    add rsp, 0x28
    ret

runtime_validate_config:
    cmp dword [rel config_error], 0
    jne runtime_validate_config_fail
    call runtime_validate_config_lines
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_database
    mov edx, config_key_database_end-config_key_database
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_ttl
    mov edx, config_key_ttl_end-config_key_ttl
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    lea rcx, [rel config_value]
    call runtime_validate_decimal
    test eax, eax
    jnz runtime_validate_config_fail
    lea rcx, [rel config_value]
    call runtime_parse_decimal
    test rax, rax
    jz runtime_validate_config_fail
    mov rcx, config_key_auto
    mov edx, config_key_auto_end-config_key_auto
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_validate_config_fail
    lea rcx, [rel config_value]
    call runtime_parse_bool
    cmp eax, 1
    jne runtime_validate_config_fail
    mov rcx, config_key_case
    mov edx, config_key_case_end-config_key_case
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_validate_config_case_done
    lea rcx, [rel config_value]
    call runtime_parse_bool
    cmp eax, -1
    je runtime_validate_config_fail
runtime_validate_config_case_done:
    mov rcx, config_key_package
    mov edx, config_key_package_end-config_key_package
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_application
    mov edx, config_key_application_end-config_key_application
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_title_prefix
    mov edx, config_key_title_prefix_end-config_key_title_prefix
    call runtime_validate_required
    test eax, eax
    jz runtime_validate_config_title_done
    mov rcx, config_key_title_pattern
    mov edx, config_key_title_pattern_end-config_key_title_pattern
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
runtime_validate_config_title_done:
    mov rcx, config_key_title_pattern
    mov edx, config_key_title_pattern_end-config_key_title_pattern
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_validate_config_title_pattern_done
    cmp byte [rel config_value], 0
    je runtime_validate_config_title_pattern_done
    lea rcx, [rel config_value]
    lea rdx, [rel supported_title_pattern]
    xor r8d, r8d
    call runtime_validate_pattern_contract
    test eax, eax
    jnz runtime_validate_config_fail
runtime_validate_config_title_pattern_done:
    mov rcx, config_key_amount_pattern
    mov edx, config_key_amount_pattern_end-config_key_amount_pattern
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_amount_pattern
    mov edx, config_key_amount_pattern_end-config_key_amount_pattern
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_validate_config_fail
    lea rcx, [rel config_value]
    lea rdx, [rel supported_amount_pattern_title]
    lea r8, [rel supported_amount_pattern_body]
    call runtime_validate_pattern_contract
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_name_pattern
    mov edx, config_key_name_pattern_end-config_key_name_pattern
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_name_pattern
    mov edx, config_key_name_pattern_end-config_key_name_pattern
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_validate_config_fail
    lea rcx, [rel config_value]
    lea rdx, [rel supported_name_pattern_arrow]
    lea r8, [rel supported_name_pattern_body]
    call runtime_validate_pattern_contract
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_discord_token
    mov edx, config_key_discord_token_end-config_key_discord_token
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_pushbullet_token
    mov edx, config_key_pushbullet_token_end-config_key_pushbullet_token
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_application_id
    mov edx, config_key_application_id_end-config_key_application_id
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_guild_id
    mov edx, config_key_guild_id_end-config_key_guild_id
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_panel_id
    mov edx, config_key_panel_id_end-config_key_panel_id
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_admin_id
    mov edx, config_key_admin_id_end-config_key_admin_id
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_intents
    mov edx, config_key_intents_end-config_key_intents
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_intents
    mov edx, config_key_intents_end-config_key_intents
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_validate_config_fail
    lea rcx, [rel config_value]
    call runtime_validate_decimal
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_gateway
    mov edx, config_key_gateway_end-config_key_gateway
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_gateway
    mov edx, config_key_gateway_end-config_key_gateway
    call runtime_validate_ws_key
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_stream
    mov edx, config_key_stream_end-config_key_stream
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_stream
    mov edx, config_key_stream_end-config_key_stream
    call runtime_validate_ws_key
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_bank_name
    mov edx, config_key_bank_name_end-config_key_bank_name
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_bank_account
    mov edx, config_key_bank_account_end-config_key_bank_account
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_bank_holder
    mov edx, config_key_bank_holder_end-config_key_bank_holder
    call runtime_validate_required
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_min
    mov edx, config_key_min_end-config_key_min
    call runtime_validate_optional_positive
    test eax, eax
    jnz runtime_validate_config_fail
    mov rcx, config_key_max
    mov edx, config_key_max_end-config_key_max
    call runtime_validate_optional_positive
    test eax, eax
    jnz runtime_validate_config_fail
    mov rax, [rel min_amount]
    mov rdx, [rel max_amount]
    test rax, rax
    jz runtime_validate_config_success
    test rdx, rdx
    jz runtime_validate_config_success
    cmp rax, rdx
    ja runtime_validate_config_fail
runtime_validate_config_success:
    xor eax, eax
    ret
runtime_validate_config_fail:
    mov eax, 1
    ret

runtime_config_key_supported:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    sub rsp, 0x20
    mov r12, rcx
    mov r13, rdx
    lea rsi, [rel runtime_config_key_table]
    xor edi, edi
runtime_config_key_supported_loop:
    cmp edi, 24
    jae runtime_config_key_supported_fail
    lea rbx, [rsi + rdi * 8]
    lea rbx, [rbx + rdi * 8]
    mov rax, [rbx]
    cmp [rbx + 8], r13
    jne runtime_config_key_supported_next
    mov rcx, r12
    mov rdx, r13
    mov r8, rax
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_config_key_supported_success
runtime_config_key_supported_next:
    inc edi
    jmp runtime_config_key_supported_loop
runtime_config_key_supported_success:
    mov eax, 1
    jmp runtime_config_key_supported_return
runtime_config_key_supported_fail:
    xor eax, eax
runtime_config_key_supported_return:
    add rsp, 0x20
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

runtime_validate_config_lines:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 0x20
    lea r12, [rel config_buffer]
    mov r13, [rel config_length]
    xor r14d, r14d
runtime_validate_config_lines_leading:
    cmp r14, r13
    jae runtime_validate_config_lines_success
    mov al, [r12 + r14]
    cmp al, 10
    je runtime_validate_config_lines_newline
    cmp al, 32
    je runtime_validate_config_lines_skip_leading
    cmp al, 9
    je runtime_validate_config_lines_skip_leading
    cmp al, 13
    je runtime_validate_config_lines_skip_leading
    cmp al, 35
    je runtime_validate_config_lines_skip_comment
    mov r15, r14
runtime_validate_config_lines_find_equal:
    cmp r15, r13
    jae runtime_validate_config_lines_fail
    mov al, [r12 + r15]
    cmp al, 61
    je runtime_validate_config_lines_equal
    cmp al, 10
    je runtime_validate_config_lines_fail
    inc r15
    jmp runtime_validate_config_lines_find_equal
runtime_validate_config_lines_equal:
    mov rbx, r15
runtime_validate_config_lines_trim_key:
    cmp rbx, r14
    je runtime_validate_config_lines_fail
    lea rsi, [rbx - 1]
    mov al, [r12 + rsi]
    cmp al, 32
    je runtime_validate_config_lines_trim_key_one
    cmp al, 9
    jne runtime_validate_config_lines_key_ready
runtime_validate_config_lines_trim_key_one:
    dec rbx
    jmp runtime_validate_config_lines_trim_key
runtime_validate_config_lines_key_ready:
    lea rcx, [r12 + r14]
    mov rdx, rbx
    sub rdx, r14
    call runtime_config_key_supported
    test eax, eax
    jz runtime_validate_config_lines_fail
    mov r14, r15
runtime_validate_config_lines_value:
    cmp r14, r13
    jae runtime_validate_config_lines_success
    cmp byte [r12 + r14], 10
    je runtime_validate_config_lines_newline
    inc r14
    jmp runtime_validate_config_lines_value
runtime_validate_config_lines_skip_leading:
    inc r14
    jmp runtime_validate_config_lines_leading
runtime_validate_config_lines_skip_comment:
    cmp r14, r13
    jae runtime_validate_config_lines_success
    cmp byte [r12 + r14], 10
    je runtime_validate_config_lines_newline
    inc r14
    jmp runtime_validate_config_lines_skip_comment
runtime_validate_config_lines_newline:
    inc r14
    jmp runtime_validate_config_lines_leading
runtime_validate_config_lines_success:
    xor eax, eax
    jmp runtime_validate_config_lines_return
runtime_validate_config_lines_fail:
    mov eax, 1
runtime_validate_config_lines_return:
    add rsp, 0x20
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

runtime_config_value:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    mov r12, rcx
    mov r13, rdx
    mov r14, r8
    mov r15, r9
    xor ebx, ebx
runtime_config_scan:
    mov rax, [rel config_length]
    cmp rbx, rax
    jae runtime_config_missing
    test rbx, rbx
    jz runtime_config_line
    lea rsi, [rel config_buffer]
    cmp byte [rsi + rbx - 1], 10
    jne runtime_config_next
runtime_config_line:
    lea rsi, [rel config_buffer]
    add rsi, rbx
runtime_config_line_skip:
    cmp byte [rsi], 32
    je runtime_config_line_skip_one
    cmp byte [rsi], 9
    jne runtime_config_line_ready
runtime_config_line_skip_one:
    inc rsi
    jmp runtime_config_line_skip
runtime_config_line_ready:
    mov rax, [rel config_length]
    sub rax, r13
    cmp rbx, rax
    ja runtime_config_missing
    mov rdi, r12
    mov rcx, r13
    repe cmpsb
    jne runtime_config_next
runtime_config_key_end:
    cmp byte [rsi], 32
    je runtime_config_key_end_one
    cmp byte [rsi], 9
    jne runtime_config_key_equal
runtime_config_key_end_one:
    inc rsi
    jmp runtime_config_key_end
runtime_config_key_equal:
    cmp byte [rsi], 61
    jne runtime_config_next
    add rsi, 1
runtime_config_skip_space:
    cmp byte [rsi], 32
    je runtime_config_skip_space_one
    cmp byte [rsi], 9
    jne runtime_config_copy
runtime_config_skip_space_one:
    inc rsi
    jmp runtime_config_skip_space
runtime_config_copy:
    xor ecx, ecx
runtime_config_copy_loop:
    cmp ecx, r15d
    jae runtime_config_missing
    mov al, [rsi + rcx]
    cmp al, 13
    je runtime_config_copy_done
    cmp al, 10
    je runtime_config_copy_done
    test al, al
    jz runtime_config_copy_done
    mov [r14 + rcx], al
    inc ecx
    jmp runtime_config_copy_loop
runtime_config_copy_done:
    mov rdx, rcx
runtime_config_trim_value:
    test rdx, rdx
    jz runtime_config_trim_done
    dec rdx
    cmp byte [r14 + rdx], 32
    je runtime_config_trim_value
    cmp byte [r14 + rdx], 9
    je runtime_config_trim_value
    inc rdx
runtime_config_trim_done:
    mov byte [r14 + rdx], 0
    xor eax, eax
    jmp runtime_config_return
runtime_config_next:
    inc rbx
    jmp runtime_config_scan
runtime_config_missing:
    mov byte [r14], 0
    mov eax, 1
runtime_config_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

runtime_parse_decimal:
    xor eax, eax
    xor edx, edx
    mov r8, 0x0ccccccccccccccc
runtime_parse_decimal_loop:
    mov dl, [rcx]
    test dl, dl
    jz runtime_parse_decimal_done
    cmp dl, 48
    jb runtime_parse_decimal_invalid
    cmp dl, 57
    ja runtime_parse_decimal_invalid
    sub dl, 48
    cmp rax, r8
    ja runtime_parse_decimal_invalid
    jb runtime_parse_decimal_step
    cmp dl, 7
    ja runtime_parse_decimal_invalid
runtime_parse_decimal_step:
    imul rax, rax, 10
    add rax, rdx
    inc rcx
    jmp runtime_parse_decimal_loop
runtime_parse_decimal_done:
    ret
runtime_parse_decimal_invalid:
    xor eax, eax
    ret

runtime_validate_decimal:
    sub rsp, 0x28
    mov rdx, rcx
    xor r8d, r8d
    xor r10d, r10d
runtime_validate_decimal_loop:
    mov al, [rdx + r8]
    test al, al
    jz runtime_validate_decimal_done
    cmp al, 48
    jb runtime_validate_decimal_invalid
    cmp al, 57
    ja runtime_validate_decimal_invalid
    cmp al, 48
    je runtime_validate_decimal_digit_zero
    mov r10d, 1
runtime_validate_decimal_digit_zero:
    inc r8
    jmp runtime_validate_decimal_loop
runtime_validate_decimal_done:
    test r8, r8
    jz runtime_validate_decimal_invalid
    mov r9, rcx
    call runtime_parse_decimal
    test eax, eax
    jz runtime_validate_decimal_zero
    mov rcx, r9
    xor eax, eax
    add rsp, 0x28
    ret
runtime_validate_decimal_zero:
    test r10d, r10d
    jnz runtime_validate_decimal_invalid
    mov rcx, r9
    xor eax, eax
    add rsp, 0x28
    ret
runtime_validate_decimal_invalid:
    mov eax, 1
    add rsp, 0x28
    ret

runtime_apply_case_insensitive_latin:
    cmp dword [rel case_insensitive_latin], 0
    je runtime_apply_case_insensitive_latin_return
    lea rcx, [rel normalized_buffer]
    mov rdx, [rel normalized_length]
    xor r8d, r8d
runtime_apply_case_insensitive_latin_loop:
    cmp r8, rdx
    jae runtime_apply_case_insensitive_latin_return
    mov al, [rcx + r8]
    cmp al, 65
    jb runtime_apply_case_insensitive_latin_next
    cmp al, 90
    ja runtime_apply_case_insensitive_latin_next
    add al, 32
    mov [rcx + r8], al
runtime_apply_case_insensitive_latin_next:
    inc r8
    jmp runtime_apply_case_insensitive_latin_loop
runtime_apply_case_insensitive_latin_return:
    xor eax, eax
    ret

runtime_validate_ws_url:
    cmp byte [rcx], 'w'
    jne runtime_validate_ws_url_fail
    cmp byte [rcx + 1], 's'
    jne runtime_validate_ws_url_fail
    cmp byte [rcx + 2], 's'
    jne runtime_validate_ws_url_fail
    cmp byte [rcx + 3], ':'
    jne runtime_validate_ws_url_fail
    cmp byte [rcx + 4], '/'
    jne runtime_validate_ws_url_fail
    cmp byte [rcx + 5], '/'
    jne runtime_validate_ws_url_fail
    xor eax, eax
    ret
runtime_validate_ws_url_fail:
    mov eax, 1
    ret

runtime_endpoint_parse_wss_host:
    cmp byte [rcx], 'w'
    jne runtime_endpoint_parse_wss_host_fail
    cmp byte [rcx + 1], 's'
    jne runtime_endpoint_parse_wss_host_fail
    cmp byte [rcx + 2], 's'
    jne runtime_endpoint_parse_wss_host_fail
    cmp byte [rcx + 3], ':'
    jne runtime_endpoint_parse_wss_host_fail
    cmp byte [rcx + 4], '/'
    jne runtime_endpoint_parse_wss_host_fail
    cmp byte [rcx + 5], '/'
    jne runtime_endpoint_parse_wss_host_fail
    lea r8, [rcx + 6]
    lea rdx, [rel runtime_endpoint_host]
    xor r9d, r9d
runtime_endpoint_parse_wss_host_loop:
    mov al, [r8 + r9]
    test al, al
    jz runtime_endpoint_parse_wss_host_done
    cmp al, '/'
    je runtime_endpoint_parse_wss_host_done
    cmp al, '?'
    je runtime_endpoint_parse_wss_host_done
    cmp al, '#'
    je runtime_endpoint_parse_wss_host_done
    cmp r9, 255
    jae runtime_endpoint_parse_wss_host_fail
    cmp al, 'A'
    jb runtime_endpoint_parse_wss_host_store
    cmp al, 'Z'
    ja runtime_endpoint_parse_wss_host_store
    add al, 32
runtime_endpoint_parse_wss_host_store:
    mov [rdx + r9], al
    inc r9
    jmp runtime_endpoint_parse_wss_host_loop
runtime_endpoint_parse_wss_host_done:
    test r9, r9
    jz runtime_endpoint_parse_wss_host_fail
    mov byte [rdx + r9], 0
    mov [rel runtime_endpoint_host_length], r9
    lea rax, [r8 + r9]
    ret
runtime_endpoint_parse_wss_host_fail:
    xor eax, eax
    ret

runtime_endpoint_query_match_key:
    mov r10, rcx
    xor r11d, r11d
runtime_endpoint_query_match_key_loop:
    cmp r11, r8
    jae runtime_endpoint_query_match_key_separator
    mov al, [r10 + r11]
    test al, al
    jz runtime_endpoint_query_match_key_fail
    cmp al, [rdx + r11]
    jne runtime_endpoint_query_match_key_fail
    inc r11
    jmp runtime_endpoint_query_match_key_loop
runtime_endpoint_query_match_key_separator:
    cmp byte [r10 + r11], '='
    jne runtime_endpoint_query_match_key_fail
    lea rax, [r10 + r11 + 1]
    ret
runtime_endpoint_query_match_key_fail:
    xor eax, eax
    ret

runtime_endpoint_validate_query:
    sub rsp, 0x28
    mov qword [rsp + 0x20], 0
runtime_endpoint_validate_query_loop:
    mov r10, rcx
    cmp byte [r10], 0
    je runtime_endpoint_validate_query_success
    lea rdx, [rel endpoint_query_v]
    mov r8d, 1
    call runtime_endpoint_query_match_key
    test rax, rax
    jnz runtime_endpoint_validate_query_v
    mov rcx, r10
    lea rdx, [rel endpoint_query_encoding]
    mov r8d, 8
    call runtime_endpoint_query_match_key
    test rax, rax
    jz runtime_endpoint_validate_query_fail
    mov r11, [rsp + 0x20]
    test r11, 2
    jnz runtime_endpoint_validate_query_fail
    or r11, 2
    mov [rsp + 0x20], r11
    jmp runtime_endpoint_validate_query_value
runtime_endpoint_validate_query_v:
    mov r11, [rsp + 0x20]
    test r11, 1
    jnz runtime_endpoint_validate_query_fail
    or r11, 1
    mov [rsp + 0x20], r11
runtime_endpoint_validate_query_value:
    mov r10, rax
runtime_endpoint_validate_query_value_loop:
    mov al, [r10]
    test al, al
    jz runtime_endpoint_validate_query_success
    cmp al, '&'
    je runtime_endpoint_validate_query_delimiter
    cmp al, '#'
    je runtime_endpoint_validate_query_fail
    cmp al, 32
    jb runtime_endpoint_validate_query_fail
    inc r10
    jmp runtime_endpoint_validate_query_value_loop
runtime_endpoint_validate_query_delimiter:
    lea rcx, [r10 + 1]
    cmp byte [rcx], 0
    je runtime_endpoint_validate_query_fail
    jmp runtime_endpoint_validate_query_loop
runtime_endpoint_validate_query_success:
    xor eax, eax
    add rsp, 0x28
    ret
runtime_endpoint_validate_query_fail:
    mov eax, 1
    add rsp, 0x28
    ret

runtime_endpoint_validate_gateway_rest:
    mov al, [rcx]
    test al, al
    jz runtime_endpoint_validate_gateway_rest_success
    cmp al, '#'
    je runtime_endpoint_validate_gateway_rest_fail
    cmp al, '?'
    je runtime_endpoint_validate_gateway_rest_query
    cmp al, '/'
    jne runtime_endpoint_validate_gateway_rest_fail
    mov al, [rcx + 1]
    test al, al
    jz runtime_endpoint_validate_gateway_rest_success
    cmp al, '?'
    je runtime_endpoint_validate_gateway_rest_path_query
    jmp runtime_endpoint_validate_gateway_rest_fail
runtime_endpoint_validate_gateway_rest_query:
    inc rcx
    jmp runtime_endpoint_validate_query
runtime_endpoint_validate_gateway_rest_path_query:
    lea rcx, [rcx + 2]
    jmp runtime_endpoint_validate_query
runtime_endpoint_validate_gateway_rest_success:
    xor eax, eax
    ret
runtime_endpoint_validate_gateway_rest_fail:
    mov eax, 1
    ret

runtime_validate_gateway_url:
    push r12
    sub rsp, 0x20
    call runtime_endpoint_parse_wss_host
    test rax, rax
    jz runtime_validate_gateway_url_fail
    mov r12, rax
    mov rax, [rel runtime_endpoint_host_length]
    cmp rax, 18
    jne runtime_validate_gateway_url_try_gg
    lea rcx, [rel endpoint_gateway_exact]
    mov edx, 18
    lea r8, [rel runtime_endpoint_host]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_validate_gateway_url_host_ready
runtime_validate_gateway_url_try_gg:
    mov rax, [rel runtime_endpoint_host_length]
    cmp rax, 11
    jbe runtime_validate_gateway_url_try_com
    sub rax, 11
    lea rcx, [rel runtime_endpoint_host]
    add rcx, rax
    mov edx, 11
    lea r8, [rel endpoint_gateway_suffix_gg]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_validate_gateway_url_host_ready
runtime_validate_gateway_url_try_com:
    mov rax, [rel runtime_endpoint_host_length]
    cmp rax, 12
    jbe runtime_validate_gateway_url_fail
    sub rax, 12
    lea rcx, [rel runtime_endpoint_host]
    add rcx, rax
    mov edx, 12
    lea r8, [rel endpoint_gateway_suffix_com]
    call runtime_bytes_equal
    test eax, eax
    jz runtime_validate_gateway_url_fail
runtime_validate_gateway_url_host_ready:
    mov rcx, r12
    call runtime_endpoint_validate_gateway_rest
    jmp runtime_validate_gateway_url_return
runtime_validate_gateway_url_fail:
    mov eax, 1
runtime_validate_gateway_url_return:
    add rsp, 0x20
    pop r12
    ret

runtime_validate_push_url:
    push r12
    sub rsp, 0x20
    call runtime_endpoint_parse_wss_host
    test rax, rax
    jz runtime_validate_push_url_fail
    mov r12, rax
    cmp qword [rel runtime_endpoint_host_length], 21
    jne runtime_validate_push_url_fail
    lea rcx, [rel endpoint_push_exact]
    mov edx, 21
    lea r8, [rel runtime_endpoint_host]
    call runtime_bytes_equal
    test eax, eax
    jz runtime_validate_push_url_fail
    mov rcx, r12
    lea rdx, [rel endpoint_push_path]
    call runtime_cstring_equal
    test eax, eax
    jz runtime_validate_push_url_fail
    xor eax, eax
    jmp runtime_validate_push_url_return
runtime_validate_push_url_fail:
    mov eax, 1
runtime_validate_push_url_return:
    add rsp, 0x20
    pop r12
    ret

runtime_parse_bool:
    push rbx
    sub rsp, 0x20
    mov rbx, rcx
    lea rdx, [rel bool_true_1]
    call runtime_cstring_equal
    test eax, eax
    jnz runtime_parse_bool_true
    mov rcx, rbx
    lea rdx, [rel bool_true_lower]
    call runtime_cstring_equal
    test eax, eax
    jnz runtime_parse_bool_true
    mov rcx, rbx
    lea rdx, [rel bool_true_upper]
    call runtime_cstring_equal
    test eax, eax
    jnz runtime_parse_bool_true
    mov rcx, rbx
    lea rdx, [rel bool_yes_lower]
    call runtime_cstring_equal
    test eax, eax
    jnz runtime_parse_bool_true
    mov rcx, rbx
    lea rdx, [rel bool_yes_upper]
    call runtime_cstring_equal
    test eax, eax
    jnz runtime_parse_bool_true
    mov rcx, rbx
    lea rdx, [rel bool_false_0]
    call runtime_cstring_equal
    test eax, eax
    jnz runtime_parse_bool_false
    mov rcx, rbx
    lea rdx, [rel bool_false_lower]
    call runtime_cstring_equal
    test eax, eax
    jnz runtime_parse_bool_false
    mov rcx, rbx
    lea rdx, [rel bool_false_upper]
    call runtime_cstring_equal
    test eax, eax
    jnz runtime_parse_bool_false
    mov rcx, rbx
    lea rdx, [rel bool_no_lower]
    call runtime_cstring_equal
    test eax, eax
    jnz runtime_parse_bool_false
    mov rcx, rbx
    lea rdx, [rel bool_no_upper]
    call runtime_cstring_equal
    test eax, eax
    jnz runtime_parse_bool_false
    mov eax, -1
    jmp runtime_parse_bool_return
runtime_parse_bool_true:
    mov eax, 1
    jmp runtime_parse_bool_return
runtime_parse_bool_false:
    xor eax, eax
runtime_parse_bool_return:
    add rsp, 0x20
    pop rbx
    ret

runtime_validate_optional_positive:
    sub rsp, 0x28
    lea r8, [rel config_value]
    mov r9d, 4096
    call runtime_config_value
    test eax, eax
    jnz runtime_validate_optional_positive_success
    cmp byte [rel config_value], 0
    je runtime_validate_optional_positive_success
    lea rcx, [rel config_value]
    call runtime_validate_decimal
    test eax, eax
    jnz runtime_validate_optional_positive_fail
    lea rcx, [rel config_value]
    call runtime_parse_decimal
    test rax, rax
    jz runtime_validate_optional_positive_fail
runtime_validate_optional_positive_success:
    xor eax, eax
    add rsp, 0x28
    ret
runtime_validate_optional_positive_fail:
    mov eax, 1
    add rsp, 0x28
    ret

runtime_validate_ws_key:
    push r12
    sub rsp, 0x30
    mov r12, rcx
    mov [rsp + 0x20], rdx
    lea r8, [rel config_value]
    mov r9d, 4095
    call runtime_config_value
    test eax, eax
    jnz runtime_validate_ws_key_fail
    mov rax, [rsp + 0x20]
    cmp rax, config_key_gateway_end-config_key_gateway
    jne runtime_validate_ws_key_check_push
    mov rcx, r12
    mov rdx, rax
    lea r8, [rel config_key_gateway]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_validate_ws_key_gateway
    jmp runtime_validate_ws_key_fail
runtime_validate_ws_key_check_push:
    cmp rax, config_key_stream_end-config_key_stream
    jne runtime_validate_ws_key_fail
    mov rcx, r12
    mov rdx, rax
    lea r8, [rel config_key_stream]
    call runtime_bytes_equal
    test eax, eax
    jz runtime_validate_ws_key_fail
    lea rcx, [rel config_value]
    call runtime_validate_push_url
    jmp runtime_validate_ws_key_return
runtime_validate_ws_key_gateway:
    lea rcx, [rel config_value]
    call runtime_validate_gateway_url
    jmp runtime_validate_ws_key_return
runtime_validate_ws_key_fail:
    mov eax, 1
runtime_validate_ws_key_return:
    add rsp, 0x30
    pop r12
    ret

runtime_prepare_db_directory:
    lea rsi, [rel db_path]
    xor ecx, ecx
    xor r8d, r8d
runtime_prepare_db_directory_scan:
    mov al, [rsi + rcx]
    test al, al
    jz runtime_prepare_db_directory_done_scan
    cmp al, 92
    je runtime_prepare_db_directory_separator
    cmp al, 47
    je runtime_prepare_db_directory_separator
    inc rcx
    cmp rcx, 4094
    jb runtime_prepare_db_directory_scan
    jmp runtime_prepare_db_directory_noop
runtime_prepare_db_directory_separator:
    lea r8, [rcx + 1]
    inc rcx
    jmp runtime_prepare_db_directory_scan
runtime_prepare_db_directory_done_scan:
    test r8, r8
    jz runtime_prepare_db_directory_noop
    lea rsi, [rel db_path]
    lea rdi, [rel db_directory_buffer]
    xor rcx, rcx
runtime_prepare_db_directory_copy:
    cmp rcx, r8
    jae runtime_prepare_db_directory_terminate
    mov al, [rsi + rcx]
    mov [rdi + rcx], al
    inc rcx
    jmp runtime_prepare_db_directory_copy
runtime_prepare_db_directory_terminate:
    mov byte [rdi + rcx], 0
    sub rsp, 0x28
    lea rcx, [rel db_directory_buffer]
    xor edx, edx
    call CreateDirectoryA
    add rsp, 0x28
runtime_prepare_db_directory_noop:
    xor eax, eax
    ret

runtime_db_open:
    sub rsp, 0x28
    call runtime_prepare_db_directory
    call yul_sqlite_runtime_load
    test eax, eax
    jnz runtime_db_failed_stack
    lea rcx, [rel db_path]
    lea rdx, [rel db_handle]
    call yul_sqlite_open
    test eax, eax
    jnz runtime_db_failed_unload_stack
    mov rcx, [rel db_handle]
    lea rdx, [rel db_schema]
    call yul_sqlite_exec
    test eax, eax
    jnz runtime_db_failed_close_stack
    mov rcx, [rel db_handle]
    call runtime_db_migrate
    test eax, eax
    jnz runtime_db_failed_close_stack
    xor eax, eax
    add rsp, 0x28
    ret
runtime_db_failed_close_stack:
    mov rcx, [rel db_handle]
    call yul_sqlite_close
runtime_db_failed_unload_stack:
    call yul_sqlite_runtime_unload
runtime_db_failed_stack:
    add rsp, 0x28
runtime_db_failed:
    mov eax, 1
    ret

runtime_db_migrate:
    sub rsp, 0x28
    mov [rsp + 0x20], rcx
    mov rcx, [rsp + 0x20]
    lea rdx, [rel sql_native_migration_v2]
    call yul_sqlite_exec
    mov rcx, [rsp + 0x20]
    lea rdx, [rel sql_native_verify_v2]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_db_migrate_fail
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    test eax, eax
    jnz runtime_db_migrate_fail
    mov rcx, [rsp + 0x20]
    lea rdx, [rel sql_native_version_v2]
    call yul_sqlite_exec
    test eax, eax
    jnz runtime_db_migrate_fail
    mov rcx, [rsp + 0x20]
    lea rdx, [rel sql_native_migration_v3]
    call yul_sqlite_exec
    mov rcx, [rsp + 0x20]
    lea rdx, [rel sql_native_verify_v3]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_db_migrate_fail
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    test eax, eax
    jnz runtime_db_migrate_fail
    mov rcx, [rsp + 0x20]
    lea rdx, [rel sql_native_index_v3]
    call yul_sqlite_exec
    test eax, eax
    jnz runtime_db_migrate_fail
    mov rcx, [rsp + 0x20]
    lea rdx, [rel sql_native_version_v3]
    call yul_sqlite_exec
    test eax, eax
    jnz runtime_db_migrate_fail
    xor eax, eax
    add rsp, 0x28
    ret
runtime_db_migrate_fail:
    mov eax, 1
    add rsp, 0x28
    ret

runtime_db_close:
    sub rsp, 0x28
    mov rcx, [rel db_handle]
    call yul_sqlite_close
    call yul_sqlite_runtime_unload
    add rsp, 0x28
    ret

runtime_init_db:
    sub rsp, 0x28
    call runtime_db_open
    test eax, eax
    jnz runtime_init_db_fail
    call runtime_db_close
    xor eax, eax
    add rsp, 0x28
    ret
runtime_init_db_fail:
    lea rdx, [rel error_text]
    mov r8d, error_text_end-error_text
    call runtime_write
    mov eax, 1
    add rsp, 0x28
    ret

runtime_support_total:
    sub rsp, 0x28
    call runtime_db_open
    test eax, eax
    jnz runtime_support_total_fail
    mov eax, [rel command_index]
    inc eax
    cmp eax, [rel argument_count]
    jae runtime_support_total_fail_close
    mov ecx, eax
    lea rdx, [rel support_id_buffer]
    mov r8d, 256
    call runtime_arg_copy
    test eax, eax
    jnz runtime_support_total_fail_close
    mov eax, [rel command_index]
    inc eax
    mov r10, rax
    lea r11, [rel argument_lengths]
    mov rax, [r11 + r10 * 8]
    mov [rel support_id_length], rax
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_support_total]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_support_total_fail_close
    mov rcx, [rel statement_handle]
    mov edx, 1
    lea r8, [rel support_id_buffer]
    mov r9, [rel support_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 100
    je runtime_support_total_row
    xor eax, eax
    jmp runtime_support_total_print
runtime_support_total_row:
    mov rcx, [rel statement_handle]
    xor edx, edx
    call yul_sqlite_column_int64
runtime_support_total_print:
    mov rdx, decimal_buffer
    mov r8d, 64
    call runtime_u64_decimal
    mov rdx, decimal_buffer
    mov r8d, eax
    call runtime_write
    lea rdx, [rel newline]
    mov r8d, 1
    call runtime_write
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
runtime_support_total_fail_close:
    call runtime_db_close
    xor eax, eax
    add rsp, 0x28
    ret
runtime_support_total_fail:
    lea rdx, [rel error_text]
    mov r8d, error_text_end-error_text
    call runtime_write
    mov eax, 1
    add rsp, 0x28
    ret

runtime_create_order:
    sub rsp, 0x28
    mov ebx, [rel command_index]
    inc ebx
    mov ecx, ebx
    lea rdx, [rel discord_id_buffer]
    mov r8d, 256
    call runtime_arg_copy
    test eax, eax
    jnz runtime_create_order_fail
    inc ebx
    mov ecx, ebx
    lea rdx, [rel name_buffer]
    mov r8d, 512
    call runtime_arg_copy
    test eax, eax
    jnz runtime_create_order_fail
    inc ebx
    mov ecx, ebx
    lea rdx, [rel amount_buffer]
    mov r8d, 64
    call runtime_arg_copy
    test eax, eax
    jnz runtime_create_order_fail
    mov ebx, [rel command_index]
    inc ebx
    lea r10, [rel argument_lengths]
    mov rax, [r10 + rbx * 8]
    mov [rel discord_id_length], rax
    inc ebx
    mov rax, [r10 + rbx * 8]
    mov [rel name_length], rax
    inc ebx
    mov rax, [r10 + rbx * 8]
    mov [rel amount_length], rax
    lea rcx, [rel amount_buffer]
    mov rdx, [rel amount_length]
    lea r8, [rel amount_value]
    call yul_parse_amount_ascii
    test eax, eax
    jnz runtime_create_order_fail
    mov rax, [rel min_amount]
    test rax, rax
    jz runtime_create_order_max_check
    cmp [rel amount_value], rax
    jb runtime_create_order_fail
runtime_create_order_max_check:
    mov rax, [rel max_amount]
    test rax, rax
    jz runtime_create_order_name_check
    cmp [rel amount_value], rax
    ja runtime_create_order_fail
runtime_create_order_name_check:
    lea rcx, [rel name_buffer]
    mov rdx, [rel name_length]
    lea r8, [rel normalized_buffer]
    mov r9d, 1024
    lea rax, [rel normalized_length]
    mov [rsp + 0x20], rax
    call yul_normalize_name_utf8
    test eax, eax
    jnz runtime_create_order_fail
    call runtime_apply_case_insensitive_latin
    call yul_platform_now_unix
    mov [rel created_at], rax
    mov rdx, [rel order_ttl]
    add rax, rdx
    mov [rel expires_at], rax
    call runtime_make_order_id
    call runtime_db_open
    test eax, eax
    jnz runtime_create_order_fail
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_insert_order]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_create_order_close_fail
    mov rcx, [rel statement_handle]
    mov edx, 1
    lea r8, [rel order_id_buffer]
    mov r9d, 23
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 2
    lea r8, [rel discord_id_buffer]
    mov r9, [rel discord_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 3
    lea r8, [rel name_buffer]
    mov r9, [rel name_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 4
    lea r8, [rel normalized_buffer]
    mov r9, [rel normalized_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 5
    mov r8, [rel amount_value]
    call yul_sqlite_bind_int64
    mov rcx, [rel statement_handle]
    mov edx, 6
    lea r8, [rel status_pending]
    mov r9d, 7
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 7
    mov r8, [rel created_at]
    call yul_sqlite_bind_int64
    mov rcx, [rel statement_handle]
    mov edx, 8
    mov r8, [rel expires_at]
    call yul_sqlite_bind_int64
    mov rcx, [rel statement_handle]
    mov edx, 9
    lea r8, [rel status_pending]
    mov r9d, 7
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 10
    cmp dword [rel service_mode], 0
    je runtime_create_order_bind_interaction_null
    lea r8, [rel service_interaction_id]
    mov r9, [rel service_interaction_id_length]
    call yul_sqlite_bind_text
    jmp runtime_create_order_interaction_bound
runtime_create_order_bind_interaction_null:
    call yul_sqlite_bind_null
runtime_create_order_interaction_bound:
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 101
    jne runtime_create_order_statement_fail
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    cmp dword [rel service_mode], 0
    je runtime_create_order_close_success
    call runtime_find_interaction_order
    test eax, eax
    jnz runtime_create_order_close_fail
runtime_create_order_close_success:
    call runtime_db_close
    lea rdx, [rel order_created_text]
    mov r8d, order_created_text_end-order_created_text
    call runtime_write
    lea rdx, [rel order_id_buffer]
    mov r8d, 23
    call runtime_write
    lea rdx, [rel newline]
    mov r8d, 1
    call runtime_write
    xor eax, eax
    add rsp, 0x28
    ret
runtime_create_order_statement_fail:
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
runtime_create_order_close_fail:
    call runtime_db_close
runtime_create_order_fail:
    lea rdx, [rel error_text]
    mov r8d, error_text_end-error_text
    call runtime_write
    mov eax, 1
    add rsp, 0x28
    ret

runtime_find_interaction_order:
    sub rsp, 0x28
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_find_interaction_order]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_find_interaction_order_fail
    mov rcx, [rel statement_handle]
    mov edx, 1
    lea r8, [rel service_interaction_id]
    mov r9, [rel service_interaction_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 100
    jne runtime_find_interaction_order_statement_fail
    mov rcx, [rel statement_handle]
    xor edx, edx
    call yul_sqlite_column_text
    mov rcx, rax
    lea rdx, [rel order_id_buffer]
    mov r8d, 128
    call runtime_copy_cstring
    cmp rax, 23
    jne runtime_find_interaction_order_statement_fail
    mov rcx, [rel statement_handle]
    mov edx, 1
    call yul_sqlite_column_text
    mov rcx, rax
    lea rdx, [rel discord_id_buffer]
    call runtime_cstring_equal
    test eax, eax
    jz runtime_find_interaction_order_statement_fail
    mov rcx, [rel statement_handle]
    mov edx, 2
    call yul_sqlite_column_text
    mov rcx, rax
    lea rdx, [rel normalized_buffer]
    call runtime_cstring_equal
    test eax, eax
    jz runtime_find_interaction_order_statement_fail
    mov rcx, [rel statement_handle]
    mov edx, 3
    call yul_sqlite_column_int64
    cmp rax, [rel amount_value]
    jne runtime_find_interaction_order_statement_fail
    mov dword [rel order_dm_required], 0
    mov rcx, [rel statement_handle]
    mov edx, 4
    call yul_sqlite_column_text
    mov rcx, rax
    lea rdx, [rel dm_status_sent]
    call runtime_cstring_equal
    test eax, eax
    jnz runtime_find_interaction_order_status_ready
    mov rcx, [rel statement_handle]
    mov edx, 4
    call yul_sqlite_column_text
    mov rcx, rax
    lea rdx, [rel dm_status_pending]
    call runtime_cstring_equal
    test eax, eax
    jnz runtime_find_interaction_order_dm_required
    mov rcx, [rel statement_handle]
    mov edx, 4
    call yul_sqlite_column_text
    mov rcx, rax
    lea rdx, [rel dm_status_failed]
    call runtime_cstring_equal
    test eax, eax
    jz runtime_find_interaction_order_statement_fail
runtime_find_interaction_order_dm_required:
    mov dword [rel order_dm_required], 1
runtime_find_interaction_order_status_ready:
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    test eax, eax
    jnz runtime_find_interaction_order_fail
    xor eax, eax
    add rsp, 0x28
    ret
runtime_find_interaction_order_statement_fail:
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
runtime_find_interaction_order_fail:
    mov eax, 1
    add rsp, 0x28
    ret

runtime_process_push_buffer:
    mov dword [rel service_buffer_mode], 1
    call runtime_process_push
    mov dword [rel service_buffer_mode], 0
    ret

runtime_process_push:
    sub rsp, 0x28
    cmp dword [rel service_buffer_mode], 0
    jne runtime_process_push_buffer_ready
    mov ebx, [rel command_index]
    inc ebx
    mov ecx, ebx
    lea rdx, [rel json_path_buffer]
    mov r8d, 260
    call runtime_arg_copy
    test eax, eax
    jnz runtime_process_push_fail
    lea rcx, [rel json_path_buffer]
    lea rdx, [rel json_buffer]
    mov r8d, 65536
    lea r9, [rel json_length]
    call runtime_read_file
    test eax, eax
    jnz runtime_process_push_fail
runtime_process_push_buffer_ready:
    mov qword [rel push_id_length], 0
    mov qword [rel package_length], 0
    mov qword [rel application_length], 0
    mov qword [rel title_length], 0
    mov qword [rel body_length], 0
    mov qword [rel parsed_name_length], 0
    mov qword [rel normalized_length], 0
    mov qword [rel amount_length], 0
    mov qword [rel parsed_amount_value], 0
    mov qword [rel push_mirror_kind], 0
    mov qword [rel push_fingerprint_pending], 0
    mov qword [rel push_created_at], 0
    mov qword [rel push_modified_at], 0
    mov qword [rel push_event_time], 0
    mov dword [rel push_created_present], 0
    mov dword [rel push_modified_present], 0
    mov dword [rel push_timestamp_present], 0
    call runtime_json_validate_structure
    test eax, eax
    jnz runtime_process_push_parse_fail
    mov rcx, json_key_type
    mov edx, json_key_type_end-json_key_type
    lea r8, [rel package_buffer]
    mov r9d, 256
    call runtime_json_value
    test eax, eax
    jnz runtime_process_push_type_missing
    cmp qword [rel json_value_length], 4
    je runtime_process_push_envelope
    cmp qword [rel json_value_length], 6
    je runtime_process_push_raw_mirror
    jmp runtime_process_push_parse_fail
runtime_process_push_envelope:
    lea rcx, [rel package_buffer]
    mov edx, 4
    mov r8, json_push_value
    call runtime_bytes_equal
    test eax, eax
    jz runtime_process_push_parse_fail
    call runtime_json_select_push_object
    test eax, eax
    jnz runtime_process_push_parse_fail
    cmp dword [rel json_selector_found], 0
    je runtime_process_push_parse_fail
    mov rcx, json_key_type
    mov edx, json_key_type_end-json_key_type
    lea r8, [rel package_buffer]
    mov r9d, 256
    call runtime_json_value
    test eax, eax
    jnz runtime_process_push_parse_fail
    cmp qword [rel json_value_length], 6
    jne runtime_process_push_parse_fail
    lea rcx, [rel package_buffer]
    mov edx, 6
    mov r8, json_mirror_value
    call runtime_bytes_equal
    test eax, eax
    jz runtime_process_push_parse_fail
    mov qword [rel push_mirror_kind], 1
    jmp runtime_process_push_type_ready
runtime_process_push_raw_mirror:
    lea rcx, [rel package_buffer]
    mov edx, 6
    mov r8, json_mirror_value
    call runtime_bytes_equal
    test eax, eax
    jz runtime_process_push_parse_fail
    mov qword [rel push_mirror_kind], 1
    jmp runtime_process_push_type_ready
runtime_process_push_type_missing:
    jmp runtime_process_push_parse_fail
runtime_process_push_type_ready:
    call yul_platform_now_unix
    mov [rel created_at], rax
    mov rcx, json_key_id
    mov edx, json_key_id_end-json_key_id
    lea r8, [rel push_id_buffer]
    mov r9d, 256
    call runtime_json_value
    test eax, eax
    jz runtime_process_push_id_validate
    cmp dword [rel json_key_found], 0
    jne runtime_process_push_id_invalid
    mov qword [rel push_fingerprint_pending], 1
    mov qword [rel push_id_length], 0
    jmp runtime_process_push_id_fields_ready
runtime_process_push_id_validate:
    mov rax, [rel json_value_length]
    test rax, rax
    jz runtime_process_push_id_invalid
    lea rcx, [rel push_id_buffer]
    xor rdx, rdx
runtime_process_push_id_validate_loop:
    cmp rdx, rax
    jae runtime_process_push_id_invalid
    mov r8b, [rcx + rdx]
    cmp r8b, 32
    je runtime_process_push_id_validate_next
    cmp r8b, 9
    je runtime_process_push_id_validate_next
    cmp r8b, 10
    je runtime_process_push_id_validate_next
    cmp r8b, 13
    jne runtime_process_push_id_ready
runtime_process_push_id_validate_next:
    inc rdx
    jmp runtime_process_push_id_validate_loop
runtime_process_push_id_invalid:
    mov qword [rel push_mirror_kind], 0
    jmp runtime_process_push_parse_fail
runtime_process_push_id_ready:
    mov rax, [rel json_value_length]
    mov [rel push_id_length], rax
runtime_process_push_id_fields_ready:
    mov rcx, json_key_package
    mov edx, json_key_package_end-json_key_package
    lea r8, [rel package_buffer]
    mov r9d, 256
    call runtime_json_value
    test eax, eax
    jnz runtime_process_push_parse_fail
    mov rax, [rel json_value_length]
    mov [rel package_length], rax
    mov rcx, json_key_application
    mov edx, json_key_application_end-json_key_application
    lea r8, [rel application_buffer]
    mov r9d, 256
    call runtime_json_value
    test eax, eax
    jnz runtime_process_push_parse_fail
    mov rax, [rel json_value_length]
    mov [rel application_length], rax
    mov rcx, json_key_title
    mov edx, json_key_title_end-json_key_title
    lea r8, [rel title_buffer]
    mov r9d, 1024
    call runtime_json_value
    test eax, eax
    jnz runtime_process_push_parse_fail
    mov rax, [rel json_value_length]
    mov [rel title_length], rax
    call runtime_check_source_filters
    test eax, eax
    jnz runtime_process_push_unsupported
    mov rcx, json_key_body
    mov edx, json_key_body_end-json_key_body
    lea r8, [rel body_buffer]
    mov r9d, 16384
    call runtime_json_value
    test eax, eax
    jnz runtime_process_push_parse_fail
    mov rax, [rel json_value_length]
    mov [rel body_length], rax
    call runtime_extract_push_name
    test eax, eax
    jnz runtime_process_push_parse_fail
    call runtime_extract_push_amount
    test eax, eax
    jnz runtime_process_push_parse_fail
    call runtime_parse_push_timestamps
    test eax, eax
    jnz runtime_process_push_parse_fail
    cmp qword [rel push_fingerprint_pending], 0
    je runtime_process_push_fingerprint_ready
    call runtime_make_push_fingerprint
    test eax, eax
    jnz runtime_process_push_parse_fail
    mov rax, [rel json_value_length]
    mov [rel push_id_length], rax
runtime_process_push_fingerprint_ready:
    call yul_platform_now_unix
    mov [rel created_at], rax
    cmp dword [rel push_timestamp_present], 0
    jne runtime_process_push_event_time_ready
    mov [rel push_event_time], rax
runtime_process_push_event_time_ready:
    call runtime_db_open
    test eax, eax
    jnz runtime_process_push_fail
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_begin]
    call yul_sqlite_exec
    test eax, eax
    jnz runtime_process_push_close_fail
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_duplicate]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_process_push_rollback_fail
    mov rcx, [rel statement_handle]
    mov edx, 1
    lea r8, [rel push_id_buffer]
    mov r9, [rel push_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 100
    jne runtime_process_push_not_duplicate
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    call runtime_sql_rollback
    call runtime_db_close
    call runtime_print_duplicate
    xor eax, eax
    add rsp, 0x28
    ret
runtime_process_push_not_duplicate:
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    jmp runtime_process_push_insert_event
runtime_process_push_insert_event:
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_insert_push]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_process_push_rollback_fail
    mov rcx, [rel statement_handle]
    mov edx, 1
    lea r8, [rel push_id_buffer]
    mov r9, [rel push_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 2
    lea r8, [rel package_buffer]
    mov r9, [rel package_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 3
    lea r8, [rel application_buffer]
    mov r9, [rel application_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 4
    lea r8, [rel title_buffer]
    mov r9, [rel title_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 5
    lea r8, [rel parsed_name_buffer]
    mov r9, [rel parsed_name_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 6
    lea r8, [rel normalized_buffer]
    mov r9, [rel normalized_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 7
    mov r8, [rel parsed_amount_value]
    call yul_sqlite_bind_int64
    mov rcx, [rel statement_handle]
    mov edx, 8
    lea r8, [rel status_received]
    mov r9d, 8
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 9
    mov r8, [rel created_at]
    call yul_sqlite_bind_int64
    mov rcx, [rel statement_handle]
    mov edx, 10
    cmp dword [rel push_created_present], 0
    je runtime_process_push_created_null
    mov r8, [rel push_created_at]
    call yul_sqlite_bind_int64
    jmp runtime_process_push_created_done
runtime_process_push_created_null:
    call yul_sqlite_bind_null
runtime_process_push_created_done:
    mov rcx, [rel statement_handle]
    mov edx, 11
    cmp dword [rel push_modified_present], 0
    je runtime_process_push_modified_null
    mov r8, [rel push_modified_at]
    call yul_sqlite_bind_int64
    jmp runtime_process_push_modified_done
runtime_process_push_modified_null:
    call yul_sqlite_bind_null
runtime_process_push_modified_done:
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 101
    jne runtime_process_push_statement_fail
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    call runtime_native_credit
    cmp eax, 0
    je runtime_process_push_credit_done
    cmp eax, 1
    je runtime_process_push_mark_review
    jmp runtime_process_push_rollback_fail
runtime_process_push_mark_review:
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_mark_review]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_process_push_rollback_fail
    mov rcx, [rel statement_handle]
    mov edx, 1
    lea r8, [rel push_id_buffer]
    mov r9, [rel push_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 101
    jne runtime_process_push_statement_fail
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_commit]
    call yul_sqlite_exec
    test eax, eax
    jnz runtime_process_push_close_fail
    call runtime_db_close
    call runtime_print_review
    xor eax, eax
    add rsp, 0x28
    ret
runtime_process_push_credit_done:
    call runtime_db_close
    call runtime_print_consumed
    xor eax, eax
    add rsp, 0x28
    ret
runtime_process_push_parse_fail:
    cmp qword [rel push_id_length], 0
    jne runtime_process_push_parse_fail_ready
    call runtime_make_push_fingerprint
    mov rax, [rel json_value_length]
    mov [rel push_id_length], rax
runtime_process_push_parse_fail_ready:
    lea rsi, [rel status_parse_failed]
    lea rdi, [rel status_scratch]
    mov ecx, status_parse_failed_end-status_parse_failed
    rep movsb
    mov qword [rel status_scratch_length], status_parse_failed_end-status_parse_failed
    call runtime_record_nonpayment
    cmp eax, 2
    je runtime_process_push_nonpayment_duplicate
    test eax, eax
    jnz runtime_process_push_nonpayment_fail
    call runtime_print_parse_failed
    xor eax, eax
    add rsp, 0x28
    ret
runtime_process_push_unsupported:
    cmp qword [rel push_id_length], 0
    jne runtime_process_push_unsupported_id_ready
    call runtime_make_push_fingerprint
    mov rax, [rel json_value_length]
    mov [rel push_id_length], rax
runtime_process_push_unsupported_id_ready:
    lea rsi, [rel status_unsupported]
    lea rdi, [rel status_scratch]
    mov ecx, status_unsupported_end-status_unsupported
    rep movsb
    mov qword [rel status_scratch_length], status_unsupported_end-status_unsupported
    call runtime_record_nonpayment
    cmp eax, 2
    je runtime_process_push_nonpayment_duplicate
    test eax, eax
    jnz runtime_process_push_nonpayment_fail
    call runtime_print_unsupported
    xor eax, eax
    add rsp, 0x28
    ret
runtime_process_push_nonpayment_duplicate:
    call runtime_print_duplicate
    xor eax, eax
    add rsp, 0x28
    ret
runtime_process_push_nonpayment_fail:
    lea rdx, [rel error_text]
    mov r8d, error_text_end-error_text
    call runtime_write
    mov eax, 1
    add rsp, 0x28
    ret
runtime_process_push_statement_fail:
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
runtime_process_push_rollback_fail:
    call runtime_sql_rollback
runtime_process_push_close_fail:
    call runtime_db_close
runtime_process_push_fail:
    lea rdx, [rel error_text]
    mov r8d, error_text_end-error_text
    call runtime_write
    mov eax, 1
    add rsp, 0x28
    ret

runtime_record_nonpayment:
    sub rsp, 0x28
    call yul_platform_now_unix
    mov [rel created_at], rax
    call runtime_db_open
    test eax, eax
    jnz runtime_record_nonpayment_fail
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_begin]
    call yul_sqlite_exec
    test eax, eax
    jnz runtime_record_nonpayment_close_fail
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_duplicate]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_record_nonpayment_rollback_fail
    mov rcx, [rel statement_handle]
    mov edx, 1
    lea r8, [rel push_id_buffer]
    mov r9, [rel push_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 100
    je runtime_record_nonpayment_duplicate
    cmp eax, 101
    jne runtime_record_nonpayment_statement_fail
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    mov qword [rel statement_handle], 0
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_insert_push]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_record_nonpayment_rollback_fail
    mov rcx, [rel statement_handle]
    mov edx, 1
    lea r8, [rel push_id_buffer]
    mov r9, [rel push_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 2
    lea r8, [rel package_buffer]
    mov r9, [rel package_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 3
    lea r8, [rel application_buffer]
    mov r9, [rel application_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 4
    lea r8, [rel title_buffer]
    mov r9, [rel title_length]
    call yul_sqlite_bind_text
    cmp qword [rel parsed_name_length], 0
    je runtime_record_nonpayment_name_null
    mov rcx, [rel statement_handle]
    mov edx, 5
    lea r8, [rel parsed_name_buffer]
    mov r9, [rel parsed_name_length]
    call yul_sqlite_bind_text
    jmp runtime_record_nonpayment_name_done
runtime_record_nonpayment_name_null:
    mov rcx, [rel statement_handle]
    mov edx, 5
    call yul_sqlite_bind_null
runtime_record_nonpayment_name_done:
    cmp qword [rel normalized_length], 0
    je runtime_record_nonpayment_normalized_null
    mov rcx, [rel statement_handle]
    mov edx, 6
    lea r8, [rel normalized_buffer]
    mov r9, [rel normalized_length]
    call yul_sqlite_bind_text
    jmp runtime_record_nonpayment_normalized_done
runtime_record_nonpayment_normalized_null:
    mov rcx, [rel statement_handle]
    mov edx, 6
    call yul_sqlite_bind_null
runtime_record_nonpayment_normalized_done:
    cmp qword [rel amount_length], 0
    je runtime_record_nonpayment_amount_null
    mov rcx, [rel statement_handle]
    mov edx, 7
    mov r8, [rel parsed_amount_value]
    call yul_sqlite_bind_int64
    jmp runtime_record_nonpayment_amount_done
runtime_record_nonpayment_amount_null:
    mov rcx, [rel statement_handle]
    mov edx, 7
    call yul_sqlite_bind_null
runtime_record_nonpayment_amount_done:
    mov rcx, [rel statement_handle]
    mov edx, 8
    lea r8, [rel status_scratch]
    mov r9, [rel status_scratch_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 9
    mov r8, [rel created_at]
    call yul_sqlite_bind_int64
    mov rcx, [rel statement_handle]
    mov edx, 10
    cmp dword [rel push_created_present], 0
    je runtime_record_nonpayment_created_null
    mov r8, [rel push_created_at]
    call yul_sqlite_bind_int64
    jmp runtime_record_nonpayment_created_done
runtime_record_nonpayment_created_null:
    call yul_sqlite_bind_null
runtime_record_nonpayment_created_done:
    mov rcx, [rel statement_handle]
    mov edx, 11
    cmp dword [rel push_modified_present], 0
    je runtime_record_nonpayment_modified_null
    mov r8, [rel push_modified_at]
    call yul_sqlite_bind_int64
    jmp runtime_record_nonpayment_modified_done
runtime_record_nonpayment_modified_null:
    call yul_sqlite_bind_null
runtime_record_nonpayment_modified_done:
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 101
    jne runtime_record_nonpayment_statement_fail
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    mov qword [rel statement_handle], 0
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_commit]
    call yul_sqlite_exec
    test eax, eax
    jnz runtime_record_nonpayment_close_fail
    call runtime_db_close
    xor eax, eax
    add rsp, 0x28
    ret
runtime_record_nonpayment_duplicate:
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    call runtime_sql_rollback
    call runtime_db_close
    mov eax, 2
    add rsp, 0x28
    ret
runtime_record_nonpayment_statement_fail:
    cmp qword [rel statement_handle], 0
    je runtime_record_nonpayment_rollback_fail
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    mov qword [rel statement_handle], 0
runtime_record_nonpayment_rollback_fail:
    call runtime_sql_rollback
runtime_record_nonpayment_close_fail:
    call runtime_db_close
runtime_record_nonpayment_fail:
    mov eax, 1
    add rsp, 0x28
    ret

runtime_parse_push_timestamps:
    sub rsp, 0x28
    lea rcx, [rel json_buffer]
    lea rdx, [rel json_timestamp_created_key]
    call service_find_root_timestamp
    cmp eax, 0
    je runtime_parse_push_created
    cmp eax, 1
    jne runtime_parse_push_timestamps_fail
    jmp runtime_parse_push_modified_start
runtime_parse_push_created:
    mov rax, [rel service_number_value]
    mov [rel push_created_at], rax
    mov dword [rel push_created_present], 1
    mov [rel push_event_time], rax
    mov dword [rel push_timestamp_present], 1
runtime_parse_push_modified_start:
    lea rcx, [rel json_buffer]
    lea rdx, [rel json_timestamp_modified_key]
    call service_find_root_timestamp
    cmp eax, 0
    je runtime_parse_push_modified
    cmp eax, 1
    jne runtime_parse_push_timestamps_fail
    jmp runtime_parse_push_timestamps_success
runtime_parse_push_modified:
    mov rax, [rel service_number_value]
    mov [rel push_modified_at], rax
    mov dword [rel push_modified_present], 1
    cmp dword [rel push_created_present], 0
    jne runtime_parse_push_timestamps_success
    mov [rel push_event_time], rax
    mov dword [rel push_timestamp_present], 1
runtime_parse_push_timestamps_success:
    xor eax, eax
    add rsp, 0x28
    ret
runtime_parse_push_timestamps_fail:
    mov eax, 1
    add rsp, 0x28
    ret

runtime_native_credit:
    sub rsp, 0x28
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_find_order]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_native_credit_error
    mov rcx, [rel statement_handle]
    mov edx, 1
    lea r8, [rel normalized_buffer]
    mov r9, [rel normalized_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 2
    mov r8, [rel parsed_amount_value]
    call yul_sqlite_bind_int64
    mov rcx, [rel statement_handle]
    mov edx, 3
    mov r8, [rel created_at]
    call yul_sqlite_bind_int64
    mov rcx, [rel statement_handle]
    mov edx, 4
    mov r8, [rel push_event_time]
    call yul_sqlite_bind_int64
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 100
    jne runtime_native_credit_no_match
    mov rcx, [rel statement_handle]
    xor edx, edx
    call yul_sqlite_column_text
    mov rcx, rax
    lea rdx, [rel credit_order_id]
    mov r8d, 128
    call runtime_copy_cstring
    mov [rel credit_order_id_length], rax
    mov rcx, [rel statement_handle]
    mov edx, 1
    call yul_sqlite_column_text
    mov rcx, rax
    lea rdx, [rel credit_discord_id]
    mov r8d, 256
    call runtime_copy_cstring
    mov [rel credit_discord_id_length], rax
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 100
    je runtime_native_credit_ambiguous
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_update_paid]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_native_credit_error
    mov rcx, [rel statement_handle]
    mov edx, 1
    lea r8, [rel push_id_buffer]
    mov r9, [rel push_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 2
    mov r8, [rel parsed_amount_value]
    call yul_sqlite_bind_int64
    mov rcx, [rel statement_handle]
    mov edx, 3
    mov r8, [rel created_at]
    call yul_sqlite_bind_int64
    mov rcx, [rel statement_handle]
    mov edx, 4
    lea r8, [rel credit_order_id]
    mov r9, [rel credit_order_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 101
    jne runtime_native_credit_error_statement
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_insert_ledger]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_native_credit_error
    mov rcx, [rel statement_handle]
    mov edx, 1
    lea r8, [rel credit_order_id]
    mov r9, [rel credit_order_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 2
    lea r8, [rel credit_discord_id]
    mov r9, [rel credit_discord_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 3
    mov r8, [rel parsed_amount_value]
    call yul_sqlite_bind_int64
    mov rcx, [rel statement_handle]
    mov edx, 4
    lea r8, [rel reason_deposit]
    mov r9d, 7
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 5
    mov r8, [rel created_at]
    call yul_sqlite_bind_int64
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 101
    jne runtime_native_credit_error_statement
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_get_total]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_native_credit_error
    mov rcx, [rel statement_handle]
    mov edx, 1
    lea r8, [rel credit_discord_id]
    mov r9, [rel credit_discord_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 100
    jne runtime_native_credit_total_zero
    mov rcx, [rel statement_handle]
    xor edx, edx
    call yul_sqlite_column_int64
    mov [rel credit_current_total], rax
    jmp runtime_native_credit_total_done
runtime_native_credit_total_zero:
    mov qword [rel credit_current_total], 0
runtime_native_credit_total_done:
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    mov rcx, [rel credit_current_total]
    mov rdx, [rel parsed_amount_value]
    lea r8, [rel credit_next_total]
    call yul_add_support_total
    test eax, eax
    jnz runtime_native_credit_error
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_upsert_total]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_native_credit_error
    mov rcx, [rel statement_handle]
    mov edx, 1
    lea r8, [rel credit_discord_id]
    mov r9, [rel credit_discord_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 2
    mov r8, [rel credit_next_total]
    call yul_sqlite_bind_int64
    mov rcx, [rel statement_handle]
    mov edx, 3
    mov r8, [rel created_at]
    call yul_sqlite_bind_int64
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 101
    jne runtime_native_credit_error_statement
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_mark_consumed]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_native_credit_error
    mov rcx, [rel statement_handle]
    mov edx, 1
    lea r8, [rel credit_order_id]
    mov r9, [rel credit_order_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    mov edx, 2
    lea r8, [rel push_id_buffer]
    mov r9, [rel push_id_length]
    call yul_sqlite_bind_text
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 101
    jne runtime_native_credit_error_statement
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_commit]
    call yul_sqlite_exec
    test eax, eax
    jnz runtime_native_credit_error
    xor eax, eax
    add rsp, 0x28
    ret
runtime_native_credit_no_match:
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    mov eax, 1
    add rsp, 0x28
    ret
runtime_native_credit_ambiguous:
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
    mov eax, 1
    add rsp, 0x28
    ret
runtime_native_credit_error_statement:
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
runtime_native_credit_error:
    mov eax, 2
    add rsp, 0x28
    ret

runtime_make_push_fingerprint:
    push rbx
    push rsi
    push rdi
    push r12
    mov dword [rel json_key_found], 0
    mov rax, 14695981039346656037
    mov rbx, 1099511628211
    cmp qword [rel push_mirror_kind], 1
    jne runtime_make_push_fingerprint_raw
    cmp qword [rel push_fingerprint_pending], 0
    je runtime_make_push_fingerprint_raw
    lea rsi, [rel json_buffer]
    mov r12, [rel json_length]
    call runtime_fingerprint_hash_payload
    test r8d, r8d
    jz runtime_make_push_fingerprint_format
    mov dword [rel json_key_found], 1
    mov qword [rel push_mirror_kind], 2
    mov rax, 14695981039346656037
    jmp runtime_make_push_fingerprint_raw_buffer
runtime_make_push_fingerprint_raw:
    lea rsi, [rel json_buffer]
runtime_make_push_fingerprint_raw_buffer:
    xor r12, r12
runtime_make_push_fingerprint_loop:
    cmp r12, [rel json_length]
    jae runtime_make_push_fingerprint_format
    movzx edi, byte [rsi + r12]
    xor rax, rdi
    imul rax, rbx
    inc r12
    jmp runtime_make_push_fingerprint_loop
runtime_make_push_fingerprint_format:
    lea rdi, [rel push_id_buffer]
    cmp qword [rel push_mirror_kind], 1
    jne runtime_make_push_fingerprint_invalid_prefix
    mov byte [rdi], 'm'
    mov byte [rdi + 1], 'i'
    mov byte [rdi + 2], 'r'
    mov byte [rdi + 3], 'r'
    mov byte [rdi + 4], 'o'
    mov byte [rdi + 5], 'r'
    mov byte [rdi + 6], '-'
    mov r8d, 7
    mov r9d, 23
    jmp runtime_make_push_fingerprint_prefix_ready
runtime_make_push_fingerprint_invalid_prefix:
    mov byte [rdi], 'i'
    mov byte [rdi + 1], 'n'
    mov byte [rdi + 2], 'v'
    mov byte [rdi + 3], 'a'
    mov byte [rdi + 4], 'l'
    mov byte [rdi + 5], 'i'
    mov byte [rdi + 6], 'd'
    mov byte [rdi + 7], '-'
    mov r8d, 8
    mov r9d, 24
runtime_make_push_fingerprint_prefix_ready:
    lea rsi, [rel hex_digits]
    mov r12d, 16
runtime_make_push_fingerprint_hex:
    mov rdx, rax
    shr rdx, 60
    mov dl, [rsi + rdx]
    mov [rdi + r8], dl
    shl rax, 4
    inc rdi
    dec r12d
    jnz runtime_make_push_fingerprint_hex
    sub rdi, 16
    mov byte [rdi + r9], 0
    mov qword [rel json_value_length], r9
    mov eax, [rel json_key_found]
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

runtime_fingerprint_hash_payload:
    push r13
    push r14
    push r15
    xor ecx, ecx
runtime_fingerprint_payload_start:
    cmp rcx, r12
    jae runtime_fingerprint_payload_fail
    mov dil, [rsi + rcx]
    cmp dil, 32
    je runtime_fingerprint_payload_start_space
    cmp dil, 9
    je runtime_fingerprint_payload_start_space
    cmp dil, 10
    je runtime_fingerprint_payload_start_space
    cmp dil, 13
    je runtime_fingerprint_payload_start_space
    cmp dil, '{'
    jne runtime_fingerprint_payload_fail
    inc rcx
    xor r14d, r14d
runtime_fingerprint_payload_field:
    cmp rcx, r12
    jae runtime_fingerprint_payload_fail
    mov dil, [rsi + rcx]
    cmp dil, 32
    je runtime_fingerprint_payload_field_space
    cmp dil, 9
    je runtime_fingerprint_payload_field_space
    cmp dil, 10
    je runtime_fingerprint_payload_field_space
    cmp dil, 13
    je runtime_fingerprint_payload_field_space
    cmp dil, '}'
    jne runtime_fingerprint_payload_field_not_close
    test r14, r14
    jnz runtime_fingerprint_payload_fail
    jmp runtime_fingerprint_payload_close
runtime_fingerprint_payload_field_not_close:
    cmp dil, '"'
    jne runtime_fingerprint_payload_fail
    xor r14d, r14d
    lea rdx, [rcx + 1]
    mov r8, rdx
runtime_fingerprint_payload_key_loop:
    cmp r8, r12
    jae runtime_fingerprint_payload_fail
    mov dil, [rsi + r8]
    cmp dil, 92
    je runtime_fingerprint_payload_key_escape
    cmp dil, '"'
    je runtime_fingerprint_payload_key_done
    inc r8
    jmp runtime_fingerprint_payload_key_loop
runtime_fingerprint_payload_key_escape:
    inc r8
    cmp r8, r12
    jae runtime_fingerprint_payload_fail
    inc r8
    jmp runtime_fingerprint_payload_key_loop
runtime_fingerprint_payload_key_done:
    mov r11, r8
    mov r10, r8
    sub r10, rdx
    xor r13d, r13d
    cmp r10, 4
    jne runtime_fingerprint_payload_key_check_created
    cmp byte [rsi + rdx], 'i'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 1], 'd'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 2], 'e'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 3], 'n'
    jne runtime_fingerprint_payload_key_checked
    mov r13d, 1
    jmp runtime_fingerprint_payload_key_checked
runtime_fingerprint_payload_key_check_created:
    cmp r10, 7
    jne runtime_fingerprint_payload_key_check_modified
    cmp byte [rsi + rdx], 'c'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 1], 'r'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 2], 'e'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 3], 'a'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 4], 't'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 5], 'e'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 6], 'd'
    jne runtime_fingerprint_payload_key_checked
    mov r13d, 1
    jmp runtime_fingerprint_payload_key_checked
runtime_fingerprint_payload_key_check_modified:
    cmp r10, 8
    jne runtime_fingerprint_payload_key_check_active
    cmp byte [rsi + rdx], 'm'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 1], 'o'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 2], 'd'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 3], 'i'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 4], 'f'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 5], 'i'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 6], 'e'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 7], 'd'
    jne runtime_fingerprint_payload_key_checked
    mov r13d, 1
    jmp runtime_fingerprint_payload_key_checked
runtime_fingerprint_payload_key_check_active:
    cmp r10, 6
    jne runtime_fingerprint_payload_key_check_dismissed
    cmp byte [rsi + rdx], 'a'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 1], 'c'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 2], 't'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 3], 'i'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 4], 'v'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 5], 'e'
    jne runtime_fingerprint_payload_key_checked
    mov r13d, 1
    jmp runtime_fingerprint_payload_key_checked
runtime_fingerprint_payload_key_check_dismissed:
    cmp r10, 9
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx], 'd'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 1], 'i'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 2], 's'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 3], 'm'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 4], 'i'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 5], 's'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 6], 's'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 7], 'e'
    jne runtime_fingerprint_payload_key_checked
    cmp byte [rsi + rdx + 8], 'd'
    jne runtime_fingerprint_payload_key_checked
    mov r13d, 1
runtime_fingerprint_payload_key_checked:
    mov r8, r11
    test r13d, r13d
    jnz runtime_fingerprint_payload_key_hashed
    mov r9, rdx
    mov r10, r8
runtime_fingerprint_payload_key_hash_loop:
    cmp r9, r10
    jae runtime_fingerprint_payload_key_hash_done
    movzx edi, byte [rsi + r9]
    xor rax, rdi
    imul rax, rbx
    inc r9
    jmp runtime_fingerprint_payload_key_hash_loop
runtime_fingerprint_payload_key_hash_done:
    xor edi, edi
    xor rax, rdi
    imul rax, rbx
runtime_fingerprint_payload_key_hashed:
    lea rcx, [r8 + 1]
runtime_fingerprint_payload_after_key:
    cmp rcx, r12
    jae runtime_fingerprint_payload_fail
    mov dil, [rsi + rcx]
    cmp dil, 32
    je runtime_fingerprint_payload_after_key_space
    cmp dil, 9
    je runtime_fingerprint_payload_after_key_space
    cmp dil, 10
    je runtime_fingerprint_payload_after_key_space
    cmp dil, 13
    je runtime_fingerprint_payload_after_key_space
    cmp dil, ':'
    jne runtime_fingerprint_payload_fail
    inc rcx
runtime_fingerprint_payload_before_value:
    cmp rcx, r12
    jae runtime_fingerprint_payload_fail
    mov dil, [rsi + rcx]
    cmp dil, 32
    je runtime_fingerprint_payload_before_value_space
    cmp dil, 9
    je runtime_fingerprint_payload_before_value_space
    cmp dil, 10
    je runtime_fingerprint_payload_before_value_space
    cmp dil, 13
    je runtime_fingerprint_payload_before_value_space
    mov r9, rcx
    cmp dil, '"'
    je runtime_fingerprint_payload_value_string
    cmp dil, '{'
    je runtime_fingerprint_payload_value_compound
    cmp dil, '['
    je runtime_fingerprint_payload_value_compound
    cmp dil, ','
    je runtime_fingerprint_payload_fail
    cmp dil, '}'
    je runtime_fingerprint_payload_fail
    jmp runtime_fingerprint_payload_value_primitive
runtime_fingerprint_payload_value_string:
    lea r10, [r9 + 1]
runtime_fingerprint_payload_value_string_loop:
    cmp r10, r12
    jae runtime_fingerprint_payload_fail
    mov dil, [rsi + r10]
    cmp dil, 92
    je runtime_fingerprint_payload_value_string_escape
    cmp dil, '"'
    je runtime_fingerprint_payload_value_end_one
    inc r10
    jmp runtime_fingerprint_payload_value_string_loop
runtime_fingerprint_payload_value_string_escape:
    inc r10
    cmp r10, r12
    jae runtime_fingerprint_payload_fail
    inc r10
    jmp runtime_fingerprint_payload_value_string_loop
runtime_fingerprint_payload_value_end_one:
    inc r10
    jmp runtime_fingerprint_payload_value_ready
runtime_fingerprint_payload_value_compound:
    lea r15, [rel json_structure_stack]
    mov r14d, 1
    mov [r15], dil
    lea r10, [r9 + 1]
    xor r11d, r11d
runtime_fingerprint_payload_value_compound_loop:
    cmp r10, r12
    jae runtime_fingerprint_payload_fail
    mov dil, [rsi + r10]
    test r11b, 1
    jnz runtime_fingerprint_payload_value_in_string
    cmp dil, '"'
    je runtime_fingerprint_payload_value_string_open
    cmp dil, '{'
    je runtime_fingerprint_payload_value_open
    cmp dil, '['
    je runtime_fingerprint_payload_value_open
    cmp dil, '}'
    je runtime_fingerprint_payload_value_close_object
    cmp dil, ']'
    je runtime_fingerprint_payload_value_close_array
    inc r10
    jmp runtime_fingerprint_payload_value_compound_loop
runtime_fingerprint_payload_value_string_open:
    mov r11d, 1
    inc r10
    jmp runtime_fingerprint_payload_value_compound_loop
runtime_fingerprint_payload_value_open:
    cmp r14, 255
    jae runtime_fingerprint_payload_fail
    mov [r15 + r14], dil
    inc r14
    inc r10
    jmp runtime_fingerprint_payload_value_compound_loop
runtime_fingerprint_payload_value_close_object:
    test r14, r14
    jz runtime_fingerprint_payload_fail
    mov r8, r14
    dec r8
    cmp byte [r15 + r8], '{'
    jne runtime_fingerprint_payload_fail
    dec r14
    inc r10
    test r14, r14
    jnz runtime_fingerprint_payload_value_compound_loop
    jmp runtime_fingerprint_payload_value_ready
runtime_fingerprint_payload_value_close_array:
    test r14, r14
    jz runtime_fingerprint_payload_fail
    mov r8, r14
    dec r8
    cmp byte [r15 + r8], '['
    jne runtime_fingerprint_payload_fail
    dec r14
    inc r10
    test r14, r14
    jnz runtime_fingerprint_payload_value_compound_loop
    jmp runtime_fingerprint_payload_value_ready
runtime_fingerprint_payload_value_in_string:
    test r11b, 2
    jnz runtime_fingerprint_payload_value_escape_done
    cmp dil, 92
    je runtime_fingerprint_payload_value_escape
    cmp dil, '"'
    je runtime_fingerprint_payload_value_string_close
    inc r10
    jmp runtime_fingerprint_payload_value_compound_loop
runtime_fingerprint_payload_value_escape:
    or r11d, 2
    inc r10
    jmp runtime_fingerprint_payload_value_compound_loop
runtime_fingerprint_payload_value_escape_done:
    and r11d, 1
    inc r10
    jmp runtime_fingerprint_payload_value_compound_loop
runtime_fingerprint_payload_value_string_close:
    xor r11d, r11d
    inc r10
    jmp runtime_fingerprint_payload_value_compound_loop
runtime_fingerprint_payload_value_primitive:
    mov r10, r9
runtime_fingerprint_payload_value_primitive_loop:
    cmp r10, r12
    jae runtime_fingerprint_payload_fail
    mov dil, [rsi + r10]
    cmp dil, ','
    je runtime_fingerprint_payload_value_ready
    cmp dil, '}'
    je runtime_fingerprint_payload_value_ready
    cmp dil, ']'
    je runtime_fingerprint_payload_fail
    inc r10
    jmp runtime_fingerprint_payload_value_primitive_loop
runtime_fingerprint_payload_value_ready:
    test r13d, r13d
    jnz runtime_fingerprint_payload_value_hashed
    mov r8, r9
runtime_fingerprint_payload_value_hash_loop:
    cmp r8, r10
    jae runtime_fingerprint_payload_value_hash_done
    movzx edi, byte [rsi + r8]
    xor rax, rdi
    imul rax, rbx
    inc r8
    jmp runtime_fingerprint_payload_value_hash_loop
runtime_fingerprint_payload_value_hash_done:
    mov edi, 255
    xor rax, rdi
    imul rax, rbx
runtime_fingerprint_payload_value_hashed:
    mov rcx, r10
runtime_fingerprint_payload_after_value:
    cmp rcx, r12
    jae runtime_fingerprint_payload_fail
    mov dil, [rsi + rcx]
    cmp dil, 32
    je runtime_fingerprint_payload_after_value_space
    cmp dil, 9
    je runtime_fingerprint_payload_after_value_space
    cmp dil, 10
    je runtime_fingerprint_payload_after_value_space
    cmp dil, 13
    je runtime_fingerprint_payload_after_value_space
    cmp dil, ','
    je runtime_fingerprint_payload_comma
    cmp dil, '}'
    je runtime_fingerprint_payload_close
    jmp runtime_fingerprint_payload_fail
runtime_fingerprint_payload_comma:
    inc rcx
    mov r14d, 1
    jmp runtime_fingerprint_payload_field
runtime_fingerprint_payload_close:
    inc rcx
runtime_fingerprint_payload_trailing:
    cmp rcx, r12
    jae runtime_fingerprint_payload_success
    mov dil, [rsi + rcx]
    cmp dil, 32
    je runtime_fingerprint_payload_trailing_space
    cmp dil, 9
    je runtime_fingerprint_payload_trailing_space
    cmp dil, 10
    je runtime_fingerprint_payload_trailing_space
    cmp dil, 13
    je runtime_fingerprint_payload_trailing_space
    jmp runtime_fingerprint_payload_fail
runtime_fingerprint_payload_start_space:
    inc rcx
    jmp runtime_fingerprint_payload_start
runtime_fingerprint_payload_field_space:
    inc rcx
    jmp runtime_fingerprint_payload_field
runtime_fingerprint_payload_after_key_space:
    inc rcx
    jmp runtime_fingerprint_payload_after_key
runtime_fingerprint_payload_before_value_space:
    inc rcx
    jmp runtime_fingerprint_payload_before_value
runtime_fingerprint_payload_after_value_space:
    inc rcx
    jmp runtime_fingerprint_payload_after_value
runtime_fingerprint_payload_trailing_space:
    inc rcx
    jmp runtime_fingerprint_payload_trailing
runtime_fingerprint_payload_success:
    xor r8d, r8d
    pop r15
    pop r14
    pop r13
    ret
runtime_fingerprint_payload_fail:
    mov r8d, 1
    pop r15
    pop r14
    pop r13
    ret

runtime_fingerprint_is_lifecycle:
    cmp rdx, 4
    jne runtime_fingerprint_lifecycle_created
    lea r8, [rel json_key_id]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_fingerprint_lifecycle_yes
    jmp runtime_fingerprint_lifecycle_no
runtime_fingerprint_lifecycle_created:
    cmp rdx, 7
    jne runtime_fingerprint_lifecycle_modified
    lea r8, [rel fingerprint_key_created]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_fingerprint_lifecycle_yes
    jmp runtime_fingerprint_lifecycle_no
runtime_fingerprint_lifecycle_modified:
    cmp rdx, 8
    jne runtime_fingerprint_lifecycle_active
    lea r8, [rel fingerprint_key_modified]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_fingerprint_lifecycle_yes
    jmp runtime_fingerprint_lifecycle_no
runtime_fingerprint_lifecycle_active:
    cmp rdx, 6
    jne runtime_fingerprint_lifecycle_dismissed
    lea r8, [rel fingerprint_key_active]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_fingerprint_lifecycle_yes
    jmp runtime_fingerprint_lifecycle_no
runtime_fingerprint_lifecycle_dismissed:
    cmp rdx, 9
    jne runtime_fingerprint_lifecycle_no
    lea r8, [rel fingerprint_key_dismissed]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_fingerprint_lifecycle_yes
runtime_fingerprint_lifecycle_no:
    xor eax, eax
    ret
runtime_fingerprint_lifecycle_yes:
    mov eax, 1
    ret

runtime_fingerprint_hash_span:
    xor ecx, ecx
runtime_fingerprint_hash_span_loop:
    cmp rcx, r12
    jae runtime_fingerprint_hash_span_done
    movzx edi, byte [rsi + rcx]
    xor rax, rdi
    imul rax, rbx
    inc rcx
    jmp runtime_fingerprint_hash_span_loop
runtime_fingerprint_hash_span_done:
    ret

runtime_fingerprint_hash_optional_json:
    sub rsp, 0x28
    lea r8, [rel fingerprint_scratch]
    mov r9d, 1024
    call runtime_json_value
    test eax, eax
    jnz runtime_fingerprint_hash_optional_missing
    mov edi, 1
    xor rax, rdi
    imul rax, rbx
    lea rsi, [rel fingerprint_scratch]
    mov r12, [rel json_value_length]
    call runtime_fingerprint_hash_span
    jmp runtime_fingerprint_hash_optional_separator
runtime_fingerprint_hash_optional_missing:
    xor edi, edi
    xor rax, rdi
    imul rax, rbx
runtime_fingerprint_hash_optional_separator:
    mov edi, 255
    xor rax, rdi
    imul rax, rbx
    add rsp, 0x28
    ret

runtime_copy_cstring:
    xor eax, eax
runtime_copy_cstring_loop:
    cmp eax, r8d
    jae runtime_copy_cstring_done
    mov r10b, [rcx + rax]
    mov [rdx + rax], r10b
    inc eax
    test r10b, r10b
    jnz runtime_copy_cstring_loop
    dec eax
runtime_copy_cstring_done:
    mov byte [rdx + rax], 0
    ret

runtime_check_source_filters:
    cmp qword [rel filter_package_length], 0
    je runtime_filter_rejected
    mov rax, [rel package_length]
    cmp rax, [rel filter_package_length]
    jne runtime_filter_rejected
    mov rcx, filter_package
    mov rdx, [rel filter_package_length]
    lea r8, [rel package_buffer]
    call runtime_bytes_equal
    test eax, eax
    jz runtime_filter_rejected
runtime_check_application:
    cmp qword [rel filter_application_length], 0
    je runtime_filter_rejected
    mov rax, [rel application_length]
    cmp rax, [rel filter_application_length]
    jne runtime_filter_rejected
    mov rcx, filter_application
    mov rdx, [rel filter_application_length]
    lea r8, [rel application_buffer]
    call runtime_bytes_equal
    test eax, eax
    jz runtime_filter_rejected
runtime_check_title:
    cmp qword [rel filter_title_prefix_length], 0
    je runtime_check_title_pattern_only
    mov rax, [rel title_length]
    cmp rax, [rel filter_title_prefix_length]
    jb runtime_filter_rejected
    mov rcx, filter_title_prefix
    mov rdx, [rel filter_title_prefix_length]
    lea r8, [rel title_buffer]
    call runtime_bytes_equal
    test eax, eax
    jz runtime_filter_rejected
runtime_check_title_pattern_optional:
    cmp qword [rel filter_title_pattern_length], 0
    je runtime_filter_accepted
    call runtime_title_pattern_matches
    test eax, eax
    jz runtime_filter_rejected
    jmp runtime_filter_accepted
runtime_check_title_pattern_only:
    cmp qword [rel filter_title_pattern_length], 0
    je runtime_filter_rejected
    call runtime_title_pattern_matches
    test eax, eax
    jz runtime_filter_rejected
runtime_filter_accepted:
    xor eax, eax
    ret
runtime_filter_rejected:
    mov eax, 1
    ret

runtime_bytes_equal:
    xor eax, eax
    xor r9d, r9d
runtime_bytes_equal_loop:
    cmp r9, rdx
    jae runtime_bytes_equal_yes
    mov r10b, [rcx + r9]
    cmp r10b, [r8 + r9]
    jne runtime_bytes_equal_no
    inc r9
    jmp runtime_bytes_equal_loop
runtime_bytes_equal_yes:
    mov eax, 1
runtime_bytes_equal_no:
    ret

runtime_cstring_equal:
    xor r8d, r8d
runtime_cstring_equal_loop:
    mov r9b, [rcx + r8]
    cmp r9b, [rdx + r8]
    jne runtime_cstring_equal_no
    test r9b, r9b
    jz runtime_cstring_equal_yes
    inc r8
    jmp runtime_cstring_equal_loop
runtime_cstring_equal_yes:
    mov eax, 1
    ret
runtime_cstring_equal_no:
    xor eax, eax
    ret

runtime_validate_pattern_contract:
    push rbx
    push rsi
    push rdi
    sub rsp, 0x28
    mov rbx, rcx
    mov rsi, rdx
    mov rdi, r8
    mov rcx, rbx
    mov rdx, rsi
    call runtime_cstring_equal
    test eax, eax
    jnz runtime_validate_pattern_success
    test rdi, rdi
    jz runtime_validate_pattern_fail
    mov rcx, rbx
    mov rdx, rdi
    call runtime_cstring_equal
    test eax, eax
    jz runtime_validate_pattern_fail
runtime_validate_pattern_success:
    xor eax, eax
    jmp runtime_validate_pattern_return
runtime_validate_pattern_fail:
    mov eax, 1
runtime_validate_pattern_return:
    add rsp, 0x28
    pop rdi
    pop rsi
    pop rbx
    ret

runtime_title_pattern_matches:
    lea rcx, [rel filter_title_pattern]
    lea rdx, [rel supported_title_pattern]
    call runtime_cstring_equal
    test eax, eax
    jz runtime_title_pattern_no
    lea rsi, [rel title_buffer]
    mov rdi, [rel title_length]
    xor r8d, r8d
    xor r9d, r9d
runtime_title_pattern_digits:
    cmp r8, rdi
    jae runtime_title_pattern_digits_done
    mov r10b, [rsi + r8]
    cmp r10b, 48
    jb runtime_title_pattern_digits_done
    cmp r10b, 57
    ja runtime_title_pattern_comma
    inc r9
    inc r8
    jmp runtime_title_pattern_digits
runtime_title_pattern_comma:
    cmp r10b, 44
    jne runtime_title_pattern_digits_done
    test r9, r9
    jz runtime_title_pattern_no
    inc r8
    jmp runtime_title_pattern_digits
runtime_title_pattern_digits_done:
    test r9, r9
    jz runtime_title_pattern_no
    lea r10, [r8 + 3]
    cmp r10, rdi
    jae runtime_title_pattern_no
    cmp byte [rsi + r8], 0xec
    jne runtime_title_pattern_no
    cmp byte [rsi + r8 + 1], 0x9b
    jne runtime_title_pattern_no
    cmp byte [rsi + r8 + 2], 0x90
    jne runtime_title_pattern_no
    add r8, 3
runtime_title_pattern_space:
    cmp r8, rdi
    jae runtime_title_pattern_no
    mov r10b, [rsi + r8]
    cmp r10b, 32
    je runtime_title_pattern_space_one
    cmp r10b, 9
    je runtime_title_pattern_space_one
    cmp r10b, 10
    je runtime_title_pattern_space_one
    cmp r10b, 13
    jne runtime_title_pattern_deposit
runtime_title_pattern_space_one:
    inc r8
    jmp runtime_title_pattern_space
runtime_title_pattern_deposit:
    lea r10, [r8 + 6]
    cmp r10, rdi
    jne runtime_title_pattern_no
    cmp byte [rsi + r8], 0xec
    jne runtime_title_pattern_no
    cmp byte [rsi + r8 + 1], 0x9e
    jne runtime_title_pattern_no
    cmp byte [rsi + r8 + 2], 0x85
    jne runtime_title_pattern_no
    cmp byte [rsi + r8 + 3], 0xea
    jne runtime_title_pattern_no
    cmp byte [rsi + r8 + 4], 0xb8
    jne runtime_title_pattern_no
    cmp byte [rsi + r8 + 5], 0x88
    jne runtime_title_pattern_no
    mov eax, 1
    ret
runtime_title_pattern_no:
    xor eax, eax
    ret

runtime_sql_rollback:
    sub rsp, 0x28
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_rollback]
    call yul_sqlite_exec
    add rsp, 0x28
    ret

runtime_json_validate_structure:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    mov r12, json_buffer
    mov r13, [rel json_length]
    xor ebx, ebx
    xor esi, esi
    xor r14d, r14d
    xor r15d, r15d
    lea r8, [rel json_structure_stack]
runtime_json_validate_loop:
    cmp rbx, r13
    jae runtime_json_validate_done
    mov al, [r12 + rbx]
    mov r11b, al
    cmp al, 32
    je runtime_json_validate_next
    cmp al, 9
    je runtime_json_validate_next
    cmp al, 10
    je runtime_json_validate_next
    cmp al, 13
    je runtime_json_validate_next
    test rsi, rsi
    jz runtime_json_validate_root
    lea r10, [rsi - 1]
    movzx eax, byte [r8 + r10]
    cmp eax, 1
    je runtime_json_validate_object_key_or_end
    cmp eax, 2
    je runtime_json_validate_object_key_required
    cmp eax, 3
    je runtime_json_validate_object_colon
    cmp eax, 4
    je runtime_json_validate_value
    cmp eax, 5
    je runtime_json_validate_object_comma_or_end
    cmp eax, 6
    je runtime_json_validate_value_or_end
    cmp eax, 7
    je runtime_json_validate_value_required
    cmp eax, 8
    je runtime_json_validate_array_comma_or_end
    jmp runtime_json_validate_fail
runtime_json_validate_root:
    test r14d, r14d
    jnz runtime_json_validate_fail
    jmp runtime_json_validate_value
runtime_json_validate_object_key_or_end:
    cmp r11b, 125
    je runtime_json_validate_close_object
runtime_json_validate_object_key_required:
    cmp r11b, 34
    jne runtime_json_validate_fail
    mov r15d, 1
    inc rbx
    jmp runtime_json_validate_string_loop
runtime_json_validate_object_colon:
    cmp r11b, 58
    jne runtime_json_validate_fail
    mov byte [r8 + r10], 4
    inc rbx
    jmp runtime_json_validate_loop
runtime_json_validate_object_comma_or_end:
    cmp r11b, 44
    je runtime_json_validate_object_comma
    cmp r11b, 125
    je runtime_json_validate_close_object
    jmp runtime_json_validate_fail
runtime_json_validate_object_comma:
    mov byte [r8 + r10], 2
    inc rbx
    jmp runtime_json_validate_loop
runtime_json_validate_value_or_end:
    cmp r11b, 93
    je runtime_json_validate_close_array
    jmp runtime_json_validate_value
runtime_json_validate_value_required:
    jmp runtime_json_validate_value
runtime_json_validate_array_comma_or_end:
    cmp r11b, 44
    je runtime_json_validate_array_comma
    cmp r11b, 93
    je runtime_json_validate_close_array
    jmp runtime_json_validate_fail
runtime_json_validate_array_comma:
    mov byte [r8 + r10], 7
    inc rbx
    jmp runtime_json_validate_loop
runtime_json_validate_value:
    cmp r11b, 34
    je runtime_json_validate_value_string
    cmp r11b, 123
    je runtime_json_validate_open_object
    cmp r11b, 91
    je runtime_json_validate_open_array
    cmp r11b, 45
    je runtime_json_validate_number
    cmp r11b, 48
    jb runtime_json_validate_value_literal
    cmp r11b, 57
    jbe runtime_json_validate_number
    jmp runtime_json_validate_value_literal
runtime_json_validate_value_string:
    mov r15d, 2
    inc rbx
    jmp runtime_json_validate_string_loop
runtime_json_validate_open_object:
    cmp rsi, 255
    jae runtime_json_validate_fail
    mov byte [r8 + rsi], 1
    inc rsi
    inc rbx
    jmp runtime_json_validate_loop
runtime_json_validate_open_array:
    cmp rsi, 255
    jae runtime_json_validate_fail
    mov byte [r8 + rsi], 6
    inc rsi
    inc rbx
    jmp runtime_json_validate_loop
runtime_json_validate_string_loop:
    cmp rbx, r13
    jae runtime_json_validate_fail
    mov al, [r12 + rbx]
    cmp al, 92
    je runtime_json_validate_string_escape
    cmp al, 34
    je runtime_json_validate_string_close
    cmp al, 32
    jb runtime_json_validate_fail
    inc rbx
    jmp runtime_json_validate_string_loop
runtime_json_validate_string_escape:
    inc rbx
    cmp rbx, r13
    jae runtime_json_validate_fail
    mov al, [r12 + rbx]
    cmp al, 34
    je runtime_json_validate_string_escape_one
    cmp al, 47
    je runtime_json_validate_string_escape_one
    cmp al, 92
    je runtime_json_validate_string_escape_one
    cmp al, 98
    je runtime_json_validate_string_escape_one
    cmp al, 102
    je runtime_json_validate_string_escape_one
    cmp al, 110
    je runtime_json_validate_string_escape_one
    cmp al, 114
    je runtime_json_validate_string_escape_one
    cmp al, 116
    je runtime_json_validate_string_escape_one
    cmp al, 117
    je runtime_json_validate_unicode_escape
    jmp runtime_json_validate_fail
runtime_json_validate_string_escape_one:
    inc rbx
    jmp runtime_json_validate_string_loop
runtime_json_validate_unicode_escape:
    inc rbx
    mov r10, 4
runtime_json_validate_unicode_loop:
    cmp rbx, r13
    jae runtime_json_validate_fail
    mov al, [r12 + rbx]
    cmp al, 48
    jb runtime_json_validate_unicode_alpha
    cmp al, 57
    jbe runtime_json_validate_unicode_digit
runtime_json_validate_unicode_alpha:
    cmp al, 65
    jb runtime_json_validate_unicode_lower
    cmp al, 70
    jbe runtime_json_validate_unicode_digit
runtime_json_validate_unicode_lower:
    cmp al, 97
    jb runtime_json_validate_fail
    cmp al, 102
    ja runtime_json_validate_fail
runtime_json_validate_unicode_digit:
    inc rbx
    dec r10
    jnz runtime_json_validate_unicode_loop
    jmp runtime_json_validate_string_loop
runtime_json_validate_string_close:
    inc rbx
    cmp r15d, 1
    je runtime_json_validate_key_close
    jmp runtime_json_validate_complete_value
runtime_json_validate_key_close:
    test rsi, rsi
    jz runtime_json_validate_fail
    lea r10, [rsi - 1]
    mov byte [r8 + r10], 3
    jmp runtime_json_validate_loop
runtime_json_validate_close_object:
    test rsi, rsi
    jz runtime_json_validate_fail
    lea r10, [rsi - 1]
    movzx eax, byte [r8 + r10]
    cmp eax, 1
    je runtime_json_validate_close_object_ok
    cmp eax, 5
    jne runtime_json_validate_fail
runtime_json_validate_close_object_ok:
    dec rsi
    inc rbx
    jmp runtime_json_validate_complete_value
runtime_json_validate_close_array:
    test rsi, rsi
    jz runtime_json_validate_fail
    lea r10, [rsi - 1]
    movzx eax, byte [r8 + r10]
    cmp eax, 6
    je runtime_json_validate_close_array_ok
    cmp eax, 8
    jne runtime_json_validate_fail
runtime_json_validate_close_array_ok:
    dec rsi
    inc rbx
    jmp runtime_json_validate_complete_value
runtime_json_validate_complete_value:
    test rsi, rsi
    jz runtime_json_validate_root_complete
    lea r10, [rsi - 1]
    movzx eax, byte [r8 + r10]
    cmp eax, 4
    je runtime_json_validate_complete_object_value
    cmp eax, 6
    je runtime_json_validate_complete_array_value
    cmp eax, 7
    je runtime_json_validate_complete_array_value
    jmp runtime_json_validate_fail
runtime_json_validate_complete_object_value:
    mov byte [r8 + r10], 5
    jmp runtime_json_validate_loop
runtime_json_validate_complete_array_value:
    mov byte [r8 + r10], 8
    jmp runtime_json_validate_loop
runtime_json_validate_root_complete:
    mov r14d, 1
    jmp runtime_json_validate_loop
runtime_json_validate_number:
    mov al, [r12 + rbx]
    cmp al, 45
    jne runtime_json_validate_number_integer
    inc rbx
    cmp rbx, r13
    jae runtime_json_validate_fail
runtime_json_validate_number_integer:
    mov al, [r12 + rbx]
    cmp al, 48
    je runtime_json_validate_number_zero
    cmp al, 49
    jb runtime_json_validate_fail
    cmp al, 57
    ja runtime_json_validate_fail
    inc rbx
runtime_json_validate_number_digits:
    cmp rbx, r13
    jae runtime_json_validate_number_after_integer
    mov al, [r12 + rbx]
    cmp al, 48
    jb runtime_json_validate_number_after_integer
    cmp al, 57
    ja runtime_json_validate_number_after_integer
    inc rbx
    jmp runtime_json_validate_number_digits
runtime_json_validate_number_zero:
    inc rbx
    cmp rbx, r13
    jae runtime_json_validate_number_after_integer
    mov al, [r12 + rbx]
    cmp al, 48
    jb runtime_json_validate_number_after_integer
    cmp al, 57
    jbe runtime_json_validate_fail
runtime_json_validate_number_after_integer:
    cmp rbx, r13
    jae runtime_json_validate_complete_value
    mov al, [r12 + rbx]
    cmp al, 46
    je runtime_json_validate_number_fraction
    cmp al, 101
    je runtime_json_validate_number_exponent
    cmp al, 69
    je runtime_json_validate_number_exponent
    jmp runtime_json_validate_complete_value
runtime_json_validate_number_fraction:
    inc rbx
    cmp rbx, r13
    jae runtime_json_validate_fail
    mov al, [r12 + rbx]
    cmp al, 48
    jb runtime_json_validate_fail
    cmp al, 57
    ja runtime_json_validate_fail
    inc rbx
runtime_json_validate_fraction_digits:
    cmp rbx, r13
    jae runtime_json_validate_number_after_fraction
    mov al, [r12 + rbx]
    cmp al, 48
    jb runtime_json_validate_number_after_fraction
    cmp al, 57
    ja runtime_json_validate_number_after_fraction
    inc rbx
    jmp runtime_json_validate_fraction_digits
runtime_json_validate_number_after_fraction:
    cmp rbx, r13
    jae runtime_json_validate_complete_value
    mov al, [r12 + rbx]
    cmp al, 101
    je runtime_json_validate_number_exponent
    cmp al, 69
    je runtime_json_validate_number_exponent
    jmp runtime_json_validate_complete_value
runtime_json_validate_number_exponent:
    inc rbx
    cmp rbx, r13
    jae runtime_json_validate_fail
    mov al, [r12 + rbx]
    cmp al, 43
    je runtime_json_validate_number_exponent_sign
    cmp al, 45
    je runtime_json_validate_number_exponent_sign
    jmp runtime_json_validate_number_exponent_digit
runtime_json_validate_number_exponent_sign:
    inc rbx
    cmp rbx, r13
    jae runtime_json_validate_fail
runtime_json_validate_number_exponent_digit:
    mov al, [r12 + rbx]
    cmp al, 48
    jb runtime_json_validate_fail
    cmp al, 57
    ja runtime_json_validate_fail
    inc rbx
runtime_json_validate_exponent_digits:
    cmp rbx, r13
    jae runtime_json_validate_complete_value
    mov al, [r12 + rbx]
    cmp al, 48
    jb runtime_json_validate_complete_value
    cmp al, 57
    ja runtime_json_validate_complete_value
    inc rbx
    jmp runtime_json_validate_exponent_digits
runtime_json_validate_value_literal:
    cmp r11b, 116
    je runtime_json_validate_true
    cmp r11b, 102
    je runtime_json_validate_false
    cmp r11b, 110
    je runtime_json_validate_null
    jmp runtime_json_validate_fail
runtime_json_validate_true:
    lea r10, [rbx + 4]
    cmp r10, r13
    ja runtime_json_validate_fail
    mov al, [r12 + rbx]
    cmp al, 116
    jne runtime_json_validate_fail
    mov al, [r12 + rbx + 1]
    cmp al, 114
    jne runtime_json_validate_fail
    mov al, [r12 + rbx + 2]
    cmp al, 117
    jne runtime_json_validate_fail
    mov al, [r12 + rbx + 3]
    cmp al, 101
    jne runtime_json_validate_fail
    add rbx, 4
    jmp runtime_json_validate_complete_value
runtime_json_validate_false:
    lea r10, [rbx + 5]
    cmp r10, r13
    ja runtime_json_validate_fail
    mov al, [r12 + rbx]
    cmp al, 102
    jne runtime_json_validate_fail
    mov al, [r12 + rbx + 1]
    cmp al, 97
    jne runtime_json_validate_fail
    mov al, [r12 + rbx + 2]
    cmp al, 108
    jne runtime_json_validate_fail
    mov al, [r12 + rbx + 3]
    cmp al, 115
    jne runtime_json_validate_fail
    mov al, [r12 + rbx + 4]
    cmp al, 101
    jne runtime_json_validate_fail
    add rbx, 5
    jmp runtime_json_validate_complete_value
runtime_json_validate_null:
    lea r10, [rbx + 4]
    cmp r10, r13
    ja runtime_json_validate_fail
    mov al, [r12 + rbx]
    cmp al, 110
    jne runtime_json_validate_fail
    mov al, [r12 + rbx + 1]
    cmp al, 117
    jne runtime_json_validate_fail
    mov al, [r12 + rbx + 2]
    cmp al, 108
    jne runtime_json_validate_fail
    mov al, [r12 + rbx + 3]
    cmp al, 108
    jne runtime_json_validate_fail
    add rbx, 4
    jmp runtime_json_validate_complete_value
runtime_json_validate_next:
    inc rbx
    jmp runtime_json_validate_loop
runtime_json_validate_done:
    test rsi, rsi
    jnz runtime_json_validate_fail
    test r14d, r14d
    jz runtime_json_validate_fail
    xor eax, eax
    jmp runtime_json_validate_return
runtime_json_validate_fail:
    mov eax, 1
runtime_json_validate_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

runtime_json_select_push_object:
    mov qword [rel json_selector_found], 0
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    mov r12, json_buffer
    mov r13, [rel json_length]
    xor ebx, ebx
    xor r14d, r14d
runtime_json_select_start:
    cmp rbx, r13
    jae runtime_json_select_success
    mov al, [r12 + rbx]
    cmp al, 32
    je runtime_json_select_skip
    cmp al, 9
    je runtime_json_select_skip
    cmp al, 10
    je runtime_json_select_skip
    cmp al, 13
    je runtime_json_select_skip
    cmp al, 123
    jne runtime_json_select_fail
    mov r14d, 1
    inc rbx
    jmp runtime_json_select_loop
runtime_json_select_skip:
    inc rbx
    jmp runtime_json_select_start
runtime_json_select_loop:
    cmp rbx, r13
    jae runtime_json_select_fail
    mov al, [r12 + rbx]
    cmp al, 34
    je runtime_json_select_string
    cmp al, 123
    je runtime_json_select_open
    cmp al, 91
    je runtime_json_select_open
    cmp al, 125
    je runtime_json_select_close
    cmp al, 93
    je runtime_json_select_close
    inc rbx
    jmp runtime_json_select_loop
runtime_json_select_open:
    inc r14
    inc rbx
    jmp runtime_json_select_loop
runtime_json_select_close:
    dec r14
    jz runtime_json_select_success
    inc rbx
    jmp runtime_json_select_loop
runtime_json_select_string:
    lea r10, [rbx + 1]
    mov r11, r10
runtime_json_select_string_loop:
    cmp r11, r13
    jae runtime_json_select_fail
    mov al, [r12 + r11]
    cmp al, 92
    je runtime_json_select_string_escape
    cmp al, 34
    je runtime_json_select_string_closed
    inc r11
    jmp runtime_json_select_string_loop
runtime_json_select_string_escape:
    add r11, 2
    jmp runtime_json_select_string_loop
runtime_json_select_string_closed:
    cmp r14, 1
    jne runtime_json_select_string_continue
    mov rax, r11
    sub rax, r10
    cmp rax, 4
    jne runtime_json_select_string_continue
    cmp byte [r12 + r10], 'p'
    jne runtime_json_select_string_continue
    cmp byte [r12 + r10 + 1], 'u'
    jne runtime_json_select_string_continue
    cmp byte [r12 + r10 + 2], 's'
    jne runtime_json_select_string_continue
    cmp byte [r12 + r10 + 3], 'h'
    jne runtime_json_select_string_continue
    lea r8, [r11 + 1]
runtime_json_select_push_space:
    cmp r8, r13
    jae runtime_json_select_fail
    mov al, [r12 + r8]
    cmp al, 32
    je runtime_json_select_push_space_one
    cmp al, 9
    je runtime_json_select_push_space_one
    cmp al, 10
    je runtime_json_select_push_space_one
    cmp al, 13
    je runtime_json_select_push_space_one
    cmp al, 58
    jne runtime_json_select_string_continue
    inc r8
runtime_json_select_push_value_space:
    cmp r8, r13
    jae runtime_json_select_fail
    mov al, [r12 + r8]
    cmp al, 32
    je runtime_json_select_push_value_space_one
    cmp al, 9
    je runtime_json_select_push_value_space_one
    cmp al, 10
    je runtime_json_select_push_value_space_one
    cmp al, 13
    je runtime_json_select_push_value_space_one
    cmp al, 123
    jne runtime_json_select_fail
    xor r9d, r9d
    xor r10d, r10d
    xor r11d, r11d
    xor r15d, r15d
    mov rsi, r8
runtime_json_select_object_loop:
    cmp rsi, r13
    jae runtime_json_select_fail
    mov al, [r12 + rsi]
    test r11, r11
    jnz runtime_json_select_object_string
    cmp al, 34
    je runtime_json_select_object_string_start
    cmp al, 123
    je runtime_json_select_object_open
    cmp al, 91
    je runtime_json_select_object_open
    cmp al, 125
    je runtime_json_select_object_close
    cmp al, 93
    je runtime_json_select_object_close
    inc rsi
    jmp runtime_json_select_object_loop
runtime_json_select_object_string_start:
    mov r11d, 1
    inc rsi
    jmp runtime_json_select_object_loop
runtime_json_select_object_string:
    test r15, r15
    jnz runtime_json_select_object_string_escaped
    cmp al, 92
    je runtime_json_select_object_string_escape
    cmp al, 34
    jne runtime_json_select_object_next
    xor r11d, r11d
    jmp runtime_json_select_object_next
runtime_json_select_object_string_escape:
    mov r15d, 1
    jmp runtime_json_select_object_next
runtime_json_select_object_string_escaped:
    xor r15d, r15d
runtime_json_select_object_next:
    inc rsi
    jmp runtime_json_select_object_loop
runtime_json_select_object_open:
    inc r9
    inc rsi
    jmp runtime_json_select_object_loop
runtime_json_select_object_close:
    test r9, r9
    jz runtime_json_select_fail
    dec r9
    jnz runtime_json_select_object_next
    inc rsi
    mov rcx, rsi
    sub rcx, r8
    xor rdx, rdx
    lea rdi, [r12 + r8]
runtime_json_select_copy_loop:
    cmp rdx, rcx
    jae runtime_json_select_copy_done
    mov al, [rdi + rdx]
    mov [r12 + rdx], al
    inc rdx
    jmp runtime_json_select_copy_loop
runtime_json_select_copy_done:
    mov byte [r12 + rcx], 0
    mov [rel json_length], rcx
    mov dword [rel json_selector_found], 1
    jmp runtime_json_select_success
runtime_json_select_push_space_one:
    inc r8
    jmp runtime_json_select_push_space
runtime_json_select_push_value_space_one:
    inc r8
    jmp runtime_json_select_push_value_space
runtime_json_select_string_continue:
    lea rbx, [r11 + 1]
    jmp runtime_json_select_loop
runtime_json_select_fail:
    mov eax, 1
    jmp runtime_json_select_return
runtime_json_select_success:
    xor eax, eax
runtime_json_select_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

runtime_json_value:
    mov dword [rel json_key_found], 0
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8
    mov qword [rsp], 0
    mov r12, rcx
    mov r13, rdx
    mov r14, r8
    mov r15, r9
    lea rsi, [rel json_buffer]
    mov rdi, [rel json_length]
    add rdi, rsi
    mov rbx, rsi
runtime_json_scan:
    cmp rbx, rdi
    jae runtime_json_missing
    cmp byte [rbx], 34
    jne runtime_json_scan_byte
    lea r10, [rbx + 1]
    mov r11, r10
runtime_json_string_scan:
    cmp r11, rdi
    jae runtime_json_missing
    mov al, [r11]
    cmp al, 92
    je runtime_json_string_escape
    cmp al, 34
    je runtime_json_string_closed
    inc r11
    jmp runtime_json_string_scan
runtime_json_string_escape:
    inc r11
    cmp r11, rdi
    jae runtime_json_missing
    inc r11
    jmp runtime_json_string_scan
runtime_json_string_closed:
    lea r8, [r11 + 1]
runtime_json_key_space:
    cmp r8, rdi
    jae runtime_json_missing
    mov al, [r8]
    cmp al, 32
    je runtime_json_key_space_one
    cmp al, 9
    je runtime_json_key_space_one
    cmp al, 10
    je runtime_json_key_space_one
    cmp al, 13
    jne runtime_json_key_colon
runtime_json_key_space_one:
    inc r8
    jmp runtime_json_key_space
runtime_json_key_colon:
    cmp al, 58
    jne runtime_json_scan_next
    cmp qword [rsp], 1
    jne runtime_json_scan_next
    sub r11, r10
    cmp r11, r13
    jne runtime_json_key_length_mismatch
    mov r9, r10
    mov rax, r12
    mov rdx, r13
runtime_json_key_compare:
    test rdx, rdx
    jz runtime_json_key_match
    mov cl, [r9]
    cmp cl, [rax]
    jne runtime_json_key_mismatch
    inc r9
    inc rax
    dec rdx
    jmp runtime_json_key_compare
runtime_json_key_match:
    mov dword [rel json_key_found], 1
    lea r11, [r8 + 1]
runtime_json_value_space:
    cmp r11, rdi
    jae runtime_json_missing
    mov al, [r11]
    cmp al, 32
    je runtime_json_value_space_one
    cmp al, 9
    je runtime_json_value_space_one
    cmp al, 10
    je runtime_json_value_space_one
    cmp al, 13
    jne runtime_json_value_quote
runtime_json_value_space_one:
    inc r11
    jmp runtime_json_value_space
runtime_json_value_quote:
    cmp al, 34
    jne runtime_json_missing
    inc r11
    xor ecx, ecx
runtime_json_copy:
    cmp r11, rdi
    jae runtime_json_missing
    mov al, [r11]
    cmp al, 34
    je runtime_json_copy_done
    cmp ecx, r15d
    jae runtime_json_missing
    cmp al, 92
    jne runtime_json_copy_store
    inc r11
    cmp r11, rdi
    jae runtime_json_missing
    mov al, [r11]
    cmp al, 110
    jne runtime_json_escape_r
    mov al, 10
    jmp runtime_json_copy_store
runtime_json_escape_r:
    cmp al, 114
    jne runtime_json_escape_t
    mov al, 13
    jmp runtime_json_copy_store
runtime_json_escape_t:
    cmp al, 116
    jne runtime_json_copy_store
    mov al, 9
runtime_json_copy_store:
    mov [r14 + rcx], al
    inc ecx
    inc r11
    jmp runtime_json_copy
runtime_json_copy_done:
    mov byte [r14 + rcx], 0
    mov [rel json_value_length], rcx
    xor eax, eax
    jmp runtime_json_return
runtime_json_key_mismatch:
    lea rbx, [r8 + 1]
    jmp runtime_json_scan
runtime_json_key_length_mismatch:
    lea rbx, [r8 + 1]
    jmp runtime_json_scan
runtime_json_scan_byte:
    cmp byte [rbx], 123
    je runtime_json_open
    cmp byte [rbx], 91
    je runtime_json_open
    cmp byte [rbx], 125
    je runtime_json_close
    cmp byte [rbx], 93
    je runtime_json_close
    inc rbx
    jmp runtime_json_scan
runtime_json_open:
    inc qword [rsp]
    inc rbx
    jmp runtime_json_scan
runtime_json_close:
    cmp qword [rsp], 0
    je runtime_json_missing
    dec qword [rsp]
    inc rbx
    jmp runtime_json_scan
runtime_json_scan_next:
    lea rbx, [r11 + 1]
    jmp runtime_json_scan
runtime_json_missing:
    mov byte [r14], 0
    mov eax, 1
runtime_json_return:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

runtime_extract_push_name:
    call runtime_validate_name_candidates
    test eax, eax
    jne runtime_extract_failed
    xor eax, eax
    lea rcx, [rel filter_name]
    lea rdx, [rel supported_name_pattern_arrow]
    call runtime_cstring_equal
    test eax, eax
    jnz runtime_extract_name_arrow
    mov rcx, body_label_name
    mov edx, body_label_name_end-body_label_name
    lea r8, [rel body_buffer]
    mov r9, [rel body_length]
    call runtime_find_substring
    test rax, rax
    jnz runtime_extract_name_body_found
    mov rcx, body_label_sender
    mov edx, body_label_sender_end-body_label_sender
    lea r8, [rel body_buffer]
    mov r9, [rel body_length]
    call runtime_find_substring
    test rax, rax
    jnz runtime_extract_name_body_found
    mov rcx, body_label_sender_space
    mov edx, body_label_sender_space_end-body_label_sender_space
    lea r8, [rel body_buffer]
    mov r9, [rel body_length]
    call runtime_find_substring
    test rax, rax
    jnz runtime_extract_name_body_found
    mov rcx, body_label_sender_ascii
    mov edx, body_label_sender_ascii_end-body_label_sender_ascii
    lea r8, [rel body_buffer]
    mov r9, [rel body_length]
    call runtime_find_substring
    test rax, rax
    jnz runtime_extract_name_body_found
    mov rcx, body_label_name_ascii
    mov edx, body_label_name_ascii_end-body_label_name_ascii
    lea r8, [rel body_buffer]
    mov r9, [rel body_length]
    call runtime_find_substring
    test rax, rax
    jz runtime_extract_name_title_labels
runtime_extract_name_body_found:
    mov rsi, rax
runtime_extract_name_skip:
    mov al, [rsi]
    cmp al, 58
    je runtime_extract_name_skip_one
    cmp al, 32
    je runtime_extract_name_skip_one
    cmp al, 9
    je runtime_extract_name_skip_one
    cmp al, 0xef
    jne runtime_extract_name_copy
    cmp byte [rsi + 1], 0xbc
    jne runtime_extract_name_copy
    cmp byte [rsi + 2], 0x9a
    jne runtime_extract_name_copy
    add rsi, 3
    jmp runtime_extract_name_skip
runtime_extract_name_skip_one:
    inc rsi
    jmp runtime_extract_name_skip
runtime_extract_name_copy:
    lea rdi, [rel parsed_name_buffer]
    xor ecx, ecx
runtime_extract_name_loop:
    mov al, [rsi + rcx]
    cmp al, 10
    je runtime_extract_name_done
    cmp al, 13
    je runtime_extract_name_done
    cmp al, 44
    je runtime_extract_name_done
    cmp al, 40
    je runtime_extract_name_done
    cmp al, 41
    je runtime_extract_name_done
    test al, al
    jz runtime_extract_failed
    mov [rdi + rcx], al
    inc ecx
    cmp ecx, 511
    jb runtime_extract_name_loop
    jmp runtime_extract_failed
runtime_extract_name_title_labels:
    mov rcx, body_label_name
    mov edx, body_label_name_end-body_label_name
    lea r8, [rel title_buffer]
    mov r9, [rel title_length]
    call runtime_find_substring
    test rax, rax
    jnz runtime_extract_name_title_found
    mov rcx, body_label_sender
    mov edx, body_label_sender_end-body_label_sender
    lea r8, [rel title_buffer]
    mov r9, [rel title_length]
    call runtime_find_substring
    test rax, rax
    jnz runtime_extract_name_title_found
    mov rcx, body_label_sender_space
    mov edx, body_label_sender_space_end-body_label_sender_space
    lea r8, [rel title_buffer]
    mov r9, [rel title_length]
    call runtime_find_substring
    test rax, rax
    jnz runtime_extract_name_title_found
    mov rcx, body_label_sender_ascii
    mov edx, body_label_sender_ascii_end-body_label_sender_ascii
    lea r8, [rel title_buffer]
    mov r9, [rel title_length]
    call runtime_find_substring
    test rax, rax
    jnz runtime_extract_name_title_found
    mov rcx, body_label_name_ascii
    mov edx, body_label_name_ascii_end-body_label_name_ascii
    lea r8, [rel title_buffer]
    mov r9, [rel title_length]
    call runtime_find_substring
    test rax, rax
    jz runtime_extract_failed
runtime_extract_name_title_found:
    mov rsi, rax
    jmp runtime_extract_name_skip
runtime_extract_name_done:
    mov byte [rdi + rcx], 0
    mov [rel parsed_name_length], rcx
    lea rcx, [rel parsed_name_buffer]
    mov rdx, [rel parsed_name_length]
    lea r8, [rel normalized_buffer]
    mov r9d, 1024
    lea rax, [rel normalized_length]
    mov [rsp + 0x20], rax
    call yul_normalize_name_utf8
    test eax, eax
    jnz runtime_extract_failed
    call runtime_apply_case_insensitive_latin
    ret

runtime_extract_name_arrow:
    lea rsi, [rel body_buffer]
    mov r9, [rel body_length]
    xor ecx, ecx
runtime_extract_name_arrow_scan:
    lea r10, [rcx + 2]
    cmp r10, r9
    jae runtime_extract_name_arrow_title
    cmp byte [rsi + rcx], 0xe2
    jne runtime_extract_name_arrow_next
    cmp byte [rsi + rcx + 1], 0x86
    jne runtime_extract_name_arrow_next
    cmp byte [rsi + rcx + 2], 0x92
    je runtime_extract_name_arrow_found
runtime_extract_name_arrow_next:
    inc rcx
    jmp runtime_extract_name_arrow_scan
runtime_extract_name_arrow_found:
    mov rdx, rcx
    mov r11, rdx
    lea r8, [rdx + 3]
runtime_extract_name_arrow_suffix_space:
    cmp r8, r9
    jae runtime_extract_failed
    mov al, [rsi + r8]
    cmp al, 32
    je runtime_extract_name_arrow_suffix_space_one
    cmp al, 9
    jne runtime_extract_name_arrow_suffix_check
runtime_extract_name_arrow_suffix_space_one:
    inc r8
    jmp runtime_extract_name_arrow_suffix_space
runtime_extract_name_arrow_suffix_check:
    lea r10, [r8 + 23]
    cmp r10, r9
    jne runtime_extract_failed
    lea rcx, [rsi + r8]
    mov edx, 23
    lea r8, [rel supported_name_pattern_arrow_suffix]
    call runtime_bytes_equal
    test eax, eax
    jz runtime_extract_failed
    test r11, r11
    jz runtime_extract_failed
    xor ecx, ecx
    xor r8d, r8d
runtime_extract_name_arrow_validate:
    cmp rcx, r11
    jae runtime_extract_name_arrow_validated
    mov al, [rsi + rcx]
    cmp al, 13
    je runtime_extract_failed
    cmp al, 10
    je runtime_extract_failed
    cmp al, 44
    je runtime_extract_failed
    cmp al, 40
    je runtime_extract_failed
    cmp al, 41
    je runtime_extract_failed
    cmp al, 0xe2
    jne runtime_extract_name_arrow_count
    lea r10, [rcx + 2]
    cmp r10, r11
    jae runtime_extract_failed
    cmp byte [rsi + rcx + 1], 0x86
    jne runtime_extract_name_arrow_count
    cmp byte [rsi + rcx + 2], 0x92
    je runtime_extract_failed
runtime_extract_name_arrow_count:
    cmp al, 0x80
    jb runtime_extract_name_arrow_count_one
    cmp al, 0xbf
    jbe runtime_extract_name_arrow_next_validate
runtime_extract_name_arrow_count_one:
    inc r8
    cmp r8, 100
    ja runtime_extract_failed
runtime_extract_name_arrow_next_validate:
    inc rcx
    jmp runtime_extract_name_arrow_validate
runtime_extract_name_arrow_validated:
    mov rdx, r11
runtime_extract_name_arrow_trim:
    test rdx, rdx
    jz runtime_extract_failed
    cmp byte [rsi + rdx - 1], 32
    je runtime_extract_name_arrow_trim_one
    cmp byte [rsi + rdx - 1], 9
    jne runtime_extract_name_arrow_copy
runtime_extract_name_arrow_trim_one:
    dec rdx
    jmp runtime_extract_name_arrow_trim
runtime_extract_name_arrow_copy:
    lea rdi, [rel parsed_name_buffer]
    xor ecx, ecx
runtime_extract_name_arrow_copy_loop:
    cmp rcx, rdx
    jae runtime_extract_name_arrow_done
    mov al, [rsi + rcx]
    mov [rdi + rcx], al
    inc ecx
    cmp ecx, 511
    jb runtime_extract_name_arrow_copy_loop
    jmp runtime_extract_failed
runtime_extract_name_arrow_title:
    lea rsi, [rel title_buffer]
    mov r9, [rel title_length]
    xor ecx, ecx
runtime_extract_name_arrow_title_scan:
    lea r10, [rcx + 2]
    cmp r10, r9
    jae runtime_extract_failed
    cmp byte [rsi + rcx], 0xe2
    jne runtime_extract_name_arrow_title_next
    cmp byte [rsi + rcx + 1], 0x86
    jne runtime_extract_name_arrow_title_next
    cmp byte [rsi + rcx + 2], 0x92
    je runtime_extract_name_arrow_found
runtime_extract_name_arrow_title_next:
    inc rcx
    jmp runtime_extract_name_arrow_title_scan
runtime_extract_name_arrow_done:
    mov byte [rdi + rcx], 0
    mov [rel parsed_name_length], rcx
    lea rcx, [rel parsed_name_buffer]
    mov rdx, [rel parsed_name_length]
    lea r8, [rel normalized_buffer]
    mov r9d, 1024
    lea rax, [rel normalized_length]
    mov [rsp + 0x20], rax
    call yul_normalize_name_utf8
    test eax, eax
    jnz runtime_extract_failed
    call runtime_apply_case_insensitive_latin
    ret

runtime_extract_push_amount:
    call runtime_validate_amount_candidates
    test eax, eax
    jne runtime_extract_failed
    xor eax, eax
    lea rcx, [rel filter_amount]
    lea rdx, [rel supported_amount_pattern_title]
    call runtime_cstring_equal
    test eax, eax
    jnz runtime_extract_amount_title
    mov rcx, body_label_amount
    mov edx, body_label_amount_end-body_label_amount
    lea r8, [rel body_buffer]
    mov r9, [rel body_length]
    call runtime_find_substring
    test rax, rax
    jnz runtime_extract_amount_body_found
    mov rcx, body_label_deposit_amount
    mov edx, body_label_deposit_amount_end-body_label_deposit_amount
    lea r8, [rel body_buffer]
    mov r9, [rel body_length]
    call runtime_find_substring
    test rax, rax
    jnz runtime_extract_amount_body_found
    mov rcx, body_label_deposit_amount2
    mov edx, body_label_deposit_amount2_end-body_label_deposit_amount2
    lea r8, [rel body_buffer]
    mov r9, [rel body_length]
    call runtime_find_substring
    test rax, rax
    jnz runtime_extract_amount_body_found
    mov rcx, body_label_amount_ascii
    mov edx, body_label_amount_ascii_end-body_label_amount_ascii
    lea r8, [rel body_buffer]
    mov r9, [rel body_length]
    call runtime_find_substring
    test rax, rax
    jz runtime_extract_failed
runtime_extract_amount_body_found:
    mov rsi, rax
runtime_extract_amount_skip:
    mov al, [rsi]
    cmp al, 58
    je runtime_extract_amount_skip_one
    cmp al, 32
    je runtime_extract_amount_skip_one
    cmp al, 9
    je runtime_extract_amount_skip_one
    cmp al, 10
    je runtime_extract_amount_skip_one
    cmp al, 13
    je runtime_extract_amount_skip_one
    cmp al, 0xef
    jne runtime_extract_amount_copy
    cmp byte [rsi + 1], 0xbc
    jne runtime_extract_amount_copy
    cmp byte [rsi + 2], 0x9a
    jne runtime_extract_amount_copy
    add rsi, 3
    jmp runtime_extract_amount_skip
runtime_extract_amount_skip_one:
    inc rsi
    jmp runtime_extract_amount_skip
runtime_extract_amount_copy:
    lea rdi, [rel amount_buffer]
    xor ecx, ecx
runtime_extract_amount_loop:
    mov al, [rsi]
    cmp al, 44
    je runtime_extract_amount_comma
    cmp al, 48
    jb runtime_extract_amount_done
    cmp al, 57
    ja runtime_extract_amount_done
    cmp ecx, 63
    jae runtime_extract_failed
    mov [rdi + rcx], al
    inc ecx
    inc rsi
    jmp runtime_extract_amount_loop
runtime_extract_amount_comma:
    test ecx, ecx
    jz runtime_extract_failed
    inc rsi
    jmp runtime_extract_amount_loop
runtime_extract_amount_done:
    test ecx, ecx
    jz runtime_extract_failed
    mov byte [rdi + rcx], 0
    mov [rel amount_length], rcx
    lea rcx, [rel amount_buffer]
    mov rdx, [rel amount_length]
    lea r8, [rel parsed_amount_value]
    call yul_parse_amount_ascii
    ret
runtime_extract_amount_title:
    lea rsi, [rel title_buffer]
    lea rdi, [rel amount_buffer]
    xor ecx, ecx
    xor r10d, r10d
runtime_extract_amount_title_loop:
    cmp r10, [rel title_length]
    jae runtime_extract_amount_title_done
    mov al, [rsi + r10]
    cmp al, 44
    je runtime_extract_amount_title_comma
    cmp al, 48
    jb runtime_extract_amount_title_done
    cmp al, 57
    ja runtime_extract_amount_title_done
    mov [rdi + rcx], al
    inc ecx
    cmp ecx, 63
    jb runtime_extract_amount_title_next
    jmp runtime_extract_failed
runtime_extract_amount_title_next:
    inc r10
    jmp runtime_extract_amount_title_loop
runtime_extract_amount_title_comma:
    test ecx, ecx
    jz runtime_extract_failed
    inc r10
    jmp runtime_extract_amount_title_loop
runtime_extract_amount_title_done:
    test ecx, ecx
    jz runtime_extract_failed
    mov byte [rdi + rcx], 0
    mov [rel amount_length], rcx
    lea rcx, [rel amount_buffer]
    mov rdx, [rel amount_length]
    lea r8, [rel parsed_amount_value]
    call yul_parse_amount_ascii
    ret
runtime_extract_failed:
    mov eax, 1
    ret

runtime_validate_name_candidates:
    cmp qword [rel filter_name_length], 57
    jne runtime_validate_name_candidates_body
    lea rcx, [rel filter_name]
    mov edx, 57
    lea r8, [rel supported_name_pattern_arrow]
    call runtime_bytes_equal
    test eax, eax
    jz runtime_validate_name_candidates_body
    call runtime_count_arrow_candidates
    cmp rax, 1
    je runtime_validate_name_candidates_good
    jmp runtime_validate_name_candidates_bad
runtime_validate_name_candidates_body:
    call runtime_count_name_candidates
    cmp rax, 1
    je runtime_validate_name_candidates_good
    jmp runtime_validate_name_candidates_bad
runtime_validate_name_candidates_bad:
    mov eax, 1
    ret
runtime_validate_name_candidates_good:
    xor eax, eax
    ret

runtime_validate_amount_candidates:
    cmp qword [rel filter_amount_length], 26
    jne runtime_validate_amount_candidates_body
    lea rcx, [rel filter_amount]
    mov edx, 26
    lea r8, [rel supported_amount_pattern_title]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_validate_amount_candidates_title
runtime_validate_amount_candidates_body:
    call runtime_count_amount_candidates
    cmp rax, 1
    je runtime_validate_amount_candidates_good
    jmp runtime_validate_amount_candidates_bad
runtime_validate_amount_candidates_title:
    call runtime_count_title_amount_candidates
    cmp rax, 1
    jne runtime_validate_amount_candidates_bad
runtime_validate_amount_candidates_good:
    xor eax, eax
    ret
runtime_validate_amount_candidates_bad:
    mov eax, 1
    ret

runtime_count_name_candidates:
    push r12
    lea rcx, [rel body_buffer]
    mov rdx, [rel body_length]
    call runtime_count_name_labels_text
    mov r12, rax
    cmp r12, 2
    jae runtime_count_name_candidates_two
    lea rcx, [rel title_buffer]
    mov rdx, [rel title_length]
    call runtime_count_name_labels_text
    add rax, r12
    cmp rax, 2
    jae runtime_count_name_candidates_two
    jmp runtime_count_name_candidates_return
runtime_count_name_candidates_two:
    mov eax, 2
runtime_count_name_candidates_return:
    pop r12
    ret

runtime_count_amount_candidates:
    push r12
    lea rcx, [rel body_buffer]
    mov rdx, [rel body_length]
    call runtime_count_amount_labels_text
    mov r12, rax
    cmp r12, 2
    jae runtime_count_amount_candidates_two
    lea rcx, [rel title_buffer]
    mov rdx, [rel title_length]
    call runtime_count_amount_labels_text
    add rax, r12
    cmp rax, 2
    jae runtime_count_amount_candidates_two
    jmp runtime_count_amount_candidates_return
runtime_count_amount_candidates_two:
    mov eax, 2
runtime_count_amount_candidates_return:
    pop r12
    ret

runtime_count_arrow_candidates:
    push r12
    lea rcx, [rel body_buffer]
    mov rdx, [rel body_length]
    call runtime_count_arrow_candidates_text
    mov r12, rax
    cmp r12, 2
    jae runtime_count_arrow_candidates_two
    lea rcx, [rel title_buffer]
    mov rdx, [rel title_length]
    call runtime_count_arrow_candidates_text
    add rax, r12
    cmp rax, 2
    jae runtime_count_arrow_candidates_two
    jmp runtime_count_arrow_candidates_return
runtime_count_arrow_candidates_two:
    mov eax, 2
runtime_count_arrow_candidates_return:
    pop r12
    ret

runtime_name_label_length:
    sub rsp, 18h
    mov [rsp], rcx
    mov [rsp + 8], rdx
    mov [rsp + 10h], r8
    test r8, r8
    jz runtime_name_label_length_boundary_ready
    mov rax, r8
    dec rax
    mov rcx, [rsp]
    movzx edx, byte [rcx + rax]
    cmp dl, 48
    jb runtime_name_label_length_boundary_ascii_upper
    cmp dl, 57
    jbe runtime_name_label_length_none
runtime_name_label_length_boundary_ascii_upper:
    cmp dl, 65
    jb runtime_name_label_length_boundary_underscore
    cmp dl, 90
    jbe runtime_name_label_length_none
runtime_name_label_length_boundary_underscore:
    cmp dl, 95
    je runtime_name_label_length_none
    cmp dl, 97
    jb runtime_name_label_length_boundary_ready
    cmp dl, 122
    jbe runtime_name_label_length_none
runtime_name_label_length_boundary_ready:
    cmp qword [rsp + 8], 13
    jb runtime_name_label_length_sender
    lea rcx, [rel body_label_sender_space]
    mov edx, 13
    mov r8, [rsp]
    add r8, [rsp + 10h]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_name_label_length_13
runtime_name_label_length_sender:
    cmp qword [rsp + 8], 9
    jb runtime_name_label_length_ascii_sender
    lea rcx, [rel body_label_name]
    mov edx, 9
    mov r8, [rsp]
    add r8, [rsp + 10h]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_name_label_length_9
    lea rcx, [rel body_label_sender]
    mov edx, 9
    mov r8, [rsp]
    add r8, [rsp + 10h]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_name_label_length_9
runtime_name_label_length_ascii_sender:
    cmp qword [rsp + 8], 6
    jb runtime_name_label_length_ascii_name
    lea rcx, [rel body_label_sender_ascii]
    mov edx, 6
    mov r8, [rsp]
    add r8, [rsp + 10h]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_name_label_length_6
runtime_name_label_length_ascii_name:
    cmp qword [rsp + 8], 4
    jb runtime_name_label_length_none
    lea rcx, [rel body_label_name_ascii]
    mov edx, 4
    mov r8, [rsp]
    add r8, [rsp + 10h]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_name_label_length_4
runtime_name_label_length_none:
    xor eax, eax
    add rsp, 18h
    ret
runtime_name_label_length_13:
    mov rcx, [rsp]
    mov rdx, [rsp + 8]
    mov r8, [rsp + 10h]
    mov r9d, 13
    call runtime_label_suffix_boundary
    test eax, eax
    jz runtime_name_label_length_none
    mov eax, 13
    add rsp, 18h
    ret
runtime_name_label_length_9:
    mov rcx, [rsp]
    mov rdx, [rsp + 8]
    mov r8, [rsp + 10h]
    mov r9d, 9
    call runtime_label_suffix_boundary
    test eax, eax
    jz runtime_name_label_length_none
    mov eax, 9
    add rsp, 18h
    ret
runtime_name_label_length_6:
    mov rcx, [rsp]
    mov rdx, [rsp + 8]
    mov r8, [rsp + 10h]
    mov r9d, 6
    call runtime_label_suffix_boundary
    test eax, eax
    jz runtime_name_label_length_none
    mov eax, 6
    add rsp, 18h
    ret
runtime_name_label_length_4:
    mov rcx, [rsp]
    mov rdx, [rsp + 8]
    mov r8, [rsp + 10h]
    mov r9d, 4
    call runtime_label_suffix_boundary
    test eax, eax
    jz runtime_name_label_length_none
    mov eax, 4
    add rsp, 18h
    ret

runtime_amount_label_length:
    sub rsp, 18h
    mov [rsp], rcx
    mov [rsp + 8], rdx
    mov [rsp + 10h], r8
    test r8, r8
    jz runtime_amount_label_length_boundary_ready
    mov rax, r8
    dec rax
    mov rcx, [rsp]
    movzx edx, byte [rcx + rax]
    cmp dl, 48
    jb runtime_amount_label_length_boundary_ascii_upper
    cmp dl, 57
    jbe runtime_amount_label_length_none
runtime_amount_label_length_boundary_ascii_upper:
    cmp dl, 65
    jb runtime_amount_label_length_boundary_underscore
    cmp dl, 90
    jbe runtime_amount_label_length_none
runtime_amount_label_length_boundary_underscore:
    cmp dl, 95
    je runtime_amount_label_length_none
    cmp dl, 97
    jb runtime_amount_label_length_boundary_ready
    cmp dl, 122
    jbe runtime_amount_label_length_none
runtime_amount_label_length_boundary_ready:
    cmp qword [rsp + 8], 12
    jb runtime_amount_label_length_9_check
    lea rcx, [rel body_label_deposit_amount2]
    mov edx, 12
    mov r8, [rsp]
    add r8, [rsp + 10h]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_amount_label_length_12
runtime_amount_label_length_9_check:
    cmp qword [rsp + 8], 9
    jb runtime_amount_label_length_6_check
    lea rcx, [rel body_label_deposit_amount]
    mov edx, 9
    mov r8, [rsp]
    add r8, [rsp + 10h]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_amount_label_length_9
runtime_amount_label_length_6_check:
    cmp qword [rsp + 8], 6
    jb runtime_amount_label_length_none
    lea rcx, [rel body_label_amount]
    mov edx, 6
    mov r8, [rsp]
    add r8, [rsp + 10h]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_amount_label_length_6
    lea rcx, [rel body_label_amount_ascii]
    mov edx, 6
    mov r8, [rsp]
    add r8, [rsp + 10h]
    call runtime_bytes_equal
    test eax, eax
    jnz runtime_amount_label_length_6
runtime_amount_label_length_none:
    xor eax, eax
    add rsp, 18h
    ret
runtime_amount_label_length_12:
    mov rcx, [rsp]
    mov rdx, [rsp + 8]
    mov r8, [rsp + 10h]
    mov r9d, 12
    call runtime_label_suffix_boundary
    test eax, eax
    jz runtime_amount_label_length_none
    mov eax, 12
    add rsp, 18h
    ret
runtime_amount_label_length_9:
    mov rcx, [rsp]
    mov rdx, [rsp + 8]
    mov r8, [rsp + 10h]
    mov r9d, 9
    call runtime_label_suffix_boundary
    test eax, eax
    jz runtime_amount_label_length_none
    mov eax, 9
    add rsp, 18h
    ret
runtime_amount_label_length_6:
    mov rcx, [rsp]
    mov rdx, [rsp + 8]
    mov r8, [rsp + 10h]
    mov r9d, 6
    call runtime_label_suffix_boundary
    test eax, eax
    jz runtime_amount_label_length_none
    mov eax, 6
    add rsp, 18h
    ret

runtime_label_suffix_boundary:
    lea rax, [r8 + r9]
    cmp rax, rdx
    jae runtime_label_suffix_boundary_yes
    mov al, [rcx + rax]
    cmp al, 48
    jb runtime_label_suffix_boundary_ascii_upper
    cmp al, 57
    jbe runtime_label_suffix_boundary_yes
runtime_label_suffix_boundary_ascii_upper:
    cmp al, 65
    jb runtime_label_suffix_boundary_underscore
    cmp al, 90
    jbe runtime_label_suffix_boundary_no
runtime_label_suffix_boundary_underscore:
    cmp al, 95
    je runtime_label_suffix_boundary_no
    cmp al, 97
    jb runtime_label_suffix_boundary_yes
    cmp al, 122
    jbe runtime_label_suffix_boundary_no
runtime_label_suffix_boundary_yes:
    mov eax, 1
    ret
runtime_label_suffix_boundary_no:
    xor eax, eax
    ret

runtime_count_name_labels_text:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    mov r12, rcx
    mov r13, rdx
    xor r14d, r14d
    xor r15d, r15d
runtime_count_name_labels_loop:
    cmp r14, r13
    jae runtime_count_name_labels_done
    mov rcx, r12
    mov rdx, r13
    mov r8, r14
    call runtime_name_label_length
    test rax, rax
    jz runtime_count_name_labels_next
    mov rsi, rax
    lea rdi, [r14 + rsi]
runtime_count_name_labels_skip:
    cmp rdi, r13
    jae runtime_count_name_labels_invalid
    mov al, [r12 + rdi]
    cmp al, 58
    je runtime_count_name_labels_skip_one
    cmp al, 32
    je runtime_count_name_labels_skip_one
    cmp al, 9
    je runtime_count_name_labels_skip_one
    cmp al, 0xef
    jne runtime_count_name_labels_value
    lea rbx, [rdi + 3]
    cmp rbx, r13
    ja runtime_count_name_labels_invalid
    cmp byte [r12 + rdi + 1], 0xbc
    jne runtime_count_name_labels_value
    cmp byte [r12 + rdi + 2], 0x9a
    jne runtime_count_name_labels_value
    add rdi, 3
    jmp runtime_count_name_labels_skip
runtime_count_name_labels_skip_one:
    inc rdi
    jmp runtime_count_name_labels_skip
runtime_count_name_labels_value:
    cmp rdi, r13
    jae runtime_count_name_labels_invalid
    mov al, [r12 + rdi]
    test al, al
    jz runtime_count_name_labels_invalid
    cmp al, 10
    je runtime_count_name_labels_invalid
    cmp al, 13
    je runtime_count_name_labels_invalid
    cmp al, 44
    je runtime_count_name_labels_invalid
    cmp al, 40
    je runtime_count_name_labels_invalid
    cmp al, 41
    je runtime_count_name_labels_invalid
    mov rbx, rdi
runtime_count_name_labels_end:
    cmp rbx, r13
    jae runtime_count_name_labels_valid
    mov al, [r12 + rbx]
    test al, al
    jz runtime_count_name_labels_invalid
    cmp al, 10
    je runtime_count_name_labels_valid
    cmp al, 13
    je runtime_count_name_labels_valid
    cmp al, 44
    je runtime_count_name_labels_valid
    cmp al, 40
    je runtime_count_name_labels_valid
    cmp al, 41
    je runtime_count_name_labels_valid
    inc rbx
    jmp runtime_count_name_labels_end
runtime_count_name_labels_valid:
    inc r15
    cmp r15, 2
    jae runtime_count_name_labels_two
    cmp rbx, r13
    jae runtime_count_name_labels_done
    lea r14, [rbx + 1]
    jmp runtime_count_name_labels_loop
runtime_count_name_labels_next:
    inc r14
    jmp runtime_count_name_labels_loop
runtime_count_name_labels_two:
    mov eax, 2
    jmp runtime_count_name_labels_return
runtime_count_name_labels_invalid:
    mov eax, 2
    jmp runtime_count_name_labels_return
runtime_count_name_labels_done:
    mov rax, r15
runtime_count_name_labels_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

runtime_count_amount_labels_text:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    mov r12, rcx
    mov r13, rdx
    xor r14d, r14d
    xor r15d, r15d
runtime_count_amount_labels_loop:
    cmp r14, r13
    jae runtime_count_amount_labels_done
    mov rcx, r12
    mov rdx, r13
    mov r8, r14
    call runtime_amount_label_length
    test rax, rax
    jz runtime_count_amount_labels_next
    mov rsi, rax
    lea rdi, [r14 + rsi]
runtime_count_amount_labels_skip:
    cmp rdi, r13
    jae runtime_count_amount_labels_invalid
    mov al, [r12 + rdi]
    cmp al, 58
    je runtime_count_amount_labels_skip_one
    cmp al, 32
    je runtime_count_amount_labels_skip_one
    cmp al, 9
    je runtime_count_amount_labels_skip_one
    cmp al, 10
    je runtime_count_amount_labels_skip_one
    cmp al, 13
    je runtime_count_amount_labels_skip_one
    cmp al, 0xef
    jne runtime_count_amount_labels_value
    lea rbx, [rdi + 3]
    cmp rbx, r13
    ja runtime_count_amount_labels_invalid
    cmp byte [r12 + rdi + 1], 0xbc
    jne runtime_count_amount_labels_value
    cmp byte [r12 + rdi + 2], 0x9a
    jne runtime_count_amount_labels_value
    add rdi, 3
    jmp runtime_count_amount_labels_skip
runtime_count_amount_labels_skip_one:
    inc rdi
    jmp runtime_count_amount_labels_skip
runtime_count_amount_labels_value:
    cmp rdi, r13
    jae runtime_count_amount_labels_invalid
    mov al, [r12 + rdi]
    cmp al, 48
    jb runtime_count_amount_labels_invalid
    cmp al, 57
    ja runtime_count_amount_labels_invalid
    mov rbx, rdi
runtime_count_amount_labels_digits:
    cmp rbx, r13
    jae runtime_count_amount_labels_valid
    mov al, [r12 + rbx]
    cmp al, 48
    jb runtime_count_amount_labels_digits_done
    cmp al, 57
    ja runtime_count_amount_labels_digits_comma
    inc rbx
    jmp runtime_count_amount_labels_digits
runtime_count_amount_labels_digits_comma:
    cmp al, 44
    jne runtime_count_amount_labels_valid
    inc rbx
    jmp runtime_count_amount_labels_digits
runtime_count_amount_labels_digits_done:
runtime_count_amount_labels_valid:
    inc r15
    cmp r15, 2
    jae runtime_count_amount_labels_two
    cmp rbx, r13
    jae runtime_count_amount_labels_done
    lea r14, [rbx + 1]
    jmp runtime_count_amount_labels_loop
runtime_count_amount_labels_next:
    inc r14
    jmp runtime_count_amount_labels_loop
runtime_count_amount_labels_two:
    mov eax, 2
    jmp runtime_count_amount_labels_return
runtime_count_amount_labels_invalid:
    mov eax, 2
    jmp runtime_count_amount_labels_return
runtime_count_amount_labels_done:
    mov rax, r15
runtime_count_amount_labels_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

runtime_count_arrow_candidates_text:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12, rcx
    mov r13, rdx
    xor r14d, r14d
    xor r15d, r15d
runtime_count_arrow_candidates_text_loop:
    lea rbx, [r14 + 3]
    cmp rbx, r13
    ja runtime_count_arrow_candidates_text_done
    cmp byte [r12 + r14], 0xe2
    jne runtime_count_arrow_candidates_text_next
    cmp byte [r12 + r14 + 1], 0x86
    jne runtime_count_arrow_candidates_text_next
    cmp byte [r12 + r14 + 2], 0x92
    jne runtime_count_arrow_candidates_text_next
    inc r15
    cmp r15, 2
    jae runtime_count_arrow_candidates_text_two
runtime_count_arrow_candidates_text_next:
    inc r14
    jmp runtime_count_arrow_candidates_text_loop
runtime_count_arrow_candidates_text_two:
    mov eax, 2
    jmp runtime_count_arrow_candidates_text_return
runtime_count_arrow_candidates_text_done:
    mov rax, r15
runtime_count_arrow_candidates_text_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

runtime_count_title_amount_candidates:
    push r12
    lea rcx, [rel body_buffer]
    mov rdx, [rel body_length]
    call runtime_count_title_amount_text
    mov r12, rax
    cmp r12, 2
    jae runtime_count_title_amount_candidates_two
    lea rcx, [rel title_buffer]
    mov rdx, [rel title_length]
    call runtime_count_title_amount_text
    add rax, r12
    cmp rax, 2
    jae runtime_count_title_amount_candidates_two
    jmp runtime_count_title_amount_candidates_return
runtime_count_title_amount_candidates_two:
    mov eax, 2
runtime_count_title_amount_candidates_return:
    pop r12
    ret

runtime_count_title_amount_text:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12, rcx
    mov r13, rdx
    xor r14d, r14d
    xor r15d, r15d
runtime_count_title_amount_text_loop:
    cmp r14, r13
    jae runtime_count_title_amount_text_done
    mov al, [r12 + r14]
    cmp al, 48
    jb runtime_count_title_amount_text_next
    cmp al, 57
    ja runtime_count_title_amount_text_next
    mov rbx, r14
runtime_count_title_amount_text_digits:
    cmp rbx, r13
    jae runtime_count_title_amount_text_next
    mov al, [r12 + rbx]
    cmp al, 44
    je runtime_count_title_amount_text_digits_comma
    cmp al, 48
    jb runtime_count_title_amount_text_digits_done
    cmp al, 57
    ja runtime_count_title_amount_text_digits_done
    inc rbx
    jmp runtime_count_title_amount_text_digits
runtime_count_title_amount_text_digits_comma:
    inc rbx
    jmp runtime_count_title_amount_text_digits
runtime_count_title_amount_text_digits_done:
    lea rax, [rbx + 3]
    cmp rax, r13
    ja runtime_count_title_amount_text_next
    cmp byte [r12 + rbx], 0xec
    jne runtime_count_title_amount_text_next
    cmp byte [r12 + rbx + 1], 0x9b
    jne runtime_count_title_amount_text_next
    cmp byte [r12 + rbx + 2], 0x90
    jne runtime_count_title_amount_text_next
    add rbx, 3
runtime_count_title_amount_text_space:
    cmp rbx, r13
    jae runtime_count_title_amount_text_next
    mov al, [r12 + rbx]
    cmp al, 32
    je runtime_count_title_amount_text_space_one
    cmp al, 9
    je runtime_count_title_amount_text_space_one
    cmp al, 10
    je runtime_count_title_amount_text_space_one
    cmp al, 13
    jne runtime_count_title_amount_text_deposit
runtime_count_title_amount_text_space_one:
    inc rbx
    jmp runtime_count_title_amount_text_space
runtime_count_title_amount_text_deposit:
    lea rax, [rbx + 6]
    cmp rax, r13
    ja runtime_count_title_amount_text_next
    cmp byte [r12 + rbx], 0xec
    jne runtime_count_title_amount_text_next
    cmp byte [r12 + rbx + 1], 0x9e
    jne runtime_count_title_amount_text_next
    cmp byte [r12 + rbx + 2], 0x85
    jne runtime_count_title_amount_text_next
    cmp byte [r12 + rbx + 3], 0xea
    jne runtime_count_title_amount_text_next
    cmp byte [r12 + rbx + 4], 0xb8
    jne runtime_count_title_amount_text_next
    cmp byte [r12 + rbx + 5], 0x88
    jne runtime_count_title_amount_text_next
    inc r15
    cmp r15, 2
    jae runtime_count_title_amount_text_two
    lea r14, [rbx + 6]
    jmp runtime_count_title_amount_text_loop
runtime_count_title_amount_text_next:
    inc r14
    jmp runtime_count_title_amount_text_loop
runtime_count_title_amount_text_two:
    mov eax, 2
    jmp runtime_count_title_amount_text_return
runtime_count_title_amount_text_done:
    mov rax, r15
runtime_count_title_amount_text_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

runtime_find_substring:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    mov r12, rcx
    mov r13, rdx
    mov r14, r8
    xor ebx, ebx
runtime_find_substring_loop:
    cmp rbx, r9
    jae runtime_find_substring_missing
    cmp r9, r13
    jb runtime_find_substring_missing
    mov rax, r9
    sub rax, r13
    cmp rbx, rax
    ja runtime_find_substring_missing
    lea rsi, [r14 + rbx]
    mov rdi, r12
    mov rcx, r13
    repe cmpsb
    je runtime_find_substring_found
    inc rbx
    jmp runtime_find_substring_loop
runtime_find_substring_found:
    lea rax, [r14 + rbx]
    add rax, r13
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret
runtime_find_substring_missing:
    xor eax, eax
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

runtime_print_duplicate:
    sub rsp, 0x28
    lea rdx, [rel result_duplicate_prefix]
    mov r8d, result_duplicate_prefix_end-result_duplicate_prefix
    call runtime_write
    lea rdx, [rel push_id_buffer]
    mov r8, [rel push_id_length]
    call runtime_write
    lea rdx, [rel result_suffix]
    mov r8d, result_suffix_end-result_suffix
    call runtime_write
    add rsp, 0x28
    ret

runtime_print_review:
    sub rsp, 0x28
    lea rdx, [rel result_review_prefix]
    mov r8d, result_review_prefix_end-result_review_prefix
    call runtime_write
    lea rdx, [rel push_id_buffer]
    mov r8, [rel push_id_length]
    call runtime_write
    lea rdx, [rel result_suffix]
    mov r8d, result_suffix_end-result_suffix
    call runtime_write
    add rsp, 0x28
    ret

runtime_print_consumed:
    sub rsp, 0x28
    lea rdx, [rel result_consumed_prefix]
    mov r8d, result_consumed_prefix_end-result_consumed_prefix
    call runtime_write
    lea rdx, [rel push_id_buffer]
    mov r8, [rel push_id_length]
    call runtime_write
    lea rdx, [rel result_order_prefix]
    mov r8d, result_order_prefix_end-result_order_prefix
    call runtime_write
    lea rdx, [rel credit_order_id]
    mov r8, [rel credit_order_id_length]
    call runtime_write
    lea rdx, [rel result_suffix]
    mov r8d, result_suffix_end-result_suffix
    call runtime_write
    add rsp, 0x28
    ret

runtime_print_parse_failed:
    sub rsp, 0x28
    lea rdx, [rel result_parse_prefix]
    mov r8d, result_parse_prefix_end-result_parse_prefix
    call runtime_write
    add rsp, 0x28
    ret

runtime_print_unsupported:
    sub rsp, 0x28
    lea rdx, [rel result_unsupported]
    mov r8d, result_unsupported_end-result_unsupported
    call runtime_write
    add rsp, 0x28
    ret

runtime_review_list:
    sub rsp, 0x28
    call runtime_db_open
    test eax, eax
    jnz runtime_review_list_fail
    mov dword [rel list_first], 1
    lea rdx, [rel list_start]
    mov r8d, list_start_end-list_start
    call runtime_write
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_review]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_review_list_close
runtime_review_list_loop:
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 100
    jne runtime_review_list_done
    cmp dword [rel list_first], 0
    je runtime_review_list_separator
    mov dword [rel list_first], 0
    jmp runtime_review_list_row
runtime_review_list_separator:
    lea rdx, [rel list_separator]
    mov r8d, list_separator_end-list_separator
    call runtime_write
runtime_review_list_row:
    lea rdx, [rel json_push_prefix]
    mov r8d, json_push_prefix_end-json_push_prefix
    call runtime_write
    mov rcx, [rel statement_handle]
    xor edx, edx
    call yul_sqlite_column_text
    mov rcx, rax
    lea rdx, [rel line_buffer]
    mov r8d, 1024
    call runtime_copy_cstring
    lea rdx, [rel line_buffer]
    mov r8, rax
    call runtime_write
    lea rdx, [rel json_status_prefix]
    mov r8d, json_status_prefix_end-json_status_prefix
    call runtime_write
    mov rcx, [rel statement_handle]
    mov edx, 1
    call yul_sqlite_column_text
    mov rcx, rax
    lea rdx, [rel line_buffer]
    mov r8d, 1024
    call runtime_copy_cstring
    lea rdx, [rel line_buffer]
    mov r8, rax
    call runtime_write
    lea rdx, [rel json_name_prefix]
    mov r8d, json_name_prefix_end-json_name_prefix
    call runtime_write
    mov rcx, [rel statement_handle]
    mov edx, 2
    call yul_sqlite_column_text
    test rax, rax
    jz runtime_review_list_name_null
    mov rcx, rax
    lea rdx, [rel line_buffer]
    mov r8d, 1024
    call runtime_copy_cstring
    mov r12, rax
    lea rdx, [rel json_quote]
    mov r8d, json_quote_end-json_quote
    call runtime_write
    lea rdx, [rel line_buffer]
    mov r8, r12
    call runtime_write
    lea rdx, [rel json_quote]
    mov r8d, json_quote_end-json_quote
    call runtime_write
    jmp runtime_review_list_amount
runtime_review_list_name_null:
    lea rdx, [rel json_null]
    mov r8d, json_null_end-json_null
    call runtime_write
runtime_review_list_amount:
    lea rdx, [rel json_amount_prefix]
    mov r8d, json_amount_prefix_end-json_amount_prefix
    call runtime_write
    mov rcx, [rel statement_handle]
    mov edx, 3
    call yul_sqlite_column_int64
    mov rdx, decimal_buffer
    mov r8d, 64
    call runtime_u64_decimal
    mov r8, rax
    mov rdx, decimal_buffer
    call runtime_write
    lea rdx, [rel json_received_prefix]
    mov r8d, json_received_prefix_end-json_received_prefix
    call runtime_write
    mov rcx, [rel statement_handle]
    mov edx, 4
    call yul_sqlite_column_int64
    mov rdx, decimal_buffer
    mov r8d, 64
    call runtime_u64_decimal
    mov r8, rax
    mov rdx, decimal_buffer
    call runtime_write
    lea rdx, [rel json_object_suffix]
    mov r8d, json_object_suffix_end-json_object_suffix
    call runtime_write
    jmp runtime_review_list_loop
runtime_review_list_done:
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
runtime_review_list_close:
    call runtime_db_close
    lea rdx, [rel list_end]
    mov r8d, list_end_end-list_end
    call runtime_write
    xor eax, eax
    add rsp, 0x28
    ret
runtime_review_list_fail:
    lea rdx, [rel list_end]
    mov r8d, list_end_end-list_end
    call runtime_write
    mov eax, 1
    add rsp, 0x28
    ret

runtime_ledger_list:
    sub rsp, 0x28
    call runtime_db_open
    test eax, eax
    jnz runtime_ledger_list_fail
    mov dword [rel list_first], 1
    lea rdx, [rel list_start]
    mov r8d, list_start_end-list_start
    call runtime_write
    mov rcx, [rel db_handle]
    lea rdx, [rel sql_ledger]
    lea r8, [rel statement_handle]
    call yul_sqlite_prepare
    test eax, eax
    jnz runtime_ledger_list_close
runtime_ledger_list_loop:
    mov rcx, [rel statement_handle]
    call yul_sqlite_step
    cmp eax, 100
    jne runtime_ledger_list_done
    cmp dword [rel list_first], 0
    je runtime_ledger_list_separator
    mov dword [rel list_first], 0
    jmp runtime_ledger_list_row
runtime_ledger_list_separator:
    lea rdx, [rel list_separator]
    mov r8d, list_separator_end-list_separator
    call runtime_write
runtime_ledger_list_row:
    lea rdx, [rel json_order_prefix]
    mov r8d, json_order_prefix_end-json_order_prefix
    call runtime_write
    mov rcx, [rel statement_handle]
    xor edx, edx
    call yul_sqlite_column_int64
    mov rdx, decimal_buffer
    mov r8d, 64
    call runtime_u64_decimal
    mov r8, rax
    mov rdx, decimal_buffer
    call runtime_write
    lea rdx, [rel json_order_id_prefix]
    mov r8d, json_order_id_prefix_end-json_order_id_prefix
    call runtime_write
    mov rcx, [rel statement_handle]
    mov edx, 1
    call yul_sqlite_column_text
    mov rcx, rax
    lea rdx, [rel line_buffer]
    mov r8d, 1024
    call runtime_copy_cstring
    mov r12, rax
    lea rdx, [rel line_buffer]
    mov r8, r12
    call runtime_write
    lea rdx, [rel json_discord_prefix]
    mov r8d, json_discord_prefix_end-json_discord_prefix
    call runtime_write
    mov rcx, [rel statement_handle]
    mov edx, 2
    call yul_sqlite_column_text
    mov rcx, rax
    lea rdx, [rel line_buffer]
    mov r8d, 1024
    call runtime_copy_cstring
    mov r12, rax
    lea rdx, [rel line_buffer]
    mov r8, r12
    call runtime_write
    lea rdx, [rel json_quote]
    mov r8d, json_quote_end-json_quote
    call runtime_write
    lea rdx, [rel json_ledger_amount_prefix]
    mov r8d, json_ledger_amount_prefix_end-json_ledger_amount_prefix
    call runtime_write
    mov rcx, [rel statement_handle]
    mov edx, 3
    call yul_sqlite_column_int64
    mov rdx, decimal_buffer
    mov r8d, 64
    call runtime_u64_decimal
    mov r8, rax
    mov rdx, decimal_buffer
    call runtime_write
    lea rdx, [rel json_reason_prefix]
    mov r8d, json_reason_prefix_end-json_reason_prefix
    call runtime_write
    mov rcx, [rel statement_handle]
    mov edx, 4
    call yul_sqlite_column_text
    mov rcx, rax
    lea rdx, [rel line_buffer]
    mov r8d, 1024
    call runtime_copy_cstring
    mov r12, rax
    lea rdx, [rel line_buffer]
    mov r8, r12
    call runtime_write
    lea rdx, [rel json_quote]
    mov r8d, json_quote_end-json_quote
    call runtime_write
    lea rdx, [rel json_created_prefix]
    mov r8d, json_created_prefix_end-json_created_prefix
    call runtime_write
    mov rcx, [rel statement_handle]
    mov edx, 5
    call yul_sqlite_column_int64
    mov rdx, decimal_buffer
    mov r8d, 64
    call runtime_u64_decimal
    mov r8, rax
    mov rdx, decimal_buffer
    call runtime_write
    lea rdx, [rel json_object_suffix]
    mov r8d, json_object_suffix_end-json_object_suffix
    call runtime_write
    jmp runtime_ledger_list_loop
runtime_ledger_list_done:
    mov rcx, [rel statement_handle]
    call yul_sqlite_finalize
runtime_ledger_list_close:
    call runtime_db_close
    lea rdx, [rel list_end]
    mov r8d, list_end_end-list_end
    call runtime_write
    xor eax, eax
    add rsp, 0x28
    ret
runtime_ledger_list_fail:
    lea rdx, [rel list_end]
    mov r8d, list_end_end-list_end
    call runtime_write
    mov eax, 1
    add rsp, 0x28
    ret

runtime_make_order_id:
    mov rax, [rel created_at]
    add rax, [rel order_counter]
    inc qword [rel order_counter]
    mov r12, rax
    call yul_platform_process_id
    shl rax, 32
    add rax, r12
    lea rdi, [rel order_id_buffer]
    lea rsi, [rel order_prefix]
    mov ecx, order_prefix_end-order_prefix
    rep movsb
    lea rdi, [rel order_id_buffer + order_prefix_end-order_prefix]
    lea rsi, [rel hex_digits]
    mov rdx, rax
    mov ecx, 16
runtime_make_order_hex:
    mov r8, rdx
    and r8d, 15
    mov r8b, [rsi + r8]
    mov [rdi + rcx - 1], r8b
    shr rdx, 4
    loop runtime_make_order_hex
    mov byte [rel order_id_buffer + order_prefix_end-order_prefix + 16], 0
    ret

runtime_u64_decimal:
    mov r11, rdx
    lea r9, [rel decimal_tmp + 64]
    xor ecx, ecx
    test rax, rax
    jnz runtime_u64_decimal_loop
    dec r9
    mov byte [r9], 48
    mov ecx, 1
    jmp runtime_u64_decimal_copy
runtime_u64_decimal_loop:
    xor edx, edx
    mov r10d, 10
    div r10
    add dl, 48
    dec r9
    mov [r9], dl
    inc ecx
    test rax, rax
    jnz runtime_u64_decimal_loop
runtime_u64_decimal_copy:
    mov rsi, r9
    mov rdi, r11
    mov rdx, r8
    cmp rcx, rdx
    jae runtime_u64_decimal_zero
    mov rax, rcx
    rep movsb
    ret
runtime_u64_decimal_zero:
    xor eax, eax
    ret

runtime_run:
    sub rsp, 0x28
    call yul_native_service_run
    add rsp, 0x28
    ret

runtime_write:
    sub rsp, 0x28
    cmp dword [rel service_mode], 0
    jne runtime_write_service
    mov rsi, rdx
    mov rdi, r8
    mov ecx, -11
    call GetStdHandle
    mov rcx, rax
    mov rdx, rsi
    mov r8, rdi
    lea r9, [rel write_count]
    mov qword [rsp + 0x20], 0
    call WriteFile
    add rsp, 0x28
    ret
runtime_write_service:
    mov rsi, rdx
    mov rdi, r8
    mov rax, [rel service_message_length]
    add rax, rdi
    cmp rax, 16383
    ja runtime_write_service_done
    lea r10, [rel service_message]
    add r10, [rel service_message_length]
    mov r8, rdi
    mov rcx, r8
    mov rdi, r10
    rep movsb
    add [rel service_message_length], r8
runtime_write_service_done:
    add rsp, 0x28
    xor eax, eax
    ret

runtime_read_file:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 0x40
    mov rsi, rdx
    mov r14, r8
    mov r15, r9
    mov rbx, rcx
    mov rcx, rbx
    mov edx, 0x80000000
    mov r8d, 1
    xor r9d, r9d
    mov dword [rsp + 0x20], 3
    mov dword [rsp + 0x28], 0x80
    mov qword [rsp + 0x30], 0
    call CreateFileA
    cmp rax, -1
    je runtime_read_file_fail_stack
    mov r12, rax
    mov rcx, r12
    xor edx, edx
    call GetFileSize
    cmp eax, r14d
    jae runtime_read_file_close_fail
    mov rcx, r12
    mov rdx, rsi
    mov r8d, eax
    lea r9, [rel read_count]
    mov qword [rsp + 0x20], 0
    call ReadFile
    test eax, eax
    jz runtime_read_file_close_fail
    mov rax, [rel read_count]
    mov [r15], rax
    mov byte [rsi + rax], 0
    mov rcx, r12
    call CloseHandle
    add rsp, 0x40
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    xor eax, eax
    ret
runtime_read_file_close_fail:
    mov rcx, r12
    call CloseHandle
runtime_read_file_fail_stack:
    add rsp, 0x40
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    mov eax, 1
    ret

section .data

command_init_db db "init-db"
command_init_db_end:
command_panel_text db "panel-text"
command_panel_text_end:
command_support_total db "support-total"
command_support_total_end:
command_create_order db "create-order"
command_create_order_end:
command_process_push db "process-push"
command_process_push_end:
command_review_list db "review-list"
command_review_list_end:
command_ledger db "ledger"
command_ledger_end:
command_run db "run"
command_run_end:
command_validate_config db "validate-config"
command_validate_config_end:
config_option db "--config"
config_option_end:
default_db_path db "vending.db"
default_db_path_end:
default_config_path db ".local-vending.ini"
default_config_path_end:
config_key_database db "DATABASE_PATH"
config_key_database_end:
config_key_ttl db "ORDER_TTL_SECONDS"
config_key_ttl_end:
config_key_auto db "AUTO_CREDIT"
config_key_auto_end:
config_key_case db "CASE_INSENSITIVE_LATIN"
config_key_case_end:
config_key_package db "BANK_PACKAGE_NAME"
config_key_package_end:
config_key_application db "BANK_APPLICATION_NAME"
config_key_application_end:
config_key_title_prefix db "BANK_TITLE_PREFIX"
config_key_title_prefix_end:
config_key_title_pattern db "BANK_TITLE_PATTERN"
config_key_title_pattern_end:
config_key_amount_pattern db "BANK_AMOUNT_PATTERN"
config_key_amount_pattern_end:
config_key_name_pattern db "BANK_NAME_PATTERN"
config_key_name_pattern_end:
supported_title_pattern db "^[0-9][0-9,]*원\s*입금$", 0
supported_amount_pattern_title db "([0-9][0-9,]*)원\s*입금", 0
supported_amount_pattern_body db "(?:입금액|입금금액|금액|amount)\s*[:：]?\s*([0-9][0-9,]*)", 0
supported_name_pattern_arrow db "^([^\r\n→,()]{1,100}?)\s*→\s*내 토스뱅크 통장$", 0
supported_name_pattern_arrow_suffix db "내 토스뱅크 통장", 0
supported_name_pattern_body db "(?:입금자|보낸분|보낸 사람|sender|name)\s*[:：]?\s*([^\r\n,()]{1,100})", 0
endpoint_gateway_exact db "gateway.discord.gg", 0
endpoint_gateway_suffix_gg db ".discord.gg", 0
endpoint_gateway_suffix_com db ".discord.com", 0
endpoint_push_exact db "stream.pushbullet.com", 0
endpoint_push_path db "/websocket", 0
endpoint_query_v db "v", 0
endpoint_query_encoding db "encoding", 0
config_key_discord_token db "DISCORD_BOT_TOKEN"
config_key_discord_token_end:
config_key_gateway db "DISCORD_GATEWAY_URL"
config_key_gateway_end:
config_key_pushbullet_token db "PUSHBULLET_ACCESS_TOKEN"
config_key_pushbullet_token_end:
config_key_application_id db "DISCORD_APPLICATION_ID"
config_key_application_id_end:
config_key_guild_id db "DISCORD_GUILD_ID"
config_key_guild_id_end:
config_key_panel_id db "DISCORD_PANEL_CHANNEL_ID"
config_key_panel_id_end:
config_key_admin_id db "DISCORD_ADMIN_USER_ID"
config_key_admin_id_end:
config_key_intents db "DISCORD_INTENTS"
config_key_intents_end:
config_key_stream db "PUSHBULLET_STREAM_URL"
config_key_stream_end:
config_key_bank_name db "BANK_NAME"
config_key_bank_name_end:
config_key_bank_account db "BANK_ACCOUNT_NUMBER"
config_key_bank_account_end:
config_key_bank_holder db "BANK_ACCOUNT_HOLDER"
config_key_bank_holder_end:
config_key_min db "MIN_AMOUNT_KRW"
config_key_min_end:
config_key_max db "MAX_AMOUNT_KRW"
config_key_max_end:
align 8
runtime_config_key_table:
    dq config_key_database
    dq config_key_database_end-config_key_database
    dq config_key_ttl
    dq config_key_ttl_end-config_key_ttl
    dq config_key_auto
    dq config_key_auto_end-config_key_auto
    dq config_key_case
    dq config_key_case_end-config_key_case
    dq config_key_package
    dq config_key_package_end-config_key_package
    dq config_key_application
    dq config_key_application_end-config_key_application
    dq config_key_title_prefix
    dq config_key_title_prefix_end-config_key_title_prefix
    dq config_key_title_pattern
    dq config_key_title_pattern_end-config_key_title_pattern
    dq config_key_amount_pattern
    dq config_key_amount_pattern_end-config_key_amount_pattern
    dq config_key_name_pattern
    dq config_key_name_pattern_end-config_key_name_pattern
    dq config_key_min
    dq config_key_min_end-config_key_min
    dq config_key_max
    dq config_key_max_end-config_key_max
    dq config_key_discord_token
    dq config_key_discord_token_end-config_key_discord_token
    dq config_key_gateway
    dq config_key_gateway_end-config_key_gateway
    dq config_key_pushbullet_token
    dq config_key_pushbullet_token_end-config_key_pushbullet_token
    dq config_key_application_id
    dq config_key_application_id_end-config_key_application_id
    dq config_key_guild_id
    dq config_key_guild_id_end-config_key_guild_id
    dq config_key_panel_id
    dq config_key_panel_id_end-config_key_panel_id
    dq config_key_admin_id
    dq config_key_admin_id_end-config_key_admin_id
    dq config_key_intents
    dq config_key_intents_end-config_key_intents
    dq config_key_stream
    dq config_key_stream_end-config_key_stream
    dq config_key_bank_name
    dq config_key_bank_name_end-config_key_bank_name
    dq config_key_bank_account
    dq config_key_bank_account_end-config_key_bank_account
    dq config_key_bank_holder
    dq config_key_bank_holder_end-config_key_bank_holder
bool_true_1 db "1", 0
bool_false_0 db "0", 0
bool_true_lower db "true", 0
bool_true_upper db "TRUE", 0
bool_false_lower db "false", 0
bool_false_upper db "FALSE", 0
bool_yes_lower db "yes", 0
bool_yes_upper db "YES", 0
bool_no_lower db "no", 0
bool_no_upper db "NO", 0
order_prefix db "native-"
order_prefix_end:
hex_digits db "0123456789abcdef"
status_pending db "PENDING"
status_pending_end:
status_received db "RECEIVED"
status_received_end:
status_review db "REVIEW"
status_review_end:
status_consumed db "CONSUMED"
status_consumed_end:
status_parse_failed db "PARSE_FAILED"
status_parse_failed_end:
status_unsupported db "UNSUPPORTED"
status_unsupported_end:
status_match_not_found db "MATCH_NOT_FOUND"
status_match_not_found_end:
status_match_ambiguous db "MATCH_AMBIGUOUS"
status_match_ambiguous_end:
status_expired db "EXPIRED"
status_expired_end:
newline db 10
order_created_text db "order-created: "
order_created_text_end:
panel_text db "입금 후원 패널", 10, "입금자명은 신청할 때 입력한 값과 같아야 합니다.", 10, "금액 범위: 설정값", 10, "입금 알림 반영까지 시간이 걸릴 수 있습니다.", 10, "같은 이름과 금액의 주문이 여러 개면 자동 지급되지 않습니다.", 10
panel_text_end:
usage_text db "native commands: init-db | panel-text | create-order <discord-id> <name> <amount> | process-push <json> | support-total <discord-id> | review-list | ledger | validate-config | run", 10
usage_text_end:
config_valid_text db "native config valid", 10
config_valid_text_end:
config_invalid_text db "native config invalid", 10
config_invalid_text_end:
native_run_text db "native HTTPS adapters completed configured endpoint checks", 10
native_run_text_end:
native_network_unavailable_text db "native network runtime is unavailable", 10
native_network_unavailable_text_end:
result_duplicate_prefix db '{"status":"DUPLICATE","push_id":"'
result_duplicate_prefix_end:
result_review_prefix db '{"status":"REVIEW","push_id":"'
result_review_prefix_end:
result_consumed_prefix db '{"status":"CONSUMED","push_id":"'
result_consumed_prefix_end:
result_order_prefix db '","order_id":"'
result_order_prefix_end:
result_parse_prefix db '{"status":"PARSE_FAILED"}', 10
result_parse_prefix_end:
result_unsupported db '{"status":"UNSUPPORTED"}', 10
result_unsupported_end:
result_suffix db '"}', 10
result_suffix_end:
list_start db '['
list_start_end:
list_separator db ','
list_separator_end:
list_end db ']', 10
list_end_end:
json_push_prefix db '{"push_id":"'
json_push_prefix_end:
json_status_prefix db '","status":"'
json_status_prefix_end:
json_name_prefix db '","parsed_depositor_name":'
json_name_prefix_end:
json_amount_prefix db ',"parsed_amount_krw":'
json_amount_prefix_end:
json_received_prefix db ',"received_at":'
json_received_prefix_end:
json_order_prefix db '{"ledger_id":'
json_order_prefix_end:
json_order_id_prefix db ',"order_id":"'
json_order_id_prefix_end:
json_discord_prefix db '","discord_id":"'
json_discord_prefix_end:
json_reason_prefix db ',"reason":"'
json_reason_prefix_end:
json_ledger_amount_prefix db ',"amount_krw":'
json_ledger_amount_prefix_end:
json_created_prefix db ',"created_at":'
json_created_prefix_end:
json_object_suffix db '}'
json_object_suffix_end:
json_null db 'null'
json_null_end:
json_quote db '"'
json_quote_end:
reason_deposit db "deposit"
reason_deposit_end:
error_text db "native runtime error", 10
error_text_end:
sql_support_total db "SELECT cumulative_support_krw FROM support_totals WHERE discord_id=?1;", 0
sql_insert_order db "INSERT INTO deposit_orders(order_id,discord_id,depositor_name_input,depositor_name_normalized,requested_amount_krw,status,created_at,expires_at,dm_status,interaction_id) VALUES(?1,?2,?3,?4,?5,?6,?7,?8,?9,?10) ON CONFLICT(interaction_id) WHERE interaction_id IS NOT NULL DO NOTHING;", 0
sql_find_interaction_order db "SELECT order_id,discord_id,depositor_name_normalized,requested_amount_krw,dm_status FROM deposit_orders WHERE interaction_id=?1 LIMIT 1;", 0
sql_begin db "BEGIN IMMEDIATE;", 0
sql_commit db "COMMIT;", 0
sql_rollback db "ROLLBACK;", 0
sql_duplicate db "SELECT 1 FROM push_events WHERE push_id=?1 LIMIT 1;", 0
sql_insert_push db "INSERT INTO push_events(push_id,package_name,application_name,title,parsed_depositor_name,parsed_depositor_name_normalized,parsed_amount_krw,processing_status,received_at,push_created_at,push_modified_at) VALUES(?1,?2,?3,?4,?5,?6,?7,?8,?9,?10,?11);", 0
sql_mark_review db "UPDATE push_events SET processing_status='REVIEW' WHERE push_id=?1;", 0
sql_update_push_status db "UPDATE push_events SET processing_status=?1 WHERE push_id=?2;", 0
sql_review db "SELECT push_id,processing_status,parsed_depositor_name,parsed_amount_krw,received_at FROM push_events WHERE processing_status IN ('REVIEW','MATCH_NOT_FOUND','MATCH_AMBIGUOUS','EXPIRED','PARSE_FAILED','UNSUPPORTED') ORDER BY received_at ASC LIMIT 100;", 0
sql_ledger db "SELECT ledger_id,order_id,discord_id,amount_krw,reason,created_at FROM ledger ORDER BY ledger_id DESC LIMIT 100;", 0
sql_find_order db "SELECT order_id,discord_id FROM deposit_orders WHERE depositor_name_normalized=?1 AND requested_amount_krw=?2 AND status='PENDING' AND expires_at>?3 AND created_at<=?4 AND expires_at>?4 AND NOT EXISTS(SELECT 1 FROM deposit_orders AS d2 WHERE d2.depositor_name_normalized=?1 AND d2.requested_amount_krw=?2 AND d2.status='PENDING' AND d2.expires_at>?3 AND NOT(d2.created_at<=?4 AND d2.expires_at>?4)) ORDER BY created_at ASC LIMIT 2;", 0
sql_update_paid db "UPDATE deposit_orders SET status='PAID',matched_push_id=?1,matched_amount_krw=?2,matched_at=?3 WHERE order_id=?4 AND status='PENDING';", 0
sql_insert_ledger db "INSERT INTO ledger(order_id,discord_id,amount_krw,reason,created_at) VALUES(?1,?2,?3,?4,?5);", 0
sql_get_total db "SELECT cumulative_support_krw FROM support_totals WHERE discord_id=?1;", 0
sql_upsert_total db "INSERT INTO support_totals(discord_id,cumulative_support_krw,created_at,updated_at) VALUES(?1,?2,?3,?3) ON CONFLICT(discord_id) DO UPDATE SET cumulative_support_krw=excluded.cumulative_support_krw,updated_at=excluded.updated_at;", 0
sql_mark_consumed db "UPDATE push_events SET processing_status='CONSUMED',consumed_order_id=?1 WHERE push_id=?2;", 0
sql_native_migration_v2 db "ALTER TABLE deposit_orders ADD COLUMN payment_dm_status TEXT NOT NULL DEFAULT 'PENDING';", 0
sql_native_verify_v2 db "SELECT payment_dm_status FROM deposit_orders LIMIT 1;", 0
sql_native_version_v2 db "PRAGMA user_version=2;", 0
sql_native_migration_v3 db "ALTER TABLE deposit_orders ADD COLUMN interaction_id TEXT;", 0
sql_native_verify_v3 db "SELECT interaction_id FROM deposit_orders LIMIT 1;", 0
sql_native_index_v3 db "CREATE UNIQUE INDEX IF NOT EXISTS idx_deposit_orders_interaction_id ON deposit_orders(interaction_id) WHERE interaction_id IS NOT NULL;", 0
sql_native_version_v3 db "PRAGMA user_version=3;", 0
dm_status_pending db "PENDING", 0
dm_status_sent db "SENT", 0
dm_status_failed db "FAILED", 0
json_key_id db "iden"
json_key_id_end:
json_key_type db "type"
json_key_type_end:
json_push_value db "push"
json_mirror_value db "mirror"
json_key_package db "package_name"
json_key_package_end:
json_key_application db "application_name"
json_key_application_end:
json_key_title db "title"
json_key_title_end:
json_key_body db "body"
json_key_body_end:
json_key_notification_id db "notification_id"
json_key_notification_id_end:
json_key_notification_tag db "notification_tag"
json_key_notification_tag_end:
json_key_source_device_iden db "source_device_iden"
json_key_source_device_iden_end:
json_key_source_user_iden db "source_user_iden"
json_key_source_user_iden_end:
fingerprint_key_created db "created"
fingerprint_key_modified db "modified"
fingerprint_key_active db "active"
fingerprint_key_dismissed db "dismissed"
json_timestamp_created_key db '"created":', 0
json_timestamp_modified_key db '"modified":', 0
body_label_name db 0xec,0x9e,0x85,0xea,0xb8,0x88,0xec,0x9e,0x90
body_label_name_end:
body_label_sender db "보낸분"
body_label_sender_end:
body_label_sender_space db "보낸 사람"
body_label_sender_space_end:
body_label_sender_ascii db "sender"
body_label_sender_ascii_end:
body_label_name_ascii db "name"
body_label_name_ascii_end:
body_label_amount db 0xea,0xb8,0x88,0xec,0x95,0xa1
body_label_amount_end:
body_label_deposit_amount db "입금액"
body_label_deposit_amount_end:
body_label_deposit_amount2 db "입금금액"
body_label_deposit_amount2_end:
body_label_amount_ascii db "amount"
body_label_amount_ascii_end:
db_schema:
    db "PRAGMA journal_mode=WAL;PRAGMA synchronous=FULL;PRAGMA foreign_keys=ON;PRAGMA busy_timeout=5000;", 10
    db "CREATE TABLE IF NOT EXISTS support_totals(discord_id TEXT PRIMARY KEY,cumulative_support_krw INTEGER NOT NULL DEFAULT 0,created_at INTEGER NOT NULL,updated_at INTEGER NOT NULL);", 10
    db "CREATE TABLE IF NOT EXISTS deposit_orders(order_id TEXT PRIMARY KEY,interaction_id TEXT,discord_id TEXT NOT NULL,depositor_name_input TEXT NOT NULL,depositor_name_normalized TEXT NOT NULL,requested_amount_krw INTEGER NOT NULL,status TEXT NOT NULL,created_at INTEGER NOT NULL,expires_at INTEGER NOT NULL,matched_push_id TEXT UNIQUE,matched_amount_krw INTEGER,matched_at INTEGER,dm_status TEXT NOT NULL,payment_dm_status TEXT NOT NULL DEFAULT 'PENDING');", 10
    db "CREATE INDEX IF NOT EXISTS idx_deposit_orders_match ON deposit_orders(depositor_name_normalized,requested_amount_krw,status,expires_at);", 10
    db "CREATE TABLE IF NOT EXISTS push_events(push_id TEXT PRIMARY KEY,push_created_at INTEGER,push_modified_at INTEGER,package_name TEXT,application_name TEXT,title TEXT,body_hash TEXT,parsed_depositor_name TEXT,parsed_depositor_name_normalized TEXT,parsed_amount_krw INTEGER,processing_status TEXT NOT NULL,consumed_order_id TEXT,received_at INTEGER NOT NULL);", 10
    db "CREATE INDEX IF NOT EXISTS idx_push_events_status ON push_events(processing_status,received_at);", 10
    db "CREATE TABLE IF NOT EXISTS ledger(ledger_id INTEGER PRIMARY KEY AUTOINCREMENT,order_id TEXT NOT NULL UNIQUE,discord_id TEXT NOT NULL,amount_krw INTEGER NOT NULL,reason TEXT NOT NULL,created_at INTEGER NOT NULL);", 10
    db "CREATE TABLE IF NOT EXISTS settings(key TEXT PRIMARY KEY,value TEXT NOT NULL);", 10
    db "PRAGMA user_version=3;", 0

section .bss
argument_storage resb 65536
argument_ptrs resq 16
argument_lengths resq 16
argument_count resd 1
command_index resd 1
config_path resb 260
config_error resd 1
config_buffer resb 32768
config_value resb 4096
config_length resq 1
runtime_endpoint_host resb 256
runtime_endpoint_host_length resq 1
db_path resb 4096
db_directory_buffer resb 4096
db_handle resq 1
statement_handle resq 1
discord_id_buffer resb 256
name_buffer resb 512
normalized_buffer resb 1024
amount_buffer resb 64
support_id_buffer resb 256
support_id_length resq 1
order_id_buffer resb 128
decimal_buffer resb 64
decimal_tmp resb 64
amount_value resq 1
normalized_length resq 1
discord_id_length resq 1
name_length resq 1
amount_length resq 1
created_at resq 1
push_created_at resq 1
push_modified_at resq 1
push_event_time resq 1
push_created_present resd 1
push_modified_present resd 1
push_timestamp_present resd 1
push_fingerprint_pending resq 1
expires_at resq 1
order_ttl resq 1
order_counter resq 1
auto_credit resd 1
case_insensitive_latin resd 1
min_amount resq 1
max_amount resq 1
write_count resq 1
read_count resq 1
json_path_buffer resb 260
json_buffer resb 65536
json_length resq 1
json_structure_stack resb 256
json_value_length resq 1
json_key_found resd 1
json_selector_found resd 1
line_buffer resb 1024
push_id_buffer resb 256
push_id_length resq 1
fingerprint_scratch resb 1024
package_buffer resb 256
package_length resq 1
application_buffer resb 256
application_length resq 1
title_buffer resb 1024
title_length resq 1
body_buffer resb 16384
body_length resq 1
parsed_name_buffer resb 512
parsed_name_length resq 1
parsed_amount_value resq 1
push_mirror_kind resq 1
status_scratch resb 64
status_scratch_length resq 1
list_first resd 1
filter_package resb 256
filter_package_length resq 1
filter_application resb 256
filter_application_length resq 1
filter_title_prefix resb 1024
filter_title_prefix_length resq 1
filter_title_pattern resb 2048
filter_title_pattern_length resq 1
filter_amount resb 4096
filter_amount_length resq 1
filter_name resb 4096
filter_name_length resq 1
discord_token resb 2048
discord_token_length resq 1
pushbullet_token resb 2048
pushbullet_token_length resq 1
credit_order_id resb 128
credit_order_id_length resq 1
credit_discord_id resb 256
credit_discord_id_length resq 1
credit_current_total resq 1
credit_next_total resq 1
service_message resb 16384
service_message_length resq 1
service_mode resd 1
service_buffer_mode resd 1
order_dm_required resd 1
