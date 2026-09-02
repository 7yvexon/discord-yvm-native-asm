# Native source

이 디렉터리는 플랫폼별 native launcher와 결제 결정 코어의 ABI 경계를 제공합니다.

Windows x64와 Linux AArch64의 실행 파일은 Python 프로세스를 생성하지 않고 각 플랫폼의 어셈블리 런타임으로 직접 진입합니다. 실제 운영은 Linux AArch64에서만 수행하며 Windows x64는 개발·테스트 전용입니다.

금액 파서·UTF-8 입금자명 정규화·누적 금액 오버플로 검사·SQLite 동적 로더도 어셈블리로 빌드됩니다. `vending_machine/` 패키지는 회귀 테스트와 동작 비교를 위한 Python 기준 구현으로만 남겨 둡니다.

현재 ABI는 다음과 같습니다.

Windows x64와 Linux AArch64 외부 연동은 native 경로로 개발·검증합니다. 실제 운영 환경에서는 Linux AArch64 systemd 경로만 사용합니다.

두 경로에는 Gateway Hello·Identify·READY·heartbeat·resume·재연결, REST 패널·interaction·DM, Pushbullet WebSocket·tickle·modified_after polling과 cursor/session 영속화가 포함됩니다.

Windows는 WinHTTP WebSocket·HTTPS API와 콘솔 제어 이벤트를 개발·테스트하는 용도이고, Linux는 libcurl/OpenSSL·systemd 신호 경로를 사용합니다.

Python은 기준 구현과 fixture/parity 회귀 테스트에 사용하며, Python과 Linux native만 `뀨?` 길드 태그 관측을 제공합니다.

길드 태그 관측의 플랫폼 범위는 다음과 같습니다.

| 경로 | 지원 범위 |
| --- | --- |
| Python | `GUILD_MEMBER_UPDATE`, 로그 채널, 단일 상태 임베드, 재시작·`READY`·`RESUMED` 재색인 |
| Windows x64 native | 미지원. Windows native 전용 검증 설정에서는 태그 키를 제외 |
| Linux AArch64 native | `GUILD_MEMBER_UPDATE`, REST 멤버 페이지 색인, 상태 메시지 저장·재사용·복구 |

태그 채널을 지정하면 Python과 Linux native가 `GUILD_MEMBERS` intent 비트(`2`)를 런타임에 추가합니다. Developer Portal의 Server Members Intent와 대상 길드·채널 권한은 별도로 준비해야 합니다.

Linux native의 상태 채널·메시지·멤버 목록은 SQLite `settings`에 저장되어 재연결과 재시작 뒤 다시 사용됩니다.

```text
yul_parse_amount_ascii(input, length, output_amount) -> status
yul_normalize_name_utf8(input, input_length, output, output_capacity, output_length) -> status
yul_add_support_total(current_total, amount, output_total) -> status
yul_sqlite_runtime_load() -> status
yul_sqlite_runtime_unload() -> status
yul_sqlite_open(path, output_db) -> status
yul_sqlite_close(db) -> status
yul_sqlite_exec(db, sql) -> status
yul_sqlite_prepare(db, sql, output_statement) -> status
yul_sqlite_bind_text(statement, index, value, length) -> status
yul_sqlite_bind_int64(statement, index, value) -> status
yul_sqlite_bind_null(statement, index) -> status
yul_sqlite_step(statement) -> sqlite result code
yul_sqlite_finalize(statement) -> status
yul_sqlite_column_int64(statement, index) -> int64
yul_sqlite_column_text(statement, index) -> pointer
yul_sqlite_errmsg(db) -> pointer
```

성공 상태는 0이며, 그 외 상태는 입력 오류·범위 초과·출력 버퍼 부족을 뜻합니다. 포인터와 길이는 플랫폼 C ABI를 따르고, 문자열은 NUL 종결이 아닌 명시적 길이를 사용합니다.

외부 서비스의 실제 장기 세션과 주문 처리는 Linux AArch64 systemd에서 수행합니다. Windows x64 native `run`은 개발·테스트용입니다. `deploy/yul-vending-machine.service`는 Python 실행 파일을 참조하지 않으며, Windows 실행 파일도 Python 런타임을 링크하거나 생성하지 않습니다.

Windows x64와 Linux AArch64 native launcher는 설정 파일, SQLite 스키마 초기화·migration, 주문 생성, 누적 금액 조회, Push fixture 파싱, source 필터, fingerprint·중복 방지를 네이티브 런타임에서 수행합니다. 파싱 실패나 지원하지 않는 이벤트는 기록하고, 검토 목록·원장·자동 지급 트랜잭션도 native 경로에서 처리합니다.

두 native 경로에는 외부 Discord·Pushbullet TLS 프로토콜, 패널·interaction·DM·DM 재시도, Gateway/Push 재연결, 커서·세션 영속화와 이벤트 직렬화가 포함되어 있습니다.

자동 지급은 항상 활성화됩니다. 유일하게 매칭된 주문을 `PAID`로 바꾸고 원장·누적 후원 금액을 기록한 뒤 완료 DM을 전송합니다. Linux AArch64 native는 길드 태그 상태에 따라 설정된 Discord 역할을 부여·회수하며, 긴급 중지 시 전체 서비스를 중지합니다.

native 명령은 `init-db`, `panel-text`, `create-order`, `process-push`, `support-total`, `review-list`, `ledger`, `validate-config`, `run`입니다. Linux AArch64에는 `gateway-probe`가 추가됩니다. 검토 목록은 조회 전용입니다.

Python 기준 구현은 별도로 `panel` 명령을 제공하며, 길드 태그 상태 동기화는 Linux native와 동일한 상태 계약을 따릅니다.

빌드·테스트 순서는 루트 [README](../README.md), 설정 키는 [설정 가이드](../docs/configuration.md), 태그 이벤트와 권한은 [Discord 길드 태그 관측](../docs/discord-guild-tags.md), AArch64 검증은 [Native 전환 검증](../docs/native-transition.md)을 기준으로 합니다.
