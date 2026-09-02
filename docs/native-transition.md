# Native 전환 검증과 배포 결정

이 문서는 Python 기준 구현에서 native launcher로 운영 경계를 옮길 때 확인해야 할 계약과 검증 순서를 설명합니다. 특정 운영 호스트·SSH 키·릴리스 ID·자격 증명과 운영 데이터는 저장소에 기록하지 않습니다. 아래 원격 예시는 `<ops-user>@<private-host>`와 `<private-key-file>`을 실제 환경에 맞게 바꿔 사용하세요.

## 운영 결정

| 경로 | 역할 | 운영 사용 |
| --- | --- | --- |
| Python | 기준 구현, fixture, 동작 비교, 회귀 테스트 | 운영 프로세스로 사용하지 않음 |
| Windows x64 native | 어셈블리 launcher·WinHTTP 경계·콘솔 종료 검증 | 개발·테스트 전용 |
| Linux AArch64 native | syscall·libcurl/OpenSSL·systemd 경계와 전체 서비스 | 운영 프로파일 |

native launcher는 Python 프로세스를 생성하지 않습니다. Linux 서비스는 systemd가 launcher를 직접 실행하고, 설정·SQLite·Discord Gateway·Pushbullet 루프를 native 경로에서 처리합니다.

## 기능 경계

두 native 경로는 결제·Push·Discord 상호작용에 대해 다음 동작 계약을 공유합니다.

- 설정 파일 파싱과 필수값·범위·Toss source·패턴 fail-closed 검증
- SQLite schema 적용과 payment_dm_status 마이그레이션
- 주문 생성, 만료 확인, 금액·입금자명 정규화
- Push JSON 파싱, 앱·패키지·제목 필터, fingerprint 기반 중복 방지
- 직접 미러 fingerprint는 최상위 payload의 모든 bounded 필드를 포함하고 `iden`, `created`, `modified`, `active`, `dismissed` lifecycle 필드만 제외합니다.
- Windows x64와 Linux AArch64 native는 동일한 원시 바이트 payload에 같은 FNV-1a namespace를 사용하며, Python의 canonical SHA-256은 별도 namespace입니다.
- native fingerprint는 lifecycle 이외 필드의 키 순서·공백·직렬화가 달라지면 달라질 수 있습니다.
- Discord interaction은 application·guild·panel channel 범위를 exact 비교하고, 게시된 패널의 message ID를 settings에 영속화해 button interaction의 message ID까지 확인합니다. interaction ID는 주문에 unique하게 저장하며 replay payload가 원래 사용자·이름·금액과 다르면 fail-closed합니다.
- 이름·금액 후보가 body/title 또는 여러 지원 라벨에서 두 건 이상 발견되면 값이 같더라도 모호한 이벤트로 격리하고 자동 반영하지 않습니다.
- `created`와 `modified`가 모두 없는 direct mirror도 현재 수신 시각에 유효한 유일 주문과 이름·금액이 맞으면 자동 반영합니다. 실제 발생 시각은 검증하지 않으므로 오래된 이벤트가 새 주문에 반영될 위험을 운영자가 관리해야 합니다.
- RECEIVED, UNSUPPORTED, PARSE_FAILED, 중복, 모호 매칭 기록
- BEGIN IMMEDIATE 안의 주문 상태 변경·원장·누적 금액·Push 소비 상태 커밋
- Discord Gateway Hello·Identify·READY·heartbeat·resume·재연결
- Discord REST 명령 등록·패널·interaction 응답·DM과 제한된 재시도
- Pushbullet WebSocket·tickle·modified_after polling과 cursor 영속화
- SIGINT/SIGTERM 시 Gateway·Push 소켓과 자식·스레드 정리

Windows x64 native는 만료된 주문을 별도 `EXPIRED` 상태로 전환하지 않고 `PENDING`으로 유지합니다. 매칭 SQL에서 `expires_at`을 확인해 만료 주문을 자동 반영 대상에서 제외하며, 만료 이벤트는 검토 상태로 남길 수 있습니다. Python 및 Linux AArch64 기준 구현의 만료 상태 전이와 혼동하지 않도록 운영 DB를 Windows native와 교차 운영하지 마세요.

길드 태그 관측은 플랫폼별 범위가 다릅니다.

| 경로 | 길드 태그 지원 |
| --- | --- |
| Python | 로그 채널, 단일 상태 임베드, 설정된 역할, 재시작·`READY`·`RESUMED` 재색인 |
| Windows x64 native | 미지원. 결제·Push·Gateway 경계 회귀만 검증 |
| Linux AArch64 native | `GUILD_MEMBER_UPDATE`, REST 멤버 재색인, 상태 메시지 재사용·복구, 설정된 역할 |

태그 역할 ID를 사용하는 Python·Linux 런타임도 `GUILD_MEMBERS` intent 비트(`2`)를 자동으로 더합니다. 역할 동기화에는 `Manage Roles` 권한과 대상 역할보다 높은 봇 역할 순서가 필요합니다.

태그 채널을 사용하는 Python·Linux 런타임은 `GUILD_MEMBERS` intent 비트(`2`)를 자동으로 더합니다. Discord Developer Portal의 Server Members Intent 활성화와 대상 길드의 멤버 조회·메시지·임베드 권한은 별도로 필요합니다.

Linux native는 상태 채널·멤버 목록을 SQLite `settings`에 저장하고, 시작·`READY`·`RESUMED` 때 다시 색인합니다. 저장된 메시지가 삭제되면 최근 상태 채널 메시지에서 봇이 만든 상태 임베드를 찾아 재사용한 뒤, 찾지 못할 때만 새 메시지를 만듭니다.

상세 조건은 [Discord 길드 태그 관측](discord-guild-tags.md)을 참고하세요.

Linux AArch64에는 Gateway TLS·HTTP Upgrade 단독 연결을 확인하는 `gateway-probe`가 추가됩니다. Python의 `panel` 명령은 기준 구현에만 존재하며, native `run`은 `/입금패널` interaction을 처리합니다.

## ABI와 런타임 의존성

src/의 플랫폼별 어셈블리는 다음 계층으로 나뉩니다.

- amount_parser_*, name_normalizer_*: 입력 검증과 UTF-8 정규화
- ledger_*: 주문 매칭, 트랜잭션, 원장, 누적 금액
- native_network_*, native_service_*: HTTP/WebSocket과 서비스 수명주기
- native_runtime_*, platform_*: 설정·SQLite·syscall/OS 경계
- main*: launcher 진입점과 명령 라우팅

Linux 최종 링크는 대상 glibc ABI와 호환되는 AArch64 sysroot 및 libcurl.so.4, libsqlite3.so.0, OpenSSL 런타임을 필요로 합니다. Windows는 WinHTTP·BCrypt와 검증된 SQLite DLL을 사용합니다. 빌드 도구와 sysroot는 전역 설치 대신 .tools/ 아래에 준비합니다.

## 검증 순서

1. Python 전체 회귀를 실행합니다.

   ~~~powershell
   python -m unittest discover -s tests -v
   ~~~

2. Windows x64 launcher와 공통 코어를 빌드한 뒤 native CLI·프로토콜 계약 테스트를 실행합니다.

   ~~~powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File build/build.ps1
   powershell -NoProfile -ExecutionPolicy Bypass -File build/build-core.ps1
   python -m unittest tests.test_native_cli tests.test_native_protocol_contracts -v
   ~~~

3. Linux AArch64 산출물을 빌드하고 file, ldd, deploy/verify-release.sh로 아키텍처·동적 의존성·해시·보안 속성·설정 fail-closed를 확인합니다.

   ~~~powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File build/build-aarch64.ps1
   powershell -NoProfile -ExecutionPolicy Bypass -File build/create-release.ps1 -ReleaseId <release-id> -Architecture linux-aarch64
   ~~~

4. 로컬에 AArch64 실행 환경이 없으면 승인된 AArch64 호스트 또는 qemu-aarch64에서 native CLI와 `gateway-probe`를 실행합니다. 원격 임시 디렉터리는 작업마다 새로 만들고, 테스트 후 정확히 삭제합니다.

   Windows x64와 Linux AArch64 native 모두 첫 공개 릴리스의 검증 대상입니다. Windows는 x64 회귀·경계 검증, Linux는 운영 프로파일 검증을 담당합니다.

5. GitHub Actions의 `native-windows-x64`와 `native-linux-aarch64` job을 릴리스 필수 status check로 지정합니다.

Windows job은 portable toolchain으로 Windows launcher·공통 core·Linux AArch64 release를 빌드하고 Windows native 회귀를 실행합니다.

Linux job은 release package를 ARM64 runner에서 `deploy/verify-release.sh`, `panel-text`, `init-db`, 주문 생성·조회 smoke와 native 회귀 테스트로 검증합니다.

ARM64 runner 또는 `libcurl.so.4`·`libsqlite3.so.0` ABI를 제공할 수 없으면 Linux 실행 gate가 완료되지 않은 것으로 기록합니다.

## AArch64 원격 CLI 검증 예시

아래 예시는 공개 저장소에서 사용할 수 있는 일반 절차입니다. `<ops-user>`, `<private-host>`, `<private-key-file>`을 실제 검증 환경에 맞게 교체합니다. `config.example.ini`만 사용하고 실제 토큰·계좌번호·운영 DB·Push 원문은 전송하지 않습니다.

~~~powershell
$sshKey = "<private-key-file>"
$sshTarget = "<ops-user>@<private-host>"
$remoteDir = "/tmp/yul-vending-machine-$([guid]::NewGuid().ToString('N'))"

ssh -i $sshKey $sshTarget "mkdir -p $remoteDir/data"
scp -i $sshKey "build/linux-aarch64/yul-vending-machine" "$($sshTarget):$remoteDir/yul-vending-machine"
scp -i $sshKey "config.example.ini" "$($sshTarget):$remoteDir/config.example.ini"
ssh -i $sshKey $sshTarget "chmod +x $remoteDir/yul-vending-machine"
ssh -i $sshKey $sshTarget "cd $remoteDir && ./yul-vending-machine --config ./config.example.ini panel-text"
ssh -i $sshKey $sshTarget "cd $remoteDir && ./yul-vending-machine --config ./config.example.ini init-db"
ssh -i $sshKey $sshTarget "cd $remoteDir && ./yul-vending-machine --config ./config.example.ini create-order smoke-user smoke-name 10"
ssh -i $sshKey $sshTarget "cd $remoteDir && ./yul-vending-machine --config ./config.example.ini support-total smoke-user"
ssh -i $sshKey $sshTarget "rm -rf $remoteDir"
~~~

실제 run 통합 검증은 제한된 자격 증명과 승인된 테스트 이벤트가 있을 때만 수행합니다. Gateway READY·heartbeat·resume·통제된 재연결, Push cursor의 존재와 단조 증가, SIGTERM 뒤 자식·소켓 정리를 확인하되 토큰·응답 본문·Push 원문은 출력하지 않습니다.

길드 태그를 활성화한 경우 초기 멤버 재색인, 태그 착용·해제 이벤트, `RESUMED` 재색인, 상태 메시지 단일성·재사용도 확인합니다. 실제 Push가 0건이면 cursor 전진이나 자동 매칭 성공으로 보고하지 않습니다.

## 릴리스 게이트

- [ ] Python 회귀와 native 계약 테스트가 통과했다.
- [ ] Windows x64 산출물이 Python 기준 구현과 주요 상태 전이를 일치시킨다.
- [ ] Linux AArch64 ELF가 PIE·RELRO·BIND_NOW·non-executable stack·strip 검사를 통과했다.
- [ ] RELEASE.json source commit과 SHA256SUMS를 생성하고 검증했다.
- [ ] 대상 서버의 loader·glibc·libcurl·SQLite ABI 호환성을 확인했다.
- [ ] 운영 설정 없이 validate-config가 실패하고, 완전한 임시 설정으로만 성공한다.
- [ ] Toss canonical fixture와 중복·파싱 실패·모호 매칭 회귀를 확인했다.
- [ ] 길드 태그를 사용할 경우 Server Members Intent, 채널 권한, 초기·`READY`·`RESUMED` 재색인과 상태 메시지 복구를 확인했다.
- [ ] Windows x64 native 전용 검증 설정에는 지원하지 않는 길드 태그 키를 넣지 않았고, Linux/Python 지원 범위를 문서화했다.
- [ ] Windows native의 만료 주문이 의도적으로 `PENDING`으로 유지되고, `expires_at` 조건으로만 매칭에서 제외되는지 확인했다.
- [ ] Windows/Linux native가 같은 canonical fixture에서 동일한 FNV-1a golden fingerprint를 생성하는지 확인했다.
- [ ] 직접 미러 fingerprint의 broad payload·lifecycle 제외·native/Python digest namespace 차이·원시 직렬화 민감성을 릴리스 노트에 기록했다.
- [ ] 생성 시각·수정 시각이 없는 direct mirror도 수신 시각 기준 유일 매칭이면 자동 반영한다는 정책과 오래된 이벤트 오반영 위험을 문서화하고, 양 native·Python 회귀 테스트로 고정했다.
- [ ] Discord interaction의 application·guild·channel·panel message 범위와 interaction ID replay 계약을 양쪽 native에서 확인했다.
- [ ] systemd ExecStartPre, sandbox, ReadWritePaths, UMask를 점검했다.
- [ ] 실제 장기 실행 검증에서 비밀값과 원문을 로그·artifact에 남기지 않았다.
- [ ] 원격 임시 디렉터리와 캡처 파일을 삭제했다.

운영 설치·healthcheck·백업·복원·롤백은 [운영 Runbook](operations-runbook.md), 키별 의미와 기본값은 [설정 가이드](configuration.md)를 기준으로 합니다.
