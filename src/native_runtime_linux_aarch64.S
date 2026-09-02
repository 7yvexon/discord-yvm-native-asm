.text
.global yul_native_runtime_main
.global rt_validate_gateway_url
.global rt_validate_push_url
.global rt_json_validate_structure
.global rt_json_buffer
.global rt_json_length
.global rt_service_cursor
.type yul_native_runtime_main, %function
.extern yul_native_network_probe
.extern yul_native_network_run
.extern yul_native_network_start
.extern yul_native_network_rest_json
.extern native_ws_open_url
.extern native_ws_build_upgrade
.extern native_ws_build_upgrade_url
.extern native_ws_close
.extern native_ws_send_text
.extern native_ws_recv_message
.extern native_pushbullet_poll
.extern native_ws_build_identify
.extern native_ws_build_heartbeat
.extern native_ws_sleep
.extern native_json_find_pattern
.extern native_json_find_root_pattern
.extern native_json_find_number
.extern native_json_find_root_number
.extern native_parse_decimal_scaled
.extern native_json_find_root_decimal_scaled
.extern native_scaled_u64_to_ascii
.extern native_json_validate_structure
.extern ws_json_buffer
.extern ws_json_length
.extern ws_cursor
.extern ws_cursor_candidate
.extern ws_poll_has_pushes
.extern ws_sequence
.extern ws_sequence_valid
.extern ws_heartbeat_interval
.extern ws_identify_intents
.extern ws_error_code
.extern ws_stage
.extern rest_status
.extern rest_error_code
.extern discord_gateway_url
.extern discord_ws_host
.extern discord_ws_path
.extern json_key_heartbeat_interval
.extern json_key_op
.extern json_key_s
.extern json_key_ready
.extern json_key_type_push
.extern json_key_type_push_space
.extern json_key_type_tickle
.extern json_key_type_tickle_space
.extern pushbullet_ws_host
.extern pushbullet_ws_path_prefix
.extern pushbullet_stream_prefix
.extern ws_http_path
.extern ws_stream_url
.extern fork
.extern prctl
.extern signal
.extern kill
.extern waitpid
.extern yul_parse_amount_ascii
.extern yul_normalize_name_utf8
.extern yul_add_support_total
.extern yul_sqlite_runtime_load
.extern yul_sqlite_runtime_unload
.extern yul_sqlite_open
.extern yul_sqlite_close
.extern yul_sqlite_exec
.extern yul_sqlite_prepare
.extern yul_sqlite_bind_text
.extern yul_sqlite_bind_int64
.extern yul_sqlite_bind_null
.extern yul_sqlite_step
.extern yul_sqlite_finalize
.extern yul_sqlite_column_int64
.extern yul_sqlite_column_text

.section .rodata
cmd_init_db: .ascii "init-db"
cmd_panel_text: .ascii "panel-text"
cmd_support_total: .ascii "support-total"
cmd_create_order: .ascii "create-order"
cmd_process_push: .ascii "process-push"
cmd_run: .ascii "run"
cmd_review_list: .ascii "review-list"
cmd_ledger: .ascii "ledger"
cmd_validate_config: .ascii "validate-config"
cmd_gateway_probe: .ascii "gateway-probe"
config_option: .ascii "--config"
default_db_path: .asciz "vending.db"
default_config_path: .asciz ".local-vending.ini"
default_tag_log_channel: .asciz ""
default_tag_status_channel: .asciz ""
default_tag_role: .asciz ""
default_push_stream: .asciz "wss://stream.pushbullet.com/websocket"
key_database: .ascii "DATABASE_PATH"
key_ttl: .ascii "ORDER_TTL_SECONDS"
key_auto: .ascii "AUTO_CREDIT"
key_case: .ascii "CASE_INSENSITIVE_LATIN"
key_package: .ascii "BANK_PACKAGE_NAME"
key_application: .ascii "BANK_APPLICATION_NAME"
key_title: .ascii "BANK_TITLE_PREFIX"
key_title_pattern: .ascii "BANK_TITLE_PATTERN"
key_amount_pattern: .ascii "BANK_AMOUNT_PATTERN"
key_name_pattern: .ascii "BANK_NAME_PATTERN"
key_min: .ascii "MIN_AMOUNT_KRW"
key_max: .ascii "MAX_AMOUNT_KRW"
key_discord_token: .ascii "DISCORD_BOT_TOKEN"
key_discord_gateway: .ascii "DISCORD_GATEWAY_URL"
key_pushbullet_token: .ascii "PUSHBULLET_ACCESS_TOKEN"
key_discord_application: .ascii "DISCORD_APPLICATION_ID"
key_discord_guild: .ascii "DISCORD_GUILD_ID"
key_discord_panel: .ascii "DISCORD_PANEL_CHANNEL_ID"
key_discord_tag_log: .ascii "DISCORD_GUILD_TAG_LOG_CHANNEL_ID"
key_discord_tag_status: .ascii "DISCORD_GUILD_TAG_STATUS_CHANNEL_ID"
key_discord_tag_role: .ascii "DISCORD_GUILD_TAG_ROLE_ID"
key_discord_admin: .ascii "DISCORD_ADMIN_USER_ID"
key_discord_intents: .ascii "DISCORD_INTENTS"
key_push_stream: .ascii "PUSHBULLET_STREAM_URL"
key_bank_name: .ascii "BANK_NAME"
key_bank_account: .ascii "BANK_ACCOUNT_NUMBER"
key_bank_holder: .ascii "BANK_ACCOUNT_HOLDER"
.align 3
rt_config_key_table:
    .quad key_database - rt_config_key_table
    .quad 13
    .quad key_ttl - rt_config_key_table
    .quad 17
    .quad key_auto - rt_config_key_table
    .quad 11
    .quad key_case - rt_config_key_table
    .quad 22
    .quad key_package - rt_config_key_table
    .quad 17
    .quad key_application - rt_config_key_table
    .quad 21
    .quad key_title - rt_config_key_table
    .quad 17
    .quad key_title_pattern - rt_config_key_table
    .quad 18
    .quad key_amount_pattern - rt_config_key_table
    .quad 19
    .quad key_name_pattern - rt_config_key_table
    .quad 17
    .quad key_min - rt_config_key_table
    .quad 14
    .quad key_max - rt_config_key_table
    .quad 14
    .quad key_discord_token - rt_config_key_table
    .quad 17
    .quad key_discord_gateway - rt_config_key_table
    .quad 19
    .quad key_pushbullet_token - rt_config_key_table
    .quad 23
    .quad key_discord_application - rt_config_key_table
    .quad 22
    .quad key_discord_guild - rt_config_key_table
    .quad 16
    .quad key_discord_panel - rt_config_key_table
    .quad 24
    .quad key_discord_tag_log - rt_config_key_table
    .quad 32
    .quad key_discord_tag_status - rt_config_key_table
    .quad 35
    .quad key_discord_tag_role - rt_config_key_table
    .quad 25
    .quad key_discord_admin - rt_config_key_table
    .quad 21
    .quad key_discord_intents - rt_config_key_table
    .quad 15
    .quad key_push_stream - rt_config_key_table
    .quad 21
    .quad key_bank_name - rt_config_key_table
    .quad 9
    .quad key_bank_account - rt_config_key_table
    .quad 19
    .quad key_bank_holder - rt_config_key_table
    .quad 19
bool_true_1: .asciz "1"
bool_false_0: .asciz "0"
bool_true_lower: .asciz "true"
bool_true_upper: .asciz "TRUE"
bool_false_lower: .asciz "false"
bool_false_upper: .asciz "FALSE"
bool_yes_lower: .asciz "yes"
bool_yes_upper: .asciz "YES"
bool_no_lower: .asciz "no"
bool_no_upper: .asciz "NO"
order_prefix: .ascii "native-"
status_pending: .asciz "PENDING"
status_received: .asciz "RECEIVED"
status_review: .asciz "REVIEW"
status_consumed: .asciz "CONSUMED"
status_sent: .asciz "SENT"
status_failed: .asciz "FAILED"
status_parse_failed: .asciz "PARSE_FAILED"
status_unsupported: .asciz "UNSUPPORTED"
status_duplicate: .asciz "DUPLICATE"
status_match_not_found: .asciz "MATCH_NOT_FOUND"
status_match_ambiguous: .asciz "MATCH_AMBIGUOUS"
status_expired: .asciz "EXPIRED"
reason_deposit: .ascii "deposit"
newline: .byte 10
panel_text: .asciz "입금 후원 패널\n입금자명은 신청할 때 입력한 값과 같아야 합니다.\n금액 범위: 설정값\n입금 알림 반영까지 시간이 걸릴 수 있습니다.\n같은 이름과 금액의 주문이 여러 개면 자동 지급되지 않습니다.\n"
usage_text: .asciz "native commands: init-db | panel-text | create-order <discord-id> <name> <amount> | process-push <json> | support-total <discord-id> | review-list | ledger | validate-config | gateway-probe | run\n"
run_text: .asciz "native service stopped\n"
error_text: .asciz "native runtime error\n"
config_valid_text: .asciz "native config valid\n"
config_invalid_text: .asciz "native config invalid\n"
gateway_probe_result_prefix: .asciz "gateway-probe result="
gateway_probe_stage_prefix: .asciz " stage="
gateway_probe_error_prefix: .asciz " curl_error="
order_created_text: .asciz "order-created: "
result_prefix: .asciz "status: "
result_mid_push: .asciz " push-id: "
result_suffix: .byte 10
rt_hex_digits: .ascii "0123456789abcdef"
list_start: .asciz "["
list_separator: .asciz ","
list_end: .asciz "]"
list_end_newline: .byte 10
json_push_prefix: .asciz "{\"push_id\":\""
json_status_prefix: .asciz "\",\"status\":\""
json_name_prefix: .asciz "\",\"parsed_depositor_name\":"
json_amount_prefix: .asciz ",\"parsed_amount_krw\":"
json_ledger_amount_prefix: .asciz ",\"amount_krw\":"
json_received_prefix: .asciz ",\"received_at\":"
json_order_prefix: .asciz "{\"ledger_id\":"
json_order_id_prefix: .asciz ",\"order_id\":\""
json_discord_prefix: .asciz "\",\"discord_id\":\""
json_reason_prefix: .asciz ",\"reason\":\""
json_created_prefix: .asciz ",\"created_at\":"
json_object_suffix: .asciz "}"
json_null: .asciz "null"
json_quote: .asciz "\""
json_key_id: .ascii "iden"
json_key_type: .ascii "type"
json_push_value: .ascii "push"
json_mirror_value: .ascii "mirror"
json_message_id: .ascii "id"
json_data_key: .ascii "d"
json_message_key: .ascii "message"
json_member_key: .ascii "member"
json_user_key: .ascii "user"
json_key_push_object: .ascii "push"
json_created_key: .ascii "\"created\":"
json_modified_key: .ascii "\"modified\":"
json_created_name: .ascii "\"created\""
json_modified_name: .ascii "\"modified\""
json_cursor_key: .ascii "\"cursor\":"
json_cursor_key_space: .ascii "\"cursor\" :"
json_key_package: .ascii "package_name"
json_key_application: .ascii "application_name"
json_key_title: .ascii "title"
json_key_body: .ascii "body"
json_key_notification_id: .ascii "notification_id"
json_key_notification_tag: .ascii "notification_tag"
json_key_source_device_iden: .ascii "source_device_iden"
json_key_source_user_iden: .ascii "source_user_iden"
fingerprint_key_active: .ascii "active"
fingerprint_key_dismissed: .ascii "dismissed"
json_pushes_key: .ascii "\"pushes\""
json_pushes_prefix: .ascii "\"pushes\": ["
json_pushes_prefix_compact: .ascii "\"pushes\":["
json_push_type_mirror: .ascii "\"type\":\"mirror\""
json_push_type_mirror_space: .ascii "\"type\": \"mirror\""
fingerprint_mirror_prefix: .asciz "mirror-"
fingerprint_invalid_prefix: .asciz "invalid-"
label_name: .byte 0xec,0x9e,0x85,0xea,0xb8,0x88,0xec,0x9e,0x90
label_sender: .byte 0xeb,0xb3,0xb4,0xeb,0x82,0xb8,0xeb,0xb6,0x84
label_sender_space: .byte 0xeb,0xb3,0xb4,0xeb,0x82,0xb8,0x20,0xec,0x82,0xac,0xeb,0x9e,0x8c
label_sender_ascii: .ascii "sender"
label_name_ascii: .ascii "name"
label_amount: .byte 0xea,0xb8,0x88,0xec,0x95,0xa1
label_deposit_amount: .byte 0xec,0x9e,0x85,0xea,0xb8,0x88,0xec,0x95,0xa1
label_deposit_amount2: .byte 0xec,0x9e,0x85,0xea,0xb8,0x88,0xea,0xb8,0x88,0xec,0x95,0xa1
label_amount_ascii: .ascii "amount"
utf8_arrow: .byte 0xe2,0x86,0x92
default_bank_amount_pattern: .asciz "(?:입금액|입금금액|금액|amount)\\s*[:：]?\\s*([0-9][0-9,]*)"
default_bank_name_pattern: .asciz "(?:입금자|보낸분|보낸 사람|sender|name)\\s*[:：]?\\s*([^\\r\\n,()]{1,100})"
title_pattern_toss: .asciz "^[0-9][0-9,]*원\\s*입금$"
title_amount_pattern_toss: .asciz "([0-9][0-9,]*)원\\s*입금"
arrow_bank_name_pattern: .asciz "^([^\\r\\n→,()]{1,100}?)\\s*→\\s*내 토스뱅크 통장$"
arrow_bank_name_suffix: .asciz "내 토스뱅크 통장"
endpoint_gateway_exact: .asciz "gateway.discord.gg"
endpoint_gateway_suffix_gg: .asciz ".discord.gg"
endpoint_gateway_suffix_com: .asciz ".discord.com"
endpoint_push_exact: .asciz "stream.pushbullet.com"
endpoint_push_path: .asciz "/websocket"
endpoint_query_v: .asciz "v"
endpoint_query_encoding: .asciz "encoding"
discord_api_prefix: .asciz "https://discord.com/api/v10/"
path_commands_prefix: .asciz "applications/"
path_commands_middle: .asciz "/guilds/"
path_commands_suffix: .asciz "/commands"
path_channel_messages: .asciz "channels/"
path_messages_suffix: .asciz "/messages"
path_messages_history_suffix: .asciz "/messages?limit=100"
path_guild_members_prefix: .asciz "guilds/"
path_guild_members_suffix: .asciz "/members?limit=50"
path_guild_members_after: .asciz "&after="
path_guild_member_roles_prefix: .asciz "guilds/"
path_guild_member_roles_member: .asciz "/members/"
path_guild_member_roles_suffix: .asciz "/roles/"
path_interaction_prefix: .asciz "interactions/"
path_interaction_middle: .asciz "/"
path_interaction_suffix: .asciz "/callback"
path_dm_create: .asciz "users/@me/channels"
path_webhook_prefix: .asciz "webhooks/"
path_webhook_middle: .asciz "/"
path_webhook_message: .asciz "/messages/@original"
method_post: .asciz "POST"
method_put: .asciz "PUT"
method_patch: .asciz "PATCH"
method_delete: .asciz "DELETE"
method_get: .asciz "GET"
json_commands: .asciz "[{\"name\":\"후원금액\",\"description\":\"내 누적 후원 금액을 확인합니다.\",\"type\":1},{\"name\":\"입금패널\",\"description\":\"입금 패널을 게시합니다.\",\"type\":1},{\"name\":\"검토목록\",\"description\":\"자동 처리되지 않은 입금 알림을 조회합니다.\",\"type\":1},{\"name\":\"지급원장\",\"description\":\"지급 원장을 조회합니다.\",\"type\":1}]"
 json_panel_prefix: .asciz "{\"embeds\":[{\"title\":\"💳 입금 후원 안내\",\"description\":\"후원할 금액과 입금자명을 등록하면 입금 알림을 확인해 자동으로 반영합니다.\",\"color\":5793266,\"fields\":[{\"name\":\"📝 신청 방법\",\"value\":\"1. **입금 신청** 버튼을 눌러요.\\n2. 입금자명과 금액을 입력해요.\\n3. 안내된 계좌로 정확히 입금해요.\",\"inline\":false},{\"name\":\"⏱️ 처리 안내\",\"value\":\"입금 알림 반영까지 잠시 걸릴 수 있어요.\",\"inline\":true},{\"name\":\"🔐 자동 확인 조건\",\"value\":\"입금자명과 금액이 신청 정보와 모두 일치해야 해요.\",\"inline\":false}]}],\"components\":[{\"type\":1,\"components\":[{\"type\":2,\"style\":1,\"label\":\"입금 신청\",\"custom_id\":\"vending:deposit:v1\",\"emoji\":{\"name\":\"💳\"}}]}]}"
json_modal_response: .asciz "{\"type\":9,\"data\":{\"custom_id\":\"vending:deposit:modal:v1\",\"title\":\"💳 입금 신청\",\"components\":[{\"type\":1,\"components\":[{\"type\":4,\"custom_id\":\"depositor_name\",\"label\":\"입금자명\",\"style\":1,\"required\":true,\"max_length\":100}]},{\"type\":1,\"components\":[{\"type\":4,\"custom_id\":\"amount_krw\",\"label\":\"입금 금액(원)\",\"style\":1,\"required\":true,\"max_length\":19}]}]}}"
json_deferred_response: .asciz "{\"type\":5,\"data\":{\"flags\":64}}"
json_response_prefix: .asciz "{\"type\":4,\"data\":{\"embeds\":[{\"title\":\"테스트 자판기\",\"description\":\""
json_response_suffix: .asciz "\",\"color\":5793266}],\"flags\":64}}"
 json_dm_channel_prefix: .asciz "{\"recipient_id\":\""
 json_dm_channel_suffix: .asciz "\"}"
 json_dm_content_prefix: .asciz "{\"embeds\":[{\"title\":\"테스트 자판기\",\"description\":\""
 json_dm_nonce_prefix: .asciz "\",\"color\":5793266}],\"nonce\":\""
 json_dm_nonce_suffix: .asciz "\",\"enforce_nonce\":true}"
 dm_nonce_order_prefix: .asciz "o-"
 dm_nonce_payment_prefix: .asciz "p-"
json_quote_colon: .asciz "\":\""
json_string_end: .asciz "\""
json_value_prefix: .asciz "\"value\":\""
json_id_pattern: .ascii "\"id\":\""
json_token_pattern: .ascii "\"token\":\""
json_name_pattern: .ascii "\"name\":\""
json_name_pattern_space: .ascii "\"name\": \""
json_custom_pattern: .ascii "\"custom_id\":\""
json_custom_pattern_space: .ascii "\"custom_id\": \""
json_event_interaction: .ascii "\"t\":\"INTERACTION_CREATE\""
json_event_interaction_space: .ascii "\"t\": \"INTERACTION_CREATE\""
json_event_member_update: .ascii "\"t\":\"GUILD_MEMBER_UPDATE\""
json_event_member_update_space: .ascii "\"t\": \"GUILD_MEMBER_UPDATE\""
json_event_resumed: .ascii "\"t\":\"RESUMED\""
json_event_resumed_space: .ascii "\"t\": \"RESUMED\""
json_member_tag_enabled: .ascii "\"identity_enabled\":true"
json_member_tag_enabled_space: .ascii "\"identity_enabled\": true"
json_member_tag_value: .ascii "\"tag\":\"뀨?\""
json_member_tag_value_space: .ascii "\"tag\": \"뀨?\""
json_key_guild_id: .ascii "guild_id"
json_key_application_id: .ascii "application_id"
json_key_channel_id: .ascii "channel_id"
json_key_identity_guild_id: .ascii "identity_guild_id"
json_key_primary_guild: .ascii "primary_guild"
json_key_user: .ascii "user"
json_tag_log_prefix: .asciz "{\"embeds\":[{\"title\":\"🏷️ `뀨?` 길드 태그 "
json_tag_log_enabled_middle: .asciz "착용\",\"description\":\"<@"
json_tag_log_disabled_middle: .asciz "해제\",\"description\":\"<@"
json_tag_log_description_middle: .asciz "> 님의 `뀨?` 길드 태그가 변경되었습니다.\",\"color\":"
json_tag_log_enabled_color: .asciz "5763719"
json_tag_log_disabled_color: .asciz "16705372"
json_tag_log_suffix: .asciz "}]}"
json_tag_status_prefix: .asciz "{\"embeds\":[{\"title\":\"🏷️ `뀨?` 현재 착용자\",\"description\":\"현재 `뀨?` 길드 태그를 착용 중인 사람: **"
json_tag_status_count_suffix: .asciz "명**"
json_tag_status_empty: .asciz "\\n\\n현재 착용 중인 사람이 없습니다."
json_tag_status_item_prefix: .asciz "\\n\\n• <@"
json_tag_status_item_suffix: .asciz ">"
json_tag_status_suffix: .asciz "\",\"color\":5763719}],\"allowed_mentions\":{\"parse\":[]}}"
json_tag_status_nonce_key: .ascii "nonce"
json_tag_status_nonce_prefix: .asciz ",\"nonce\":\""
json_tag_status_nonce_suffix: .asciz "\",\"enforce_nonce\":true}"
json_tag_status_title_pattern: .asciz "\"title\":\"🏷️ `뀨?` 현재 착용자\""
json_tag_status_author_bot_pattern: .asciz "\"bot\":true"
json_tag_status_setting_message: .asciz "discord.guild_tag_status_message_id"
json_tag_status_setting_channel: .asciz "discord.guild_tag_status_channel_id"
json_tag_status_setting_members: .asciz "discord.guild_tag_status_members"
json_type_pattern: .ascii "\"type\":"
json_op_pattern: .ascii "\"op\":"
json_sequence_pattern: .ascii "\"s\":"
json_token_key: .ascii "token"
json_modal_data_key: .ascii "data"
json_session_key: .ascii "session_id"
json_resume_key: .ascii "resume_gateway_url"
json_session_pattern: .ascii "\"session_id\":\""
json_resume_pattern: .ascii "\"resume_gateway_url\":\""
json_ready_pattern: .ascii "\"t\":\"READY\""
json_gateway_reconnect: .asciz "{\"op\":6,\"d\":{\"token\":\""
json_gateway_resume_mid: .asciz "\",\"session_id\":\""
json_gateway_resume_seq: .asciz "\",\"seq\":"
json_gateway_resume_suffix: .asciz "}}"
json_rest_content_prefix: .asciz "{\"embeds\":[{\"title\":\"테스트 자판기\",\"description\":\""
json_rest_content_suffix: .asciz "\",\"color\":5793266}]}"
json_order_content_prefix: .asciz "✅ **입금 신청이 접수되었습니다.**\n은행: "
json_order_content_account: .asciz "\n계좌번호: "
json_order_content_holder: .asciz "\n예금주: "
json_order_content_amount: .asciz "\n입금 금액: "
json_order_content_name: .asciz "\n입금자명: "
json_order_content_expiry: .asciz "\n만료 시각: "
json_order_content_suffix: .asciz "\n입금자명과 금액이 모두 일치해야 자동 확인됩니다."
 json_payment_content_prefix: .asciz "🎉 **입금이 확인되었습니다!**\n반영 금액: "
 json_payment_content_total: .asciz "\n누적 후원 금액: "
 json_support_content_prefix: .asciz "💰 **누적 후원 금액**\n현재까지 "
json_support_content_suffix: .asciz "원 입니다."
command_support_name: .asciz "후원금액"
command_panel_name: .asciz "입금패널"
command_review_name: .asciz "검토목록"
command_ledger_name: .asciz "지급원장"
button_deposit_id: .asciz "vending:deposit:v1"
modal_deposit_id: .asciz "vending:deposit:modal:v1"
response_invalid: .asciz "⚠️ 요청 형식이 올바르지 않습니다."
response_unsupported: .asciz "⚠️ 지원하지 않는 요청입니다."
response_permission: .asciz "⛔ 관리자 권한을 확인해 주세요."
response_invalid_input: .asciz "⚠️ 입금자명 또는 금액을 확인해 주세요."
response_order_failed: .asciz "⚠️ 입금 신청을 처리하지 못했습니다."
response_panel_failed: .asciz "⚠️ 입금 패널을 게시하지 못했습니다."
response_panel_success: .asciz "✅ 입금 패널을 게시했습니다."
response_total_prefix: .asciz "💰 누적 후원 금액\n현재까지 "
response_total_suffix: .asciz "원 입니다."
response_review_empty: .asciz "📭 검토 대기 입금이 없습니다."
response_ledger_empty: .asciz "📭 지급 원장이 없습니다."
service_stage_db: .asciz "native service stage: db\n"
service_stage_rest: .asciz "native service stage: rest\n"
service_stage_token: .asciz "native service stage: token\n"
 service_stage_fork: .asciz "native service stage: fork\n"
 service_stage_gateway_child: .asciz "native service stage: gateway-child\n"
service_interaction_parse_failed: .asciz "native interaction parse failed\n"
service_interaction_callback_failed: .asciz "native interaction callback failed status="
service_gateway_child_exited: .asciz "native gateway child exited code="
service_gateway_child_signaled: .asciz "native gateway child signaled signal="
service_gateway_child_wait_error: .asciz "native gateway child waitpid error\n"
service_stage_network_start: .asciz "native service stage: network-start\n"
service_stage_register_commands: .asciz "native service stage: register-commands\n"
service_rest_failure: .asciz "native service rest failure status="
service_rest_failure_curl: .asciz " curl="
setting_gateway_sequence: .asciz "discord.gateway_sequence"
setting_gateway_session: .asciz "discord.gateway_session_id"
setting_gateway_resume: .asciz "discord.gateway_resume_url"
setting_push_cursor: .asciz "pushbullet.last_modified"
setting_panel_message: .asciz "discord.panel_message_id"
sql_begin: .asciz "BEGIN IMMEDIATE;"
sql_commit: .asciz "COMMIT;"
sql_rollback: .asciz "ROLLBACK;"
sql_duplicate: .asciz "SELECT 1 FROM push_events WHERE push_id=?1 LIMIT 1;"
sql_insert_push: .asciz "INSERT INTO push_events(push_id,package_name,application_name,title,parsed_depositor_name,parsed_depositor_name_normalized,parsed_amount_krw,processing_status,received_at,push_created_at,push_modified_at) VALUES(?1,?2,?3,?4,?5,?6,?7,?8,?9,?10,?11);"
sql_update_push_status: .asciz "UPDATE push_events SET processing_status=?1 WHERE push_id=?2;"
sql_expire: .asciz "UPDATE deposit_orders SET status='EXPIRED' WHERE status='PENDING' AND expires_at<=?1;"
sql_find_order: .asciz "SELECT order_id,discord_id FROM deposit_orders WHERE depositor_name_normalized=?1 AND requested_amount_krw=?2 AND status='PENDING' AND expires_at>?3 AND created_at<=?4 AND expires_at>?4 AND NOT EXISTS(SELECT 1 FROM deposit_orders AS d2 WHERE d2.depositor_name_normalized=?1 AND d2.requested_amount_krw=?2 AND d2.status='PENDING' AND d2.expires_at>?3 AND NOT(d2.created_at<=?4 AND d2.expires_at>?4)) ORDER BY created_at ASC,order_id ASC LIMIT 2;"
sql_update_paid: .asciz "UPDATE deposit_orders SET status='PAID',matched_push_id=?1,matched_amount_krw=?2,matched_at=?3 WHERE order_id=?4 AND status='PENDING';"
sql_insert_ledger: .asciz "INSERT INTO ledger(order_id,discord_id,amount_krw,reason,created_at) VALUES(?1,?2,?3,?4,?5);"
sql_get_total: .asciz "SELECT cumulative_support_krw FROM support_totals WHERE discord_id=?1;"
sql_upsert_total: .asciz "INSERT INTO support_totals(discord_id,cumulative_support_krw,created_at,updated_at) VALUES(?1,?2,?3,?3) ON CONFLICT(discord_id) DO UPDATE SET cumulative_support_krw=excluded.cumulative_support_krw,updated_at=excluded.updated_at;"
sql_mark_consumed: .asciz "UPDATE push_events SET processing_status='CONSUMED',consumed_order_id=?1 WHERE push_id=?2;"
sql_insert_order: .asciz "INSERT INTO deposit_orders(order_id,discord_id,depositor_name_input,depositor_name_normalized,requested_amount_krw,status,created_at,expires_at,dm_status,interaction_id) VALUES(?1,?2,?3,?4,?5,?6,?7,?8,?9,?10) ON CONFLICT(interaction_id) WHERE interaction_id IS NOT NULL DO NOTHING;"
sql_find_interaction_order: .asciz "SELECT order_id,discord_id,depositor_name_normalized,requested_amount_krw,dm_status FROM deposit_orders WHERE interaction_id=?1 LIMIT 1;"
sql_review: .asciz "SELECT push_id,processing_status,parsed_depositor_name,parsed_amount_krw,received_at FROM push_events WHERE processing_status IN ('REVIEW','MATCH_NOT_FOUND','MATCH_AMBIGUOUS','EXPIRED','PARSE_FAILED','UNSUPPORTED') ORDER BY received_at ASC LIMIT 100;"
sql_ledger: .asciz "SELECT ledger_id,order_id,discord_id,amount_krw,reason,created_at FROM ledger ORDER BY ledger_id DESC LIMIT 100;"
sql_get_setting: .asciz "SELECT value FROM settings WHERE key=?1 LIMIT 1;"
sql_set_setting: .asciz "INSERT INTO settings(key,value) VALUES(?1,?2) ON CONFLICT(key) DO UPDATE SET value=excluded.value;"
sql_update_dm: .asciz "UPDATE deposit_orders SET dm_status=?1 WHERE order_id=?2;"
sql_update_payment_dm: .asciz "UPDATE deposit_orders SET payment_dm_status=?1 WHERE order_id=?2;"
sql_pending_dm: .asciz "SELECT order_id,discord_id,depositor_name_input,requested_amount_krw,expires_at FROM deposit_orders WHERE dm_status IN ('PENDING','FAILED') ORDER BY created_at ASC LIMIT 1;"
sql_pending_payment_dm: .asciz "SELECT order_id,discord_id,matched_amount_krw FROM deposit_orders WHERE status='PAID' AND payment_dm_status IN ('PENDING','FAILED') ORDER BY matched_at ASC LIMIT 1;"
sql_native_migration_v2: .asciz "ALTER TABLE deposit_orders ADD COLUMN payment_dm_status TEXT NOT NULL DEFAULT 'PENDING';"
sql_native_verify_v2: .asciz "SELECT payment_dm_status FROM deposit_orders LIMIT 1;"
sql_native_version_v2: .asciz "PRAGMA user_version=2;"
sql_native_migration_v3: .asciz "ALTER TABLE deposit_orders ADD COLUMN interaction_id TEXT;"
sql_native_verify_v3: .asciz "SELECT interaction_id FROM deposit_orders LIMIT 1;"
sql_native_index_v3: .asciz "CREATE UNIQUE INDEX IF NOT EXISTS idx_deposit_orders_interaction_id ON deposit_orders(interaction_id) WHERE interaction_id IS NOT NULL;"
sql_native_version_v3: .asciz "PRAGMA user_version=3;"
db_schema:
    .ascii "PRAGMA journal_mode=WAL;PRAGMA synchronous=FULL;PRAGMA foreign_keys=ON;PRAGMA busy_timeout=5000;"
    .byte 10
    .ascii "CREATE TABLE IF NOT EXISTS support_totals(discord_id TEXT PRIMARY KEY,cumulative_support_krw INTEGER NOT NULL DEFAULT 0,created_at INTEGER NOT NULL,updated_at INTEGER NOT NULL);"
    .byte 10
    .ascii "CREATE TABLE IF NOT EXISTS deposit_orders(order_id TEXT PRIMARY KEY,interaction_id TEXT,discord_id TEXT NOT NULL,depositor_name_input TEXT NOT NULL,depositor_name_normalized TEXT NOT NULL,requested_amount_krw INTEGER NOT NULL,status TEXT NOT NULL,created_at INTEGER NOT NULL,expires_at INTEGER NOT NULL,matched_push_id TEXT UNIQUE,matched_amount_krw INTEGER,matched_at INTEGER,dm_status TEXT NOT NULL,payment_dm_status TEXT NOT NULL DEFAULT 'PENDING');"
    .byte 10
    .ascii "CREATE INDEX IF NOT EXISTS idx_deposit_orders_match ON deposit_orders(depositor_name_normalized,requested_amount_krw,status,expires_at);"
    .byte 10
    .ascii "CREATE TABLE IF NOT EXISTS push_events(push_id TEXT PRIMARY KEY,push_created_at INTEGER,push_modified_at INTEGER,package_name TEXT,application_name TEXT,title TEXT,body_hash TEXT,parsed_depositor_name TEXT,parsed_depositor_name_normalized TEXT,parsed_amount_krw INTEGER,processing_status TEXT NOT NULL,consumed_order_id TEXT,received_at INTEGER NOT NULL);"
    .byte 10
    .ascii "CREATE INDEX IF NOT EXISTS idx_push_events_status ON push_events(processing_status,received_at);"
    .byte 10
    .ascii "CREATE TABLE IF NOT EXISTS ledger(ledger_id INTEGER PRIMARY KEY AUTOINCREMENT,order_id TEXT NOT NULL UNIQUE,discord_id TEXT NOT NULL,amount_krw INTEGER NOT NULL,reason TEXT NOT NULL,created_at INTEGER NOT NULL);"
    .byte 10
    .ascii "CREATE TABLE IF NOT EXISTS settings(key TEXT PRIMARY KEY,value TEXT NOT NULL);"
    .byte 10
    .asciz "PRAGMA user_version=3;"

.text
yul_native_runtime_main:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    adrp x2, rt_argc
    add x2, x2, :lo12:rt_argc
    str x0, [x2]
    adrp x2, rt_argv
    add x2, x2, :lo12:rt_argv
    str x1, [x2]
    bl rt_defaults
    bl rt_load_cli
    bl rt_load_config
    bl rt_find_command
    adrp x19, rt_command_index
    add x19, x19, :lo12:rt_command_index
    ldr x19, [x19]
    cmp x19, #-1
    b.eq rt_usage
    adrp x20, rt_argv
    add x20, x20, :lo12:rt_argv
    ldr x20, [x20]
    ldr x20, [x20, x19, lsl #3]
    adrp x21, cmd_init_db
    add x21, x21, :lo12:cmd_init_db
    mov x22, #7
    mov x0, x20
    mov x1, x21
    mov x2, x22
    bl rt_str_eq
    cbnz w0, rt_cmd_init
    adrp x21, cmd_panel_text
    add x21, x21, :lo12:cmd_panel_text
    mov x22, #10
    mov x0, x20
    mov x1, x21
    mov x2, x22
    bl rt_str_eq
    cbnz w0, rt_cmd_panel
    adrp x21, cmd_support_total
    add x21, x21, :lo12:cmd_support_total
    mov x22, #13
    mov x0, x20
    mov x1, x21
    mov x2, x22
    bl rt_str_eq
    cbnz w0, rt_cmd_total
    adrp x21, cmd_create_order
    add x21, x21, :lo12:cmd_create_order
    mov x22, #12
    mov x0, x20
    mov x1, x21
    mov x2, x22
    bl rt_str_eq
    cbnz w0, rt_cmd_order
    adrp x21, cmd_process_push
    add x21, x21, :lo12:cmd_process_push
    mov x22, #12
    mov x0, x20
    mov x1, x21
    mov x2, x22
    bl rt_str_eq
    cbnz w0, rt_cmd_push
    adrp x21, cmd_review_list
    add x21, x21, :lo12:cmd_review_list
    mov x22, #11
    mov x0, x20
    mov x1, x21
    mov x2, x22
    bl rt_str_eq
    cbnz w0, rt_cmd_review
    adrp x21, cmd_ledger
    add x21, x21, :lo12:cmd_ledger
    mov x22, #6
    mov x0, x20
    mov x1, x21
    mov x2, x22
    bl rt_str_eq
    cbnz w0, rt_cmd_ledger
    adrp x21, cmd_run
    add x21, x21, :lo12:cmd_run
    mov x22, #3
    mov x0, x20
    mov x1, x21
    mov x2, x22
    bl rt_str_eq
    cbnz w0, rt_cmd_run
    adrp x21, cmd_validate_config
    add x21, x21, :lo12:cmd_validate_config
    mov x22, #15
    mov x0, x20
    mov x1, x21
    mov x2, x22
    bl rt_str_eq
    cbnz w0, rt_cmd_validate_config
    adrp x21, cmd_gateway_probe
    add x21, x21, :lo12:cmd_gateway_probe
    mov x22, #13
    mov x0, x20
    mov x1, x21
    mov x2, x22
    bl rt_str_eq
    cbnz w0, rt_cmd_gateway_probe
rt_usage:
    adrp x0, usage_text
    add x0, x0, :lo12:usage_text
    mov x1, #0
    bl rt_write_cstr
    mov w0, #1
    b rt_done
rt_cmd_init:
    bl rt_db_open
    cbnz w0, rt_fail
    bl rt_db_close
    mov w0, wzr
    b rt_done
rt_cmd_panel:
    adrp x0, panel_text
    add x0, x0, :lo12:panel_text
    mov x1, #0
    bl rt_write_cstr
    mov w0, wzr
    b rt_done
rt_cmd_total:
    bl rt_support_total
    b rt_done
rt_cmd_order:
    bl rt_create_order
    b rt_done
rt_cmd_push:
    bl rt_process_push
    b rt_done
rt_cmd_review:
    bl rt_review_list
    b rt_done
rt_cmd_ledger:
    bl rt_ledger_list
    b rt_done
rt_cmd_run:
    bl rt_validate_config
    cbnz w0, rt_fail_config
    bl rt_service_run
    cbnz w0, rt_fail
rt_run_success:
    adrp x0, run_text
    add x0, x0, :lo12:run_text
    mov x1, #0
    bl rt_write_cstr
    mov w0, wzr
    b rt_done
rt_cmd_validate_config:
    bl rt_validate_config
    cbnz w0, rt_fail_config
    adrp x0, config_valid_text
    add x0, x0, :lo12:config_valid_text
    mov x1, #0
    bl rt_write_cstr
    mov w0, wzr
    b rt_done
rt_cmd_gateway_probe:
    bl rt_validate_config
    cbnz w0, rt_fail_config
    bl rt_gateway_probe
    b rt_done
rt_gateway_probe:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x29, sp
    adrp x0, rt_discord_token
    add x0, x0, :lo12:rt_discord_token
    mov x1, xzr
    bl yul_native_network_run
    mov w19, w0
    adrp x20, ws_stage
    add x20, x20, :lo12:ws_stage
    ldr w20, [x20]
    adrp x21, ws_error_code
    add x21, x21, :lo12:ws_error_code
    ldr w21, [x21]
    adrp x0, gateway_probe_result_prefix
    add x0, x0, :lo12:gateway_probe_result_prefix
    mov x1, xzr
    bl rt_write_cstr
    mov x0, x19
    adrp x1, rt_decimal
    add x1, x1, :lo12:rt_decimal
    mov x2, #64
    bl rt_u64_decimal
    mov x1, x0
    adrp x0, rt_decimal
    add x0, x0, :lo12:rt_decimal
    bl rt_write_cstr
    adrp x0, gateway_probe_stage_prefix
    add x0, x0, :lo12:gateway_probe_stage_prefix
    mov x1, xzr
    bl rt_write_cstr
    mov x0, x20
    adrp x1, rt_decimal
    add x1, x1, :lo12:rt_decimal
    mov x2, #64
    bl rt_u64_decimal
    mov x1, x0
    adrp x0, rt_decimal
    add x0, x0, :lo12:rt_decimal
    bl rt_write_cstr
    adrp x0, gateway_probe_error_prefix
    add x0, x0, :lo12:gateway_probe_error_prefix
    mov x1, xzr
    bl rt_write_cstr
    mov x0, x21
    adrp x1, rt_decimal
    add x1, x1, :lo12:rt_decimal
    mov x2, #64
    bl rt_u64_decimal
    mov x1, x0
    adrp x0, rt_decimal
    add x0, x0, :lo12:rt_decimal
    bl rt_write_cstr
    adrp x0, newline
    add x0, x0, :lo12:newline
    mov x1, #1
    bl rt_write_cstr
    mov w0, w19
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
rt_fail:
    adrp x0, error_text
    add x0, x0, :lo12:error_text
    mov x1, #0
    bl rt_write_cstr
    mov w0, #1
    b rt_done
rt_fail_config:
    adrp x0, config_invalid_text
    add x0, x0, :lo12:config_invalid_text
    mov x1, #0
    bl rt_write_cstr
    mov w0, #1
rt_done:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret

rt_defaults:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, default_db_path
    add x0, x0, :lo12:default_db_path
    adrp x1, rt_db_path
    add x1, x1, :lo12:rt_db_path
    bl rt_copy_cstr
    adrp x0, default_config_path
    add x0, x0, :lo12:default_config_path
    adrp x1, rt_config_path
    add x1, x1, :lo12:rt_config_path
    bl rt_copy_cstr
    adrp x0, rt_order_ttl
    add x0, x0, :lo12:rt_order_ttl
    mov x1, #1800
    str x1, [x0]
    adrp x0, rt_auto_credit
    add x0, x0, :lo12:rt_auto_credit
    mov w1, #1
    str w1, [x0]
    adrp x0, rt_case_insensitive_latin
    add x0, x0, :lo12:rt_case_insensitive_latin
    str wzr, [x0]
    adrp x0, rt_min_amount
    add x0, x0, :lo12:rt_min_amount
    str xzr, [x0]
    adrp x0, rt_max_amount
    add x0, x0, :lo12:rt_max_amount
    str xzr, [x0]
    adrp x0, rt_config_error
    add x0, x0, :lo12:rt_config_error
    str wzr, [x0]
    adrp x0, rt_discord_intents
    add x0, x0, :lo12:rt_discord_intents
    mov x1, #1
    str x1, [x0]
    adrp x0, rt_filter_package_length
    add x0, x0, :lo12:rt_filter_package_length
    str xzr, [x0]
    adrp x0, rt_filter_application_length
    add x0, x0, :lo12:rt_filter_application_length
    str xzr, [x0]
    adrp x0, rt_filter_title_length
    add x0, x0, :lo12:rt_filter_title_length
    str xzr, [x0]
    adrp x0, default_bank_amount_pattern
    add x0, x0, :lo12:default_bank_amount_pattern
    adrp x1, rt_filter_amount
    add x1, x1, :lo12:rt_filter_amount
    bl rt_copy_cstr
    adrp x0, rt_filter_amount
    add x0, x0, :lo12:rt_filter_amount
    bl rt_cstr_length
    adrp x1, rt_filter_amount_length
    add x1, x1, :lo12:rt_filter_amount_length
    str x0, [x1]
    adrp x0, default_bank_name_pattern
    add x0, x0, :lo12:default_bank_name_pattern
    adrp x1, rt_filter_name
    add x1, x1, :lo12:rt_filter_name
    bl rt_copy_cstr
    adrp x0, rt_filter_name
    add x0, x0, :lo12:rt_filter_name
    bl rt_cstr_length
    adrp x1, rt_filter_name_length
    add x1, x1, :lo12:rt_filter_name_length
    str x0, [x1]
    adrp x0, rt_filter_title_pattern_length
    add x0, x0, :lo12:rt_filter_title_pattern_length
    str xzr, [x0]
    adrp x0, default_push_stream
    add x0, x0, :lo12:default_push_stream
    adrp x1, rt_push_stream
    add x1, x1, :lo12:rt_push_stream
    bl rt_copy_cstr
    adrp x0, rt_push_stream
    add x0, x0, :lo12:rt_push_stream
    bl rt_cstr_length
    adrp x1, rt_push_stream_length
    add x1, x1, :lo12:rt_push_stream_length
    str x0, [x1]
    adrp x0, discord_gateway_url
    add x0, x0, :lo12:discord_gateway_url
    adrp x1, rt_gateway_url
    add x1, x1, :lo12:rt_gateway_url
    bl rt_copy_cstr
    adrp x0, rt_gateway_url
    add x0, x0, :lo12:rt_gateway_url
    bl rt_cstr_length
    adrp x1, rt_gateway_url_length
    add x1, x1, :lo12:rt_gateway_url_length
    str x0, [x1]
    adrp x0, rt_discord_application_length
    add x0, x0, :lo12:rt_discord_application_length
    str xzr, [x0]
    adrp x0, rt_discord_guild_length
    add x0, x0, :lo12:rt_discord_guild_length
    str xzr, [x0]
    adrp x0, rt_discord_panel_length
    add x0, x0, :lo12:rt_discord_panel_length
    str xzr, [x0]
    adrp x0, default_tag_log_channel
    add x0, x0, :lo12:default_tag_log_channel
    adrp x1, rt_discord_tag_log
    add x1, x1, :lo12:rt_discord_tag_log
    bl rt_copy_cstr
    adrp x0, rt_discord_tag_log
    add x0, x0, :lo12:rt_discord_tag_log
    bl rt_cstr_length
    adrp x1, rt_discord_tag_log_length
    add x1, x1, :lo12:rt_discord_tag_log_length
    str x0, [x1]
    adrp x0, default_tag_status_channel
    add x0, x0, :lo12:default_tag_status_channel
    adrp x1, rt_discord_tag_status
    add x1, x1, :lo12:rt_discord_tag_status
    bl rt_copy_cstr
    adrp x0, rt_discord_tag_status
    add x0, x0, :lo12:rt_discord_tag_status
    bl rt_cstr_length
    adrp x1, rt_discord_tag_status_length
    add x1, x1, :lo12:rt_discord_tag_status_length
    str x0, [x1]
    adrp x0, default_tag_role
    add x0, x0, :lo12:default_tag_role
    adrp x1, rt_discord_tag_role
    add x1, x1, :lo12:rt_discord_tag_role
    bl rt_copy_cstr
    adrp x0, rt_discord_tag_role
    add x0, x0, :lo12:rt_discord_tag_role
    bl rt_cstr_length
    adrp x1, rt_discord_tag_role_length
    add x1, x1, :lo12:rt_discord_tag_role_length
    str x0, [x1]
    adrp x0, rt_tag_status_message
    add x0, x0, :lo12:rt_tag_status_message
    strb wzr, [x0]
    adrp x0, rt_tag_status_members
    add x0, x0, :lo12:rt_tag_status_members
    strb wzr, [x0]
    adrp x0, rt_discord_admin_length
    add x0, x0, :lo12:rt_discord_admin_length
    str xzr, [x0]
    adrp x0, rt_bank_name_length
    add x0, x0, :lo12:rt_bank_name_length
    str xzr, [x0]
    adrp x0, rt_bank_account_length
    add x0, x0, :lo12:rt_bank_account_length
    str xzr, [x0]
    adrp x0, rt_bank_holder_length
    add x0, x0, :lo12:rt_bank_holder_length
    str xzr, [x0]
    ldp x29, x30, [sp], #16
    ret

rt_load_cli:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x29, sp
    adrp x19, rt_argc
    add x19, x19, :lo12:rt_argc
    ldr x19, [x19]
    adrp x20, rt_argv
    add x20, x20, :lo12:rt_argv
    ldr x20, [x20]
    mov x21, #1
rt_load_cli_loop:
    cmp x21, x19
    b.hs rt_load_cli_done
    ldr x0, [x20, x21, lsl #3]
    adrp x1, config_option
    add x1, x1, :lo12:config_option
    mov x2, #8
    bl rt_str_eq
    cbz w0, rt_load_cli_next
    add x21, x21, #1
    cmp x21, x19
    b.hs rt_load_cli_done
    ldr x0, [x20, x21, lsl #3]
    adrp x1, rt_config_path
    add x1, x1, :lo12:rt_config_path
    mov x2, #512
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_cli_done
rt_load_cli_next:
    add x21, x21, #1
    b rt_load_cli_loop
rt_load_cli_done:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

rt_find_command:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x29, sp
    adrp x19, rt_argc
    add x19, x19, :lo12:rt_argc
    ldr x19, [x19]
    adrp x20, rt_argv
    add x20, x20, :lo12:rt_argv
    ldr x20, [x20]
    adrp x21, rt_command_index
    add x21, x21, :lo12:rt_command_index
    mov x22, #-1
    str x22, [x21]
    mov x21, #1
rt_find_command_loop:
    cmp x21, x19
    b.hs rt_find_command_done
    ldr x0, [x20, x21, lsl #3]
    mov x6, x0
    adrp x1, cmd_init_db
    add x1, x1, :lo12:cmd_init_db
    mov x2, #7
    mov x0, x6
    bl rt_str_eq
    cbnz w0, rt_find_command_hit
    adrp x1, cmd_panel_text
    add x1, x1, :lo12:cmd_panel_text
    mov x2, #10
    mov x0, x6
    bl rt_str_eq
    cbnz w0, rt_find_command_hit
    adrp x1, cmd_support_total
    add x1, x1, :lo12:cmd_support_total
    mov x2, #13
    mov x0, x6
    bl rt_str_eq
    cbnz w0, rt_find_command_hit
    adrp x1, cmd_create_order
    add x1, x1, :lo12:cmd_create_order
    mov x2, #12
    mov x0, x6
    bl rt_str_eq
    cbnz w0, rt_find_command_hit
    adrp x1, cmd_process_push
    add x1, x1, :lo12:cmd_process_push
    mov x2, #12
    mov x0, x6
    bl rt_str_eq
    cbnz w0, rt_find_command_hit
    adrp x1, cmd_review_list
    add x1, x1, :lo12:cmd_review_list
    mov x2, #11
    mov x0, x6
    bl rt_str_eq
    cbnz w0, rt_find_command_hit
    adrp x1, cmd_ledger
    add x1, x1, :lo12:cmd_ledger
    mov x2, #6
    mov x0, x6
    bl rt_str_eq
    cbnz w0, rt_find_command_hit
    adrp x1, cmd_run
    add x1, x1, :lo12:cmd_run
    mov x2, #3
    mov x0, x6
    bl rt_str_eq
    cbnz w0, rt_find_command_hit
    adrp x1, cmd_validate_config
    add x1, x1, :lo12:cmd_validate_config
    mov x2, #15
    mov x0, x6
    bl rt_str_eq
    cbnz w0, rt_find_command_hit
    adrp x1, cmd_gateway_probe
    add x1, x1, :lo12:cmd_gateway_probe
    mov x2, #13
    mov x0, x6
    bl rt_str_eq
    cbnz w0, rt_find_command_hit
    add x21, x21, #1
    b rt_find_command_loop
rt_find_command_hit:
    adrp x22, rt_command_index
    add x22, x22, :lo12:rt_command_index
    str x21, [x22]
rt_find_command_done:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

rt_str_eq:
    mov x3, xzr
rt_str_eq_loop:
    cmp x3, x2
    b.hs rt_str_eq_end
    ldrb w4, [x0, x3]
    ldrb w5, [x1, x3]
    cmp w4, w5
    b.ne rt_str_eq_no
    add x3, x3, #1
    b rt_str_eq_loop
rt_str_eq_end:
    ldrb w4, [x0, x3]
    cbz w4, rt_str_eq_yes
rt_str_eq_no:
    mov w0, wzr
    ret
rt_str_eq_yes:
    mov w0, #1
    ret

rt_bytes_equal_cstring:
    mov x3, xzr
rt_bytes_equal_cstring_loop:
    ldrb w4, [x0, x3]
    ldrb w5, [x1, x3]
    cmp w4, w5
    b.ne rt_bytes_equal_cstring_no
    cbz w4, rt_bytes_equal_cstring_yes
    add x3, x3, #1
    b rt_bytes_equal_cstring_loop
rt_bytes_equal_cstring_yes:
    mov w0, #1
    ret
rt_bytes_equal_cstring_no:
    mov w0, wzr
    ret

rt_copy_cstr:
    mov x2, xzr
rt_copy_cstr_loop:
    ldrb w3, [x0, x2]
    strb w3, [x1, x2]
    add x2, x2, #1
    cbnz w3, rt_copy_cstr_loop
    ret

rt_copy_cstr_bounded:
    mov x3, xzr
    cbz x2, rt_copy_cstr_bounded_fail
rt_copy_cstr_bounded_loop:
    cmp x3, x2
    b.hs rt_copy_cstr_bounded_fail
    ldrb w4, [x0, x3]
    strb w4, [x1, x3]
    cbz w4, rt_copy_cstr_bounded_success
    add x3, x3, #1
    b rt_copy_cstr_bounded_loop
rt_copy_cstr_bounded_fail:
    strb wzr, [x1]
    mov w0, #1
    ret
rt_copy_cstr_bounded_success:
    mov w0, wzr
    ret

rt_copy_n:
    mov x3, xzr
rt_copy_n_loop:
    cmp x3, x2
    b.hs rt_copy_n_done
    ldrb w4, [x1, x3]
    strb w4, [x0, x3]
    add x3, x3, #1
    b rt_copy_n_loop
rt_copy_n_done:
    ret

rt_arg_copy:
    adrp x3, rt_argc
    add x3, x3, :lo12:rt_argc
    ldr x3, [x3]
    cmp x0, x3
    b.hs rt_arg_copy_fail
    adrp x4, rt_argv
    add x4, x4, :lo12:rt_argv
    ldr x4, [x4]
    ldr x4, [x4, x0, lsl #3]
    mov x5, xzr
rt_arg_copy_loop:
    cmp x5, x2
    b.hs rt_arg_copy_fail
    ldrb w6, [x4, x5]
    strb w6, [x1, x5]
    add x5, x5, #1
    cbnz w6, rt_arg_copy_loop
    sub x0, x5, #1
    ret
rt_arg_copy_fail:
    mov x0, #-1
    ret

rt_write_cstr:
    adrp x5, rt_service_mode
    add x5, x5, :lo12:rt_service_mode
    ldr w5, [x5]
    cbz w5, rt_write_stdout
    mov x2, x0
    cbnz x1, rt_write_capture_length_ready
    mov x4, x0
rt_write_capture_length:
    ldrb w3, [x2], #1
    cbnz w3, rt_write_capture_length
    sub x1, x2, x4
    sub x1, x1, #1
    mov x2, x4
rt_write_capture_length_ready:
    adrp x4, rt_service_message_length
    add x4, x4, :lo12:rt_service_message_length
    ldr x5, [x4]
    mov x6, #16383
    cmp x5, x6
    b.hs rt_write_capture_overflow
    sub x6, x6, x5
    cmp x1, x6
    b.hi rt_write_capture_overflow
    adrp x6, rt_service_message
    add x6, x6, :lo12:rt_service_message
    add x6, x6, x5
    mov x7, xzr
rt_write_capture_loop:
    cmp x7, x1
    b.hs rt_write_capture_done
    ldrb w8, [x2, x7]
    strb w8, [x6, x7]
    add x7, x7, #1
    b rt_write_capture_loop
rt_write_capture_done:
    add x5, x5, x1
    str x5, [x4]
    adrp x6, rt_service_message
    add x6, x6, :lo12:rt_service_message
    strb wzr, [x6, x5]
    mov w0, wzr
    b rt_write_capture_return
rt_write_capture_overflow:
    adrp x6, rt_service_message_overflow
    add x6, x6, :lo12:rt_service_message_overflow
    mov w7, #1
    str w7, [x6]
    mov w0, #1
rt_write_capture_return:
    ret
rt_write_stdout:
    mov x2, x0
    cbnz x1, rt_write_ready
    mov x4, x0
rt_write_len:
    ldrb w3, [x2], #1
    cbnz w3, rt_write_len
    sub x1, x2, x4
    sub x1, x1, #1
    mov x2, x4
rt_write_ready:
    mov x3, x1
    mov x1, x2
    mov x2, x3
    mov x0, #1
    mov x8, #64
    svc #0
    ret
rt_log_cstr:
    mov x2, x0
    cbnz x1, rt_log_ready
    mov x4, x0
rt_log_len:
    ldrb w3, [x2], #1
    cbnz w3, rt_log_len
    sub x1, x2, x4
    sub x1, x1, #1
    mov x2, x4
rt_log_ready:
    mov x3, x1
    mov x1, x2
    mov x2, x3
    mov x0, #2
    mov x8, #64
    svc #0
    ret
rt_service_log_gateway_child_status:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov w19, w0
    and w20, w19, #0x7f
    cbz w20, rt_service_log_gateway_child_exited
    adrp x0, service_gateway_child_signaled
    add x0, x0, :lo12:service_gateway_child_signaled
    mov x1, xzr
    bl rt_log_cstr
    mov w0, w20
    b rt_service_log_gateway_child_number
rt_service_log_gateway_child_exited:
    adrp x0, service_gateway_child_exited
    add x0, x0, :lo12:service_gateway_child_exited
    mov x1, xzr
    bl rt_log_cstr
    lsr w20, w19, #8
    and w20, w20, #0xff
    mov w0, w20
rt_service_log_gateway_child_number:
    adrp x1, rt_decimal
    add x1, x1, :lo12:rt_decimal
    mov x2, #64
    bl rt_u64_decimal
    mov x1, x0
    adrp x0, rt_decimal
    add x0, x0, :lo12:rt_decimal
    bl rt_log_cstr
    adrp x0, newline
    add x0, x0, :lo12:newline
    mov x1, #1
    bl rt_log_cstr
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
rt_service_log_rest_status:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, service_rest_failure
    add x0, x0, :lo12:service_rest_failure
    mov x1, xzr
    bl rt_log_cstr
    adrp x0, rest_status
    add x0, x0, :lo12:rest_status
    ldr w0, [x0]
    adrp x1, rt_decimal
    add x1, x1, :lo12:rt_decimal
    mov x2, #64
    bl rt_u64_decimal
    mov x1, x0
    adrp x0, rt_decimal
    add x0, x0, :lo12:rt_decimal
    bl rt_log_cstr
    adrp x0, service_rest_failure_curl
    add x0, x0, :lo12:service_rest_failure_curl
    mov x1, xzr
    bl rt_log_cstr
    adrp x0, rest_error_code
    add x0, x0, :lo12:rest_error_code
    ldr w0, [x0]
    adrp x1, rt_decimal
    add x1, x1, :lo12:rt_decimal
    mov x2, #64
    bl rt_u64_decimal
    mov x1, x0
    adrp x0, rt_decimal
    add x0, x0, :lo12:rt_decimal
    bl rt_log_cstr
    adrp x0, newline
    add x0, x0, :lo12:newline
    mov x1, #1
    bl rt_log_cstr
    ldp x29, x30, [sp], #16
    ret
rt_read_file:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    str x0, [sp, #16]
    str x1, [sp, #24]
    str x2, [sp, #32]
    str x3, [sp, #40]
    mov x0, #-100
    ldr x1, [sp, #16]
    mov x2, xzr
    mov x3, xzr
    mov x8, #56
    svc #0
    cmp x0, #0
    b.lt rt_read_file_fail
    mov x4, x0
    ldr x6, [sp, #32]
    sub x6, x6, #1
    mov x5, xzr
rt_read_file_data:
    cmp x5, x6
    b.hs rt_read_file_probe
    mov x0, x4
    ldr x1, [sp, #24]
    add x1, x1, x5
    sub x2, x6, x5
    mov x8, #63
    svc #0
    cmp x0, #0
    b.lt rt_read_file_close_fail
    cbz x0, rt_read_file_probe
    add x5, x5, x0
    b rt_read_file_data
rt_read_file_probe:
    mov x0, x4
    adrp x1, rt_read_probe
    add x1, x1, :lo12:rt_read_probe
    mov x2, #1
    mov x8, #63
    svc #0
    cmp x0, #0
    b.lt rt_read_file_close_fail
    cbnz x0, rt_read_file_overflow
    ldr x1, [sp, #24]
    strb wzr, [x1, x5]
    mov x0, x4
    mov x8, #57
    svc #0
    cmp x0, #0
    b.lt rt_read_file_fail
    ldr x6, [sp, #40]
    str x5, [x6]
    mov x0, xzr
    ldp x29, x30, [sp], #64
    ret
rt_read_file_overflow:
    mov x0, x4
    mov x8, #57
    svc #0
    mov x0, #-2
    ldp x29, x30, [sp], #64
    ret
rt_read_file_close_fail:
    mov x0, x4
    mov x8, #57
    svc #0
rt_read_file_fail:
    mov x0, #-1
    ldp x29, x30, [sp], #64
    ret

rt_now:
    mov x0, #0
    adrp x1, rt_timespec
    add x1, x1, :lo12:rt_timespec
    mov x8, #113
    svc #0
    adrp x0, rt_timespec
    add x0, x0, :lo12:rt_timespec
    ldr x0, [x0]
    ret

rt_parse_decimal:
    mov x3, xzr
    mov x4, #10
    mov x6, #0xcccc
    movk x6, #0xcccc, lsl #16
    movk x6, #0xcccc, lsl #32
    movk x6, #0x0ccc, lsl #48
rt_parse_decimal_loop:
    ldrb w5, [x0], #1
    cbz w5, rt_parse_decimal_done
    cmp w5, #48
    b.lo rt_parse_decimal_bad
    cmp w5, #57
    b.hi rt_parse_decimal_bad
    sub w5, w5, #48
    cmp x3, x6
    b.hi rt_parse_decimal_bad
    b.lo rt_parse_decimal_step
    cmp w5, #7
    b.hi rt_parse_decimal_bad
rt_parse_decimal_step:
    madd x3, x3, x4, x5
    b rt_parse_decimal_loop
rt_parse_decimal_done:
    mov x0, x3
    ret
rt_parse_decimal_bad:
    mov x0, #-1
    ret

rt_apply_case_insensitive_latin:
    adrp x0, rt_case_insensitive_latin
    add x0, x0, :lo12:rt_case_insensitive_latin
    ldr w0, [x0]
    cbz w0, rt_apply_case_insensitive_latin_return
    adrp x1, rt_normalized
    add x1, x1, :lo12:rt_normalized
    adrp x2, rt_normalized_length
    add x2, x2, :lo12:rt_normalized_length
    ldr x2, [x2]
    mov x3, xzr
rt_apply_case_insensitive_latin_loop:
    cmp x3, x2
    b.hs rt_apply_case_insensitive_latin_return
    ldrb w4, [x1, x3]
    cmp w4, #65
    b.lo rt_apply_case_insensitive_latin_next
    cmp w4, #90
    b.hi rt_apply_case_insensitive_latin_next
    add w4, w4, #32
    strb w4, [x1, x3]
rt_apply_case_insensitive_latin_next:
    add x3, x3, #1
    b rt_apply_case_insensitive_latin_loop
rt_apply_case_insensitive_latin_return:
    mov w0, wzr
    ret

rt_validate_ws_url:
    ldrb w1, [x0]
    cmp w1, #119
    b.ne rt_validate_ws_url_fail
    ldrb w1, [x0, #1]
    cmp w1, #115
    b.ne rt_validate_ws_url_fail
    ldrb w1, [x0, #2]
    cmp w1, #115
    b.ne rt_validate_ws_url_fail
    ldrb w1, [x0, #3]
    cmp w1, #58
    b.ne rt_validate_ws_url_fail
    ldrb w1, [x0, #4]
    cmp w1, #47
    b.ne rt_validate_ws_url_fail
    ldrb w1, [x0, #5]
    cmp w1, #47
    b.ne rt_validate_ws_url_fail
    mov w0, wzr
    ret
rt_validate_ws_url_fail:
    mov w0, #1
    ret

rt_endpoint_parse_wss_host:
    ldrb w1, [x0]
    cmp w1, #119
    b.ne rt_endpoint_parse_wss_host_fail
    ldrb w1, [x0, #1]
    cmp w1, #115
    b.ne rt_endpoint_parse_wss_host_fail
    ldrb w1, [x0, #2]
    cmp w1, #115
    b.ne rt_endpoint_parse_wss_host_fail
    ldrb w1, [x0, #3]
    cmp w1, #58
    b.ne rt_endpoint_parse_wss_host_fail
    ldrb w1, [x0, #4]
    cmp w1, #47
    b.ne rt_endpoint_parse_wss_host_fail
    ldrb w1, [x0, #5]
    cmp w1, #47
    b.ne rt_endpoint_parse_wss_host_fail
    add x4, x0, #6
    adrp x2, rt_endpoint_host
    add x2, x2, :lo12:rt_endpoint_host
    mov x3, xzr
rt_endpoint_parse_wss_host_loop:
    ldrb w5, [x4, x3]
    cbz w5, rt_endpoint_parse_wss_host_done
    cmp w5, #47
    b.eq rt_endpoint_parse_wss_host_done
    cmp w5, #63
    b.eq rt_endpoint_parse_wss_host_done
    cmp w5, #35
    b.eq rt_endpoint_parse_wss_host_done
    cmp x3, #255
    b.hs rt_endpoint_parse_wss_host_fail
    cmp w5, #65
    b.lo rt_endpoint_parse_wss_host_store
    cmp w5, #90
    b.hi rt_endpoint_parse_wss_host_store
    add w5, w5, #32
rt_endpoint_parse_wss_host_store:
    strb w5, [x2, x3]
    add x3, x3, #1
    b rt_endpoint_parse_wss_host_loop
rt_endpoint_parse_wss_host_done:
    cbz x3, rt_endpoint_parse_wss_host_fail
    strb wzr, [x2, x3]
    adrp x6, rt_endpoint_host_length
    add x6, x6, :lo12:rt_endpoint_host_length
    str x3, [x6]
    add x0, x4, x3
    ret
rt_endpoint_parse_wss_host_fail:
    mov x0, xzr
    ret

rt_endpoint_query_match_key:
    mov x3, x0
    mov x4, x1
    mov x5, x2
    mov x6, xzr
rt_endpoint_query_match_key_loop:
    cmp x6, x5
    b.hs rt_endpoint_query_match_key_separator
    ldrb w7, [x3, x6]
    cbz w7, rt_endpoint_query_match_key_fail
    ldrb w8, [x4, x6]
    cmp w7, w8
    b.ne rt_endpoint_query_match_key_fail
    add x6, x6, #1
    b rt_endpoint_query_match_key_loop
rt_endpoint_query_match_key_separator:
    ldrb w7, [x3, x5]
    cmp w7, #61
    b.ne rt_endpoint_query_match_key_fail
    add x0, x3, x5
    add x0, x0, #1
    ret
rt_endpoint_query_match_key_fail:
    mov x0, xzr
    ret

rt_endpoint_validate_query:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x9, xzr
rt_endpoint_validate_query_loop:
    mov x10, x0
    ldrb w1, [x0]
    cbz w1, rt_endpoint_validate_query_success
    adrp x1, endpoint_query_v
    add x1, x1, :lo12:endpoint_query_v
    mov x2, #1
    bl rt_endpoint_query_match_key
    cbnz x0, rt_endpoint_validate_query_v
    mov x0, x10
    adrp x1, endpoint_query_encoding
    add x1, x1, :lo12:endpoint_query_encoding
    mov x2, #8
    bl rt_endpoint_query_match_key
    cbz x0, rt_endpoint_validate_query_fail
    tbnz x9, #1, rt_endpoint_validate_query_fail
    orr x9, x9, #2
    b rt_endpoint_validate_query_value
rt_endpoint_validate_query_v:
    tbnz x9, #0, rt_endpoint_validate_query_fail
    orr x9, x9, #1
rt_endpoint_validate_query_value:
    mov x10, x0
rt_endpoint_validate_query_value_loop:
    ldrb w1, [x10]
    cbz w1, rt_endpoint_validate_query_success
    cmp w1, #38
    b.eq rt_endpoint_validate_query_delimiter
    cmp w1, #35
    b.eq rt_endpoint_validate_query_fail
    cmp w1, #32
    b.lo rt_endpoint_validate_query_fail
    add x10, x10, #1
    b rt_endpoint_validate_query_value_loop
rt_endpoint_validate_query_delimiter:
    add x0, x10, #1
    ldrb w1, [x0]
    cbz w1, rt_endpoint_validate_query_fail
    b rt_endpoint_validate_query_loop
rt_endpoint_validate_query_success:
    mov w0, wzr
    ldp x29, x30, [sp], #16
    ret
rt_endpoint_validate_query_fail:
    mov w0, #1
    ldp x29, x30, [sp], #16
    ret

rt_endpoint_validate_gateway_rest:
    ldrb w1, [x0]
    cbz w1, rt_endpoint_validate_gateway_rest_success
    cmp w1, #35
    b.eq rt_endpoint_validate_gateway_rest_fail
    cmp w1, #63
    b.eq rt_endpoint_validate_gateway_rest_query
    cmp w1, #47
    b.ne rt_endpoint_validate_gateway_rest_fail
    ldrb w1, [x0, #1]
    cbz w1, rt_endpoint_validate_gateway_rest_success
    cmp w1, #63
    b.eq rt_endpoint_validate_gateway_rest_path_query
    b rt_endpoint_validate_gateway_rest_fail
rt_endpoint_validate_gateway_rest_query:
    add x0, x0, #1
    b rt_endpoint_validate_query
rt_endpoint_validate_gateway_rest_path_query:
    add x0, x0, #2
    b rt_endpoint_validate_query
rt_endpoint_validate_gateway_rest_success:
    mov w0, wzr
    ret
rt_endpoint_validate_gateway_rest_fail:
    mov w0, #1
    ret

rt_validate_gateway_url:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    bl rt_endpoint_parse_wss_host
    cbz x0, rt_validate_gateway_url_fail
    mov x20, x0
    adrp x0, rt_endpoint_host
    add x0, x0, :lo12:rt_endpoint_host
    adrp x1, endpoint_gateway_exact
    add x1, x1, :lo12:endpoint_gateway_exact
    mov x2, #18
    bl rt_str_eq
    cbnz w0, rt_validate_gateway_url_host_ready
    adrp x1, rt_endpoint_host_length
    add x1, x1, :lo12:rt_endpoint_host_length
    ldr x1, [x1]
    cmp x1, #11
    b.ls rt_validate_gateway_url_try_com
    sub x2, x1, #11
    adrp x0, rt_endpoint_host
    add x0, x0, :lo12:rt_endpoint_host
    add x0, x0, x2
    adrp x1, endpoint_gateway_suffix_gg
    add x1, x1, :lo12:endpoint_gateway_suffix_gg
    mov x2, #11
    bl rt_str_eq
    cbnz w0, rt_validate_gateway_url_host_ready
rt_validate_gateway_url_try_com:
    adrp x1, rt_endpoint_host_length
    add x1, x1, :lo12:rt_endpoint_host_length
    ldr x1, [x1]
    cmp x1, #12
    b.ls rt_validate_gateway_url_fail
    sub x2, x1, #12
    adrp x0, rt_endpoint_host
    add x0, x0, :lo12:rt_endpoint_host
    add x0, x0, x2
    adrp x1, endpoint_gateway_suffix_com
    add x1, x1, :lo12:endpoint_gateway_suffix_com
    mov x2, #12
    bl rt_str_eq
    cbz w0, rt_validate_gateway_url_fail
rt_validate_gateway_url_host_ready:
    mov x0, x20
    bl rt_endpoint_validate_gateway_rest
    b rt_validate_gateway_url_return
rt_validate_gateway_url_fail:
    mov w0, #1
rt_validate_gateway_url_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_validate_push_url:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    bl rt_endpoint_parse_wss_host
    cbz x0, rt_validate_push_url_fail
    mov x20, x0
    adrp x0, rt_endpoint_host
    add x0, x0, :lo12:rt_endpoint_host
    adrp x1, endpoint_push_exact
    add x1, x1, :lo12:endpoint_push_exact
    mov x2, #21
    bl rt_str_eq
    cbz w0, rt_validate_push_url_fail
    mov x0, x20
    adrp x1, endpoint_push_path
    add x1, x1, :lo12:endpoint_push_path
    mov x2, #10
    bl rt_str_eq
    cbz w0, rt_validate_push_url_fail
    mov w0, wzr
    b rt_validate_push_url_return
rt_validate_push_url_fail:
    mov w0, #1
rt_validate_push_url_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_parse_bool:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    adrp x1, bool_true_1
    add x1, x1, :lo12:bool_true_1
    mov x2, #1
    bl rt_str_eq
    cbnz w0, rt_parse_bool_true
    mov x0, x19
    adrp x1, bool_true_lower
    add x1, x1, :lo12:bool_true_lower
    mov x2, #4
    bl rt_str_eq
    cbnz w0, rt_parse_bool_true
    mov x0, x19
    adrp x1, bool_true_upper
    add x1, x1, :lo12:bool_true_upper
    mov x2, #4
    bl rt_str_eq
    cbnz w0, rt_parse_bool_true
    mov x0, x19
    adrp x1, bool_yes_lower
    add x1, x1, :lo12:bool_yes_lower
    mov x2, #3
    bl rt_str_eq
    cbnz w0, rt_parse_bool_true
    mov x0, x19
    adrp x1, bool_yes_upper
    add x1, x1, :lo12:bool_yes_upper
    mov x2, #3
    bl rt_str_eq
    cbnz w0, rt_parse_bool_true
    mov x0, x19
    adrp x1, bool_false_0
    add x1, x1, :lo12:bool_false_0
    mov x2, #1
    bl rt_str_eq
    cbnz w0, rt_parse_bool_false
    mov x0, x19
    adrp x1, bool_false_lower
    add x1, x1, :lo12:bool_false_lower
    mov x2, #5
    bl rt_str_eq
    cbnz w0, rt_parse_bool_false
    mov x0, x19
    adrp x1, bool_false_upper
    add x1, x1, :lo12:bool_false_upper
    mov x2, #5
    bl rt_str_eq
    cbnz w0, rt_parse_bool_false
    mov x0, x19
    adrp x1, bool_no_lower
    add x1, x1, :lo12:bool_no_lower
    mov x2, #2
    bl rt_str_eq
    cbnz w0, rt_parse_bool_false
    mov x0, x19
    adrp x1, bool_no_upper
    add x1, x1, :lo12:bool_no_upper
    mov x2, #2
    bl rt_str_eq
    cbnz w0, rt_parse_bool_false
    mov x0, #-1
    b rt_parse_bool_return
rt_parse_bool_true:
    mov x0, #1
    b rt_parse_bool_return
rt_parse_bool_false:
    mov x0, xzr
rt_parse_bool_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_load_config:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_config_path
    add x0, x0, :lo12:rt_config_path
    adrp x1, rt_config_buffer
    add x1, x1, :lo12:rt_config_buffer
    mov x2, #32768
    adrp x3, rt_config_length
    add x3, x3, :lo12:rt_config_length
    bl rt_read_file
    cbnz x0, rt_load_config_missing
    adrp x0, key_database
    add x0, x0, :lo12:key_database
    mov x1, #13
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_ttl
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_db_path
    add x1, x1, :lo12:rt_db_path
    mov x2, #4096
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
rt_cfg_ttl:
    adrp x0, key_ttl
    add x0, x0, :lo12:key_ttl
    mov x1, #17
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_auto
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    bl rt_parse_decimal
    cmn x0, #1
    b.eq rt_cfg_auto
    adrp x1, rt_order_ttl
    add x1, x1, :lo12:rt_order_ttl
    str x0, [x1]
rt_cfg_auto:
    adrp x0, key_auto
    add x0, x0, :lo12:key_auto
    mov x1, #11
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_case
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    bl rt_parse_bool
    cmn x0, #1
    b.eq rt_cfg_case
    adrp x1, rt_auto_credit
    add x1, x1, :lo12:rt_auto_credit
    str w0, [x1]
rt_cfg_case:
    adrp x0, key_case
    add x0, x0, :lo12:key_case
    mov x1, #22
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_package
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    bl rt_parse_bool
    cmn x0, #1
    b.eq rt_cfg_package
    adrp x1, rt_case_insensitive_latin
    add x1, x1, :lo12:rt_case_insensitive_latin
    str w0, [x1]
rt_cfg_package:
    adrp x0, key_package
    add x0, x0, :lo12:key_package
    mov x1, #17
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_application
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_filter_package
    add x1, x1, :lo12:rt_filter_package
    mov x2, #256
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_filter_package
    add x0, x0, :lo12:rt_filter_package
    bl rt_cstr_length
    adrp x1, rt_filter_package_length
    add x1, x1, :lo12:rt_filter_package_length
    str x0, [x1]
rt_cfg_application:
    adrp x0, key_application
    add x0, x0, :lo12:key_application
    mov x1, #21
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_title
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_filter_application
    add x1, x1, :lo12:rt_filter_application
    mov x2, #256
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_filter_application
    add x0, x0, :lo12:rt_filter_application
    bl rt_cstr_length
    adrp x1, rt_filter_application_length
    add x1, x1, :lo12:rt_filter_application_length
    str x0, [x1]
rt_cfg_title:
    adrp x0, key_title
    add x0, x0, :lo12:key_title
    mov x1, #17
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_title_pattern
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_filter_title
    add x1, x1, :lo12:rt_filter_title
    mov x2, #1024
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_filter_title
    add x0, x0, :lo12:rt_filter_title
    bl rt_cstr_length
    adrp x1, rt_filter_title_length
    add x1, x1, :lo12:rt_filter_title_length
    str x0, [x1]
rt_cfg_title_pattern:
    adrp x0, key_title_pattern
    add x0, x0, :lo12:key_title_pattern
    mov x1, #18
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_amount_pattern
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_filter_title_pattern
    add x1, x1, :lo12:rt_filter_title_pattern
    mov x2, #2048
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_filter_title_pattern
    add x0, x0, :lo12:rt_filter_title_pattern
    bl rt_cstr_length
    adrp x1, rt_filter_title_pattern_length
    add x1, x1, :lo12:rt_filter_title_pattern_length
    str x0, [x1]
rt_cfg_amount_pattern:
    adrp x0, key_amount_pattern
    add x0, x0, :lo12:key_amount_pattern
    mov x1, #19
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_name_pattern
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_filter_amount
    add x1, x1, :lo12:rt_filter_amount
    mov x2, #4096
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_filter_amount
    add x0, x0, :lo12:rt_filter_amount
    bl rt_cstr_length
    adrp x1, rt_filter_amount_length
    add x1, x1, :lo12:rt_filter_amount_length
    str x0, [x1]
rt_cfg_name_pattern:
    adrp x0, key_name_pattern
    add x0, x0, :lo12:key_name_pattern
    mov x1, #17
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_tokens
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_filter_name
    add x1, x1, :lo12:rt_filter_name
    mov x2, #4096
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_filter_name
    add x0, x0, :lo12:rt_filter_name
    bl rt_cstr_length
    adrp x1, rt_filter_name_length
    add x1, x1, :lo12:rt_filter_name_length
    str x0, [x1]
rt_cfg_tokens:
    adrp x0, key_discord_token
    add x0, x0, :lo12:key_discord_token
    mov x1, #17
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_push_token
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_discord_token
    add x1, x1, :lo12:rt_discord_token
    mov x2, #2048
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_discord_token
    add x0, x0, :lo12:rt_discord_token
    bl rt_cstr_length
    adrp x1, rt_discord_token_length
    add x1, x1, :lo12:rt_discord_token_length
    str x0, [x1]
rt_cfg_push_token:
    adrp x0, key_pushbullet_token
    add x0, x0, :lo12:key_pushbullet_token
    mov x1, #23
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_discord_application
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_pushbullet_token
    add x1, x1, :lo12:rt_pushbullet_token
    mov x2, #2048
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_pushbullet_token
    add x0, x0, :lo12:rt_pushbullet_token
    bl rt_cstr_length
    adrp x1, rt_pushbullet_token_length
    add x1, x1, :lo12:rt_pushbullet_token_length
    str x0, [x1]
rt_cfg_discord_application:
    adrp x0, key_discord_application
    add x0, x0, :lo12:key_discord_application
    mov x1, #22
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_discord_guild
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_discord_application
    add x1, x1, :lo12:rt_discord_application
    mov x2, #128
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_discord_application
    add x0, x0, :lo12:rt_discord_application
    bl rt_cstr_length
    adrp x1, rt_discord_application_length
    add x1, x1, :lo12:rt_discord_application_length
    str x0, [x1]
rt_cfg_discord_guild:
    adrp x0, key_discord_guild
    add x0, x0, :lo12:key_discord_guild
    mov x1, #16
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_discord_panel
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_discord_guild
    add x1, x1, :lo12:rt_discord_guild
    mov x2, #128
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_discord_guild
    add x0, x0, :lo12:rt_discord_guild
    bl rt_cstr_length
    adrp x1, rt_discord_guild_length
    add x1, x1, :lo12:rt_discord_guild_length
    str x0, [x1]
rt_cfg_discord_panel:
    adrp x0, key_discord_panel
    add x0, x0, :lo12:key_discord_panel
    mov x1, #24
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_discord_tag_log
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_discord_panel
    add x1, x1, :lo12:rt_discord_panel
    mov x2, #128
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_discord_panel
    add x0, x0, :lo12:rt_discord_panel
    bl rt_cstr_length
    adrp x1, rt_discord_panel_length
    add x1, x1, :lo12:rt_discord_panel_length
    str x0, [x1]
rt_cfg_discord_tag_log:
    adrp x0, key_discord_tag_log
    add x0, x0, :lo12:key_discord_tag_log
    mov x1, #32
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_discord_tag_status
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_discord_tag_log
    add x1, x1, :lo12:rt_discord_tag_log
    mov x2, #128
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_discord_tag_log
    add x0, x0, :lo12:rt_discord_tag_log
    bl rt_cstr_length
    adrp x1, rt_discord_tag_log_length
    add x1, x1, :lo12:rt_discord_tag_log_length
    str x0, [x1]
rt_cfg_discord_tag_status:
    adrp x0, key_discord_tag_status
    add x0, x0, :lo12:key_discord_tag_status
    mov x1, #35
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_discord_tag_role
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_discord_tag_status
    add x1, x1, :lo12:rt_discord_tag_status
    mov x2, #128
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_discord_tag_status
    add x0, x0, :lo12:rt_discord_tag_status
    bl rt_cstr_length
    adrp x1, rt_discord_tag_status_length
    add x1, x1, :lo12:rt_discord_tag_status_length
    str x0, [x1]
rt_cfg_discord_tag_role:
    adrp x0, key_discord_tag_role
    add x0, x0, :lo12:key_discord_tag_role
    mov x1, #25
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_discord_admin
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_discord_tag_role
    add x1, x1, :lo12:rt_discord_tag_role
    mov x2, #128
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_discord_tag_role
    add x0, x0, :lo12:rt_discord_tag_role
    bl rt_cstr_length
    adrp x1, rt_discord_tag_role_length
    add x1, x1, :lo12:rt_discord_tag_role_length
    str x0, [x1]
rt_cfg_discord_admin:
    adrp x0, key_discord_admin
    add x0, x0, :lo12:key_discord_admin
    mov x1, #21
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_discord_intents
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_discord_admin
    add x1, x1, :lo12:rt_discord_admin
    mov x2, #128
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_discord_admin
    add x0, x0, :lo12:rt_discord_admin
    bl rt_cstr_length
    adrp x1, rt_discord_admin_length
    add x1, x1, :lo12:rt_discord_admin_length
    str x0, [x1]
rt_cfg_discord_intents:
    adrp x0, key_discord_intents
    add x0, x0, :lo12:key_discord_intents
    mov x1, #15
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_push_stream
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    bl rt_parse_decimal
    cmn x0, #1
    b.eq rt_cfg_push_stream
    adrp x1, rt_discord_intents
    add x1, x1, :lo12:rt_discord_intents
    str x0, [x1]
rt_cfg_gateway:
    adrp x0, key_discord_gateway
    add x0, x0, :lo12:key_discord_gateway
    mov x1, #19
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_push_stream
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_gateway_url
    add x1, x1, :lo12:rt_gateway_url
    mov x2, #2048
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_gateway_url
    add x0, x0, :lo12:rt_gateway_url
    bl rt_cstr_length
    adrp x1, rt_gateway_url_length
    add x1, x1, :lo12:rt_gateway_url_length
    str x0, [x1]
rt_cfg_push_stream:
    adrp x0, key_push_stream
    add x0, x0, :lo12:key_push_stream
    mov x1, #21
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_bank_name
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_push_stream
    add x1, x1, :lo12:rt_push_stream
    mov x2, #4096
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_push_stream
    add x0, x0, :lo12:rt_push_stream
    bl rt_cstr_length
    adrp x1, rt_push_stream_length
    add x1, x1, :lo12:rt_push_stream_length
    str x0, [x1]
rt_cfg_bank_name:
    adrp x0, key_bank_name
    add x0, x0, :lo12:key_bank_name
    mov x1, #9
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_bank_account
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_bank_name
    add x1, x1, :lo12:rt_bank_name
    mov x2, #512
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_bank_name
    add x0, x0, :lo12:rt_bank_name
    bl rt_cstr_length
    adrp x1, rt_bank_name_length
    add x1, x1, :lo12:rt_bank_name_length
    str x0, [x1]
rt_cfg_bank_account:
    adrp x0, key_bank_account
    add x0, x0, :lo12:key_bank_account
    mov x1, #19
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_bank_holder
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_bank_account
    add x1, x1, :lo12:rt_bank_account
    mov x2, #512
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_bank_account
    add x0, x0, :lo12:rt_bank_account
    bl rt_cstr_length
    adrp x1, rt_bank_account_length
    add x1, x1, :lo12:rt_bank_account_length
    str x0, [x1]
rt_cfg_bank_holder:
    adrp x0, key_bank_holder
    add x0, x0, :lo12:key_bank_holder
    mov x1, #19
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_min
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    adrp x1, rt_bank_holder
    add x1, x1, :lo12:rt_bank_holder
    mov x2, #512
    bl rt_copy_cstr_bounded
    cbnz w0, rt_load_config_invalid
    adrp x0, rt_bank_holder
    add x0, x0, :lo12:rt_bank_holder
    bl rt_cstr_length
    adrp x1, rt_bank_holder_length
    add x1, x1, :lo12:rt_bank_holder_length
    str x0, [x1]
rt_cfg_min:
    adrp x0, key_min
    add x0, x0, :lo12:key_min
    mov x1, #14
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_cfg_max
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    bl rt_parse_decimal
    cmn x0, #1
    b.eq rt_cfg_max
    adrp x1, rt_min_amount
    add x1, x1, :lo12:rt_min_amount
    str x0, [x1]
rt_cfg_max:
    adrp x0, key_max
    add x0, x0, :lo12:key_max
    mov x1, #14
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_load_config_done
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    bl rt_parse_decimal
    cmn x0, #1
    b.eq rt_load_config_done
    adrp x1, rt_max_amount
    add x1, x1, :lo12:rt_max_amount
    str x0, [x1]
rt_load_config_done:
    adrp x0, rt_discord_tag_log_length
    add x0, x0, :lo12:rt_discord_tag_log_length
    ldr x0, [x0]
    cbnz x0, rt_load_config_enable_tag_intent
    adrp x0, rt_discord_tag_status_length
    add x0, x0, :lo12:rt_discord_tag_status_length
    ldr x0, [x0]
    cbnz x0, rt_load_config_enable_tag_intent
    adrp x0, rt_discord_tag_role_length
    add x0, x0, :lo12:rt_discord_tag_role_length
    ldr x0, [x0]
    cbz x0, rt_load_config_return
rt_load_config_enable_tag_intent:
    adrp x0, rt_discord_intents
    add x0, x0, :lo12:rt_discord_intents
    ldr x1, [x0]
    orr x1, x1, #2
    str x1, [x0]
rt_load_config_return:
    ldp x29, x30, [sp], #16
    ret

rt_load_config_missing:
    adrp x1, rt_config_error
    add x1, x1, :lo12:rt_config_error
    mov w0, #1
    str w0, [x1]
    b rt_load_config_return

rt_load_config_invalid:
    b rt_load_config_missing

rt_validate_required:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    mov x0, x19
    mov x1, x20
    bl rt_config_lookup
    cbnz w0, rt_validate_required_fail
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    bl rt_cstr_length
    cbz x0, rt_validate_required_fail
    mov w0, wzr
    b rt_validate_required_return
rt_validate_required_fail:
    mov w0, #1
rt_validate_required_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_validate_optional_positive:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_validate_optional_positive_success
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    bl rt_cstr_length
    cbz x0, rt_validate_optional_positive_success
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    bl rt_parse_decimal
    cmn x0, #1
    b.eq rt_validate_optional_positive_fail
    cbz x0, rt_validate_optional_positive_fail
rt_validate_optional_positive_success:
    mov w0, wzr
    b rt_validate_optional_positive_return
rt_validate_optional_positive_fail:
    mov w0, #1
rt_validate_optional_positive_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_validate_ws_key:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_validate_ws_key_fail
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    cmp x20, #19
    b.eq rt_validate_ws_key_gateway
    cmp x20, #21
    b.eq rt_validate_ws_key_push
    b rt_validate_ws_key_fail
rt_validate_ws_key_gateway:
    bl rt_validate_gateway_url
    b rt_validate_ws_key_return
rt_validate_ws_key_push:
    bl rt_validate_push_url
    b rt_validate_ws_key_return
rt_validate_ws_key_fail:
    mov w0, #1
rt_validate_ws_key_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_validate_config:
    stp x29, x30, [sp, #-0x10]!
    mov x29, sp
    adrp x1, rt_config_error
    add x1, x1, :lo12:rt_config_error
    ldr w1, [x1]
    cbnz w1, rt_validate_config_fail
    bl rt_validate_config_lines
    cbnz w0, rt_validate_config_fail
    adrp x0, key_database
    add x0, x0, :lo12:key_database
    mov x1, #13
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, key_ttl
    add x0, x0, :lo12:key_ttl
    mov x1, #17
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, key_ttl
    add x0, x0, :lo12:key_ttl
    mov x1, #17
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_validate_config_fail
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    bl rt_parse_decimal
    cmn x0, #1
    b.eq rt_validate_config_fail
    cbz x0, rt_validate_config_fail
    adrp x0, key_auto
    add x0, x0, :lo12:key_auto
    mov x1, #11
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_validate_config_fail
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    bl rt_parse_bool
    cmp x0, #1
    b.ne rt_validate_config_fail
    adrp x0, key_case
    add x0, x0, :lo12:key_case
    mov x1, #22
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_validate_config_case_done
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    bl rt_parse_bool
    cmn x0, #1
    b.eq rt_validate_config_fail
rt_validate_config_case_done:
    adrp x0, key_package
    add x0, x0, :lo12:key_package
    mov x1, #17
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, key_application
    add x0, x0, :lo12:key_application
    mov x1, #21
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, key_title
    add x0, x0, :lo12:key_title
    mov x1, #17
    bl rt_validate_required
    cbnz w0, rt_validate_title_pattern
    b rt_validate_config_title_pattern_optional
rt_validate_title_pattern:
    adrp x0, key_title_pattern
    add x0, x0, :lo12:key_title_pattern
    mov x1, #18
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
rt_validate_config_title_pattern_optional:
    adrp x0, rt_filter_title_pattern_length
    add x0, x0, :lo12:rt_filter_title_pattern_length
    ldr x0, [x0]
    cbz x0, rt_validate_config_after_title
    adrp x0, rt_filter_title_pattern
    add x0, x0, :lo12:rt_filter_title_pattern
    adrp x1, rt_filter_title_pattern_length
    add x1, x1, :lo12:rt_filter_title_pattern_length
    adrp x2, title_pattern_toss
    add x2, x2, :lo12:title_pattern_toss
    mov x3, xzr
    bl rt_validate_pattern_contract
    cbnz w0, rt_validate_config_fail
rt_validate_config_after_title:
    adrp x0, key_amount_pattern
    add x0, x0, :lo12:key_amount_pattern
    mov x1, #19
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, rt_filter_amount
    add x0, x0, :lo12:rt_filter_amount
    adrp x1, rt_filter_amount_length
    add x1, x1, :lo12:rt_filter_amount_length
    adrp x2, title_amount_pattern_toss
    add x2, x2, :lo12:title_amount_pattern_toss
    adrp x3, default_bank_amount_pattern
    add x3, x3, :lo12:default_bank_amount_pattern
    bl rt_validate_pattern_contract
    cbnz w0, rt_validate_config_fail
    adrp x0, key_name_pattern
    add x0, x0, :lo12:key_name_pattern
    mov x1, #17
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, rt_filter_name
    add x0, x0, :lo12:rt_filter_name
    adrp x1, rt_filter_name_length
    add x1, x1, :lo12:rt_filter_name_length
    adrp x2, arrow_bank_name_pattern
    add x2, x2, :lo12:arrow_bank_name_pattern
    adrp x3, default_bank_name_pattern
    add x3, x3, :lo12:default_bank_name_pattern
    bl rt_validate_pattern_contract
    cbnz w0, rt_validate_config_fail
    adrp x0, key_discord_token
    add x0, x0, :lo12:key_discord_token
    mov x1, #17
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, key_pushbullet_token
    add x0, x0, :lo12:key_pushbullet_token
    mov x1, #23
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, key_discord_application
    add x0, x0, :lo12:key_discord_application
    mov x1, #22
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, key_discord_guild
    add x0, x0, :lo12:key_discord_guild
    mov x1, #16
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, key_discord_panel
    add x0, x0, :lo12:key_discord_panel
    mov x1, #24
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, key_discord_admin
    add x0, x0, :lo12:key_discord_admin
    mov x1, #21
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, key_discord_intents
    add x0, x0, :lo12:key_discord_intents
    mov x1, #15
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, key_discord_intents
    add x0, x0, :lo12:key_discord_intents
    mov x1, #15
    adrp x2, rt_config_value
    add x2, x2, :lo12:rt_config_value
    mov x3, #4096
    bl rt_config_lookup
    cbnz w0, rt_validate_config_fail
    adrp x0, rt_config_value
    add x0, x0, :lo12:rt_config_value
    bl rt_parse_decimal
    cmn x0, #1
    b.eq rt_validate_config_fail
    adrp x0, key_discord_gateway
    add x0, x0, :lo12:key_discord_gateway
    mov x1, #19
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, key_discord_gateway
    add x0, x0, :lo12:key_discord_gateway
    mov x1, #19
    bl rt_validate_ws_key
    cbnz w0, rt_validate_config_fail
    adrp x0, key_push_stream
    add x0, x0, :lo12:key_push_stream
    mov x1, #21
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, key_push_stream
    add x0, x0, :lo12:key_push_stream
    mov x1, #21
    bl rt_validate_ws_key
    cbnz w0, rt_validate_config_fail
    adrp x0, key_bank_name
    add x0, x0, :lo12:key_bank_name
    mov x1, #9
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, key_bank_account
    add x0, x0, :lo12:key_bank_account
    mov x1, #19
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, key_bank_holder
    add x0, x0, :lo12:key_bank_holder
    mov x1, #19
    bl rt_validate_required
    cbnz w0, rt_validate_config_fail
    adrp x0, key_min
    add x0, x0, :lo12:key_min
    mov x1, #14
    bl rt_validate_optional_positive
    cbnz w0, rt_validate_config_fail
    adrp x0, key_max
    add x0, x0, :lo12:key_max
    mov x1, #14
    bl rt_validate_optional_positive
    cbnz w0, rt_validate_config_fail
    adrp x0, rt_min_amount
    add x0, x0, :lo12:rt_min_amount
    ldr x1, [x0]
    adrp x0, rt_max_amount
    add x0, x0, :lo12:rt_max_amount
    ldr x0, [x0]
    cbz x1, rt_validate_config_success
    cbz x0, rt_validate_config_success
    cmp x1, x0
    b.hi rt_validate_config_fail
rt_validate_config_success:
    mov w0, wzr
    b rt_validate_config_return
rt_validate_config_fail:
    mov w0, #1
rt_validate_config_return:
    ldp x29, x30, [sp], #0x10
    ret

rt_validate_pattern_contract:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    ldr x23, [x20]
    mov x0, x21
    bl rt_cstr_length
    cmp x23, x0
    b.eq rt_validate_pattern_first_compare
    cbz x22, rt_validate_pattern_fail
    mov x0, x22
    bl rt_cstr_length
    cmp x23, x0
    b.ne rt_validate_pattern_fail
    b rt_validate_pattern_second_compare
rt_validate_pattern_first_compare:
    mov x0, x19
    mov x1, x23
    mov x2, x21
    bl rt_mem_eq
    cbnz w0, rt_validate_pattern_success
    cbz x22, rt_validate_pattern_fail
    mov x0, x22
    bl rt_cstr_length
    cmp x23, x0
    b.ne rt_validate_pattern_fail
rt_validate_pattern_second_compare:
    mov x0, x19
    mov x1, x23
    mov x2, x22
    bl rt_mem_eq
    cbnz w0, rt_validate_pattern_success
    b rt_validate_pattern_fail
rt_validate_pattern_fail:
    mov w0, #1
    b rt_validate_pattern_return
rt_validate_pattern_success:
    mov w0, wzr
rt_validate_pattern_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_cstr_length:
    mov x1, xzr
rt_cstr_length_loop:
    ldrb w2, [x0, x1]
    cbz w2, rt_cstr_length_done
    add x1, x1, #1
    b rt_cstr_length_loop
rt_cstr_length_done:
    mov x0, x1
    ret

rt_config_key_supported:
    stp x29, x30, [sp, #-80]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    adrp x21, rt_config_key_table
    add x21, x21, :lo12:rt_config_key_table
    mov x22, xzr
rt_config_key_supported_loop:
    cmp x22, #27
    b.hs rt_config_key_supported_fail
    add x23, x21, x22, lsl #4
    ldr x24, [x23]
    add x24, x24, x21
    ldr x25, [x23, #8]
    cmp x25, x20
    b.ne rt_config_key_supported_next
    mov x0, x19
    mov x1, x20
    mov x2, x24
    bl rt_mem_eq
    cbnz w0, rt_config_key_supported_success
rt_config_key_supported_next:
    add x22, x22, #1
    b rt_config_key_supported_loop
rt_config_key_supported_success:
    mov w0, #1
    b rt_config_key_supported_return
rt_config_key_supported_fail:
    mov w0, wzr
rt_config_key_supported_return:
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret

rt_validate_config_lines:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    adrp x19, rt_config_buffer
    add x19, x19, :lo12:rt_config_buffer
    adrp x20, rt_config_length
    add x20, x20, :lo12:rt_config_length
    ldr x20, [x20]
    mov x21, xzr
rt_validate_config_lines_leading:
    cmp x21, x20
    b.hs rt_validate_config_lines_success
    ldrb w0, [x19, x21]
    cmp w0, #10
    b.eq rt_validate_config_lines_newline
    cmp w0, #32
    b.eq rt_validate_config_lines_skip_leading
    cmp w0, #9
    b.eq rt_validate_config_lines_skip_leading
    cmp w0, #13
    b.eq rt_validate_config_lines_skip_leading
    cmp w0, #35
    b.eq rt_validate_config_lines_skip_comment
    mov x22, x21
rt_validate_config_lines_find_equal:
    cmp x22, x20
    b.hs rt_validate_config_lines_fail
    ldrb w0, [x19, x22]
    cmp w0, #61
    b.eq rt_validate_config_lines_equal
    cmp w0, #10
    b.eq rt_validate_config_lines_fail
    add x22, x22, #1
    b rt_validate_config_lines_find_equal
rt_validate_config_lines_equal:
    mov x23, x22
rt_validate_config_lines_trim_key:
    cmp x23, x21
    b.eq rt_validate_config_lines_fail
    sub x24, x23, #1
    ldrb w0, [x19, x24]
    cmp w0, #32
    b.eq rt_validate_config_lines_trim_key_one
    cmp w0, #9
    b.ne rt_validate_config_lines_key_ready
rt_validate_config_lines_trim_key_one:
    sub x23, x23, #1
    b rt_validate_config_lines_trim_key
rt_validate_config_lines_key_ready:
    add x0, x19, x21
    sub x1, x23, x21
    bl rt_config_key_supported
    cbz w0, rt_validate_config_lines_fail
    mov x21, x22
rt_validate_config_lines_value:
    cmp x21, x20
    b.hs rt_validate_config_lines_success
    ldrb w0, [x19, x21]
    cmp w0, #10
    b.eq rt_validate_config_lines_newline
    add x21, x21, #1
    b rt_validate_config_lines_value
rt_validate_config_lines_skip_leading:
    add x21, x21, #1
    b rt_validate_config_lines_leading
rt_validate_config_lines_skip_comment:
    cmp x21, x20
    b.hs rt_validate_config_lines_success
    ldrb w0, [x19, x21]
    cmp w0, #10
    b.eq rt_validate_config_lines_newline
    add x21, x21, #1
    b rt_validate_config_lines_skip_comment
rt_validate_config_lines_newline:
    add x21, x21, #1
    b rt_validate_config_lines_leading
rt_validate_config_lines_success:
    mov w0, wzr
    b rt_validate_config_lines_return
rt_validate_config_lines_fail:
    mov w0, #1
rt_validate_config_lines_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_config_lookup:
    adrp x4, rt_config_buffer
    add x4, x4, :lo12:rt_config_buffer
    adrp x5, rt_config_length
    add x5, x5, :lo12:rt_config_length
    ldr x5, [x5]
    mov x6, xzr
rt_config_lookup_scan:
    cmp x6, x5
    b.hs rt_config_lookup_missing
    cbz x6, rt_config_lookup_line
    ldrb w7, [x4, x6]
    cmp w7, #10
    b.ne rt_config_lookup_next
    add x6, x6, #1
rt_config_lookup_line:
    mov x12, x6
rt_config_lookup_line_leading:
    cmp x12, x5
    b.hs rt_config_lookup_missing
    ldrb w7, [x4, x12]
    cmp w7, #32
    b.eq rt_config_lookup_line_leading_one
    cmp w7, #9
    b.ne rt_config_lookup_key
rt_config_lookup_line_leading_one:
    add x12, x12, #1
    b rt_config_lookup_line_leading
rt_config_lookup_key:
    mov x8, xzr
rt_config_lookup_key_loop:
    cmp x8, x1
    b.hs rt_config_lookup_equal
    add x9, x12, x8
    cmp x9, x5
    b.hs rt_config_lookup_missing
    ldrb w10, [x4, x9]
    ldrb w11, [x0, x8]
    cmp w10, w11
    b.ne rt_config_lookup_next
    add x8, x8, #1
    b rt_config_lookup_key_loop
rt_config_lookup_equal:
    add x9, x12, x1
rt_config_lookup_key_space:
    cmp x9, x5
    b.hs rt_config_lookup_missing
    ldrb w10, [x4, x9]
    cmp w10, #32
    b.eq rt_config_lookup_key_space_one
    cmp w10, #9
    b.eq rt_config_lookup_key_space_one
    cmp w10, #61
    b.ne rt_config_lookup_next
    add x9, x9, #1
    b rt_config_lookup_skip
rt_config_lookup_key_space_one:
    add x9, x9, #1
    b rt_config_lookup_key_space
rt_config_lookup_skip:
    cmp x9, x5
    b.hs rt_config_lookup_missing
    ldrb w10, [x4, x9]
    cmp w10, #32
    b.eq rt_config_lookup_skip_one
    cmp w10, #9
    b.ne rt_config_lookup_copy
rt_config_lookup_skip_one:
    add x9, x9, #1
    b rt_config_lookup_skip
rt_config_lookup_copy:
    mov x8, xzr
rt_config_lookup_copy_loop:
    cmp x8, x3
    b.hs rt_config_lookup_missing
    cmp x9, x5
    b.hs rt_config_lookup_copy_done
    ldrb w10, [x4, x9]
    cmp w10, #10
    b.eq rt_config_lookup_copy_done
    cmp w10, #13
    b.eq rt_config_lookup_copy_done
    strb w10, [x2, x8]
    add x8, x8, #1
    add x9, x9, #1
    b rt_config_lookup_copy_loop
rt_config_lookup_copy_done:
    mov x7, x8
rt_config_lookup_trim_value:
    cbz x7, rt_config_lookup_trim_done
    sub x7, x7, #1
    ldrb w10, [x2, x7]
    cmp w10, #32
    b.eq rt_config_lookup_trim_value
    cmp w10, #9
    b.eq rt_config_lookup_trim_value
    add x7, x7, #1
rt_config_lookup_trim_done:
    strb wzr, [x2, x7]
    mov w0, wzr
    ret
rt_config_lookup_next:
    add x6, x6, #1
    b rt_config_lookup_scan
rt_config_lookup_missing:
    strb wzr, [x2]
    mov w0, #1
    ret

rt_db_migrate:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    mov x0, x19
    adrp x1, sql_native_migration_v2
    add x1, x1, :lo12:sql_native_migration_v2
    bl yul_sqlite_exec
    mov x0, x19
    adrp x1, sql_native_verify_v2
    add x1, x1, :lo12:sql_native_verify_v2
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_db_migrate_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    cbnz w0, rt_db_migrate_fail
    mov x0, x19
    adrp x1, sql_native_version_v2
    add x1, x1, :lo12:sql_native_version_v2
    bl yul_sqlite_exec
    cbnz w0, rt_db_migrate_fail
    mov x0, x19
    adrp x1, sql_native_migration_v3
    add x1, x1, :lo12:sql_native_migration_v3
    bl yul_sqlite_exec
    mov x0, x19
    adrp x1, sql_native_verify_v3
    add x1, x1, :lo12:sql_native_verify_v3
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_db_migrate_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    cbnz w0, rt_db_migrate_fail
    mov x0, x19
    adrp x1, sql_native_index_v3
    add x1, x1, :lo12:sql_native_index_v3
    bl yul_sqlite_exec
    cbnz w0, rt_db_migrate_fail
    mov x0, x19
    adrp x1, sql_native_version_v3
    add x1, x1, :lo12:sql_native_version_v3
    bl yul_sqlite_exec
    cbnz w0, rt_db_migrate_fail
    mov w0, wzr
    b rt_db_migrate_return
rt_db_migrate_fail:
    mov w0, #1
rt_db_migrate_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_db_open:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl yul_sqlite_runtime_load
    cbnz w0, rt_db_open_fail
    adrp x0, rt_db_path
    add x0, x0, :lo12:rt_db_path
    adrp x1, rt_db_handle
    add x1, x1, :lo12:rt_db_handle
    bl yul_sqlite_open
    cbnz w0, rt_db_open_unload
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, db_schema
    add x1, x1, :lo12:db_schema
    bl yul_sqlite_exec
    cbnz w0, rt_db_open_close
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    bl rt_db_migrate
    cbnz w0, rt_db_open_close
    mov w0, wzr
    b rt_db_open_return
rt_db_open_close:
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    bl yul_sqlite_close
rt_db_open_unload:
    bl yul_sqlite_runtime_unload
rt_db_open_fail:
    mov w0, #1
rt_db_open_return:
    ldp x29, x30, [sp], #16
    ret

rt_db_close:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    cbz x0, rt_db_close_unload
    bl yul_sqlite_close
    adrp x1, rt_db_handle
    add x1, x1, :lo12:rt_db_handle
    str xzr, [x1]
rt_db_close_unload:
    bl yul_sqlite_runtime_unload
    ldp x29, x30, [sp], #16
    ret

rt_create_order:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x29, sp
    adrp x19, rt_command_index
    add x19, x19, :lo12:rt_command_index
    ldr x19, [x19]
    add x0, x19, #1
    adrp x1, rt_discord_id
    add x1, x1, :lo12:rt_discord_id
    mov x2, #256
    bl rt_arg_copy
    cmn x0, #1
    b.eq rt_create_order_fail
    adrp x20, rt_discord_id_length
    add x20, x20, :lo12:rt_discord_id_length
    str x0, [x20]
    add x0, x19, #2
    adrp x1, rt_name
    add x1, x1, :lo12:rt_name
    mov x2, #512
    bl rt_arg_copy
    cmn x0, #1
    b.eq rt_create_order_fail
    adrp x20, rt_name_length
    add x20, x20, :lo12:rt_name_length
    str x0, [x20]
    add x0, x19, #3
    adrp x1, rt_amount_text
    add x1, x1, :lo12:rt_amount_text
    mov x2, #64
    bl rt_arg_copy
    cmn x0, #1
    b.eq rt_create_order_fail
    adrp x20, rt_amount_length
    add x20, x20, :lo12:rt_amount_length
    str x0, [x20]
    adrp x0, rt_amount_text
    add x0, x0, :lo12:rt_amount_text
    adrp x1, rt_amount_length
    add x1, x1, :lo12:rt_amount_length
    ldr x1, [x1]
    adrp x2, rt_amount_value
    add x2, x2, :lo12:rt_amount_value
    bl yul_parse_amount_ascii
    cbnz w0, rt_create_order_fail
    adrp x0, rt_amount_value
    add x0, x0, :lo12:rt_amount_value
    ldr x20, [x0]
    adrp x0, rt_min_amount
    add x0, x0, :lo12:rt_min_amount
    ldr x21, [x0]
    cbz x21, rt_create_order_max
    cmp x20, x21
    b.lo rt_create_order_fail
rt_create_order_max:
    adrp x0, rt_max_amount
    add x0, x0, :lo12:rt_max_amount
    ldr x21, [x0]
    cbz x21, rt_create_order_name
    cmp x20, x21
    b.hi rt_create_order_fail
rt_create_order_name:
    adrp x0, rt_name
    add x0, x0, :lo12:rt_name
    adrp x1, rt_name_length
    add x1, x1, :lo12:rt_name_length
    ldr x1, [x1]
    adrp x2, rt_normalized
    add x2, x2, :lo12:rt_normalized
    mov x3, #1024
    adrp x4, rt_normalized_length
    add x4, x4, :lo12:rt_normalized_length
    bl yul_normalize_name_utf8
    cbnz w0, rt_create_order_fail
    bl rt_apply_case_insensitive_latin
    bl rt_now
    adrp x1, rt_created_at
    add x1, x1, :lo12:rt_created_at
    str x0, [x1]
    adrp x2, rt_order_ttl
    add x2, x2, :lo12:rt_order_ttl
    ldr x2, [x2]
    add x0, x0, x2
    adrp x1, rt_expires_at
    add x1, x1, :lo12:rt_expires_at
    str x0, [x1]
    bl rt_make_order_id
    bl rt_db_open
    cbnz w0, rt_create_order_fail
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_insert_order
    add x1, x1, :lo12:sql_insert_order
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_create_order_close_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    adrp x2, rt_order_id
    add x2, x2, :lo12:rt_order_id
    mov x3, #23
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #2
    adrp x2, rt_discord_id
    add x2, x2, :lo12:rt_discord_id
    adrp x3, rt_discord_id_length
    add x3, x3, :lo12:rt_discord_id_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #3
    adrp x2, rt_name
    add x2, x2, :lo12:rt_name
    adrp x3, rt_name_length
    add x3, x3, :lo12:rt_name_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #4
    adrp x2, rt_normalized
    add x2, x2, :lo12:rt_normalized
    adrp x3, rt_normalized_length
    add x3, x3, :lo12:rt_normalized_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #5
    adrp x2, rt_amount_value
    add x2, x2, :lo12:rt_amount_value
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #6
    adrp x2, status_pending
    add x2, x2, :lo12:status_pending
    mov x3, #7
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #10
    adrp x2, rt_service_mode
    add x2, x2, :lo12:rt_service_mode
    ldr w2, [x2]
    cbz w2, rt_create_order_bind_interaction_null
    adrp x2, rt_service_interaction_id
    add x2, x2, :lo12:rt_service_interaction_id
    bl rt_cstr_length
    mov x3, x0
    adrp x2, rt_service_interaction_id
    add x2, x2, :lo12:rt_service_interaction_id
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #10
    bl yul_sqlite_bind_text
    b rt_create_order_interaction_bound
rt_create_order_bind_interaction_null:
    bl yul_sqlite_bind_null
rt_create_order_interaction_bound:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #7
    adrp x2, rt_created_at
    add x2, x2, :lo12:rt_created_at
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #8
    adrp x2, rt_expires_at
    add x2, x2, :lo12:rt_expires_at
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #9
    adrp x2, status_pending
    add x2, x2, :lo12:status_pending
    mov x3, #7
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #101
    b.ne rt_create_order_statement_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    adrp x0, rt_service_mode
    add x0, x0, :lo12:rt_service_mode
    ldr w0, [x0]
    cbz w0, rt_create_order_close_success
    bl rt_find_interaction_order
    cbnz w0, rt_create_order_close_fail
rt_create_order_close_success:
    bl rt_db_close
    adrp x0, order_created_text
    add x0, x0, :lo12:order_created_text
    mov x1, #0
    bl rt_write_cstr
    adrp x0, rt_order_id
    add x0, x0, :lo12:rt_order_id
    mov x1, #23
    bl rt_write_cstr
    adrp x0, newline
    add x0, x0, :lo12:newline
    mov x1, #1
    bl rt_write_cstr
    mov w0, wzr
    b rt_create_order_return
rt_create_order_statement_fail:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
rt_create_order_close_fail:
    bl rt_db_close
rt_create_order_fail:
    mov w0, #1
rt_create_order_return:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

rt_find_interaction_order:
    stp x29, x30, [sp, #-32]!
    str x19, [sp, #16]
    mov x29, sp
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_find_interaction_order
    add x1, x1, :lo12:sql_find_interaction_order
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_find_interaction_order_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    adrp x2, rt_service_interaction_id
    add x2, x2, :lo12:rt_service_interaction_id
    bl rt_cstr_length
    mov x3, x0
    adrp x2, rt_service_interaction_id
    add x2, x2, :lo12:rt_service_interaction_id
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #100
    b.ne rt_find_interaction_order_statement_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, xzr
    bl yul_sqlite_column_text
    adrp x1, rt_order_id
    add x1, x1, :lo12:rt_order_id
    mov x2, #128
    bl rt_copy_cstr_bounded
    cbnz w0, rt_find_interaction_order_statement_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    bl yul_sqlite_column_text
    adrp x1, rt_discord_id
    add x1, x1, :lo12:rt_discord_id
    adrp x2, rt_discord_id_length
    add x2, x2, :lo12:rt_discord_id_length
    ldr x2, [x2]
    bl rt_str_eq
    cbz w0, rt_find_interaction_order_statement_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #2
    bl yul_sqlite_column_text
    adrp x1, rt_normalized
    add x1, x1, :lo12:rt_normalized
    adrp x2, rt_normalized_length
    add x2, x2, :lo12:rt_normalized_length
    ldr x2, [x2]
    bl rt_str_eq
    cbz w0, rt_find_interaction_order_statement_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #3
    bl yul_sqlite_column_int64
    adrp x1, rt_amount_value
    add x1, x1, :lo12:rt_amount_value
    ldr x1, [x1]
    cmp x0, x1
    b.ne rt_find_interaction_order_statement_fail
    adrp x0, rt_order_dm_required
    add x0, x0, :lo12:rt_order_dm_required
    str wzr, [x0]
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #4
    bl yul_sqlite_column_text
    mov x19, x0
    adrp x1, status_sent
    add x1, x1, :lo12:status_sent
    mov x2, #4
    bl rt_str_eq
    cbnz w0, rt_find_interaction_order_status_ready
    mov x0, x19
    adrp x1, status_pending
    add x1, x1, :lo12:status_pending
    mov x2, #7
    bl rt_str_eq
    cbnz w0, rt_find_interaction_order_dm_required
    mov x0, x19
    adrp x1, status_failed
    add x1, x1, :lo12:status_failed
    mov x2, #6
    bl rt_str_eq
    cbz w0, rt_find_interaction_order_statement_fail
rt_find_interaction_order_dm_required:
    adrp x0, rt_order_dm_required
    add x0, x0, :lo12:rt_order_dm_required
    mov w1, #1
    str w1, [x0]
rt_find_interaction_order_status_ready:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    cbnz w0, rt_find_interaction_order_fail
    mov w0, wzr
    b rt_find_interaction_order_return
rt_find_interaction_order_statement_fail:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
rt_find_interaction_order_fail:
    mov w0, #1
rt_find_interaction_order_return:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_make_order_id:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_order_id
    add x0, x0, :lo12:rt_order_id
    adrp x1, order_prefix
    add x1, x1, :lo12:order_prefix
    mov x2, #7
    bl rt_copy_n
    bl rt_now
    adrp x1, rt_order_counter
    add x1, x1, :lo12:rt_order_counter
    ldr x2, [x1]
    add x2, x2, #1
    str x2, [x1]
    mov x3, x0
    mov x8, #172
    svc #0
    lsl x0, x0, #32
    add x0, x0, x3
    add x0, x0, x2
    adrp x1, rt_order_id
    add x1, x1, :lo12:rt_order_id
    add x1, x1, #7
    mov x3, #16
    bl rt_hex16
    ldp x29, x30, [sp], #16
    ret

rt_hex16:
    adrp x4, rt_hex_digits
    add x4, x4, :lo12:rt_hex_digits
    mov x5, #60
    mov x3, xzr
rt_hex16_loop:
    lsr x6, x0, x5
    and x6, x6, #15
    ldrb w7, [x4, x6]
    strb w7, [x1, x3]
    sub x5, x5, #4
    add x3, x3, #1
    cmp x5, #-4
    b.ne rt_hex16_loop
    strb wzr, [x1, x3]
    ret

rt_support_total:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    adrp x19, rt_command_index
    add x19, x19, :lo12:rt_command_index
    ldr x19, [x19]
    add x0, x19, #1
    adrp x1, rt_support_id
    add x1, x1, :lo12:rt_support_id
    mov x2, #256
    bl rt_arg_copy
    cmn x0, #1
    b.eq rt_support_total_fail
    adrp x1, rt_support_id_length
    add x1, x1, :lo12:rt_support_id_length
    str x0, [x1]
    bl rt_db_open
    cbnz w0, rt_support_total_fail
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_get_total
    add x1, x1, :lo12:sql_get_total
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_support_total_close_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    adrp x2, rt_support_id
    add x2, x2, :lo12:rt_support_id
    adrp x3, rt_support_id_length
    add x3, x3, :lo12:rt_support_id_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #100
    b.eq rt_support_total_row
    mov x0, xzr
    b rt_support_total_print
rt_support_total_row:
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x1, [x1]
    mov x0, x1
    mov x1, xzr
    bl yul_sqlite_column_int64
rt_support_total_print:
    adrp x1, rt_current_total
    add x1, x1, :lo12:rt_current_total
    str x0, [x1]
    adrp x1, rt_decimal
    add x1, x1, :lo12:rt_decimal
    mov x2, #64
    bl rt_u64_decimal
    mov x1, x0
    adrp x0, rt_decimal
    add x0, x0, :lo12:rt_decimal
    bl rt_write_cstr
    adrp x0, newline
    add x0, x0, :lo12:newline
    mov x1, #1
    bl rt_write_cstr
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
rt_support_total_close_fail:
    bl rt_db_close
    mov w0, wzr
    b rt_support_total_return
rt_support_total_fail:
    mov w0, #1
rt_support_total_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_u64_decimal:
    adrp x3, rt_decimal_tmp
    add x3, x3, :lo12:rt_decimal_tmp
    mov x4, xzr
    cbnz x0, rt_u64_decimal_loop
    mov w5, #48
    strb w5, [x1]
    mov x0, #1
    ret
rt_u64_decimal_loop:
    mov x5, #10
    udiv x6, x0, x5
    msub x7, x6, x5, x0
    add w7, w7, #48
    strb w7, [x3, x4]
    add x4, x4, #1
    mov x0, x6
    cbnz x0, rt_u64_decimal_loop
    mov x5, xzr
rt_u64_decimal_reverse:
    cmp x5, x4
    b.hs rt_u64_decimal_done
    sub x6, x4, x5
    sub x6, x6, #1
    ldrb w7, [x3, x6]
    strb w7, [x1, x5]
    add x5, x5, #1
    b rt_u64_decimal_reverse
rt_u64_decimal_done:
    strb wzr, [x1, x4]
    mov x0, x4
    ret

rt_process_push:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    adrp x19, rt_command_index
    add x19, x19, :lo12:rt_command_index
    ldr x19, [x19]
    add x0, x19, #1
    adrp x1, rt_json_path
    add x1, x1, :lo12:rt_json_path
    mov x2, #512
    bl rt_arg_copy
    cmn x0, #1
    b.eq rt_process_fail
    adrp x0, rt_json_path
    add x0, x0, :lo12:rt_json_path
    adrp x1, rt_json_buffer
    add x1, x1, :lo12:rt_json_buffer
    mov x2, #65536
    adrp x3, rt_json_length
    add x3, x3, :lo12:rt_json_length
    bl rt_read_file
    cbnz x0, rt_process_fail
    bl rt_parse_push_json
    cbnz w0, rt_process_parse_fail
    bl rt_check_filters
    cbnz w0, rt_process_unsupported
    bl rt_now
    adrp x1, rt_created_at
    add x1, x1, :lo12:rt_created_at
    str x0, [x1]
    adrp x1, rt_push_timestamp_present
    add x1, x1, :lo12:rt_push_timestamp_present
    ldr w1, [x1]
    cbnz w1, rt_process_push_event_time_ready
    adrp x1, rt_push_event_time
    add x1, x1, :lo12:rt_push_event_time
    str x0, [x1]
rt_process_push_event_time_ready:
    bl rt_db_open
    cbnz w0, rt_process_fail
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_begin
    add x1, x1, :lo12:sql_begin
    bl yul_sqlite_exec
    cbnz w0, rt_process_close_fail
    bl rt_check_duplicate
    cmp w0, #1
    b.eq rt_process_duplicate
    cmp w0, #2
    b.eq rt_process_rollback_fail
    bl rt_insert_push_received
    cbnz w0, rt_process_rollback_fail
    bl rt_credit
    cmp w0, #0
    b.eq rt_process_consumed
    cmp w0, #1
    b.eq rt_process_mark_review
    b rt_process_rollback_fail
rt_process_mark_review:
    adrp x0, rt_push_id
    add x0, x0, :lo12:rt_push_id
    adrp x1, status_review
    add x1, x1, :lo12:status_review
    bl rt_update_push_status
    cbnz w0, rt_process_rollback_fail
    bl rt_commit_close
    adrp x0, status_review
    add x0, x0, :lo12:status_review
    bl rt_print_push_result
    b rt_process_return
rt_process_consumed:
    bl rt_db_close
    adrp x0, status_consumed
    add x0, x0, :lo12:status_consumed
    bl rt_print_push_result
    b rt_process_return
rt_process_duplicate:
    bl rt_db_rollback_close
    adrp x0, status_duplicate
    add x0, x0, :lo12:status_duplicate
    bl rt_print_push_result
    b rt_process_return
rt_process_parse_fail:
    adrp x0, rt_push_id_length
    add x0, x0, :lo12:rt_push_id_length
    ldr x1, [x0]
    cbnz x1, rt_process_parse_fail_ready
    bl rt_fingerprint_push_id
rt_process_parse_fail_ready:
    adrp x0, status_parse_failed
    add x0, x0, :lo12:status_parse_failed
    adrp x1, rt_status_scratch
    add x1, x1, :lo12:rt_status_scratch
    bl rt_copy_cstr
    bl rt_record_nonpayment
    cmp w0, #2
    b.eq rt_process_nonpayment_duplicate
    cbnz w0, rt_process_fail
    adrp x0, status_parse_failed
    add x0, x0, :lo12:status_parse_failed
    bl rt_print_push_result
    b rt_process_return
rt_process_unsupported:
    adrp x0, status_unsupported
    add x0, x0, :lo12:status_unsupported
    adrp x1, rt_status_scratch
    add x1, x1, :lo12:rt_status_scratch
    bl rt_copy_cstr
    bl rt_record_nonpayment
    cmp w0, #2
    b.eq rt_process_nonpayment_duplicate
    cbnz w0, rt_process_fail
    adrp x0, status_unsupported
    add x0, x0, :lo12:status_unsupported
    bl rt_print_push_result
    b rt_process_return
rt_process_nonpayment_duplicate:
    adrp x0, status_duplicate
    add x0, x0, :lo12:status_duplicate
    bl rt_print_push_result
    b rt_process_return
rt_process_rollback_fail:
    bl rt_db_rollback_close
rt_process_close_fail:
    bl rt_db_close
rt_process_fail:
    mov w0, #1
rt_process_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_parse_push_json:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_push_id_length
    add x0, x0, :lo12:rt_push_id_length
    str xzr, [x0]
    adrp x0, rt_package_length
    add x0, x0, :lo12:rt_package_length
    str xzr, [x0]
    adrp x0, rt_application_length
    add x0, x0, :lo12:rt_application_length
    str xzr, [x0]
    adrp x0, rt_title_length
    add x0, x0, :lo12:rt_title_length
    str xzr, [x0]
    adrp x0, rt_body_length
    add x0, x0, :lo12:rt_body_length
    str xzr, [x0]
    adrp x0, rt_parsed_name_length
    add x0, x0, :lo12:rt_parsed_name_length
    str xzr, [x0]
    adrp x0, rt_normalized_length
    add x0, x0, :lo12:rt_normalized_length
    str xzr, [x0]
    adrp x0, rt_amount_length
    add x0, x0, :lo12:rt_amount_length
    str xzr, [x0]
    adrp x0, rt_amount_value
    add x0, x0, :lo12:rt_amount_value
    str xzr, [x0]
    adrp x0, rt_push_mirror_kind
    add x0, x0, :lo12:rt_push_mirror_kind
    str xzr, [x0]
    adrp x0, rt_push_root_type_present
    add x0, x0, :lo12:rt_push_root_type_present
    str xzr, [x0]
    adrp x0, rt_push_fingerprint_pending
    add x0, x0, :lo12:rt_push_fingerprint_pending
    str xzr, [x0]
    adrp x0, rt_push_created_at
    add x0, x0, :lo12:rt_push_created_at
    str xzr, [x0]
    adrp x0, rt_push_modified_at
    add x0, x0, :lo12:rt_push_modified_at
    str xzr, [x0]
    adrp x0, rt_push_event_time
    add x0, x0, :lo12:rt_push_event_time
    str xzr, [x0]
    adrp x0, rt_push_created_present
    add x0, x0, :lo12:rt_push_created_present
    str wzr, [x0]
    adrp x0, rt_push_modified_present
    add x0, x0, :lo12:rt_push_modified_present
    str wzr, [x0]
    adrp x0, rt_push_timestamp_present
    add x0, x0, :lo12:rt_push_timestamp_present
    str wzr, [x0]
    bl rt_json_validate_structure
    cbnz w0, rt_parse_push_json_fail
    adrp x0, json_key_type
    add x0, x0, :lo12:json_key_type
    mov x1, #4
    adrp x2, rt_package
    add x2, x2, :lo12:rt_package
    mov x3, #256
    bl rt_json_value
    cbz w0, rt_parse_push_json_type_found
    cmp w0, #2
    b.eq rt_parse_push_json_fail
    b rt_parse_push_json_type_missing
rt_parse_push_json_type_found:
    adrp x0, rt_json_value_length
    add x0, x0, :lo12:rt_json_value_length
    ldr x0, [x0]
    cmp x0, #4
    b.eq rt_parse_push_json_envelope
    cmp x0, #6
    b.eq rt_parse_push_json_raw_mirror
    b rt_parse_push_json_fail
rt_parse_push_json_envelope:
    adrp x0, rt_package
    add x0, x0, :lo12:rt_package
    mov x1, #4
    adrp x2, json_push_value
    add x2, x2, :lo12:json_push_value
    bl rt_mem_eq
    cbz w0, rt_parse_push_json_fail
    mov w1, #1
    adrp x0, rt_push_root_type_present
    add x0, x0, :lo12:rt_push_root_type_present
    str w1, [x0]
    bl rt_json_select_push_object
    cbnz w0, rt_parse_push_json_fail
    adrp x0, rt_json_selector_found
    add x0, x0, :lo12:rt_json_selector_found
    ldr w0, [x0]
    cbz w0, rt_parse_push_json_fail
    b rt_parse_push_json_type_nested
rt_parse_push_json_raw_mirror:
    adrp x0, json_key_type
    add x0, x0, :lo12:json_key_type
    mov x1, #4
    adrp x2, rt_package
    add x2, x2, :lo12:rt_package
    mov x3, #256
    bl rt_json_value
    cbnz w0, rt_parse_push_json_fail
    adrp x0, rt_json_value_length
    add x0, x0, :lo12:rt_json_value_length
    ldr x0, [x0]
    cmp x0, #6
    b.ne rt_parse_push_json_fail
    adrp x0, rt_package
    add x0, x0, :lo12:rt_package
    mov x1, #6
    adrp x2, json_mirror_value
    add x2, x2, :lo12:json_mirror_value
    bl rt_mem_eq
    cbz w0, rt_parse_push_json_fail
    mov w1, #1
    adrp x0, rt_push_mirror_kind
    add x0, x0, :lo12:rt_push_mirror_kind
    str w1, [x0]
    mov w1, #2
    adrp x0, rt_push_root_type_present
    add x0, x0, :lo12:rt_push_root_type_present
    str w1, [x0]
    b rt_parse_push_json_type_ready
rt_parse_push_json_type_missing:
    b rt_parse_push_json_fail
rt_parse_push_json_type_nested:
    adrp x0, json_key_type
    add x0, x0, :lo12:json_key_type
    mov x1, #4
    adrp x2, rt_package
    add x2, x2, :lo12:rt_package
    mov x3, #256
    bl rt_json_value
    cbnz w0, rt_parse_push_json_fail
    adrp x0, rt_json_value_length
    add x0, x0, :lo12:rt_json_value_length
    ldr x0, [x0]
    cmp x0, #6
    b.ne rt_parse_push_json_fail
    adrp x0, rt_package
    add x0, x0, :lo12:rt_package
    mov x1, #6
    adrp x2, json_mirror_value
    add x2, x2, :lo12:json_mirror_value
    bl rt_mem_eq
    cbz w0, rt_parse_push_json_fail
    mov w1, #1
    adrp x0, rt_push_mirror_kind
    add x0, x0, :lo12:rt_push_mirror_kind
    str w1, [x0]
    b rt_parse_push_json_type_ready
rt_parse_push_json_type_ready:
    adrp x0, json_key_id
    add x0, x0, :lo12:json_key_id
    mov x1, #4
    adrp x2, rt_push_id
    add x2, x2, :lo12:rt_push_id
    mov x3, #256
    bl rt_json_value
    cbz w0, rt_parse_push_json_id_value_ready
    cmp w0, #2
    b.eq rt_parse_push_json_id_invalid
    b rt_parse_push_json_id_fingerprint
rt_parse_push_json_id_value_ready:
    adrp x1, rt_json_value_length
    add x1, x1, :lo12:rt_json_value_length
    ldr x2, [x1]
    cbz x2, rt_parse_push_json_id_empty
    adrp x3, rt_push_id
    add x3, x3, :lo12:rt_push_id
    mov x4, xzr
rt_parse_push_json_id_blank_loop:
    cmp x4, x2
    b.hs rt_parse_push_json_id_whitespace
    ldrb w5, [x3, x4]
    cmp w5, #32
    b.eq rt_parse_push_json_id_blank_next
    cmp w5, #9
    b.eq rt_parse_push_json_id_blank_next
    cmp w5, #10
    b.eq rt_parse_push_json_id_blank_next
    cmp w5, #13
    b.ne rt_parse_push_json_id_ready
rt_parse_push_json_id_blank_next:
    add x4, x4, #1
    b rt_parse_push_json_id_blank_loop
rt_parse_push_json_id_empty:
    adrp x0, rt_push_root_type_present
    add x0, x0, :lo12:rt_push_root_type_present
    ldr x0, [x0]
    cmp x0, #2
    b.eq rt_parse_push_json_id_invalid
    b rt_parse_push_json_id_fingerprint
rt_parse_push_json_id_whitespace:
    adrp x0, rt_push_root_type_present
    add x0, x0, :lo12:rt_push_root_type_present
    ldr x0, [x0]
    cmp x0, #2
    b.eq rt_parse_push_json_id_invalid
    b rt_parse_push_json_id_fingerprint
rt_parse_push_json_id_invalid:
    adrp x0, rt_push_mirror_kind
    add x0, x0, :lo12:rt_push_mirror_kind
    mov w1, #2
    str w1, [x0]
    bl rt_fingerprint_push_id
    cbnz w0, rt_parse_push_json_fail
    b rt_parse_push_json_fail
rt_parse_push_json_id_fingerprint:
    adrp x0, rt_push_fingerprint_pending
    add x0, x0, :lo12:rt_push_fingerprint_pending
    mov x1, #1
    str x1, [x0]
    b rt_parse_push_json_id_fields_ready
rt_parse_push_json_id_ready:
    adrp x1, rt_push_id_length
    add x1, x1, :lo12:rt_push_id_length
    adrp x2, rt_json_value_length
    add x2, x2, :lo12:rt_json_value_length
    ldr x2, [x2]
    str x2, [x1]
rt_parse_push_json_id_fields_ready:
    adrp x0, json_key_package
    add x0, x0, :lo12:json_key_package
    mov x1, #12
    adrp x2, rt_package
    add x2, x2, :lo12:rt_package
    mov x3, #256
    bl rt_json_value
    cbnz w0, rt_parse_push_json_fail
    adrp x1, rt_package_length
    add x1, x1, :lo12:rt_package_length
    adrp x2, rt_json_value_length
    add x2, x2, :lo12:rt_json_value_length
    ldr x2, [x2]
    str x2, [x1]
    adrp x0, json_key_application
    add x0, x0, :lo12:json_key_application
    mov x1, #16
    adrp x2, rt_application
    add x2, x2, :lo12:rt_application
    mov x3, #256
    bl rt_json_value
    cbnz w0, rt_parse_push_json_fail
    adrp x1, rt_application_length
    add x1, x1, :lo12:rt_application_length
    adrp x2, rt_json_value_length
    add x2, x2, :lo12:rt_json_value_length
    ldr x2, [x2]
    str x2, [x1]
    adrp x0, json_key_title
    add x0, x0, :lo12:json_key_title
    mov x1, #5
    adrp x2, rt_title
    add x2, x2, :lo12:rt_title
    mov x3, #1024
    bl rt_json_value
    cbnz w0, rt_parse_push_json_fail
    adrp x1, rt_title_length
    add x1, x1, :lo12:rt_title_length
    adrp x2, rt_json_value_length
    add x2, x2, :lo12:rt_json_value_length
    ldr x2, [x2]
    str x2, [x1]
    adrp x0, json_key_body
    add x0, x0, :lo12:json_key_body
    mov x1, #4
    adrp x2, rt_body
    add x2, x2, :lo12:rt_body
    mov x3, #16384
    bl rt_json_value
    cbnz w0, rt_parse_push_json_fail
    adrp x1, rt_body_length
    add x1, x1, :lo12:rt_body_length
    adrp x2, rt_json_value_length
    add x2, x2, :lo12:rt_json_value_length
    ldr x2, [x2]
    str x2, [x1]
    bl rt_extract_name
    cbnz w0, rt_parse_push_json_fail
    bl rt_extract_amount
    cbnz w0, rt_parse_push_json_fail
    bl rt_parse_push_timestamps
    cbnz w0, rt_parse_push_json_fail
    adrp x0, rt_push_fingerprint_pending
    add x0, x0, :lo12:rt_push_fingerprint_pending
    ldr x0, [x0]
    cbz x0, rt_parse_push_json_fingerprint_ready
    bl rt_fingerprint_push_id
    cbnz w0, rt_parse_push_json_fail
rt_parse_push_json_fingerprint_ready:
    mov w0, wzr
    b rt_parse_push_json_return
rt_parse_push_json_fail:
    mov w0, #1
rt_parse_push_json_return:
    ldp x29, x30, [sp], #16
    ret

rt_parse_push_timestamps:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    adrp x19, rt_json_buffer
    add x19, x19, :lo12:rt_json_buffer
    adrp x20, rt_json_length
    add x20, x20, :lo12:rt_json_length
    ldr x20, [x20]
    mov x0, x19
    mov x1, x20
    adrp x2, json_created_key
    add x2, x2, :lo12:json_created_key
    mov x3, #10
    bl native_json_find_root_pattern
    cbnz x0, rt_parse_push_created_value
    mov x0, x19
    mov x1, x20
    adrp x2, json_created_name
    add x2, x2, :lo12:json_created_name
    mov x3, #9
    bl native_json_find_root_pattern
    cbnz x0, rt_parse_push_timestamps_fail
    b rt_parse_push_modified_start
rt_parse_push_created_value:
    mov x0, x19
    mov x1, x20
    adrp x2, json_created_key
    add x2, x2, :lo12:json_created_key
    mov x3, #10
    bl native_json_find_root_decimal_scaled
    cmn x0, #1
    b.eq rt_parse_push_timestamps_fail
    mov x1, #0x4240
    movk x1, #0xf, lsl #16
    udiv x0, x0, x1
    adrp x1, rt_push_created_at
    add x1, x1, :lo12:rt_push_created_at
    str x0, [x1]
    adrp x1, rt_push_event_time
    add x1, x1, :lo12:rt_push_event_time
    str x0, [x1]
    mov w2, #1
    adrp x1, rt_push_created_present
    add x1, x1, :lo12:rt_push_created_present
    str w2, [x1]
    adrp x1, rt_push_timestamp_present
    add x1, x1, :lo12:rt_push_timestamp_present
    str w2, [x1]
rt_parse_push_modified_start:
    mov x0, x19
    mov x1, x20
    adrp x2, json_modified_key
    add x2, x2, :lo12:json_modified_key
    mov x3, #11
    bl native_json_find_root_pattern
    cbnz x0, rt_parse_push_modified_value
    mov x0, x19
    mov x1, x20
    adrp x2, json_modified_name
    add x2, x2, :lo12:json_modified_name
    mov x3, #10
    bl native_json_find_root_pattern
    cbnz x0, rt_parse_push_timestamps_fail
    b rt_parse_push_timestamps_success
rt_parse_push_modified_value:
    mov x0, x19
    mov x1, x20
    adrp x2, json_modified_key
    add x2, x2, :lo12:json_modified_key
    mov x3, #11
    bl native_json_find_root_decimal_scaled
    cmn x0, #1
    b.eq rt_parse_push_timestamps_fail
    mov x1, #0x4240
    movk x1, #0xf, lsl #16
    udiv x0, x0, x1
    adrp x1, rt_push_modified_at
    add x1, x1, :lo12:rt_push_modified_at
    str x0, [x1]
    mov w2, #1
    adrp x1, rt_push_modified_present
    add x1, x1, :lo12:rt_push_modified_present
    str w2, [x1]
    adrp x1, rt_push_created_present
    add x1, x1, :lo12:rt_push_created_present
    ldr w1, [x1]
    cbnz w1, rt_parse_push_timestamps_success
    adrp x1, rt_push_event_time
    add x1, x1, :lo12:rt_push_event_time
    str x0, [x1]
    adrp x1, rt_push_timestamp_present
    add x1, x1, :lo12:rt_push_timestamp_present
    str w2, [x1]
rt_parse_push_timestamps_success:
    mov w0, wzr
    b rt_parse_push_timestamps_return
rt_parse_push_timestamps_fail:
    mov w0, #1
rt_parse_push_timestamps_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_json_validate_structure:
    stp x29, x30, [sp, #-96]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x29, sp
    adrp x19, rt_json_buffer
    add x19, x19, :lo12:rt_json_buffer
    adrp x20, rt_json_length
    add x20, x20, :lo12:rt_json_length
    ldr x20, [x20]
    mov x21, xzr
    mov x22, xzr
    mov x23, xzr
    mov x24, xzr
    adrp x26, rt_json_structure_stack
    add x26, x26, :lo12:rt_json_structure_stack
rt_json_validate_loop:
    cmp x21, x20
    b.hs rt_json_validate_done
    ldrb w0, [x19, x21]
    cmp w0, #32
    b.eq rt_json_validate_next
    cmp w0, #9
    b.eq rt_json_validate_next
    cmp w0, #10
    b.eq rt_json_validate_next
    cmp w0, #13
    b.eq rt_json_validate_next
    cbz x22, rt_json_validate_root
    sub x27, x22, #1
    ldrb w1, [x26, x27]
    cmp w1, #1
    b.eq rt_json_validate_object_key_or_end
    cmp w1, #2
    b.eq rt_json_validate_object_key_required
    cmp w1, #3
    b.eq rt_json_validate_object_colon
    cmp w1, #4
    b.eq rt_json_validate_value
    cmp w1, #5
    b.eq rt_json_validate_object_comma_or_end
    cmp w1, #6
    b.eq rt_json_validate_value_or_end
    cmp w1, #7
    b.eq rt_json_validate_value_required
    cmp w1, #8
    b.eq rt_json_validate_array_comma_or_end
    b rt_json_validate_fail
rt_json_validate_root:
    cbnz x23, rt_json_validate_fail
    b rt_json_validate_value
rt_json_validate_object_key_or_end:
    cmp w0, #125
    b.eq rt_json_validate_close_object
rt_json_validate_object_key_required:
    cmp w0, #34
    b.ne rt_json_validate_fail
    mov x24, #1
    add x21, x21, #1
    b rt_json_validate_string_loop
rt_json_validate_object_colon:
    cmp w0, #58
    b.ne rt_json_validate_fail
    mov w1, #4
    strb w1, [x26, x27]
    add x21, x21, #1
    b rt_json_validate_loop
rt_json_validate_object_comma_or_end:
    cmp w0, #44
    b.eq rt_json_validate_object_comma
    cmp w0, #125
    b.eq rt_json_validate_close_object
    b rt_json_validate_fail
rt_json_validate_object_comma:
    mov w1, #2
    strb w1, [x26, x27]
    add x21, x21, #1
    b rt_json_validate_loop
rt_json_validate_value_or_end:
    cmp w0, #93
    b.eq rt_json_validate_close_array
    b rt_json_validate_value
rt_json_validate_value_required:
    b rt_json_validate_value
rt_json_validate_array_comma_or_end:
    cmp w0, #44
    b.eq rt_json_validate_array_comma
    cmp w0, #93
    b.eq rt_json_validate_close_array
    b rt_json_validate_fail
rt_json_validate_array_comma:
    mov w1, #7
    strb w1, [x26, x27]
    add x21, x21, #1
    b rt_json_validate_loop
rt_json_validate_value:
    cmp w0, #34
    b.eq rt_json_validate_value_string
    cmp w0, #123
    b.eq rt_json_validate_open_object
    cmp w0, #91
    b.eq rt_json_validate_open_array
    cmp w0, #45
    b.eq rt_json_validate_number
    cmp w0, #48
    b.lo rt_json_validate_value_literal
    cmp w0, #57
    b.ls rt_json_validate_number
    b rt_json_validate_value_literal
rt_json_validate_value_string:
    mov x24, #2
    add x21, x21, #1
    b rt_json_validate_string_loop
rt_json_validate_open_object:
    cmp x22, #255
    b.hs rt_json_validate_fail
    mov w1, #1
    strb w1, [x26, x22]
    add x22, x22, #1
    add x21, x21, #1
    b rt_json_validate_loop
rt_json_validate_open_array:
    cmp x22, #255
    b.hs rt_json_validate_fail
    mov w1, #6
    strb w1, [x26, x22]
    add x22, x22, #1
    add x21, x21, #1
    b rt_json_validate_loop
rt_json_validate_string_loop:
    cmp x21, x20
    b.hs rt_json_validate_fail
    ldrb w0, [x19, x21]
    cmp w0, #92
    b.eq rt_json_validate_string_escape
    cmp w0, #34
    b.eq rt_json_validate_string_close
    cmp w0, #32
    b.lo rt_json_validate_fail
    add x21, x21, #1
    b rt_json_validate_string_loop
rt_json_validate_string_escape:
    add x21, x21, #1
    cmp x21, x20
    b.hs rt_json_validate_fail
    ldrb w0, [x19, x21]
    cmp w0, #34
    b.eq rt_json_validate_string_escape_one
    cmp w0, #47
    b.eq rt_json_validate_string_escape_one
    cmp w0, #92
    b.eq rt_json_validate_string_escape_one
    cmp w0, #98
    b.eq rt_json_validate_string_escape_one
    cmp w0, #102
    b.eq rt_json_validate_string_escape_one
    cmp w0, #110
    b.eq rt_json_validate_string_escape_one
    cmp w0, #114
    b.eq rt_json_validate_string_escape_one
    cmp w0, #116
    b.eq rt_json_validate_string_escape_one
    cmp w0, #117
    b.eq rt_json_validate_unicode_escape
    b rt_json_validate_fail
rt_json_validate_string_escape_one:
    add x21, x21, #1
    b rt_json_validate_string_loop
rt_json_validate_unicode_escape:
    add x21, x21, #1
    mov x27, #4
rt_json_validate_unicode_loop:
    cmp x21, x20
    b.hs rt_json_validate_fail
    ldrb w0, [x19, x21]
    cmp w0, #48
    b.lo rt_json_validate_unicode_alpha
    cmp w0, #57
    b.ls rt_json_validate_unicode_digit
rt_json_validate_unicode_alpha:
    cmp w0, #65
    b.lo rt_json_validate_unicode_lower
    cmp w0, #70
    b.ls rt_json_validate_unicode_digit
rt_json_validate_unicode_lower:
    cmp w0, #97
    b.lo rt_json_validate_fail
    cmp w0, #102
    b.hi rt_json_validate_fail
rt_json_validate_unicode_digit:
    add x21, x21, #1
    subs x27, x27, #1
    b.ne rt_json_validate_unicode_loop
    b rt_json_validate_string_loop
rt_json_validate_string_close:
    add x21, x21, #1
    cmp x24, #1
    b.eq rt_json_validate_key_close
    b rt_json_validate_complete_value
rt_json_validate_key_close:
    cbz x22, rt_json_validate_fail
    sub x27, x22, #1
    mov w1, #3
    strb w1, [x26, x27]
    b rt_json_validate_loop
rt_json_validate_close_object:
    cbz x22, rt_json_validate_fail
    sub x27, x22, #1
    ldrb w1, [x26, x27]
    cmp w1, #1
    b.eq rt_json_validate_close_object_ok
    cmp w1, #5
    b.ne rt_json_validate_fail
rt_json_validate_close_object_ok:
    sub x22, x22, #1
    add x21, x21, #1
    b rt_json_validate_complete_value
rt_json_validate_close_array:
    cbz x22, rt_json_validate_fail
    sub x27, x22, #1
    ldrb w1, [x26, x27]
    cmp w1, #6
    b.eq rt_json_validate_close_array_ok
    cmp w1, #8
    b.ne rt_json_validate_fail
rt_json_validate_close_array_ok:
    sub x22, x22, #1
    add x21, x21, #1
    b rt_json_validate_complete_value
rt_json_validate_complete_value:
    cbz x22, rt_json_validate_root_complete
    sub x27, x22, #1
    ldrb w1, [x26, x27]
    cmp w1, #4
    b.eq rt_json_validate_complete_object_value
    cmp w1, #6
    b.eq rt_json_validate_complete_array_value
    cmp w1, #7
    b.eq rt_json_validate_complete_array_value
    b rt_json_validate_fail
rt_json_validate_complete_object_value:
    mov w1, #5
    strb w1, [x26, x27]
    b rt_json_validate_loop
rt_json_validate_complete_array_value:
    mov w1, #8
    strb w1, [x26, x27]
    b rt_json_validate_loop
rt_json_validate_root_complete:
    mov x23, #1
    b rt_json_validate_loop
rt_json_validate_number:
    ldrb w0, [x19, x21]
    cmp w0, #45
    b.ne rt_json_validate_number_integer
    add x21, x21, #1
    cmp x21, x20
    b.hs rt_json_validate_fail
rt_json_validate_number_integer:
    ldrb w0, [x19, x21]
    cmp w0, #48
    b.eq rt_json_validate_number_zero
    cmp w0, #49
    b.lo rt_json_validate_fail
    cmp w0, #57
    b.hi rt_json_validate_fail
    add x21, x21, #1
rt_json_validate_number_digits:
    cmp x21, x20
    b.hs rt_json_validate_number_after_integer
    ldrb w0, [x19, x21]
    cmp w0, #48
    b.lo rt_json_validate_number_after_integer
    cmp w0, #57
    b.hi rt_json_validate_number_after_integer
    add x21, x21, #1
    b rt_json_validate_number_digits
rt_json_validate_number_zero:
    add x21, x21, #1
    cmp x21, x20
    b.hs rt_json_validate_number_after_integer
    ldrb w0, [x19, x21]
    cmp w0, #48
    b.lo rt_json_validate_number_after_integer
    cmp w0, #57
    b.ls rt_json_validate_fail
rt_json_validate_number_after_integer:
    cmp x21, x20
    b.hs rt_json_validate_complete_value
    ldrb w0, [x19, x21]
    cmp w0, #46
    b.eq rt_json_validate_number_fraction
    cmp w0, #101
    b.eq rt_json_validate_number_exponent
    cmp w0, #69
    b.eq rt_json_validate_number_exponent
    b rt_json_validate_complete_value
rt_json_validate_number_fraction:
    add x21, x21, #1
    cmp x21, x20
    b.hs rt_json_validate_fail
    ldrb w0, [x19, x21]
    cmp w0, #48
    b.lo rt_json_validate_fail
    cmp w0, #57
    b.hi rt_json_validate_fail
    add x21, x21, #1
rt_json_validate_fraction_digits:
    cmp x21, x20
    b.hs rt_json_validate_number_after_fraction
    ldrb w0, [x19, x21]
    cmp w0, #48
    b.lo rt_json_validate_number_after_fraction
    cmp w0, #57
    b.hi rt_json_validate_number_after_fraction
    add x21, x21, #1
    b rt_json_validate_fraction_digits
rt_json_validate_number_after_fraction:
    cmp x21, x20
    b.hs rt_json_validate_complete_value
    ldrb w0, [x19, x21]
    cmp w0, #101
    b.eq rt_json_validate_number_exponent
    cmp w0, #69
    b.eq rt_json_validate_number_exponent
    b rt_json_validate_complete_value
rt_json_validate_number_exponent:
    add x21, x21, #1
    cmp x21, x20
    b.hs rt_json_validate_fail
    ldrb w0, [x19, x21]
    cmp w0, #43
    b.eq rt_json_validate_number_exponent_sign
    cmp w0, #45
    b.eq rt_json_validate_number_exponent_sign
    b rt_json_validate_number_exponent_digit
rt_json_validate_number_exponent_sign:
    add x21, x21, #1
    cmp x21, x20
    b.hs rt_json_validate_fail
rt_json_validate_number_exponent_digit:
    ldrb w0, [x19, x21]
    cmp w0, #48
    b.lo rt_json_validate_fail
    cmp w0, #57
    b.hi rt_json_validate_fail
    add x21, x21, #1
rt_json_validate_exponent_digits:
    cmp x21, x20
    b.hs rt_json_validate_complete_value
    ldrb w0, [x19, x21]
    cmp w0, #48
    b.lo rt_json_validate_complete_value
    cmp w0, #57
    b.hi rt_json_validate_complete_value
    add x21, x21, #1
    b rt_json_validate_exponent_digits
rt_json_validate_value_literal:
    cmp w0, #116
    b.eq rt_json_validate_true
    cmp w0, #102
    b.eq rt_json_validate_false
    cmp w0, #110
    b.eq rt_json_validate_null
    b rt_json_validate_fail
rt_json_validate_true:
    add x27, x21, #4
    cmp x27, x20
    b.hi rt_json_validate_fail
    ldrb w0, [x19, x21]
    cmp w0, #116
    b.ne rt_json_validate_fail
    add x27, x21, #1
    ldrb w0, [x19, x27]
    cmp w0, #114
    b.ne rt_json_validate_fail
    add x27, x27, #1
    ldrb w0, [x19, x27]
    cmp w0, #117
    b.ne rt_json_validate_fail
    add x27, x27, #1
    ldrb w0, [x19, x27]
    cmp w0, #101
    b.ne rt_json_validate_fail
    add x21, x21, #4
    b rt_json_validate_complete_value
rt_json_validate_false:
    add x27, x21, #5
    cmp x27, x20
    b.hi rt_json_validate_fail
    ldrb w0, [x19, x21]
    cmp w0, #102
    b.ne rt_json_validate_fail
    add x27, x21, #1
    ldrb w0, [x19, x27]
    cmp w0, #97
    b.ne rt_json_validate_fail
    add x27, x27, #1
    ldrb w0, [x19, x27]
    cmp w0, #108
    b.ne rt_json_validate_fail
    add x27, x27, #1
    ldrb w0, [x19, x27]
    cmp w0, #115
    b.ne rt_json_validate_fail
    add x27, x27, #1
    ldrb w0, [x19, x27]
    cmp w0, #101
    b.ne rt_json_validate_fail
    add x21, x21, #5
    b rt_json_validate_complete_value
rt_json_validate_null:
    add x27, x21, #4
    cmp x27, x20
    b.hi rt_json_validate_fail
    ldrb w0, [x19, x21]
    cmp w0, #110
    b.ne rt_json_validate_fail
    add x27, x21, #1
    ldrb w0, [x19, x27]
    cmp w0, #117
    b.ne rt_json_validate_fail
    add x27, x27, #1
    ldrb w0, [x19, x27]
    cmp w0, #108
    b.ne rt_json_validate_fail
    add x27, x27, #1
    ldrb w0, [x19, x27]
    cmp w0, #108
    b.ne rt_json_validate_fail
    add x21, x21, #4
    b rt_json_validate_complete_value
rt_json_validate_next:
    add x21, x21, #1
    b rt_json_validate_loop
rt_json_validate_done:
    cbnz x22, rt_json_validate_fail
    cbz x23, rt_json_validate_fail
    mov w0, wzr
    b rt_json_validate_return
rt_json_validate_fail:
    mov w0, #1
rt_json_validate_return:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret

rt_json_select_push_object:
    adrp x0, json_key_push_object
    add x0, x0, :lo12:json_key_push_object
    mov x1, #4
    b rt_json_select_named_object

rt_json_select_named_object:
    stp x29, x30, [sp, #-96]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x29, sp
    mov x16, x0
    mov x17, x1
    adrp x0, rt_json_selector_found
    add x0, x0, :lo12:rt_json_selector_found
    str xzr, [x0]
    adrp x19, rt_json_buffer
    add x19, x19, :lo12:rt_json_buffer
    adrp x20, rt_json_length
    add x20, x20, :lo12:rt_json_length
    ldr x20, [x20]
    mov x21, xzr
    mov x22, xzr
rt_json_select_start:
    cmp x21, x20
    b.hs rt_json_select_return
    ldrb w0, [x19, x21]
    cmp w0, #32
    b.eq rt_json_select_skip
    cmp w0, #9
    b.eq rt_json_select_skip
    cmp w0, #10
    b.eq rt_json_select_skip
    cmp w0, #13
    b.eq rt_json_select_skip
    cmp w0, #123
    b.ne rt_json_select_fail
    mov x22, #1
    add x21, x21, #1
    b rt_json_select_loop
rt_json_select_skip:
    add x21, x21, #1
    b rt_json_select_start
rt_json_select_loop:
    cmp x21, x20
    b.hs rt_json_select_fail
    ldrb w0, [x19, x21]
    cmp w0, #34
    b.eq rt_json_select_string
    cmp w0, #123
    b.eq rt_json_select_open
    cmp w0, #91
    b.eq rt_json_select_open
    cmp w0, #125
    b.eq rt_json_select_close
    cmp w0, #93
    b.eq rt_json_select_close
    add x21, x21, #1
    b rt_json_select_loop
rt_json_select_open:
    add x22, x22, #1
    add x21, x21, #1
    b rt_json_select_loop
rt_json_select_close:
    cbz x22, rt_json_select_fail
    sub x22, x22, #1
    cbz x22, rt_json_select_return
    add x21, x21, #1
    b rt_json_select_loop
rt_json_select_string:
    add x24, x21, #1
    mov x25, x24
rt_json_select_string_loop:
    cmp x25, x20
    b.hs rt_json_select_fail
    ldrb w0, [x19, x25]
    cmp w0, #92
    b.eq rt_json_select_string_escape
    cmp w0, #34
    b.eq rt_json_select_string_closed
    add x25, x25, #1
    b rt_json_select_string_loop
rt_json_select_string_escape:
    add x25, x25, #2
    b rt_json_select_string_loop
rt_json_select_string_closed:
    cmp x22, #1
    b.ne rt_json_select_string_continue
    sub x26, x25, x24
    cmp x26, x17
    b.ne rt_json_select_string_continue
    add x0, x19, x24
    mov x1, x17
    mov x2, x16
    bl rt_mem_eq
    cbz w0, rt_json_select_string_continue
    add x27, x25, #1
rt_json_select_push_space:
    cmp x27, x20
    b.hs rt_json_select_fail
    ldrb w0, [x19, x27]
    cmp w0, #32
    b.eq rt_json_select_push_space_one
    cmp w0, #9
    b.eq rt_json_select_push_space_one
    cmp w0, #10
    b.eq rt_json_select_push_space_one
    cmp w0, #13
    b.ne rt_json_select_push_colon
rt_json_select_push_space_one:
    add x27, x27, #1
    b rt_json_select_push_space
rt_json_select_push_colon:
    cmp w0, #58
    b.ne rt_json_select_string_continue
    add x27, x27, #1
rt_json_select_push_value_space:
    cmp x27, x20
    b.hs rt_json_select_fail
    ldrb w0, [x19, x27]
    cmp w0, #32
    b.eq rt_json_select_push_value_space_one
    cmp w0, #9
    b.eq rt_json_select_push_value_space_one
    cmp w0, #10
    b.eq rt_json_select_push_value_space_one
    cmp w0, #13
    b.ne rt_json_select_push_value
rt_json_select_push_value_space_one:
    add x27, x27, #1
    b rt_json_select_push_value_space
rt_json_select_push_value:
    cmp w0, #123
    b.ne rt_json_select_fail
    mov x28, xzr
    mov x23, xzr
    mov x24, xzr
    mov x25, x27
rt_json_select_object_loop:
    cmp x25, x20
    b.hs rt_json_select_fail
    ldrb w0, [x19, x25]
    cbnz x23, rt_json_select_object_string
    cmp w0, #34
    b.eq rt_json_select_object_string_start
    cmp w0, #123
    b.eq rt_json_select_object_open
    cmp w0, #91
    b.eq rt_json_select_object_open
    cmp w0, #125
    b.eq rt_json_select_object_close
    cmp w0, #93
    b.eq rt_json_select_object_close
    add x25, x25, #1
    b rt_json_select_object_loop
rt_json_select_object_string_start:
    mov x23, #1
    add x25, x25, #1
    b rt_json_select_object_loop
rt_json_select_object_string:
    cbnz x24, rt_json_select_object_string_escaped
    cmp w0, #92
    b.eq rt_json_select_object_string_escape
    cmp w0, #34
    b.ne rt_json_select_object_next
    mov x23, xzr
    b rt_json_select_object_next
rt_json_select_object_string_escape:
    mov x24, #1
    b rt_json_select_object_next
rt_json_select_object_string_escaped:
    mov x24, xzr
rt_json_select_object_next:
    add x25, x25, #1
    b rt_json_select_object_loop
rt_json_select_object_open:
    add x28, x28, #1
    add x25, x25, #1
    b rt_json_select_object_loop
rt_json_select_object_close:
    cbz x28, rt_json_select_fail
    sub x28, x28, #1
    cbnz x28, rt_json_select_object_next
    add x25, x25, #1
    sub x26, x25, x27
    adrp x0, rt_json_selector_found
    add x0, x0, :lo12:rt_json_selector_found
    mov w1, #1
    str w1, [x0]
    mov x23, xzr
rt_json_select_copy_loop:
    cmp x23, x26
    b.hs rt_json_select_copy_done
    add x0, x19, x27
    ldrb w1, [x0, x23]
    strb w1, [x19, x23]
    add x23, x23, #1
    b rt_json_select_copy_loop
rt_json_select_copy_done:
    strb wzr, [x19, x26]
    adrp x0, rt_json_length
    add x0, x0, :lo12:rt_json_length
    str x26, [x0]
    mov w0, wzr
    b rt_json_select_return
rt_json_select_string_continue:
    add x21, x25, #1
    b rt_json_select_loop
rt_json_select_fail:
    mov w0, #1
    b rt_json_select_epilogue
rt_json_select_return:
    mov w0, wzr
rt_json_select_epilogue:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret

rt_fingerprint_push_id:
    stp x29, x30, [sp, #-96]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x29, sp
    adrp x0, rt_fingerprint_status
    add x0, x0, :lo12:rt_fingerprint_status
    str wzr, [x0]
    mov x21, #0x2325
    movk x21, #0x8422, lsl #16
    movk x21, #0x9ce4, lsl #32
    movk x21, #0xcbf2, lsl #48
    mov x24, #0x1b3
    movk x24, #0x100, lsl #32
    adrp x0, rt_push_mirror_kind
    add x0, x0, :lo12:rt_push_mirror_kind
    ldr x0, [x0]
    cmp x0, #1
    b.ne rt_fingerprint_raw
    adrp x0, rt_push_fingerprint_pending
    add x0, x0, :lo12:rt_push_fingerprint_pending
    ldr x0, [x0]
    cbz x0, rt_fingerprint_raw
    adrp x19, rt_json_buffer
    add x19, x19, :lo12:rt_json_buffer
    adrp x20, rt_json_length
    add x20, x20, :lo12:rt_json_length
    ldr x20, [x20]
    bl rt_fingerprint_hash_payload
    cbz w0, rt_fingerprint_hash_done
    mov w1, #1
    adrp x0, rt_fingerprint_status
    add x0, x0, :lo12:rt_fingerprint_status
    str w1, [x0]
    mov w1, #2
    adrp x0, rt_push_mirror_kind
    add x0, x0, :lo12:rt_push_mirror_kind
    str w1, [x0]
    mov x21, #0x2325
    movk x21, #0x8422, lsl #16
    movk x21, #0x9ce4, lsl #32
    movk x21, #0xcbf2, lsl #48
    b rt_fingerprint_raw_buffer
rt_fingerprint_raw:
    adrp x19, rt_json_buffer
    add x19, x19, :lo12:rt_json_buffer
    adrp x20, rt_json_length
    add x20, x20, :lo12:rt_json_length
    ldr x20, [x20]
rt_fingerprint_raw_buffer:
    mov x22, xzr
rt_fingerprint_hash_loop:
    cmp x22, x20
    b.hs rt_fingerprint_hash_done
    ldrb w23, [x19, x22]
    eor x21, x21, x23
    mul x21, x21, x24
    add x22, x22, #1
    b rt_fingerprint_hash_loop
rt_fingerprint_hash_done:
    adrp x0, rt_push_mirror_kind
    add x0, x0, :lo12:rt_push_mirror_kind
    ldr x0, [x0]
    cmp x0, #2
    b.eq rt_fingerprint_invalid_kind
    cbnz x0, rt_fingerprint_mirror_prefix
    mov x0, x19
    mov x1, x20
    adrp x2, json_push_type_mirror
    add x2, x2, :lo12:json_push_type_mirror
    mov x3, #15
    bl native_json_find_root_pattern
    cbnz x0, rt_fingerprint_mirror_prefix
    mov x0, x19
    mov x1, x20
    adrp x2, json_push_type_mirror_space
    add x2, x2, :lo12:json_push_type_mirror_space
    mov x3, #16
    bl native_json_find_root_pattern
rt_fingerprint_mirror_prefix:
    adrp x22, rt_push_id
    add x22, x22, :lo12:rt_push_id
    cbz x0, rt_fingerprint_invalid_prefix
    adrp x0, fingerprint_mirror_prefix
    add x0, x0, :lo12:fingerprint_mirror_prefix
    mov x1, x22
    bl rt_copy_cstr
    b rt_fingerprint_prefix_done
rt_fingerprint_invalid_kind:
    adrp x22, rt_push_id
    add x22, x22, :lo12:rt_push_id
rt_fingerprint_invalid_prefix:
    adrp x0, fingerprint_invalid_prefix
    add x0, x0, :lo12:fingerprint_invalid_prefix
    mov x1, x22
    bl rt_copy_cstr
rt_fingerprint_prefix_done:
    mov x0, x22
    bl rt_cstr_length
    mov x23, x0
    adrp x25, rt_hex_digits
    add x25, x25, :lo12:rt_hex_digits
    mov x24, #60
    mov x26, xzr
rt_fingerprint_hex_loop:
    cmp x26, #16
    b.hs rt_fingerprint_hex_done
    lsr x0, x21, x24
    and x0, x0, #15
    ldrb w0, [x25, x0]
    strb w0, [x22, x23]
    add x23, x23, #1
    sub x24, x24, #4
    add x26, x26, #1
    b rt_fingerprint_hex_loop
rt_fingerprint_hex_done:
    strb wzr, [x22, x23]
    adrp x0, rt_push_id_length
    add x0, x0, :lo12:rt_push_id_length
    str x23, [x0]
    adrp x0, rt_fingerprint_status
    add x0, x0, :lo12:rt_fingerprint_status
    ldr w0, [x0]
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret

rt_fingerprint_hash_payload:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x22, xzr
rt_fingerprint_payload_start:
    cmp x22, x20
    b.hs rt_fingerprint_payload_fail
    ldrb w0, [x19, x22]
    cmp w0, #32
    b.eq rt_fingerprint_payload_start_space
    cmp w0, #9
    b.eq rt_fingerprint_payload_start_space
    cmp w0, #10
    b.eq rt_fingerprint_payload_start_space
    cmp w0, #13
    b.eq rt_fingerprint_payload_start_space
    cmp w0, #123
    b.ne rt_fingerprint_payload_fail
    add x22, x22, #1
    mov x14, xzr
rt_fingerprint_payload_field:
    cmp x22, x20
    b.hs rt_fingerprint_payload_fail
    ldrb w0, [x19, x22]
    cmp w0, #32
    b.eq rt_fingerprint_payload_field_space
    cmp w0, #9
    b.eq rt_fingerprint_payload_field_space
    cmp w0, #10
    b.eq rt_fingerprint_payload_field_space
    cmp w0, #13
    b.eq rt_fingerprint_payload_field_space
    cmp w0, #125
    b.ne rt_fingerprint_payload_field_not_close
    cbnz x14, rt_fingerprint_payload_fail
    b rt_fingerprint_payload_close
rt_fingerprint_payload_field_not_close:
    cmp w0, #34
    b.ne rt_fingerprint_payload_fail
    mov x14, xzr
    add x25, x22, #1
    mov x26, x25
rt_fingerprint_payload_key_loop:
    cmp x26, x20
    b.hs rt_fingerprint_payload_fail
    ldrb w0, [x19, x26]
    cmp w0, #92
    b.eq rt_fingerprint_payload_key_escape
    cmp w0, #34
    b.eq rt_fingerprint_payload_key_done
    add x26, x26, #1
    b rt_fingerprint_payload_key_loop
rt_fingerprint_payload_key_escape:
    add x26, x26, #1
    cmp x26, x20
    b.hs rt_fingerprint_payload_fail
    add x26, x26, #1
    b rt_fingerprint_payload_key_loop
rt_fingerprint_payload_key_done:
    sub x1, x26, x25
    add x0, x19, x25
    bl rt_fingerprint_is_lifecycle
    mov w15, w0
    cbnz w15, rt_fingerprint_payload_key_hashed
    mov x27, x25
rt_fingerprint_payload_key_hash_loop:
    cmp x27, x26
    b.hs rt_fingerprint_payload_key_hash_done
    ldrb w0, [x19, x27]
    eor x21, x21, x0
    mul x21, x21, x24
    add x27, x27, #1
    b rt_fingerprint_payload_key_hash_loop
rt_fingerprint_payload_key_hash_done:
    mov x0, xzr
    eor x21, x21, x0
    mul x21, x21, x24
rt_fingerprint_payload_key_hashed:
    add x22, x26, #1
rt_fingerprint_payload_after_key:
    cmp x22, x20
    b.hs rt_fingerprint_payload_fail
    ldrb w0, [x19, x22]
    cmp w0, #32
    b.eq rt_fingerprint_payload_after_key_space
    cmp w0, #9
    b.eq rt_fingerprint_payload_after_key_space
    cmp w0, #10
    b.eq rt_fingerprint_payload_after_key_space
    cmp w0, #13
    b.eq rt_fingerprint_payload_after_key_space
    cmp w0, #58
    b.ne rt_fingerprint_payload_fail
    add x22, x22, #1
rt_fingerprint_payload_before_value:
    cmp x22, x20
    b.hs rt_fingerprint_payload_fail
    ldrb w0, [x19, x22]
    cmp w0, #32
    b.eq rt_fingerprint_payload_before_value_space
    cmp w0, #9
    b.eq rt_fingerprint_payload_before_value_space
    cmp w0, #10
    b.eq rt_fingerprint_payload_before_value_space
    cmp w0, #13
    b.eq rt_fingerprint_payload_before_value_space
    mov x25, x22
    cmp w0, #34
    b.eq rt_fingerprint_payload_value_string
    cmp w0, #123
    b.eq rt_fingerprint_payload_value_compound
    cmp w0, #91
    b.eq rt_fingerprint_payload_value_compound
    cmp w0, #44
    b.eq rt_fingerprint_payload_fail
    cmp w0, #125
    b.eq rt_fingerprint_payload_fail
    b rt_fingerprint_payload_value_primitive
rt_fingerprint_payload_value_string:
    add x26, x25, #1
rt_fingerprint_payload_value_string_loop:
    cmp x26, x20
    b.hs rt_fingerprint_payload_fail
    ldrb w0, [x19, x26]
    cmp w0, #92
    b.eq rt_fingerprint_payload_value_string_escape
    cmp w0, #34
    b.eq rt_fingerprint_payload_value_end_one
    add x26, x26, #1
    b rt_fingerprint_payload_value_string_loop
rt_fingerprint_payload_value_string_escape:
    add x26, x26, #1
    cmp x26, x20
    b.hs rt_fingerprint_payload_fail
    add x26, x26, #1
    b rt_fingerprint_payload_value_string_loop
rt_fingerprint_payload_value_end_one:
    add x26, x26, #1
    b rt_fingerprint_payload_value_ready
rt_fingerprint_payload_value_compound:
    adrp x16, rt_json_structure_stack
    add x16, x16, :lo12:rt_json_structure_stack
    mov x23, #1
    strb w0, [x16]
    add x26, x25, #1
    mov x27, xzr
    mov x28, xzr
rt_fingerprint_payload_value_compound_loop:
    cmp x26, x20
    b.hs rt_fingerprint_payload_fail
    ldrb w0, [x19, x26]
    tst x27, #1
    b.ne rt_fingerprint_payload_value_in_string
    cmp w0, #34
    b.eq rt_fingerprint_payload_value_string_open
    cmp w0, #123
    b.eq rt_fingerprint_payload_value_open
    cmp w0, #91
    b.eq rt_fingerprint_payload_value_open
    cmp w0, #125
    b.eq rt_fingerprint_payload_value_close_object
    cmp w0, #93
    b.eq rt_fingerprint_payload_value_close_array
    add x26, x26, #1
    b rt_fingerprint_payload_value_compound_loop
rt_fingerprint_payload_value_string_open:
    mov x27, #1
    add x26, x26, #1
    b rt_fingerprint_payload_value_compound_loop
rt_fingerprint_payload_value_open:
    cmp x23, #255
    b.hs rt_fingerprint_payload_fail
    strb w0, [x16, x23]
    add x23, x23, #1
    add x26, x26, #1
    b rt_fingerprint_payload_value_compound_loop
rt_fingerprint_payload_value_close_object:
    cbz x23, rt_fingerprint_payload_fail
    sub x17, x23, #1
    ldrb w1, [x16, x17]
    cmp w1, #123
    b.ne rt_fingerprint_payload_fail
    sub x23, x23, #1
    add x26, x26, #1
    cbnz x23, rt_fingerprint_payload_value_compound_loop
    b rt_fingerprint_payload_value_ready
rt_fingerprint_payload_value_close_array:
    cbz x23, rt_fingerprint_payload_fail
    sub x17, x23, #1
    ldrb w1, [x16, x17]
    cmp w1, #91
    b.ne rt_fingerprint_payload_fail
    sub x23, x23, #1
    add x26, x26, #1
    cbnz x23, rt_fingerprint_payload_value_compound_loop
    b rt_fingerprint_payload_value_ready
rt_fingerprint_payload_value_in_string:
    cbnz x28, rt_fingerprint_payload_value_escape_done
    cmp w0, #92
    b.eq rt_fingerprint_payload_value_escape
    cmp w0, #34
    b.eq rt_fingerprint_payload_value_string_close
    add x26, x26, #1
    b rt_fingerprint_payload_value_compound_loop
rt_fingerprint_payload_value_escape:
    mov x28, #1
    add x26, x26, #1
    b rt_fingerprint_payload_value_compound_loop
rt_fingerprint_payload_value_escape_done:
    mov x28, xzr
    add x26, x26, #1
    b rt_fingerprint_payload_value_compound_loop
rt_fingerprint_payload_value_string_close:
    mov x27, xzr
    add x26, x26, #1
    b rt_fingerprint_payload_value_compound_loop
rt_fingerprint_payload_value_primitive:
    mov x26, x25
rt_fingerprint_payload_value_primitive_loop:
    cmp x26, x20
    b.hs rt_fingerprint_payload_fail
    ldrb w0, [x19, x26]
    cmp w0, #44
    b.eq rt_fingerprint_payload_value_ready
    cmp w0, #125
    b.eq rt_fingerprint_payload_value_ready
    cmp w0, #93
    b.eq rt_fingerprint_payload_fail
    add x26, x26, #1
    b rt_fingerprint_payload_value_primitive_loop
rt_fingerprint_payload_value_ready:
    cbnz w15, rt_fingerprint_payload_value_hashed
    mov x27, x25
rt_fingerprint_payload_value_hash_loop:
    cmp x27, x26
    b.hs rt_fingerprint_payload_value_hash_done
    ldrb w0, [x19, x27]
    eor x21, x21, x0
    mul x21, x21, x24
    add x27, x27, #1
    b rt_fingerprint_payload_value_hash_loop
rt_fingerprint_payload_value_hash_done:
    mov x0, #255
    eor x21, x21, x0
    mul x21, x21, x24
rt_fingerprint_payload_value_hashed:
    mov x22, x26
rt_fingerprint_payload_after_value:
    cmp x22, x20
    b.hs rt_fingerprint_payload_fail
    ldrb w0, [x19, x22]
    cmp w0, #32
    b.eq rt_fingerprint_payload_after_value_space
    cmp w0, #9
    b.eq rt_fingerprint_payload_after_value_space
    cmp w0, #10
    b.eq rt_fingerprint_payload_after_value_space
    cmp w0, #13
    b.eq rt_fingerprint_payload_after_value_space
    cmp w0, #44
    b.eq rt_fingerprint_payload_comma
    cmp w0, #125
    b.eq rt_fingerprint_payload_close
    b rt_fingerprint_payload_fail
rt_fingerprint_payload_comma:
    add x22, x22, #1
    mov x14, #1
    b rt_fingerprint_payload_field
rt_fingerprint_payload_close:
    add x22, x22, #1
rt_fingerprint_payload_trailing:
    cmp x22, x20
    b.hs rt_fingerprint_payload_success
    ldrb w0, [x19, x22]
    cmp w0, #32
    b.eq rt_fingerprint_payload_trailing_space
    cmp w0, #9
    b.eq rt_fingerprint_payload_trailing_space
    cmp w0, #10
    b.eq rt_fingerprint_payload_trailing_space
    cmp w0, #13
    b.eq rt_fingerprint_payload_trailing_space
    b rt_fingerprint_payload_fail
rt_fingerprint_payload_start_space:
    add x22, x22, #1
    b rt_fingerprint_payload_start
rt_fingerprint_payload_field_space:
    add x22, x22, #1
    b rt_fingerprint_payload_field
rt_fingerprint_payload_after_key_space:
    add x22, x22, #1
    b rt_fingerprint_payload_after_key
rt_fingerprint_payload_before_value_space:
    add x22, x22, #1
    b rt_fingerprint_payload_before_value
rt_fingerprint_payload_after_value_space:
    add x22, x22, #1
    b rt_fingerprint_payload_after_value
rt_fingerprint_payload_trailing_space:
    add x22, x22, #1
    b rt_fingerprint_payload_trailing
rt_fingerprint_payload_success:
    mov w0, wzr
    b rt_fingerprint_payload_return
rt_fingerprint_payload_return:
    ldp x29, x30, [sp], #16
    ret
rt_fingerprint_payload_fail:
    mov w0, #1
    b rt_fingerprint_payload_return

rt_fingerprint_is_lifecycle:
    cmp x1, #4
    b.eq rt_fingerprint_lifecycle_id
    cmp x1, #7
    b.eq rt_fingerprint_lifecycle_created
    cmp x1, #8
    b.eq rt_fingerprint_lifecycle_modified
    cmp x1, #6
    b.eq rt_fingerprint_lifecycle_active
    cmp x1, #9
    b.eq rt_fingerprint_lifecycle_dismissed
    b rt_fingerprint_lifecycle_no
rt_fingerprint_lifecycle_id:
    adrp x2, json_key_id
    add x2, x2, :lo12:json_key_id
    b rt_fingerprint_lifecycle_compare
rt_fingerprint_lifecycle_created:
    adrp x2, json_created_name
    add x2, x2, :lo12:json_created_name
    add x2, x2, #1
    b rt_fingerprint_lifecycle_compare
rt_fingerprint_lifecycle_modified:
    adrp x2, json_modified_name
    add x2, x2, :lo12:json_modified_name
    add x2, x2, #1
    b rt_fingerprint_lifecycle_compare
rt_fingerprint_lifecycle_active:
    adrp x2, fingerprint_key_active
    add x2, x2, :lo12:fingerprint_key_active
    b rt_fingerprint_lifecycle_compare
rt_fingerprint_lifecycle_dismissed:
    adrp x2, fingerprint_key_dismissed
    add x2, x2, :lo12:fingerprint_key_dismissed
rt_fingerprint_lifecycle_compare:
    mov x3, xzr
rt_fingerprint_lifecycle_compare_loop:
    cmp x3, x1
    b.hs rt_fingerprint_lifecycle_yes
    ldrb w4, [x0, x3]
    ldrb w5, [x2, x3]
    cmp w4, w5
    b.ne rt_fingerprint_lifecycle_no
    add x3, x3, #1
    b rt_fingerprint_lifecycle_compare_loop
rt_fingerprint_lifecycle_no:
    mov w0, wzr
    ret
rt_fingerprint_lifecycle_yes:
    mov w0, #1
    ret

rt_fingerprint_hash_span:
    mov x22, xzr
rt_fingerprint_hash_span_loop:
    cmp x22, x20
    b.hs rt_fingerprint_hash_span_return
    ldrb w23, [x19, x22]
    eor x21, x21, x23
    mul x21, x21, x24
    add x22, x22, #1
    b rt_fingerprint_hash_span_loop
rt_fingerprint_hash_span_return:
    ret

rt_fingerprint_hash_optional_json:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x0, x19
    mov x1, x20
    adrp x2, rt_fingerprint_scratch
    add x2, x2, :lo12:rt_fingerprint_scratch
    mov x3, #1024
    bl rt_json_value
    cbnz w0, rt_fingerprint_hash_optional_missing
    mov x0, #1
    eor x21, x21, x0
    mul x21, x21, x24
    adrp x19, rt_fingerprint_scratch
    add x19, x19, :lo12:rt_fingerprint_scratch
    adrp x20, rt_json_value_length
    add x20, x20, :lo12:rt_json_value_length
    ldr x20, [x20]
    bl rt_fingerprint_hash_span
    b rt_fingerprint_hash_optional_separator
rt_fingerprint_hash_optional_missing:
    mov x0, xzr
    eor x21, x21, x0
    mul x21, x21, x24
rt_fingerprint_hash_optional_separator:
    mov x0, #255
    eor x21, x21, x0
    mul x21, x21, x24
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_json_decode_escape:
    mov x5, x0
    cmp x5, x1
    b.hs rt_json_decode_escape_failure
    ldrb w6, [x5]
    cmp w6, #34
    b.eq rt_json_decode_escape_quote
    cmp w6, #47
    b.eq rt_json_decode_escape_slash
    cmp w6, #92
    b.eq rt_json_decode_escape_backslash
    cmp w6, #98
    b.eq rt_json_decode_escape_backspace
    cmp w6, #102
    b.eq rt_json_decode_escape_formfeed
    cmp w6, #110
    b.eq rt_json_decode_escape_newline
    cmp w6, #114
    b.eq rt_json_decode_escape_return
    cmp w6, #116
    b.eq rt_json_decode_escape_tab
    cmp w6, #117
    b.eq rt_json_decode_escape_unicode
    b rt_json_decode_escape_failure
rt_json_decode_escape_quote:
    mov x9, #34
    b rt_json_decode_escape_simple
rt_json_decode_escape_slash:
    mov x9, #47
    b rt_json_decode_escape_simple
rt_json_decode_escape_backslash:
    mov x9, #92
    b rt_json_decode_escape_simple
rt_json_decode_escape_backspace:
    mov x9, #8
    b rt_json_decode_escape_simple
rt_json_decode_escape_formfeed:
    mov x9, #12
    b rt_json_decode_escape_simple
rt_json_decode_escape_newline:
    mov x9, #10
    b rt_json_decode_escape_simple
rt_json_decode_escape_return:
    mov x9, #13
    b rt_json_decode_escape_simple
rt_json_decode_escape_tab:
    mov x9, #9
    b rt_json_decode_escape_simple
rt_json_decode_escape_simple:
    add x5, x5, #1
    b rt_json_decode_escape_emit
rt_json_decode_escape_unicode:
    add x5, x5, #1
    sub x8, x1, x5
    cmp x8, #4
    b.lo rt_json_decode_escape_failure
    mov x9, xzr
    mov x10, xzr
rt_json_decode_escape_hex_loop:
    ldrb w6, [x5, x10]
    cmp w6, #48
    b.lo rt_json_decode_escape_hex_alpha
    cmp w6, #57
    b.ls rt_json_decode_escape_hex_digit
rt_json_decode_escape_hex_alpha:
    cmp w6, #65
    b.lo rt_json_decode_escape_hex_lower
    cmp w6, #70
    b.hi rt_json_decode_escape_hex_lower
    sub w7, w6, #55
    b rt_json_decode_escape_hex_value
rt_json_decode_escape_hex_lower:
    cmp w6, #97
    b.lo rt_json_decode_escape_failure
    cmp w6, #102
    b.hi rt_json_decode_escape_failure
    sub w7, w6, #87
    b rt_json_decode_escape_hex_value
rt_json_decode_escape_hex_digit:
    sub w7, w6, #48
rt_json_decode_escape_hex_value:
    lsl x9, x9, #4
    add x9, x9, x7
    add x10, x10, #1
    cmp x10, #4
    b.lo rt_json_decode_escape_hex_loop
    add x5, x5, #4
    mov x10, #0xd800
    cmp x9, x10
    b.lo rt_json_decode_escape_bmp
    mov x10, #0xdbff
    cmp x9, x10
    b.ls rt_json_decode_escape_high_surrogate
    mov x10, #0xdc00
    cmp x9, x10
    b.lo rt_json_decode_escape_bmp
    mov x10, #0xdfff
    cmp x9, x10
    b.ls rt_json_decode_escape_failure
    b rt_json_decode_escape_bmp
rt_json_decode_escape_high_surrogate:
    sub x8, x1, x5
    cmp x8, #6
    b.lo rt_json_decode_escape_failure
    ldrb w6, [x5]
    cmp w6, #92
    b.ne rt_json_decode_escape_failure
    ldrb w6, [x5, #1]
    cmp w6, #117
    b.ne rt_json_decode_escape_failure
    add x5, x5, #2
    mov x10, xzr
    mov x11, xzr
rt_json_decode_escape_low_hex_loop:
    ldrb w6, [x5, x11]
    cmp w6, #48
    b.lo rt_json_decode_escape_low_hex_alpha
    cmp w6, #57
    b.ls rt_json_decode_escape_low_hex_digit
rt_json_decode_escape_low_hex_alpha:
    cmp w6, #65
    b.lo rt_json_decode_escape_low_hex_lower
    cmp w6, #70
    b.hi rt_json_decode_escape_low_hex_lower
    sub w7, w6, #55
    b rt_json_decode_escape_low_hex_value
rt_json_decode_escape_low_hex_lower:
    cmp w6, #97
    b.lo rt_json_decode_escape_failure
    cmp w6, #102
    b.hi rt_json_decode_escape_failure
    sub w7, w6, #87
    b rt_json_decode_escape_low_hex_value
rt_json_decode_escape_low_hex_digit:
    sub w7, w6, #48
rt_json_decode_escape_low_hex_value:
    lsl x10, x10, #4
    add x10, x10, x7
    add x11, x11, #1
    cmp x11, #4
    b.lo rt_json_decode_escape_low_hex_loop
    add x5, x5, #4
    mov x11, #0xdc00
    cmp x10, x11
    b.lo rt_json_decode_escape_failure
    mov x11, #0xdfff
    cmp x10, x11
    b.hi rt_json_decode_escape_failure
    mov x11, #0xd800
    sub x9, x9, x11
    lsl x9, x9, #10
    mov x11, #0xdc00
    sub x10, x10, x11
    add x9, x9, x10
    mov x10, #0x10000
    add x9, x9, x10
rt_json_decode_escape_bmp:
    b rt_json_decode_escape_emit
rt_json_decode_escape_emit:
    cmp x9, #0x7f
    b.ls rt_json_decode_escape_emit_one
    cmp x9, #0x7ff
    b.ls rt_json_decode_escape_emit_two
    mov x10, #0xffff
    cmp x9, x10
    b.ls rt_json_decode_escape_emit_three
    b rt_json_decode_escape_emit_four
rt_json_decode_escape_emit_one:
    add x8, x3, #1
    cmp x8, x4
    b.hs rt_json_decode_escape_failure
    strb w9, [x2, x3]
    add x3, x3, #1
    b rt_json_decode_escape_success
rt_json_decode_escape_emit_two:
    add x8, x3, #2
    cmp x8, x4
    b.hs rt_json_decode_escape_failure
    add x8, x2, x3
    lsr x10, x9, #6
    and w10, w10, #0x1f
    orr w10, w10, #0xc0
    strb w10, [x8]
    and w10, w9, #0x3f
    orr w10, w10, #0x80
    strb w10, [x8, #1]
    add x3, x3, #2
    b rt_json_decode_escape_success
rt_json_decode_escape_emit_three:
    add x8, x3, #3
    cmp x8, x4
    b.hs rt_json_decode_escape_failure
    add x8, x2, x3
    lsr x10, x9, #12
    and w10, w10, #0x0f
    orr w10, w10, #0xe0
    strb w10, [x8]
    lsr x10, x9, #6
    and w10, w10, #0x3f
    orr w10, w10, #0x80
    strb w10, [x8, #1]
    and w10, w9, #0x3f
    orr w10, w10, #0x80
    strb w10, [x8, #2]
    add x3, x3, #3
    b rt_json_decode_escape_success
rt_json_decode_escape_emit_four:
    add x8, x3, #4
    cmp x8, x4
    b.hs rt_json_decode_escape_failure
    add x8, x2, x3
    lsr x10, x9, #18
    and w10, w10, #0x07
    orr w10, w10, #0xf0
    strb w10, [x8]
    lsr x10, x9, #12
    and w10, w10, #0x3f
    orr w10, w10, #0x80
    strb w10, [x8, #1]
    lsr x10, x9, #6
    and w10, w10, #0x3f
    orr w10, w10, #0x80
    strb w10, [x8, #2]
    and w10, w9, #0x3f
    orr w10, w10, #0x80
    strb w10, [x8, #3]
    add x3, x3, #4
rt_json_decode_escape_success:
    mov x0, x5
    mov x1, x3
    mov w2, wzr
    ret
rt_json_decode_escape_failure:
    mov w2, #1
    ret

rt_json_value:
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
    adrp x23, rt_json_buffer
    add x23, x23, :lo12:rt_json_buffer
    adrp x24, rt_json_length
    add x24, x24, :lo12:rt_json_length
    ldr x24, [x24]
    mov x25, xzr
    mov x17, xzr
rt_json_scan:
    cmp x25, x24
    b.hs rt_json_fail
    ldrb w0, [x23, x25]
    cmp w0, #34
    b.ne rt_json_scan_byte
    add x26, x25, #1
    mov x27, x26
rt_json_string_scan:
    cmp x27, x24
    b.hs rt_json_fail
    ldrb w0, [x23, x27]
    cmp w0, #92
    b.eq rt_json_string_escape
    cmp w0, #34
    b.eq rt_json_string_closed
    add x27, x27, #1
    b rt_json_string_scan
rt_json_string_escape:
    add x27, x27, #1
    cmp x27, x24
    b.hs rt_json_fail
    add x27, x27, #1
    b rt_json_string_scan
rt_json_string_closed:
    add x0, x27, #1
rt_json_key_space:
    cmp x0, x24
    b.hs rt_json_fail
    ldrb w1, [x23, x0]
    cmp w1, #32
    b.eq rt_json_key_space_one
    cmp w1, #9
    b.eq rt_json_key_space_one
    cmp w1, #10
    b.eq rt_json_key_space_one
    cmp w1, #13
    b.ne rt_json_key_colon
rt_json_key_space_one:
    add x0, x0, #1
    b rt_json_key_space
rt_json_key_colon:
    cmp w1, #58
    b.ne rt_json_scan_next
    cmp x17, #1
    b.ne rt_json_scan_next
    mov x18, x0
    sub x0, x27, x26
    cmp x0, x20
    b.ne rt_json_scan_next
    mov x0, xzr
rt_json_key_compare:
    cmp x0, x20
    b.hs rt_json_key_match
    add x1, x26, x0
    ldrb w2, [x23, x1]
    ldrb w3, [x19, x0]
    cmp w2, w3
    b.ne rt_json_scan_next
    add x0, x0, #1
    b rt_json_key_compare
rt_json_key_match:
    add x27, x18, #1
rt_json_value_space:
    cmp x27, x24
    b.hs rt_json_fail
    ldrb w0, [x23, x27]
    cmp w0, #32
    b.eq rt_json_value_space_one
    cmp w0, #9
    b.eq rt_json_value_space_one
    cmp w0, #10
    b.eq rt_json_value_space_one
    cmp w0, #13
    b.ne rt_json_value_quote
rt_json_value_space_one:
    add x27, x27, #1
    b rt_json_value_space
rt_json_value_quote:
    cmp w0, #34
    b.ne rt_json_non_string
    add x27, x27, #1
    mov x28, xzr
rt_json_copy_loop:
    cmp x27, x24
    b.hs rt_json_fail
    ldrb w0, [x23, x27]
    cmp w0, #34
    b.eq rt_json_copy_done
    cmp w0, #92
    b.ne rt_json_copy_store
    add x27, x27, #1
    cmp x27, x24
    b.hs rt_json_fail
    add x0, x23, x27
    add x1, x23, x24
    mov x2, x21
    mov x3, x28
    mov x4, x22
    bl rt_json_decode_escape
    cbnz w2, rt_json_fail
    sub x27, x0, x23
    mov x28, x1
    b rt_json_copy_loop
rt_json_copy_store:
    add x1, x28, #1
    cmp x1, x22
    b.hs rt_json_fail
    strb w0, [x21, x28]
    add x28, x28, #1
    add x27, x27, #1
    b rt_json_copy_loop
rt_json_copy_done:
    strb wzr, [x21, x28]
    adrp x0, rt_json_value_length
    add x0, x0, :lo12:rt_json_value_length
    str x28, [x0]
    mov w0, wzr
    b rt_json_return
rt_json_scan_next:
    add x25, x27, #1
    b rt_json_scan
rt_json_scan_byte:
    cmp w0, #123
    b.eq rt_json_open
    cmp w0, #91
    b.eq rt_json_open
    cmp w0, #125
    b.eq rt_json_close
    cmp w0, #93
    b.eq rt_json_close
    add x25, x25, #1
    b rt_json_scan
rt_json_open:
    add x17, x17, #1
    add x25, x25, #1
    b rt_json_scan
rt_json_close:
    cbz x17, rt_json_fail
    sub x17, x17, #1
    add x25, x25, #1
    b rt_json_scan
rt_json_fail:
    strb wzr, [x21]
    mov w0, #1
    b rt_json_return
rt_json_non_string:
    strb wzr, [x21]
    mov w0, #2
rt_json_return:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret

rt_extract_name:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl rt_validate_name_candidates
    cbnz w0, rt_extract_name_fail
    adrp x0, rt_filter_name
    add x0, x0, :lo12:rt_filter_name
    adrp x1, arrow_bank_name_pattern
    add x1, x1, :lo12:arrow_bank_name_pattern
    mov x2, #57
    bl rt_str_eq
    cbnz w0, rt_extract_name_arrow
    adrp x0, label_name
    add x0, x0, :lo12:label_name
    mov x1, #9
    bl rt_find_body_sub
    cbnz x0, rt_extract_name_found
    adrp x0, label_sender
    add x0, x0, :lo12:label_sender
    mov x1, #9
    bl rt_find_body_sub
    cbnz x0, rt_extract_name_found
    adrp x0, label_sender_space
    add x0, x0, :lo12:label_sender_space
    mov x1, #13
    bl rt_find_body_sub
    cbnz x0, rt_extract_name_found
    adrp x0, label_sender_ascii
    add x0, x0, :lo12:label_sender_ascii
    mov x1, #6
    bl rt_find_body_sub
    cbnz x0, rt_extract_name_found
    adrp x0, label_name_ascii
    add x0, x0, :lo12:label_name_ascii
    mov x1, #4
    bl rt_find_body_sub
    cbnz x0, rt_extract_name_found
    adrp x0, label_name
    add x0, x0, :lo12:label_name
    mov x1, #9
    bl rt_find_title_sub
    cbnz x0, rt_extract_name_found
    adrp x0, label_sender
    add x0, x0, :lo12:label_sender
    mov x1, #9
    bl rt_find_title_sub
    cbnz x0, rt_extract_name_found
    adrp x0, label_sender_space
    add x0, x0, :lo12:label_sender_space
    mov x1, #13
    bl rt_find_title_sub
    cbnz x0, rt_extract_name_found
    adrp x0, label_sender_ascii
    add x0, x0, :lo12:label_sender_ascii
    mov x1, #6
    bl rt_find_title_sub
    cbnz x0, rt_extract_name_found
    adrp x0, label_name_ascii
    add x0, x0, :lo12:label_name_ascii
    mov x1, #4
    bl rt_find_title_sub
    cbnz x0, rt_extract_name_found
    b rt_extract_name_fail

rt_extract_name_arrow:
    adrp x4, rt_body
    add x4, x4, :lo12:rt_body
    adrp x5, rt_body_length
    add x5, x5, :lo12:rt_body_length
    ldr x5, [x5]
    cmp x5, #3
    b.lo rt_extract_name_arrow_title
    mov x6, xzr
rt_extract_name_arrow_scan:
    sub x7, x5, #3
    cmp x6, x7
    b.hi rt_extract_name_arrow_title
    ldrb w8, [x4, x6]
    mov w9, #226
    cmp w8, w9
    b.ne rt_extract_name_arrow_scan_next
    add x7, x6, #1
    ldrb w8, [x4, x7]
    mov w9, #134
    cmp w8, w9
    b.ne rt_extract_name_arrow_scan_next
    add x7, x6, #2
    ldrb w8, [x4, x7]
    mov w9, #146
    cmp w8, w9
    b.eq rt_extract_name_arrow_found
rt_extract_name_arrow_scan_next:
    add x6, x6, #1
    b rt_extract_name_arrow_scan
rt_extract_name_arrow_title:
    adrp x4, rt_title
    add x4, x4, :lo12:rt_title
    adrp x5, rt_title_length
    add x5, x5, :lo12:rt_title_length
    ldr x5, [x5]
    cmp x5, #3
    b.lo rt_extract_name_fail
    mov x6, xzr
rt_extract_name_arrow_title_scan:
    sub x7, x5, #3
    cmp x6, x7
    b.hi rt_extract_name_fail
    ldrb w8, [x4, x6]
    mov w9, #226
    cmp w8, w9
    b.ne rt_extract_name_arrow_title_scan_next
    add x7, x6, #1
    ldrb w8, [x4, x7]
    mov w9, #134
    cmp w8, w9
    b.ne rt_extract_name_arrow_title_scan_next
    add x7, x6, #2
    ldrb w8, [x4, x7]
    mov w9, #146
    cmp w8, w9
    b.eq rt_extract_name_arrow_found
rt_extract_name_arrow_title_scan_next:
    add x6, x6, #1
    b rt_extract_name_arrow_title_scan
rt_extract_name_arrow_found:
    add x7, x6, #3
rt_extract_name_arrow_suffix_space:
    cmp x7, x5
    b.hs rt_extract_name_fail
    ldrb w8, [x4, x7]
    cmp w8, #32
    b.eq rt_extract_name_arrow_suffix_space_one
    cmp w8, #9
    b.ne rt_extract_name_arrow_suffix_check
rt_extract_name_arrow_suffix_space_one:
    add x7, x7, #1
    b rt_extract_name_arrow_suffix_space
rt_extract_name_arrow_suffix_check:
    add x8, x7, #23
    cmp x8, x5
    b.ne rt_extract_name_fail
    adrp x2, arrow_bank_name_suffix
    add x2, x2, :lo12:arrow_bank_name_suffix
    mov x8, xzr
rt_extract_name_arrow_suffix_loop:
    cmp x8, #23
    b.hs rt_extract_name_arrow_suffix_good
    add x9, x7, x8
    ldrb w10, [x4, x9]
    ldrb w11, [x2, x8]
    cmp w10, w11
    b.ne rt_extract_name_fail
    add x8, x8, #1
    b rt_extract_name_arrow_suffix_loop
rt_extract_name_arrow_suffix_good:
    cbz x6, rt_extract_name_fail
    mov x7, xzr
    mov x8, xzr
rt_extract_name_arrow_validate:
    cmp x7, x6
    b.hs rt_extract_name_arrow_validated
    ldrb w9, [x4, x7]
    cmp w9, #13
    b.eq rt_extract_name_fail
    cmp w9, #10
    b.eq rt_extract_name_fail
    cmp w9, #44
    b.eq rt_extract_name_fail
    cmp w9, #40
    b.eq rt_extract_name_fail
    cmp w9, #41
    b.eq rt_extract_name_fail
    cmp w9, #226
    b.ne rt_extract_name_arrow_count
    add x10, x7, #2
    cmp x10, x6
    b.hs rt_extract_name_fail
    add x10, x4, x7
    ldrb w11, [x10, #1]
    cmp w11, #134
    b.ne rt_extract_name_arrow_count
    ldrb w11, [x10, #2]
    cmp w11, #146
    b.eq rt_extract_name_fail
rt_extract_name_arrow_count:
    cmp w9, #128
    b.lo rt_extract_name_arrow_count_one
    cmp w9, #191
    b.ls rt_extract_name_arrow_next
rt_extract_name_arrow_count_one:
    add x8, x8, #1
    cmp x8, #100
    b.hi rt_extract_name_fail
rt_extract_name_arrow_next:
    add x7, x7, #1
    b rt_extract_name_arrow_validate
rt_extract_name_arrow_validated:
    mov x5, x6
rt_extract_name_arrow_trim:
    cbz x5, rt_extract_name_fail
    sub x6, x5, #1
    ldrb w3, [x4, x6]
    cmp w3, #32
    b.eq rt_extract_name_arrow_trim_store
    cmp w3, #9
    b.eq rt_extract_name_arrow_trim_store
    b rt_extract_name_arrow_copy
rt_extract_name_arrow_trim_store:
    mov x5, x6
    b rt_extract_name_arrow_trim
rt_extract_name_arrow_copy:
    cbz x5, rt_extract_name_fail
    mov x7, x4
    adrp x4, rt_parsed_name
    add x4, x4, :lo12:rt_parsed_name
    mov x6, xzr
rt_extract_name_arrow_copy_loop:
    cmp x6, x5
    b.hs rt_extract_name_done
    cmp x6, #512
    b.hs rt_extract_name_fail
    ldrb w3, [x7, x6]
    strb w3, [x4, x6]
    add x6, x6, #1
    b rt_extract_name_arrow_copy_loop
rt_extract_name_found:
    mov x2, x0
rt_extract_name_skip:
    ldrb w3, [x2]
    cmp w3, #58
    b.eq rt_extract_name_skip_one
    cmp w3, #32
    b.eq rt_extract_name_skip_one
    cmp w3, #9
    b.eq rt_extract_name_skip_one
    cmp w3, #239
    b.ne rt_extract_name_copy
    ldrb w4, [x2, #1]
    cmp w4, #188
    b.ne rt_extract_name_copy
    ldrb w4, [x2, #2]
    cmp w4, #154
    b.ne rt_extract_name_copy
    add x2, x2, #3
    b rt_extract_name_skip
rt_extract_name_skip_one:
    add x2, x2, #1
    b rt_extract_name_skip
rt_extract_name_copy:
    adrp x4, rt_parsed_name
    add x4, x4, :lo12:rt_parsed_name
    mov x5, xzr
rt_extract_name_loop:
    cmp x5, #512
    b.hs rt_extract_name_fail
    ldrb w3, [x2, x5]
    cmp w3, #10
    b.eq rt_extract_name_done
    cmp w3, #13
    b.eq rt_extract_name_done
    cmp w3, #44
    b.eq rt_extract_name_done
    cmp w3, #40
    b.eq rt_extract_name_done
    cmp w3, #41
    b.eq rt_extract_name_done
    cbz w3, rt_extract_name_fail
    strb w3, [x4, x5]
    add x5, x5, #1
    b rt_extract_name_loop
rt_extract_name_done:
    strb wzr, [x4, x5]
    adrp x0, rt_parsed_name_length
    add x0, x0, :lo12:rt_parsed_name_length
    str x5, [x0]
    adrp x0, rt_parsed_name
    add x0, x0, :lo12:rt_parsed_name
    adrp x1, rt_parsed_name_length
    add x1, x1, :lo12:rt_parsed_name_length
    ldr x1, [x1]
    adrp x2, rt_normalized
    add x2, x2, :lo12:rt_normalized
    mov x3, #1024
    adrp x4, rt_normalized_length
    add x4, x4, :lo12:rt_normalized_length
    bl yul_normalize_name_utf8
    cbnz w0, rt_extract_name_return
    bl rt_apply_case_insensitive_latin
    b rt_extract_name_return
rt_extract_name_fail:
    mov w0, #1
rt_extract_name_return:
    ldp x29, x30, [sp], #16
    ret

rt_extract_amount_title:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x4, rt_title
    add x4, x4, :lo12:rt_title
    adrp x5, rt_title_length
    add x5, x5, :lo12:rt_title_length
    ldr x5, [x5]
    mov x6, xzr
    mov x7, xzr
rt_extract_amount_title_digits:
    cmp x6, x5
    b.hs rt_extract_amount_title_fail
    ldrb w8, [x4, x6]
    cmp w8, #48
    b.lo rt_extract_amount_title_after_digits
    cmp w8, #57
    b.hi rt_extract_amount_title_comma
    add x7, x7, #1
    add x6, x6, #1
    b rt_extract_amount_title_digits
rt_extract_amount_title_comma:
    cmp w8, #44
    b.ne rt_extract_amount_title_after_digits
    cbz x7, rt_extract_amount_title_fail
    add x6, x6, #1
    b rt_extract_amount_title_digits
rt_extract_amount_title_after_digits:
    cbz x7, rt_extract_amount_title_fail
    mov x9, xzr
    adrp x10, rt_amount_text
    add x10, x10, :lo12:rt_amount_text
    mov x11, xzr
rt_extract_amount_title_copy:
    cmp x11, x6
    b.hs rt_extract_amount_title_won
    cmp x9, #64
    b.hs rt_extract_amount_title_fail
    ldrb w8, [x4, x11]
    cmp w8, #44
    b.eq rt_extract_amount_title_copy_next
    strb w8, [x10, x9]
    add x9, x9, #1
rt_extract_amount_title_copy_next:
    add x11, x11, #1
    b rt_extract_amount_title_copy
rt_extract_amount_title_won:
    add x11, x6, #3
    cmp x11, x5
    b.hi rt_extract_amount_title_fail
    ldrb w8, [x4, x6]
    mov w12, #236
    cmp w8, w12
    b.ne rt_extract_amount_title_fail
    add x6, x6, #1
    ldrb w8, [x4, x6]
    mov w12, #155
    cmp w8, w12
    b.ne rt_extract_amount_title_fail
    add x6, x6, #1
    ldrb w8, [x4, x6]
    mov w12, #144
    cmp w8, w12
    b.ne rt_extract_amount_title_fail
    add x6, x6, #1
rt_extract_amount_title_space:
    cmp x6, x5
    b.hs rt_extract_amount_title_fail
    ldrb w8, [x4, x6]
    cmp w8, #32
    b.eq rt_extract_amount_title_space_next
    cmp w8, #9
    b.ne rt_extract_amount_title_ip
rt_extract_amount_title_space_next:
    add x6, x6, #1
    b rt_extract_amount_title_space
rt_extract_amount_title_ip:
    add x11, x6, #6
    cmp x11, x5
    b.hi rt_extract_amount_title_fail
    ldrb w8, [x4, x6]
    mov w12, #236
    cmp w8, w12
    b.ne rt_extract_amount_title_fail
    add x6, x6, #1
    ldrb w8, [x4, x6]
    mov w12, #158
    cmp w8, w12
    b.ne rt_extract_amount_title_fail
    add x6, x6, #1
    ldrb w8, [x4, x6]
    mov w12, #133
    cmp w8, w12
    b.ne rt_extract_amount_title_fail
    add x6, x6, #1
    ldrb w8, [x4, x6]
    mov w12, #234
    cmp w8, w12
    b.ne rt_extract_amount_title_fail
    add x6, x6, #1
    ldrb w8, [x4, x6]
    mov w12, #184
    cmp w8, w12
    b.ne rt_extract_amount_title_fail
    add x6, x6, #1
    ldrb w8, [x4, x6]
    mov w12, #136
    cmp w8, w12
    b.ne rt_extract_amount_title_fail
    add x6, x6, #1
    cmp x6, x5
    b.ne rt_extract_amount_title_fail
    strb wzr, [x10, x9]
    adrp x0, rt_amount_length
    add x0, x0, :lo12:rt_amount_length
    str x9, [x0]
    adrp x0, rt_amount_text
    add x0, x0, :lo12:rt_amount_text
    mov x1, x9
    adrp x2, rt_amount_value
    add x2, x2, :lo12:rt_amount_value
    bl yul_parse_amount_ascii
    b rt_extract_amount_title_return
rt_extract_amount_title_fail:
    mov w0, #1
rt_extract_amount_title_return:
    ldp x29, x30, [sp], #16
    ret

rt_extract_amount:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl rt_validate_amount_candidates
    cbnz w0, rt_extract_amount_fail
    adrp x0, rt_filter_amount
    add x0, x0, :lo12:rt_filter_amount
    adrp x1, title_amount_pattern_toss
    add x1, x1, :lo12:title_amount_pattern_toss
    mov x2, #26
    bl rt_str_eq
    cbnz w0, rt_extract_amount_title_only
    b rt_extract_amount_body
rt_extract_amount_title_only:
    bl rt_extract_amount_title
    b rt_extract_amount_return
rt_extract_amount_body:
    adrp x0, label_amount
    add x0, x0, :lo12:label_amount
    mov x1, #6
    bl rt_find_body_sub
    cbnz x0, rt_extract_amount_found
    adrp x0, label_deposit_amount
    add x0, x0, :lo12:label_deposit_amount
    mov x1, #9
    bl rt_find_body_sub
    cbnz x0, rt_extract_amount_found
    adrp x0, label_deposit_amount2
    add x0, x0, :lo12:label_deposit_amount2
    mov x1, #12
    bl rt_find_body_sub
    cbnz x0, rt_extract_amount_found
    adrp x0, label_amount_ascii
    add x0, x0, :lo12:label_amount_ascii
    mov x1, #6
    bl rt_find_body_sub
    cbz x0, rt_extract_amount_fail
rt_extract_amount_found:
    mov x2, x0
rt_extract_amount_skip:
    ldrb w3, [x2]
    cmp w3, #58
    b.eq rt_extract_amount_skip_one
    cmp w3, #32
    b.eq rt_extract_amount_skip_one
    b rt_extract_amount_copy
rt_extract_amount_skip_one:
    add x2, x2, #1
    b rt_extract_amount_skip
rt_extract_amount_copy:
    adrp x4, rt_amount_text
    add x4, x4, :lo12:rt_amount_text
    mov x5, xzr
rt_extract_amount_loop:
    cmp x5, #64
    b.hs rt_extract_amount_fail
    ldrb w3, [x2]
    cmp w3, #44
    b.eq rt_extract_amount_comma
    cmp w3, #48
    b.lo rt_extract_amount_done
    cmp w3, #57
    b.hi rt_extract_amount_done
    strb w3, [x4, x5]
    add x5, x5, #1
    add x2, x2, #1
    b rt_extract_amount_loop
rt_extract_amount_comma:
    add x2, x2, #1
    b rt_extract_amount_loop
rt_extract_amount_done:
    cbz x5, rt_extract_amount_fail
    strb wzr, [x4, x5]
    adrp x0, rt_amount_length
    add x0, x0, :lo12:rt_amount_length
    str x5, [x0]
    adrp x0, rt_amount_text
    add x0, x0, :lo12:rt_amount_text
    adrp x1, rt_amount_length
    add x1, x1, :lo12:rt_amount_length
    ldr x1, [x1]
    adrp x2, rt_amount_value
    add x2, x2, :lo12:rt_amount_value
    bl yul_parse_amount_ascii
    b rt_extract_amount_return
rt_extract_amount_fail:
    mov w0, #1
rt_extract_amount_return:
    ldp x29, x30, [sp], #16
    ret

rt_validate_name_candidates:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    adrp x0, rt_filter_name
    add x0, x0, :lo12:rt_filter_name
    adrp x1, arrow_bank_name_pattern
    add x1, x1, :lo12:arrow_bank_name_pattern
    mov x2, #57
    bl rt_str_eq
    cbnz w0, rt_validate_name_arrow
    bl rt_count_name_candidates
    cmp x0, #1
    b.eq rt_validate_name_good
    b rt_validate_name_bad
rt_validate_name_arrow:
    bl rt_count_arrow_candidates
    cmp x0, #1
    b.eq rt_validate_name_good
rt_validate_name_bad:
    mov w0, #1
    b rt_validate_name_return
rt_validate_name_good:
    mov w0, wzr
rt_validate_name_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_validate_amount_candidates:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    adrp x0, rt_filter_amount
    add x0, x0, :lo12:rt_filter_amount
    adrp x1, title_amount_pattern_toss
    add x1, x1, :lo12:title_amount_pattern_toss
    mov x2, #26
    bl rt_str_eq
    cbnz w0, rt_validate_amount_title
    bl rt_count_amount_candidates
    cmp x0, #1
    b.eq rt_validate_amount_good
    b rt_validate_amount_bad
rt_validate_amount_title:
    bl rt_count_title_amount_candidates
    cmp x0, #1
    b.eq rt_validate_amount_good
    b rt_validate_amount_bad
rt_validate_amount_bad:
    mov w0, #1
    b rt_validate_amount_return
rt_validate_amount_good:
    mov w0, wzr
rt_validate_amount_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_count_name_candidates:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    adrp x0, rt_body
    add x0, x0, :lo12:rt_body
    adrp x1, rt_body_length
    add x1, x1, :lo12:rt_body_length
    ldr x1, [x1]
    bl rt_count_name_labels_text
    mov x19, x0
    cmp x19, #2
    b.hs rt_count_name_candidates_two
    adrp x0, rt_title
    add x0, x0, :lo12:rt_title
    adrp x1, rt_title_length
    add x1, x1, :lo12:rt_title_length
    ldr x1, [x1]
    bl rt_count_name_labels_text
    add x0, x19, x0
    cmp x0, #2
    b.hs rt_count_name_candidates_two
    b rt_count_name_candidates_return
rt_count_name_candidates_two:
    mov x0, #2
rt_count_name_candidates_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_count_amount_candidates:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    adrp x0, rt_body
    add x0, x0, :lo12:rt_body
    adrp x1, rt_body_length
    add x1, x1, :lo12:rt_body_length
    ldr x1, [x1]
    bl rt_count_amount_labels_text
    mov x19, x0
    cmp x19, #2
    b.hs rt_count_amount_candidates_two
    adrp x0, rt_title
    add x0, x0, :lo12:rt_title
    adrp x1, rt_title_length
    add x1, x1, :lo12:rt_title_length
    ldr x1, [x1]
    bl rt_count_amount_labels_text
    add x0, x19, x0
    cmp x0, #2
    b.hs rt_count_amount_candidates_two
    b rt_count_amount_candidates_return
rt_count_amount_candidates_two:
    mov x0, #2
rt_count_amount_candidates_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_count_arrow_candidates:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    adrp x0, rt_body
    add x0, x0, :lo12:rt_body
    adrp x1, rt_body_length
    add x1, x1, :lo12:rt_body_length
    ldr x1, [x1]
    bl rt_count_arrow_candidates_text
    mov x19, x0
    cmp x19, #2
    b.hs rt_count_arrow_candidates_two
    adrp x0, rt_title
    add x0, x0, :lo12:rt_title
    adrp x1, rt_title_length
    add x1, x1, :lo12:rt_title_length
    ldr x1, [x1]
    bl rt_count_arrow_candidates_text
    add x0, x19, x0
    cmp x0, #2
    b.hs rt_count_arrow_candidates_two
    b rt_count_arrow_candidates_return
rt_count_arrow_candidates_two:
    mov x0, #2
rt_count_arrow_candidates_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_name_label_length:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x6, x0
    mov x7, x1
    mov x8, x2
    cbz x8, rt_name_label_length_boundary_ready
    sub x9, x8, #1
    ldrb w10, [x6, x9]
    cmp w10, #48
    b.lo rt_name_label_length_boundary_ascii_upper
    cmp w10, #57
    b.ls rt_name_label_length_none
rt_name_label_length_boundary_ascii_upper:
    cmp w10, #65
    b.lo rt_name_label_length_boundary_underscore
    cmp w10, #90
    b.ls rt_name_label_length_none
rt_name_label_length_boundary_underscore:
    cmp w10, #95
    b.eq rt_name_label_length_none
    cmp w10, #97
    b.lo rt_name_label_length_boundary_ready
    cmp w10, #122
    b.ls rt_name_label_length_none
rt_name_label_length_boundary_ready:
    cmp x7, #13
    b.lo rt_name_label_length_sender
    adrp x0, label_sender_space
    add x0, x0, :lo12:label_sender_space
    mov x1, #13
    add x2, x6, x8
    bl rt_mem_eq
    cbnz w0, rt_name_label_length_13
rt_name_label_length_sender:
    cmp x7, #9
    b.lo rt_name_label_length_ascii_sender
    adrp x0, label_name
    add x0, x0, :lo12:label_name
    mov x1, #9
    add x2, x6, x8
    bl rt_mem_eq
    cbnz w0, rt_name_label_length_9
    adrp x0, label_sender
    add x0, x0, :lo12:label_sender
    mov x1, #9
    add x2, x6, x8
    bl rt_mem_eq
    cbnz w0, rt_name_label_length_9
rt_name_label_length_ascii_sender:
    cmp x7, #6
    b.lo rt_name_label_length_ascii_name
    adrp x0, label_sender_ascii
    add x0, x0, :lo12:label_sender_ascii
    mov x1, #6
    add x2, x6, x8
    bl rt_mem_eq
    cbnz w0, rt_name_label_length_6
rt_name_label_length_ascii_name:
    cmp x7, #4
    b.lo rt_name_label_length_none
    adrp x0, label_name_ascii
    add x0, x0, :lo12:label_name_ascii
    mov x1, #4
    add x2, x6, x8
    bl rt_mem_eq
    cbnz w0, rt_name_label_length_4
rt_name_label_length_none:
    mov x0, xzr
    b rt_name_label_length_return
rt_name_label_length_13:
    mov x0, x6
    mov x1, x7
    mov x2, x8
    mov x3, #13
    bl rt_label_suffix_boundary
    cbz w0, rt_name_label_length_none
    mov x0, #13
    b rt_name_label_length_return
rt_name_label_length_9:
    mov x0, x6
    mov x1, x7
    mov x2, x8
    mov x3, #9
    bl rt_label_suffix_boundary
    cbz w0, rt_name_label_length_none
    mov x0, #9
    b rt_name_label_length_return
rt_name_label_length_6:
    mov x0, x6
    mov x1, x7
    mov x2, x8
    mov x3, #6
    bl rt_label_suffix_boundary
    cbz w0, rt_name_label_length_none
    mov x0, #6
    b rt_name_label_length_return
rt_name_label_length_4:
    mov x0, x6
    mov x1, x7
    mov x2, x8
    mov x3, #4
    bl rt_label_suffix_boundary
    cbz w0, rt_name_label_length_none
    mov x0, #4
rt_name_label_length_return:
    ldp x29, x30, [sp], #16
    ret

rt_amount_label_length:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x6, x0
    mov x7, x1
    mov x8, x2
    cbz x8, rt_amount_label_length_boundary_ready
    sub x9, x8, #1
    ldrb w10, [x6, x9]
    cmp w10, #48
    b.lo rt_amount_label_length_boundary_ascii_upper
    cmp w10, #57
    b.ls rt_amount_label_length_none
rt_amount_label_length_boundary_ascii_upper:
    cmp w10, #65
    b.lo rt_amount_label_length_boundary_underscore
    cmp w10, #90
    b.ls rt_amount_label_length_none
rt_amount_label_length_boundary_underscore:
    cmp w10, #95
    b.eq rt_amount_label_length_none
    cmp w10, #97
    b.lo rt_amount_label_length_boundary_ready
    cmp w10, #122
    b.ls rt_amount_label_length_none
rt_amount_label_length_boundary_ready:
    cmp x7, #12
    b.lo rt_amount_label_length_9_check
    adrp x0, label_deposit_amount2
    add x0, x0, :lo12:label_deposit_amount2
    mov x1, #12
    add x2, x6, x8
    bl rt_mem_eq
    cbnz w0, rt_amount_label_length_12
rt_amount_label_length_9_check:
    cmp x7, #9
    b.lo rt_amount_label_length_6_check
    adrp x0, label_deposit_amount
    add x0, x0, :lo12:label_deposit_amount
    mov x1, #9
    add x2, x6, x8
    bl rt_mem_eq
    cbnz w0, rt_amount_label_length_9
rt_amount_label_length_6_check:
    cmp x7, #6
    b.lo rt_amount_label_length_none
    adrp x0, label_amount
    add x0, x0, :lo12:label_amount
    mov x1, #6
    add x2, x6, x8
    bl rt_mem_eq
    cbnz w0, rt_amount_label_length_6
    adrp x0, label_amount_ascii
    add x0, x0, :lo12:label_amount_ascii
    mov x1, #6
    add x2, x6, x8
    bl rt_mem_eq
    cbnz w0, rt_amount_label_length_6
rt_amount_label_length_none:
    mov x0, xzr
    b rt_amount_label_length_return
rt_amount_label_length_12:
    mov x0, x6
    mov x1, x7
    mov x2, x8
    mov x3, #12
    bl rt_label_suffix_boundary
    cbz w0, rt_amount_label_length_none
    mov x0, #12
    b rt_amount_label_length_return
rt_amount_label_length_9:
    mov x0, x6
    mov x1, x7
    mov x2, x8
    mov x3, #9
    bl rt_label_suffix_boundary
    cbz w0, rt_amount_label_length_none
    mov x0, #9
    b rt_amount_label_length_return
rt_amount_label_length_6:
    mov x0, x6
    mov x1, x7
    mov x2, x8
    mov x3, #6
    bl rt_label_suffix_boundary
    cbz w0, rt_amount_label_length_none
    mov x0, #6
rt_amount_label_length_return:
    ldp x29, x30, [sp], #16
    ret

rt_label_suffix_boundary:
    add x4, x2, x3
    cmp x4, x1
    b.hs rt_label_suffix_boundary_yes
    add x5, x0, x4
    ldrb w4, [x5]
    cmp w4, #48
    b.lo rt_label_suffix_boundary_ascii_upper
    cmp w4, #57
    b.ls rt_label_suffix_boundary_yes
rt_label_suffix_boundary_ascii_upper:
    cmp w4, #65
    b.lo rt_label_suffix_boundary_underscore
    cmp w4, #90
    b.ls rt_label_suffix_boundary_no
rt_label_suffix_boundary_underscore:
    cmp w4, #95
    b.eq rt_label_suffix_boundary_no
    cmp w4, #97
    b.lo rt_label_suffix_boundary_yes
    cmp w4, #122
    b.ls rt_label_suffix_boundary_no
rt_label_suffix_boundary_yes:
    mov w0, #1
    ret
rt_label_suffix_boundary_no:
    mov w0, wzr
    ret

rt_count_name_labels_text:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, xzr
    mov x22, xzr
rt_count_name_labels_loop:
    cmp x21, x20
    b.hs rt_count_name_labels_done
    mov x0, x19
    mov x1, x20
    mov x2, x21
    bl rt_name_label_length
    cbz x0, rt_count_name_labels_next
    mov x23, x0
    add x24, x21, x23
rt_count_name_labels_skip:
    cmp x24, x20
    b.hs rt_count_name_labels_invalid
    ldrb w0, [x19, x24]
    cmp w0, #58
    b.eq rt_count_name_labels_skip_one
    cmp w0, #32
    b.eq rt_count_name_labels_skip_one
    cmp w0, #9
    b.eq rt_count_name_labels_skip_one
    cmp w0, #239
    b.ne rt_count_name_labels_value
    add x3, x24, #3
    cmp x3, x20
    b.hi rt_count_name_labels_invalid
    add x3, x19, x24
    ldrb w0, [x3, #1]
    cmp w0, #188
    b.ne rt_count_name_labels_value
    ldrb w0, [x3, #2]
    cmp w0, #154
    b.ne rt_count_name_labels_value
    add x24, x24, #3
    b rt_count_name_labels_skip
rt_count_name_labels_skip_one:
    add x24, x24, #1
    b rt_count_name_labels_skip
rt_count_name_labels_value:
    cmp x24, x20
    b.hs rt_count_name_labels_invalid
    ldrb w0, [x19, x24]
    cbz w0, rt_count_name_labels_invalid
    cmp w0, #10
    b.eq rt_count_name_labels_invalid
    cmp w0, #13
    b.eq rt_count_name_labels_invalid
    cmp w0, #44
    b.eq rt_count_name_labels_invalid
    cmp w0, #40
    b.eq rt_count_name_labels_invalid
    cmp w0, #41
    b.eq rt_count_name_labels_invalid
    mov x3, x24
rt_count_name_labels_end:
    cmp x3, x20
    b.hs rt_count_name_labels_valid
    ldrb w0, [x19, x3]
    cbz w0, rt_count_name_labels_invalid
    cmp w0, #10
    b.eq rt_count_name_labels_valid
    cmp w0, #13
    b.eq rt_count_name_labels_valid
    cmp w0, #44
    b.eq rt_count_name_labels_valid
    cmp w0, #40
    b.eq rt_count_name_labels_valid
    cmp w0, #41
    b.eq rt_count_name_labels_valid
    add x3, x3, #1
    b rt_count_name_labels_end
rt_count_name_labels_valid:
    add x22, x22, #1
    cmp x22, #2
    b.hs rt_count_name_labels_two
    cmp x3, x20
    b.hs rt_count_name_labels_done
    add x21, x3, #1
    b rt_count_name_labels_loop
rt_count_name_labels_next:
    add x21, x21, #1
    b rt_count_name_labels_loop
rt_count_name_labels_two:
    mov x0, #2
    b rt_count_name_labels_return
rt_count_name_labels_invalid:
    mov x0, #2
    b rt_count_name_labels_return
rt_count_name_labels_done:
    mov x0, x22
rt_count_name_labels_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_count_amount_labels_text:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, xzr
    mov x22, xzr
rt_count_amount_labels_loop:
    cmp x21, x20
    b.hs rt_count_amount_labels_done
    mov x0, x19
    mov x1, x20
    mov x2, x21
    bl rt_amount_label_length
    cbz x0, rt_count_amount_labels_next
    mov x23, x0
    add x24, x21, x23
rt_count_amount_labels_skip:
    cmp x24, x20
    b.hs rt_count_amount_labels_invalid
    ldrb w0, [x19, x24]
    cmp w0, #58
    b.eq rt_count_amount_labels_skip_one
    cmp w0, #32
    b.eq rt_count_amount_labels_skip_one
    cmp w0, #9
    b.eq rt_count_amount_labels_skip_one
    cmp w0, #10
    b.eq rt_count_amount_labels_skip_one
    cmp w0, #13
    b.eq rt_count_amount_labels_skip_one
    cmp w0, #239
    b.ne rt_count_amount_labels_value
    add x3, x24, #3
    cmp x3, x20
    b.hi rt_count_amount_labels_invalid
    add x3, x19, x24
    ldrb w0, [x3, #1]
    cmp w0, #188
    b.ne rt_count_amount_labels_value
    ldrb w0, [x3, #2]
    cmp w0, #154
    b.ne rt_count_amount_labels_value
    add x24, x24, #3
    b rt_count_amount_labels_skip
rt_count_amount_labels_skip_one:
    add x24, x24, #1
    b rt_count_amount_labels_skip
rt_count_amount_labels_value:
    cmp x24, x20
    b.hs rt_count_amount_labels_invalid
    ldrb w0, [x19, x24]
    cmp w0, #48
    b.lo rt_count_amount_labels_invalid
    cmp w0, #57
    b.hi rt_count_amount_labels_invalid
    mov x3, x24
rt_count_amount_labels_digits:
    cmp x3, x20
    b.hs rt_count_amount_labels_valid
    ldrb w0, [x19, x3]
    cmp w0, #48
    b.lo rt_count_amount_labels_digits_done
    cmp w0, #57
    b.hi rt_count_amount_labels_digits_comma
    add x3, x3, #1
    b rt_count_amount_labels_digits
rt_count_amount_labels_digits_comma:
    cmp w0, #44
    b.ne rt_count_amount_labels_valid
    add x3, x3, #1
    b rt_count_amount_labels_digits
rt_count_amount_labels_digits_done:
rt_count_amount_labels_valid:
    add x22, x22, #1
    cmp x22, #2
    b.hs rt_count_amount_labels_two
    cmp x3, x20
    b.hs rt_count_amount_labels_done
    add x21, x3, #1
    b rt_count_amount_labels_loop
rt_count_amount_labels_next:
    add x21, x21, #1
    b rt_count_amount_labels_loop
rt_count_amount_labels_two:
    mov x0, #2
    b rt_count_amount_labels_return
rt_count_amount_labels_invalid:
    mov x0, #2
    b rt_count_amount_labels_return
rt_count_amount_labels_done:
    mov x0, x22
rt_count_amount_labels_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_count_arrow_candidates_text:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, xzr
    mov x22, xzr
rt_count_arrow_candidates_text_loop:
    add x3, x21, #3
    cmp x3, x20
    b.hi rt_count_arrow_candidates_text_done
    add x3, x19, x21
    ldrb w4, [x3]
    cmp w4, #226
    b.ne rt_count_arrow_candidates_text_next
    ldrb w4, [x3, #1]
    cmp w4, #134
    b.ne rt_count_arrow_candidates_text_next
    ldrb w4, [x3, #2]
    cmp w4, #146
    b.ne rt_count_arrow_candidates_text_next
    add x22, x22, #1
    cmp x22, #2
    b.hs rt_count_arrow_candidates_text_two
rt_count_arrow_candidates_text_next:
    add x21, x21, #1
    b rt_count_arrow_candidates_text_loop
rt_count_arrow_candidates_text_two:
    mov x0, #2
    b rt_count_arrow_candidates_text_return
rt_count_arrow_candidates_text_done:
    mov x0, x22
rt_count_arrow_candidates_text_return:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

rt_count_title_amount_candidates:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    adrp x0, rt_body
    add x0, x0, :lo12:rt_body
    adrp x1, rt_body_length
    add x1, x1, :lo12:rt_body_length
    ldr x1, [x1]
    bl rt_count_title_amount_text
    mov x19, x0
    cmp x19, #2
    b.hs rt_count_title_amount_candidates_two
    adrp x0, rt_title
    add x0, x0, :lo12:rt_title
    adrp x1, rt_title_length
    add x1, x1, :lo12:rt_title_length
    ldr x1, [x1]
    bl rt_count_title_amount_text
    add x0, x19, x0
    cmp x0, #2
    b.hs rt_count_title_amount_candidates_two
    b rt_count_title_amount_candidates_return
rt_count_title_amount_candidates_two:
    mov x0, #2
rt_count_title_amount_candidates_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_count_title_amount_text:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, xzr
    mov x22, xzr
rt_count_title_amount_text_loop:
    cmp x21, x20
    b.hs rt_count_title_amount_text_done
    ldrb w0, [x19, x21]
    cmp w0, #48
    b.lo rt_count_title_amount_text_next
    cmp w0, #57
    b.hi rt_count_title_amount_text_next
    mov x23, x21
rt_count_title_amount_text_digits:
    cmp x23, x20
    b.hs rt_count_title_amount_text_next
    ldrb w0, [x19, x23]
    cmp w0, #44
    b.eq rt_count_title_amount_text_digits_comma
    cmp w0, #48
    b.lo rt_count_title_amount_text_digits_done
    cmp w0, #57
    b.hi rt_count_title_amount_text_digits_done
    add x23, x23, #1
    b rt_count_title_amount_text_digits
rt_count_title_amount_text_digits_comma:
    add x23, x23, #1
    b rt_count_title_amount_text_digits
rt_count_title_amount_text_digits_done:
    add x24, x23, #3
    cmp x24, x20
    b.hi rt_count_title_amount_text_next
    add x3, x19, x23
    ldrb w0, [x3]
    cmp w0, #236
    b.ne rt_count_title_amount_text_next
    ldrb w0, [x3, #1]
    cmp w0, #155
    b.ne rt_count_title_amount_text_next
    ldrb w0, [x3, #2]
    cmp w0, #144
    b.ne rt_count_title_amount_text_next
    add x23, x23, #3
rt_count_title_amount_text_space:
    cmp x23, x20
    b.hs rt_count_title_amount_text_next
    ldrb w0, [x19, x23]
    cmp w0, #32
    b.eq rt_count_title_amount_text_space_one
    cmp w0, #9
    b.eq rt_count_title_amount_text_space_one
    cmp w0, #10
    b.eq rt_count_title_amount_text_space_one
    cmp w0, #13
    b.ne rt_count_title_amount_text_deposit
rt_count_title_amount_text_space_one:
    add x23, x23, #1
    b rt_count_title_amount_text_space
rt_count_title_amount_text_deposit:
    add x24, x23, #6
    cmp x24, x20
    b.hi rt_count_title_amount_text_next
    add x3, x19, x23
    ldrb w0, [x3]
    cmp w0, #236
    b.ne rt_count_title_amount_text_next
    ldrb w0, [x3, #1]
    cmp w0, #158
    b.ne rt_count_title_amount_text_next
    ldrb w0, [x3, #2]
    cmp w0, #133
    b.ne rt_count_title_amount_text_next
    ldrb w0, [x3, #3]
    cmp w0, #234
    b.ne rt_count_title_amount_text_next
    ldrb w0, [x3, #4]
    cmp w0, #184
    b.ne rt_count_title_amount_text_next
    ldrb w0, [x3, #5]
    cmp w0, #136
    b.ne rt_count_title_amount_text_next
    add x22, x22, #1
    cmp x22, #2
    b.hs rt_count_title_amount_text_two
    add x21, x23, #6
    b rt_count_title_amount_text_loop
rt_count_title_amount_text_next:
    add x21, x21, #1
    b rt_count_title_amount_text_loop
rt_count_title_amount_text_two:
    mov x0, #2
    b rt_count_title_amount_text_return
rt_count_title_amount_text_done:
    mov x0, x22
rt_count_title_amount_text_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_find_body_sub:
    adrp x4, rt_body
    add x4, x4, :lo12:rt_body
    adrp x5, rt_body_length
    add x5, x5, :lo12:rt_body_length
    ldr x5, [x5]
    mov x6, xzr
rt_find_body_loop:
    cmp x6, x5
    b.hs rt_find_body_none
    cmp x5, x1
    b.lo rt_find_body_none
    sub x7, x5, x1
    cmp x6, x7
    b.hi rt_find_body_none
    add x7, x4, x6
    mov x8, xzr
rt_find_body_compare:
    cmp x8, x1
    b.hs rt_find_body_found
    ldrb w9, [x7, x8]
    ldrb w10, [x0, x8]
    cmp w9, w10
    b.ne rt_find_body_next
    add x8, x8, #1
    b rt_find_body_compare
rt_find_body_found:
    add x0, x7, x1
    ret
rt_find_body_next:
    add x6, x6, #1
    b rt_find_body_loop
rt_find_body_none:
    mov x0, xzr
    ret

rt_find_title_sub:
    adrp x4, rt_title
    add x4, x4, :lo12:rt_title
    adrp x5, rt_title_length
    add x5, x5, :lo12:rt_title_length
    ldr x5, [x5]
    mov x6, xzr
rt_find_title_loop:
    cmp x6, x5
    b.hs rt_find_title_none
    cmp x5, x1
    b.lo rt_find_title_none
    sub x7, x5, x1
    cmp x6, x7
    b.hi rt_find_title_none
    add x7, x4, x6
    mov x8, xzr
rt_find_title_compare:
    cmp x8, x1
    b.hs rt_find_title_found
    ldrb w9, [x7, x8]
    ldrb w10, [x0, x8]
    cmp w9, w10
    b.ne rt_find_title_next
    add x8, x8, #1
    b rt_find_title_compare
rt_find_title_found:
    add x0, x7, x1
    ret
rt_find_title_next:
    add x6, x6, #1
    b rt_find_title_loop
rt_find_title_none:
    mov x0, xzr
    ret

rt_check_title_pattern:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_filter_title_pattern_length
    add x0, x0, :lo12:rt_filter_title_pattern_length
    ldr x1, [x0]
    cbz x1, rt_check_title_pattern_good
    adrp x0, rt_filter_title_pattern
    add x0, x0, :lo12:rt_filter_title_pattern
    adrp x1, rt_filter_title_pattern_length
    add x1, x1, :lo12:rt_filter_title_pattern_length
    adrp x2, title_pattern_toss
    add x2, x2, :lo12:title_pattern_toss
    mov x3, xzr
    bl rt_validate_pattern_contract
    cbnz w0, rt_check_title_pattern_bad
    adrp x4, rt_title
    add x4, x4, :lo12:rt_title
    adrp x5, rt_title_length
    add x5, x5, :lo12:rt_title_length
    ldr x5, [x5]
    mov x6, xzr
    mov x7, xzr
rt_check_title_digits:
    cmp x6, x5
    b.hs rt_check_title_digits_done
    ldrb w8, [x4, x6]
    cmp w8, #48
    b.lo rt_check_title_digits_done
    cmp w8, #57
    b.hi rt_check_title_digits_comma
    add x7, x7, #1
    add x6, x6, #1
    b rt_check_title_digits
rt_check_title_digits_comma:
    cmp w8, #44
    b.ne rt_check_title_digits_done
    cbz x7, rt_check_title_pattern_bad
    add x6, x6, #1
    b rt_check_title_digits
rt_check_title_digits_done:
    cbz x7, rt_check_title_pattern_bad
    add x8, x6, #3
    cmp x8, x5
    b.hs rt_check_title_pattern_bad
    ldrb w9, [x4, x6]
    cmp w9, #236
    b.ne rt_check_title_pattern_bad
    add x10, x4, x6
    ldrb w9, [x10, #1]
    cmp w9, #155
    b.ne rt_check_title_pattern_bad
    ldrb w9, [x10, #2]
    cmp w9, #144
    b.ne rt_check_title_pattern_bad
    add x6, x6, #3
rt_check_title_pattern_space:
    cmp x6, x5
    b.hs rt_check_title_pattern_bad
    ldrb w8, [x4, x6]
    cmp w8, #32
    b.eq rt_check_title_pattern_space_one
    cmp w8, #9
    b.eq rt_check_title_pattern_space_one
    cmp w8, #10
    b.eq rt_check_title_pattern_space_one
    cmp w8, #13
    b.ne rt_check_title_pattern_deposit
rt_check_title_pattern_space_one:
    add x6, x6, #1
    b rt_check_title_pattern_space
rt_check_title_pattern_deposit:
    add x8, x6, #6
    cmp x8, x5
    b.ne rt_check_title_pattern_bad
    ldrb w9, [x4, x6]
    cmp w9, #236
    b.ne rt_check_title_pattern_bad
    add x10, x4, x6
    ldrb w9, [x10, #1]
    cmp w9, #158
    b.ne rt_check_title_pattern_bad
    ldrb w9, [x10, #2]
    cmp w9, #133
    b.ne rt_check_title_pattern_bad
    ldrb w9, [x10, #3]
    cmp w9, #234
    b.ne rt_check_title_pattern_bad
    ldrb w9, [x10, #4]
    cmp w9, #184
    b.ne rt_check_title_pattern_bad
    ldrb w9, [x10, #5]
    cmp w9, #136
    b.ne rt_check_title_pattern_bad
    b rt_check_title_pattern_good
rt_check_title_pattern_good:
    mov w0, wzr
    b rt_check_title_pattern_return
rt_check_title_pattern_bad:
    mov w0, #1
rt_check_title_pattern_return:
    ldp x29, x30, [sp], #16
    ret

rt_check_filters:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_filter_package_length
    add x0, x0, :lo12:rt_filter_package_length
    ldr x1, [x0]
    cbz x1, rt_filters_bad
    adrp x0, rt_package
    add x0, x0, :lo12:rt_package
    adrp x2, rt_filter_package
    add x2, x2, :lo12:rt_filter_package
    adrp x3, rt_package_length
    add x3, x3, :lo12:rt_package_length
    ldr x3, [x3]
    cmp x3, x1
    b.ne rt_filters_bad
    bl rt_mem_eq
    cbz w0, rt_filters_bad
rt_filter_application_check:
    adrp x0, rt_filter_application_length
    add x0, x0, :lo12:rt_filter_application_length
    ldr x1, [x0]
    cbz x1, rt_filters_bad
    adrp x0, rt_application
    add x0, x0, :lo12:rt_application
    adrp x2, rt_filter_application
    add x2, x2, :lo12:rt_filter_application
    adrp x3, rt_application_length
    add x3, x3, :lo12:rt_application_length
    ldr x3, [x3]
    cmp x3, x1
    b.ne rt_filters_bad
    bl rt_mem_eq
    cbz w0, rt_filters_bad
rt_filter_title_check:
    adrp x0, rt_filter_title_length
    add x0, x0, :lo12:rt_filter_title_length
    ldr x1, [x0]
    cbz x1, rt_filter_title_pattern_only
    adrp x0, rt_title
    add x0, x0, :lo12:rt_title
    adrp x2, rt_filter_title
    add x2, x2, :lo12:rt_filter_title
    bl rt_prefix_eq
    cbz w0, rt_filters_bad
    b rt_filter_title_pattern_optional
rt_filter_title_pattern_only:
    adrp x0, rt_filter_title_pattern_length
    add x0, x0, :lo12:rt_filter_title_pattern_length
    ldr x1, [x0]
    cbz x1, rt_filters_bad
    b rt_filter_title_pattern_check
rt_filter_title_pattern_optional:
rt_filter_title_pattern_check:
    adrp x0, rt_filter_title_pattern_length
    add x0, x0, :lo12:rt_filter_title_pattern_length
    ldr x1, [x0]
    bl rt_check_title_pattern
    cbnz w0, rt_filters_bad
rt_filters_good:
    mov w0, wzr
    b rt_check_filters_return
rt_filters_bad:
    mov w0, #1
rt_check_filters_return:
    ldp x29, x30, [sp], #16
    ret

rt_mem_eq:
    mov x3, xzr
rt_mem_eq_loop:
    cmp x3, x1
    b.hs rt_mem_eq_yes
    ldrb w4, [x0, x3]
    ldrb w5, [x2, x3]
    cmp w4, w5
    b.ne rt_mem_eq_no
    add x3, x3, #1
    b rt_mem_eq_loop
rt_mem_eq_yes:
    mov w0, #1
    ret
rt_mem_eq_no:
    mov w0, wzr
    ret

rt_prefix_eq:
    mov x3, xzr
rt_prefix_eq_loop:
    cmp x3, x1
    b.hs rt_mem_eq_yes
    ldrb w4, [x0, x3]
    ldrb w5, [x2, x3]
    cmp w4, w5
    b.ne rt_mem_eq_no
    add x3, x3, #1
    b rt_prefix_eq_loop

rt_check_duplicate:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_duplicate
    add x1, x1, :lo12:sql_duplicate
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_check_duplicate_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    adrp x2, rt_push_id
    add x2, x2, :lo12:rt_push_id
    adrp x3, rt_push_id_length
    add x3, x3, :lo12:rt_push_id_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    mov w19, #1
    cmp w0, #100
    b.eq rt_check_duplicate_done
    mov w19, wzr
    cmp w0, #101
    b.ne rt_check_duplicate_fail
rt_check_duplicate_done:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    mov w0, w19
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
rt_check_duplicate_fail:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    mov w0, #2
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_insert_push_received:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_insert_push
    add x1, x1, :lo12:sql_insert_push
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_insert_push_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    adrp x2, rt_push_id
    add x2, x2, :lo12:rt_push_id
    adrp x3, rt_push_id_length
    add x3, x3, :lo12:rt_push_id_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #2
    adrp x2, rt_package
    add x2, x2, :lo12:rt_package
    adrp x3, rt_package_length
    add x3, x3, :lo12:rt_package_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #3
    adrp x2, rt_application
    add x2, x2, :lo12:rt_application
    adrp x3, rt_application_length
    add x3, x3, :lo12:rt_application_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #4
    adrp x2, rt_title
    add x2, x2, :lo12:rt_title
    adrp x3, rt_title_length
    add x3, x3, :lo12:rt_title_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #5
    adrp x4, rt_parsed_name_length
    add x4, x4, :lo12:rt_parsed_name_length
    ldr x4, [x4]
    cbz x4, rt_insert_push_name_null
    adrp x2, rt_parsed_name
    add x2, x2, :lo12:rt_parsed_name
    mov x3, x4
    bl yul_sqlite_bind_text
    b rt_insert_push_name_done
rt_insert_push_name_null:
    bl yul_sqlite_bind_null
rt_insert_push_name_done:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #6
    adrp x4, rt_normalized_length
    add x4, x4, :lo12:rt_normalized_length
    ldr x4, [x4]
    cbz x4, rt_insert_push_normalized_null
    adrp x2, rt_normalized
    add x2, x2, :lo12:rt_normalized
    mov x3, x4
    bl yul_sqlite_bind_text
    b rt_insert_push_normalized_done
rt_insert_push_normalized_null:
    bl yul_sqlite_bind_null
rt_insert_push_normalized_done:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #7
    adrp x4, rt_amount_length
    add x4, x4, :lo12:rt_amount_length
    ldr x4, [x4]
    cbz x4, rt_insert_push_amount_null
    adrp x2, rt_amount_value
    add x2, x2, :lo12:rt_amount_value
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    b rt_insert_push_amount_done
rt_insert_push_amount_null:
    bl yul_sqlite_bind_null
rt_insert_push_amount_done:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #8
    adrp x2, status_received
    add x2, x2, :lo12:status_received
    mov x3, #8
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #9
    adrp x2, rt_created_at
    add x2, x2, :lo12:rt_created_at
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #10
    adrp x4, rt_push_created_present
    add x4, x4, :lo12:rt_push_created_present
    ldr w4, [x4]
    cbz w4, rt_insert_push_created_null
    adrp x2, rt_push_created_at
    add x2, x2, :lo12:rt_push_created_at
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    b rt_insert_push_created_done
rt_insert_push_created_null:
    bl yul_sqlite_bind_null
rt_insert_push_created_done:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #11
    adrp x4, rt_push_modified_present
    add x4, x4, :lo12:rt_push_modified_present
    ldr w4, [x4]
    cbz w4, rt_insert_push_modified_null
    adrp x2, rt_push_modified_at
    add x2, x2, :lo12:rt_push_modified_at
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    b rt_insert_push_modified_done
rt_insert_push_modified_null:
    bl yul_sqlite_bind_null
rt_insert_push_modified_done:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #101
    b.ne rt_insert_push_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    mov w0, wzr
    b rt_insert_push_return
rt_insert_push_fail:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    mov w0, #1
rt_insert_push_return:
    ldp x29, x30, [sp], #16
    ret

rt_update_push_status:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    adrp x0, rt_status_scratch
    add x0, x0, :lo12:rt_status_scratch
    adrp x1, rt_status_scratch
    add x1, x1, :lo12:rt_status_scratch
    mov x0, x20
    bl rt_copy_cstr
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_update_push_status
    add x1, x1, :lo12:sql_update_push_status
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_update_push_fail
    adrp x21, rt_statement
    add x21, x21, :lo12:rt_statement
    ldr x0, [x21]
    mov x22, x0
    mov x1, #1
    adrp x2, rt_status_scratch
    add x2, x2, :lo12:rt_status_scratch
    mov x0, x2
    bl rt_cstr_length
    mov x3, x0
    mov x0, x22
    mov x1, #1
    adrp x2, rt_status_scratch
    add x2, x2, :lo12:rt_status_scratch
    bl yul_sqlite_bind_text
    ldr x0, [x21]
    mov x1, #2
    adrp x2, rt_push_id
    add x2, x2, :lo12:rt_push_id
    adrp x3, rt_push_id_length
    add x3, x3, :lo12:rt_push_id_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    ldr x0, [x21]
    bl yul_sqlite_step
    cmp w0, #101
    b.ne rt_update_push_fail
    ldr x0, [x21]
    bl yul_sqlite_finalize
    mov w0, wzr
    b rt_update_push_return
rt_update_push_fail:
    adrp x21, rt_statement
    add x21, x21, :lo12:rt_statement
    ldr x0, [x21]
    cbz x0, rt_update_push_fail_done
    bl yul_sqlite_finalize
rt_update_push_fail_done:
    mov w0, #1
rt_update_push_return:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

rt_credit:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_expire
    add x1, x1, :lo12:sql_expire
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_credit_error
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    adrp x2, rt_created_at
    add x2, x2, :lo12:rt_created_at
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #101
    b.ne rt_credit_statement_error
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_find_order
    add x1, x1, :lo12:sql_find_order
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_credit_error
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    adrp x2, rt_normalized
    add x2, x2, :lo12:rt_normalized
    adrp x3, rt_normalized_length
    add x3, x3, :lo12:rt_normalized_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #2
    adrp x2, rt_amount_value
    add x2, x2, :lo12:rt_amount_value
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #3
    adrp x2, rt_created_at
    add x2, x2, :lo12:rt_created_at
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #4
    adrp x2, rt_push_event_time
    add x2, x2, :lo12:rt_push_event_time
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #100
    b.ne rt_credit_no_match
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x0, [x1]
    mov x1, #0
    bl yul_sqlite_column_text
    adrp x1, rt_credit_order_id
    add x1, x1, :lo12:rt_credit_order_id
    mov x2, #128
    bl rt_copy_cstr_bounded
    cbnz w0, rt_credit_statement_error
    adrp x0, rt_credit_order_id
    add x0, x0, :lo12:rt_credit_order_id
    bl rt_cstr_length
    adrp x1, rt_credit_order_id_length
    add x1, x1, :lo12:rt_credit_order_id_length
    str x0, [x1]
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x0, [x1]
    mov x1, #1
    bl yul_sqlite_column_text
    adrp x1, rt_credit_discord_id
    add x1, x1, :lo12:rt_credit_discord_id
    mov x2, #256
    bl rt_copy_cstr_bounded
    cbnz w0, rt_credit_statement_error
    adrp x0, rt_credit_discord_id
    add x0, x0, :lo12:rt_credit_discord_id
    bl rt_cstr_length
    adrp x1, rt_credit_discord_id_length
    add x1, x1, :lo12:rt_credit_discord_id_length
    str x0, [x1]
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #100
    b.eq rt_credit_ambiguous
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    bl rt_update_paid
    cbnz w0, rt_credit_error
    bl rt_insert_ledger
    cbnz w0, rt_credit_error
    bl rt_update_total
    cbnz w0, rt_credit_error
    bl rt_mark_consumed
    cbnz w0, rt_credit_error
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_commit
    add x1, x1, :lo12:sql_commit
    bl yul_sqlite_exec
    cbnz w0, rt_credit_error
    mov w0, wzr
    b rt_credit_return
rt_credit_no_match:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    mov w0, #1
    b rt_credit_return
rt_credit_ambiguous:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    mov w0, #1
    b rt_credit_return
rt_credit_statement_error:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
rt_credit_error:
    mov w0, #2
rt_credit_return:
    ldp x29, x30, [sp], #16
    ret

rt_update_paid:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_update_paid
    add x1, x1, :lo12:sql_update_paid
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_update_paid_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    adrp x2, rt_push_id
    add x2, x2, :lo12:rt_push_id
    adrp x3, rt_push_id_length
    add x3, x3, :lo12:rt_push_id_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #2
    adrp x2, rt_amount_value
    add x2, x2, :lo12:rt_amount_value
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #3
    adrp x2, rt_created_at
    add x2, x2, :lo12:rt_created_at
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #4
    adrp x2, rt_credit_order_id
    add x2, x2, :lo12:rt_credit_order_id
    adrp x3, rt_credit_order_id_length
    add x3, x3, :lo12:rt_credit_order_id_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #101
    b.ne rt_update_paid_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    mov w0, wzr
    b rt_update_paid_return
rt_update_paid_fail:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    mov w0, #1
rt_update_paid_return:
    ldp x29, x30, [sp], #16
    ret

rt_insert_ledger:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_insert_ledger
    add x1, x1, :lo12:sql_insert_ledger
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_insert_ledger_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    adrp x2, rt_credit_order_id
    add x2, x2, :lo12:rt_credit_order_id
    adrp x3, rt_credit_order_id_length
    add x3, x3, :lo12:rt_credit_order_id_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #2
    adrp x2, rt_credit_discord_id
    add x2, x2, :lo12:rt_credit_discord_id
    adrp x3, rt_credit_discord_id_length
    add x3, x3, :lo12:rt_credit_discord_id_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #3
    adrp x2, rt_amount_value
    add x2, x2, :lo12:rt_amount_value
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #4
    adrp x2, reason_deposit
    add x2, x2, :lo12:reason_deposit
    mov x3, #7
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #5
    adrp x2, rt_created_at
    add x2, x2, :lo12:rt_created_at
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #101
    b.ne rt_insert_ledger_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    mov w0, wzr
    b rt_insert_ledger_return
rt_insert_ledger_fail:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    mov w0, #1
rt_insert_ledger_return:
    ldp x29, x30, [sp], #16
    ret

rt_update_total:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_get_total
    add x1, x1, :lo12:sql_get_total
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_update_total_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    adrp x2, rt_credit_discord_id
    add x2, x2, :lo12:rt_credit_discord_id
    adrp x3, rt_credit_discord_id_length
    add x3, x3, :lo12:rt_credit_discord_id_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #100
    b.ne rt_update_total_zero
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x0, [x1]
    mov x1, xzr
    bl yul_sqlite_column_int64
    b rt_update_total_have
rt_update_total_zero:
    mov x0, xzr
rt_update_total_have:
    adrp x1, rt_current_total
    add x1, x1, :lo12:rt_current_total
    str x0, [x1]
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    adrp x0, rt_current_total
    add x0, x0, :lo12:rt_current_total
    ldr x0, [x0]
    adrp x1, rt_amount_value
    add x1, x1, :lo12:rt_amount_value
    ldr x1, [x1]
    adrp x2, rt_next_total
    add x2, x2, :lo12:rt_next_total
    bl yul_add_support_total
    cbnz w0, rt_update_total_fail
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_upsert_total
    add x1, x1, :lo12:sql_upsert_total
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_update_total_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    adrp x2, rt_credit_discord_id
    add x2, x2, :lo12:rt_credit_discord_id
    adrp x3, rt_credit_discord_id_length
    add x3, x3, :lo12:rt_credit_discord_id_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #2
    adrp x2, rt_next_total
    add x2, x2, :lo12:rt_next_total
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #3
    adrp x2, rt_created_at
    add x2, x2, :lo12:rt_created_at
    ldr x2, [x2]
    bl yul_sqlite_bind_int64
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #101
    b.ne rt_update_total_statement_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    mov w0, wzr
    b rt_update_total_return
rt_update_total_statement_fail:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
rt_update_total_fail:
    mov w0, #1
rt_update_total_return:
    ldp x29, x30, [sp], #16
    ret

rt_mark_consumed:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_mark_consumed
    add x1, x1, :lo12:sql_mark_consumed
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_mark_consumed_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    adrp x2, rt_credit_order_id
    add x2, x2, :lo12:rt_credit_order_id
    adrp x3, rt_credit_order_id_length
    add x3, x3, :lo12:rt_credit_order_id_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #2
    adrp x2, rt_push_id
    add x2, x2, :lo12:rt_push_id
    adrp x3, rt_push_id_length
    add x3, x3, :lo12:rt_push_id_length
    ldr x3, [x3]
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #101
    b.ne rt_mark_consumed_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    mov w0, wzr
    b rt_mark_consumed_return
rt_mark_consumed_fail:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    mov w0, #1
rt_mark_consumed_return:
    ldp x29, x30, [sp], #16
    ret

rt_commit_close:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_commit
    add x1, x1, :lo12:sql_commit
    bl yul_sqlite_exec
    mov w19, w0
    bl rt_db_close
    mov w0, w19
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
rt_db_rollback_close:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_rollback
    add x1, x1, :lo12:sql_rollback
    bl yul_sqlite_exec
    bl rt_db_close
    ldp x29, x30, [sp], #16
    ret

rt_record_nonpayment:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl rt_now
    adrp x1, rt_created_at
    add x1, x1, :lo12:rt_created_at
    str x0, [x1]
    adrp x1, rt_push_timestamp_present
    add x1, x1, :lo12:rt_push_timestamp_present
    ldr w1, [x1]
    cbnz w1, rt_record_nonpayment_event_time_ready
    adrp x1, rt_push_event_time
    add x1, x1, :lo12:rt_push_event_time
    str x0, [x1]
rt_record_nonpayment_event_time_ready:
    bl rt_db_open
    cbnz w0, rt_record_nonpayment_fail
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_begin
    add x1, x1, :lo12:sql_begin
    bl yul_sqlite_exec
    cbnz w0, rt_record_nonpayment_close
    bl rt_check_duplicate
    cmp w0, #1
    b.eq rt_record_nonpayment_duplicate
    cmp w0, #2
    b.eq rt_record_nonpayment_rollback
    bl rt_insert_push_received
    cbnz w0, rt_record_nonpayment_rollback
    adrp x0, rt_push_id
    add x0, x0, :lo12:rt_push_id
    adrp x1, rt_status_scratch
    add x1, x1, :lo12:rt_status_scratch
    bl rt_update_push_status
    bl rt_commit_close
    cbnz w0, rt_record_nonpayment_fail
    mov w0, wzr
    b rt_record_nonpayment_return
rt_record_nonpayment_rollback:
    bl rt_db_rollback_close
    mov w0, #1
    b rt_record_nonpayment_return
rt_record_nonpayment_duplicate:
    bl rt_db_rollback_close
    mov w0, #2
    b rt_record_nonpayment_return
rt_record_nonpayment_close:
    bl rt_db_close
rt_record_nonpayment_fail:
    mov w0, #1
rt_record_nonpayment_return:
    ldp x29, x30, [sp], #16
    ret

rt_print_push_result:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    adrp x0, result_prefix
    add x0, x0, :lo12:result_prefix
    mov x1, #0
    bl rt_write_cstr
    mov x0, x19
    mov x1, #0
    bl rt_write_cstr
    adrp x0, result_mid_push
    add x0, x0, :lo12:result_mid_push
    mov x1, #0
    bl rt_write_cstr
    adrp x0, rt_push_id
    add x0, x0, :lo12:rt_push_id
    adrp x1, rt_push_id_length
    add x1, x1, :lo12:rt_push_id_length
    ldr x1, [x1]
    bl rt_write_cstr
    adrp x0, result_suffix
    add x0, x0, :lo12:result_suffix
    mov x1, #1
    bl rt_write_cstr
    mov w0, wzr
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_review_list:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl rt_db_open
    cbnz w0, rt_review_fail
    adrp x0, rt_list_first
    add x0, x0, :lo12:rt_list_first
    mov w1, #1
    str w1, [x0]
    adrp x0, list_start
    add x0, x0, :lo12:list_start
    mov x1, #0
    bl rt_write_cstr
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_review
    add x1, x1, :lo12:sql_review
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_review_close
rt_review_loop:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #100
    b.ne rt_review_done
    adrp x0, rt_list_first
    add x0, x0, :lo12:rt_list_first
    ldr w1, [x0]
    cbz w1, rt_review_separator
    str wzr, [x0]
    b rt_review_row
rt_review_separator:
    adrp x0, list_separator
    add x0, x0, :lo12:list_separator
    mov x1, #0
    bl rt_write_cstr
rt_review_row:
    adrp x0, json_push_prefix
    add x0, x0, :lo12:json_push_prefix
    mov x1, #0
    bl rt_write_cstr
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x0, [x1]
    mov x1, #0
    bl yul_sqlite_column_text
    adrp x1, rt_line
    add x1, x1, :lo12:rt_line
    bl rt_copy_cstr
    adrp x0, rt_line
    add x0, x0, :lo12:rt_line
    mov x1, #0
    bl rt_write_cstr
    adrp x0, json_quote
    add x0, x0, :lo12:json_quote
    mov x1, #0
    bl rt_write_cstr
    adrp x0, json_status_prefix
    add x0, x0, :lo12:json_status_prefix
    mov x1, #0
    bl rt_write_cstr
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x0, [x1]
    mov x1, #1
    bl yul_sqlite_column_text
    adrp x1, rt_line
    add x1, x1, :lo12:rt_line
    bl rt_copy_cstr
    adrp x0, rt_line
    add x0, x0, :lo12:rt_line
    mov x1, #0
    bl rt_write_cstr
    adrp x0, json_name_prefix
    add x0, x0, :lo12:json_name_prefix
    mov x1, #0
    bl rt_write_cstr
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x0, [x1]
    mov x1, #2
    bl yul_sqlite_column_text
    cbz x0, rt_review_name_null
    adrp x1, rt_line
    add x1, x1, :lo12:rt_line
    bl rt_copy_cstr
    adrp x0, json_quote
    add x0, x0, :lo12:json_quote
    mov x1, #0
    bl rt_write_cstr
    adrp x0, rt_line
    add x0, x0, :lo12:rt_line
    mov x1, #0
    bl rt_write_cstr
    adrp x0, json_quote
    add x0, x0, :lo12:json_quote
    mov x1, #0
    bl rt_write_cstr
    b rt_review_amount
rt_review_name_null:
    adrp x0, json_null
    add x0, x0, :lo12:json_null
    mov x1, #0
    bl rt_write_cstr
rt_review_amount:
    adrp x0, json_amount_prefix
    add x0, x0, :lo12:json_amount_prefix
    mov x1, #0
    bl rt_write_cstr
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x0, [x1]
    mov x1, #3
    bl yul_sqlite_column_int64
    adrp x1, rt_decimal
    add x1, x1, :lo12:rt_decimal
    mov x2, #64
    bl rt_u64_decimal
    mov x1, x0
    adrp x0, rt_decimal
    add x0, x0, :lo12:rt_decimal
    bl rt_write_cstr
    adrp x0, json_received_prefix
    add x0, x0, :lo12:json_received_prefix
    mov x1, #0
    bl rt_write_cstr
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x0, [x1]
    mov x1, #4
    bl yul_sqlite_column_int64
    adrp x1, rt_decimal
    add x1, x1, :lo12:rt_decimal
    mov x2, #64
    bl rt_u64_decimal
    mov x1, x0
    adrp x0, rt_decimal
    add x0, x0, :lo12:rt_decimal
    bl rt_write_cstr
    adrp x0, json_object_suffix
    add x0, x0, :lo12:json_object_suffix
    mov x1, #0
    bl rt_write_cstr
    b rt_review_loop
rt_review_done:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
rt_review_close:
    bl rt_db_close
rt_review_fail:
    adrp x0, list_end
    add x0, x0, :lo12:list_end
    mov x1, #0
    bl rt_write_cstr
    adrp x0, list_end_newline
    add x0, x0, :lo12:list_end_newline
    mov x1, #1
    bl rt_write_cstr
    mov w0, wzr
    ldp x29, x30, [sp], #16
    ret

rt_ledger_list:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl rt_db_open
    cbnz w0, rt_ledger_fail
    adrp x0, rt_list_first
    add x0, x0, :lo12:rt_list_first
    mov w1, #1
    str w1, [x0]
    adrp x0, list_start
    add x0, x0, :lo12:list_start
    mov x1, #0
    bl rt_write_cstr
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_ledger
    add x1, x1, :lo12:sql_ledger
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_ledger_close
rt_ledger_loop:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #100
    b.ne rt_ledger_done
    adrp x0, rt_list_first
    add x0, x0, :lo12:rt_list_first
    ldr w1, [x0]
    cbz w1, rt_ledger_separator
    str wzr, [x0]
    b rt_ledger_row
rt_ledger_separator:
    adrp x0, list_separator
    add x0, x0, :lo12:list_separator
    mov x1, #0
    bl rt_write_cstr
rt_ledger_row:
    adrp x0, json_order_prefix
    add x0, x0, :lo12:json_order_prefix
    mov x1, #0
    bl rt_write_cstr
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x0, [x1]
    mov x1, #0
    bl yul_sqlite_column_int64
    adrp x1, rt_decimal
    add x1, x1, :lo12:rt_decimal
    mov x2, #64
    bl rt_u64_decimal
    mov x1, x0
    adrp x0, rt_decimal
    add x0, x0, :lo12:rt_decimal
    bl rt_write_cstr
    adrp x0, json_order_id_prefix
    add x0, x0, :lo12:json_order_id_prefix
    mov x1, #0
    bl rt_write_cstr
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x0, [x1]
    mov x1, #1
    bl yul_sqlite_column_text
    adrp x1, rt_line
    add x1, x1, :lo12:rt_line
    bl rt_copy_cstr
    adrp x0, rt_line
    add x0, x0, :lo12:rt_line
    mov x1, #0
    bl rt_write_cstr
    adrp x0, json_discord_prefix
    add x0, x0, :lo12:json_discord_prefix
    mov x1, #0
    bl rt_write_cstr
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x0, [x1]
    mov x1, #2
    bl yul_sqlite_column_text
    adrp x1, rt_line
    add x1, x1, :lo12:rt_line
    bl rt_copy_cstr
    adrp x0, rt_line
    add x0, x0, :lo12:rt_line
    mov x1, #0
    bl rt_write_cstr
    adrp x0, json_quote
    add x0, x0, :lo12:json_quote
    mov x1, #0
    bl rt_write_cstr
    adrp x0, json_ledger_amount_prefix
    add x0, x0, :lo12:json_ledger_amount_prefix
    mov x1, #0
    bl rt_write_cstr
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x0, [x1]
    mov x1, #3
    bl yul_sqlite_column_int64
    adrp x1, rt_decimal
    add x1, x1, :lo12:rt_decimal
    mov x2, #64
    bl rt_u64_decimal
    mov x1, x0
    adrp x0, rt_decimal
    add x0, x0, :lo12:rt_decimal
    bl rt_write_cstr
    adrp x0, json_reason_prefix
    add x0, x0, :lo12:json_reason_prefix
    mov x1, #0
    bl rt_write_cstr
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x0, [x1]
    mov x1, #4
    bl yul_sqlite_column_text
    adrp x1, rt_line
    add x1, x1, :lo12:rt_line
    bl rt_copy_cstr
    adrp x0, rt_line
    add x0, x0, :lo12:rt_line
    mov x1, #0
    bl rt_write_cstr
    adrp x0, json_quote
    add x0, x0, :lo12:json_quote
    mov x1, #0
    bl rt_write_cstr
    adrp x0, json_created_prefix
    add x0, x0, :lo12:json_created_prefix
    mov x1, #0
    bl rt_write_cstr
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x0, [x1]
    mov x1, #5
    bl yul_sqlite_column_int64
    adrp x1, rt_decimal
    add x1, x1, :lo12:rt_decimal
    mov x2, #64
    bl rt_u64_decimal
    mov x1, x0
    adrp x0, rt_decimal
    add x0, x0, :lo12:rt_decimal
    bl rt_write_cstr
    adrp x0, json_object_suffix
    add x0, x0, :lo12:json_object_suffix
    mov x1, #0
    bl rt_write_cstr
    b rt_ledger_loop
rt_ledger_done:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
rt_ledger_close:
    bl rt_db_close
rt_ledger_fail:
    adrp x0, list_end
    add x0, x0, :lo12:list_end
    mov x1, #0
    bl rt_write_cstr
    adrp x0, list_end_newline
    add x0, x0, :lo12:list_end_newline
    mov x1, #1
    bl rt_write_cstr
    mov w0, wzr
    ldp x29, x30, [sp], #16
    ret

rt_setting_get:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    bl rt_db_open
    cbnz w0, rt_setting_get_fail
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_get_setting
    add x1, x1, :lo12:sql_get_setting
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_setting_get_close
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x0, x19
    bl rt_cstr_length
    mov x3, x0
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    mov x2, x19
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #100
    b.ne rt_setting_get_missing
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #0
    bl yul_sqlite_column_text
    cbz x0, rt_setting_get_missing
    mov x19, x0
    mov x0, x19
    mov x1, x20
    mov x2, x21
    bl rt_copy_cstr_bounded
    cbnz w0, rt_setting_get_missing
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    bl rt_db_close
    mov w0, wzr
    b rt_setting_get_return
rt_setting_get_missing:
    strb wzr, [x20]
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
rt_setting_get_close:
    bl rt_db_close
rt_setting_get_fail:
    mov w0, #1
rt_setting_get_return:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

rt_setting_set:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    bl rt_db_open
    cbnz w0, rt_setting_set_fail
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_set_setting
    add x1, x1, :lo12:sql_set_setting
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_setting_set_close
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x0, x19
    bl rt_cstr_length
    mov x3, x0
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    mov x2, x19
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x0, x20
    bl rt_cstr_length
    mov x3, x0
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #2
    mov x2, x20
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #101
    b.ne rt_setting_set_statement_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    bl rt_db_close
    mov w0, wzr
    b rt_setting_set_return
rt_setting_set_statement_fail:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
rt_setting_set_close:
    bl rt_db_close
rt_setting_set_fail:
    mov w0, #1
rt_setting_set_return:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

rt_update_dm_status:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    bl rt_db_open
    cbnz w0, rt_update_dm_fail
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    cbz x21, rt_update_dm_select_regular
    adrp x1, sql_update_payment_dm
    b rt_update_dm_select_done
rt_update_dm_select_regular:
    adrp x1, sql_update_dm
rt_update_dm_select_done:
    cbz x21, rt_update_dm_add_regular
    add x1, x1, :lo12:sql_update_payment_dm
    b rt_update_dm_add_done
rt_update_dm_add_regular:
    add x1, x1, :lo12:sql_update_dm
rt_update_dm_add_done:
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_update_dm_close
    mov x0, x19
    bl rt_cstr_length
    mov x3, x0
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    mov x2, x19
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x0, x20
    bl rt_cstr_length
    mov x3, x0
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #2
    mov x2, x20
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #101
    b.ne rt_update_dm_statement_fail
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
    bl rt_db_close
    mov w0, wzr
    b rt_update_dm_return
rt_update_dm_statement_fail:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
rt_update_dm_close:
    bl rt_db_close
rt_update_dm_fail:
    mov w0, #1
rt_update_dm_return:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

rt_json_extract_pattern:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    adrp x0, rt_json_buffer
    add x0, x0, :lo12:rt_json_buffer
    adrp x1, rt_json_length
    add x1, x1, :lo12:rt_json_length
    ldr x1, [x1]
    adrp x23, rt_json_buffer
    add x23, x23, :lo12:rt_json_buffer
    add x23, x23, x1
    mov x2, x19
    mov x3, x20
    bl native_json_find_pattern
    cbz x0, rt_json_extract_fail
    add x0, x0, x20
    mov x1, xzr
rt_json_extract_loop:
    cmp x0, x23
    b.hs rt_json_extract_fail
    cmp x1, x22
    b.hs rt_json_extract_fail
    ldrb w3, [x0]
    cmp w3, #34
    b.eq rt_json_extract_done
    cmp w3, #92
    b.ne rt_json_extract_plain
    add x0, x0, #1
    mov x4, x1
    mov x1, x23
    mov x2, x21
    mov x3, x4
    mov x4, x22
    bl rt_json_decode_escape
    cbnz w2, rt_json_extract_fail
    mov x1, x3
    b rt_json_extract_loop
rt_json_extract_store:
    strb w3, [x21, x1]
    add x1, x1, #1
    add x0, x0, #1
    b rt_json_extract_loop
rt_json_extract_plain:
    add x4, x1, #1
    cmp x4, x22
    b.hs rt_json_extract_fail
    strb w3, [x21, x1]
    add x1, x1, #1
    add x0, x0, #1
    b rt_json_extract_loop
rt_json_extract_done:
    strb wzr, [x21, x1]
    mov x0, x1
    b rt_json_extract_return
rt_json_extract_fail:
    strb wzr, [x21]
    mov x0, #-1
rt_json_extract_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_json_extract_nth_pattern:
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
    adrp x25, rt_json_buffer
    add x25, x25, :lo12:rt_json_buffer
    adrp x26, rt_json_length
    add x26, x26, :lo12:rt_json_length
    ldr x26, [x26]
    add x26, x26, x25
    mov x24, x25
    mov x27, xzr
    mov x28, xzr
rt_json_extract_nth_find:
    cmp x24, x26
    b.hs rt_json_extract_nth_fail
    ldrb w3, [x24]
    cbnz x27, rt_json_extract_nth_string
    mov x0, x24
    sub x1, x26, x24
    cmp x1, x20
    b.lo rt_json_extract_nth_scan_next
    mov x2, xzr
rt_json_extract_nth_compare:
    cmp x2, x20
    b.hs rt_json_extract_nth_match
    ldrb w4, [x0, x2]
    ldrb w5, [x19, x2]
    cmp w4, w5
    b.ne rt_json_extract_nth_scan_next
    add x2, x2, #1
    b rt_json_extract_nth_compare
rt_json_extract_nth_match:
    cbz x23, rt_json_extract_nth_found
    sub x23, x23, #1
    add x24, x24, x20
    mov x27, #1
    mov x28, xzr
    b rt_json_extract_nth_find
rt_json_extract_nth_scan_next:
    cmp w3, #34
    b.eq rt_json_extract_nth_string_start
    add x24, x24, #1
    b rt_json_extract_nth_find
rt_json_extract_nth_string:
    cbnz x28, rt_json_extract_nth_string_escaped
    cmp w3, #92
    b.eq rt_json_extract_nth_string_escape
    cmp w3, #34
    b.eq rt_json_extract_nth_string_closed
    add x24, x24, #1
    b rt_json_extract_nth_find
rt_json_extract_nth_string_escape:
    mov x28, #1
    add x24, x24, #1
    b rt_json_extract_nth_find
rt_json_extract_nth_string_escaped:
    mov x28, xzr
    add x24, x24, #1
    b rt_json_extract_nth_find
rt_json_extract_nth_string_closed:
    mov x27, xzr
    add x24, x24, #1
    b rt_json_extract_nth_find
rt_json_extract_nth_string_start:
    mov x27, #1
    mov x28, xzr
    add x24, x24, #1
    b rt_json_extract_nth_find
rt_json_extract_nth_found:
    add x0, x24, x20
    mov x1, xzr
rt_json_extract_nth_loop:
    cmp x0, x26
    b.hs rt_json_extract_nth_fail
    cmp x1, x22
    b.hs rt_json_extract_nth_fail
    ldrb w3, [x0]
    cmp w3, #34
    b.eq rt_json_extract_nth_done
    cmp w3, #92
    b.ne rt_json_extract_nth_plain
    add x0, x0, #1
    mov x4, x1
    mov x1, x26
    mov x2, x21
    mov x3, x4
    mov x4, x22
    bl rt_json_decode_escape
    cbnz w2, rt_json_extract_nth_fail
    mov x1, x3
    b rt_json_extract_nth_loop
rt_json_extract_nth_plain:
    add x4, x1, #1
    cmp x4, x22
    b.hs rt_json_extract_nth_fail
    strb w3, [x21, x1]
    add x1, x1, #1
    add x0, x0, #1
    b rt_json_extract_nth_loop
rt_json_extract_nth_done:
    strb wzr, [x21, x1]
    mov x0, x1
    b rt_json_extract_nth_return
rt_json_extract_nth_fail:
    strb wzr, [x21]
    mov x0, #-1
rt_json_extract_nth_return:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret

rt_service_copy_json:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x2, rt_json_buffer
    add x2, x2, :lo12:rt_json_buffer
    mov x3, #65535
    cmp x1, x3
    b.hi rt_service_copy_json_overflow
    mov x3, xzr
rt_service_copy_json_loop:
    cmp x3, x1
    b.hs rt_service_copy_json_done
    ldrb w4, [x0, x3]
    strb w4, [x2, x3]
    add x3, x3, #1
    b rt_service_copy_json_loop
rt_service_copy_json_done:
    strb wzr, [x2, x3]
    adrp x4, rt_json_length
    add x4, x4, :lo12:rt_json_length
    str x3, [x4]
    mov x0, x3
    ldp x29, x30, [sp], #16
    ret
rt_service_copy_json_overflow:
    strb wzr, [x2]
    adrp x4, rt_json_length
    add x4, x4, :lo12:rt_json_length
    str xzr, [x4]
    mov x0, #-1
    ldp x29, x30, [sp], #16
    ret

rt_service_append_cstr:
    ldrb w2, [x1], #1
    cbz w2, rt_service_append_cstr_done
    strb w2, [x0], #1
    b rt_service_append_cstr
rt_service_append_cstr_done:
    ret

rt_service_append_json:
    ldrb w2, [x1], #1
    cbz w2, rt_service_append_json_done
    cmp w2, #34
    b.eq rt_service_append_json_quote
    cmp w2, #92
    b.eq rt_service_append_json_slash
    cmp w2, #10
    b.eq rt_service_append_json_newline
    cmp w2, #13
    b.eq rt_service_append_json_return
    strb w2, [x0], #1
    b rt_service_append_json
rt_service_append_json_quote:
    mov w3, #92
    strb w3, [x0], #1
    mov w3, #34
    strb w3, [x0], #1
    b rt_service_append_json
rt_service_append_json_slash:
    mov w3, #92
    strb w3, [x0], #1
    strb w2, [x0], #1
    b rt_service_append_json
rt_service_append_json_newline:
    mov w3, #92
    strb w3, [x0], #1
    mov w3, #110
    strb w3, [x0], #1
    b rt_service_append_json
rt_service_append_json_return:
    b rt_service_append_json
rt_service_append_json_done:
    ret

rt_service_append_u64:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    mov x19, x0
    mov x20, x1
    mov x0, x20
    adrp x1, rt_decimal
    add x1, x1, :lo12:rt_decimal
    mov x2, #64
    bl rt_u64_decimal
    mov x2, x0
    adrp x0, rt_decimal
    add x0, x0, :lo12:rt_decimal
    mov x1, x0
    mov x0, x19
    bl rt_service_append_bytes
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

rt_service_append_bytes:
    mov x3, xzr
rt_service_append_bytes_loop:
    cmp x3, x2
    b.hs rt_service_append_bytes_done
    ldrb w4, [x1, x3]
    strb w4, [x0, x3]
    add x3, x3, #1
    b rt_service_append_bytes_loop
rt_service_append_bytes_done:
    add x0, x0, x2
    ret

rt_service_rest_call:
    mov x4, #20000
    b rt_service_rest_call_timeout
rt_service_rest_call_fast:
    mov x4, #2000
rt_service_rest_call_timeout:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, x4
    mov x0, x20
    mov x1, x19
    adrp x2, rt_discord_token
    add x2, x2, :lo12:rt_discord_token
    mov x3, x21
    mov x4, x22
    adrp x5, rt_service_response
    add x5, x5, :lo12:rt_service_response
    mov x6, #65535
    mov x7, x23
    bl yul_native_network_rest_json
    mov w23, w0
    adrp x16, rt_service_response_length
    add x16, x16, :lo12:rt_service_response_length
    str x1, [x16]
    cbnz w23, rt_service_rest_return
    adrp x0, rest_status
    add x0, x0, :lo12:rest_status
    ldr w0, [x0]
    cmp w0, #200
    b.lo rt_service_rest_http_fail
    cmp w0, #300
    b.hs rt_service_rest_http_fail
    mov w23, wzr
    b rt_service_rest_return
rt_service_rest_http_fail:
    mov w23, #1
rt_service_rest_return:
    mov w0, w23
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_service_rest_retry:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov w23, #3
    adrp x0, rt_service_retry_delay
    add x0, x0, :lo12:rt_service_retry_delay
    mov x1, #1
    str x1, [x0]
rt_service_rest_retry_loop:
    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, x22
    bl rt_service_rest_call
    mov w24, w0
    cbz w24, rt_service_rest_retry_return
    adrp x0, rest_status
    add x0, x0, :lo12:rest_status
    ldr w0, [x0]
    cbz w0, rt_service_rest_retry_wait
    cmp w0, #429
    b.eq rt_service_rest_retry_wait
    cmp w0, #500
    b.lo rt_service_rest_retry_return
    cmp w0, #600
    b.hs rt_service_rest_retry_return
rt_service_rest_retry_wait:
    subs w23, w23, #1
    b.eq rt_service_rest_retry_return
    adrp x0, rt_service_retry_delay
    add x0, x0, :lo12:rt_service_retry_delay
    ldr x0, [x0]
    bl rt_service_sleep_seconds
    adrp x1, rt_service_retry_delay
    add x1, x1, :lo12:rt_service_retry_delay
    ldr x0, [x1]
    lsl x0, x0, #1
    cmp x0, #30
    b.ls rt_service_rest_retry_store_delay
    mov x0, #30
rt_service_rest_retry_store_delay:
    str x0, [x1]
    b rt_service_rest_retry_loop
rt_service_rest_retry_return:
    mov w0, w24
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_service_copy_static:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    mov x0, x19
    bl rt_cstr_length
    mov x3, x0
    adrp x0, rt_service_body
    add x0, x0, :lo12:rt_service_body
    mov x1, x19
    mov x2, x3
    bl rt_service_append_bytes
    strb wzr, [x0]
    adrp x1, rt_service_body
    add x1, x1, :lo12:rt_service_body
    sub x0, x0, x1
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_service_register_commands:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_discord_application_length
    add x0, x0, :lo12:rt_discord_application_length
    ldr x0, [x0]
    cbz x0, rt_service_register_done
    adrp x0, rt_discord_guild_length
    add x0, x0, :lo12:rt_discord_guild_length
    ldr x0, [x0]
    cbz x0, rt_service_register_done
    adrp x0, rt_service_url
    add x0, x0, :lo12:rt_service_url
    adrp x1, discord_api_prefix
    add x1, x1, :lo12:discord_api_prefix
    bl rt_service_append_cstr
    adrp x1, path_commands_prefix
    add x1, x1, :lo12:path_commands_prefix
    bl rt_service_append_cstr
    adrp x1, rt_discord_application
    add x1, x1, :lo12:rt_discord_application
    bl rt_service_append_cstr
    adrp x1, path_commands_middle
    add x1, x1, :lo12:path_commands_middle
    bl rt_service_append_cstr
    adrp x1, rt_discord_guild
    add x1, x1, :lo12:rt_discord_guild
    bl rt_service_append_cstr
    adrp x1, path_commands_suffix
    add x1, x1, :lo12:path_commands_suffix
    bl rt_service_append_cstr
    strb wzr, [x0]
    adrp x0, json_commands
    add x0, x0, :lo12:json_commands
    bl rt_service_copy_static
    adrp x4, rt_service_status
    add x4, x4, :lo12:rt_service_status
    str x0, [x4]
    adrp x4, rt_service_status
    add x4, x4, :lo12:rt_service_status
    ldr x3, [x4]
    adrp x2, rt_service_body
    add x2, x2, :lo12:rt_service_body
    adrp x1, rt_service_url
    add x1, x1, :lo12:rt_service_url
    adrp x0, method_put
    add x0, x0, :lo12:method_put
    bl rt_service_rest_retry
    b rt_service_register_return
rt_service_register_done:
    mov w0, wzr
rt_service_register_return:
    ldp x29, x30, [sp], #16
    ret

rt_service_publish_panel:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_discord_panel_length
    add x0, x0, :lo12:rt_discord_panel_length
    ldr x0, [x0]
    cbz x0, rt_service_publish_fail
    adrp x0, rt_service_url
    add x0, x0, :lo12:rt_service_url
    adrp x1, discord_api_prefix
    add x1, x1, :lo12:discord_api_prefix
    bl rt_service_append_cstr
    adrp x1, path_channel_messages
    add x1, x1, :lo12:path_channel_messages
    bl rt_service_append_cstr
    adrp x1, rt_discord_panel
    add x1, x1, :lo12:rt_discord_panel
    bl rt_service_append_cstr
    adrp x1, path_messages_suffix
    add x1, x1, :lo12:path_messages_suffix
    bl rt_service_append_cstr
    strb wzr, [x0]
    adrp x0, json_panel_prefix
    add x0, x0, :lo12:json_panel_prefix
    bl rt_service_copy_static
    mov x3, x0
    adrp x2, rt_service_body
    add x2, x2, :lo12:rt_service_body
    adrp x1, rt_service_url
    add x1, x1, :lo12:rt_service_url
    adrp x0, method_post
    add x0, x0, :lo12:method_post
    bl rt_service_rest_call
    cbnz w0, rt_service_publish_fail
    adrp x0, rt_service_response
    add x0, x0, :lo12:rt_service_response
    adrp x1, rt_service_response_length
    add x1, x1, :lo12:rt_service_response_length
    ldr x1, [x1]
    bl rt_service_copy_json
    cmn x0, #1
    b.eq rt_service_publish_fail
    adrp x0, json_message_id
    add x0, x0, :lo12:json_message_id
    mov x1, #2
    adrp x2, rt_panel_message_id
    add x2, x2, :lo12:rt_panel_message_id
    mov x3, #256
    bl rt_json_value
    cbnz w0, rt_service_publish_fail
    adrp x0, rt_json_value_length
    add x0, x0, :lo12:rt_json_value_length
    ldr x0, [x0]
    cbz x0, rt_service_publish_fail
    adrp x0, setting_panel_message
    add x0, x0, :lo12:setting_panel_message
    adrp x1, rt_panel_message_id
    add x1, x1, :lo12:rt_panel_message_id
    mov x2, xzr
    bl rt_setting_set
    cbnz w0, rt_service_publish_fail
    mov w0, wzr
    b rt_service_publish_return
rt_service_publish_fail:
    mov w0, #1
rt_service_publish_return:
    ldp x29, x30, [sp], #16
    ret

rt_service_build_dm_nonce:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x0, x19
    bl rt_cstr_length
    cmp x0, #23
    b.hi rt_service_build_dm_nonce_fail
    adrp x0, rt_service_dm_nonce
    add x0, x0, :lo12:rt_service_dm_nonce
    mov x1, x20
    bl rt_service_append_cstr
    mov x1, x19
    bl rt_service_append_cstr
    strb wzr, [x0]
    mov w0, wzr
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
rt_service_build_dm_nonce_fail:
    adrp x0, rt_service_dm_nonce
    add x0, x0, :lo12:rt_service_dm_nonce
    strb wzr, [x0]
    mov w0, #1
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_service_send_dm:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    adrp x0, rt_service_url
    add x0, x0, :lo12:rt_service_url
    adrp x1, discord_api_prefix
    add x1, x1, :lo12:discord_api_prefix
    bl rt_service_append_cstr
    adrp x1, path_dm_create
    add x1, x1, :lo12:path_dm_create
    bl rt_service_append_cstr
    strb wzr, [x0]
    adrp x0, rt_service_body
    add x0, x0, :lo12:rt_service_body
    adrp x1, json_dm_channel_prefix
    add x1, x1, :lo12:json_dm_channel_prefix
    bl rt_service_append_cstr
    mov x1, x19
    bl rt_service_append_json
    adrp x1, json_dm_channel_suffix
    add x1, x1, :lo12:json_dm_channel_suffix
    bl rt_service_append_cstr
    adrp x1, rt_service_body
    add x1, x1, :lo12:rt_service_body
    sub x3, x0, x1
    adrp x2, rt_service_body
    add x2, x2, :lo12:rt_service_body
    adrp x1, rt_service_url
    add x1, x1, :lo12:rt_service_url
    adrp x0, method_post
    add x0, x0, :lo12:method_post
    bl rt_service_rest_call
    cbnz w0, rt_service_dm_fail
    adrp x0, rt_service_response
    add x0, x0, :lo12:rt_service_response
    adrp x1, rt_service_response_length
    add x1, x1, :lo12:rt_service_response_length
    ldr x1, [x1]
    bl rt_service_copy_json
    cmn x0, #1
    b.eq rt_service_dm_fail
    adrp x0, json_message_id
    add x0, x0, :lo12:json_message_id
    mov x1, #2
    adrp x2, rt_service_channel
    add x2, x2, :lo12:rt_service_channel
    mov x3, #256
    bl rt_json_value
    cbnz w0, rt_service_dm_fail
    adrp x0, rt_service_url
    add x0, x0, :lo12:rt_service_url
    adrp x1, discord_api_prefix
    add x1, x1, :lo12:discord_api_prefix
    bl rt_service_append_cstr
    adrp x1, path_channel_messages
    add x1, x1, :lo12:path_channel_messages
    bl rt_service_append_cstr
    adrp x1, rt_service_channel
    add x1, x1, :lo12:rt_service_channel
    bl rt_service_append_cstr
    adrp x1, path_messages_suffix
    add x1, x1, :lo12:path_messages_suffix
    bl rt_service_append_cstr
    strb wzr, [x0]
    adrp x0, rt_service_body
    add x0, x0, :lo12:rt_service_body
    adrp x1, json_dm_content_prefix
    add x1, x1, :lo12:json_dm_content_prefix
    bl rt_service_append_cstr
    mov x1, x20
    bl rt_service_append_json
    adrp x1, json_dm_nonce_prefix
    add x1, x1, :lo12:json_dm_nonce_prefix
    bl rt_service_append_cstr
    adrp x1, rt_service_dm_nonce
    add x1, x1, :lo12:rt_service_dm_nonce
    bl rt_service_append_cstr
    adrp x1, json_dm_nonce_suffix
    add x1, x1, :lo12:json_dm_nonce_suffix
    bl rt_service_append_cstr
    adrp x1, rt_service_body
    add x1, x1, :lo12:rt_service_body
    sub x3, x0, x1
    adrp x2, rt_service_body
    add x2, x2, :lo12:rt_service_body
    adrp x1, rt_service_url
    add x1, x1, :lo12:rt_service_url
    adrp x0, method_post
    add x0, x0, :lo12:method_post
    bl rt_service_rest_retry
    b rt_service_dm_return
rt_service_dm_fail:
    mov w0, #1
rt_service_dm_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_service_send_interaction:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    adrp x0, rt_service_url
    add x0, x0, :lo12:rt_service_url
    adrp x1, discord_api_prefix
    add x1, x1, :lo12:discord_api_prefix
    bl rt_service_append_cstr
    adrp x1, path_interaction_prefix
    add x1, x1, :lo12:path_interaction_prefix
    bl rt_service_append_cstr
    mov x1, x19
    bl rt_service_append_cstr
    adrp x1, path_interaction_middle
    add x1, x1, :lo12:path_interaction_middle
    bl rt_service_append_cstr
    mov x1, x20
    bl rt_service_append_cstr
    adrp x1, path_interaction_suffix
    add x1, x1, :lo12:path_interaction_suffix
    bl rt_service_append_cstr
    strb wzr, [x0]
    adrp x2, rt_service_url
    add x2, x2, :lo12:rt_service_url
    mov x3, x22
    mov x1, x2
    mov x2, x21
    adrp x0, method_post
    add x0, x0, :lo12:method_post
    bl rt_service_rest_call_fast
    mov w23, w0
    cbz w23, rt_service_send_interaction_return
    bl rt_service_log_interaction_failure
rt_service_send_interaction_return:
    mov w0, w23
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_service_log_interaction_failure:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, service_interaction_callback_failed
    add x0, x0, :lo12:service_interaction_callback_failed
    mov x1, xzr
    bl rt_log_cstr
    adrp x0, rest_status
    add x0, x0, :lo12:rest_status
    ldr x0, [x0]
    adrp x1, rt_decimal
    add x1, x1, :lo12:rt_decimal
    mov x2, #64
    bl rt_u64_decimal
    mov x1, x0
    adrp x0, rt_decimal
    add x0, x0, :lo12:rt_decimal
    bl rt_log_cstr
    adrp x0, newline
    add x0, x0, :lo12:newline
    mov x1, #1
    bl rt_log_cstr
    ldp x29, x30, [sp], #16
    ret

rt_service_defer_interaction:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    adrp x0, json_deferred_response
    add x0, x0, :lo12:json_deferred_response
    bl rt_service_copy_static
    mov x3, x0
    adrp x0, rt_service_interaction_id
    add x0, x0, :lo12:rt_service_interaction_id
    adrp x1, rt_service_interaction_token
    add x1, x1, :lo12:rt_service_interaction_token
    adrp x2, rt_service_body
    add x2, x2, :lo12:rt_service_body
    bl rt_service_send_interaction
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_service_edit_original:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    adrp x0, rt_service_url
    add x0, x0, :lo12:rt_service_url
    adrp x1, discord_api_prefix
    add x1, x1, :lo12:discord_api_prefix
    bl rt_service_append_cstr
    adrp x1, path_webhook_prefix
    add x1, x1, :lo12:path_webhook_prefix
    bl rt_service_append_cstr
    adrp x1, rt_discord_application
    add x1, x1, :lo12:rt_discord_application
    bl rt_service_append_cstr
    adrp x1, path_webhook_middle
    add x1, x1, :lo12:path_webhook_middle
    bl rt_service_append_cstr
    adrp x1, rt_service_interaction_token
    add x1, x1, :lo12:rt_service_interaction_token
    bl rt_service_append_cstr
    adrp x1, path_webhook_message
    add x1, x1, :lo12:path_webhook_message
    bl rt_service_append_cstr
    strb wzr, [x0]
    adrp x0, rt_service_body
    add x0, x0, :lo12:rt_service_body
    adrp x1, json_rest_content_prefix
    add x1, x1, :lo12:json_rest_content_prefix
    bl rt_service_append_cstr
    mov x1, x19
    bl rt_service_append_json
    adrp x1, json_rest_content_suffix
    add x1, x1, :lo12:json_rest_content_suffix
    bl rt_service_append_cstr
    adrp x1, rt_service_body
    add x1, x1, :lo12:rt_service_body
    sub x20, x0, x1
    adrp x2, rt_service_url
    add x2, x2, :lo12:rt_service_url
    mov x1, x2
    adrp x2, rt_service_body
    add x2, x2, :lo12:rt_service_body
    mov x3, x20
    adrp x0, method_patch
    add x0, x0, :lo12:method_patch
    bl rt_service_rest_call
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_service_build_ephemeral:
    stp x29, x30, [sp, #-32]!
    str x19, [sp, #16]
    mov x29, sp
    mov x19, x0
    adrp x0, rt_service_body
    add x0, x0, :lo12:rt_service_body
    adrp x1, json_response_prefix
    add x1, x1, :lo12:json_response_prefix
    bl rt_service_append_cstr
    mov x1, x19
    bl rt_service_append_json
    adrp x1, json_response_suffix
    add x1, x1, :lo12:json_response_suffix
    bl rt_service_append_cstr
    adrp x1, rt_service_body
    add x1, x1, :lo12:rt_service_body
    sub x0, x0, x1
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_service_build_order_content:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_service_body
    add x0, x0, :lo12:rt_service_body
    adrp x1, json_order_content_prefix
    add x1, x1, :lo12:json_order_content_prefix
    bl rt_service_append_cstr
    adrp x1, rt_bank_name
    add x1, x1, :lo12:rt_bank_name
    bl rt_service_append_json
    adrp x1, json_order_content_account
    add x1, x1, :lo12:json_order_content_account
    bl rt_service_append_cstr
    adrp x1, rt_bank_account
    add x1, x1, :lo12:rt_bank_account
    bl rt_service_append_json
    adrp x1, json_order_content_holder
    add x1, x1, :lo12:json_order_content_holder
    bl rt_service_append_cstr
    adrp x1, rt_bank_holder
    add x1, x1, :lo12:rt_bank_holder
    bl rt_service_append_json
    adrp x1, json_order_content_amount
    add x1, x1, :lo12:json_order_content_amount
    bl rt_service_append_cstr
    adrp x1, rt_amount_value
    add x1, x1, :lo12:rt_amount_value
    ldr x1, [x1]
    bl rt_service_append_u64
    adrp x1, json_order_content_name
    add x1, x1, :lo12:json_order_content_name
    bl rt_service_append_cstr
    adrp x1, rt_name
    add x1, x1, :lo12:rt_name
    bl rt_service_append_json
    adrp x1, json_order_content_expiry
    add x1, x1, :lo12:json_order_content_expiry
    bl rt_service_append_cstr
    adrp x1, rt_expires_at
    add x1, x1, :lo12:rt_expires_at
    ldr x1, [x1]
    bl rt_service_append_u64
    adrp x1, json_order_content_suffix
    add x1, x1, :lo12:json_order_content_suffix
    bl rt_service_append_cstr
    strb wzr, [x0]
    adrp x1, rt_service_body
    add x1, x1, :lo12:rt_service_body
    sub x0, x0, x1
    ldp x29, x30, [sp], #16
    ret

rt_service_prepare_create_args:
    adrp x3, rt_service_argv
    add x3, x3, :lo12:rt_service_argv
    str xzr, [x3]
    add x4, x3, #8
    str x0, [x4]
    add x4, x3, #16
    str x1, [x4]
    add x4, x3, #24
    str x2, [x4]
    adrp x4, rt_argc
    add x4, x4, :lo12:rt_argc
    mov x5, #4
    str x5, [x4]
    adrp x4, rt_argv
    add x4, x4, :lo12:rt_argv
    str x3, [x4]
    adrp x4, rt_command_index
    add x4, x4, :lo12:rt_command_index
    str xzr, [x4]
    ret

rt_service_create_order:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl rt_service_prepare_create_args
    adrp x0, rt_service_mode
    add x0, x0, :lo12:rt_service_mode
    mov w1, #1
    str w1, [x0]
    bl rt_create_order
    ldp x29, x30, [sp], #16
    ret

rt_service_support_total:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x1, rt_service_argv
    add x1, x1, :lo12:rt_service_argv
    str xzr, [x1]
    add x2, x1, #8
    str x0, [x2]
    adrp x2, rt_argc
    add x2, x2, :lo12:rt_argc
    mov x3, #2
    str x3, [x2]
    adrp x2, rt_argv
    add x2, x2, :lo12:rt_argv
    str x1, [x2]
    adrp x2, rt_command_index
    add x2, x2, :lo12:rt_command_index
    str xzr, [x2]
    adrp x2, rt_service_mode
    add x2, x2, :lo12:rt_service_mode
    mov w3, #1
    str w3, [x2]
    bl rt_support_total
    ldp x29, x30, [sp], #16
    ret

rt_service_reply_content:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    adrp x0, rt_service_message_overflow
    add x0, x0, :lo12:rt_service_message_overflow
    ldr w0, [x0]
    cbnz w0, rt_service_reply_overflow
    adrp x0, rt_service_interaction_deferred
    add x0, x0, :lo12:rt_service_interaction_deferred
    ldr w0, [x0]
    cbnz w0, rt_service_reply_deferred
    bl rt_service_build_ephemeral
    mov x20, x0
    adrp x0, rt_service_interaction_id
    add x0, x0, :lo12:rt_service_interaction_id
    adrp x1, rt_service_interaction_token
    add x1, x1, :lo12:rt_service_interaction_token
    adrp x2, rt_service_body
    add x2, x2, :lo12:rt_service_body
    mov x3, x20
    bl rt_service_send_interaction
    b rt_service_reply_return
rt_service_reply_deferred:
    mov x0, x19
    bl rt_service_edit_original
    b rt_service_reply_return
rt_service_reply_overflow:
    mov w0, #1
rt_service_reply_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
rt_service_reply_static:
    b rt_service_reply_content

rt_service_extract_interaction_user:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x0, x19
    mov x1, x20
    bl rt_service_copy_json
    cmn x0, #1
    b.eq rt_service_extract_interaction_user_restore
    adrp x0, json_data_key
    add x0, x0, :lo12:json_data_key
    mov x1, #1
    bl rt_json_select_named_object
    cbnz w0, rt_service_extract_interaction_user_restore
    adrp x0, rt_json_selector_found
    add x0, x0, :lo12:rt_json_selector_found
    ldr w0, [x0]
    cbz w0, rt_service_extract_interaction_user_restore
    adrp x0, json_member_key
    add x0, x0, :lo12:json_member_key
    mov x1, #6
    bl rt_json_select_named_object
    cbnz w0, rt_service_extract_interaction_user_direct
    adrp x0, rt_json_selector_found
    add x0, x0, :lo12:rt_json_selector_found
    ldr w0, [x0]
    cbz w0, rt_service_extract_interaction_user_direct
    adrp x0, json_user_key
    add x0, x0, :lo12:json_user_key
    mov x1, #4
    bl rt_json_select_named_object
    cbnz w0, rt_service_extract_interaction_user_restore
    adrp x0, rt_json_selector_found
    add x0, x0, :lo12:rt_json_selector_found
    ldr w0, [x0]
    cbz w0, rt_service_extract_interaction_user_restore
    b rt_service_extract_interaction_user_value
rt_service_extract_interaction_user_direct:
    adrp x0, json_user_key
    add x0, x0, :lo12:json_user_key
    mov x1, #4
    bl rt_json_select_named_object
    cbnz w0, rt_service_extract_interaction_user_restore
    adrp x0, rt_json_selector_found
    add x0, x0, :lo12:rt_json_selector_found
    ldr w0, [x0]
    cbz w0, rt_service_extract_interaction_user_restore
rt_service_extract_interaction_user_value:
    adrp x0, json_message_id
    add x0, x0, :lo12:json_message_id
    mov x1, #2
    adrp x2, rt_service_user
    add x2, x2, :lo12:rt_service_user
    mov x3, #256
    bl rt_json_value
rt_service_extract_interaction_user_restore:
    mov x0, x19
    mov x1, x20
    bl rt_service_copy_json
    mov w0, wzr
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

rt_service_validate_button_message:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_panel_message_id
    add x0, x0, :lo12:rt_panel_message_id
    bl rt_cstr_length
    cbz x0, rt_service_validate_button_message_fail
    adrp x0, json_message_key
    add x0, x0, :lo12:json_message_key
    mov x1, #7
    bl rt_json_select_named_object
    cbnz w0, rt_service_validate_button_message_fail
    adrp x0, rt_json_selector_found
    add x0, x0, :lo12:rt_json_selector_found
    ldr w0, [x0]
    cbz w0, rt_service_validate_button_message_fail
    adrp x0, json_message_id
    add x0, x0, :lo12:json_message_id
    mov x1, #2
    adrp x2, rt_service_channel
    add x2, x2, :lo12:rt_service_channel
    mov x3, #256
    bl rt_json_value
    cbnz w0, rt_service_validate_button_message_fail
    adrp x0, rt_json_value_length
    add x0, x0, :lo12:rt_json_value_length
    ldr x0, [x0]
    cbz x0, rt_service_validate_button_message_fail
    adrp x0, rt_panel_message_id
    add x0, x0, :lo12:rt_panel_message_id
    bl rt_cstr_length
    mov x2, x0
    adrp x0, rt_service_channel
    add x0, x0, :lo12:rt_service_channel
    adrp x1, rt_panel_message_id
    add x1, x1, :lo12:rt_panel_message_id
    bl rt_str_eq
    cbz w0, rt_service_validate_button_message_fail
    mov w0, wzr
    b rt_service_validate_button_message_return
rt_service_validate_button_message_fail:
    mov w0, #1
rt_service_validate_button_message_return:
    ldp x29, x30, [sp], #16
    ret

rt_service_validate_interaction_scope:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_discord_application_length
    add x0, x0, :lo12:rt_discord_application_length
    ldr x2, [x0]
    cbz x2, rt_service_validate_interaction_scope_fail
    adrp x0, json_key_application_id
    add x0, x0, :lo12:json_key_application_id
    mov x1, #14
    adrp x2, rt_service_channel
    add x2, x2, :lo12:rt_service_channel
    mov x3, #256
    bl rt_json_value
    cbnz w0, rt_service_validate_interaction_scope_fail
    adrp x0, rt_json_value_length
    add x0, x0, :lo12:rt_json_value_length
    ldr x0, [x0]
    cbz x0, rt_service_validate_interaction_scope_fail
    adrp x0, rt_service_channel
    add x0, x0, :lo12:rt_service_channel
    adrp x1, rt_discord_application
    add x1, x1, :lo12:rt_discord_application
    adrp x2, rt_discord_application_length
    add x2, x2, :lo12:rt_discord_application_length
    ldr x2, [x2]
    bl rt_str_eq
    cbz w0, rt_service_validate_interaction_scope_fail
    adrp x0, rt_discord_guild_length
    add x0, x0, :lo12:rt_discord_guild_length
    ldr x2, [x0]
    cbz x2, rt_service_validate_interaction_scope_fail
    adrp x0, json_key_guild_id
    add x0, x0, :lo12:json_key_guild_id
    mov x1, #8
    adrp x2, rt_service_channel
    add x2, x2, :lo12:rt_service_channel
    mov x3, #256
    bl rt_json_value
    cbnz w0, rt_service_validate_interaction_scope_fail
    adrp x0, rt_json_value_length
    add x0, x0, :lo12:rt_json_value_length
    ldr x0, [x0]
    cbz x0, rt_service_validate_interaction_scope_fail
    adrp x0, rt_service_channel
    add x0, x0, :lo12:rt_service_channel
    adrp x1, rt_discord_guild
    add x1, x1, :lo12:rt_discord_guild
    adrp x2, rt_discord_guild_length
    add x2, x2, :lo12:rt_discord_guild_length
    ldr x2, [x2]
    bl rt_str_eq
    cbz w0, rt_service_validate_interaction_scope_fail
    adrp x0, rt_discord_panel_length
    add x0, x0, :lo12:rt_discord_panel_length
    ldr x2, [x0]
    cbz x2, rt_service_validate_interaction_scope_fail
    adrp x0, json_key_channel_id
    add x0, x0, :lo12:json_key_channel_id
    mov x1, #10
    adrp x2, rt_service_channel
    add x2, x2, :lo12:rt_service_channel
    mov x3, #256
    bl rt_json_value
    cbnz w0, rt_service_validate_interaction_scope_fail
    adrp x0, rt_json_value_length
    add x0, x0, :lo12:rt_json_value_length
    ldr x0, [x0]
    cbz x0, rt_service_validate_interaction_scope_fail
    adrp x0, rt_service_channel
    add x0, x0, :lo12:rt_service_channel
    adrp x1, rt_discord_panel
    add x1, x1, :lo12:rt_discord_panel
    adrp x2, rt_discord_panel_length
    add x2, x2, :lo12:rt_discord_panel_length
    ldr x2, [x2]
    bl rt_str_eq
    cbz w0, rt_service_validate_interaction_scope_fail
    mov w0, wzr
    b rt_service_validate_interaction_scope_return
rt_service_validate_interaction_scope_fail:
    mov w0, #1
rt_service_validate_interaction_scope_return:
    ldp x29, x30, [sp], #16
    ret

rt_service_select_interaction_data:
    adrp x0, json_data_key
    add x0, x0, :lo12:json_data_key
    mov x1, #1
    bl rt_json_select_named_object
    cbnz w0, rt_service_select_interaction_data_fail
    adrp x0, rt_json_selector_found
    add x0, x0, :lo12:rt_json_selector_found
    ldr w0, [x0]
    cbz w0, rt_service_select_interaction_data_fail
    mov w0, wzr
    ret
rt_service_select_interaction_data_fail:
    mov w0, #1
    ret

rt_service_handle_interaction:
    stp x29, x30, [sp, #-96]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    adrp x0, rt_service_mode
    add x0, x0, :lo12:rt_service_mode
    mov w1, #1
    str w1, [x0]
    adrp x0, rt_service_message_overflow
    add x0, x0, :lo12:rt_service_message_overflow
    str wzr, [x0]
    adrp x0, rt_service_interaction_deferred
    add x0, x0, :lo12:rt_service_interaction_deferred
    str wzr, [x0]
    adrp x0, rt_service_user
    add x0, x0, :lo12:rt_service_user
    strb wzr, [x0]
    adrp x0, rt_service_custom_id
    add x0, x0, :lo12:rt_service_custom_id
    strb wzr, [x0]
    adrp x0, rt_service_name
    add x0, x0, :lo12:rt_service_name
    strb wzr, [x0]
    adrp x0, rt_service_amount
    add x0, x0, :lo12:rt_service_amount
    strb wzr, [x0]
    mov x0, x19
    mov x1, x20
    bl rt_service_copy_json
    cmn x0, #1
    b.eq rt_service_interaction_parse_failed
    adrp x0, rt_service_message_length
    add x0, x0, :lo12:rt_service_message_length
    str xzr, [x0]
    adrp x0, rt_service_message
    add x0, x0, :lo12:rt_service_message
    strb wzr, [x0]
    adrp x0, rt_json_buffer
    add x0, x0, :lo12:rt_json_buffer
    adrp x1, rt_json_length
    add x1, x1, :lo12:rt_json_length
    ldr x1, [x1]
    adrp x2, json_event_interaction
    add x2, x2, :lo12:json_event_interaction
    mov x3, #24
    bl native_json_find_root_pattern
    cbnz x0, rt_service_interaction_event_ready
    adrp x2, json_event_interaction_space
    add x2, x2, :lo12:json_event_interaction_space
    mov x3, #25
    bl native_json_find_root_pattern
    cbz x0, rt_service_interaction_parse_failed
rt_service_interaction_event_ready:
    mov x0, x19
    mov x1, x20
    bl rt_service_extract_interaction_user
    bl rt_service_validate_interaction_scope
    cbnz w0, rt_service_interaction_parse_failed
    adrp x0, json_message_id
    add x0, x0, :lo12:json_message_id
    mov x1, #2
    adrp x2, rt_service_interaction_id
    add x2, x2, :lo12:rt_service_interaction_id
    mov x3, #256
    bl rt_json_value
    cbnz w0, rt_service_interaction_parse_failed
    adrp x0, json_token_key
    add x0, x0, :lo12:json_token_key
    mov x1, #5
    adrp x2, rt_service_interaction_token
    add x2, x2, :lo12:rt_service_interaction_token
    mov x3, #512
    bl rt_json_value
    cbnz w0, rt_service_interaction_parse_failed
    adrp x0, rt_json_buffer
    add x0, x0, :lo12:rt_json_buffer
    adrp x1, rt_json_length
    add x1, x1, :lo12:rt_json_length
    ldr x1, [x1]
    adrp x2, json_type_pattern
    add x2, x2, :lo12:json_type_pattern
    mov x3, #7
    bl native_json_find_root_number
    cmp x0, #-1
    b.eq rt_service_interaction_parse_failed
    mov x23, x0
    cmp x23, #3
    b.eq rt_service_interaction_button
    cmp x23, #5
    b.eq rt_service_interaction_modal
    cmp x23, #2
    b.eq rt_service_interaction_command
    adrp x0, response_unsupported
    add x0, x0, :lo12:response_unsupported
    bl rt_service_reply_content
    b rt_service_interaction_return
rt_service_interaction_button:
    bl rt_service_validate_button_message
    cbnz w0, rt_service_interaction_parse_failed
    mov x0, x19
    mov x1, x20
    bl rt_service_copy_json
    cmn x0, #1
    b.eq rt_service_interaction_parse_failed
    bl rt_service_select_interaction_data
    cbnz w0, rt_service_interaction_parse_failed
    adrp x0, json_custom_pattern
    add x0, x0, :lo12:json_custom_pattern
    mov x1, #13
    adrp x2, rt_service_custom_id
    add x2, x2, :lo12:rt_service_custom_id
    mov x3, #256
    bl rt_json_extract_pattern
    cmn x0, #1
    b.ne rt_service_interaction_button_custom_ready
    adrp x0, json_custom_pattern_space
    add x0, x0, :lo12:json_custom_pattern_space
    mov x1, #14
    adrp x2, rt_service_custom_id
    add x2, x2, :lo12:rt_service_custom_id
    mov x3, #256
    bl rt_json_extract_pattern
    cmn x0, #1
    b.eq rt_service_interaction_invalid
rt_service_interaction_button_custom_ready:
    adrp x0, rt_service_custom_id
    add x0, x0, :lo12:rt_service_custom_id
    adrp x1, button_deposit_id
    add x1, x1, :lo12:button_deposit_id
    mov x2, #18
    bl rt_str_eq
    cbz w0, rt_service_interaction_unsupported
    adrp x0, json_modal_response
    add x0, x0, :lo12:json_modal_response
    bl rt_service_copy_static
    mov x3, x0
    adrp x2, rt_service_body
    add x2, x2, :lo12:rt_service_body
    adrp x0, rt_service_interaction_id
    add x0, x0, :lo12:rt_service_interaction_id
    adrp x1, rt_service_interaction_token
    add x1, x1, :lo12:rt_service_interaction_token
    mov x19, x0
    mov x20, x1
    adrp x0, rt_service_interaction_id
    add x0, x0, :lo12:rt_service_interaction_id
    adrp x1, rt_service_interaction_token
    add x1, x1, :lo12:rt_service_interaction_token
    adrp x2, rt_service_body
    add x2, x2, :lo12:rt_service_body
    bl rt_service_send_interaction
    b rt_service_interaction_return
rt_service_interaction_modal:
    bl rt_service_defer_interaction
    cbnz w0, rt_service_interaction_return
    adrp x0, rt_service_interaction_deferred
    add x0, x0, :lo12:rt_service_interaction_deferred
    mov w1, #1
    str w1, [x0]
    bl rt_service_select_interaction_data
    cbnz w0, rt_service_interaction_invalid
    adrp x0, json_modal_data_key
    add x0, x0, :lo12:json_modal_data_key
    mov x1, #4
    bl rt_json_select_named_object
    cbnz w0, rt_service_interaction_invalid
    adrp x0, rt_json_selector_found
    add x0, x0, :lo12:rt_json_selector_found
    ldr w0, [x0]
    cbz w0, rt_service_interaction_invalid
    adrp x0, json_custom_pattern
    add x0, x0, :lo12:json_custom_pattern
    mov x1, #13
    adrp x2, rt_service_custom_id
    add x2, x2, :lo12:rt_service_custom_id
    mov x3, #256
    bl rt_json_extract_pattern
    cmn x0, #1
    b.ne rt_service_interaction_modal_custom_ready
    adrp x0, json_custom_pattern_space
    add x0, x0, :lo12:json_custom_pattern_space
    mov x1, #14
    adrp x2, rt_service_custom_id
    add x2, x2, :lo12:rt_service_custom_id
    mov x3, #256
    bl rt_json_extract_pattern
    cmn x0, #1
    b.eq rt_service_interaction_invalid
rt_service_interaction_modal_custom_ready:
    adrp x0, rt_service_custom_id
    add x0, x0, :lo12:rt_service_custom_id
    adrp x1, modal_deposit_id
    add x1, x1, :lo12:modal_deposit_id
    mov x2, #24
    bl rt_str_eq
    cbz w0, rt_service_interaction_unsupported
    adrp x0, rt_service_user
    add x0, x0, :lo12:rt_service_user
    bl rt_cstr_length
    cbz x0, rt_service_interaction_invalid
rt_service_interaction_modal_user_ready:
    adrp x0, json_value_prefix
    add x0, x0, :lo12:json_value_prefix
    mov x1, #9
    adrp x2, rt_service_name
    add x2, x2, :lo12:rt_service_name
    mov x3, #512
    mov x4, xzr
    bl rt_json_extract_nth_pattern
    cmn x0, #1
    b.eq rt_service_interaction_invalid
    adrp x0, json_value_prefix
    add x0, x0, :lo12:json_value_prefix
    mov x1, #9
    adrp x2, rt_service_amount
    add x2, x2, :lo12:rt_service_amount
    mov x3, #64
    mov x4, #1
    bl rt_json_extract_nth_pattern
    cmn x0, #1
    b.eq rt_service_interaction_invalid
    adrp x0, rt_service_user
    add x0, x0, :lo12:rt_service_user
    adrp x1, rt_service_name
    add x1, x1, :lo12:rt_service_name
    adrp x2, rt_service_amount
    add x2, x2, :lo12:rt_service_amount
    bl rt_service_create_order
    cbnz w0, rt_service_interaction_order_fail
    bl rt_service_build_order_content
    mov x19, x0
    adrp x0, rt_service_body
    add x0, x0, :lo12:rt_service_body
    adrp x1, rt_service_message
    add x1, x1, :lo12:rt_service_message
    bl rt_copy_cstr
    adrp x0, rt_service_message
    add x0, x0, :lo12:rt_service_message
    bl rt_service_reply_content
    adrp x0, rt_order_dm_required
    add x0, x0, :lo12:rt_order_dm_required
    ldr w0, [x0]
    cbz w0, rt_service_interaction_return
    adrp x0, rt_service_user
    add x0, x0, :lo12:rt_service_user
    adrp x1, rt_service_message
    add x1, x1, :lo12:rt_service_message
    adrp x0, rt_order_id
    add x0, x0, :lo12:rt_order_id
    adrp x1, dm_nonce_order_prefix
    add x1, x1, :lo12:dm_nonce_order_prefix
    bl rt_service_build_dm_nonce
    cbnz w0, rt_service_interaction_dm_failed
    adrp x0, rt_service_user
    add x0, x0, :lo12:rt_service_user
    adrp x1, rt_service_message
    add x1, x1, :lo12:rt_service_message
    bl rt_service_send_dm
    cbnz w0, rt_service_interaction_dm_failed
    adrp x0, status_sent
    add x0, x0, :lo12:status_sent
    adrp x1, rt_order_id
    add x1, x1, :lo12:rt_order_id
    mov x2, xzr
    bl rt_update_dm_status
    b rt_service_interaction_return
rt_service_interaction_dm_failed:
    adrp x0, status_failed
    add x0, x0, :lo12:status_failed
    adrp x1, rt_order_id
    add x1, x1, :lo12:rt_order_id
    mov x2, xzr
    bl rt_update_dm_status
    b rt_service_interaction_return
rt_service_interaction_command:
    bl rt_service_defer_interaction
    cbnz w0, rt_service_interaction_return
    adrp x0, rt_service_interaction_deferred
    add x0, x0, :lo12:rt_service_interaction_deferred
    mov w1, #1
    str w1, [x0]
    bl rt_service_select_interaction_data
    cbnz w0, rt_service_interaction_invalid
    adrp x0, json_name_pattern
    add x0, x0, :lo12:json_name_pattern
    mov x1, #8
    adrp x2, rt_service_command_name
    add x2, x2, :lo12:rt_service_command_name
    mov x3, #256
    bl rt_json_extract_pattern
    cmn x0, #1
    b.ne rt_service_interaction_command_name_ready
    adrp x0, json_name_pattern_space
    add x0, x0, :lo12:json_name_pattern_space
    mov x1, #9
    adrp x2, rt_service_command_name
    add x2, x2, :lo12:rt_service_command_name
    mov x3, #256
    bl rt_json_extract_pattern
    cmn x0, #1
    b.eq rt_service_interaction_invalid
rt_service_interaction_command_name_ready:
    adrp x0, rt_service_user
    add x0, x0, :lo12:rt_service_user
    bl rt_cstr_length
    cbz x0, rt_service_interaction_invalid
rt_service_interaction_command_user_ready:
    adrp x0, rt_service_command_name
    add x0, x0, :lo12:rt_service_command_name
    adrp x1, command_support_name
    add x1, x1, :lo12:command_support_name
    mov x2, #12
    bl rt_str_eq
    cbnz w0, rt_service_interaction_support
    adrp x0, rt_service_command_name
    add x0, x0, :lo12:rt_service_command_name
    adrp x1, command_panel_name
    add x1, x1, :lo12:command_panel_name
    mov x2, #12
    bl rt_str_eq
    cbnz w0, rt_service_interaction_panel
    adrp x0, rt_service_command_name
    add x0, x0, :lo12:rt_service_command_name
    adrp x1, command_review_name
    add x1, x1, :lo12:command_review_name
    mov x2, #12
    bl rt_str_eq
    cbnz w0, rt_service_interaction_review
    adrp x0, rt_service_command_name
    add x0, x0, :lo12:rt_service_command_name
    adrp x1, command_ledger_name
    add x1, x1, :lo12:command_ledger_name
    mov x2, #12
    bl rt_str_eq
    cbnz w0, rt_service_interaction_ledger
    adrp x0, response_unsupported
    add x0, x0, :lo12:response_unsupported
    bl rt_service_reply_content
    b rt_service_interaction_return
rt_service_interaction_support:
    adrp x0, rt_service_message_length
    add x0, x0, :lo12:rt_service_message_length
    str xzr, [x0]
    adrp x0, rt_service_message
    add x0, x0, :lo12:rt_service_message
    strb wzr, [x0]
    adrp x0, rt_service_user
    add x0, x0, :lo12:rt_service_user
    bl rt_service_support_total
    adrp x0, rt_service_message
    add x0, x0, :lo12:rt_service_message
    adrp x1, response_total_prefix
    add x1, x1, :lo12:response_total_prefix
    bl rt_service_append_cstr
    adrp x1, rt_current_total
    add x1, x1, :lo12:rt_current_total
    ldr x1, [x1]
    bl rt_service_append_u64
    adrp x1, response_total_suffix
    add x1, x1, :lo12:response_total_suffix
    bl rt_service_append_cstr
    strb wzr, [x0]
    adrp x0, rt_service_message
    add x0, x0, :lo12:rt_service_message
    bl rt_service_reply_content
    b rt_service_interaction_return
rt_service_interaction_panel:
    adrp x0, rt_service_user
    add x0, x0, :lo12:rt_service_user
    adrp x1, rt_discord_admin
    add x1, x1, :lo12:rt_discord_admin
    adrp x2, rt_discord_admin_length
    add x2, x2, :lo12:rt_discord_admin_length
    ldr x2, [x2]
    bl rt_str_eq
    cbz w0, rt_service_interaction_permission
    bl rt_service_publish_panel
    cbnz w0, rt_service_interaction_panel_fail
    adrp x0, response_panel_success
    add x0, x0, :lo12:response_panel_success
    bl rt_service_reply_content
    b rt_service_interaction_return
rt_service_interaction_review:
    adrp x0, rt_service_user
    add x0, x0, :lo12:rt_service_user
    adrp x1, rt_discord_admin
    add x1, x1, :lo12:rt_discord_admin
    adrp x2, rt_discord_admin_length
    add x2, x2, :lo12:rt_discord_admin_length
    ldr x2, [x2]
    bl rt_str_eq
    cbz w0, rt_service_interaction_permission
    adrp x0, rt_service_message_length
    add x0, x0, :lo12:rt_service_message_length
    str xzr, [x0]
    adrp x0, rt_service_message
    add x0, x0, :lo12:rt_service_message
    strb wzr, [x0]
    bl rt_review_list
    adrp x0, rt_service_message
    add x0, x0, :lo12:rt_service_message
    bl rt_service_reply_content
    b rt_service_interaction_return
rt_service_interaction_ledger:
    adrp x0, rt_service_user
    add x0, x0, :lo12:rt_service_user
    adrp x1, rt_discord_admin
    add x1, x1, :lo12:rt_discord_admin
    adrp x2, rt_discord_admin_length
    add x2, x2, :lo12:rt_discord_admin_length
    ldr x2, [x2]
    bl rt_str_eq
    cbz w0, rt_service_interaction_permission
    adrp x0, rt_service_message_length
    add x0, x0, :lo12:rt_service_message_length
    str xzr, [x0]
    adrp x0, rt_service_message
    add x0, x0, :lo12:rt_service_message
    strb wzr, [x0]
    bl rt_ledger_list
    adrp x0, rt_service_message
    add x0, x0, :lo12:rt_service_message
    bl rt_service_reply_content
    b rt_service_interaction_return
rt_service_interaction_panel_fail:
    adrp x0, response_panel_failed
    add x0, x0, :lo12:response_panel_failed
    bl rt_service_reply_content
    b rt_service_interaction_return
rt_service_interaction_permission:
    adrp x0, response_permission
    add x0, x0, :lo12:response_permission
    bl rt_service_reply_content
    b rt_service_interaction_return
rt_service_interaction_invalid:
    adrp x0, response_invalid
    add x0, x0, :lo12:response_invalid
    bl rt_service_reply_content
    b rt_service_interaction_return
rt_service_interaction_parse_failed:
    adrp x0, service_interaction_parse_failed
    add x0, x0, :lo12:service_interaction_parse_failed
    mov x1, xzr
    bl rt_log_cstr
    b rt_service_interaction_return
rt_service_interaction_order_fail:
    adrp x0, response_order_failed
    add x0, x0, :lo12:response_order_failed
    bl rt_service_reply_content
    b rt_service_interaction_return
rt_service_interaction_unsupported:
    adrp x0, response_unsupported
    add x0, x0, :lo12:response_unsupported
    bl rt_service_reply_content
rt_service_interaction_return:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret

rt_service_load_gateway_state:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, setting_gateway_sequence
    add x0, x0, :lo12:setting_gateway_sequence
    adrp x1, rt_setting_output
    add x1, x1, :lo12:rt_setting_output
    mov x2, #4096
    bl rt_setting_get
    cbnz w0, rt_service_gateway_state_empty
    adrp x0, rt_setting_output
    add x0, x0, :lo12:rt_setting_output
    bl rt_parse_decimal
    cmn x0, #1
    b.eq rt_service_gateway_state_empty
    adrp x1, ws_sequence
    add x1, x1, :lo12:ws_sequence
    str x0, [x1]
    adrp x1, ws_sequence_valid
    add x1, x1, :lo12:ws_sequence_valid
    mov w2, #1
    str w2, [x1]
    b rt_service_gateway_state_session
rt_service_gateway_state_empty:
    adrp x1, ws_sequence_valid
    add x1, x1, :lo12:ws_sequence_valid
    str wzr, [x1]
rt_service_gateway_state_session:
    adrp x0, setting_gateway_session
    add x0, x0, :lo12:setting_gateway_session
    adrp x1, rt_service_session_id
    add x1, x1, :lo12:rt_service_session_id
    mov x2, #256
    bl rt_setting_get
    adrp x0, setting_gateway_resume
    add x0, x0, :lo12:setting_gateway_resume
    adrp x1, rt_service_resume_url
    add x1, x1, :lo12:rt_service_resume_url
    mov x2, #1024
    bl rt_setting_get
    ldp x29, x30, [sp], #16
    ret

rt_service_save_gateway_state:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_setting_value
    add x0, x0, :lo12:rt_setting_value
    adrp x1, ws_sequence_valid
    add x1, x1, :lo12:ws_sequence_valid
    ldr w1, [x1]
    cbz w1, rt_service_save_gateway_empty_sequence
    adrp x1, ws_sequence
    add x1, x1, :lo12:ws_sequence
    ldr x1, [x1]
    mov x2, #0
    mov x3, x0
    mov x0, x1
    mov x1, x3
    mov x2, #4096
    bl rt_u64_decimal
    b rt_service_save_gateway_sequence_done
rt_service_save_gateway_empty_sequence:
    strb wzr, [x0]
rt_service_save_gateway_sequence_done:
    adrp x0, setting_gateway_sequence
    add x0, x0, :lo12:setting_gateway_sequence
    adrp x1, rt_setting_value
    add x1, x1, :lo12:rt_setting_value
    bl rt_setting_set
    adrp x0, setting_gateway_session
    add x0, x0, :lo12:setting_gateway_session
    adrp x1, rt_service_session_id
    add x1, x1, :lo12:rt_service_session_id
    bl rt_setting_set
    adrp x0, setting_gateway_resume
    add x0, x0, :lo12:setting_gateway_resume
    adrp x1, rt_service_resume_url
    add x1, x1, :lo12:rt_service_resume_url
    bl rt_setting_set
    ldp x29, x30, [sp], #16
    ret

rt_service_build_resume:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_service_body
    add x0, x0, :lo12:rt_service_body
    adrp x1, json_gateway_reconnect
    add x1, x1, :lo12:json_gateway_reconnect
    bl rt_service_append_cstr
    adrp x1, rt_discord_token
    add x1, x1, :lo12:rt_discord_token
    bl rt_service_append_json
    adrp x1, json_gateway_resume_mid
    add x1, x1, :lo12:json_gateway_resume_mid
    bl rt_service_append_cstr
    adrp x1, rt_service_session_id
    add x1, x1, :lo12:rt_service_session_id
    bl rt_service_append_json
    adrp x1, json_gateway_resume_seq
    add x1, x1, :lo12:json_gateway_resume_seq
    bl rt_service_append_cstr
    adrp x1, ws_sequence
    add x1, x1, :lo12:ws_sequence
    ldr x1, [x1]
    bl rt_service_append_u64
    adrp x1, json_gateway_resume_suffix
    add x1, x1, :lo12:json_gateway_resume_suffix
    bl rt_service_append_cstr
    strb wzr, [x0]
    adrp x1, rt_service_body
    add x1, x1, :lo12:rt_service_body
    sub x0, x0, x1
    ldp x29, x30, [sp], #16
    ret

rt_service_send_heartbeat:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl native_ws_build_heartbeat
    mov x2, x1
    mov x1, x0
    adrp x0, rt_service_gateway_handle
    add x0, x0, :lo12:rt_service_gateway_handle
    ldr x0, [x0]
    bl native_ws_send_text
    ldp x29, x30, [sp], #16
    ret

rt_service_gateway_open:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x23, xzr
    adrp x22, rt_gateway_url
    add x22, x22, :lo12:rt_gateway_url
    adrp x0, ws_sequence_valid
    add x0, x0, :lo12:ws_sequence_valid
    ldr w0, [x0]
    cbz w0, rt_service_gateway_open_url_ready
    adrp x0, rt_service_session_id
    add x0, x0, :lo12:rt_service_session_id
    ldrb w0, [x0]
    cbz w0, rt_service_gateway_open_url_ready
    adrp x0, rt_service_resume_url
    add x0, x0, :lo12:rt_service_resume_url
    ldrb w0, [x0]
    cbz w0, rt_service_gateway_open_url_ready
    adrp x0, rt_service_resume_url
    add x0, x0, :lo12:rt_service_resume_url
    mov x22, x0
    mov x23, #1
rt_service_gateway_open_url_ready:
    mov x0, x22
    bl native_ws_build_upgrade_url
    cbz x0, rt_service_gateway_open_fail
    mov x0, x22
    bl native_ws_open_url
    cbz x0, rt_service_gateway_open_fail
    adrp x1, rt_service_gateway_handle
    add x1, x1, :lo12:rt_service_gateway_handle
    str x0, [x1]
    mov x19, x0
    bl native_ws_recv_message
    cmp x0, #2
    b.eq rt_service_gateway_open_close_fail
    cbz x0, rt_service_gateway_open_close_fail
    mov x20, x0
    mov x21, x1
    mov x0, x20
    mov x1, x21
    bl native_json_validate_structure
    cbnz w0, rt_service_gateway_open_close_fail
    mov x0, x20
    mov x1, x21
    adrp x2, json_op_pattern
    add x2, x2, :lo12:json_op_pattern
    mov x3, #5
    bl native_json_find_root_number
    cmp x0, #10
    b.ne rt_service_gateway_open_close_fail
    mov x0, x20
    mov x1, x21
    adrp x2, json_key_heartbeat_interval
    add x2, x2, :lo12:json_key_heartbeat_interval
    mov x3, #21
    bl native_json_find_number
    cmp x0, #0
    b.lt rt_service_gateway_open_default_interval
    cmp x0, #1000
    b.hs rt_service_gateway_open_interval_done
rt_service_gateway_open_default_interval:
    mov x0, #30000
rt_service_gateway_open_interval_done:
    adrp x1, ws_heartbeat_interval
    add x1, x1, :lo12:ws_heartbeat_interval
    str x0, [x1]
    adrp x1, ws_sequence_valid
    add x1, x1, :lo12:ws_sequence_valid
    ldr w1, [x1]
    cbz w1, rt_service_gateway_send_identify
    adrp x1, rt_service_session_id
    add x1, x1, :lo12:rt_service_session_id
    ldrb w1, [x1]
    cbz w1, rt_service_gateway_send_identify
    bl rt_service_build_resume
    mov x22, x0
    adrp x1, rt_service_body
    add x1, x1, :lo12:rt_service_body
    mov x0, x19
    mov x2, x22
    bl native_ws_send_text
    cbnz w0, rt_service_gateway_open_close_fail
    b rt_service_gateway_open_sent
rt_service_gateway_send_identify:
    adrp x0, rt_discord_intents
    add x0, x0, :lo12:rt_discord_intents
    ldr x0, [x0]
    adrp x1, ws_identify_intents
    add x1, x1, :lo12:ws_identify_intents
    str x0, [x1]
    adrp x0, rt_discord_token
    add x0, x0, :lo12:rt_discord_token
    bl native_ws_build_identify
    mov x2, x1
    mov x1, x0
    mov x0, x19
    bl native_ws_send_text
    cbnz w0, rt_service_gateway_open_close_fail
rt_service_gateway_open_sent:
    bl rt_now
    adrp x1, rt_service_last_heartbeat
    add x1, x1, :lo12:rt_service_last_heartbeat
    str x0, [x1]
    mov w0, wzr
    b rt_service_gateway_open_return
rt_service_gateway_open_close_fail:
    mov x0, x19
    bl native_ws_close
rt_service_gateway_open_fail:
    cbz x23, rt_service_gateway_open_final_fail
    mov x23, xzr
    adrp x22, rt_gateway_url
    add x22, x22, :lo12:rt_gateway_url
    b rt_service_gateway_open_url_ready
rt_service_gateway_open_final_fail:
    mov w0, #1
rt_service_gateway_open_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_service_sleep_one:
    mov x0, #1
    b rt_service_sleep_seconds

rt_service_sleep_seconds:
    mov x9, x0
    adrp x0, rt_timespec
    add x0, x0, :lo12:rt_timespec
    str x9, [x0, #0]
    str xzr, [x0, #8]
    mov x1, xzr
    mov x8, #101
    svc #0
    ret

rt_service_backoff_sleep:
    stp x29, x30, [sp, #-32]!
    str x19, [sp, #16]
    mov x29, sp
    adrp x1, rt_service_retry_delay
    add x1, x1, :lo12:rt_service_retry_delay
    ldr x0, [x1]
    cbnz x0, rt_service_backoff_ready
    mov x0, #5
    str x0, [x1]
rt_service_backoff_ready:
    mov x19, x0
    bl rt_service_sleep_seconds
    lsl x0, x19, #1
    cmp x0, #60
    b.ls rt_service_backoff_store
    mov x0, #60
rt_service_backoff_store:
    adrp x1, rt_service_retry_delay
    add x1, x1, :lo12:rt_service_retry_delay
    str x0, [x1]
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_service_gateway_heartbeat_due:
    stp x29, x30, [sp, #-32]!
    str x20, [sp, #16]
    mov x29, sp
    bl rt_now
    mov x20, x0
    adrp x1, rt_service_last_heartbeat
    add x1, x1, :lo12:rt_service_last_heartbeat
    ldr x1, [x1]
    sub x20, x20, x1
    adrp x1, ws_heartbeat_interval
    add x1, x1, :lo12:ws_heartbeat_interval
    ldr x1, [x1]
    mov x2, #1000
    udiv x1, x1, x2
    cbnz x1, rt_service_gateway_heartbeat_interval_ready
    mov x1, #1
rt_service_gateway_heartbeat_interval_ready:
    cmp x20, x1
    b.lo rt_service_gateway_heartbeat_not_due
    bl rt_service_send_heartbeat
    cbnz w0, rt_service_gateway_heartbeat_failed
    bl rt_now
    adrp x1, rt_service_last_heartbeat
    add x1, x1, :lo12:rt_service_last_heartbeat
    str x0, [x1]
rt_service_gateway_heartbeat_not_due:
    mov w0, wzr
    b rt_service_gateway_heartbeat_return
rt_service_gateway_heartbeat_failed:
    mov w0, #1
rt_service_gateway_heartbeat_return:
    ldr x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_service_sync_guild_tag_role:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    adrp x0, rt_discord_tag_role_length
    add x0, x0, :lo12:rt_discord_tag_role_length
    ldr x0, [x0]
    cbz x0, rt_service_sync_guild_tag_role_done
    adrp x0, rt_service_url
    add x0, x0, :lo12:rt_service_url
    adrp x1, discord_api_prefix
    add x1, x1, :lo12:discord_api_prefix
    bl rt_service_append_cstr
    adrp x1, path_guild_member_roles_prefix
    add x1, x1, :lo12:path_guild_member_roles_prefix
    bl rt_service_append_cstr
    adrp x1, rt_discord_guild
    add x1, x1, :lo12:rt_discord_guild
    bl rt_service_append_cstr
    adrp x1, path_guild_member_roles_member
    add x1, x1, :lo12:path_guild_member_roles_member
    bl rt_service_append_cstr
    adrp x1, rt_tag_user
    add x1, x1, :lo12:rt_tag_user
    bl rt_service_append_cstr
    adrp x1, path_guild_member_roles_suffix
    add x1, x1, :lo12:path_guild_member_roles_suffix
    bl rt_service_append_cstr
    adrp x1, rt_discord_tag_role
    add x1, x1, :lo12:rt_discord_tag_role
    bl rt_service_append_cstr
    strb wzr, [x0]
    adrp x1, rt_tag_current
    add x1, x1, :lo12:rt_tag_current
    ldr w1, [x1]
    cbz w1, rt_service_sync_guild_tag_role_remove
    adrp x0, method_put
    add x0, x0, :lo12:method_put
    b rt_service_sync_guild_tag_role_request
rt_service_sync_guild_tag_role_remove:
    adrp x0, method_delete
    add x0, x0, :lo12:method_delete
rt_service_sync_guild_tag_role_request:
    adrp x1, rt_service_url
    add x1, x1, :lo12:rt_service_url
    mov x2, xzr
    mov x3, xzr
    bl rt_service_rest_retry
rt_service_sync_guild_tag_role_done:
    mov w0, wzr
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_service_handle_guild_tag_update:
    stp x29, x30, [sp, #-96]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    adrp x0, rt_discord_tag_log_length
    add x0, x0, :lo12:rt_discord_tag_log_length
    ldr x0, [x0]
    cbnz x0, rt_service_guild_tag_configured
    adrp x0, rt_discord_tag_status_length
    add x0, x0, :lo12:rt_discord_tag_status_length
    ldr x0, [x0]
    cbnz x0, rt_service_guild_tag_configured
    adrp x0, rt_discord_tag_role_length
    add x0, x0, :lo12:rt_discord_tag_role_length
    ldr x0, [x0]
    cbz x0, rt_service_guild_tag_done
rt_service_guild_tag_configured:
    mov x0, x19
    mov x1, x20
    bl rt_service_copy_json
    cmn x0, #1
    b.eq rt_service_guild_tag_done
    adrp x0, json_data_key
    add x0, x0, :lo12:json_data_key
    mov x1, #1
    bl rt_json_select_named_object
    cbnz w0, rt_service_guild_tag_done
    adrp x0, rt_json_selector_found
    add x0, x0, :lo12:rt_json_selector_found
    ldr w0, [x0]
    cbz w0, rt_service_guild_tag_done
    adrp x0, json_key_guild_id
    add x0, x0, :lo12:json_key_guild_id
    mov x1, #8
    adrp x2, rt_tag_event_guild
    add x2, x2, :lo12:rt_tag_event_guild
    mov x3, #128
    bl rt_json_value
    cbnz w0, rt_service_guild_tag_done
    adrp x0, rt_tag_event_guild
    add x0, x0, :lo12:rt_tag_event_guild
    adrp x1, rt_discord_guild
    add x1, x1, :lo12:rt_discord_guild
    adrp x2, rt_discord_guild_length
    add x2, x2, :lo12:rt_discord_guild_length
    ldr x2, [x2]
    bl rt_str_eq
    cbz w0, rt_service_guild_tag_done
    adrp x0, json_key_user
    add x0, x0, :lo12:json_key_user
    mov x1, #4
    bl rt_json_select_named_object
    cbnz w0, rt_service_guild_tag_done
    adrp x0, rt_json_selector_found
    add x0, x0, :lo12:rt_json_selector_found
    ldr w0, [x0]
    cbz w0, rt_service_guild_tag_done
    adrp x0, json_message_id
    add x0, x0, :lo12:json_message_id
    mov x1, #2
    adrp x2, rt_tag_user
    add x2, x2, :lo12:rt_tag_user
    mov x3, #256
    bl rt_json_value
    cbnz w0, rt_service_guild_tag_done
    adrp x0, rt_json_value_length
    add x0, x0, :lo12:rt_json_value_length
    ldr x21, [x0]
    adrp x0, json_key_primary_guild
    add x0, x0, :lo12:json_key_primary_guild
    mov x1, #13
    bl rt_json_select_named_object
    cbnz w0, rt_service_guild_tag_done
    adrp x0, rt_json_selector_found
    add x0, x0, :lo12:rt_json_selector_found
    ldr w0, [x0]
    cbz w0, rt_service_guild_tag_no_primary
    mov w23, wzr
    adrp x0, rt_json_buffer
    add x0, x0, :lo12:rt_json_buffer
    adrp x1, rt_json_length
    add x1, x1, :lo12:rt_json_length
    ldr x1, [x1]
    adrp x2, json_member_tag_enabled
    add x2, x2, :lo12:json_member_tag_enabled
    mov x3, #23
    bl native_json_find_root_pattern
    cbnz x0, rt_service_guild_tag_enabled
    adrp x0, rt_json_buffer
    add x0, x0, :lo12:rt_json_buffer
    adrp x1, rt_json_length
    add x1, x1, :lo12:rt_json_length
    ldr x1, [x1]
    adrp x2, json_member_tag_enabled_space
    add x2, x2, :lo12:json_member_tag_enabled_space
    mov x3, #24
    bl native_json_find_root_pattern
    cbz x0, rt_service_guild_tag_identity
rt_service_guild_tag_enabled:
    mov w23, #1
rt_service_guild_tag_active:
    cbz w23, rt_service_guild_tag_identity
    adrp x0, json_key_identity_guild_id
    add x0, x0, :lo12:json_key_identity_guild_id
    mov x1, #17
    adrp x2, rt_tag_identity_guild
    add x2, x2, :lo12:rt_tag_identity_guild
    mov x3, #128
    bl rt_json_value
    cbnz w0, rt_service_guild_tag_done
    adrp x0, rt_tag_identity_guild
    add x0, x0, :lo12:rt_tag_identity_guild
    adrp x1, rt_discord_guild
    add x1, x1, :lo12:rt_discord_guild
    adrp x2, rt_discord_guild_length
    add x2, x2, :lo12:rt_discord_guild_length
    ldr x2, [x2]
    bl rt_str_eq
    cbz w0, rt_service_guild_tag_identity_mismatch
    mov w23, #1
    b rt_service_guild_tag_identity
rt_service_guild_tag_identity_mismatch:
rt_service_guild_tag_no_primary:
    mov w23, wzr
rt_service_guild_tag_identity:
    adrp x0, rt_tag_current
    add x0, x0, :lo12:rt_tag_current
    str w23, [x0]
    mov w24, wzr
    adrp x25, rt_tag_count
    add x25, x25, :lo12:rt_tag_count
    ldr w26, [x25]
    adrp x27, rt_tag_users
    add x27, x27, :lo12:rt_tag_users
rt_service_guild_tag_find_loop:
    cmp w24, w26
    b.hs rt_service_guild_tag_new
    add x28, x27, x24, lsl #8
    adrp x0, rt_tag_user
    add x0, x0, :lo12:rt_tag_user
    mov x1, x28
    mov x2, x21
    bl rt_str_eq
    cbz w0, rt_service_guild_tag_find_next
    adrp x0, rt_tag_states
    add x0, x0, :lo12:rt_tag_states
    add x0, x0, x24, lsl #2
    ldr w0, [x0]
    cmp w0, w23
    b.eq rt_service_guild_tag_done
    adrp x0, rt_tag_states
    add x0, x0, :lo12:rt_tag_states
    add x0, x0, x24, lsl #2
    str w23, [x0]
    bl rt_service_persist_tag_members
    bl rt_service_sync_guild_tag_role
    bl rt_service_send_guild_tag_status
    adrp x0, rt_discord_tag_log_length
    add x0, x0, :lo12:rt_discord_tag_log_length
    ldr x0, [x0]
    cbz x0, rt_service_guild_tag_done
    bl rt_service_send_guild_tag_log
    b rt_service_guild_tag_done
rt_service_guild_tag_find_next:
    add w24, w24, #1
    b rt_service_guild_tag_find_loop
rt_service_guild_tag_new:
    cmp w26, #128
    b.hs rt_service_guild_tag_done
    add x28, x27, x26, lsl #8
    adrp x0, rt_tag_user
    add x0, x0, :lo12:rt_tag_user
    mov x1, x28
    bl rt_copy_cstr
    adrp x0, rt_tag_states
    add x0, x0, :lo12:rt_tag_states
    add x0, x0, x26, lsl #2
    str w23, [x0]
    add w26, w26, #1
    str w26, [x25]
    bl rt_service_persist_tag_members
    bl rt_service_sync_guild_tag_role
    bl rt_service_send_guild_tag_status
rt_service_guild_tag_done:
    mov w0, wzr
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret

rt_service_build_guild_members_url:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_service_url
    add x0, x0, :lo12:rt_service_url
    adrp x1, discord_api_prefix
    add x1, x1, :lo12:discord_api_prefix
    bl rt_service_append_cstr
    adrp x1, path_guild_members_prefix
    add x1, x1, :lo12:path_guild_members_prefix
    bl rt_service_append_cstr
    adrp x1, rt_discord_guild
    add x1, x1, :lo12:rt_discord_guild
    bl rt_service_append_cstr
    adrp x1, path_guild_members_suffix
    add x1, x1, :lo12:path_guild_members_suffix
    bl rt_service_append_cstr
    adrp x1, rt_tag_sync_after
    add x1, x1, :lo12:rt_tag_sync_after
    ldrb w2, [x1]
    cbz w2, rt_service_build_guild_members_url_done
    adrp x1, path_guild_members_after
    add x1, x1, :lo12:path_guild_members_after
    bl rt_service_append_cstr
    adrp x1, rt_tag_sync_after
    add x1, x1, :lo12:rt_tag_sync_after
    bl rt_service_append_cstr
rt_service_build_guild_members_url_done:
    strb wzr, [x0]
    ldp x29, x30, [sp], #16
    ret

rt_service_index_guild_tag_member:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x0, x19
    mov x1, x20
    bl rt_service_copy_json
    cmn x0, #1
    b.eq rt_service_index_guild_tag_member_return
    adrp x0, json_key_user
    add x0, x0, :lo12:json_key_user
    mov x1, #4
    bl rt_json_select_named_object
    cbnz w0, rt_service_index_guild_tag_member_return
    adrp x0, rt_json_selector_found
    add x0, x0, :lo12:rt_json_selector_found
    ldr w0, [x0]
    cbz w0, rt_service_index_guild_tag_member_return
    adrp x0, json_message_id
    add x0, x0, :lo12:json_message_id
    mov x1, #2
    adrp x2, rt_tag_user
    add x2, x2, :lo12:rt_tag_user
    mov x3, #256
    bl rt_json_value
    cbnz w0, rt_service_index_guild_tag_member_return
    adrp x0, rt_tag_user
    add x0, x0, :lo12:rt_tag_user
    bl rt_cstr_length
    cbz x0, rt_service_index_guild_tag_member_return
    adrp x0, rt_tag_user
    add x0, x0, :lo12:rt_tag_user
    adrp x1, rt_tag_sync_after
    add x1, x1, :lo12:rt_tag_sync_after
    bl rt_copy_cstr
    adrp x0, json_key_primary_guild
    add x0, x0, :lo12:json_key_primary_guild
    mov x1, #13
    bl rt_json_select_named_object
    cbnz w0, rt_service_index_guild_tag_member_return
    adrp x0, rt_json_selector_found
    add x0, x0, :lo12:rt_json_selector_found
    ldr w0, [x0]
    cbz w0, rt_service_index_guild_tag_member_remove_role
    adrp x0, rt_json_buffer
    add x0, x0, :lo12:rt_json_buffer
    adrp x1, rt_json_length
    add x1, x1, :lo12:rt_json_length
    ldr x1, [x1]
    adrp x2, json_member_tag_enabled
    add x2, x2, :lo12:json_member_tag_enabled
    mov x3, #23
    bl native_json_find_root_pattern
    cbnz x0, rt_service_index_guild_tag_member_enabled
    adrp x0, rt_json_buffer
    add x0, x0, :lo12:rt_json_buffer
    adrp x1, rt_json_length
    add x1, x1, :lo12:rt_json_length
    ldr x1, [x1]
    adrp x2, json_member_tag_enabled_space
    add x2, x2, :lo12:json_member_tag_enabled_space
    mov x3, #24
    bl native_json_find_root_pattern
    cbz x0, rt_service_index_guild_tag_member_remove_role
rt_service_index_guild_tag_member_enabled:
    adrp x0, json_key_identity_guild_id
    add x0, x0, :lo12:json_key_identity_guild_id
    mov x1, #17
    adrp x2, rt_tag_identity_guild
    add x2, x2, :lo12:rt_tag_identity_guild
    mov x3, #128
    bl rt_json_value
    cbnz w0, rt_service_index_guild_tag_member_return
    adrp x0, rt_tag_identity_guild
    add x0, x0, :lo12:rt_tag_identity_guild
    adrp x1, rt_discord_guild
    add x1, x1, :lo12:rt_discord_guild
    adrp x2, rt_discord_guild_length
    add x2, x2, :lo12:rt_discord_guild_length
    ldr x2, [x2]
    bl rt_str_eq
    cbz w0, rt_service_index_guild_tag_member_remove_role
    adrp x0, rt_tag_current
    add x0, x0, :lo12:rt_tag_current
    mov w1, #1
    str w1, [x0]
    bl rt_service_sync_guild_tag_role
    adrp x0, rt_tag_count
    add x0, x0, :lo12:rt_tag_count
    ldr w21, [x0]
    cmp w21, #128
    b.hs rt_service_index_guild_tag_member_return
    adrp x22, rt_tag_users
    add x22, x22, :lo12:rt_tag_users
    add x22, x22, x21, lsl #8
    adrp x0, rt_tag_user
    add x0, x0, :lo12:rt_tag_user
    mov x1, x22
    bl rt_copy_cstr
    adrp x22, rt_tag_states
    add x22, x22, :lo12:rt_tag_states
    add x22, x22, x21, lsl #2
    mov w23, #1
    str w23, [x22]
    add w21, w21, #1
    adrp x0, rt_tag_count
    add x0, x0, :lo12:rt_tag_count
    str w21, [x0]
rt_service_index_guild_tag_member_return:
    mov w0, wzr
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_service_index_guild_tag_member_remove_role:
    adrp x0, rt_tag_current
    add x0, x0, :lo12:rt_tag_current
    str wzr, [x0]
    bl rt_service_sync_guild_tag_role
    b rt_service_index_guild_tag_member_return

rt_service_sync_guild_tag_status:
    stp x29, x30, [sp, #-176]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x29, sp
    adrp x0, rt_discord_tag_status_length
    add x0, x0, :lo12:rt_discord_tag_status_length
    ldr x0, [x0]
    cbnz x0, rt_service_sync_guild_tag_status_configured
    adrp x0, rt_discord_tag_role_length
    add x0, x0, :lo12:rt_discord_tag_role_length
    ldr x0, [x0]
    cbz x0, rt_service_sync_guild_tag_status_fail
rt_service_sync_guild_tag_status_configured:
    adrp x0, rt_discord_guild_length
    add x0, x0, :lo12:rt_discord_guild_length
    ldr x0, [x0]
    cbz x0, rt_service_sync_guild_tag_status_fail
    adrp x0, rt_tag_count
    add x0, x0, :lo12:rt_tag_count
    str wzr, [x0]
    adrp x0, rt_tag_sync_after
    add x0, x0, :lo12:rt_tag_sync_after
    strb wzr, [x0]
rt_service_sync_guild_tag_status_page:
    adrp x0, rt_tag_sync_after
    add x0, x0, :lo12:rt_tag_sync_after
    adrp x1, rt_tag_sync_previous_after
    add x1, x1, :lo12:rt_tag_sync_previous_after
    bl rt_copy_cstr
    bl rt_service_build_guild_members_url
    adrp x0, method_get
    add x0, x0, :lo12:method_get
    adrp x1, rt_service_url
    add x1, x1, :lo12:rt_service_url
    mov x2, xzr
    mov x3, xzr
    bl rt_service_rest_retry
    cbnz w0, rt_service_sync_guild_tag_status_fail
    adrp x0, rt_service_response_length
    add x0, x0, :lo12:rt_service_response_length
    ldr x20, [x0]
    cbz x20, rt_service_sync_guild_tag_status_fail
    adrp x19, rt_service_response
    add x19, x19, :lo12:rt_service_response
    mov x0, x19
    mov x1, x20
    bl native_json_validate_structure
    cbnz w0, rt_service_sync_guild_tag_status_fail
    mov x21, xzr
rt_service_sync_guild_tag_status_find_array:
    cmp x21, x20
    b.hs rt_service_sync_guild_tag_status_fail
    ldrb w0, [x19, x21]
    cmp w0, #32
    b.eq rt_service_sync_guild_tag_status_find_array_skip
    cmp w0, #9
    b.eq rt_service_sync_guild_tag_status_find_array_skip
    cmp w0, #10
    b.eq rt_service_sync_guild_tag_status_find_array_skip
    cmp w0, #13
    b.eq rt_service_sync_guild_tag_status_find_array_skip
    cmp w0, #91
    b.eq rt_service_sync_guild_tag_status_array_start
    b rt_service_sync_guild_tag_status_fail
rt_service_sync_guild_tag_status_find_array_skip:
    add x21, x21, #1
    b rt_service_sync_guild_tag_status_find_array
rt_service_sync_guild_tag_status_array_start:
    add x21, x21, #1
    adrp x0, rt_tag_sync_page_count
    add x0, x0, :lo12:rt_tag_sync_page_count
    str wzr, [x0]
rt_service_sync_guild_tag_status_array_loop:
    cmp x21, x20
    b.hs rt_service_sync_guild_tag_status_fail
    ldrb w0, [x19, x21]
    cmp w0, #32
    b.eq rt_service_sync_guild_tag_status_array_skip
    cmp w0, #9
    b.eq rt_service_sync_guild_tag_status_array_skip
    cmp w0, #10
    b.eq rt_service_sync_guild_tag_status_array_skip
    cmp w0, #13
    b.eq rt_service_sync_guild_tag_status_array_skip
    cmp w0, #44
    b.eq rt_service_sync_guild_tag_status_array_skip
    cmp w0, #93
    b.eq rt_service_sync_guild_tag_status_page_done
    cmp w0, #123
    b.eq rt_service_sync_guild_tag_status_member_start
    b rt_service_sync_guild_tag_status_fail
rt_service_sync_guild_tag_status_array_skip:
    add x21, x21, #1
    b rt_service_sync_guild_tag_status_array_loop
rt_service_sync_guild_tag_status_member_start:
    mov x22, x21
    mov x23, #1
    mov x24, xzr
    mov x25, xzr
    add x21, x21, #1
rt_service_sync_guild_tag_status_member_scan:
    cmp x21, x20
    b.hs rt_service_sync_guild_tag_status_fail
    ldrb w0, [x19, x21]
    cbnz x24, rt_service_sync_guild_tag_status_member_string
    cmp w0, #34
    b.eq rt_service_sync_guild_tag_status_member_string_start
    cmp w0, #123
    b.eq rt_service_sync_guild_tag_status_member_open
    cmp w0, #91
    b.eq rt_service_sync_guild_tag_status_member_open
    cmp w0, #125
    b.eq rt_service_sync_guild_tag_status_member_close_object
    cmp w0, #93
    b.eq rt_service_sync_guild_tag_status_member_close_array
    add x21, x21, #1
    b rt_service_sync_guild_tag_status_member_scan
rt_service_sync_guild_tag_status_member_string_start:
    mov x24, #1
    mov x25, xzr
    add x21, x21, #1
    b rt_service_sync_guild_tag_status_member_scan
rt_service_sync_guild_tag_status_member_string:
    cbnz x25, rt_service_sync_guild_tag_status_member_string_escaped
    cmp w0, #92
    b.eq rt_service_sync_guild_tag_status_member_string_escape
    cmp w0, #34
    b.eq rt_service_sync_guild_tag_status_member_string_close
    add x21, x21, #1
    b rt_service_sync_guild_tag_status_member_scan
rt_service_sync_guild_tag_status_member_string_escape:
    mov x25, #1
    add x21, x21, #1
    b rt_service_sync_guild_tag_status_member_scan
rt_service_sync_guild_tag_status_member_string_escaped:
    mov x25, xzr
    add x21, x21, #1
    b rt_service_sync_guild_tag_status_member_scan
rt_service_sync_guild_tag_status_member_string_close:
    mov x24, xzr
    add x21, x21, #1
    b rt_service_sync_guild_tag_status_member_scan
rt_service_sync_guild_tag_status_member_open:
    add x23, x23, #1
    add x21, x21, #1
    b rt_service_sync_guild_tag_status_member_scan
rt_service_sync_guild_tag_status_member_close_object:
    cmp x23, #1
    b.eq rt_service_sync_guild_tag_status_member_done
    sub x23, x23, #1
    add x21, x21, #1
    b rt_service_sync_guild_tag_status_member_scan
rt_service_sync_guild_tag_status_member_close_array:
    cmp x23, #1
    b.eq rt_service_sync_guild_tag_status_fail
    sub x23, x23, #1
    add x21, x21, #1
    b rt_service_sync_guild_tag_status_member_scan
rt_service_sync_guild_tag_status_member_done:
    add x21, x21, #1
    sub x1, x21, x22
    add x0, x19, x22
    bl rt_service_index_guild_tag_member
    adrp x0, rt_tag_sync_page_count
    add x0, x0, :lo12:rt_tag_sync_page_count
    ldr w26, [x0]
    add w26, w26, #1
    str w26, [x0]
    b rt_service_sync_guild_tag_status_array_loop
rt_service_sync_guild_tag_status_page_done:
    adrp x0, rt_tag_sync_page_count
    add x0, x0, :lo12:rt_tag_sync_page_count
    ldr w26, [x0]
    cmp w26, #50
    b.lo rt_service_sync_guild_tag_status_complete
    adrp x0, rt_tag_sync_after
    add x0, x0, :lo12:rt_tag_sync_after
    bl rt_cstr_length
    mov x27, x0
    cbz x27, rt_service_sync_guild_tag_status_fail
    adrp x0, rt_tag_sync_previous_after
    add x0, x0, :lo12:rt_tag_sync_previous_after
    bl rt_cstr_length
    mov x28, x0
    cmp x27, x28
    b.ne rt_service_sync_guild_tag_status_page
    adrp x0, rt_tag_sync_after
    add x0, x0, :lo12:rt_tag_sync_after
    adrp x1, rt_tag_sync_previous_after
    add x1, x1, :lo12:rt_tag_sync_previous_after
    mov x2, x27
    bl rt_str_eq
    cbnz w0, rt_service_sync_guild_tag_status_fail
    b rt_service_sync_guild_tag_status_page
rt_service_sync_guild_tag_status_complete:
    bl rt_service_persist_tag_members
    bl rt_service_send_guild_tag_status
    mov w0, wzr
    b rt_service_sync_guild_tag_status_return
rt_service_sync_guild_tag_status_fail:
    bl rt_service_load_tag_status
    mov w0, #1
rt_service_sync_guild_tag_status_return:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #176
    ret

rt_service_persist_tag_members:
    stp x29, x30, [sp, #-80]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    mov x29, sp
    adrp x19, rt_tag_status_members
    add x19, x19, :lo12:rt_tag_status_members
    mov x20, x19
    strb wzr, [x20]
    mov w21, #1
    mov w22, wzr
    adrp x23, rt_tag_count
    add x23, x23, :lo12:rt_tag_count
    ldr w23, [x23]
    adrp x24, rt_tag_users
    add x24, x24, :lo12:rt_tag_users
    adrp x25, rt_tag_states
    add x25, x25, :lo12:rt_tag_states
rt_service_persist_tag_members_loop:
    cmp w22, w23
    b.hs rt_service_persist_tag_members_done
    add x26, x25, x22, lsl #2
    ldr w0, [x26]
    cbz w0, rt_service_persist_tag_members_next
    cbnz w21, rt_service_persist_tag_members_first
    mov w0, #44
    strb w0, [x20], #1
rt_service_persist_tag_members_first:
    mov w21, wzr
    add x0, x24, x22, lsl #8
    mov x1, x0
    mov x0, x20
    bl rt_service_append_cstr
    mov x20, x0
rt_service_persist_tag_members_next:
    add w22, w22, #1
    b rt_service_persist_tag_members_loop
rt_service_persist_tag_members_done:
    strb wzr, [x20]
    adrp x0, json_tag_status_setting_members
    add x0, x0, :lo12:json_tag_status_setting_members
    mov x1, x19
    mov x2, #4096
    bl rt_setting_set
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret

rt_service_load_tag_status:
    stp x29, x30, [sp, #-96]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x29, sp
    adrp x0, json_tag_status_setting_message
    add x0, x0, :lo12:json_tag_status_setting_message
    adrp x1, rt_tag_status_message
    add x1, x1, :lo12:rt_tag_status_message
    mov x2, #256
    bl rt_setting_get
    adrp x0, json_tag_status_setting_channel
    add x0, x0, :lo12:json_tag_status_setting_channel
    adrp x1, rt_tag_status_stored_channel
    add x1, x1, :lo12:rt_tag_status_stored_channel
    mov x2, #128
    bl rt_setting_get
    adrp x0, rt_discord_tag_status
    add x0, x0, :lo12:rt_discord_tag_status
    bl rt_cstr_length
    mov x20, x0
    adrp x0, rt_tag_status_stored_channel
    add x0, x0, :lo12:rt_tag_status_stored_channel
    adrp x1, rt_discord_tag_status
    add x1, x1, :lo12:rt_discord_tag_status
    mov x2, x20
    bl rt_str_eq
    cbnz w0, rt_service_load_tag_status_channel_ready
    adrp x0, rt_tag_status_message
    add x0, x0, :lo12:rt_tag_status_message
    strb wzr, [x0]
rt_service_load_tag_status_channel_ready:
    adrp x0, json_tag_status_setting_members
    add x0, x0, :lo12:json_tag_status_setting_members
    adrp x1, rt_tag_status_members
    add x1, x1, :lo12:rt_tag_status_members
    mov x2, #4096
    bl rt_setting_get
    adrp x0, rt_tag_count
    add x0, x0, :lo12:rt_tag_count
    str wzr, [x0]
    adrp x19, rt_tag_status_members
    add x19, x19, :lo12:rt_tag_status_members
    mov x20, xzr
    mov w21, wzr
    adrp x22, rt_tag_users
    add x22, x22, :lo12:rt_tag_users
    adrp x23, rt_tag_states
    add x23, x23, :lo12:rt_tag_states
rt_service_load_tag_status_scan:
    ldrb w26, [x19, x20]
    cbz w26, rt_service_load_tag_status_done
    cmp w26, #44
    b.eq rt_service_load_tag_status_skip_comma
    cmp w21, #128
    b.hs rt_service_load_tag_status_done
    add x24, x22, x21, lsl #8
    mov x25, xzr
rt_service_load_tag_status_copy:
    ldrb w26, [x19, x20]
    cbz w26, rt_service_load_tag_status_token_end
    cmp w26, #44
    b.eq rt_service_load_tag_status_token_end
    cmp x25, #255
    b.hs rt_service_load_tag_status_discard_token
    strb w26, [x24, x25]
    add x25, x25, #1
    add x20, x20, #1
    b rt_service_load_tag_status_copy
rt_service_load_tag_status_discard_token:
    ldrb w26, [x19, x20]
    cbz w26, rt_service_load_tag_status_done
    cmp w26, #44
    b.eq rt_service_load_tag_status_token_end
    add x20, x20, #1
    b rt_service_load_tag_status_discard_token
rt_service_load_tag_status_token_end:
    strb wzr, [x24, x25]
    cbz x25, rt_service_load_tag_status_after_token
    add x27, x23, x21, lsl #2
    mov w28, #1
    str w28, [x27]
    add w21, w21, #1
rt_service_load_tag_status_after_token:
    ldrb w26, [x19, x20]
    cbz w26, rt_service_load_tag_status_done
    add x20, x20, #1
    b rt_service_load_tag_status_scan
rt_service_load_tag_status_skip_comma:
    add x20, x20, #1
    b rt_service_load_tag_status_scan
rt_service_load_tag_status_done:
    adrp x0, rt_tag_count
    add x0, x0, :lo12:rt_tag_count
    str w21, [x0]
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret

rt_service_build_guild_tag_status:
    stp x29, x30, [sp, #-80]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    mov x29, sp
    adrp x19, rt_service_body
    add x19, x19, :lo12:rt_service_body
    mov x0, x19
    adrp x1, json_tag_status_prefix
    add x1, x1, :lo12:json_tag_status_prefix
    bl rt_service_append_cstr
    mov x23, x0
    adrp x20, rt_tag_count
    add x20, x20, :lo12:rt_tag_count
    ldr w20, [x20]
    mov w21, wzr
    mov w22, wzr
    adrp x24, rt_tag_states
    add x24, x24, :lo12:rt_tag_states
rt_service_build_guild_tag_status_count_loop:
    cmp w22, w20
    b.hs rt_service_build_guild_tag_status_count_done
    add x0, x24, x22, lsl #2
    ldr w0, [x0]
    cbz w0, rt_service_build_guild_tag_status_count_next
    add w21, w21, #1
rt_service_build_guild_tag_status_count_next:
    add w22, w22, #1
    b rt_service_build_guild_tag_status_count_loop
rt_service_build_guild_tag_status_count_done:
    mov x0, x23
    mov x1, x21
    bl rt_service_append_u64
    mov x23, x0
    adrp x1, json_tag_status_count_suffix
    add x1, x1, :lo12:json_tag_status_count_suffix
    mov x0, x23
    bl rt_service_append_cstr
    mov x23, x0
    cbnz w21, rt_service_build_guild_tag_status_items
    adrp x1, json_tag_status_empty
    add x1, x1, :lo12:json_tag_status_empty
    mov x0, x23
    bl rt_service_append_cstr
    mov x23, x0
    b rt_service_build_guild_tag_status_suffix
rt_service_build_guild_tag_status_items:
    mov w22, wzr
    adrp x24, rt_tag_users
    add x24, x24, :lo12:rt_tag_users
    adrp x25, rt_tag_states
    add x25, x25, :lo12:rt_tag_states
rt_service_build_guild_tag_status_items_loop:
    cmp w22, w20
    b.hs rt_service_build_guild_tag_status_suffix
    add x0, x25, x22, lsl #2
    ldr w0, [x0]
    cbz w0, rt_service_build_guild_tag_status_items_next
    adrp x1, json_tag_status_item_prefix
    add x1, x1, :lo12:json_tag_status_item_prefix
    mov x0, x23
    bl rt_service_append_cstr
    mov x23, x0
    add x0, x24, x22, lsl #8
    mov x1, x0
    mov x0, x23
    bl rt_service_append_cstr
    mov x23, x0
    adrp x1, json_tag_status_item_suffix
    add x1, x1, :lo12:json_tag_status_item_suffix
    mov x0, x23
    bl rt_service_append_cstr
    mov x23, x0
rt_service_build_guild_tag_status_items_next:
    add w22, w22, #1
    b rt_service_build_guild_tag_status_items_loop
rt_service_build_guild_tag_status_suffix:
    adrp x1, json_tag_status_suffix
    add x1, x1, :lo12:json_tag_status_suffix
    mov x0, x23
    bl rt_service_append_cstr
    mov x23, x0
    strb wzr, [x23]
    sub x0, x23, x19
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret

rt_service_find_guild_tag_status_message:
    stp x29, x30, [sp, #-96]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x29, sp
    adrp x0, rt_service_url
    add x0, x0, :lo12:rt_service_url
    adrp x1, discord_api_prefix
    add x1, x1, :lo12:discord_api_prefix
    bl rt_service_append_cstr
    adrp x1, path_channel_messages
    add x1, x1, :lo12:path_channel_messages
    bl rt_service_append_cstr
    adrp x1, rt_discord_tag_status
    add x1, x1, :lo12:rt_discord_tag_status
    bl rt_service_append_cstr
    adrp x1, path_messages_history_suffix
    add x1, x1, :lo12:path_messages_history_suffix
    bl rt_service_append_cstr
    strb wzr, [x0]
    adrp x1, rt_service_url
    add x1, x1, :lo12:rt_service_url
    adrp x0, method_get
    add x0, x0, :lo12:method_get
    mov x2, xzr
    mov x3, xzr
    bl rt_service_rest_retry
    cbnz w0, rt_service_find_guild_tag_status_message_fail
    adrp x19, rt_service_response
    add x19, x19, :lo12:rt_service_response
    adrp x20, rt_service_response_length
    add x20, x20, :lo12:rt_service_response_length
    ldr x20, [x20]
    cbz x20, rt_service_find_guild_tag_status_message_fail
    mov x0, x19
    mov x1, x20
    bl native_json_validate_structure
    cbnz w0, rt_service_find_guild_tag_status_message_fail
    mov x21, xzr
rt_service_find_guild_tag_status_message_array:
    cmp x21, x20
    b.hs rt_service_find_guild_tag_status_message_fail
    ldrb w0, [x19, x21]
    cmp w0, #32
    b.eq rt_service_find_guild_tag_status_message_array_skip
    cmp w0, #9
    b.eq rt_service_find_guild_tag_status_message_array_skip
    cmp w0, #10
    b.eq rt_service_find_guild_tag_status_message_array_skip
    cmp w0, #13
    b.eq rt_service_find_guild_tag_status_message_array_skip
    cmp w0, #91
    b.eq rt_service_find_guild_tag_status_message_array_start
    b rt_service_find_guild_tag_status_message_fail
rt_service_find_guild_tag_status_message_array_skip:
    add x21, x21, #1
    b rt_service_find_guild_tag_status_message_array
rt_service_find_guild_tag_status_message_array_start:
    add x21, x21, #1
rt_service_find_guild_tag_status_message_next:
    cmp x21, x20
    b.hs rt_service_find_guild_tag_status_message_fail
    ldrb w0, [x19, x21]
    cmp w0, #32
    b.eq rt_service_find_guild_tag_status_message_next_skip
    cmp w0, #9
    b.eq rt_service_find_guild_tag_status_message_next_skip
    cmp w0, #10
    b.eq rt_service_find_guild_tag_status_message_next_skip
    cmp w0, #13
    b.eq rt_service_find_guild_tag_status_message_next_skip
    cmp w0, #44
    b.eq rt_service_find_guild_tag_status_message_next_skip
    cmp w0, #93
    b.eq rt_service_find_guild_tag_status_message_fail
    cmp w0, #123
    b.eq rt_service_find_guild_tag_status_message_object_start
    b rt_service_find_guild_tag_status_message_fail
rt_service_find_guild_tag_status_message_next_skip:
    add x21, x21, #1
    b rt_service_find_guild_tag_status_message_next
rt_service_find_guild_tag_status_message_object_start:
    mov x22, x21
    mov x23, #1
    mov x24, xzr
    mov x25, xzr
    add x21, x21, #1
rt_service_find_guild_tag_status_message_object_scan:
    cmp x21, x20
    b.hs rt_service_find_guild_tag_status_message_fail
    ldrb w0, [x19, x21]
    cbnz x24, rt_service_find_guild_tag_status_message_string
    cmp w0, #34
    b.eq rt_service_find_guild_tag_status_message_string_start
    cmp w0, #123
    b.eq rt_service_find_guild_tag_status_message_open
    cmp w0, #91
    b.eq rt_service_find_guild_tag_status_message_open
    cmp w0, #125
    b.eq rt_service_find_guild_tag_status_message_close_object
    cmp w0, #93
    b.eq rt_service_find_guild_tag_status_message_close_array
    add x21, x21, #1
    b rt_service_find_guild_tag_status_message_object_scan
rt_service_find_guild_tag_status_message_string_start:
    mov x24, #1
    mov x25, xzr
    add x21, x21, #1
    b rt_service_find_guild_tag_status_message_object_scan
rt_service_find_guild_tag_status_message_string:
    cbnz x25, rt_service_find_guild_tag_status_message_string_escaped
    cmp w0, #92
    b.eq rt_service_find_guild_tag_status_message_string_escape
    cmp w0, #34
    b.eq rt_service_find_guild_tag_status_message_string_close
    add x21, x21, #1
    b rt_service_find_guild_tag_status_message_object_scan
rt_service_find_guild_tag_status_message_string_escape:
    mov x25, #1
    add x21, x21, #1
    b rt_service_find_guild_tag_status_message_object_scan
rt_service_find_guild_tag_status_message_string_escaped:
    mov x25, xzr
    add x21, x21, #1
    b rt_service_find_guild_tag_status_message_object_scan
rt_service_find_guild_tag_status_message_string_close:
    mov x24, xzr
    add x21, x21, #1
    b rt_service_find_guild_tag_status_message_object_scan
rt_service_find_guild_tag_status_message_open:
    add x23, x23, #1
    add x21, x21, #1
    b rt_service_find_guild_tag_status_message_object_scan
rt_service_find_guild_tag_status_message_close_object:
    sub x23, x23, #1
    cbnz x23, rt_service_find_guild_tag_status_message_object_scan_continue
    add x21, x21, #1
    sub x26, x21, x22
    add x0, x19, x22
    mov x1, x26
    bl rt_service_copy_json
    cmn x0, #1
    b.eq rt_service_find_guild_tag_status_message_fail
    adrp x0, json_tag_status_nonce_key
    add x0, x0, :lo12:json_tag_status_nonce_key
    mov x1, #5
    adrp x2, rt_tag_status_nonce_candidate
    add x2, x2, :lo12:rt_tag_status_nonce_candidate
    mov x3, #64
    bl rt_json_value
    cbnz w0, rt_service_find_guild_tag_status_message_title
    adrp x0, rt_tag_status_nonce_candidate
    add x0, x0, :lo12:rt_tag_status_nonce_candidate
    adrp x1, rt_discord_tag_status
    add x1, x1, :lo12:rt_discord_tag_status
    adrp x2, rt_discord_tag_status_length
    add x2, x2, :lo12:rt_discord_tag_status_length
    ldr x2, [x2]
    bl rt_str_eq
    cbnz w0, rt_service_find_guild_tag_status_message_match
rt_service_find_guild_tag_status_message_title:
    adrp x2, json_tag_status_title_pattern
    add x2, x2, :lo12:json_tag_status_title_pattern
    mov x0, x2
    bl rt_cstr_length
    mov x3, x0
    adrp x0, rt_json_buffer
    add x0, x0, :lo12:rt_json_buffer
    adrp x1, rt_json_length
    add x1, x1, :lo12:rt_json_length
    ldr x1, [x1]
    adrp x2, json_tag_status_title_pattern
    add x2, x2, :lo12:json_tag_status_title_pattern
    bl native_json_find_pattern
    cbz x0, rt_service_find_guild_tag_status_message_object_scan_next
    adrp x2, json_tag_status_author_bot_pattern
    add x2, x2, :lo12:json_tag_status_author_bot_pattern
    mov x0, x2
    bl rt_cstr_length
    mov x3, x0
    adrp x0, rt_json_buffer
    add x0, x0, :lo12:rt_json_buffer
    adrp x1, rt_json_length
    add x1, x1, :lo12:rt_json_length
    ldr x1, [x1]
    adrp x2, json_tag_status_author_bot_pattern
    add x2, x2, :lo12:json_tag_status_author_bot_pattern
    bl native_json_find_pattern
    cbz x0, rt_service_find_guild_tag_status_message_object_scan_next
rt_service_find_guild_tag_status_message_match:
    adrp x0, json_message_id
    add x0, x0, :lo12:json_message_id
    mov x1, #2
    adrp x2, rt_tag_status_message
    add x2, x2, :lo12:rt_tag_status_message
    mov x3, #256
    bl rt_json_value
    cbnz w0, rt_service_find_guild_tag_status_message_object_scan_next
    adrp x0, rt_tag_status_message
    add x0, x0, :lo12:rt_tag_status_message
    bl rt_cstr_length
    cbz x0, rt_service_find_guild_tag_status_message_object_scan_next
    mov w0, wzr
    b rt_service_find_guild_tag_status_message_return
rt_service_find_guild_tag_status_message_object_scan_continue:
    add x21, x21, #1
    b rt_service_find_guild_tag_status_message_object_scan
rt_service_find_guild_tag_status_message_object_scan_next:
    b rt_service_find_guild_tag_status_message_next
rt_service_find_guild_tag_status_message_close_array:
    sub x23, x23, #1
    cbnz x23, rt_service_find_guild_tag_status_message_object_scan_continue
    b rt_service_find_guild_tag_status_message_fail
rt_service_find_guild_tag_status_message_fail:
    mov w0, #1
rt_service_find_guild_tag_status_message_return:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret

rt_service_send_guild_tag_status:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    adrp x0, rt_discord_tag_status_length
    add x0, x0, :lo12:rt_discord_tag_status_length
    ldr x0, [x0]
    cbz x0, rt_service_send_guild_tag_status_fail
    bl rt_service_build_guild_tag_status
    mov x19, x0
    adrp x0, rt_tag_status_message
    add x0, x0, :lo12:rt_tag_status_message
    bl rt_cstr_length
    cbz x0, rt_service_send_guild_tag_status_recover
rt_service_send_guild_tag_status_patch:
    adrp x0, rt_service_url
    add x0, x0, :lo12:rt_service_url
    adrp x1, discord_api_prefix
    add x1, x1, :lo12:discord_api_prefix
    bl rt_service_append_cstr
    adrp x1, path_channel_messages
    add x1, x1, :lo12:path_channel_messages
    bl rt_service_append_cstr
    adrp x1, rt_discord_tag_status
    add x1, x1, :lo12:rt_discord_tag_status
    bl rt_service_append_cstr
    adrp x1, path_messages_suffix
    add x1, x1, :lo12:path_messages_suffix
    bl rt_service_append_cstr
    adrp x1, path_interaction_middle
    add x1, x1, :lo12:path_interaction_middle
    bl rt_service_append_cstr
    adrp x1, rt_tag_status_message
    add x1, x1, :lo12:rt_tag_status_message
    bl rt_service_append_cstr
    strb wzr, [x0]
    mov x3, x19
    adrp x2, rt_service_body
    add x2, x2, :lo12:rt_service_body
    adrp x1, rt_service_url
    add x1, x1, :lo12:rt_service_url
    adrp x0, method_patch
    add x0, x0, :lo12:method_patch
    bl rt_service_rest_retry
    cbz w0, rt_service_send_guild_tag_status_persist
    adrp x0, rest_status
    add x0, x0, :lo12:rest_status
    ldr w0, [x0]
    cmp w0, #404
    b.ne rt_service_send_guild_tag_status_fail
    adrp x0, rt_tag_status_message
    add x0, x0, :lo12:rt_tag_status_message
    strb wzr, [x0]
rt_service_send_guild_tag_status_recover:
    bl rt_service_find_guild_tag_status_message
    cbz w0, rt_service_send_guild_tag_status_patch
rt_service_send_guild_tag_status_create:
    adrp x21, rt_discord_tag_status_length
    add x21, x21, :lo12:rt_discord_tag_status_length
    ldr x21, [x21]
    cmp x21, #25
    b.hi rt_service_send_guild_tag_status_create_plain
    adrp x0, rt_service_body
    add x0, x0, :lo12:rt_service_body
    add x0, x0, x19
    sub x0, x0, #1
    adrp x1, json_tag_status_nonce_prefix
    add x1, x1, :lo12:json_tag_status_nonce_prefix
    bl rt_service_append_cstr
    adrp x1, rt_discord_tag_status
    add x1, x1, :lo12:rt_discord_tag_status
    bl rt_service_append_cstr
    adrp x1, json_tag_status_nonce_suffix
    add x1, x1, :lo12:json_tag_status_nonce_suffix
    bl rt_service_append_cstr
    adrp x1, rt_service_body
    add x1, x1, :lo12:rt_service_body
    sub x19, x0, x1
rt_service_send_guild_tag_status_create_plain:
    adrp x0, rt_service_url
    add x0, x0, :lo12:rt_service_url
    adrp x1, discord_api_prefix
    add x1, x1, :lo12:discord_api_prefix
    bl rt_service_append_cstr
    adrp x1, path_channel_messages
    add x1, x1, :lo12:path_channel_messages
    bl rt_service_append_cstr
    adrp x1, rt_discord_tag_status
    add x1, x1, :lo12:rt_discord_tag_status
    bl rt_service_append_cstr
    adrp x1, path_messages_suffix
    add x1, x1, :lo12:path_messages_suffix
    bl rt_service_append_cstr
    strb wzr, [x0]
    mov x3, x19
    adrp x2, rt_service_body
    add x2, x2, :lo12:rt_service_body
    adrp x1, rt_service_url
    add x1, x1, :lo12:rt_service_url
    adrp x0, method_post
    add x0, x0, :lo12:method_post
    bl rt_service_rest_retry
    cbnz w0, rt_service_send_guild_tag_status_fail
    adrp x0, rt_service_response
    add x0, x0, :lo12:rt_service_response
    adrp x1, rt_service_response_length
    add x1, x1, :lo12:rt_service_response_length
    ldr x1, [x1]
    bl rt_service_copy_json
    cmn x0, #1
    b.eq rt_service_send_guild_tag_status_fail
    adrp x0, json_message_id
    add x0, x0, :lo12:json_message_id
    mov x1, #2
    adrp x2, rt_tag_status_message
    add x2, x2, :lo12:rt_tag_status_message
    mov x3, #256
    bl rt_json_value
    cbnz w0, rt_service_send_guild_tag_status_fail
rt_service_send_guild_tag_status_persist:
    adrp x0, json_tag_status_setting_message
    add x0, x0, :lo12:json_tag_status_setting_message
    adrp x1, rt_tag_status_message
    add x1, x1, :lo12:rt_tag_status_message
    mov x2, #256
    bl rt_setting_set
    adrp x0, json_tag_status_setting_channel
    add x0, x0, :lo12:json_tag_status_setting_channel
    adrp x1, rt_discord_tag_status
    add x1, x1, :lo12:rt_discord_tag_status
    mov x2, #128
    bl rt_setting_set
    bl rt_service_persist_tag_members
    mov w0, wzr
    b rt_service_send_guild_tag_status_return
rt_service_send_guild_tag_status_fail:
    mov w0, #1
rt_service_send_guild_tag_status_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_service_send_guild_tag_log:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_service_url
    add x0, x0, :lo12:rt_service_url
    adrp x1, discord_api_prefix
    add x1, x1, :lo12:discord_api_prefix
    bl rt_service_append_cstr
    adrp x1, path_channel_messages
    add x1, x1, :lo12:path_channel_messages
    bl rt_service_append_cstr
    adrp x1, rt_discord_tag_log
    add x1, x1, :lo12:rt_discord_tag_log
    bl rt_service_append_cstr
    adrp x1, path_messages_suffix
    add x1, x1, :lo12:path_messages_suffix
    bl rt_service_append_cstr
    strb wzr, [x0]
    adrp x0, rt_service_body
    add x0, x0, :lo12:rt_service_body
    adrp x1, json_tag_log_prefix
    add x1, x1, :lo12:json_tag_log_prefix
    bl rt_service_append_cstr
    adrp x1, rt_tag_current
    add x1, x1, :lo12:rt_tag_current
    ldr w1, [x1]
    cbz w1, rt_service_guild_tag_log_disabled
    adrp x1, json_tag_log_enabled_middle
    add x1, x1, :lo12:json_tag_log_enabled_middle
    bl rt_service_append_cstr
    b rt_service_guild_tag_log_user
rt_service_guild_tag_log_disabled:
    adrp x1, json_tag_log_disabled_middle
    add x1, x1, :lo12:json_tag_log_disabled_middle
    bl rt_service_append_cstr
rt_service_guild_tag_log_user:
    adrp x1, rt_tag_user
    add x1, x1, :lo12:rt_tag_user
    bl rt_service_append_json
    adrp x1, json_tag_log_description_middle
    add x1, x1, :lo12:json_tag_log_description_middle
    bl rt_service_append_cstr
    adrp x1, rt_tag_current
    add x1, x1, :lo12:rt_tag_current
    ldr w1, [x1]
    cbz w1, rt_service_guild_tag_log_color_disabled
    adrp x1, json_tag_log_enabled_color
    add x1, x1, :lo12:json_tag_log_enabled_color
    bl rt_service_append_cstr
    b rt_service_guild_tag_log_finish
rt_service_guild_tag_log_color_disabled:
    adrp x1, json_tag_log_disabled_color
    add x1, x1, :lo12:json_tag_log_disabled_color
    bl rt_service_append_cstr
rt_service_guild_tag_log_finish:
    adrp x1, json_tag_log_suffix
    add x1, x1, :lo12:json_tag_log_suffix
    bl rt_service_append_cstr
    strb wzr, [x0]
    adrp x1, rt_service_body
    add x1, x1, :lo12:rt_service_body
    sub x3, x0, x1
    adrp x1, rt_service_url
    add x1, x1, :lo12:rt_service_url
    adrp x0, method_post
    add x0, x0, :lo12:method_post
    adrp x2, rt_service_body
    add x2, x2, :lo12:rt_service_body
    bl rt_service_rest_retry
    ldp x29, x30, [sp], #16
    ret

rt_service_gateway_dispatch:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    mov x0, x19
    mov x1, x20
    bl native_json_validate_structure
    cbnz w0, rt_service_gateway_dispatch_invalid
    mov x0, x19
    mov x1, x20
    adrp x2, json_op_pattern
    add x2, x2, :lo12:json_op_pattern
    mov x3, #5
    bl native_json_find_root_number
    mov x23, x0
    cmp x23, #0
    b.eq rt_service_gateway_dispatch_event
    cmp x23, #1
    b.eq rt_service_gateway_dispatch_heartbeat
    cmp x23, #7
    b.eq rt_service_gateway_dispatch_reconnect
    cmp x23, #9
    b.eq rt_service_gateway_dispatch_invalid
    cmp x23, #11
    b.eq rt_service_gateway_dispatch_done
    b rt_service_gateway_dispatch_done
rt_service_gateway_dispatch_event:
    mov x23, xzr
    mov x0, x19
    mov x1, x20
    adrp x2, json_event_member_update
    add x2, x2, :lo12:json_event_member_update
    mov x3, #25
    bl native_json_find_root_pattern
    cbnz x0, rt_service_gateway_dispatch_member_update
    mov x0, x19
    mov x1, x20
    adrp x2, json_event_member_update_space
    add x2, x2, :lo12:json_event_member_update_space
    mov x3, #26
    bl native_json_find_root_pattern
    cbnz x0, rt_service_gateway_dispatch_member_update
    b rt_service_gateway_dispatch_interaction_check
rt_service_gateway_dispatch_member_update:
    mov x0, x19
    mov x1, x20
    bl rt_service_handle_guild_tag_update
    b rt_service_gateway_dispatch_event_sequence
rt_service_gateway_dispatch_interaction_check:
    mov x0, x19
    mov x1, x20
    adrp x2, json_event_interaction
    add x2, x2, :lo12:json_event_interaction
    mov x3, #24
    bl native_json_find_root_pattern
    cbnz x0, rt_service_gateway_dispatch_interaction_first
    mov x0, x19
    mov x1, x20
    adrp x2, json_event_interaction_space
    add x2, x2, :lo12:json_event_interaction_space
    mov x3, #25
    bl native_json_find_root_pattern
    cbnz x0, rt_service_gateway_dispatch_interaction_first
    b rt_service_gateway_dispatch_event_sequence
rt_service_gateway_dispatch_interaction_first:
    mov w23, #1
    mov x0, x19
    mov x1, x20
    bl rt_service_handle_interaction
rt_service_gateway_dispatch_event_sequence:
    mov x0, x19
    mov x1, x20
    adrp x2, json_sequence_pattern
    add x2, x2, :lo12:json_sequence_pattern
    mov x3, #4
    bl native_json_find_root_number
    cmp x0, #0
    b.lt rt_service_gateway_dispatch_event_sequence_missing
    adrp x1, ws_sequence
    add x1, x1, :lo12:ws_sequence
    str x0, [x1]
    adrp x1, ws_sequence_valid
    add x1, x1, :lo12:ws_sequence_valid
    mov w2, #1
    str w2, [x1]
    bl rt_service_save_gateway_state
    cbnz x23, rt_service_gateway_dispatch_done
rt_service_gateway_dispatch_event_sequence_missing:
    cbnz x23, rt_service_gateway_dispatch_done
    b rt_service_gateway_dispatch_ready
rt_service_gateway_dispatch_ready:
    mov x0, x19
    mov x1, x20
    bl rt_service_copy_json
    cmn x0, #1
    b.eq rt_service_gateway_dispatch_invalid
    mov x0, x19
    mov x1, x20
    adrp x2, json_event_resumed
    add x2, x2, :lo12:json_event_resumed
    mov x3, #13
    bl native_json_find_root_pattern
    cbnz x0, rt_service_gateway_dispatch_resumed
    mov x0, x19
    mov x1, x20
    adrp x2, json_event_resumed_space
    add x2, x2, :lo12:json_event_resumed_space
    mov x3, #14
    bl native_json_find_root_pattern
    cbnz x0, rt_service_gateway_dispatch_resumed
    mov x0, x19
    mov x1, x20
    adrp x2, json_ready_pattern
    add x2, x2, :lo12:json_ready_pattern
    mov x3, #11
    bl native_json_find_root_pattern
    cbz x0, rt_service_gateway_dispatch_interaction
    adrp x0, json_data_key
    add x0, x0, :lo12:json_data_key
    mov x1, #1
    bl rt_json_select_named_object
    cbnz w0, rt_service_gateway_dispatch_done
    adrp x0, rt_json_selector_found
    add x0, x0, :lo12:rt_json_selector_found
    ldr w0, [x0]
    cbz w0, rt_service_gateway_dispatch_done
    adrp x0, rt_service_session_id
    add x0, x0, :lo12:rt_service_session_id
    strb wzr, [x0]
    adrp x0, rt_service_resume_url
    add x0, x0, :lo12:rt_service_resume_url
    strb wzr, [x0]
    adrp x0, json_session_key
    add x0, x0, :lo12:json_session_key
    mov x1, #10
    adrp x2, rt_service_session_id
    add x2, x2, :lo12:rt_service_session_id
    mov x3, #256
    bl rt_json_value
    cbnz w0, rt_service_gateway_dispatch_done
    adrp x0, json_resume_key
    add x0, x0, :lo12:json_resume_key
    mov x1, #17
    adrp x2, rt_service_resume_url
    add x2, x2, :lo12:rt_service_resume_url
    mov x3, #1024
    bl rt_json_value
    cbnz w0, rt_service_gateway_dispatch_done
    bl rt_service_save_gateway_state
    bl rt_service_sync_guild_tag_status
    cbz w0, rt_service_gateway_dispatch_interaction
    bl rt_service_send_guild_tag_status
rt_service_gateway_dispatch_interaction:
    mov x0, x19
    mov x1, x20
    adrp x2, json_event_interaction
    add x2, x2, :lo12:json_event_interaction
    mov x3, #24
    bl native_json_find_root_pattern
    cbz x0, rt_service_gateway_dispatch_done
    mov x0, x19
    mov x1, x20
    bl rt_service_handle_interaction
    b rt_service_gateway_dispatch_done
rt_service_gateway_dispatch_heartbeat:
    bl rt_service_send_heartbeat
    b rt_service_gateway_dispatch_done
rt_service_gateway_dispatch_resumed:
    bl rt_service_sync_guild_tag_status
    cbz w0, rt_service_gateway_dispatch_done
    bl rt_service_send_guild_tag_status
    b rt_service_gateway_dispatch_done
rt_service_gateway_dispatch_reconnect:
    mov w0, #1
    b rt_service_gateway_dispatch_return
rt_service_gateway_dispatch_invalid:
    adrp x1, ws_sequence_valid
    add x1, x1, :lo12:ws_sequence_valid
    str wzr, [x1]
    adrp x1, rt_service_session_id
    add x1, x1, :lo12:rt_service_session_id
    strb wzr, [x1]
    adrp x1, rt_service_resume_url
    add x1, x1, :lo12:rt_service_resume_url
    strb wzr, [x1]
    bl rt_service_save_gateway_state
    mov w0, #1
    b rt_service_gateway_dispatch_return
rt_service_gateway_dispatch_done:
    mov w0, wzr
rt_service_gateway_dispatch_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_service_gateway_loop:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    bl rt_service_load_tag_status
    bl rt_service_load_gateway_state
    bl rt_service_sync_guild_tag_status
    cbz w0, rt_service_gateway_retry
    bl rt_service_send_guild_tag_status
rt_service_gateway_retry:
    adrp x0, rt_service_stop
    add x0, x0, :lo12:rt_service_stop
    ldr w0, [x0]
    cbnz w0, rt_service_gateway_done
    bl rt_service_gateway_open
    cbnz w0, rt_service_gateway_wait_retry
    adrp x1, rt_service_retry_delay
    add x1, x1, :lo12:rt_service_retry_delay
    mov x0, #5
    str x0, [x1]
rt_service_gateway_messages:
    adrp x0, rt_service_stop
    add x0, x0, :lo12:rt_service_stop
    ldr w0, [x0]
    cbnz w0, rt_service_gateway_close
    adrp x0, rt_service_gateway_handle
    add x0, x0, :lo12:rt_service_gateway_handle
    ldr x0, [x0]
    bl native_ws_recv_message
    cmp x0, #2
    b.eq rt_service_gateway_timeout
    cbz x0, rt_service_gateway_close
    mov x19, x0
    mov x20, x1
    mov x0, x19
    mov x1, x20
    bl rt_service_gateway_dispatch
    cbnz w0, rt_service_gateway_close
rt_service_gateway_timeout:
    bl rt_service_gateway_heartbeat_due
    cbnz w0, rt_service_gateway_close
    b rt_service_gateway_messages
rt_service_gateway_close:
    adrp x0, rt_service_gateway_handle
    add x0, x0, :lo12:rt_service_gateway_handle
    ldr x0, [x0]
    bl native_ws_close
    adrp x1, rt_service_gateway_handle
    add x1, x1, :lo12:rt_service_gateway_handle
    str xzr, [x1]
rt_service_gateway_wait_retry:
    adrp x0, rt_service_stop
    add x0, x0, :lo12:rt_service_stop
    ldr w0, [x0]
    cbnz w0, rt_service_gateway_done
    bl rt_service_backoff_sleep
    b rt_service_gateway_retry
rt_service_gateway_done:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_service_process_push_buffer:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    mov x20, x1
    adrp x0, rt_push_id_length
    add x0, x0, :lo12:rt_push_id_length
    str xzr, [x0]
    adrp x0, rt_package_length
    add x0, x0, :lo12:rt_package_length
    str xzr, [x0]
    adrp x0, rt_application_length
    add x0, x0, :lo12:rt_application_length
    str xzr, [x0]
    adrp x0, rt_title_length
    add x0, x0, :lo12:rt_title_length
    str xzr, [x0]
    adrp x0, rt_body_length
    add x0, x0, :lo12:rt_body_length
    str xzr, [x0]
    adrp x0, rt_parsed_name_length
    add x0, x0, :lo12:rt_parsed_name_length
    str xzr, [x0]
    adrp x0, rt_normalized_length
    add x0, x0, :lo12:rt_normalized_length
    str xzr, [x0]
    adrp x0, rt_amount_length
    add x0, x0, :lo12:rt_amount_length
    str xzr, [x0]
    adrp x0, rt_amount_value
    add x0, x0, :lo12:rt_amount_value
    str xzr, [x0]
    adrp x0, rt_push_mirror_kind
    add x0, x0, :lo12:rt_push_mirror_kind
    str xzr, [x0]
    mov x0, x19
    mov x1, x20
    bl rt_service_copy_json
    cmn x0, #1
    b.eq rt_service_push_parse_fail
    bl rt_parse_push_json
    cbnz w0, rt_service_push_parse_fail
    bl rt_check_filters
    cbnz w0, rt_service_push_unsupported
    bl rt_now
    adrp x1, rt_created_at
    add x1, x1, :lo12:rt_created_at
    str x0, [x1]
    adrp x1, rt_push_timestamp_present
    add x1, x1, :lo12:rt_push_timestamp_present
    ldr w1, [x1]
    cbnz w1, rt_service_push_event_time_ready
    adrp x1, rt_push_event_time
    add x1, x1, :lo12:rt_push_event_time
    str x0, [x1]
rt_service_push_event_time_ready:
    bl rt_db_open
    cbnz w0, rt_service_push_fail
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_begin
    add x1, x1, :lo12:sql_begin
    bl yul_sqlite_exec
    cbnz w0, rt_service_push_close_fail
    bl rt_check_duplicate
    cmp w0, #1
    b.eq rt_service_push_duplicate
    cmp w0, #2
    b.eq rt_service_push_rollback_fail
    bl rt_insert_push_received
    cbnz w0, rt_service_push_rollback_fail
    bl rt_credit
    cmp w0, #0
    b.eq rt_service_push_consumed
    cmp w0, #1
    b.eq rt_service_push_review
    b rt_service_push_rollback_fail
rt_service_push_review:
    adrp x0, rt_push_id
    add x0, x0, :lo12:rt_push_id
    adrp x1, status_review
    add x1, x1, :lo12:status_review
    bl rt_update_push_status
    cbnz w0, rt_service_push_rollback_fail
    bl rt_commit_close
    cbnz w0, rt_service_push_error
    adrp x0, status_review
    add x0, x0, :lo12:status_review
    adrp x1, rt_service_status
    add x1, x1, :lo12:rt_service_status
    bl rt_copy_cstr
    mov w0, #1
    b rt_service_push_return
rt_service_push_consumed:
    bl rt_db_close
    adrp x0, status_consumed
    add x0, x0, :lo12:status_consumed
    adrp x1, rt_service_status
    add x1, x1, :lo12:rt_service_status
    bl rt_copy_cstr
    mov w0, wzr
    b rt_service_push_return
rt_service_push_duplicate:
    bl rt_db_rollback_close
    adrp x0, status_duplicate
    add x0, x0, :lo12:status_duplicate
    adrp x1, rt_service_status
    add x1, x1, :lo12:rt_service_status
    bl rt_copy_cstr
    mov w0, #1
    b rt_service_push_return
rt_service_push_parse_fail:
    adrp x0, rt_push_id_length
    add x0, x0, :lo12:rt_push_id_length
    ldr x1, [x0]
    cbnz x1, rt_service_push_parse_fail_ready
    bl rt_fingerprint_push_id
rt_service_push_parse_fail_ready:
    adrp x0, status_parse_failed
    add x0, x0, :lo12:status_parse_failed
    adrp x1, rt_status_scratch
    add x1, x1, :lo12:rt_status_scratch
    bl rt_copy_cstr
    bl rt_record_nonpayment
    cmp w0, #2
    b.eq rt_service_push_nonpayment_duplicate
    cbnz w0, rt_service_push_error
    adrp x0, status_parse_failed
    add x0, x0, :lo12:status_parse_failed
    adrp x1, rt_service_status
    add x1, x1, :lo12:rt_service_status
    bl rt_copy_cstr
    mov w0, #1
    b rt_service_push_return
rt_service_push_unsupported:
    adrp x0, status_unsupported
    add x0, x0, :lo12:status_unsupported
    adrp x1, rt_status_scratch
    add x1, x1, :lo12:rt_status_scratch
    bl rt_copy_cstr
    bl rt_record_nonpayment
    cmp w0, #2
    b.eq rt_service_push_nonpayment_duplicate
    cbnz w0, rt_service_push_error
    adrp x0, status_unsupported
    add x0, x0, :lo12:status_unsupported
    adrp x1, rt_service_status
    add x1, x1, :lo12:rt_service_status
    bl rt_copy_cstr
    mov w0, #1
    b rt_service_push_return
rt_service_push_nonpayment_duplicate:
    adrp x0, status_duplicate
    add x0, x0, :lo12:status_duplicate
    adrp x1, rt_service_status
    add x1, x1, :lo12:rt_service_status
    bl rt_copy_cstr
    mov w0, #1
    b rt_service_push_return
rt_service_push_rollback_fail:
    bl rt_db_rollback_close
rt_service_push_close_fail:
    bl rt_db_close
rt_service_push_fail:
rt_service_push_error:
    mov w0, #2
rt_service_push_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_service_build_payment_content:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_service_message
    add x0, x0, :lo12:rt_service_message
    adrp x1, json_payment_content_prefix
    add x1, x1, :lo12:json_payment_content_prefix
    bl rt_service_append_cstr
    adrp x1, rt_amount_value
    add x1, x1, :lo12:rt_amount_value
    ldr x1, [x1]
    bl rt_service_append_u64
    adrp x1, json_payment_content_total
    add x1, x1, :lo12:json_payment_content_total
    bl rt_service_append_cstr
    adrp x1, rt_next_total
    add x1, x1, :lo12:rt_next_total
    ldr x1, [x1]
    bl rt_service_append_u64
    strb wzr, [x0]
    ldp x29, x30, [sp], #16
    ret

rt_service_payment_dm:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    bl rt_service_build_payment_content
    adrp x0, rt_credit_order_id
    add x0, x0, :lo12:rt_credit_order_id
    adrp x1, dm_nonce_payment_prefix
    add x1, x1, :lo12:dm_nonce_payment_prefix
    bl rt_service_build_dm_nonce
    cbnz w0, rt_service_payment_dm_failed
    adrp x0, rt_credit_discord_id
    add x0, x0, :lo12:rt_credit_discord_id
    adrp x1, rt_service_message
    add x1, x1, :lo12:rt_service_message
    bl rt_service_send_dm
    mov w19, w0
    cbnz w19, rt_service_payment_dm_failed
    mov x2, #1
    adrp x1, rt_credit_order_id
    add x1, x1, :lo12:rt_credit_order_id
    adrp x0, status_sent
    add x0, x0, :lo12:status_sent
    bl rt_update_dm_status
    b rt_service_payment_dm_return
rt_service_payment_dm_failed:
    mov x2, #1
    adrp x1, rt_credit_order_id
    add x1, x1, :lo12:rt_credit_order_id
    adrp x0, status_failed
    add x0, x0, :lo12:status_failed
    bl rt_update_dm_status
rt_service_payment_dm_return:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_service_retry_pending_dms:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x23, xzr
rt_service_retry_dm_loop:
    cmp x23, #100
    b.hs rt_service_retry_dm_return
    add x23, x23, #1
    bl rt_db_open
    cbnz w0, rt_service_retry_dm_return
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_pending_dm
    add x1, x1, :lo12:sql_pending_dm
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_service_retry_dm_close
    adrp x19, rt_statement
    add x19, x19, :lo12:rt_statement
    ldr x19, [x19]
    mov x0, x19
    bl yul_sqlite_step
    cmp w0, #100
    b.ne rt_service_retry_dm_done
    mov x0, x19
    mov x1, #0
    bl yul_sqlite_column_text
    adrp x1, rt_order_id
    add x1, x1, :lo12:rt_order_id
    mov x2, #128
    bl rt_copy_cstr_bounded
    cbnz w0, rt_service_retry_dm_done
    mov x0, x19
    mov x1, #1
    bl yul_sqlite_column_text
    adrp x1, rt_service_user
    add x1, x1, :lo12:rt_service_user
    mov x2, #256
    bl rt_copy_cstr_bounded
    cbnz w0, rt_service_retry_dm_done
    mov x0, x19
    mov x1, #2
    bl yul_sqlite_column_text
    adrp x1, rt_name
    add x1, x1, :lo12:rt_name
    mov x2, #512
    bl rt_copy_cstr_bounded
    cbnz w0, rt_service_retry_dm_done
    mov x0, x19
    mov x1, #3
    bl yul_sqlite_column_int64
    adrp x1, rt_amount_value
    add x1, x1, :lo12:rt_amount_value
    str x0, [x1]
    mov x0, x19
    mov x1, #4
    bl yul_sqlite_column_int64
    adrp x1, rt_expires_at
    add x1, x1, :lo12:rt_expires_at
    str x0, [x1]
    mov x0, x19
    bl yul_sqlite_finalize
    bl rt_db_close
    bl rt_service_build_order_content
    adrp x0, rt_order_id
    add x0, x0, :lo12:rt_order_id
    adrp x1, dm_nonce_order_prefix
    add x1, x1, :lo12:dm_nonce_order_prefix
    bl rt_service_build_dm_nonce
    cbnz w0, rt_service_retry_dm_failed
    adrp x0, rt_service_user
    add x0, x0, :lo12:rt_service_user
    adrp x1, rt_service_body
    add x1, x1, :lo12:rt_service_body
    bl rt_service_send_dm
    cbnz w0, rt_service_retry_dm_failed
    mov w24, wzr
    adrp x0, status_sent
    add x0, x0, :lo12:status_sent
    b rt_service_retry_dm_update
rt_service_retry_dm_failed:
    adrp x0, status_failed
    add x0, x0, :lo12:status_failed
    mov w24, #1
rt_service_retry_dm_update:
    adrp x1, rt_order_id
    add x1, x1, :lo12:rt_order_id
    mov x2, xzr
    bl rt_update_dm_status
    cbnz w0, rt_service_retry_dm_return
    cbnz w24, rt_service_retry_dm_return
    b rt_service_retry_dm_loop
rt_service_retry_dm_done:
    mov x0, x19
    bl yul_sqlite_finalize
rt_service_retry_dm_close:
    bl rt_db_close
rt_service_retry_dm_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_service_get_support_total:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x0
    mov x20, xzr
    bl rt_db_open
    cbnz w0, rt_service_get_total_store
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_get_total
    add x1, x1, :lo12:sql_get_total
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_service_get_total_close
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x0, [x1]
    mov x0, x19
    bl rt_cstr_length
    mov x3, x0
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    mov x1, #1
    mov x2, x19
    bl yul_sqlite_bind_text
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_step
    cmp w0, #100
    b.ne rt_service_get_total_finalize
    adrp x1, rt_statement
    add x1, x1, :lo12:rt_statement
    ldr x0, [x1]
    mov x1, xzr
    bl yul_sqlite_column_int64
    mov x20, x0
rt_service_get_total_finalize:
    adrp x0, rt_statement
    add x0, x0, :lo12:rt_statement
    ldr x0, [x0]
    bl yul_sqlite_finalize
rt_service_get_total_close:
    bl rt_db_close
rt_service_get_total_store:
    adrp x1, rt_next_total
    add x1, x1, :lo12:rt_next_total
    str x20, [x1]
    mov x0, x20
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_service_retry_pending_payment_dms:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    mov x23, xzr
rt_service_retry_payment_loop:
    cmp x23, #100
    b.hs rt_service_retry_payment_return
    add x23, x23, #1
    bl rt_db_open
    cbnz w0, rt_service_retry_payment_return
    adrp x0, rt_db_handle
    add x0, x0, :lo12:rt_db_handle
    ldr x0, [x0]
    adrp x1, sql_pending_payment_dm
    add x1, x1, :lo12:sql_pending_payment_dm
    adrp x2, rt_statement
    add x2, x2, :lo12:rt_statement
    bl yul_sqlite_prepare
    cbnz w0, rt_service_retry_payment_close
    adrp x19, rt_statement
    add x19, x19, :lo12:rt_statement
    ldr x19, [x19]
    mov x0, x19
    bl yul_sqlite_step
    cmp w0, #100
    b.ne rt_service_retry_payment_done
    mov x0, x19
    mov x1, #0
    bl yul_sqlite_column_text
    adrp x1, rt_credit_order_id
    add x1, x1, :lo12:rt_credit_order_id
    mov x2, #128
    bl rt_copy_cstr_bounded
    cbnz w0, rt_service_retry_payment_done
    mov x0, x19
    mov x1, #1
    bl yul_sqlite_column_text
    adrp x1, rt_credit_discord_id
    add x1, x1, :lo12:rt_credit_discord_id
    mov x2, #256
    bl rt_copy_cstr_bounded
    cbnz w0, rt_service_retry_payment_done
    mov x0, x19
    mov x1, #2
    bl yul_sqlite_column_int64
    adrp x1, rt_amount_value
    add x1, x1, :lo12:rt_amount_value
    str x0, [x1]
    mov x0, x19
    bl yul_sqlite_finalize
    bl rt_db_close
    adrp x0, rt_credit_discord_id
    add x0, x0, :lo12:rt_credit_discord_id
    bl rt_service_get_support_total
    bl rt_service_build_payment_content
    adrp x0, rt_credit_order_id
    add x0, x0, :lo12:rt_credit_order_id
    adrp x1, dm_nonce_payment_prefix
    add x1, x1, :lo12:dm_nonce_payment_prefix
    bl rt_service_build_dm_nonce
    cbnz w0, rt_service_retry_payment_failed
    adrp x0, rt_credit_discord_id
    add x0, x0, :lo12:rt_credit_discord_id
    adrp x1, rt_service_message
    add x1, x1, :lo12:rt_service_message
    bl rt_service_send_dm
    cbnz w0, rt_service_retry_payment_failed
    mov w24, wzr
    adrp x0, status_sent
    add x0, x0, :lo12:status_sent
    b rt_service_retry_payment_update
rt_service_retry_payment_failed:
    adrp x0, status_failed
    add x0, x0, :lo12:status_failed
    mov w24, #1
rt_service_retry_payment_update:
    adrp x1, rt_credit_order_id
    add x1, x1, :lo12:rt_credit_order_id
    mov x2, #1
    bl rt_update_dm_status
    cbnz w0, rt_service_retry_payment_return
    cbnz w24, rt_service_retry_payment_return
    b rt_service_retry_payment_loop
rt_service_retry_payment_done:
    mov x0, x19
    bl yul_sqlite_finalize
rt_service_retry_payment_close:
    bl rt_db_close
rt_service_retry_payment_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_service_load_push_cursor:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, setting_push_cursor
    add x0, x0, :lo12:setting_push_cursor
    adrp x1, rt_setting_output
    add x1, x1, :lo12:rt_setting_output
    mov x2, #4096
    bl rt_setting_get
    cbnz w0, rt_service_load_push_cursor_empty
    adrp x0, rt_setting_output
    add x0, x0, :lo12:rt_setting_output
    bl native_parse_decimal_scaled
    cmn x0, #1
    b.eq rt_service_load_push_cursor_empty
    adrp x1, ws_cursor
    add x1, x1, :lo12:ws_cursor
    str x0, [x1]
    ldp x29, x30, [sp], #16
    ret

rt_service_load_push_cursor_empty:
    adrp x1, ws_cursor
    add x1, x1, :lo12:ws_cursor
    str xzr, [x1]
    ldp x29, x30, [sp], #16
    ret

rt_service_load_panel_message:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, setting_panel_message
    add x0, x0, :lo12:setting_panel_message
    adrp x1, rt_panel_message_id
    add x1, x1, :lo12:rt_panel_message_id
    mov x2, #256
    bl rt_setting_get
    cbz w0, rt_service_load_panel_message_return
    adrp x0, rt_panel_message_id
    add x0, x0, :lo12:rt_panel_message_id
    strb wzr, [x0]
rt_service_load_panel_message_return:
    ldp x29, x30, [sp], #16
    ret

rt_service_save_push_cursor:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_setting_value
    add x0, x0, :lo12:rt_setting_value
    adrp x1, ws_cursor
    add x1, x1, :lo12:ws_cursor
    ldr x1, [x1]
    mov x2, #4096
    mov x3, x0
    mov x0, x1
    mov x1, x3
    bl native_scaled_u64_to_ascii
    adrp x0, setting_push_cursor
    add x0, x0, :lo12:setting_push_cursor
    adrp x1, rt_setting_value
    add x1, x1, :lo12:rt_setting_value
    bl rt_setting_set
    ldp x29, x30, [sp], #16
    ret

rt_service_process_poll_response:
    stp x29, x30, [sp, #-96]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x29, sp
    adrp x0, rt_service_cursor
    add x0, x0, :lo12:rt_service_cursor
    strb wzr, [x0]
    adrp x19, ws_json_buffer
    add x19, x19, :lo12:ws_json_buffer
    adrp x20, ws_json_length
    add x20, x20, :lo12:ws_json_length
    ldr x20, [x20]
    cbz x20, rt_service_process_poll_success
    mov x0, x19
    mov x1, x20
    bl native_json_validate_structure
    cbnz w0, rt_service_process_poll_error
    add x23, x19, x20
    mov x0, x19
    mov x1, x20
    adrp x2, json_pushes_key
    add x2, x2, :lo12:json_pushes_key
    mov x3, #8
    bl native_json_find_root_pattern
    cbz x0, rt_service_process_poll_success
    add x21, x0, #8
rt_service_process_poll_key_space:
    cmp x21, x23
    b.hs rt_service_process_poll_error
    ldrb w0, [x21]
    cmp w0, #32
    b.eq rt_service_process_poll_key_space_one
    cmp w0, #9
    b.eq rt_service_process_poll_key_space_one
    cmp w0, #10
    b.eq rt_service_process_poll_key_space_one
    cmp w0, #13
    b.eq rt_service_process_poll_key_space_one
    cmp w0, #58
    b.ne rt_service_process_poll_error
    add x21, x21, #1
rt_service_process_poll_value_space:
    cmp x21, x23
    b.hs rt_service_process_poll_error
    ldrb w0, [x21]
    cmp w0, #32
    b.eq rt_service_process_poll_value_space_one
    cmp w0, #9
    b.eq rt_service_process_poll_value_space_one
    cmp w0, #10
    b.eq rt_service_process_poll_value_space_one
    cmp w0, #13
    b.eq rt_service_process_poll_value_space_one
    cmp w0, #91
    b.ne rt_service_process_poll_error
    add x21, x21, #1
    b rt_service_process_poll_array_first
rt_service_process_poll_key_space_one:
    add x21, x21, #1
    b rt_service_process_poll_key_space
rt_service_process_poll_value_space_one:
    add x21, x21, #1
    b rt_service_process_poll_value_space
rt_service_process_poll_array_first:
    cmp x21, x23
    b.hs rt_service_process_poll_error
    ldrb w0, [x21]
    cmp w0, #32
    b.eq rt_service_process_poll_array_first_space
    cmp w0, #9
    b.eq rt_service_process_poll_array_first_space
    cmp w0, #10
    b.eq rt_service_process_poll_array_first_space
    cmp w0, #13
    b.eq rt_service_process_poll_array_first_space
    cmp w0, #93
    b.eq rt_service_process_poll_success
    cmp w0, #123
    b.ne rt_service_process_poll_error
    b rt_service_process_poll_object_start
rt_service_process_poll_array_first_space:
    add x21, x21, #1
    b rt_service_process_poll_array_first
rt_service_process_poll_object_start:
    mov x22, x21
    mov x24, #1
    mov x25, xzr
    mov x26, xzr
rt_service_process_poll_object:
    add x21, x21, #1
    cmp x21, x23
    b.hs rt_service_process_poll_error
    ldrb w0, [x21]
    cbnz x25, rt_service_process_poll_string
    cmp w0, #34
    b.eq rt_service_process_poll_string_start
    cmp w0, #123
    b.eq rt_service_process_poll_open
    cmp w0, #125
    b.eq rt_service_process_poll_close
    b rt_service_process_poll_object
rt_service_process_poll_string_start:
    mov x25, #1
    b rt_service_process_poll_object
rt_service_process_poll_string:
    cbnz x26, rt_service_process_poll_string_escaped
    cmp w0, #92
    b.eq rt_service_process_poll_string_escape
    cmp w0, #34
    b.ne rt_service_process_poll_object
    mov x25, xzr
    b rt_service_process_poll_object
rt_service_process_poll_string_escape:
    mov x26, #1
    b rt_service_process_poll_object
rt_service_process_poll_string_escaped:
    mov x26, xzr
    b rt_service_process_poll_object
rt_service_process_poll_open:
    add x24, x24, #1
    b rt_service_process_poll_object
rt_service_process_poll_close:
    sub x24, x24, #1
    cbnz x24, rt_service_process_poll_object
    add x1, x21, #1
    sub x1, x1, x22
    mov x27, x1
    mov x0, x22
    adrp x0, ws_poll_has_pushes
    add x0, x0, :lo12:ws_poll_has_pushes
    mov w1, #1
    str w1, [x0]
    mov x0, x22
    mov x1, x27
    bl rt_service_process_push_buffer
    mov w26, w0
    cmp w0, #2
    b.eq rt_service_process_poll_error
    mov x0, x22
    mov x1, x27
    bl rt_service_update_poll_candidate
    cmp w26, #0
    b.ne rt_service_process_poll_after_object
    bl rt_service_payment_dm
rt_service_process_poll_after_object:
    add x21, x22, x27
rt_service_process_poll_after_object_space:
    cmp x21, x23
    b.hs rt_service_process_poll_error
    ldrb w0, [x21]
    cmp w0, #32
    b.eq rt_service_process_poll_after_object_space_one
    cmp w0, #9
    b.eq rt_service_process_poll_after_object_space_one
    cmp w0, #10
    b.eq rt_service_process_poll_after_object_space_one
    cmp w0, #13
    b.eq rt_service_process_poll_after_object_space_one
    cmp w0, #44
    b.eq rt_service_process_poll_after_comma
    cmp w0, #93
    b.eq rt_service_process_poll_success
    b rt_service_process_poll_error
rt_service_process_poll_after_object_space_one:
    add x21, x21, #1
    b rt_service_process_poll_after_object_space
rt_service_process_poll_after_comma:
    add x21, x21, #1
rt_service_process_poll_after_comma_space:
    cmp x21, x23
    b.hs rt_service_process_poll_error
    ldrb w0, [x21]
    cmp w0, #32
    b.eq rt_service_process_poll_after_comma_space_one
    cmp w0, #9
    b.eq rt_service_process_poll_after_comma_space_one
    cmp w0, #10
    b.eq rt_service_process_poll_after_comma_space_one
    cmp w0, #13
    b.eq rt_service_process_poll_after_comma_space_one
    cmp w0, #123
    b.ne rt_service_process_poll_error
    b rt_service_process_poll_object_start
rt_service_process_poll_after_comma_space_one:
    add x21, x21, #1
    b rt_service_process_poll_after_comma_space
rt_service_process_poll_success:
    adrp x1, ws_json_length
    add x1, x1, :lo12:ws_json_length
    ldr x1, [x1]
    cbz x1, rt_service_process_poll_success_empty
    bl rt_service_extract_next_cursor
    cmn x0, #1
    b.eq rt_service_process_poll_error
rt_service_process_poll_success_empty:
    mov w0, wzr
    b rt_service_process_poll_return
rt_service_process_poll_error:
    mov w0, #1
rt_service_process_poll_return:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
rt_service_process_poll_done:
    b rt_service_process_poll_return

rt_service_extract_next_cursor:
    stp x29, x30, [sp, #-96]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x29, sp
    adrp x19, ws_json_buffer
    add x19, x19, :lo12:ws_json_buffer
    adrp x20, ws_json_length
    add x20, x20, :lo12:ws_json_length
    ldr x20, [x20]
    add x21, x19, x20
    adrp x0, json_cursor_key
    add x0, x0, :lo12:json_cursor_key
    mov x2, x0
    mov x0, x19
    mov x1, x20
    mov x3, #9
    bl native_json_find_root_pattern
    cbz x0, rt_service_extract_cursor_find_spaced
    add x0, x0, #9
    b rt_service_extract_cursor_found
rt_service_extract_cursor_find_spaced:
    mov x0, x19
    mov x1, x20
    adrp x2, json_cursor_key_space
    add x2, x2, :lo12:json_cursor_key_space
    mov x3, #10
    bl native_json_find_root_pattern
    cbz x0, rt_service_extract_cursor_empty
    add x0, x0, #10
rt_service_extract_cursor_found:
    mov x22, x0
rt_service_extract_cursor_space:
    cmp x22, x21
    b.hs rt_service_extract_cursor_fail
    ldrb w0, [x22]
    cmp w0, #32
    b.eq rt_service_extract_cursor_space_one
    cmp w0, #9
    b.eq rt_service_extract_cursor_space_one
    cmp w0, #10
    b.eq rt_service_extract_cursor_space_one
    cmp w0, #13
    b.eq rt_service_extract_cursor_space_one
    cmp w0, #34
    b.eq rt_service_extract_cursor_string
    cmp w0, #110
    b.eq rt_service_extract_cursor_null
    b rt_service_extract_cursor_fail
rt_service_extract_cursor_space_one:
    add x22, x22, #1
    b rt_service_extract_cursor_space
rt_service_extract_cursor_null:
    sub x26, x21, x22
    cmp x26, #4
    b.lo rt_service_extract_cursor_fail
    ldrb w0, [x22, #1]
    cmp w0, #117
    b.ne rt_service_extract_cursor_fail
    ldrb w0, [x22, #2]
    cmp w0, #108
    b.ne rt_service_extract_cursor_fail
    ldrb w0, [x22, #3]
    cmp w0, #108
    b.ne rt_service_extract_cursor_fail
    add x22, x22, #4
rt_service_extract_cursor_null_space:
    cmp x22, x21
    b.hs rt_service_extract_cursor_empty
    ldrb w0, [x22]
    cmp w0, #32
    b.eq rt_service_extract_cursor_null_space_one
    cmp w0, #9
    b.eq rt_service_extract_cursor_null_space_one
    cmp w0, #10
    b.eq rt_service_extract_cursor_null_space_one
    cmp w0, #13
    b.eq rt_service_extract_cursor_null_space_one
    cmp w0, #44
    b.eq rt_service_extract_cursor_empty
    cmp w0, #125
    b.eq rt_service_extract_cursor_empty
    cmp w0, #93
    b.eq rt_service_extract_cursor_empty
    b rt_service_extract_cursor_fail
rt_service_extract_cursor_null_space_one:
    add x22, x22, #1
    b rt_service_extract_cursor_null_space
rt_service_extract_cursor_string:
    add x22, x22, #1
    adrp x23, rt_service_cursor
    add x23, x23, :lo12:rt_service_cursor
    mov x24, xzr
    mov x25, #128
rt_service_extract_cursor_string_loop:
    cmp x22, x21
    b.hs rt_service_extract_cursor_fail
    ldrb w0, [x22]
    cmp w0, #34
    b.eq rt_service_extract_cursor_string_done
    cmp w0, #92
    b.ne rt_service_extract_cursor_string_plain
    add x22, x22, #1
    mov x0, x22
    mov x1, x21
    mov x2, x23
    mov x3, x24
    mov x4, x25
    bl rt_json_decode_escape
    cbnz w2, rt_service_extract_cursor_fail
    mov x22, x0
    mov x24, x1
    b rt_service_extract_cursor_string_loop
rt_service_extract_cursor_string_plain:
    add x26, x24, #1
    cmp x26, x25
    b.hs rt_service_extract_cursor_fail
    strb w0, [x23, x24]
    add x24, x24, #1
    add x22, x22, #1
    b rt_service_extract_cursor_string_loop
rt_service_extract_cursor_string_done:
    strb wzr, [x23, x24]
    mov x0, x24
    b rt_service_extract_cursor_return
rt_service_extract_cursor_empty:
    adrp x0, rt_service_cursor
    add x0, x0, :lo12:rt_service_cursor
    strb wzr, [x0]
    mov x0, xzr
    b rt_service_extract_cursor_return
rt_service_extract_cursor_fail:
    adrp x0, rt_service_cursor
    add x0, x0, :lo12:rt_service_cursor
    strb wzr, [x0]
    mov x0, #-1
rt_service_extract_cursor_return:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret

rt_service_store_seen_cursor:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    adrp x19, rt_service_cursor
    add x19, x19, :lo12:rt_service_cursor
    adrp x20, rt_service_poll_seen_count
    add x20, x20, :lo12:rt_service_poll_seen_count
    ldr x21, [x20]
    mov x22, xzr
rt_service_store_seen_cursor_check:
    cmp x22, x21
    b.hs rt_service_store_seen_cursor_new
    mov x0, x19
    adrp x1, rt_service_poll_seen_cursors
    add x1, x1, :lo12:rt_service_poll_seen_cursors
    mov x2, #257
    mul x3, x22, x2
    add x1, x1, x3
    bl rt_bytes_equal_cstring
    cbnz w0, rt_service_store_seen_cursor_error
    add x22, x22, #1
    b rt_service_store_seen_cursor_check
rt_service_store_seen_cursor_new:
    cmp x21, #100
    b.hs rt_service_store_seen_cursor_error
    adrp x1, rt_service_poll_seen_cursors
    add x1, x1, :lo12:rt_service_poll_seen_cursors
    mov x2, #257
    mul x3, x21, x2
    add x1, x1, x3
    mov x0, x19
    mov x2, #257
    bl rt_copy_cstr_bounded
    cbnz w0, rt_service_store_seen_cursor_error
    add x21, x21, #1
    str x21, [x20]
    mov w0, wzr
    b rt_service_store_seen_cursor_return
rt_service_store_seen_cursor_error:
    mov w0, #1
rt_service_store_seen_cursor_return:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_service_update_poll_candidate:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl rt_service_copy_json
    cmn x0, #1
    b.eq rt_service_update_poll_candidate_return
    bl rt_json_validate_structure
    cbnz w0, rt_service_update_poll_candidate_return
    adrp x0, rt_json_buffer
    add x0, x0, :lo12:rt_json_buffer
    adrp x1, rt_json_length
    add x1, x1, :lo12:rt_json_length
    ldr x1, [x1]
    adrp x2, json_modified_key
    add x2, x2, :lo12:json_modified_key
    mov x3, #11
    bl native_json_find_root_decimal_scaled
    cmn x0, #1
    b.eq rt_service_update_poll_candidate_return
    adrp x1, ws_cursor_candidate
    add x1, x1, :lo12:ws_cursor_candidate
    ldr x2, [x1]
    cmp x0, x2
    csel x0, x0, x2, hi
    str x0, [x1]
rt_service_update_poll_candidate_return:
    ldp x29, x30, [sp], #16
    ret

rt_service_poll_once:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x0, rt_service_cursor
    add x0, x0, :lo12:rt_service_cursor
    strb wzr, [x0]
    adrp x0, rt_service_poll_had_pushes
    add x0, x0, :lo12:rt_service_poll_had_pushes
    str wzr, [x0]
    adrp x0, rt_service_poll_page_count
    add x0, x0, :lo12:rt_service_poll_page_count
    str xzr, [x0]
    adrp x0, rt_service_poll_seen_count
    add x0, x0, :lo12:rt_service_poll_seen_count
    str xzr, [x0]
    adrp x0, ws_cursor_candidate
    add x0, x0, :lo12:ws_cursor_candidate
    adrp x1, ws_cursor
    add x1, x1, :lo12:ws_cursor
    ldr x1, [x1]
    str x1, [x0]
rt_service_poll_page:
    adrp x0, rt_pushbullet_token
    add x0, x0, :lo12:rt_pushbullet_token
    bl native_pushbullet_poll
    cbnz w0, rt_service_poll_return
    bl rt_service_process_poll_response
    cbnz w0, rt_service_poll_return
    adrp x0, ws_poll_has_pushes
    add x0, x0, :lo12:ws_poll_has_pushes
    ldr w0, [x0]
    cbz w0, rt_service_poll_page_ready
    adrp x0, rt_service_poll_had_pushes
    add x0, x0, :lo12:rt_service_poll_had_pushes
    mov w1, #1
    str w1, [x0]
rt_service_poll_page_ready:
    adrp x0, rt_service_cursor
    add x0, x0, :lo12:rt_service_cursor
    ldrb w0, [x0]
    cbz w0, rt_service_poll_finalize
    bl rt_service_store_seen_cursor
    cbnz w0, rt_service_poll_error
    adrp x0, rt_service_poll_page_count
    add x0, x0, :lo12:rt_service_poll_page_count
    ldr x1, [x0]
    add x1, x1, #1
    str x1, [x0]
    cmp x1, #100
    b.hs rt_service_poll_error
    b rt_service_poll_page
rt_service_poll_finalize:
    adrp x0, rt_service_poll_had_pushes
    add x0, x0, :lo12:rt_service_poll_had_pushes
    ldr w0, [x0]
    cbz w0, rt_service_poll_return
    adrp x0, ws_cursor_candidate
    add x0, x0, :lo12:ws_cursor_candidate
    ldr x0, [x0]
    adrp x1, ws_cursor
    add x1, x1, :lo12:ws_cursor
    ldr x2, [x1]
    cmp x0, x2
    csel x0, x0, x2, hi
    str x0, [x1]
    bl rt_service_save_push_cursor
    b rt_service_poll_return
rt_service_poll_error:
    mov w0, #1
rt_service_poll_return:
    ldp x29, x30, [sp], #16
    ret

rt_service_push_loop:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    mov x29, sp
    adrp x0, rt_pushbullet_token_length
    add x0, x0, :lo12:rt_pushbullet_token_length
    ldr x0, [x0]
    cbz x0, rt_service_push_wait_only
    bl rt_service_load_push_cursor
    bl rt_now
    adrp x1, rt_service_next_poll
    add x1, x1, :lo12:rt_service_next_poll
    add x0, x0, #30
    str x0, [x1]
rt_service_push_retry:
    adrp x0, rt_service_stop
    add x0, x0, :lo12:rt_service_stop
    ldr w0, [x0]
    cbnz w0, rt_service_push_done
    bl rt_service_gateway_child_check
    cbnz w0, rt_service_push_gateway_dead
    adrp x0, pushbullet_ws_host
    add x0, x0, :lo12:pushbullet_ws_host
    adrp x1, pushbullet_ws_path_prefix
    add x1, x1, :lo12:pushbullet_ws_path_prefix
    adrp x2, rt_pushbullet_token
    add x2, x2, :lo12:rt_pushbullet_token
    adrp x3, ws_http_path
    add x3, x3, :lo12:ws_http_path
    bl rt_service_build_push_path
    adrp x0, pushbullet_ws_host
    add x0, x0, :lo12:pushbullet_ws_host
    adrp x1, ws_http_path
    add x1, x1, :lo12:ws_http_path
    bl native_ws_build_upgrade
    adrp x0, ws_stream_url
    add x0, x0, :lo12:ws_stream_url
    adrp x1, pushbullet_stream_prefix
    add x1, x1, :lo12:pushbullet_stream_prefix
    bl rt_service_append_cstr
    adrp x1, rt_pushbullet_token
    add x1, x1, :lo12:rt_pushbullet_token
    bl rt_service_append_cstr
    strb wzr, [x0]
    adrp x0, ws_stream_url
    add x0, x0, :lo12:ws_stream_url
    bl native_ws_open_url
    cbz x0, rt_service_push_wait_retry
    mov x19, x0
    adrp x1, rt_service_retry_delay
    add x1, x1, :lo12:rt_service_retry_delay
    mov x0, #5
    str x0, [x1]
    adrp x1, rt_service_gateway_handle
    add x1, x1, :lo12:rt_service_gateway_handle
    str x19, [x1]
rt_service_push_messages:
    adrp x0, rt_service_stop
    add x0, x0, :lo12:rt_service_stop
    ldr w0, [x0]
    cbnz w0, rt_service_push_close
    bl rt_service_gateway_child_check
    cbnz w0, rt_service_push_gateway_dead
    mov x0, x19
    bl native_ws_recv_message
    cmp x0, #2
    b.eq rt_service_push_timeout
    cbz x0, rt_service_push_close
    mov x20, x0
    mov x21, x1
    mov x0, x20
    mov x1, x21
    bl native_json_validate_structure
    cbnz w0, rt_service_push_messages
    mov x0, x20
    mov x1, x21
    adrp x2, json_key_type_push
    add x2, x2, :lo12:json_key_type_push
    mov x3, #13
    bl native_json_find_root_pattern
    cbnz x0, rt_service_push_process_message
    mov x0, x20
    mov x1, x21
    adrp x2, json_key_type_push_space
    add x2, x2, :lo12:json_key_type_push_space
    mov x3, #14
    bl native_json_find_root_pattern
    cbnz x0, rt_service_push_process_message
    mov x0, x20
    mov x1, x21
    adrp x2, json_key_type_tickle
    add x2, x2, :lo12:json_key_type_tickle
    mov x3, #15
    bl native_json_find_root_pattern
    cbnz x0, rt_service_push_tickle
    mov x0, x20
    mov x1, x21
    adrp x2, json_key_type_tickle_space
    add x2, x2, :lo12:json_key_type_tickle_space
    mov x3, #16
    bl native_json_find_root_pattern
    cbz x0, rt_service_push_messages
rt_service_push_tickle:
    bl rt_service_poll_once
    cbnz w0, rt_service_push_close
    b rt_service_push_messages
rt_service_push_process_message:
    mov x0, x20
    mov x1, x21
    bl rt_service_process_push_buffer
    cbnz w0, rt_service_push_messages
    bl rt_service_payment_dm
    b rt_service_push_messages
rt_service_push_timeout:
    bl rt_now
    mov x20, x0
    adrp x1, rt_service_next_poll
    add x1, x1, :lo12:rt_service_next_poll
    ldr x1, [x1]
    cmp x20, x1
    b.lo rt_service_push_messages
    bl rt_service_poll_once
    cbnz w0, rt_service_push_close
    bl rt_now
    adrp x1, rt_service_next_poll
    add x1, x1, :lo12:rt_service_next_poll
    add x0, x0, #30
    str x0, [x1]
    b rt_service_push_messages
rt_service_push_close:
    mov x0, x19
    bl native_ws_close
rt_service_push_wait_retry:
    adrp x0, rt_service_stop
    add x0, x0, :lo12:rt_service_stop
    ldr w0, [x0]
    cbnz w0, rt_service_push_done
    bl rt_service_gateway_child_check
    cbnz w0, rt_service_push_gateway_dead
    bl rt_service_backoff_sleep
    b rt_service_push_retry
rt_service_push_wait_only:
    adrp x0, rt_service_stop
    add x0, x0, :lo12:rt_service_stop
    ldr w0, [x0]
    cbnz w0, rt_service_push_done
    bl rt_service_gateway_child_check
    cbnz w0, rt_service_push_gateway_dead
    bl rt_service_sleep_one
    b rt_service_push_wait_only
rt_service_push_gateway_dead:
    adrp x0, rt_service_stop
    add x0, x0, :lo12:rt_service_stop
    mov w1, #1
    str w1, [x0]
    b rt_service_push_done
rt_service_push_done:
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

rt_service_build_push_path:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    mov x19, x3
    mov x20, x2
    mov x0, x19
    mov x1, x1
    bl rt_service_append_cstr
    mov x1, x20
    bl rt_service_append_cstr
    strb wzr, [x0]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

rt_service_signal_handler:
    adrp x1, rt_service_stop
    add x1, x1, :lo12:rt_service_stop
    mov w2, #1
    str w2, [x1]
    ret

rt_service_gateway_child_check:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x1, rt_service_gateway_pid
    add x1, x1, :lo12:rt_service_gateway_pid
    ldr x0, [x1]
    cbz x0, rt_service_gateway_child_dead
    adrp x1, rt_service_gateway_wait_status
    add x1, x1, :lo12:rt_service_gateway_wait_status
    mov x2, #1
    bl waitpid
    cbz x0, rt_service_gateway_child_alive
    cmp x0, #0
    b.lt rt_service_gateway_child_wait_error
    adrp x1, rt_service_gateway_wait_status
    add x1, x1, :lo12:rt_service_gateway_wait_status
    ldr w0, [x1]
    bl rt_service_log_gateway_child_status
    b rt_service_gateway_child_dead
rt_service_gateway_child_wait_error:
    adrp x0, service_gateway_child_wait_error
    add x0, x0, :lo12:service_gateway_child_wait_error
    mov x1, xzr
    bl rt_log_cstr
rt_service_gateway_child_dead:
    adrp x1, rt_service_gateway_failed
    add x1, x1, :lo12:rt_service_gateway_failed
    mov w2, #1
    str w2, [x1]
    adrp x1, rt_service_gateway_pid
    add x1, x1, :lo12:rt_service_gateway_pid
    str xzr, [x1]
    mov w0, #1
    b rt_service_gateway_child_check_return
rt_service_gateway_child_alive:
    mov w0, wzr
rt_service_gateway_child_check_return:
    ldp x29, x30, [sp], #16
    ret

rt_service_run:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    mov x29, sp
    adrp x0, rt_service_stop
    add x0, x0, :lo12:rt_service_stop
    str wzr, [x0]
    mov x0, #15
    adrp x1, rt_service_signal_handler
    add x1, x1, :lo12:rt_service_signal_handler
    bl signal
    mov x0, #2
    adrp x1, rt_service_signal_handler
    add x1, x1, :lo12:rt_service_signal_handler
    bl signal
    bl rt_db_open
    cbnz w0, rt_service_run_fail_db
    bl rt_db_close
    bl rt_service_load_panel_message
    adrp x0, service_stage_network_start
    add x0, x0, :lo12:service_stage_network_start
    mov x1, xzr
    bl rt_log_cstr
    bl yul_native_network_start
    cbnz w0, rt_service_run_fail_rest
    adrp x0, service_stage_register_commands
    add x0, x0, :lo12:service_stage_register_commands
    mov x1, xzr
    bl rt_log_cstr
    bl rt_service_register_commands
    cbz w0, rt_service_run_register_commands_ready
    bl rt_service_log_rest_status
    b rt_service_run_fail_rest
rt_service_run_register_commands_ready:
    adrp x0, rt_discord_token_length
    add x0, x0, :lo12:rt_discord_token_length
    ldr x0, [x0]
    adrp x1, rt_pushbullet_token_length
    add x1, x1, :lo12:rt_pushbullet_token_length
    ldr x1, [x1]
    orr x2, x0, x1
    cbz x2, rt_service_run_fail_token
    cbz x0, rt_service_run_skip_dm_retry
    bl rt_service_retry_pending_dms
    bl rt_service_retry_pending_payment_dms
rt_service_run_skip_dm_retry:
    adrp x1, rt_service_retry_delay
    add x1, x1, :lo12:rt_service_retry_delay
    mov x0, #5
    str x0, [x1]
    adrp x1, rt_service_gateway_pid
    add x1, x1, :lo12:rt_service_gateway_pid
    str xzr, [x1]
    adrp x1, rt_service_gateway_failed
    add x1, x1, :lo12:rt_service_gateway_failed
    str wzr, [x1]
    bl fork
    cmp x0, #-1
    b.eq rt_service_run_fail_fork
    cbz x0, rt_service_run_child
    adrp x1, rt_service_gateway_pid
    add x1, x1, :lo12:rt_service_gateway_pid
    str x0, [x1]
    bl rt_service_push_loop
    adrp x0, rt_service_gateway_failed
    add x0, x0, :lo12:rt_service_gateway_failed
    ldr w0, [x0]
    cbnz w0, rt_service_run_gateway_failed
    adrp x1, rt_service_gateway_pid
    add x1, x1, :lo12:rt_service_gateway_pid
    ldr x1, [x1]
    cbz x1, rt_service_run_parent_done
    mov x19, x1
    mov x0, x19
    mov x1, #15
    bl kill
    mov x0, x19
    mov x1, xzr
    mov x2, xzr
    bl waitpid
rt_service_run_parent_done:
    mov w0, wzr
    b rt_service_run_return
rt_service_run_gateway_failed:
    adrp x1, rt_service_gateway_pid
    add x1, x1, :lo12:rt_service_gateway_pid
    ldr x1, [x1]
    cbz x1, rt_service_run_gateway_failed_stage
    mov x19, x1
    mov x0, x19
    mov x1, #15
    bl kill
    mov x0, x19
    mov x1, xzr
    mov x2, xzr
    bl waitpid
rt_service_run_gateway_failed_stage:
    adrp x0, service_stage_gateway_child
    add x0, x0, :lo12:service_stage_gateway_child
    mov x1, xzr
    bl rt_write_cstr
    b rt_service_run_fail
rt_service_run_child:
    mov x0, #1
    mov x1, #15
    bl prctl
    bl rt_service_gateway_loop
    mov x8, #93
    svc #0
    b rt_service_run_return
rt_service_run_fail_db:
    adrp x0, service_stage_db
    add x0, x0, :lo12:service_stage_db
    mov x1, xzr
    bl rt_write_cstr
    b rt_service_run_fail
rt_service_run_fail_rest:
    adrp x0, service_stage_rest
    add x0, x0, :lo12:service_stage_rest
    mov x1, xzr
    bl rt_write_cstr
    b rt_service_run_fail
rt_service_run_fail_token:
    adrp x0, service_stage_token
    add x0, x0, :lo12:service_stage_token
    mov x1, xzr
    bl rt_write_cstr
    b rt_service_run_fail
rt_service_run_fail_fork:
    adrp x0, service_stage_fork
    add x0, x0, :lo12:service_stage_fork
    mov x1, xzr
    bl rt_write_cstr
    b rt_service_run_fail
rt_service_run_fail:
    mov w0, #1
rt_service_run_return:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

.section .bss
.align 3
rt_argc: .skip 8
rt_argv: .skip 8
rt_command_index: .skip 8
rt_config_path: .skip 512
rt_config_error: .skip 4
rt_db_path: .skip 4096
rt_config_buffer: .skip 32768
rt_config_value: .skip 4096
rt_config_length: .skip 8
rt_endpoint_host: .skip 256
rt_endpoint_host_length: .skip 8
rt_read_probe: .skip 1
.align 3
rt_db_handle: .skip 8
rt_statement: .skip 8
rt_discord_id: .skip 256
rt_discord_id_length: .skip 8
rt_name: .skip 512
rt_name_length: .skip 8
rt_normalized: .skip 1024
rt_normalized_length: .skip 8
rt_push_mirror_kind: .skip 8
rt_push_root_type_present: .skip 8
rt_push_fingerprint_pending: .skip 8
rt_push_created_at: .skip 8
rt_push_modified_at: .skip 8
rt_push_event_time: .skip 8
rt_push_created_present: .skip 4
rt_push_modified_present: .skip 4
rt_push_timestamp_present: .skip 4
.align 3
rt_amount_text: .skip 64
rt_amount_length: .skip 8
rt_amount_value: .skip 8
rt_created_at: .skip 8
rt_expires_at: .skip 8
rt_order_ttl: .skip 8
rt_order_counter: .skip 8
rt_auto_credit: .skip 4
rt_case_insensitive_latin: .skip 4
rt_min_amount: .skip 8
rt_max_amount: .skip 8
rt_filter_package: .skip 256
rt_filter_package_length: .skip 8
rt_filter_application: .skip 256
rt_filter_application_length: .skip 8
rt_filter_title: .skip 1024
rt_filter_title_length: .skip 8
rt_filter_title_pattern: .skip 2048
rt_filter_title_pattern_length: .skip 8
rt_filter_amount: .skip 4096
rt_filter_amount_length: .skip 8
rt_filter_name: .skip 4096
rt_filter_name_length: .skip 8
rt_discord_token: .skip 2048
rt_discord_token_length: .skip 8
rt_pushbullet_token: .skip 2048
rt_pushbullet_token_length: .skip 8
rt_discord_application: .skip 128
rt_discord_application_length: .skip 8
rt_discord_guild: .skip 128
rt_discord_guild_length: .skip 8
rt_discord_panel: .skip 128
rt_discord_panel_length: .skip 8
rt_discord_tag_log: .skip 128
rt_discord_tag_log_length: .skip 8
rt_discord_tag_status: .skip 128
rt_discord_tag_status_length: .skip 8
rt_discord_tag_role: .skip 128
rt_discord_tag_role_length: .skip 8
rt_discord_admin: .skip 128
rt_discord_admin_length: .skip 8
rt_discord_intents: .skip 8
rt_push_stream: .skip 4096
rt_push_stream_length: .skip 8
rt_gateway_url: .skip 2048
rt_gateway_url_length: .skip 8
rt_bank_name: .skip 512
rt_bank_name_length: .skip 8
rt_bank_account: .skip 512
rt_bank_account_length: .skip 8
rt_bank_holder: .skip 512
rt_bank_holder_length: .skip 8
rt_support_id: .skip 256
rt_support_id_length: .skip 8
rt_order_id: .skip 128
rt_decimal: .skip 64
rt_decimal_tmp: .skip 64
rt_json_path: .skip 512
rt_json_buffer: .skip 65536
rt_json_length: .skip 8
rt_json_selector_found: .skip 8
rt_fingerprint_status: .skip 8
rt_json_structure_stack: .skip 256
rt_json_value_length: .skip 8
rt_push_id: .skip 256
rt_push_id_length: .skip 8
rt_fingerprint_scratch: .skip 1024
rt_package: .skip 256
rt_package_length: .skip 8
rt_application: .skip 256
rt_application_length: .skip 8
rt_title: .skip 1024
rt_title_length: .skip 8
rt_body: .skip 16384
rt_body_length: .skip 8
rt_parsed_name: .skip 512
rt_parsed_name_length: .skip 8
rt_status_scratch: .skip 64
rt_line: .skip 1024
rt_list_first: .skip 4
rt_credit_order_id: .skip 128
rt_credit_order_id_length: .skip 8
rt_credit_discord_id: .skip 256
rt_credit_discord_id_length: .skip 8
rt_current_total: .skip 8
rt_next_total: .skip 8
rt_timespec: .skip 16
rt_setting_key: .skip 256
rt_setting_value: .skip 4096
rt_setting_output: .skip 4096
rt_service_user: .skip 256
rt_service_name: .skip 512
rt_service_amount: .skip 64
rt_service_interaction_id: .skip 256
rt_service_interaction_token: .skip 512
rt_service_custom_id: .skip 256
rt_service_command_name: .skip 256
rt_service_channel: .skip 256
rt_service_response: .skip 65536
rt_service_response_length: .skip 8
rt_service_body: .skip 65536
rt_service_message: .skip 16384
rt_service_message_length: .skip 8
rt_service_message_overflow: .skip 4
rt_service_interaction_deferred: .skip 4
rt_service_dm_nonce: .skip 32
rt_order_dm_required: .skip 4
rt_panel_message_id: .skip 256
rt_service_argv: .skip 32
rt_service_url: .skip 8192
rt_service_status: .skip 64
rt_tag_user: .skip 256
rt_tag_users: .skip 32768
rt_tag_states: .skip 512
rt_tag_count: .skip 4
rt_tag_sync_after: .skip 256
rt_tag_sync_previous_after: .skip 256
rt_tag_sync_page_count: .skip 4
rt_tag_event_guild: .skip 128
rt_tag_identity_guild: .skip 128
rt_tag_current: .skip 4
rt_tag_status_message: .skip 256
rt_tag_status_nonce_candidate: .skip 64
rt_tag_status_members: .skip 4096
rt_tag_status_stored_channel: .skip 128
rt_service_mode: .skip 4
rt_service_stop: .skip 4
rt_service_gateway_pid: .skip 8
rt_service_gateway_wait_status: .skip 4
rt_service_gateway_failed: .skip 4
rt_service_gateway_handle: .skip 8
rt_service_last_heartbeat: .skip 8
rt_service_next_poll: .skip 8
rt_service_retry_delay: .skip 8
rt_service_session_id: .skip 256
rt_service_resume_url: .skip 1024
rt_service_cursor: .skip 128
rt_service_poll_had_pushes: .skip 4
rt_service_poll_page_count: .skip 8
rt_poll_source: .skip 65536
rt_service_poll_seen_count: .skip 8
rt_service_poll_seen_cursors: .skip 25700
