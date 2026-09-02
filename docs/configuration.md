# 설정 가이드

`config.example.ini`는 공개 저장소에 안전하게 커밋할 수 있도록 비밀값과 운영 채널 ID를 비워 둔 템플릿입니다. 실제 토큰·계좌번호·알림 원문은 이 저장소에 넣지 말고, 운영 릴리스와 분리된 파일 또는 비밀 저장소에서 주입하세요.

## 설정 파일 만들기

```powershell
Copy-Item config.example.ini .local-vending.ini
```

`.local-vending.ini`와 `config.ini`는 `.gitignore`에 포함되어 있습니다. 그래도 커밋 전에 `git diff --cached`와 `git status --short`를 확인하고, 이미 노출한 자격 증명은 즉시 폐기·재발급하세요.

## 키 목록

### Discord

| 키 | 필수 실행 경로 | 설명 |
| --- | --- | --- |
| `DISCORD_BOT_TOKEN` | `run`, `panel` | Discord Bot 토큰 |
| `DISCORD_APPLICATION_ID` | `run`, `panel` | 애플리케이션 ID |
| `DISCORD_GUILD_ID` | `run` | 명령을 등록할 서버 ID |
| `DISCORD_PANEL_CHANNEL_ID` | `run`, `panel` | 입금 패널을 게시할 채널 ID |
| `DISCORD_GUILD_TAG_LOG_CHANNEL_ID` | Python `run`, Linux native `run` | `뀨?` 길드 태그 착용·해제 로그를 보낼 채널 ID. 템플릿 기본값은 공란 |
| `DISCORD_GUILD_TAG_STATUS_CHANNEL_ID` | Python `run`, Linux native `run` | 시작 시 길드 멤버 전체를 색인하고, 현재 `뀨?` 길드 태그 착용자 목록을 하나의 임베드로 갱신할 채널 ID. 템플릿 기본값은 공란 |
| `DISCORD_GUILD_TAG_ROLE_ID` | Python `run`, Linux native `run` | 태그 착용자에게 부여하고 해제 시 회수할 역할 ID. 템플릿 기본값은 공란이며, 비워 두면 역할 동기화를 끔 |
| `DISCORD_ADMIN_USER_ID` | `run`, `panel`, `review-list`, `ledger` | 관리자 조회·패널 게시 권한을 확인할 사용자 ID |
| `DISCORD_GATEWAY_URL` | 선택 | 기본값 `wss://gateway.discord.gg/?v=10&encoding=json` |
| `DISCORD_INTENTS` | 선택 | 기본값 `1`; 음수가 아니어야 함 |

`DISCORD_BOT_TOKEN`은 파일·환경 변수·로그·명령행 인자에 노출하지 마세요. Discord 애플리케이션에는 필요한 서버와 권한만 부여하고, 명령 등록 대상도 운영 서버로 제한하세요.

표에서 `선택`으로 표시한 키는 Python 기준 구현이 코드 기본값을 제공한다는 뜻입니다. native `validate-config`는 `DISCORD_GATEWAY_URL`, `DISCORD_INTENTS`, `PUSHBULLET_STREAM_URL`을 설정 파일에서 확인하므로 native 운영 설정에는 명시적으로 넣으세요.

native에서는 `BANK_TITLE_PREFIX`와 `BANK_TITLE_PATTERN` 중 적어도 하나가 필요합니다. 두 값을 모두 비우면 시작하지 않습니다.

공개 템플릿과 Python·Linux AArch64 native의 길드 태그 채널·역할 기본값은 모두 공란입니다. 설정하지 않으면 태그 기능이 비활성화됩니다.

Python `run`에서 태그를 사용하려면 두 채널 값을 설정해야 합니다. Linux AArch64 native에서 관측과 역할 동기화를 켜려면 필요한 키를 명시적으로 채우세요.

운영 환경에서는 채널·역할 ID를 자신의 서버 값으로 채우고, 역할 동기화를 사용하려면 Developer Portal의 Server Members Intent와 `Manage Roles` 권한, 대상 역할보다 높은 봇 역할 순서를 확인하세요.

Windows x64 native는 길드 태그를 구현하지 않고 strict 설정 검증에서 해당 키를 허용하지 않습니다. Windows native 전용 설정에는 길드 태그 키를 넣지 마세요. 세 경로의 지원 범위와 이벤트 조건은 [Discord 길드 태그 관측](discord-guild-tags.md)을 따릅니다.

두 태그 채널 중 하나 또는 역할 ID가 값이 있으면 Python과 Linux AArch64 native가 `DISCORD_INTENTS`에 `GUILD_MEMBERS` 비트(`2`)를 자동으로 더합니다.

Discord Developer Portal에서도 Server Members Intent를 켜야 하며, 봇이 대상 길드에 있고 멤버 조회·메시지 전송·임베드 게시 권한을 가져야 합니다. 역할을 동기화하면 `Manage Roles` 권한과 대상 역할보다 높은 봇 역할 순서도 필요합니다.

상태 임베드는 다음 `settings` 키를 사용해 재시작 후에도 복구합니다.

```text
discord.guild_tag_status_channel_id
discord.guild_tag_status_message_id
discord.guild_tag_status_members
```

### Pushbullet

| 키 | 필수 실행 경로 | 설명 |
| --- | --- | --- |
| `PUSHBULLET_ACCESS_TOKEN` | `run` | Pushbullet API/WebSocket 액세스 토큰 |
| `PUSHBULLET_STREAM_URL` | 선택 | 기본값 `wss://stream.pushbullet.com/websocket` |

수신 루프는 WebSocket 이벤트와 `modified_after` polling을 함께 사용하고 cursor를 SQLite `settings`에 저장합니다. 캡처 도구나 디버그 로그로 실제 Push 본문을 보존하지 마세요.

### 은행·Toss source

| 키 | 필수 실행 경로 | 설명 |
| --- | --- | --- |
| `BANK_NAME` | `run` | 패널에 표시할 은행 이름 |
| `BANK_ACCOUNT_NUMBER` | `run` | 패널에 표시할 계좌번호 |
| `BANK_ACCOUNT_HOLDER` | `run` | 패널에 표시할 예금주 |
| `BANK_PACKAGE_NAME` | `run` | Push 앱 패키지 필터. Toss 운영 계약은 `viva.republica.toss` |
| `BANK_APPLICATION_NAME` | `run` | Push 앱 이름 필터. Toss 운영 계약은 `토스` |
| `BANK_TITLE_PREFIX` | 선택 | 제목 접두사 필터. 보통 비워 둠 |
| `BANK_TITLE_PATTERN` | 선택 | 운영 계약은 `^[0-9][0-9,]*원\s*입금$` 또는 빈 값 |
| `BANK_AMOUNT_PATTERN` | `run` | 지원되는 금액 정규식 중 하나 |
| `BANK_NAME_PATTERN` | `run` | 지원되는 입금자명 정규식 중 하나 |

native 런타임은 임의의 정규식 확장을 실행하지 않고 다음 계약만 허용합니다.

```ini
BANK_PACKAGE_NAME=viva.republica.toss
BANK_APPLICATION_NAME=토스
BANK_TITLE_PREFIX=
BANK_TITLE_PATTERN=^[0-9][0-9,]*원\s*입금$
BANK_AMOUNT_PATTERN=([0-9][0-9,]*)원\s*입금
BANK_NAME_PATTERN=^([^\r\n→,()]{1,100}?)\s*→\s*내 토스뱅크 통장$
```

기본 호환성 패턴은 `BANK_AMOUNT_PATTERN`의 `입금액`·`입금금액`·`금액`·`amount` 형식과 `BANK_NAME_PATTERN`의 `입금자`·`보낸분`·`보낸 사람`·`sender`·`name` 형식입니다. Python은 설정된 정규식을 실행할 수 있지만, native와 같은 동작을 보장하려면 위 지원 목록을 유지하세요.

1원 알림처럼 앱이 입금자명과 금액을 검열한 이벤트는 `PARSE_FAILED`로 기록되고 자동 반영되지 않습니다. 출금·취소·잔액 변경·다른 앱 이벤트는 source와 제목 필터 단계에서 제외합니다.

### 주문·금액·저장소

| 키 | 기본값 | 설명 |
| --- | --- | --- |
| `ORDER_TTL_SECONDS` | `1800` | 주문 유효 시간. 양의 정수 |
| `MIN_AMOUNT_KRW` | 비어 있음 | 최소 금액. 설정하면 양의 64비트 정수 |
| `MAX_AMOUNT_KRW` | 비어 있음 | 최대 금액. 설정하면 `MIN_AMOUNT_KRW` 이상인 양의 64비트 정수 |
| `AUTO_CREDIT` | `1` | 항상 `1`이어야 함. 자동 반영을 끄는 모드는 없음 |
| `CASE_INSENSITIVE_LATIN` | `0` | 라틴 문자 이름 비교의 대소문자 무시 여부 |
| `DATABASE_PATH` | `./data/vending.db` (템플릿) | SQLite 경로. 운영에서는 릴리스 밖의 `shared/data` 사용 |

SQLite는 WAL과 외래 키를 사용하고, 유효한 단일 매칭의 주문 상태·원장·누적 금액·Push 소비 상태를 하나의 `BEGIN IMMEDIATE` 트랜잭션에서 기록합니다. 원본 Push 본문은 저장하지 않고 해시와 파싱 결과만 보존합니다.

## Python과 native의 차이

직접 미러 이벤트의 fingerprint는 최상위 payload에서 `iden`, `created`, `modified`, `active`, `dismissed`를 제외한 bounded JSON 필드를 폭넓게 반영합니다.

Windows x64와 Linux AArch64 native는 같은 원시 바이트 payload에 같은 FNV-1a digest namespace를 사용합니다. Python은 canonical JSON + SHA-256 별도 namespace를 사용하므로 Python과 native의 결과 push ID 문자열은 서로 다를 수 있습니다.

native fingerprint는 lifecycle 이외 필드의 키 순서·공백·직렬화가 달라져도 달라질 수 있습니다. 생성에 실패한 malformed payload는 이전 값으로 재사용하지 않고 격리합니다.

`created`와 `modified`가 모두 없는 direct mirror도 허용합니다. 이 경우 Python은 현재 수신 시각에 유효한 유일 주문을 매칭하고, Windows/Linux native는 같은 수신 시각을 이벤트 시각으로 사용합니다. 실제 입금·알림 발생 시각은 확인하지 않으므로 오래된 이벤트가 새 주문에 반영될 위험을 운영자가 관리해야 합니다.

Windows x64 native는 주문의 `expires_at`을 매칭 조건에 사용하지만 만료된 주문의 저장 상태를 `EXPIRED`로 전환하지 않습니다. 만료된 Windows 주문은 `PENDING`으로 남으며 자동 반영 대상에서 제외됩니다. Python과 Linux AArch64의 상태 전이와 함께 사용해야 한다면 데이터베이스를 분리하세요.

| 항목 | Python 기준 구현 | Windows/Linux native |
| --- | --- | --- |
| 환경 변수 우선순위 | 지원. 파일 값보다 우선 | 지원하지 않음. 설정 파일 기준 |
| 운영 `run` | 사용하지 않음 | Linux AArch64만 운영 경로 |
| `panel` 명령 | 지원 | CLI에서는 미지원. native `run`이 `/입금패널` interaction을 처리 |
| `validate-config` | 별도 명령 없음 | 지원. 누락·빈 값·범위·패턴을 fail-closed 검증 |

두 런타임을 비교할 때는 같은 설정 파일과 같은 fixture를 사용하고, `AUTO_CREDIT=1`과 Toss source 필터를 유지하세요.

## 운영 전 점검

```sh
/path/to/yul-vending-machine \
  --config /path/to/shared/config/vending.ini validate-config
```

검증이 실패하면 서비스를 시작하지 않습니다. 성공 후에도 다음을 확인하세요.

- 설정 파일 소유자와 권한이 운영 계정 전용인지
- 토큰과 계좌번호가 journal, shell history, CI artifact에 남지 않는지
- `BANK_PACKAGE_NAME`·`BANK_APPLICATION_NAME`·제목·본문 계약이 실제 Toss 알림과 일치하는지
- `MIN_AMOUNT_KRW`·`MAX_AMOUNT_KRW`가 테스트 송금 한도와 일치하는지
- `DATABASE_PATH`가 릴리스 디렉터리 밖의 백업 가능한 경로인지
- 제한된 fixture로 `RECEIVED`, `UNSUPPORTED`, `PARSE_FAILED`, 중복, 단일 매칭 결과를 확인했는지
- 길드 태그를 사용할 경우 Developer Portal의 Server Members Intent와 두 태그 채널의 ID·권한을 확인했는지
- 상태 채널에 봇이 관리하는 단일 임베드가 생성되고, 재시작·`RESUMED` 뒤 같은 메시지가 갱신되는지 확인했는지

자동 반영을 즉시 중지해야 하면 설정값을 임의로 바꾸지 말고 systemd 서비스를 중지하세요. 현재 구현에는 별도의 dry-run 또는 `AUTO_CREDIT=0` kill switch가 없습니다.
