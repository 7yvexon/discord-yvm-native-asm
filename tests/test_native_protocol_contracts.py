import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LINUX_NETWORK = (ROOT / "src" / "native_network_linux_aarch64.S").read_text(encoding="utf-8")
LINUX_RUNTIME = (ROOT / "src" / "native_runtime_linux_aarch64.S").read_text(encoding="utf-8")
WINDOWS_NETWORK = (ROOT / "src" / "native_network_windows_x64.asm").read_text(encoding="utf-8")
WINDOWS_RUNTIME = (ROOT / "src" / "native_runtime_windows_x64.asm").read_text(encoding="utf-8")
WINDOWS_SERVICE = (ROOT / "src" / "native_service_windows_x64.asm").read_text(encoding="utf-8")
SERVICE_UNIT = (ROOT / "deploy" / "yul-vending-machine.service").read_text(encoding="utf-8")
DISCORD_BUTTON_FIXTURE = ROOT / "fixtures" / "discord" / "interaction-create-button.json"


class NativeProtocolContractTests(unittest.TestCase):
    def test_linux_receiver_accumulates_fragmented_messages_and_handles_ping(self):
        self.assertIn(".ws_raw_next_frame:", LINUX_NETWORK)
        self.assertIn("tbz w23, #7, .ws_raw_message_fragment", LINUX_NETWORK)
        self.assertIn(".ws_raw_text_frame:", LINUX_NETWORK)
        self.assertIn(".ws_raw_continuation_frame:", LINUX_NETWORK)
        self.assertIn(".ws_raw_control_frame:", LINUX_NETWORK)
        self.assertIn("tst w23, #0x70", LINUX_NETWORK)
        self.assertIn("tbz w23, #7, .ws_raw_failure", LINUX_NETWORK)
        self.assertIn("cmp w26, #126", LINUX_NETWORK)
        self.assertIn("b .ws_raw_payload_length", LINUX_NETWORK)
        self.assertIn("cmp w24, #10", LINUX_NETWORK)
        self.assertIn("cbnz w24, .ws_raw_failure", LINUX_NETWORK)
        self.assertIn(".ws_raw_ping:", LINUX_NETWORK)
        self.assertIn(".ws_raw_pong:", LINUX_NETWORK)
        self.assertIn("ws_fragment_active", LINUX_NETWORK)
        self.assertIn("native_ws_send_frame", LINUX_NETWORK)
        receiver_header = LINUX_NETWORK.split(".ws_raw_next_frame:", 1)[1].split(".ws_raw_payload_length:", 1)[0]
        self.assertNotIn("b.eq .ws_raw_ping", receiver_header)

    def test_linux_websocket_urls_are_normalized_for_libcurl(self):
        self.assertIn("native_ws_prepare_url:", LINUX_NETWORK)
        self.assertIn("https_url_prefix", LINUX_NETWORK)
        self.assertIn("ws_transport_url", LINUX_NETWORK)

    def test_native_websocket_url_selection_is_gated_by_wss_allowlists(self):
        parser = WINDOWS_NETWORK.split("native_parse_url:", 1)[1].split("native_parse_url_host:", 1)[0]
        self.assertIn("native_parse_url_wss:", parser)
        self.assertIn("add rsi, 5", parser)
        self.assertIn("add rsi, 6", parser)
        windows_open = WINDOWS_NETWORK.split("yul_native_network_ws_open:", 1)[1].split(
            "native_ws_select_gateway_default:", 1
        )[0]
        self.assertIn("runtime_validate_gateway_url", windows_open)
        self.assertIn("runtime_validate_push_url", windows_open)
        self.assertIn("runtime_validate_gateway_url:", WINDOWS_RUNTIME)
        self.assertIn("runtime_validate_push_url:", WINDOWS_RUNTIME)
        self.assertIn("rt_validate_gateway_url:", LINUX_RUNTIME)
        self.assertIn("rt_validate_push_url:", LINUX_RUNTIME)
        self.assertIn("bl rt_validate_gateway_url", LINUX_NETWORK)
        runtime_ws_validator = WINDOWS_RUNTIME.split("runtime_validate_ws_url:", 1)[1].split(
            "runtime_endpoint_parse_wss_host:", 1
        )[0]
        self.assertIn("cmp byte [rcx + 2], 's'", runtime_ws_validator)
        self.assertNotIn("cmp byte [rcx + 2], ':'", runtime_ws_validator)

    def test_linux_websocket_upgrade_validates_headers_and_accept(self):
        upgrade = LINUX_NETWORK.split("native_ws_http_upgrade:", 1)[1].split("native_ws_validate_accept:", 1)[0]
        self.assertIn("native_ws_validate_accept", upgrade)
        self.assertIn("http_status_101", upgrade)
        self.assertIn("http_connection_header", LINUX_NETWORK)
        self.assertIn("http_upgrade_header", LINUX_NETWORK)
        self.assertIn("http_accept_header_prefix", LINUX_NETWORK)
        self.assertIn("native_bytes_find_pattern_ci:", LINUX_NETWORK)
        self.assertIn("ws_accept_guid", LINUX_NETWORK)
        self.assertIn("native_ws_compute_accept:", LINUX_NETWORK)
        self.assertIn("movz w14, #0xc1d6", LINUX_NETWORK)
        self.assertNotIn("movz w14, #0x1d6c", LINUX_NETWORK)

    def test_linux_websocket_frame_buffer_covers_maximum_client_frame(self):
        self.assertIn("ws_frame_buffer: .skip 65544", LINUX_NETWORK)

    def test_linux_resume_url_is_used_for_upgrade_endpoint(self):
        gateway_open = LINUX_RUNTIME.split("rt_service_gateway_open:", 1)[1].split("rt_service_sleep_one:", 1)[0]
        self.assertIn("rt_service_resume_url", gateway_open)
        self.assertIn("native_ws_build_upgrade_url", gateway_open)
        self.assertIn("native_ws_open_url", gateway_open)

    def test_push_cursor_is_checkpointed_after_processing(self):
        poll = LINUX_RUNTIME.split("rt_service_poll_once:", 1)[1].split("rt_service_poll_return:", 1)[0]
        self.assertIn("ws_cursor_candidate", LINUX_NETWORK)
        self.assertIn("ws_poll_has_pushes", poll)
        self.assertIn("rt_service_process_poll_response", poll)
        self.assertIn("rt_service_save_push_cursor", poll)
        self.assertLess(poll.index("rt_service_process_poll_response"), poll.index("rt_service_save_push_cursor"))
        self.assertIn("cbnz w0, rt_service_poll_return", poll)

    def test_linux_push_poll_preserves_fractional_cursor_and_follows_pages(self):
        self.assertIn("native_parse_decimal_scaled", LINUX_NETWORK)
        self.assertIn("native_json_find_root_decimal_scaled", LINUX_NETWORK)
        decimal_finder = LINUX_NETWORK.split("native_json_find_decimal_scaled:", 1)[1].split("native_parse_decimal_scaled_span:", 1)[0]
        self.assertIn("add x0, x0, x22", decimal_finder)
        self.assertIn("native_scaled_u64_to_ascii", LINUX_NETWORK)
        self.assertIn("pushbullet_poll_cursor_prefix", LINUX_NETWORK)
        self.assertIn("pushbullet_poll_suffix", LINUX_NETWORK)
        self.assertIn("rt_service_poll_page_count", LINUX_RUNTIME)
        self.assertIn("cmp x1, #100", LINUX_RUNTIME)
        self.assertIn("rt_service_extract_next_cursor", LINUX_RUNTIME)

    def test_linux_push_poll_serializes_persisted_cursor_value(self):
        poll = LINUX_NETWORK.split("native_pushbullet_poll:", 1)[1].split(
            "native_ws_build_identify:", 1
        )[0]
        first_page = poll.split(".push_poll_page_cursor:", 1)[0]
        self.assertIn("adrp x1, ws_cursor", first_page)
        self.assertIn("add x1, x1, :lo12:ws_cursor", first_page)
        self.assertIn("ldr x0, [x1]", first_page)
        self.assertLess(first_page.index("ldr x0, [x1]"), first_page.index("bl native_scaled_u64_to_ascii"))

    def test_linux_push_poll_rejects_repeated_page_cursors(self):
        poll = LINUX_RUNTIME.split("rt_service_poll_once:", 1)[1].split("rt_service_poll_return:", 1)[0]
        helper = LINUX_RUNTIME.split("rt_service_store_seen_cursor:", 1)[1].split(
            "rt_service_update_poll_candidate:", 1
        )[0]
        self.assertIn("rt_service_store_seen_cursor", poll)
        self.assertIn("rt_service_poll_seen_count", poll)
        self.assertIn("rt_bytes_equal_cstring", helper)
        self.assertIn("rt_copy_cstr_bounded", helper)
        self.assertIn("rt_service_poll_seen_cursors: .skip 25700", LINUX_RUNTIME)

    def test_linux_root_pattern_accepts_colon_after_bare_key(self):
        boundary = LINUX_NETWORK.split(".json_root_pattern_boundary:", 1)[1].split(
            ".json_root_pattern_outside:", 1
        )[0]
        self.assertIn("cmp w1, #58\n    b.eq .json_root_pattern_yes", boundary)
        self.assertIn('json_pushes_key: .ascii "\\"pushes\\""', LINUX_RUNTIME)

    def test_linux_http_and_handshake_failures_are_bounded(self):
        upgrade = LINUX_NETWORK.split("native_ws_http_upgrade:", 1)[1].split("native_ws_validate_accept:", 1)[0]
        self.assertIn("mov x22, #2000", upgrade)
        self.assertIn("subs x22, x22, #1", upgrade)
        self.assertIn("rest_status", LINUX_NETWORK)
        poll = LINUX_RUNTIME.split("rt_service_poll_once:", 1)[1].split("rt_service_poll_return:", 1)[0]
        self.assertIn("cbnz w0, rt_service_poll_return", poll)
        self.assertIn("cbnz w0, rt_service_push_close", LINUX_RUNTIME)
        probe = LINUX_NETWORK.split("yul_native_network_probe:", 1)[1].split("yul_native_network_run:", 1)[0]
        self.assertIn("cmp w0, #200", probe)
        self.assertIn("cmp w0, #300", probe)

    def test_linux_websocket_io_no_progress_is_bounded_and_delayed(self):
        self.assertIn(".raw_send_no_progress:", LINUX_NETWORK)
        self.assertIn("cbz x3, .raw_send_no_progress", LINUX_NETWORK)
        self.assertIn(".raw_recv_no_progress:", LINUX_NETWORK)
        self.assertIn("cbz x3, .raw_recv_no_progress", LINUX_NETWORK)
        send = LINUX_NETWORK.split(".raw_send_no_progress:", 1)[1].split(".raw_send_progress:", 1)[0]
        recv = LINUX_NETWORK.split(".raw_recv_no_progress:", 1)[1].split(".raw_recv_progress:", 1)[0]
        self.assertIn("bl native_ws_sleep", send)
        self.assertIn("bl native_ws_sleep", recv)
        self.assertIn("cmp x23, #200", send)
        self.assertIn("cmp x23, #400", recv)

    def test_linux_json_escape_decoder_supports_unicode_and_surrogates(self):
        self.assertIn("rt_json_decode_escape:", LINUX_RUNTIME)
        self.assertIn("rt_json_decode_escape_unicode:", LINUX_RUNTIME)
        self.assertIn("rt_json_decode_escape_high_surrogate:", LINUX_RUNTIME)
        self.assertIn("rt_json_decode_escape_emit_four:", LINUX_RUNTIME)
        self.assertIn("bl rt_json_decode_escape", LINUX_RUNTIME)

    def test_windows_push_cursor_is_checkpointed_after_processing(self):
        poll = WINDOWS_SERVICE.split("service_poll_pushes:", 1)[1].split("service_poll_return:", 1)[0]
        self.assertIn("service_cursor_candidate", poll)
        self.assertIn("service_poll_has_pushes", poll)
        self.assertIn("call service_process_poll_response", poll)
        self.assertIn("call service_save_cursor", poll)
        self.assertLess(poll.index("call service_process_poll_response"), poll.index("call service_save_cursor"))
        self.assertIn("jnz service_poll_error", poll)

    def test_windows_push_poll_follows_and_validates_cursor_pages(self):
        poll = WINDOWS_SERVICE.split("service_poll_pushes:", 1)[1].split("service_poll_return:", 1)[0]
        response = WINDOWS_SERVICE.split("service_process_poll_response:", 1)[1].split(
            "service_process_poll_object:", 1
        )[0]
        poll_object = WINDOWS_SERVICE.split("service_process_poll_object:", 1)[1].split(
            "service_extract_poll_cursor:", 1
        )[0]
        root_finder = WINDOWS_SERVICE.split("service_find_root_after:", 1)[1].split(
            "service_find_after:", 1
        )[0]
        self.assertIn("service_poll_cursor_url", poll)
        self.assertIn("push_poll_cursor_prefix", poll)
        self.assertIn("service_poll_page_count", poll)
        self.assertIn("cmp dword [rel service_poll_page_count], 100", poll)
        self.assertIn("call service_store_seen_cursor", poll)
        self.assertIn("call service_extract_poll_cursor", response)
        self.assertIn("service_poll_page_push_count", poll_object)
        self.assertNotIn("cmp dword [rel service_poll_page_push_count], 50", response)
        self.assertIn("jne service_poll_response_return", response)
        self.assertIn("cmp al, ':'", root_finder)
        self.assertIn("service_poll_seen_cursors resb 25700", WINDOWS_SERVICE)

    def test_source_filters_and_json_parsers_are_structural(self):
        filter_block = LINUX_RUNTIME.split("rt_check_filters:", 1)[1].split("rt_mem_eq:", 1)[0]
        self.assertIn("rt_package_length", filter_block)
        self.assertIn("rt_application_length", filter_block)
        self.assertIn("runtime_check_source_filters:", WINDOWS_RUNTIME)
        self.assertIn("package_length", WINDOWS_RUNTIME.split("runtime_check_source_filters:", 1)[1].split("runtime_check_application:", 1)[0])
        self.assertIn("rt_json_validate_structure:", LINUX_RUNTIME)
        self.assertIn("rt_json_string_escape:", LINUX_RUNTIME)
        self.assertIn("runtime_json_validate_structure:", WINDOWS_RUNTIME)
        self.assertIn("runtime_json_string_escape", WINDOWS_RUNTIME)

    def test_windows_unsupported_missing_id_is_fingerprinted_before_recording(self):
        unsupported = WINDOWS_RUNTIME.split("runtime_process_push_unsupported:", 1)[1].split(
            "runtime_process_push_nonpayment_fail:", 1
        )[0]
        self.assertIn("cmp qword [rel push_id_length], 0", unsupported)
        self.assertIn("call runtime_make_push_fingerprint", unsupported)
        self.assertIn("mov [rel push_id_length], rax", unsupported)
        self.assertLess(
            unsupported.index("call runtime_make_push_fingerprint"),
            unsupported.index("call runtime_record_nonpayment"),
        )

    def test_native_fingerprint_scanners_cover_payload_fields_and_fail_closed(self):
        linux = LINUX_RUNTIME.split("rt_fingerprint_hash_payload:", 1)[1].split(
            "rt_fingerprint_is_lifecycle:", 1
        )[0]
        windows = WINDOWS_RUNTIME.split("runtime_fingerprint_hash_payload:", 1)[1].split(
            "runtime_fingerprint_is_lifecycle:", 1
        )[0]
        for scanner in (linux, windows):
            self.assertIn("payload_value_compound", scanner)
            self.assertIn("payload_value_in_string", scanner)
            self.assertIn("payload_key_escape", scanner)
            self.assertIn("payload_fail", scanner)
        self.assertIn("mov dil, [rsi + rcx]", windows)
        self.assertNotIn("mov al, [rsi + rcx]", windows)
        self.assertNotIn("mov al, [rsi + r10]", windows)
        self.assertNotIn("mov al, [rsi + r8]", windows)
        self.assertIn("fingerprint_key_active", LINUX_RUNTIME)
        self.assertIn("fingerprint_key_dismissed", LINUX_RUNTIME)
        self.assertIn("fingerprint_key_active", WINDOWS_RUNTIME)
        self.assertIn("fingerprint_key_dismissed", WINDOWS_RUNTIME)
        windows_format = WINDOWS_RUNTIME.split("runtime_make_push_fingerprint_format:", 1)[1].split(
            "runtime_make_push_fingerprint_invalid_prefix:", 1
        )[0]
        self.assertIn("cmp qword [rel push_mirror_kind], 1", windows_format)
        self.assertIn("jne runtime_make_push_fingerprint_invalid_prefix", windows_format)

    def test_linux_fingerprint_and_candidate_helpers_preserve_return_addresses(self):
        fingerprint = LINUX_RUNTIME.split("rt_fingerprint_hash_payload:", 1)[1].split(
            "rt_fingerprint_is_lifecycle:", 1
        )[0]
        self.assertIn("stp x29, x30, [sp, #-16]!", fingerprint)
        self.assertIn("ldp x29, x30, [sp], #16", fingerprint)
        lifecycle = LINUX_RUNTIME.split("rt_fingerprint_is_lifecycle:", 1)[1].split(
            "rt_fingerprint_hash_span:", 1
        )[0]
        self.assertIn("rt_fingerprint_lifecycle_compare_loop:", lifecycle)
        self.assertNotIn("bl rt_mem_eq", lifecycle)
        name_length = LINUX_RUNTIME.split("rt_name_label_length:", 1)[1].split(
            "rt_amount_label_length:", 1
        )[0]
        amount_length = LINUX_RUNTIME.split("rt_amount_label_length:", 1)[1].split(
            "rt_count_name_labels_text:", 1
        )[0]
        for helper in (name_length, amount_length):
            self.assertIn("stp x29, x30, [sp, #-16]!", helper)
            self.assertIn("ldp x29, x30, [sp], #16", helper)

    def test_linux_extraction_copy_buffers_are_bounded(self):
        name_copy = LINUX_RUNTIME.split("rt_extract_name_arrow_copy_loop:", 1)[1].split(
            "rt_extract_name_found:", 1
        )[0]
        amount_copy = LINUX_RUNTIME.split("rt_extract_amount_title_copy:", 1)[1].split(
            "rt_extract_amount_title_won:", 1
        )[0]
        self.assertIn("cmp x6, #512", name_copy)
        self.assertIn("b.hs rt_extract_name_fail", name_copy)
        self.assertIn("cmp x9, #64", amount_copy)
        self.assertIn("b.hs rt_extract_amount_title_fail", amount_copy)

    def test_linux_push_parser_fails_closed_on_type_and_blank_identity(self):
        parser = LINUX_RUNTIME.split("rt_parse_push_json:", 1)[1].split("rt_parse_push_json_fail:", 1)[0]
        envelope = parser.split("rt_parse_push_json_envelope:", 1)[1].split(
            "rt_parse_push_json_raw_mirror:", 1
        )[0]
        nested = parser.split("rt_parse_push_json_type_nested:", 1)[1].split(
            "rt_parse_push_json_type_ready:", 1
        )[0]
        identity = parser.split("rt_parse_push_json_type_ready:", 1)[1].split(
            "rt_parse_push_json_id_fields_ready:", 1
        )[0]
        service = LINUX_RUNTIME.split("rt_service_process_push_buffer:", 1)[1].split(
            "rt_service_build_payment_content:", 1
        )[0]
        service_setup = service.split("bl rt_service_copy_json", 1)[0]
        parse_failure = service.split("rt_service_push_parse_fail:", 1)[1].split(
            "rt_service_push_unsupported:", 1
        )[0]

        self.assertIn("adrp x2, json_push_value", envelope)
        self.assertIn("bl rt_mem_eq", envelope)
        self.assertIn("cbz w0, rt_parse_push_json_fail", envelope)
        self.assertIn("cbnz w0, rt_parse_push_json_fail", nested)
        self.assertNotIn("rt_parse_push_json_nested_legacy", parser)
        self.assertIn("rt_parse_push_json_id_blank_loop:", identity)
        self.assertIn("b.hs rt_parse_push_json_id_whitespace", identity)
        self.assertIn("b.eq rt_parse_push_json_id_invalid", identity)
        self.assertIn("bl rt_fingerprint_push_id", identity)
        self.assertIn("rt_push_mirror_kind", service_setup)
        self.assertIn("bl rt_fingerprint_push_id", parse_failure)
        self.assertLess(parse_failure.index("bl rt_fingerprint_push_id"), parse_failure.index("bl rt_record_nonpayment"))

    def test_native_pattern_contract_is_fail_closed(self):
        self.assertIn("rt_validate_pattern_contract:", LINUX_RUNTIME)
        self.assertIn("arrow_bank_name_pattern", LINUX_RUNTIME)
        self.assertIn("runtime_validate_pattern_contract:", WINDOWS_RUNTIME)
        self.assertIn("supported_amount_pattern_title", WINDOWS_RUNTIME)
        self.assertIn("supported_name_pattern_arrow", WINDOWS_RUNTIME)
        self.assertIn("title_amount_pattern_toss", LINUX_RUNTIME)

    def test_native_ambiguity_validation_is_called_before_first_match_extraction(self):
        linux_name = LINUX_RUNTIME.split("rt_extract_name:", 1)[1].split("rt_extract_name_arrow:", 1)[0]
        linux_amount = LINUX_RUNTIME.split("rt_extract_amount:", 1)[1].split("rt_extract_amount_title_only:", 1)[0]
        windows_name = WINDOWS_RUNTIME.split("runtime_extract_push_name:", 1)[1].split("runtime_extract_name_arrow:", 1)[0]
        windows_amount = WINDOWS_RUNTIME.split("runtime_extract_push_amount:", 1)[1].split("runtime_extract_amount_title:", 1)[0]
        self.assertIn("bl rt_validate_name_candidates", linux_name)
        self.assertIn("bl rt_validate_amount_candidates", linux_amount)
        self.assertIn("call runtime_validate_name_candidates", windows_name)
        self.assertIn("call runtime_validate_amount_candidates", windows_amount)
        linux_body = LINUX_RUNTIME.split("rt_find_body_sub:", 1)[1].split("rt_find_title_sub:", 1)[0]
        linux_title = LINUX_RUNTIME.split("rt_find_title_sub:", 1)[1].split("rt_check_title_pattern:", 1)[0]
        windows_finder = WINDOWS_RUNTIME.split("runtime_find_substring:", 1)[1].split("runtime_print_duplicate:", 1)[0]
        self.assertIn("cmp x5, x1", linux_body)
        self.assertIn("cmp x5, x1", linux_title)
        self.assertIn("cmp r9, r13", windows_finder)
        windows_name_validation = WINDOWS_RUNTIME.split("runtime_validate_name_candidates:", 1)[1].split(
            "runtime_validate_amount_candidates:", 1
        )[0]
        self.assertIn("call runtime_count_arrow_candidates", windows_name_validation)
        self.assertIn("cmp rax, 1", windows_name_validation)

    def test_native_fingerprint_key_hash_starts_after_opening_quote(self):
        windows_fingerprint = WINDOWS_RUNTIME.split("runtime_fingerprint_payload_key_checked:", 1)[1].split(
            "runtime_fingerprint_payload_after_key:", 1
        )[0]
        linux_fingerprint = LINUX_RUNTIME.split("rt_fingerprint_payload_key_done:", 1)[1].split(
            "rt_fingerprint_payload_after_key:", 1
        )[0]
        self.assertIn("mov r9, rdx", windows_fingerprint)
        self.assertIn("mov x27, x25", linux_fingerprint)
        self.assertIn("movk x24, #0x100, lsl #32", LINUX_RUNTIME)

    def test_native_special_pattern_validators_scan_body_and_title(self):
        linux_name_validator = LINUX_RUNTIME.split("rt_validate_name_candidates:", 1)[1].split(
            "rt_count_name_candidates:", 1
        )[0]
        linux_amount_validator = LINUX_RUNTIME.split("rt_validate_amount_candidates:", 1)[1].split(
            "rt_count_name_candidates:", 1
        )[0]
        windows_name_validator = WINDOWS_RUNTIME.split("runtime_validate_name_candidates:", 1)[1].split(
            "runtime_count_name_candidates:", 1
        )[0]
        windows_amount_validator = WINDOWS_RUNTIME.split("runtime_validate_amount_candidates:", 1)[1].split(
            "runtime_count_name_candidates:", 1
        )[0]
        self.assertIn("bl rt_count_arrow_candidates", linux_name_validator)
        self.assertIn("bl rt_count_title_amount_candidates", linux_amount_validator)
        self.assertIn("call runtime_count_arrow_candidates", windows_name_validator)
        self.assertIn("call runtime_count_title_amount_candidates", windows_amount_validator)
        for runtime, name_length, amount_length in (
            (LINUX_RUNTIME, "rt_count_arrow_candidates:", "rt_count_title_amount_candidates:"),
            (WINDOWS_RUNTIME, "runtime_count_arrow_candidates:", "runtime_count_title_amount_candidates:"),
        ):
            linux = runtime == LINUX_RUNTIME
            name_counter = runtime.split(name_length, 1)[1].split(
                "rt_count_name_labels_text:" if linux else "runtime_count_name_labels_text:", 1
            )[0]
            amount_counter = runtime.split(amount_length, 1)[1].split(
                "rt_count_title_amount_text:" if linux else "runtime_count_title_amount_text:", 1
            )[0]
            self.assertIn("body", name_counter)
            self.assertIn("title", name_counter)
            self.assertIn("body", amount_counter)
            self.assertIn("title", amount_counter)

    def test_native_nonpayment_duplicates_are_reported_as_idempotent(self):
        windows_parse = WINDOWS_RUNTIME.split("runtime_process_push_parse_fail:", 1)[1].split(
            "runtime_process_push_unsupported:", 1
        )[0]
        windows_unsupported = WINDOWS_RUNTIME.split("runtime_process_push_unsupported:", 1)[1].split(
            "runtime_process_push_nonpayment_fail:", 1
        )[0]
        linux_parse = LINUX_RUNTIME.split("rt_process_parse_fail:", 1)[1].split(
            "rt_process_unsupported:", 1
        )[0]
        linux_unsupported = LINUX_RUNTIME.split("rt_process_unsupported:", 1)[1].split(
            "rt_process_nonpayment_duplicate:", 1
        )[0]
        service_parse = LINUX_RUNTIME.split("rt_service_push_parse_fail:", 1)[1].split(
            "rt_service_push_unsupported:", 1
        )[0]
        service_unsupported = LINUX_RUNTIME.split("rt_service_push_unsupported:", 1)[1].split(
            "rt_service_push_nonpayment_duplicate:", 1
        )[0]
        self.assertIn("cmp eax, 2", windows_parse)
        self.assertIn("cmp eax, 2", windows_unsupported)
        self.assertIn("cmp w0, #2", linux_parse)
        self.assertIn("cmp w0, #2", linux_unsupported)
        self.assertIn("cmp w0, #2", service_parse)
        self.assertIn("cmp w0, #2", service_unsupported)
        nonpayment = LINUX_RUNTIME.split("rt_record_nonpayment:", 1)[1].split(
            "rt_print_push_result:", 1
        )[0]
        self.assertIn("rt_record_nonpayment_duplicate:", nonpayment)
        self.assertIn("mov w0, #2", nonpayment)

    def test_native_amount_and_sender_scanners_use_literal_lengths(self):
        windows_title = WINDOWS_RUNTIME.split("runtime_count_title_amount_text_digits:", 1)[1].split(
            "runtime_count_title_amount_text_digits_done:", 1
        )[0]
        linux_title = LINUX_RUNTIME.split("rt_count_title_amount_text_digits:", 1)[1].split(
            "rt_count_title_amount_text_digits_done:", 1
        )[0]
        self.assertLess(windows_title.index("cmp al, 44"), windows_title.index("cmp al, 48"))
        self.assertLess(linux_title.index("cmp w0, #44"), linux_title.index("cmp w0, #48"))
        self.assertIn("mov x1, #13", LINUX_RUNTIME.split("rt_extract_name:", 1)[1].split("rt_extract_name_arrow:", 1)[0])
        windows_name_length = WINDOWS_RUNTIME.split("runtime_name_label_length:", 1)[1].split(
            "runtime_amount_label_length:", 1
        )[0]
        self.assertIn("cmp qword [rsp + 8], 13", windows_name_length)
        self.assertIn("mov edx, 13", windows_name_length)
        self.assertIn(
            "label_sender: .byte 0xeb,0xb3,0xb4,0xeb,0x82,0xb8,0xeb,0xb6,0x84",
            LINUX_RUNTIME,
        )
        self.assertIn(
            "label_sender_space: .byte 0xeb,0xb3,0xb4,0xeb,0x82,0xb8,0x20,0xec,0x82,0xac,0xeb,0x9e,0x8c",
            LINUX_RUNTIME,
        )

    def test_native_json_finders_skip_strings_and_track_nested_structure(self):
        linux_finder = LINUX_NETWORK.split("native_json_find_pattern:", 1)[1].split("native_bytes_find_pattern:", 1)[0]
        self.assertIn(".json_pattern_string:", linux_finder)
        self.assertIn(".json_pattern_escape:", linux_finder)
        self.assertIn(".json_pattern_open:", linux_finder)
        self.assertIn(".json_pattern_close:", linux_finder)
        windows_finder = WINDOWS_SERVICE.split("service_find_after:", 1)[1].split("service_find_string:", 1)[0]
        self.assertIn("service_find_after_string:", windows_finder)
        self.assertIn("service_find_after_escape:", windows_finder)
        self.assertIn("service_find_after_open:", windows_finder)
        self.assertIn("service_find_after_close:", windows_finder)
        self.assertIn("mov r15, r14", windows_finder)
        self.assertIn("mov r13, 1", windows_finder)

    def test_windows_receiver_accumulates_fragmented_messages(self):
        self.assertIn("native_ws_recv_loop:", WINDOWS_NETWORK)
        self.assertIn("cmp eax, 1", WINDOWS_NETWORK)
        self.assertIn("cmp eax, 3", WINDOWS_NETWORK)
        self.assertIn("je native_ws_recv_loop", WINDOWS_NETWORK)

    def test_linux_reconnect_and_signal_paths_are_native(self):
        self.assertIn("rt_service_gateway_retry:", LINUX_RUNTIME)
        self.assertIn("rt_service_gateway_wait_retry:", LINUX_RUNTIME)
        self.assertIn("rt_service_push_retry:", LINUX_RUNTIME)
        self.assertIn("rt_service_signal_handler:", LINUX_RUNTIME)
        self.assertIn("mov x0, #15", LINUX_RUNTIME)
        self.assertIn("mov x0, #2", LINUX_RUNTIME)
        self.assertIn("bl kill", LINUX_RUNTIME)
        self.assertIn("bl waitpid", LINUX_RUNTIME)

    def test_linux_rest_retry_avoids_permanent_http_errors(self):
        retry = LINUX_RUNTIME.split("rt_service_rest_retry:", 1)[1].split("rt_service_rest_retry_return:", 1)[0]
        self.assertIn("cmp w0, #429", retry)
        self.assertIn("cmp w0, #500", retry)
        self.assertIn("cmp w0, #600", retry)
        self.assertIn("rt_service_rest_retry_wait", retry)
        self.assertIn("rt_service_retry_delay", retry)
        self.assertIn("rt_service_sleep_seconds", retry)

    def test_linux_rest_response_length_is_preserved_for_json_parsing(self):
        network_rest = LINUX_NETWORK.split("yul_native_network_rest_json:", 1)[1].split("native_copy_cstr_network:", 1)[0]
        self.assertIn("ldr x1, [x16]", network_rest.split(".rest_return:", 1)[1])
        rest_call = LINUX_RUNTIME.split("rt_service_rest_call:", 1)[1].split("rt_service_rest_retry:", 1)[0]
        self.assertIn("rt_service_response_length", rest_call)
        publish = LINUX_RUNTIME.split("rt_service_publish_panel:", 1)[1].split("rt_service_build_dm_nonce:", 1)[0]
        send_dm = LINUX_RUNTIME.split("rt_service_send_dm:", 1)[1].split("rt_service_send_interaction:", 1)[0]
        for block in (publish, send_dm):
            self.assertIn("rt_service_response_length", block)
            self.assertIn("bl rt_service_copy_json", block)

    def test_linux_channel_message_posts_target_messages_endpoint(self):
        publish = LINUX_RUNTIME.split("rt_service_publish_panel:", 1)[1].split("rt_service_build_dm_nonce:", 1)[0]
        send_dm = LINUX_RUNTIME.split("rt_service_send_dm:", 1)[1].split("rt_service_send_interaction:", 1)[0]
        for block in (publish, send_dm):
            suffix = block.split("adrp x1, path_messages_suffix", 1)[1].split("strb wzr, [x0]", 1)[0]
            self.assertIn("bl rt_service_append_cstr", suffix)

    def test_linux_guild_tag_state_compares_actual_user_id_length(self):
        handler = LINUX_RUNTIME.split("rt_service_handle_guild_tag_update:", 1)[1].split("rt_service_send_guild_tag_log:", 1)[0]
        self.assertIn("adrp x0, rt_json_value_length", handler)
        self.assertIn("ldr x21, [x0]", handler)
        find_loop = handler.split("rt_service_guild_tag_find_loop:", 1)[1].split("rt_service_guild_tag_new:", 1)[0]
        self.assertIn("mov x2, x21", find_loop)

    def test_linux_guild_tag_status_uses_one_persisted_message_and_target_guild_identity(self):
        self.assertIn('default_tag_status_channel: .asciz ""', LINUX_RUNTIME)
        self.assertIn('key_discord_tag_status: .ascii "DISCORD_GUILD_TAG_STATUS_CHANNEL_ID"', LINUX_RUNTIME)
        self.assertIn('json_tag_status_setting_message: .asciz "discord.guild_tag_status_message_id"', LINUX_RUNTIME)
        self.assertIn('json_tag_status_setting_members: .asciz "discord.guild_tag_status_members"', LINUX_RUNTIME)
        self.assertIn("rt_service_load_tag_status", LINUX_RUNTIME)
        self.assertIn("rt_service_send_guild_tag_status", LINUX_RUNTIME)
        self.assertIn("method_patch", LINUX_RUNTIME.split("rt_service_send_guild_tag_status:", 1)[1].split("rt_service_send_guild_tag_status_create:", 1)[0])
        self.assertIn("method_post", LINUX_RUNTIME.split("rt_service_send_guild_tag_status_create:", 1)[1].split("rt_service_send_guild_tag_status_persist:", 1)[0])
        handler = LINUX_RUNTIME.split("rt_service_handle_guild_tag_update:", 1)[1].split("rt_service_send_guild_tag_log:", 1)[0]
        self.assertIn("rt_service_guild_tag_identity_mismatch:", handler)
        self.assertIn("rt_service_guild_tag_no_primary:", handler)
        self.assertIn("adrp x0, json_message_id", handler)
        self.assertIn("mov w23, wzr", handler.split("rt_service_guild_tag_identity_mismatch:", 1)[1])

    def test_linux_guild_tag_status_only_creates_after_missing_message(self):
        send = LINUX_RUNTIME.split("rt_service_send_guild_tag_status:", 1)[1].split(
            "rt_service_send_guild_tag_status_create:", 1
        )[0]
        failure = send.split("bl rt_service_rest_retry", 1)[1]
        self.assertIn("adrp x0, rest_status", failure)
        self.assertIn("add x0, x0, :lo12:rest_status", failure)
        self.assertIn("ldr w0, [x0]", failure)
        self.assertIn("cmp w0, #404", failure)
        self.assertIn("b.ne rt_service_send_guild_tag_status_fail", failure)
        self.assertLess(failure.index("cmp w0, #404"), failure.index("b.ne rt_service_send_guild_tag_status_fail"))
        self.assertLess(
            failure.index("b.ne rt_service_send_guild_tag_status_fail"),
            failure.index("strb wzr, [x0]"),
        )

    def test_linux_push_service_status_copies_initialize_both_arguments(self):
        service_push = LINUX_RUNTIME.split("rt_service_process_push_buffer:", 1)[1].split(
            "rt_service_build_payment_content:", 1
        )[0]
        status_sources = {
            "rt_service_push_review": "status_review",
            "rt_service_push_consumed": "status_consumed",
            "rt_service_push_duplicate": "status_duplicate",
            "rt_service_push_parse_fail": "status_parse_failed",
            "rt_service_push_unsupported": "status_unsupported",
        }
        for label, source in status_sources.items():
            with self.subTest(label=label):
                branch = service_push.split(f"{label}:", 1)[1]
                if label == "rt_service_push_parse_fail":
                    branch = branch.split("rt_service_push_unsupported:", 1)[0]
                elif label == "rt_service_push_unsupported":
                    branch = branch.split("rt_service_push_rollback_fail:", 1)[0]
                elif label == "rt_service_push_review":
                    branch = branch.split("rt_service_push_consumed:", 1)[0]
                elif label == "rt_service_push_consumed":
                    branch = branch.split("rt_service_push_duplicate:", 1)[0]
                else:
                    branch = branch.split("rt_service_push_parse_fail:", 1)[0]
                expected = (
                    rf"adrp x0, {source}\s+"
                    rf"add x0, x0, :lo12:{source}\s+"
                    rf"adrp x1, rt_service_status\s+"
                    rf"add x1, x1, :lo12:rt_service_status\s+"
                    r"bl rt_copy_cstr"
                )
                self.assertRegex(branch, expected)

    def test_linux_guild_tag_status_recovers_existing_message_before_create(self):
        self.assertIn("path_messages_history_suffix: .asciz \"/messages?limit=100\"", LINUX_RUNTIME)
        self.assertIn("json_tag_status_nonce_prefix: .asciz", LINUX_RUNTIME)
        self.assertIn("json_tag_status_nonce_suffix: .asciz", LINUX_RUNTIME)
        self.assertIn("json_tag_status_title_pattern: .asciz", LINUX_RUNTIME)
        self.assertIn("json_tag_status_author_bot_pattern: .asciz", LINUX_RUNTIME)
        finder = LINUX_RUNTIME.split("rt_service_find_guild_tag_status_message:", 1)[1].split(
            "rt_service_send_guild_tag_status:", 1
        )[0]
        self.assertIn("method_get", finder)
        self.assertIn("path_messages_history_suffix", finder)
        self.assertIn("native_json_validate_structure", finder)
        self.assertIn("json_tag_status_nonce_key", finder)
        self.assertIn("rt_discord_tag_status_length", finder)
        self.assertIn("native_json_find_pattern", finder)
        self.assertIn("json_tag_status_author_bot_pattern", finder)
        send = LINUX_RUNTIME.split("rt_service_send_guild_tag_status:", 1)[1].split(
            "rt_service_send_guild_tag_log:", 1
        )[0]
        self.assertIn("cbz x0, rt_service_send_guild_tag_status_recover", send)
        self.assertIn("bl rt_service_find_guild_tag_status_message", send)
        create = send.split("rt_service_send_guild_tag_status_create:", 1)[1]
        self.assertIn("rt_discord_tag_status_length", create)
        self.assertIn("cmp x21, #25", create)
        self.assertIn("json_tag_status_nonce_prefix", create)
        self.assertIn("rt_discord_tag_status", create)
        self.assertIn("json_tag_status_nonce_suffix", create)
        self.assertIn("enforce_nonce", LINUX_RUNTIME)

    def test_linux_ready_reindexes_all_guild_members_before_status_update(self):
        self.assertIn('path_guild_members_suffix: .asciz "/members?limit=50"', LINUX_RUNTIME)
        self.assertIn('path_guild_members_after: .asciz "&after="', LINUX_RUNTIME)
        self.assertIn('method_get: .asciz "GET"', LINUX_RUNTIME)
        self.assertIn("rt_service_index_guild_tag_member:", LINUX_RUNTIME)
        self.assertIn("rt_service_sync_guild_tag_status:", LINUX_RUNTIME)
        url_builder = LINUX_RUNTIME.split("rt_service_build_guild_members_url:", 1)[1].split("rt_service_index_guild_tag_member:", 1)[0]
        self.assertIn("stp x29, x30, [sp, #-16]!", url_builder)
        self.assertIn("ldp x29, x30, [sp], #16", url_builder)
        self.assertIn("rt_tag_sync_after", LINUX_RUNTIME)
        self.assertIn("rt_tag_sync_previous_after", LINUX_RUNTIME)
        self.assertIn("rt_tag_sync_page_count", LINUX_RUNTIME)
        self.assertIn('json_event_resumed: .ascii "\\"t\\":\\"RESUMED\\""', LINUX_RUNTIME)
        sync = LINUX_RUNTIME.split("rt_service_sync_guild_tag_status:", 1)[1].split("rt_service_sync_guild_tag_status_return:", 1)[0]
        self.assertIn("bl native_json_validate_structure", sync)
        self.assertIn("bl rt_service_index_guild_tag_member", sync)
        self.assertIn("adrp x0, json_message_id", LINUX_RUNTIME.split("rt_service_index_guild_tag_member:", 1)[1].split("rt_service_index_guild_tag_member_return:", 1)[0])
        self.assertIn("bl rt_service_persist_tag_members", sync)
        ready = LINUX_RUNTIME.split("rt_service_gateway_dispatch_ready:", 1)[1].split("rt_service_gateway_dispatch_interaction:", 1)[0]
        self.assertIn("bl rt_service_sync_guild_tag_status", ready)
        self.assertIn("cbz w0, rt_service_gateway_dispatch_interaction", ready)
        resumed = LINUX_RUNTIME.split("rt_service_gateway_dispatch_resumed:", 1)[1].split("rt_service_gateway_dispatch_reconnect:", 1)[0]
        self.assertIn("bl rt_service_sync_guild_tag_status", resumed)
        dispatch = LINUX_RUNTIME.split("rt_service_gateway_dispatch:", 1)[1].split("rt_service_gateway_dispatch_event:", 1)[0]
        self.assertIn("cmp x23, #11", dispatch)
        self.assertIn("b.eq rt_service_gateway_dispatch_done", dispatch)
        gateway_loop = LINUX_RUNTIME.split("rt_service_gateway_loop:", 1)[1].split("rt_service_gateway_retry:", 1)[0]
        self.assertIn("bl rt_service_sync_guild_tag_status", gateway_loop)
        self.assertIn("cmp w26, #128", LINUX_RUNTIME)
        self.assertIn("cmp w21, #128", LINUX_RUNTIME)
        indexer = LINUX_RUNTIME.split("rt_service_index_guild_tag_member:", 1)[1].split("rt_service_index_guild_tag_member_return:", 1)[0]
        self.assertIn("adrp x22, rt_tag_users", indexer)
        self.assertIn("add x22, x22, :lo12:rt_tag_users", indexer)
        self.assertIn("adrp x22, rt_tag_states", indexer)
        self.assertIn("add x22, x22, :lo12:rt_tag_states", indexer)

    def test_linux_guild_tag_role_sync_uses_put_and_delete(self):
        self.assertIn('default_tag_role: .asciz ""', LINUX_RUNTIME)
        self.assertIn('key_discord_tag_role: .ascii "DISCORD_GUILD_TAG_ROLE_ID"', LINUX_RUNTIME)
        self.assertIn('method_delete: .asciz "DELETE"', LINUX_RUNTIME)
        role_sync = LINUX_RUNTIME.split("rt_service_sync_guild_tag_role:", 1)[1].split(
            "rt_service_handle_guild_tag_update:", 1
        )[0]
        self.assertIn("path_guild_member_roles_prefix", role_sync)
        self.assertIn("path_guild_member_roles_member", role_sync)
        self.assertIn("path_guild_member_roles_suffix", role_sync)
        self.assertIn("method_put", role_sync)
        self.assertIn("method_delete", role_sync)
        self.assertIn("bl rt_service_sync_guild_tag_role", LINUX_RUNTIME.split("rt_service_guild_tag_find_loop:", 1)[1])
        indexer = LINUX_RUNTIME.split("rt_service_index_guild_tag_member:", 1)[1].split(
            "rt_service_sync_guild_tag_status:", 1
        )[0]
        self.assertIn("rt_service_index_guild_tag_member_remove_role", indexer)

    def test_linux_dm_messages_are_nonce_protected_and_channel_payload_is_distinct(self):
        self.assertIn("json_dm_channel_prefix: .asciz \"{\\\"recipient_id\\\":\\\"\"", LINUX_RUNTIME)
        self.assertIn("json_dm_content_prefix: .asciz \"{\\\"embeds\\\":[{\\\"title\\\":\\\"테스트 자판기\\\",\\\"description\\\":\\\"\"", LINUX_RUNTIME)
        self.assertIn("json_dm_nonce_prefix: .asciz \"\\\",\\\"color\\\":5793266}],\\\"nonce\\\":\\\"\"", LINUX_RUNTIME)
        self.assertIn("json_dm_nonce_suffix: .asciz \"\\\",\\\"enforce_nonce\\\":true}\"", LINUX_RUNTIME)
        self.assertIn("rt_service_build_dm_nonce:", LINUX_RUNTIME)
        nonce_builder = LINUX_RUNTIME.split("rt_service_build_dm_nonce:", 1)[1].split("rt_service_send_dm:", 1)[0]
        self.assertIn("mov w0, wzr", nonce_builder)
        self.assertIn("dm_nonce_order_prefix", LINUX_RUNTIME)
        self.assertIn("dm_nonce_payment_prefix", LINUX_RUNTIME)
        send_dm = LINUX_RUNTIME.split("rt_service_send_dm:", 1)[1].split("rt_service_send_interaction:", 1)[0]
        self.assertIn("bl rt_service_rest_call", send_dm)
        self.assertIn("bl rt_service_rest_retry", send_dm)

    def test_linux_discord_messages_use_simple_embed_wrappers(self):
        panel = next(line.lstrip() for line in LINUX_RUNTIME.splitlines() if line.lstrip().startswith("json_panel_prefix"))
        self.assertIn(r'\"embeds\":[{\"title\":\"💳 입금 후원 안내\"', panel)
        self.assertIn(r'\"fields\":[', panel)
        self.assertIn(r'\"components\":[', panel)
        self.assertNotIn(r'\"content\":', panel)
        response_prefix = next(line.lstrip() for line in LINUX_RUNTIME.splitlines() if line.lstrip().startswith("json_response_prefix"))
        response_suffix = next(line.lstrip() for line in LINUX_RUNTIME.splitlines() if line.lstrip().startswith("json_response_suffix"))
        rest_prefix = next(line.lstrip() for line in LINUX_RUNTIME.splitlines() if line.lstrip().startswith("json_rest_content_prefix"))
        rest_suffix = next(line.lstrip() for line in LINUX_RUNTIME.splitlines() if line.lstrip().startswith("json_rest_content_suffix"))
        dm_prefix = next(line.lstrip() for line in LINUX_RUNTIME.splitlines() if line.lstrip().startswith("json_dm_content_prefix"))
        dm_nonce = next(line.lstrip() for line in LINUX_RUNTIME.splitlines() if line.lstrip().startswith("json_dm_nonce_prefix"))
        self.assertIn(r'\"embeds\":[{\"title\":\"테스트 자판기\",\"description\":\"', response_prefix)
        self.assertIn(r'\"color\":5793266}],\"flags\":64}}', response_suffix)
        self.assertIn(r'\"embeds\":[{\"title\":\"테스트 자판기\",\"description\":\"', rest_prefix)
        self.assertIn(r'\"color\":5793266}]}', rest_suffix)
        self.assertIn(r'\"embeds\":[{\"title\":\"테스트 자판기\",\"description\":\"', dm_prefix)
        self.assertIn(r'\"color\":5793266}],\"nonce\":\"', dm_nonce)
        for line in (response_prefix, rest_prefix, dm_prefix):
            self.assertNotIn(r'\"content\":', line)

    def test_windows_panel_payload_uses_embed_without_content(self):
        panel = next(line.lstrip() for line in WINDOWS_SERVICE.splitlines() if line.lstrip().startswith("panel_body"))
        self.assertIn('"embeds":[{"title":"💳 입금 후원 안내"', panel)
        self.assertIn('"components":[', panel)
        self.assertNotIn('"content":', panel)

    def test_linux_gateway_child_failure_is_reported_to_parent(self):
        self.assertIn("rt_service_gateway_child_check:", LINUX_RUNTIME)
        self.assertIn("rt_service_gateway_wait_status", LINUX_RUNTIME)
        self.assertIn("rt_service_gateway_failed", LINUX_RUNTIME)
        self.assertIn("rt_service_push_gateway_dead:", LINUX_RUNTIME)
        self.assertIn("service_stage_gateway_child", LINUX_RUNTIME)
        run = LINUX_RUNTIME.split("rt_service_run:", 1)[1].split(".section .bss", 1)[0]
        self.assertIn("cbnz w0, rt_service_run_gateway_failed", run)
        self.assertIn("rt_service_run_gateway_failed:", run)
        self.assertIn("bl waitpid", run)

    def test_linux_gateway_child_check_preserves_return_address(self):
        check = LINUX_RUNTIME.split("rt_service_gateway_child_check:", 1)[1].split("rt_service_run:", 1)[0]
        self.assertIn("stp x29, x30, [sp, #-16]!", check)
        self.assertIn("bl waitpid", check)
        self.assertIn("rt_service_log_gateway_child_status", check)
        self.assertIn("rt_service_gateway_child_wait_error", check)
        self.assertIn("ldp x29, x30, [sp], #16", check)
        self.assertIn("b rt_service_gateway_child_check_return", check)

    def test_linux_gateway_child_exit_status_is_classified_in_logs(self):
        self.assertIn("service_gateway_child_exited: .asciz", LINUX_RUNTIME)
        self.assertIn("service_gateway_child_signaled: .asciz", LINUX_RUNTIME)
        self.assertIn("service_gateway_child_wait_error: .asciz", LINUX_RUNTIME)
        logger = LINUX_RUNTIME.split("rt_service_log_gateway_child_status:", 1)[1].split("rt_read_file:", 1)[0]
        self.assertIn("and w20, w19, #0x7f", logger)
        self.assertIn("lsr w20, w19, #8", logger)
        self.assertIn("bl rt_u64_decimal", logger)
        self.assertIn("bl rt_log_cstr", logger)

    def test_linux_startup_rest_stages_are_logged(self):
        self.assertIn("service_stage_network_start: .asciz", LINUX_RUNTIME)
        self.assertIn("service_stage_register_commands: .asciz", LINUX_RUNTIME)
        self.assertIn("service_rest_failure: .asciz", LINUX_RUNTIME)
        self.assertIn("service_rest_failure_curl: .asciz", LINUX_RUNTIME)
        self.assertIn("rest_error_code", LINUX_RUNTIME)
        run = LINUX_RUNTIME.split("rt_service_run:", 1)[1].split("rt_service_run_fail_db:", 1)[0]
        self.assertIn("service_stage_network_start", run)
        self.assertIn("service_stage_register_commands", run)
        self.assertIn("rt_service_log_rest_status", run)

    def test_linux_rest_timeout_argument_is_not_clobbered_by_status_register(self):
        rest = LINUX_NETWORK.split("yul_native_network_rest_json:", 1)[1].split("ws_open_ok:", 1)[0]
        self.assertIn("mov x25, x7", rest)
        self.assertIn("mov x2, x25", rest)
        self.assertNotIn("mov x28, x7", rest)
        self.assertLess(rest.index("str x25, [x16]"), rest.index("mov x25, x7"))

    def test_linux_slow_interactions_defer_before_processing(self):
        self.assertIn('json_deferred_response: .asciz "{\\"type\\":5,\\"data\\":{\\"flags\\":64}}"', LINUX_RUNTIME)
        self.assertIn("rt_service_defer_interaction:", LINUX_RUNTIME)
        self.assertIn("rt_service_edit_original:", LINUX_RUNTIME)
        self.assertIn("path_webhook_prefix", LINUX_RUNTIME)
        self.assertIn("path_webhook_message", LINUX_RUNTIME)
        self.assertIn("method_patch", LINUX_RUNTIME)
        edit = LINUX_RUNTIME.split("rt_service_edit_original:", 1)[1].split("rt_service_build_ephemeral:", 1)[0]
        message_path = edit.split("adrp x1, path_webhook_message", 1)[1].split("strb wzr, [x0]", 1)[0]
        self.assertIn("bl rt_service_append_cstr", message_path)
        reply = LINUX_RUNTIME.split("rt_service_reply_content:", 1)[1].split("rt_service_reply_static:", 1)[0]
        self.assertIn("rt_service_interaction_deferred", reply)
        self.assertIn("rt_service_reply_deferred", reply)
        self.assertIn("bl rt_service_edit_original", reply)
        modal = LINUX_RUNTIME.split("rt_service_interaction_modal:", 1)[1].split("rt_service_interaction_button:", 1)[0]
        command = LINUX_RUNTIME.split("rt_service_interaction_command:", 1)[1].split("rt_service_interaction_support:", 1)[0]
        self.assertIn("bl rt_service_defer_interaction", modal)
        self.assertIn("bl rt_service_defer_interaction", command)

    def test_linux_interaction_callbacks_use_bounded_timeout_and_log_failures(self):
        send = LINUX_RUNTIME.split("rt_service_send_interaction:", 1)[1].split("rt_service_defer_interaction:", 1)[0]
        self.assertIn("bl rt_service_rest_call_fast", send)
        self.assertIn("bl rt_service_log_interaction_failure", send)
        self.assertIn("service_interaction_callback_failed", LINUX_RUNTIME)
        self.assertIn("rest_status", LINUX_RUNTIME.split("rt_service_log_interaction_failure:", 1)[1].split("rt_service_defer_interaction:", 1)[0])
        rest_call = LINUX_RUNTIME.split("rt_service_rest_call:", 1)[1].split("rt_service_rest_retry:", 1)[0]
        self.assertIn("mov x4, #20000", rest_call)
        self.assertIn("rt_service_rest_call_fast:", rest_call)
        self.assertIn("mov x4, #2000", rest_call)
        network_rest = LINUX_NETWORK.split("yul_native_network_rest_json:", 1)[1].split("native_copy_cstr_network:", 1)[0]
        self.assertIn("mov x25, x7", network_rest)
        self.assertIn("mov x2, x25", network_rest)
        self.assertIn("mov x2, #20000", network_rest)

    def test_linux_interaction_custom_id_accepts_json_spacing(self):
        self.assertIn('json_custom_pattern_space: .ascii "\\"custom_id\\": \\""', LINUX_RUNTIME)
        button = LINUX_RUNTIME.split("rt_service_interaction_button:", 1)[1].split("rt_service_interaction_modal:", 1)[0]
        modal = LINUX_RUNTIME.split("rt_service_interaction_modal:", 1)[1].split("rt_service_interaction_command:", 1)[0]
        for block, label in ((button, "rt_service_interaction_button_custom_ready"), (modal, "rt_service_interaction_modal_custom_ready")):
            self.assertIn("json_custom_pattern_space", block)
            self.assertIn(label, block)

    def test_discord_button_fixture_matches_native_interaction_contract(self):
        event = json.loads(DISCORD_BUTTON_FIXTURE.read_text(encoding="utf-8"))
        self.assertEqual(event["op"], 0)
        self.assertEqual(event["t"], "INTERACTION_CREATE")
        interaction = event["d"]
        self.assertEqual(interaction["type"], 3)
        self.assertEqual(interaction["application_id"], "123456789012345678")
        self.assertEqual(interaction["guild_id"], "223456789012345678")
        self.assertEqual(interaction["channel_id"], "323456789012345678")
        self.assertEqual(interaction["message"]["id"], "523456789012345678")
        self.assertEqual(interaction["data"]["custom_id"], "vending:deposit:v1")
        self.assertTrue(interaction["id"])
        self.assertTrue(interaction["token"])
        handler = LINUX_RUNTIME.split("rt_service_handle_interaction:", 1)[1].split("rt_service_interaction_button:", 1)[0]
        data_selector = LINUX_RUNTIME.split("rt_service_select_interaction_data:", 1)[1].split(
            "rt_service_select_interaction_data_fail:", 1
        )[0]
        self.assertIn("json_event_interaction", handler)
        self.assertIn("json_data_key", data_selector)
        self.assertIn("json_message_id", handler)
        self.assertIn("json_token_key", handler)
        self.assertIn("json_type_pattern", handler)

    def test_linux_interactions_are_acknowledged_before_gateway_state_persistence(self):
        self.assertIn('json_event_interaction_space: .ascii "\\"t\\": \\"INTERACTION_CREATE\\""', LINUX_RUNTIME)
        dispatch = LINUX_RUNTIME.split("rt_service_gateway_dispatch_event:", 1)[1].split("rt_service_gateway_dispatch_heartbeat:", 1)[0]
        self.assertIn("b rt_service_gateway_dispatch_event_sequence", dispatch)
        self.assertLess(
            dispatch.index("cbnz x0, rt_service_gateway_dispatch_interaction_first"),
            dispatch.index("bl rt_service_handle_interaction"),
        )
        self.assertLess(
            dispatch.index("bl rt_service_handle_interaction"),
            dispatch.index("bl rt_service_save_gateway_state"),
        )
        handler = LINUX_RUNTIME.split("rt_service_handle_interaction:", 1)[1].split("rt_service_interaction_button:", 1)[0]
        self.assertIn("json_event_interaction_space", handler)

    def test_linux_modal_interaction_scopes_data_and_extracts_ordered_values(self):
        modal = LINUX_RUNTIME.split("rt_service_interaction_modal:", 1)[1].split("rt_service_interaction_command:", 1)[0]
        self.assertIn("json_modal_data_key", modal)
        self.assertIn("bl rt_json_select_named_object", modal)
        self.assertIn("bl rt_json_extract_nth_pattern", modal)
        self.assertIn("mov x4, xzr", modal)
        self.assertIn("mov x4, #1", modal)
        self.assertIn("rt_json_extract_nth_pattern:", LINUX_RUNTIME)

    def test_linux_order_content_newlines_are_escaped_once_for_json(self):
        lines = [line for line in LINUX_RUNTIME.splitlines() if line.startswith("json_order_content_")]
        self.assertEqual(len(lines), 7)
        for line in lines:
            self.assertIn(r"\n", line)
            self.assertNotIn(r"\\n", line)

    def test_linux_other_json_content_newlines_are_escaped_once(self):
        panel = next(line.lstrip() for line in LINUX_RUNTIME.splitlines() if line.lstrip().startswith("json_panel_prefix"))
        self.assertIn(r"\\n", panel)
        payment_lines = [
            line
            for line in LINUX_RUNTIME.splitlines()
            if line.lstrip().startswith(("json_payment_content_", "json_support_content_prefix"))
        ]
        self.assertEqual(len(payment_lines), 3)
        for line in payment_lines:
            self.assertIn(r"\n", line)
            self.assertNotIn(r"\\n", line)

    def test_linux_dm_status_bind_uses_actual_status_length(self):
        update = LINUX_RUNTIME.split("rt_update_dm_status:", 1)[1].split("rt_update_dm_status_statement_fail:", 1)[0]
        status_bind = update.split("bl yul_sqlite_bind_text", 1)[0]
        self.assertIn("mov x0, x19", status_bind)
        self.assertIn("bl rt_cstr_length", status_bind)
        self.assertIn("mov x3, x0", status_bind)
        self.assertNotIn("mov x3, #6", status_bind)

    def test_linux_interaction_handler_validates_event_without_extracting_into_stale_buffers(self):
        handler = LINUX_RUNTIME.split("rt_service_handle_interaction:", 1)[1].split("rt_service_interaction_button:", 1)[0]
        self.assertIn("bl native_json_find_root_pattern", handler)
        preselect = handler.split("bl rt_json_select_named_object", 1)[0]
        self.assertIn("bl rt_service_extract_interaction_user", preselect)
        extractor = LINUX_RUNTIME.split("rt_service_extract_interaction_user:", 1)[1].split("rt_service_handle_interaction:", 1)[0]
        self.assertIn("json_member_key", extractor)
        self.assertIn("json_user_key", extractor)
        self.assertIn("bl rt_json_value", extractor)

    def test_native_interactions_require_exact_configured_scope_before_dispatch(self):
        linux_handler = LINUX_RUNTIME.split("rt_service_handle_interaction:", 1)[1].split(
            "rt_service_interaction_return:", 1
        )[0]
        self.assertIn("bl rt_service_validate_interaction_scope", linux_handler)
        self.assertLess(
            linux_handler.index("bl rt_service_validate_interaction_scope"),
            linux_handler.index("json_message_id"),
        )
        linux_scope = LINUX_RUNTIME.split("rt_service_validate_interaction_scope:", 1)[1].split(
            "rt_service_handle_interaction:", 1
        )[0]
        for key, configured in (
            ("json_key_application_id", "rt_discord_application"),
            ("json_key_guild_id", "rt_discord_guild"),
            ("json_key_channel_id", "rt_discord_panel"),
        ):
            self.assertIn(key, linux_scope)
            self.assertIn(configured, linux_scope)
        self.assertGreaterEqual(linux_scope.count("cbz x0, rt_service_validate_interaction_scope_fail"), 3)
        windows_handler = WINDOWS_SERVICE.split("service_handle_interaction:", 1)[1].split(
            "service_interaction_return:", 1
        )[0]
        self.assertIn("call service_validate_interaction_scope", windows_handler)
        self.assertLess(
            windows_handler.index("call service_validate_interaction_scope"),
            windows_handler.index("json_id_key"),
        )
        self.assertNotIn("call service_find_object", windows_handler)
        windows_scope = WINDOWS_SERVICE.split("service_validate_interaction_scope:", 1)[1].split(
            "service_prepare_order_args:", 1
        )[0]
        for key, configured in (
            ("json_application_id_key", "service_application"),
            ("json_guild_id_key", "service_guild"),
            ("json_channel_id_key", "service_panel"),
        ):
            self.assertIn(key, windows_scope)
            self.assertIn(configured, windows_scope)
        self.assertGreaterEqual(windows_scope.count("cmp qword [rel service_value_length], 0"), 3)

    def test_native_interaction_data_is_selected_only_after_full_scope_validation(self):
        linux_handler = LINUX_RUNTIME.split("rt_service_handle_interaction:", 1)[1].split(
            "rt_service_interaction_return:", 1
        )[0]
        self.assertLess(
            linux_handler.index("bl rt_service_validate_interaction_scope"),
            linux_handler.index("json_type_pattern"),
        )
        linux_button = LINUX_RUNTIME.split("rt_service_interaction_button:", 1)[1].split(
            "rt_service_interaction_modal:", 1
        )[0]
        self.assertLess(
            linux_button.index("bl rt_service_validate_button_message"),
            linux_button.index("bl rt_service_copy_json"),
        )
        self.assertLess(
            linux_button.index("bl rt_service_copy_json"),
            linux_button.index("bl rt_service_select_interaction_data"),
        )
        linux_modal = LINUX_RUNTIME.split("rt_service_interaction_modal:", 1)[1].split(
            "rt_service_interaction_command:", 1
        )[0]
        self.assertLess(
            linux_modal.index("bl rt_service_defer_interaction"),
            linux_modal.index("bl rt_service_select_interaction_data"),
        )
        self.assertLess(
            linux_modal.index("bl rt_service_select_interaction_data"),
            linux_modal.index("bl rt_json_select_named_object"),
        )
        linux_command = LINUX_RUNTIME.split("rt_service_interaction_command:", 1)[1].split(
            "rt_service_interaction_support:", 1
        )[0]
        self.assertLess(
            linux_command.index("bl rt_service_defer_interaction"),
            linux_command.index("bl rt_service_select_interaction_data"),
        )
        windows_handler = WINDOWS_SERVICE.split("service_handle_interaction:", 1)[1].split(
            "service_interaction_return:", 1
        )[0]
        self.assertLess(
            windows_handler.index("call service_validate_interaction_scope"),
            windows_handler.index("call service_find_root_string"),
        )
        self.assertNotIn("call service_find_object", windows_handler)
        windows_component = WINDOWS_SERVICE.split("service_interaction_component:", 1)[1].split(
            "service_interaction_modal:", 1
        )[0]
        self.assertLess(
            windows_component.index("call service_validate_button_message"),
            windows_component.index("call service_select_interaction_data"),
        )
        windows_modal = WINDOWS_SERVICE.split("service_interaction_modal:", 1)[1].split(
            "service_interaction_order_fail:", 1
        )[0]
        self.assertIn("call service_select_interaction_data", windows_modal)
        windows_command = WINDOWS_SERVICE.split("service_interaction_command:", 1)[1].split(
            "service_interaction_support:", 1
        )[0]
        self.assertIn("call service_select_interaction_data", windows_command)

    def test_native_modal_orders_are_persistently_idempotent(self):
        for runtime in (LINUX_RUNTIME, WINDOWS_RUNTIME):
            self.assertIn("interaction_id", runtime)
            self.assertIn("idx_deposit_orders_interaction_id", runtime)
            self.assertIn("sql_find_interaction_order", runtime)
            self.assertIn("ON CONFLICT(interaction_id) WHERE interaction_id IS NOT NULL DO NOTHING", runtime)
            self.assertIn("sql_native_migration_v3", runtime)
            self.assertIn("sql_native_verify_v3", runtime)
            self.assertIn("sql_native_index_v3", runtime)
            self.assertIn("sql_native_version_v3", runtime)
        linux_create = LINUX_RUNTIME.split("rt_create_order:", 1)[1].split("rt_make_order_id:", 1)[0]
        self.assertIn("bl yul_sqlite_bind_null", linux_create)
        self.assertIn("rt_service_interaction_id", linux_create)
        self.assertIn("bl rt_find_interaction_order", linux_create)
        windows_create = WINDOWS_RUNTIME.split("runtime_create_order:", 1)[1].split(
            "runtime_process_push_buffer:", 1
        )[0]
        self.assertIn("call yul_sqlite_bind_null", windows_create)
        self.assertIn("service_interaction_id", windows_create)
        self.assertIn("call runtime_find_interaction_order", windows_create)

    def test_native_modal_replay_validates_payload_and_skips_sent_dm(self):
        expected_query = (
            "SELECT order_id,discord_id,depositor_name_normalized,requested_amount_krw,dm_status "
            "FROM deposit_orders WHERE interaction_id=?1 LIMIT 1;"
        )
        self.assertIn(expected_query, LINUX_RUNTIME)
        self.assertIn(expected_query, WINDOWS_RUNTIME)
        linux_lookup = LINUX_RUNTIME.split("rt_find_interaction_order:", 1)[1].split(
            "rt_make_order_id:", 1
        )[0]
        for value in ("rt_discord_id", "rt_normalized", "rt_amount_value", "status_sent", "status_pending", "status_failed"):
            self.assertIn(value, linux_lookup)
        self.assertGreaterEqual(linux_lookup.count("rt_find_interaction_order_statement_fail"), 5)
        linux_modal = LINUX_RUNTIME.split("rt_service_interaction_modal:", 1)[1].split(
            "rt_service_interaction_command:", 1
        )[0]
        self.assertIn("rt_order_dm_required", linux_modal)
        self.assertLess(linux_modal.index("rt_order_dm_required"), linux_modal.index("bl rt_service_send_dm"))
        windows_lookup = WINDOWS_RUNTIME.split("runtime_find_interaction_order:", 1)[1].split(
            "runtime_process_push_buffer:", 1
        )[0]
        for value in (
            "discord_id_buffer",
            "normalized_buffer",
            "amount_value",
            "dm_status_sent",
            "dm_status_pending",
            "dm_status_failed",
        ):
            self.assertIn(value, windows_lookup)
        self.assertGreaterEqual(windows_lookup.count("runtime_find_interaction_order_statement_fail"), 5)
        windows_modal = WINDOWS_SERVICE.split("service_interaction_modal:", 1)[1].split(
            "service_interaction_order_fail:", 1
        )[0]
        self.assertIn("order_dm_required", windows_modal)
        self.assertLess(windows_modal.index("order_dm_required"), windows_modal.index("call service_send_dm"))

    def test_native_button_requires_persisted_panel_message(self):
        self.assertIn('setting_panel_message: .asciz "discord.panel_message_id"', LINUX_RUNTIME)
        linux_publish = LINUX_RUNTIME.split("rt_service_publish_panel:", 1)[1].split(
            "rt_service_publish_return:", 1
        )[0]
        self.assertIn("rt_panel_message_id", linux_publish)
        self.assertIn("bl rt_setting_set", linux_publish)
        linux_run = LINUX_RUNTIME.split("rt_service_run:", 1)[1].split("rt_service_run_fail_db:", 1)[0]
        self.assertIn("bl rt_service_load_panel_message", linux_run)
        linux_button = LINUX_RUNTIME.split("rt_service_interaction_button:", 1)[1].split(
            "rt_service_interaction_modal:", 1
        )[0]
        self.assertIn("bl rt_service_validate_button_message", linux_button)
        linux_button_scope = LINUX_RUNTIME.split("rt_service_validate_button_message:", 1)[1].split(
            "rt_service_validate_interaction_scope:", 1
        )[0]
        self.assertIn("json_message_key", linux_button_scope)
        self.assertIn("bl rt_json_select_named_object", linux_button_scope)
        self.assertIn("json_message_id", linux_button_scope)
        self.assertIn("rt_panel_message_id", linux_button_scope)
        linux_modal = LINUX_RUNTIME.split("rt_service_interaction_modal:", 1)[1].split(
            "rt_service_interaction_command:", 1
        )[0]
        self.assertNotIn("rt_service_validate_button_message", linux_modal)
        self.assertIn('setting_panel_message db "discord.panel_message_id", 0', WINDOWS_SERVICE)
        windows_publish = WINDOWS_SERVICE.split("service_publish_panel:", 1)[1].split(
            "service_publish_return:", 1
        )[0]
        self.assertIn("service_panel_message", windows_publish)
        self.assertIn("call service_save_setting", windows_publish)
        windows_run = WINDOWS_SERVICE.split("yul_native_service_run:", 1)[1].split(
            "service_idle_loop:", 1
        )[0]
        self.assertIn("call service_load_panel_message", windows_run)
        windows_button = WINDOWS_SERVICE.split("service_interaction_component:", 1)[1].split(
            "service_interaction_modal:", 1
        )[0]
        self.assertIn("call service_validate_button_message", windows_button)
        windows_button_scope = WINDOWS_SERVICE.split("service_validate_button_message:", 1)[1].split(
            "service_prepare_order_args:", 1
        )[0]
        self.assertIn("json_message_key", windows_button_scope)
        self.assertIn("call service_find_object", windows_button_scope)
        self.assertIn("json_id_key", windows_button_scope)
        self.assertIn("service_panel_message", windows_button_scope)
        windows_modal = WINDOWS_SERVICE.split("service_interaction_modal:", 1)[1].split(
            "service_interaction_command:", 1
        )[0]
        self.assertNotIn("service_validate_button_message", windows_modal)

    def test_linux_file_and_network_buffers_fail_closed_on_overflow(self):
        self.assertIn("rt_copy_cstr_bounded:", LINUX_RUNTIME)
        self.assertIn("rt_load_cli_done", LINUX_RUNTIME.split("rt_load_cli:", 1)[1].split("rt_find_command:", 1)[0])
        setting_get = LINUX_RUNTIME.split("rt_setting_get:", 1)[1].split("rt_setting_set:", 1)[0]
        self.assertIn("mov x21, x2", setting_get)
        self.assertIn("rt_copy_cstr_bounded", setting_get)
        self.assertIn("rt_read_file_overflow:", LINUX_RUNTIME)
        self.assertIn("rt_read_probe", LINUX_RUNTIME)
        self.assertIn("rt_service_copy_json_overflow:", LINUX_RUNTIME)
        self.assertIn("b.hi rt_service_copy_json_overflow", LINUX_RUNTIME)
        self.assertIn("rt_write_capture_overflow:", LINUX_RUNTIME)
        self.assertIn("b.hi rt_write_capture_overflow", LINUX_RUNTIME)
        self.assertIn("capture_overflow", LINUX_NETWORK)
        capture = LINUX_NETWORK.split("native_curl_capture:", 1)[1].split(".section .bss", 1)[0]
        self.assertIn("b.hi .capture_overflow", capture)
        self.assertIn("mov x0, xzr", capture)

    def test_windows_reconnect_and_console_signal_paths_are_native(self):
        self.assertIn("service_gateway_reconnect:", WINDOWS_SERVICE)
        self.assertIn("service_push_reconnect:", WINDOWS_SERVICE)
        self.assertIn("service_console_handler:", WINDOWS_SERVICE)
        self.assertIn("yul_native_network_ws_close", WINDOWS_SERVICE)

    def test_windows_gateway_ignores_heartbeat_ack_and_unsupported_dispatches(self):
        dispatch = WINDOWS_SERVICE.split("service_gateway_dispatch:", 1)[1].split(
            "service_gateway_hello:", 1
        )[0]
        self.assertIn("cmp eax, 11", dispatch)
        self.assertIn("je service_gateway_dispatch_ok", dispatch)
        self.assertIn("cmp eax, 0", dispatch)
        self.assertIn("jnz service_gateway_dispatch_invalid", dispatch)
        event = dispatch.split("service_gateway_check_event:", 1)[1].split(
            "service_gateway_check_reconnect:", 1
        )[0]
        self.assertIn("jz service_gateway_dispatch_ok", event)

    def test_windows_rest_response_capture_fails_closed_at_capacity(self):
        capture = WINDOWS_NETWORK.split("native_capture_response:", 1)[1].split(
            "native_copy_cstring:", 1
        )[0]
        self.assertIn("jmp native_capture_overflow", capture)
        self.assertIn("native_capture_overflow:", capture)
        self.assertNotIn("mov eax, ecx", capture)
        after_read = capture.split("add ebx, eax", 1)[1].split("native_capture_done:", 1)[0]
        self.assertIn("jmp native_capture_loop", after_read)
        before_add = capture.split("mov eax, [rel network_io_size]", 2)[2].split("add ebx, eax", 1)[0]
        self.assertIn("test eax, eax", before_add)
        self.assertIn("jz native_capture_fail", before_add)

    def test_windows_amount_parser_stops_after_the_first_amount_token(self):
        extractor = WINDOWS_RUNTIME.split("runtime_extract_push_amount:", 1)[1].split(
            "runtime_extract_amount_title:", 1
        )[0]
        self.assertIn("runtime_extract_amount_comma:", extractor)
        self.assertIn("ja runtime_extract_amount_done", extractor)
        self.assertNotIn("runtime_extract_amount_non_digit", extractor)

    def test_startup_configuration_is_fail_closed_on_both_native_runtimes(self):
        self.assertIn("cmd_validate_config", LINUX_RUNTIME)
        finder = LINUX_RUNTIME.split("rt_find_command:", 1)[1].split("rt_find_command_done:", 1)[0]
        self.assertIn("cmd_validate_config", finder)
        self.assertIn("cmd_gateway_probe", finder)
        self.assertIn("rt_validate_config:", LINUX_RUNTIME)
        self.assertIn("rt_fail_config:", LINUX_RUNTIME)
        self.assertIn("rt_gateway_probe:", LINUX_RUNTIME)
        self.assertIn(".global ws_error_code", LINUX_NETWORK)
        self.assertIn(".global ws_stage", LINUX_NETWORK)
        self.assertIn("command_validate_config", WINDOWS_RUNTIME)
        self.assertIn("runtime_validate_config:", WINDOWS_RUNTIME)
        self.assertIn("runtime_config_invalid:", WINDOWS_RUNTIME)
        self.assertIn("runtime_config_line:", WINDOWS_RUNTIME)
        self.assertIn("runtime_validate_decimal:", WINDOWS_RUNTIME)
        self.assertIn("runtime_validate_ws_url:", WINDOWS_RUNTIME)
        self.assertIn("config_key_case", WINDOWS_RUNTIME)
        self.assertIn("key_case", LINUX_RUNTIME)
        self.assertIn("rt_validate_ws_url:", LINUX_RUNTIME)
        self.assertIn("User=root", SERVICE_UNIT)
        self.assertIn("ExecStartPre=/root/yul-vending-machine/current/yul-vending-machine", SERVICE_UNIT)
        self.assertIn("ProtectHome=read-only", SERVICE_UNIT)
        self.assertIn("validate-config", SERVICE_UNIT)
        self.assertIn("ProtectProc=invisible", SERVICE_UNIT)
        self.assertIn("ProcSubset=pid", SERVICE_UNIT)
        self.assertIn("SystemCallArchitectures=native", SERVICE_UNIT)
        self.assertIn("KeyringMode=private", SERVICE_UNIT)

    def test_native_sqlite_migration_contract_is_embedded(self):
        self.assertIn("rt_db_migrate:", LINUX_RUNTIME)
        self.assertIn("sql_native_migration_v2", LINUX_RUNTIME)
        self.assertIn("sql_native_verify_v2", LINUX_RUNTIME)
        self.assertIn("sql_native_version_v2", LINUX_RUNTIME)
        self.assertIn("runtime_db_migrate:", WINDOWS_RUNTIME)
        self.assertIn("sql_native_migration_v2", WINDOWS_RUNTIME)
        self.assertIn("sql_native_verify_v2", WINDOWS_RUNTIME)
        self.assertIn("sql_native_version_v2", WINDOWS_RUNTIME)
        self.assertIn("sql_native_migration_v3", LINUX_RUNTIME)
        self.assertIn("sql_native_verify_v3", LINUX_RUNTIME)
        self.assertIn("sql_native_index_v3", LINUX_RUNTIME)
        self.assertIn("sql_native_version_v3", LINUX_RUNTIME)
        self.assertIn("sql_native_migration_v3", WINDOWS_RUNTIME)
        self.assertIn("sql_native_verify_v3", WINDOWS_RUNTIME)
        self.assertIn("sql_native_index_v3", WINDOWS_RUNTIME)
        self.assertIn("sql_native_version_v3", WINDOWS_RUNTIME)


if __name__ == "__main__":
    unittest.main()
