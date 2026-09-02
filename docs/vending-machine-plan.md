# 어셈블리 기반 Discord 입금 확인·누적 후원 금액 기록 봇 설계·구현 문서

문서 상태: 구현 반영 완료(운영 후속 관찰 제외)
작성일: 2026-08-24
최종 갱신: 2026-09-01

이 문서는 설계 결정과 구현 이력을 보존하는 상세 문서입니다. 공개 저장소에서 처음 읽는 경우에는 [README](../README.md)와 [설정 가이드](configuration.md)를 먼저 확인하세요. 특정 운영 호스트·자격 증명·운영 DB·실서비스 수치는 기록하지 않으며, 배포 환경은 별도 운영 기록으로 관리합니다.

## 1. 목표

Discord 패널에서 사용자가 입금 신청을 만들고, Toss 은행 입금 알림을 Pushbullet으로 수신한 뒤 입금자명과 금액이 모두 일치하는 경우에만 사용자의 누적 후원 금액을 증가시키는 봇을 구현했다. 결제 흐름과 독립적으로 지정 길드의 `뀨?` 태그 상태를 관측해 변경 로그와 현재 착용자 임베드를 유지할 수 있다.

애플리케이션 코드는 어셈블리로 작성한다. Windows x64에서 개발·테스트하고 실제 운영은 비공개 Linux AArch64 서버에서 수행하며, HTTPS·TLS·SQLite·난수·운영체제 기능은 플랫폼이 제공하는 DLL 또는 공유 라이브러리를 사용한다. Windows 운영 배포와 Windows 서비스 실행기 선택은 범위에서 제외한다.

핵심 원칙은 다음과 같다.

- 입금자명과 입금 금액이 모두 일치해야 자동 반영한다.
- 동일한 Pushbullet 이벤트가 재전달되어도 한 번만 자동 반영한다.
- 하나의 자동 반영은 주문 상태 변경, 원장 기록, 누적 후원 금액 증가가 하나의 DB 트랜잭션으로 처리된다.
- 해석이 모호한 알림은 자동 반영하지 않고 검토 대기 상태로 남긴다.
- 자동 반영은 주문을 `PAID`로 변경하고 원장·누적 후원 금액을 같은 SQLite 트랜잭션에 기록한 뒤 완료 DM을 보내는 것으로 한정한다. 계좌 송금과 재화 환전은 제공하지 않는다.
- 운영 Toss 입력은 확정된 10원 직접 미러 형식과 source 필터를 통과한 경우에만 자동 반영한다.
- 길드 태그 관측은 `GUILD_MEMBER_UPDATE`와 REST 멤버 색인을 사용하며, `DISCORD_GUILD_TAG_ROLE_ID` 역할을 태그 착용 상태에 맞춰 부여·회수한다.
- 원격 서버의 기존 서비스·데이터베이스와 기능적으로 연결하지 않는다.

## 2. 운영 환경 가정

운영 프로파일은 Linux AArch64 호스트를 기준으로 한다. SSH 개인 키와 자격 증명은 로컬 배포 환경에서 관리하며, 정식 배포 상태나 실서비스 수치는 이 저장소에 기록하지 않는다.

| 항목 | 요구 사항 |
| --- | --- |
| 운영 OS | glibc 기반 Linux |
| CPU 아키텍처 | AArch64/ARM64 |
| SQLite | WAL, `busy_timeout=5000`, `libsqlite3.so.0` 호환 |
| 네트워크 런타임 | `libcurl.so.4`, OpenSSL ABI 호환 |
| 운영 포트 | 수신 HTTP 포트 없이 외부 Gateway·Push 연결 |
| 서버 개발 도구 | 운영 서버에는 컴파일러를 설치하지 않음 |

Windows x64 실행 파일을 Linux ARM64에 그대로 배포할 수 없으므로 Windows 개발·테스트 빌드와 Linux ARM64 운영 빌드를 별도로 생성한다. 프로젝트는 다른 서비스·Discord 애플리케이션·토큰·재화·DB·배포 경로와 기능적으로 연결하지 않고, 별도의 systemd 서비스와 SQLite 데이터베이스를 사용한다.

## 3. 플랫폼 및 빌드 전략

### 3.1 Windows 개발 빌드: NASM

```text
build/windows-x64/yul-vending-machine.exe
```

NASM은 독립적으로 사용할 수 있는 x86·x64 어셈블러이며, Windows x64 실행 파일을 만들기에 적합하다. MASM은 Microsoft Visual Studio 도구 체인에 포함된 x86·x64 어셈블러로 Windows ABI와 Visual Studio 연동이 편하지만, 이 프로젝트에는 필수 요소가 아니다. 두 어셈블러 모두 Ubuntu 운영 서버의 AArch64 명령어를 직접 만들 수 없다.

따라서 Windows 개발 빌드는 NASM을 기본으로 선택한다. NASM 실행 파일과 필요한 링크 도구는 프로젝트 내부 `.tools/`에 포터블 형태로 둔다.

Windows native 네트워크 경계는 `WinHTTP`를 사용하고, Linux AArch64 네트워크 경계는 운영체제가 제공하는 `libcurl`·OpenSSL을 사용한다. SQLite는 각 플랫폼의 런타임 동적 로더를 사용한다.

실제 운영 Gateway·REST·Pushbullet 세션은 Linux AArch64 native 경로에서 처리한다. Windows 경로는 결제·Push·Gateway 동작의 개발·테스트 검증에 사용한다. 길드 태그 관측은 Python과 Linux AArch64 native에만 포함한다.

애플리케이션은 import library에 강하게 결합하지 않고 필요한 함수 주소를 런타임에 resolve하는 방식으로 작성한다. 이렇게 하면 개발 PC에 별도 SDK나 전역 DLL을 설치하지 않고 프로젝트 내부의 포터블 런타임으로 실행할 수 있다.

### 3.2 Ubuntu 운영 빌드: AArch64 LLVM 어셈블러

```text
build/linux-aarch64/yul-vending-machine
```

운영 서버가 AArch64이므로 NASM이나 MASM이 아닌 LLVM integrated assembler의 AArch64 모드 또는 AArch64 GNU assembler로 Linux ABI용 바이너리를 별도로 만든다. Windows 개발 환경의 `.tools/` 아래에 포터블 LLVM 또는 AArch64 GNU binutils를 두고 교차 어셈블·링크한다. 전역 패키지 설치는 하지 않는다.

Windows에서는 `build/build-aarch64.ps1`, Linux 호스트에서는 `build/build.sh`를 사용해 동일한 launcher와 `yul-core.so`를 빌드한다.

운영 서버에는 컴파일러를 설치하지 않는다. 릴리스에는 다음을 포함한다.

- 대상 아키텍처 native launcher와 결제 코어 공유 객체
- `config.example.ini`(비밀값이 없는 예시 설정)
- 데이터베이스 스키마와 마이그레이션 파일
- systemd 서비스·설치·검증·백업·복원·롤백 스크립트
- `RELEASE.json`과 `SHA256SUMS`

운영용 `vending.ini`와 데이터베이스는 릴리스에 넣지 않고 설치 루트의 `shared/`에 별도로 주입하며, 설치 후 운영 계정 전용·0600 권한으로 제한한다. Linux 런타임은 대상 서버의 `libcurl.so.4`, `libsqlite3.so.0`, glibc ABI를 사용하고, Windows 릴리스만 검증된 SQLite DLL을 선택적으로 포함할 수 있다.

### 3.3 공통 코드의 범위

Windows x64와 Linux AArch64는 CPU 명령어, 호출 규약, TLS API, 파일·소켓 API가 다르므로 하나의 바이너리를 양쪽에서 실행할 수 없다. 다음을 공통 기준으로 관리한다.

- SQL 스키마
- 상태 전이 규칙
- Pushbullet·Discord JSON 테스트 fixture
- 입금자명 정규화 규칙
- 금액 파서의 테스트 케이스
- 오류 코드와 감사 이벤트 형식

플랫폼별로 분리하는 모듈은 다음과 같다.

- Windows ABI, WinHTTP, BCrypt, 파일·스레드 API
- Linux AArch64 ABI, POSIX 소켓·파일·스레드 API
- Windows DLL 로더와 Linux `dlopen`/`dlsym` 로더

### 3.4 현재 명령 인터페이스

구현된 CLI는 런타임별로 다음 명령을 제공한다.

| 런타임 | 명령 |
| --- | --- |
| Python 기준 구현 | `init-db`, `create-order`, `process-push`, `review-list`, `ledger`, `support-total`, `panel-text`, `panel`, `run` |
| Windows x64 native | `init-db`, `create-order`, `process-push`, `review-list`, `ledger`, `support-total`, `panel-text`, `validate-config`, `run` |
| Linux AArch64 native | Windows native 명령과 동일하며 `gateway-probe` 추가 |

native `validate-config`는 운영 설정을 fail-closed로 검사하고, Linux 전용 `gateway-probe`는 자격 증명을 사용한 Gateway 단독 연결만 확인한다.

Python과 Linux native의 `run`만 길드 태그 관측과 설정된 역할 동기화를 수행한다. Windows native `run`은 해당 이벤트를 처리하지 않는다. 검토 목록은 조회 전용이며 수동 승인이나 결제 관련 역할 API는 제공하지 않는다.

## 4. 전체 구성

```text
Discord Gateway
       │
       ├─ INTERACTION_CREATE
       │   ├─ 패널 버튼 → 모달 응답
       │   └─ 모달 제출 → 주문 생성
       ├─ GUILD_MEMBER_UPDATE
       │   ├─ 길드·primary_guild·태그 상태 검증
       │   ├─ 상태 변경 시 로그 채널 게시
       │   └─ 현재 착용자 단일 임베드 갱신
       └─ REST API
           ├─ 패널 게시
           ├─ ephemeral 응답
           ├─ DM 채널 생성·메시지 전송
           └─ 길드 멤버 재색인·상태 메시지 복구

Pushbullet WebSocket
       │
       ├─ tickle 수신
       └─ /v2/pushes?modified_after=... 조회
               │
               ├─ 은행 앱 알림 필터
               ├─ 입금자명 추출
               ├─ 금액 추출
               └─ 주문 매칭

SQLite vending.db
       │
       └─ 하나의 트랜잭션
               ├─ Push 중복 확인
               ├─ 주문 PAID 변경
               ├─ 지급 원장 기록
               └─ 누적 후원 금액 증가
```

Discord 상호작용은 공개 HTTP 서버를 열지 않고 Gateway로 수신한다. 따라서 새 서비스가 외부에서 접근 가능한 수신 포트를 열 필요가 없다.

Discord는 버튼·모달 상호작용을 Gateway 또는 HTTP 상호작용 엔드포인트로 전달할 수 있으며, 현재 운영 환경에서는 Gateway 방식을 사용한다. [Discord Interactions](https://docs.discord.com/developers/platform/interactions)

## 5. Discord 기능

### 5.1 패널

관리자 전용 명령으로 지정 채널에 입금 패널을 게시한다.

패널 embed에는 입금 절차, 입금 알림 반영 지연 안내, 입금자명과 금액이 모두 일치해야 한다는 자동 확인 조건을 표시하고 `입금 신청` 버튼을 함께 게시한다. 금액 범위는 주문 입력 검증에 적용하며, 계좌 상세 정보와 정확한 금액은 주문 신청 응답에서 표시한다.

패널 메시지 ID와 채널 ID는 설정 파일 또는 `settings` 테이블에 저장하여 재시작 후에도 같은 패널을 관리할 수 있도록 한다.

버튼의 식별자는 버전이 포함된 고정 문자열을 사용한다.

```text
vending:deposit:v1
```

### 5.2 모달

버튼 클릭에 대해 Discord 모달 응답을 보낸다. 모달 입력은 다음과 같다.

```text
depositor_name
amount_krw
```

서버는 모달 데이터에서 사용자의 Discord ID를 가져오며, 클라이언트가 보낸 Discord ID를 신뢰하지 않는다.

입력 검증 규칙은 다음과 같다.

- 금액은 ASCII 숫자만 허용한다.
- 쉼표·통화 기호·소수점은 허용하지 않거나 정규화 후 다시 검증한다.
- 금액은 64비트 정수 범위와 설정된 최소·최대 금액 안에 있어야 한다.
- 입금자명은 공백을 앞뒤에서 제거하고 연속 공백을 하나로 정규화한다.
- 제어 문자와 0바이트는 거부한다.
- UTF-8이 아닌 입력은 거부한다.

입력은 주문 생성 전에 검증하고, 검증 실패 시 DB에 주문을 만들지 않는다.

### 5.3 주문 생성 후 응답

주문이 DB에 성공적으로 저장된 경우에만 사용자에게 다음을 보낸다.

- ephemeral 메시지
- 동일한 내용을 담은 DM

ephemeral 메시지와 DM embed에는 입금 은행명, 계좌번호, 예금주, 입금할 정확한 금액, 입력한 입금자명, 주문 만료 시각과 이름·금액 일치 조건을 포함한다. 주문 ID는 사용자 응답에 표시하지 않는다.

DM이 실패해도 주문과 지급 로직은 취소하지 않는다. DM 전송 상태만 별도로 기록하고 재시도한다.

Discord interaction의 처리가 오래 걸릴 수 있으므로, DB 또는 DM 작업이 지연될 때는 먼저 지연 응답을 보내고 후속 응답으로 결과를 갱신한다. 모달 응답과 메시지 응답 타입은 Discord 공식 문서의 타입 정의를 따른다. [Receiving and Responding](https://docs.discord.com/developers/interactions/receiving-and-responding)

### 5.4 길드 태그 관측

결제와 별도의 관측 기능으로 `DISCORD_GUILD_TAG_LOG_CHANNEL_ID`, `DISCORD_GUILD_TAG_STATUS_CHANNEL_ID`, `DISCORD_GUILD_TAG_ROLE_ID`를 지정할 수 있다. Python 기준 구현과 Linux AArch64 native가 지원하며 Windows x64 native에는 포함하지 않는다.

역할 ID가 설정되면 태그 착용자에게 역할을 부여하고 해제 시 회수한다.

역할 ID를 설정하면 `GUILD_MEMBERS` intent 비트(`2`)도 자동으로 추가하며, `Manage Roles` 권한과 대상 역할보다 높은 봇 역할 순서를 요구한다.

- 대상 이벤트는 설정한 `DISCORD_GUILD_ID`의 `GUILD_MEMBER_UPDATE`이다. 이벤트의 `primary_guild.identity_guild_id`가 대상 길드와 같고 `identity_enabled`가 `true`일 때만 `뀨?` 태그 착용 상태로 판정한다.
- 표시 이름은 `nick`, `global_name`, `username`, 사용자 ID 순으로 선택한다. 초기 색인이나 같은 상태의 반복 이벤트는 로그를 만들지 않으며, 착용·해제 상태가 바뀔 때만 로그 채널에 기록한다. 표시 이름만 바뀌면 상태 임베드만 갱신한다.
- 상태 채널에는 "🏷️ `뀨?` 현재 착용자" 임베드 하나를 유지하고 표시 이름으로 정렬한다. 상태 목록과 메시지 ID는 `settings`에 저장한다.
- Linux native는 Gateway 연결 전에 한 번 색인하고, Python과 Linux native 모두 `READY`·`RESUMED` 뒤에는 REST 멤버 목록을 다시 색인해 이벤트 누락을 보정한다. Python은 최대 1000개 단위, Linux native는 페이지 단위로 조회한다.
- Python은 저장된 메시지가 없거나 삭제된 경우 새 상태 메시지를 만들고, Linux native는 먼저 최근 메시지에서 봇이 만든 동일 상태 임베드를 찾아 재사용한 뒤 없을 때만 만든다.
- 태그 채널 또는 역할 ID를 설정하면 `GUILD_MEMBERS` intent 비트(`2`)를 자동으로 추가하지만, Developer Portal의 Server Members Intent와 멤버 조회·메시지·임베드 권한은 별도로 필요하다. 역할 동기화에는 `Manage Roles` 권한과 대상 역할보다 높은 봇 역할 순서가 필요하다.

세부 설정·권한·장애 대응은 [Discord 길드 태그 관측](discord-guild-tags.md)을 기준으로 한다.

## 6. Pushbullet 및 Toss 알림 수신

### 6.1 Fixture 기준

운영 Toss 입력 형식은 10원 직접 미러 fixture로 확정한다. 1원 알림은 Toss 앱 검열로 입금자명과 금액이 없어 `PARSE_FAILED`로만 기록하고, 다른 은행 앱 알림은 앱 내 알림 설정으로 운영 범위에서 제외한다. 다음 fixture는 운영 기준과 회귀 검증에 사용한다.

```text
fixtures/pushbullet/toss-mirror-001.json
fixtures/pushbullet/toss-mirror-direct-001.json
fixtures/pushbullet/toss-tickle-001.json
fixtures/pushbullet/toss-duplicate-001.json
fixtures/pushbullet/toss-invalid-001.json
fixtures/pushbullet/toss-unicode-escaped-001.json
```

이 목록에서 `toss-mirror-direct-001.json`만 운영 Toss 입력의 canonical fixture이다.

`toss-mirror-001.json`, `toss-duplicate-001.json`, `toss-invalid-001.json`, `toss-unicode-escaped-001.json`은 이전 일반형 payload와 중복·비입금·유니코드 escape 회귀를 보존하는 호환성 fixture이며 운영 source 형식을 결정하지 않는다.

목록 API에서 조회되는 일반 Push fixture에는 실제 Pushbullet에서 확인할 다음 필드를 포함한다.

```text
type
subtype
push.iden
push.type
push.application_name
push.package_name
push.title
push.body
push.created
push.modified
```

목록 API에서 조회되는 일반 Push fixture는 위 필드를 유지한다. 반면 WebSocket에서 직접 전달되는 미러 이벤트는 `type=push`와 중첩된 `push.type=mirror`만 있고 `subtype`, `iden`, `created`, `modified`가 없을 수 있다.

이 경우 캡처한 비공개 원본 fixture에는 `source_device_iden`, `notification_id`, `notification_tag` 등 실제 필드를 그대로 유지하되, DB에는 원문을 저장하지 않는다. 이벤트 전체의 결정적 fingerprint를 내부 키로 사용해 중복을 방지한다.

생성·수정 시각이 모두 없는 direct mirror도 현재 수신 시각에 유효한 유일 주문과 이름·금액이 맞으면 자동 반영한다. 실제 입금·알림 발생 시각은 확인하지 않으므로 오래된 이벤트가 새 주문에 반영될 위험을 운영자가 관리해야 한다.

실제 알림을 제공할 때 계좌번호와 실명은 마스킹할 수 있지만, 공백·줄바꿈·쉼표·괄호 등 파싱에 필요한 형식은 유지해야 한다.

### 6.2 실시간 수신

Pushbullet 실시간 스트림은 다음 주소를 사용한다.

```text
wss://stream.pushbullet.com/websocket/<access_token>
```

일반 Push는 스트림에서 전체 알림 본문 대신 `tickle` 이벤트를 발생시킨다. `tickle`을 받으면 로컬에서 마지막으로 확인한 Pushbullet `modified` 값을 기준으로 다음 목록 API를 조회한다.

```text
GET https://api.pushbullet.com/v2/pushes?modified_after=<last_modified>
Access-Token: <token>
```

응답은 `modified` 오름차순으로 처리해 커서를 단조 증가시키고, Push ID를 기준으로 중복을 제거한다. 서버의 `modified` 값을 커서로 사용하며 로컬 시각을 커서로 사용하지 않는다. [Pushbullet Realtime Event Stream](https://docs.pushbullet.com/v12/), [Pushbullet API](https://www.pushbullet.com/api)

WebSocket에서 `type=push`인 직접 미러 이벤트가 도착하면 목록 API를 기다리지 않고 같은 파서·DB 경로로 전달한다. 안정적인 `iden`이 없는 직접 미러 이벤트는 최상위 payload의 모든 bounded 필드에서 lifecycle 필드(`iden`, `created`, `modified`, `active`, `dismissed`)만 제외한 fingerprint로 재전달 중복을 차단한다.

이름·금액이 유일하게 매칭되는 direct mirror는 생성·수정 시각이 모두 없어도 현재 수신 시각 기준으로 자동 반영한다. 이 정책은 실제 발생 시각을 검증하지 않는다.

매칭이 모호하거나 필수 필드가 없으면 `REVIEW` 등 상태만 기록한다. fingerprint가 거래의 공식 식별자를 대신한다는 의미는 아니다.

Windows/Linux native는 같은 원시 바이트 payload에 같은 FNV-1a namespace를 사용하고 Python은 canonical SHA-256 별도 namespace를 사용한다. native digest는 lifecycle 이외 필드의 키 순서·공백·직렬화에 민감하다.

### 6.3 알림 필터

운영 Toss 알림 형식은 다음 조건으로 확정하고 설정 파일에 고정한다.

- `package_name=viva.republica.toss`
- `application_name=토스`
- 제목: `^[0-9][0-9,]*원\s*입금$`
- 금액: 제목에서 `([0-9][0-9,]*)원\s*입금` 추출
- 입금자명: 본문 `^([^\r\n→,()]{1,100}?)\s*→\s*내 토스뱅크 통장$` 추출

은행 앱 이름이나 제목만 일치하는 이벤트는 지급 근거로 사용하지 않는다. 모든 필터를 통과하고 입금자명과 금액이 각각 정확히 하나씩 추출된 경우에만 매칭 단계로 넘긴다.

### 6.4 확정된 Toss 알림 형식 운영 기준

운영 기준 fixture는 `fixtures/pushbullet/toss-mirror-direct-001.json`으로 고정한다. 이 fixture는 `application_name=토스`, `package_name=viva.republica.toss`, 제목 `10원 입금`, 본문 `홍길동 → 내 토스뱅크 통장`을 사용하며, 입금자명은 마스킹된 예시 값이다.

1원 알림은 Toss 앱이 입금자명과 금액을 검열하는 정상 예외로 취급한다. 해당 이벤트는 결제 근거로 사용하지 않고 `PARSE_FAILED` 회귀 케이스로만 보존한다.

다른 은행 앱 알림은 앱 내 알림 설정으로 운영 범위에서 차단한다. 따라서 다른 은행 앱의 알림 형식을 별도 운영 fixture로 확정하지 않지만, Toss package/application source 필터는 계속 적용한다.

추가 회귀 범위는 같은 Toss 형식의 다른 금액, 다른 이름, 출금·취소 제목, 중복 재전달, 파싱 실패다. 모든 모호한 이벤트는 `REVIEW` 등 비지급 상태로만 기록한다.

실제 운영에서는 `AUTO_CREDIT=1`을 고정하고 source 필터를 통과한 유일 매칭만 DB 원장·누적 금액에 반영한 뒤 완료 DM을 보낸다. 길드 태그 역할은 `GUILD_MEMBER_UPDATE`와 재색인 결과에 따라 별도로 동기화하며 외부 금전 이체와는 무관하다.

별도 금전 지급 kill switch, dry-run 지급 모드, 일일 금전 지급 한도는 운영 필수 조건으로 두지 않는다. 긴급 중지는 전체 systemd 서비스 중지로 처리한다.

## 7. 입금 매칭 정책

### 7.1 일치 규칙

사용자 입력과 Toss 알림은 다음 방식으로 비교한다.

```text
amount_krw == parsed_amount_krw
depositor_name_normalized == parsed_depositor_name_normalized
```

금액은 원 단위 정수로 비교한다. 소수점·부동소수점·통화 문자열은 사용하지 않는다.

입금자명은 원문을 보존하되 비교용 값만 정규화한다.

- UTF-8 유효성 검사
- 앞뒤 공백 제거
- 연속 공백 축약
- 허용되지 않은 제어 문자 제거가 아닌 거부
- 라틴 문자에 한해 설정된 대소문자 정책 적용

한국어 이름의 자모 분해나 임의 유사도 비교는 하지 않는다. 한 글자라도 다른 이름은 일치하지 않는 것으로 처리한다.

### 7.2 중복 및 모호성

다음 경우에는 자동 반영을 차단하거나 `REVIEW`로 남긴다.

- Push ID가 이미 처리된 경우
- 직접 미러 이벤트에 안정적인 Push ID가 없는 경우. fingerprint로 재전달 중복을 제한하고, 필수 필드·source 필터·유일 매칭을 만족하면 수신 시각 기준으로 자동 반영한다.
- 주문이 만료된 경우
- 입금자명만 같고 금액이 다른 경우
- 금액만 같고 입금자명이 다른 경우
- 같은 이름과 금액을 가진 대기 주문이 2개 이상인 경우
- 알림에서 이름 또는 금액을 두 개 이상 추출할 수 있는 경우
- 허용된 Toss 앱 필터를 통과하지 못한 경우
- 알림이 입금이 아닌 출금·취소·잔액 변경 알림인 경우

모호한 이벤트는 `REVIEW` 상태로 저장하고 관리자 조회 대상에 남긴다. 사용자에게는 자동 반영이 완료되지 않았다는 안내만 보낸다.

### 7.3 주문 만료

주문에는 `expires_at`을 저장한다. 주문 만료 시간은 30분으로 확정하며 설정 파일에는 `ORDER_TTL_SECONDS=1800`으로 기록한다. 만료된 주문은 매칭 대상에서 제외하며, 나중에 도착한 알림은 자동 반영하지 않고 검토 대상으로 남긴다.

## 8. SQLite 데이터 모델

### 8.1 기본 DB

초기 구현은 설치 루트의 `shared/data/vending.db`를 독립적으로 사용한다. 원격 서버에 이미 존재하는 다른 서비스의 DB에는 테이블을 추가하거나 데이터를 읽거나 쓰지 않는다.

금전 관련 데이터는 SQLite WAL과 `FULL` 동기화를 사용한다. Windows 릴리스는 프로젝트 내부에서 검증한 SQLite 3.53.4 DLL을 선택적으로 포함한다. Linux AArch64 릴리스는 운영 서버의 `libsqlite3.so.0` ABI 호환성을 verifier로 확인한 뒤 사용한다.

WAL에서는 여러 reader가 동시에 동작해도 writer는 하나뿐이다. 따라서 native 런타임은 `busy_timeout=5000`과 직렬화된 writer 경계를 함께 적용한다. [SQLite WAL](https://www.sqlite.org/wal.html)

권장 초기 설정은 다음과 같다.

```sql
PRAGMA journal_mode=WAL;
PRAGMA synchronous=FULL;
PRAGMA foreign_keys=ON;
PRAGMA busy_timeout=5000;
```

### 8.2 테이블

```text
support_totals
- discord_id TEXT PRIMARY KEY
- cumulative_support_krw INTEGER NOT NULL DEFAULT 0 CHECK(cumulative_support_krw >= 0)
- created_at INTEGER NOT NULL
- updated_at INTEGER NOT NULL

deposit_orders
- order_id TEXT PRIMARY KEY
- discord_id TEXT NOT NULL
- depositor_name_input TEXT NOT NULL
- depositor_name_normalized TEXT NOT NULL
- requested_amount_krw INTEGER NOT NULL CHECK(requested_amount_krw > 0)
- status TEXT NOT NULL
- created_at INTEGER NOT NULL
- expires_at INTEGER NOT NULL
- matched_push_id TEXT UNIQUE
- matched_amount_krw INTEGER
- matched_at INTEGER
- dm_status TEXT NOT NULL
- payment_dm_status TEXT NOT NULL DEFAULT 'PENDING'

push_events
- push_id TEXT PRIMARY KEY
- push_created_at INTEGER
- push_modified_at INTEGER
- package_name TEXT
- application_name TEXT
- title TEXT
- body_hash TEXT
- parsed_depositor_name TEXT
- parsed_depositor_name_normalized TEXT
- parsed_amount_krw INTEGER
- processing_status TEXT NOT NULL
- consumed_order_id TEXT
- received_at INTEGER NOT NULL

ledger
- ledger_id INTEGER PRIMARY KEY AUTOINCREMENT
- order_id TEXT NOT NULL UNIQUE
- discord_id TEXT NOT NULL
- amount_krw INTEGER NOT NULL CHECK(amount_krw > 0)
- reason TEXT NOT NULL
- created_at INTEGER NOT NULL

settings
- key TEXT PRIMARY KEY
- value TEXT NOT NULL
```

원본 Push 본문은 계좌·잔액·실명 정보가 포함될 수 있으므로 기본적으로 해시와 파싱 결과만 보존한다. 원본 보존이 필요하면 별도 암호화 저장과 보존 기간을 정의한다.

### 8.3 자동 반영 트랜잭션

입금 매칭은 반드시 다음 작업을 하나의 `BEGIN IMMEDIATE` 트랜잭션으로 처리한다.

```text
BEGIN IMMEDIATE

push_events에 push_id 삽입
삽입 결과가 0이면 중복 이벤트로 종료

동일한 normalized 이름·금액·유효기간의 대기 주문 조회
정확히 한 건이 아니면 REVIEW로 기록하고 종료

deposit_orders.status = PAID
deposit_orders.matched_push_id = push_id
ledger에 order_id 기준 지급 기록 삽입
support_totals.cumulative_support_krw 증가
push_events.processing_status = CONSUMED
push_events.consumed_order_id = order_id

COMMIT
```

중간 단계에서 오류가 발생하면 `ROLLBACK`한다. 지급 성공 후 Discord DM이 실패해도 이미 지급된 원장을 되돌리지 않으며, DM만 재시도한다.

SQLite의 `BEGIN IMMEDIATE`와 prepared statement, bind, step, finalize 흐름을 사용해 SQL 문자열에 사용자 입력을 직접 연결하지 않는다. SQLite는 동시에 하나의 쓰기 트랜잭션만 허용한다.

모든 지급 작업은 하나의 DB writer 또는 직렬화된 작업 큐를 통과시킨다. [SQLite Transactions](https://www.sqlite.org/lang_transaction.html), [SQLite C Interface](https://www.sqlite.org/cintro.html)

## 9. 독립 누적 후원 금액

봇은 새 `vending.db` 안에서 사용자별 누적 후원 금액만 관리한다. 원격 서버에 이미 존재하는 다른 봇의 꽃잎·골드·포인트·상점·거래 데이터와 통합하지 않는다.

현재 버전의 누적 후원 금액과 자동 반영은 다음 용도로만 제공한다.

- 사용자에게 누적 금액 표시
- 관리자에게 입금·지급 원장 제공
- 사용자별 총 후원 금액 집계
- 유일하게 매칭된 입금의 `PAID` 상태·원장·누적 금액 반영과 지급 완료 DM

Discord 역할 동기화는 `DISCORD_GUILD_TAG_ROLE_ID`가 설정된 Python/Linux 경로에서만 수행한다. 계좌 송금과 재화 환전은 제공하지 않으며, 역할 API 오류는 다음 Gateway 재색인에서 보정한다.

현재 버전에서는 다음 기능을 제공하지 않는다.

- 누적 금액 사용
- 상품 교환
- 다른 사용자에게 양도
- 차감 또는 환불 명령
- 기존 봇의 재화로 환전

누적 후원 금액은 원화 정수로 저장하며, 정상 입금이 확정될 때만 증가한다. 차감·환불·사용 기능은 추후 별도 요구사항으로 추가한다.

## 10. 어셈블리 모듈 구조

현재 저장소의 native 소스는 플랫폼별 파일로 분리되어 있다.

```text
src/
  main.asm
  main_linux_aarch64.S
  native_runtime_windows_x64.asm
  native_runtime_linux_aarch64.S
  native_service_windows_x64.asm
  native_network_windows_x64.asm
  native_network_linux_aarch64.S
  amount_parser_windows_x64.asm
  amount_parser_linux_aarch64.S
  name_normalizer_windows_x64.asm
  name_normalizer_linux_aarch64.S
  ledger_windows_x64.asm
  ledger_linux_aarch64.S
  sqlite_windows_x64.asm
  sqlite_linux_aarch64.S
  platform_windows_x64.asm
  platform_linux_aarch64.S
  kernel32.def
  yul_core_windows_x64.def

vending_machine/
  cli.py, config.py, database.py, service.py
  discord_*.py, gateway_protocol.py, pushbullet.py
  amount_parser.py, name_normalizer.py, matching.py, ledger.py

db/
  schema.sql
  migrations/

fixtures/
  pushbullet/

tests/
  test_*.py

deploy/
  yul-vending-machine.service
  install.sh, verify-release.sh, healthcheck.sh
  backup.sh, restore.sh, rollback.sh, sqlite-maintenance.sh
```

모듈의 현재 책임은 다음과 같다.

- `main*.asm|S`: 플랫폼별 진입점과 종료 경로
- `native_runtime_*.asm|S`: 설정·CLI·SQLite·주문·Push/Gateway 실행 흐름. Linux 파일은 길드 태그 색인·상태 메시지 복구도 담당
- `native_service_windows_x64.asm`: Windows native 서비스의 스레드·콘솔 종료 조정
- `native_network_*.asm|S`: TLS 전송, HTTP Upgrade, WebSocket framing과 외부 API 경계
- `amount_parser_*.asm|S`, `name_normalizer_*.asm|S`: 금액 파싱·입금자명 정규화
- `ledger_*.asm|S`: 주문 매칭, 트랜잭션, 원장, 누적 후원 금액
- `sqlite_*.asm|S`: SQLite 동적 로딩과 prepared statement ABI
- `platform_*.asm|S`: 운영체제 syscall·파일·프로세스·동기화 경계
- `vending_machine/`: Python 기준 구현, fixture 처리와 parity/회귀 테스트. `discord_gateway.py`와 `discord_messages.py`는 길드 태그 상태·로그 payload를 생성

## 11. 운영 배포안

원격 서버의 기존 Yul 서비스 트리와 분리해 다음 구조를 사용한다.

```text
<install-root>/
├── current -> releases/<release-id>
├── releases/
└── shared/
    ├── config/
    │   └── vending.ini
    ├── data/
    │   └── vending.db
    ├── backups/
    └── logs/
```

systemd 서비스 이름은 `yul-vending-machine.service`로 한다. 기존 원격 서비스는 본 프로젝트의 배포나 롤백 대상에 포함하지 않는다.

대상 서버의 기존 Yul 서비스와 같은 root 실행 형식을 사용하되, 이 프로젝트의 릴리스 무결성 검사와 sandbox 제한을 유지한다.

```text
[Unit]
Description=Yul Vending Machine
ConditionArchitecture=arm64
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=<install-root>/current
ExecStartPre=<install-root>/current/yul-vending-machine --config <install-root>/shared/config/vending.ini validate-config
ExecStart=<install-root>/current/yul-vending-machine --config <install-root>/shared/config/vending.ini run
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
KillMode=control-group
LimitNOFILE=4096
LimitCORE=0
StandardOutput=journal
StandardError=journal
SyslogIdentifier=yul-vending-machine
NoNewPrivileges=yes
CapabilityBoundingSet=
AmbientCapabilities=
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=read-only
PrivateDevices=yes
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectKernelLogs=yes
ProtectControlGroups=yes
ProtectClock=yes
ProtectHostname=yes
ProtectProc=invisible
ProcSubset=pid
LockPersonality=yes
MemoryDenyWriteExecute=yes
RestrictNamespaces=yes
RestrictRealtime=yes
RestrictSUIDSGID=yes
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
SystemCallArchitectures=native
KeyringMode=private
RemoveIPC=yes
PrivateMounts=yes
ReadWritePaths=<install-root>/shared
UMask=0077

[Install]
WantedBy=multi-user.target
```

현재 systemd unit의 `ExecStartPre`는 `validate-config`이고, `ExecStart`는 `<install-root>/current/yul-vending-machine --config <install-root>/shared/config/vending.ini run`이다.

Linux AArch64 릴리스는 Python 운영 패키지를 포함하지 않는다. Gateway·REST·Pushbullet WebSocket·polling·패널·DM 재시도·주문·길드 태그 관측을 native 경로에서 실행한다. Windows x64 native launcher는 결제·Push·Gateway 경계의 개발·테스트 검증에만 사용하며 Windows 서비스 관리자 등록은 운영 절차에 포함하지 않는다.

운영 시작 전 `validate-config`가 데이터베이스 경로, 양의 주문 TTL, `AUTO_CREDIT=1`, Discord·Pushbullet 인증 및 ID, Push stream, Toss source·정규식, 은행 표시 정보를 모두 확인한다. 누락되면 `run`과 systemd pre-start가 실패한다.

native DB 오픈 경로는 schema 적용 후 `payment_dm_status`와 `interaction_id` unique index를 추가·검증하고 `PRAGMA user_version=3`을 기록하는 멱등 migration을 실행한다.

릴리스에는 `RELEASE.json`과 `SHA256SUMS`가 포함되며, installer는 root 소유 릴리스·AArch64 ELF·심볼릭 링크 부재·해시를 검증한다. 관측·장애·수동 백업/복원·롤백 절차는 `docs/operations-runbook.md`를 따른다.

Discord와 Pushbullet은 외부로 나가는 TLS 연결만 사용하므로 새 수신 포트는 열지 않는다. 계좌번호와 토큰이 포함된 설정 파일은 0600으로 제한하고, 로그에는 토큰·전체 계좌번호·원본 알림 본문을 남기지 않는다.

## 12. 설정 항목

초기에는 JSON보다 어셈블리에서 안전하게 읽기 쉬운 `key=value` 형식을 사용한다.

```text
DISCORD_BOT_TOKEN=
DISCORD_APPLICATION_ID=
DISCORD_GUILD_ID=
DISCORD_PANEL_CHANNEL_ID=
DISCORD_GUILD_TAG_LOG_CHANNEL_ID=
DISCORD_GUILD_TAG_STATUS_CHANNEL_ID=
DISCORD_GUILD_TAG_ROLE_ID=
DISCORD_ADMIN_USER_ID=
DISCORD_GATEWAY_URL=wss://gateway.discord.gg/?v=10&encoding=json
DISCORD_INTENTS=1
PUSHBULLET_ACCESS_TOKEN=
PUSHBULLET_STREAM_URL=wss://stream.pushbullet.com/websocket
BANK_NAME=
BANK_ACCOUNT_NUMBER=
BANK_ACCOUNT_HOLDER=
BANK_PACKAGE_NAME=viva.republica.toss
BANK_APPLICATION_NAME=토스
BANK_TITLE_PREFIX=
BANK_TITLE_PATTERN=^[0-9][0-9,]*원\s*입금$
BANK_AMOUNT_PATTERN=([0-9][0-9,]*)원\s*입금
BANK_NAME_PATTERN=^([^\r\n→,()]{1,100}?)\s*→\s*내 토스뱅크 통장$
ORDER_TTL_SECONDS=1800
MIN_AMOUNT_KRW=
MAX_AMOUNT_KRW=
AUTO_CREDIT=1
CASE_INSENSITIVE_LATIN=0
DATABASE_PATH=<install-root>/shared/data/vending.db
```

토큰과 실제 계좌번호는 저장소에 넣지 않는다. `config.example.ini`의 Toss source·패턴은 동작 확인용 계약 예시이고 길드 태그 채널·역할 ID는 공란이므로, 운영 환경의 값을 별도 설정 파일에 주입한다.

## 13. 테스트 계획

### 13.1 단위 테스트

- 금액에 쉼표가 있는 경우
- 금액에 통화 문자가 포함된 경우
- 음수·소수·0·범위 초과
- UTF-8이 잘못된 입금자명
- 앞뒤 공백과 연속 공백
- 정상 이름과 한 글자 다른 이름
- Push ID 중복
- 동일 이름·금액의 주문 2개
- 만료된 주문
- 출금 알림과 잔액 알림
- 금액만 일치
- 이름만 일치
- 이름과 금액 모두 일치

### 13.2 DB 장애 테스트

- 지급 트랜잭션 중 프로세스 강제 종료
- COMMIT 전 재시작
- COMMIT 후 DM 실패
- `SQLITE_BUSY`와 재시도
- 손상되지 않은 WAL 복구
- 백업 복원 후 원장과 누적 후원 금액 검증

### 13.3 Discord 통합 테스트

- 패널 게시
- 버튼 클릭으로 모달 표시
- 모달 제출과 입력 오류
- ephemeral 응답
- DM 성공·실패·재시도
- Gateway heartbeat와 resume
- 재시작 후 패널 ID와 대기 주문 복구
- `GUILD_MEMBER_UPDATE`의 길드·태그 상태 검증과 착용·해제 로그 중복 방지
- 초기·`READY`·`RESUMED` 멤버 재색인과 표시 이름 변경
- 상태 임베드 단일성, 삭제된 상태 메시지의 재사용·재생성

### 13.4 Pushbullet 통합 테스트

- `nop` 무시
- `tickle` 후 `modified_after` 조회
- `type=push` 직접 미러 이벤트의 즉시 처리
- `iden`·시간 필드가 없는 직접 미러 이벤트의 fingerprint 및 수신 시각 기준 자동 반영
- 여러 Push의 순서 뒤바뀜
- 같은 Push 재전달
- 예상하지 않은 앱의 알림
- Toss fixture에서 이름·금액 추출
- 유일하게 매칭되는 이벤트의 자동 반영
- 모호하거나 불일치하는 이벤트의 REVIEW 기록

### 13.5 어셈블리 전용·운영 경계 검증

- `validate-config`가 필수 설정 누락·빈 문자열·`AUTO_CREDIT` 오설정을 거부하는지 확인
- 기존 `user_version=1` DB에 `payment_dm_status`와 `interaction_id`를 추가하고 unique index 및 `user_version=3`으로 올리는 native migration 확인
- Windows x64 native launcher에서 malformed JSON, 17KB 입력, 중복 fixture, SIGTERM·콘솔 종료 계약을 확인
- Linux AArch64 소스에서 bounded scratch buffer, native signal·reconnect·fragmentation 경로가 유지되는지 정적 계약 테스트
- Linux AArch64 길드 태그 상태의 settings 영속화, `GUILD_MEMBERS` intent 추가, 상태 메시지 검색·복구 계약을 확인
- Windows x64 native가 길드 태그 키·이벤트를 지원 범위에 포함하지 않는지 확인
- 최종 AArch64 ELF와 `yul-core.so`를 비공개 AArch64 검증 호스트에서 `file`·`ldd`·CLI smoke test로 확인
- 릴리스 `RELEASE.json`·`SHA256SUMS`·root 소유·심볼릭 링크 부재·systemd pre-start 설정 검증 확인

로컬 환경에서 AArch64 native를 실행할 수 없으면 승인된 AArch64 검증 호스트 또는 `qemu-aarch64`를 사용한다. 테스트 수와 실행 결과는 각 릴리스의 CI·검증 기록에 남기되, 내부 호스트 정보는 공개하지 않는다.

Windows x64 native는 만료 주문을 `PENDING`으로 유지하고 `expires_at` 조건으로만 매칭에서 제외하며, Python·Linux AArch64의 `EXPIRED` 상태 전이와 혼합하지 않는다.

### 13.6 실입금 테스트

실제 Toss 입금을 처음 받을 때는 다음 순서로 진행한다.

1. 운영과 분리된 테스트 계정 또는 최소 금액 사용
2. Pushbullet 원본을 로컬 fixture로 수집
3. 파서 결과와 수동 거래 내역 대조
4. 중복·다른 금액·다른 이름 테스트
5. `AUTO_CREDIT=1`과 실제 source 필터를 유지한 상태에서 유일 매칭 시 `PAID`·원장·누적 금액·완료 DM 확인
6. 완료 DM 상태와 원장·누적 금액의 일치 확인

## 14. 오류와 알림 정책

사용자에게는 내부 오류 상세를 노출하지 않는다.

```text
ORDER_CREATED
ORDER_VALIDATION_FAILED
ORDER_EXPIRED
PUSH_RECEIVED
PUSH_DUPLICATE
PUSH_UNSUPPORTED_SOURCE
PUSH_PARSE_FAILED
MATCH_NOT_FOUND
MATCH_AMBIGUOUS
PAYMENT_COMMITTED
DM_PENDING
REVIEW_REQUIRED
```

관리자 로그에는 주문 ID, Push ID, 처리 상태, 오류 코드, 시각만 남기고 토큰·전체 계좌번호·원본 알림 본문은 남기지 않는다.

## 15. 위험 요소와 대응

| 위험 | 대응 |
| --- | --- |
| Pushbullet 토큰 유출 | 0600 설정, 로그 마스킹, 배포 시 토큰 별도 주입 |
| 알림 형식 변경 | 허용 source 필터, fixture 회귀 테스트, 필터 미설정·불일치 이벤트 지급 차단 |
| Push 중복 수신 | `push_id` UNIQUE와 원장 `order_id` UNIQUE |
| 동일 이름·금액 주문 중복 | 정확히 한 건일 때만 자동 반영, 그 외 REVIEW |
| 알림 지연·순서 역전 | Pushbullet 서버 `modified` 커서와 주문 만료 시간 사용 |
| Discord DM 차단 | 지급과 DM을 분리하고 DM 재시도 상태 저장 |
| ARM64 배포 불일치 | Windows x64와 Linux AArch64를 별도 빌드하고 checksum 검증 |
| 원격의 다른 서비스와 혼동 | 별도 경로·별도 DB·별도 systemd 서비스 사용 |
| SQLite WAL 동시성 | writer 직렬화, `busy_timeout`, 패치된 SQLite 버전 검증 |
| 계좌 알림 위조 | 은행 앱 source 필터, 정확한 이름·금액 매칭, 모호한 이벤트 REVIEW, DB 원장·누적 금액 반영과 완료 DM만 수행 |
| Server Members Intent 누락·멤버 목록 불완전 | Portal privileged intent와 최소 권한을 확인하고 시작·`READY`·`RESUMED` REST 재색인으로 상태를 보정 |
| 상태 임베드 삭제·재연결 중 중복 생성 | 상태 채널·메시지·멤버 목록을 settings에 저장하고 Linux native는 최근 봇 메시지를 찾아 재사용 |

## 16. 구현 이력과 남은 관문

아래 단계는 현재 저장소에 반영된 구현 이력이다. 실서비스의 Push 테스트 이벤트와 장시간 운영 관찰은 배포 환경에서 별도로 승인·기록하며, 상세한 공개 검증 절차는 `docs/native-transition.md`에 정리한다.

### 0단계: 기획 확정(완료)

- 누적 후원 금액 표시 문구와 조회 방식 결정
- Windows NASM과 Linux AArch64 LLVM 어셈블러 확정
- 주문 만료 시간 30분과 금액 범위 결정
- 관리자 명령과 운영 서버의 Discord 채널 결정

### 1단계: 플랫폼 및 DB 코어(완료)

- Windows x64와 Linux AArch64 빌드 골격
- 동적 라이브러리 로더
- SQLite 스키마와 마이그레이션
- 입금자명·금액 정규화와 매칭 단위 테스트
- 중복 방지와 지급 원장 트랜잭션

### 2단계: Discord(완료)

- Gateway 연결
- heartbeat·resume
- 관리자의 패널 게시 명령
- 버튼과 모달
- ephemeral·DM
- 재시작 복구
- `뀨?` 길드 태그 착용·해제 로그와 현재 착용자 상태 임베드
- 시작·`READY`·`RESUMED` 멤버 재색인과 상태 메시지 복구

### 3단계: Pushbullet(완료)

- WebSocket 연결과 재연결
- tickle 처리와 `modified_after` 조회
- source 필터
- fixture 기반 Toss 파서
- REVIEW 큐

### 4단계: 결제 연동(완료)

- 정확한 이름·금액 매칭
- SQLite 지급 트랜잭션
- 지급 완료 DM
- 검토 목록 조회 명령
- 누적 후원 금액 조회 명령

### 5단계: 운영 배포(정식 전환 완료, 실입금 관찰 대기)

- AArch64 릴리스 생성
- 설치 루트의 `current` 링크와 `shared/` 디렉터리 구성
- 기존 서버 서비스와 같은 root systemd 실행 및 sandbox
- DB 백업·복원
- 서비스 재시작·resume 테스트
- 승인된 실입금 테스트(대기)

## 17. 운영 전 확인과 남은 결정

핵심 기능 구현은 완료되었으며, 다음 항목은 운영자 확인 또는 후속 기능 결정으로 남아 있다.

1. 승인된 실제 Toss Push 테스트 이벤트를 사용한 수신·자동 매칭과 장시간 reconnect 관찰 시점
2. 운영 설정에 주입된 Discord 서버·패널·길드 태그 채널·관리자 ID와 최소·최대 금액 정책의 최종 확인
3. 길드 태그를 사용할 경우 Server Members Intent 승인, 멤버 조회 권한과 상태 메시지 단일성 확인
4. 길드 태그 역할을 사용할 경우 필요한 `Manage Roles` 권한·역할 순서·재시도·회수 정책

계좌번호, Discord 토큰, Pushbullet 토큰은 문서나 저장소에 공유하지 않는다. 모두 로컬 설정 파일 또는 운영 비밀 주입으로 처리한다.

## 18. 배포 관문

- 실제 운영은 Linux AArch64에서만 수행하고 Windows x64는 개발·테스트 전용으로 둔다. 두 launcher 모두 Python 프로세스를 생성하지 않으며, AArch64 최종 링크는 프로젝트 내부에서 해시 검증한 glibc/libdl sysroot를 사용한다.
- `AUTO_CREDIT=1`은 지원된 유일 매칭 흐름에서만 사용한다. 생성·수정 시각이 없는 direct mirror도 수신 시각 기준 유일 매칭이면 자동 반영하며, 실제 발생 시각을 확인하지 않는 위험을 운영자가 관리한다. 역할 동기화는 결제와 독립적으로 수행한다.
- 운영 환경은 `docs/operations-runbook.md`의 release/shared 구조와 `docs/native-transition.md`의 검증 게이트를 사용한다. 릴리스·커밋·거래 수치와 실제 운영 상태는 별도 배포 기록으로 관리한다.
- 실제 Push 이벤트가 없을 때는 수신·cursor 전진·자동 매칭을 성공으로 보고하지 않는다. 백업과 복원은 운영자가 승인한 시점에 수동 실행하며, Windows 서비스 실행기는 운영 범위에 포함하지 않는다.
