# 운영 Runbook

이 문서는 Linux AArch64 native 서비스를 공개 저장소의 산출물에서 설치·관측·백업·롤백하는 일반 운영 절차입니다. 배포 스크립트의 기본 루트는 `/root/yul-vending-machine`입니다.

실제 호스트·SSH 개인 키·토큰·계좌번호·Push 원문·운영 DB는 이 문서나 저장소에 기록하지 않습니다. 다른 환경을 배포할 때는 아래 `<ops-user>`, `<private-host>`, `<release-id>` 표기를 해당 환경에 맞게 바꾸세요.

## 운영 범위와 전제

- 운영 프로파일은 Linux AArch64 native launcher + systemd입니다.
- Windows x64 native와 Python은 공개 릴리스의 개발·테스트·기준 동작 비교에 포함하며, 운영 프로세스는 Linux AArch64 native를 사용합니다.
- 릴리스 바이너리와 운영 설정·DB·백업은 서로 다른 경로에 둡니다.
- 자동 반영은 유일한 주문 매칭, SQLite 원장·누적 금액 기록, 완료 DM에 한정합니다. 외부 송금은 수행하지 않습니다.
- Windows x64 native는 만료된 주문의 저장 상태를 `PENDING`으로 유지합니다. 매칭 쿼리가 `expires_at > 현재 시각`을 요구하므로 만료 주문은 자동 지급되지 않으며, 상태를 `EXPIRED`로 바꾸는 별도 작업은 Windows 경로에서 수행하지 않습니다. Linux AArch64와 Python의 만료 상태 전이와 혼합 운영하지 마세요.
- 직접 미러 fingerprint는 최상위 payload의 bounded JSON 필드를 폭넓게 해시하되 `iden`, `created`, `modified`, `active`, `dismissed`는 lifecycle 필드로 제외합니다.
- Windows/Linux native는 같은 원시 바이트 payload에 같은 FNV-1a namespace를 사용하고 Python canonical SHA-256은 별도 namespace이므로, Python과 native 사이에서는 push ID 문자열을 공유하지 않습니다.
- native fingerprint는 lifecycle 이외 필드의 키 순서·공백·직렬화에 민감합니다. 같은 의미의 비정규화 payload가 다른 이벤트로 보일 수 있습니다.
- `created`와 `modified`가 모두 없는 direct mirror도 현재 수신 시각에 유효한 유일 주문과 이름·금액이 맞으면 자동 반영합니다. 실제 입금·알림 발생 시각은 확인하지 않으므로 오래된 이벤트가 새 주문에 반영될 위험을 운영자가 관리해야 합니다.
- 길드 태그 관측은 Linux AArch64 native 운영 범위에 포함할 수 있으며, 태그 상태에 따라 설정된 Discord 역할을 부여·회수합니다. Windows x64 native에는 이 기능이 없습니다.
- 운영 Toss 입력은 viva.republica.toss·토스 source와 10원 직접 미러 형식을 기준으로 합니다. 1원 검열 알림과 모호한 이벤트는 지급하지 않습니다.

## 디렉터리 레이아웃

설치 스크립트의 기본 루트는 `/root/yul-vending-machine`입니다. 현재 trusted 설치·롤백 진입점은 systemd unit과 일치하는 이 경로만 지원하며, 사용자 지정 루트는 거부합니다.

~~~text
/root/yul-vending-machine/
├── current -> releases/<release-id>
├── releases/<release-id>/
└── shared/
    ├── config/vending.ini
    ├── data/vending.db
    ├── backups/
    ├── logs/
    └── runtime/
~~~

releases/<release-id>는 검증 후 읽기 전용으로 보존하고, 서비스가 쓰는 영역은 shared/로 제한합니다. 설정과 DB는 운영 계정만 읽을 수 있는 0600 파일로 유지합니다.

## 배포 전 검증

1. Windows 또는 Linux 개발 환경에서 Python 회귀, native 빌드, native 경계 테스트를 실행합니다.

   ~~~powershell
   python -m unittest discover -s tests -v
   powershell -NoProfile -ExecutionPolicy Bypass -File build/build.ps1
   powershell -NoProfile -ExecutionPolicy Bypass -File build/build-core.ps1
   powershell -NoProfile -ExecutionPolicy Bypass -File build/build-aarch64.ps1
   python -m unittest tests.test_native_cli tests.test_native_protocol_contracts -v
   ~~~

2. 고유한 릴리스 ID로 Linux AArch64 릴리스를 만듭니다.

   ~~~powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File build/create-release.ps1 -ReleaseId <release-id> -Architecture linux-aarch64
   ~~~

3. 생성된 릴리스의 RELEASE.json, SHA256SUMS, launcher, yul-core.so, config.example.ini, deploy/ 파일을 확인합니다. 운영 설정·DB·토큰·실제 Push 원문은 릴리스에 포함하지 않습니다. `config.example.ini`의 Toss source는 운영 계약에 맞는지 확인하고, 공란인 길드 태그 채널·역할 ID는 실제 서버 값을 별도 설정 파일에 주입합니다.

4. 대상 서버의 loader, glibc, libcurl.so.4, libsqlite3.so.0, OpenSSL ABI가 빌드 산출물과 호환되는지 확인합니다.

5. 릴리스 디렉터리에서 deploy/verify-release.sh를 실행합니다. 이 verifier는 SHA-256, AArch64 ELF, 심볼릭 링크 부재, PIE·RELRO·BIND_NOW·non-executable stack, strip 상태와 설정 검증 smoke를 확인합니다.

설치·롤백에 사용할 `SHA256SUMS`의 SHA-256 다이제스트는 릴리스 디렉터리 밖에서 별도 신뢰 경로로 확인하고 보관합니다. `build/create-release.ps1`는 참고용 sidecar 다이제스트를 `build/releases/<release-id>.SHA256SUMS.sha256`에 생성하지만, 이 파일 자체를 릴리스와 같은 비신뢰 전송 경로에서 신뢰하지 마세요.

## 안전한 전송과 설치

원격 검증·설치에는 고유한 임시 디렉터리를 만들고, 실행 비트를 복원한 뒤 끝에서 정확히 삭제합니다.

릴리스가 제공하는 `deploy/install.sh`와 `deploy/rollback.sh`는 직접 root로 실행하지 않습니다. 둘은 의도적으로 실패하므로, 설치 호스트에 별도로 보호된 `deploy/install-trusted.sh`, `deploy/rollback-trusted.sh`, `deploy/verify-trusted-release.sh`를 복사해 사용해야 합니다.

이 고정 진입점은 릴리스 밖의 SHA256SUMS 다이제스트를 먼저 확인하고, root 전용 staging tree에서 같은 검증 결과를 사용합니다.

~~~powershell
$sshKey = "<private-key-file>"
$sshTarget = "<ops-user>@<private-host>"
$remoteDir = "/tmp/yul-vending-machine-$([guid]::NewGuid().ToString('N'))"

ssh -i $sshKey $sshTarget "mkdir -p $remoteDir"
scp -i $sshKey -r "build/releases/<release-id>" "$($sshTarget):$remoteDir/"
ssh -i $sshKey $sshTarget "chmod +x $remoteDir/<release-id>/yul-vending-machine $remoteDir/<release-id>/deploy/*.sh"
ssh -i $sshKey $sshTarget "sh $remoteDir/<release-id>/deploy/verify-release.sh $remoteDir/<release-id>"
~~~

검증 후에는 릴리스와 별도 신뢰 경로로 전달한 다이제스트 파일을 사용해 설치합니다.

~~~sh
sudo sh /usr/local/sbin/yul-vending-machine-install /path/to/<release-id> /etc/yul-vending-machine/trusted/<release-id>.SHA256SUMS.sha256
sudo install -o root -g root -m 0600 /path/to/vending.ini /root/yul-vending-machine/shared/config/vending.ini
sudo systemctl daemon-reload
sudo systemctl start yul-vending-machine.service
~~~

호스트에 보호된 설치 경로를 아직 만들지 않았다면 저장소의 `deploy/install-trusted.sh`, `deploy/rollback-trusted.sh`, `deploy/verify-trusted-release.sh`를 설치합니다.

대상 경로는 각각 `/usr/local/sbin/yul-vending-machine-install`, `/usr/local/sbin/yul-vending-machine-rollback`, `/usr/local/sbin/yul-vending-machine-verify-trusted-release`이며, root 소유·쓰기 금지로 설정합니다.

`/usr/local/share/yul-vending-machine/yul-vending-machine.service`에는 릴리스 밖에서 검토한 systemd unit을 root 소유·쓰기 금지로 보관합니다. trusted installer는 이 고정 진입점·unit만 사용하며 `YUL_INSTALL_ROOT` 같은 사용자 지정 루트는 지원하지 않습니다.

이 스크립트는 릴리스의 `SHA256SUMS`가 `/etc/yul-vending-machine/trusted/` 아래 외부 다이제스트와 일치하는지 확인한 뒤 staging을 검증·promote합니다. 설정이 완성되기 전에는 서비스를 시작하지 않습니다. 기존 `install.sh`를 릴리스에서 꺼내 `sudo sh`로 실행하는 절차는 폐기합니다.

## 시작 전 설정과 마이그레이션

~~~sh
/root/yul-vending-machine/current/yul-vending-machine --config /root/yul-vending-machine/shared/config/vending.ini validate-config
/root/yul-vending-machine/current/yul-vending-machine --config /root/yul-vending-machine/shared/config/vending.ini init-db
~~~

validate-config가 Discord·Pushbullet 인증, ID, Toss source·패턴, 은행 표시 정보, DB 경로, 주문 TTL, AUTO_CREDIT=1을 확인합니다. 실패하면 systemd ExecStartPre도 같은 이유로 시작을 거부합니다.

native DB 오픈 경로는 schema 적용 뒤 payment_dm_status와 interaction_id unique index를 확인하고 PRAGMA user_version=3을 멱등적으로 보장합니다.

Linux native에서 길드 태그를 사용하면 `DISCORD_GUILD_TAG_LOG_CHANNEL_ID`, `DISCORD_GUILD_TAG_STATUS_CHANNEL_ID`, `DISCORD_GUILD_TAG_ROLE_ID`를 설정합니다. 세 키의 기본값은 공란이며, 값을 설정하면 해당 기능이 활성화됩니다.

태그 관측과 역할 동기화를 끄려면 세 키를 비워 둡니다. 값을 설정하면 런타임이 `GUILD_MEMBERS` intent 비트(`2`)를 추가하므로 Developer Portal의 Server Members Intent를 켜고, 봇에 멤버 조회·메시지 전송·임베드 게시 권한을 부여합니다.

역할 동기화에는 `Manage Roles` 권한과 대상 역할보다 높은 봇 역할 순서가 필요합니다.

## Discord 길드 태그 확인

서비스를 처음 시작하거나 태그 설정을 바꾼 뒤에는 다음 동작을 운영 채널에서 확인합니다.

1. 상태 채널에 "🏷️ `뀨?` 현재 착용자" 임베드가 하나 생성되고, 현재 대상 길드의 활성 태그 사용자만 표시되는지 확인합니다. 판정 기준은 `primary_guild.identity_guild_id == DISCORD_GUILD_ID`와 `primary_guild.identity_enabled == true`입니다.
2. 태그를 착용·해제한 멤버의 `GUILD_MEMBER_UPDATE`가 로그 채널에 한 번만 기록되는지 확인합니다. 최초 색인과 같은 상태의 반복 이벤트는 로그를 만들지 않습니다.
3. 멤버의 표시 이름만 바뀌면 상태 임베드의 이름은 갱신되지만 착용·해제 로그는 추가하지 않는지 확인합니다.
4. Gateway가 `READY` 또는 `RESUMED`가 된 뒤 멤버 목록을 다시 색인하고, 상태 임베드가 최신 목록으로 갱신되는지 확인합니다. 재연결 후에도 상태 메시지가 중복 생성되지 않아야 합니다.
5. 상태 메시지를 삭제한 뒤 한 번 재색인해, Linux native가 최근 상태 채널 메시지에서 기존 봇 임베드를 찾아 재사용하고 찾지 못할 때만 새 메시지를 만드는지 확인합니다.
6. 태그 착용·해제에 따라 `DISCORD_GUILD_TAG_ROLE_ID` 역할이 각각 부여·회수되는지, 봇 역할 순서와 `Manage Roles` 권한이 충분한지 확인합니다.

점검 중 태그 채널 오류가 발생해도 결제 원장·누적 금액 트랜잭션을 되돌리는 기능은 없습니다. 오류 원인과 마지막 재연결 시각만 확인하고, 멤버 목록·응답 본문·토큰은 로그나 티켓에 복사하지 않습니다.

## 관측과 장애 대응

~~~sh
sudo systemctl status yul-vending-machine.service --no-pager
sudo journalctl -u yul-vending-machine.service -n 100 --no-pager
sudo journalctl -u yul-vending-machine.service -f
sudo sh /root/yul-vending-machine/current/deploy/healthcheck.sh
~~~

healthcheck.sh는 서비스 상태, 설정 검증, SQLite integrity_check, schema version, MainPID와 마지막 종료 상태를 출력합니다. 로그에는 토큰, Authorization 헤더, Push 원문, 계좌 전체 번호를 남기지 않습니다.

장애가 발생하면 다음 순서로 처리합니다.

1. systemctl status와 journal에서 native config invalid 또는 서비스 단계 오류를 확인합니다.
2. 설정·권한 오류이면 파일을 0600으로 교정하고 validate-config를 다시 실행합니다.
3. DB 오류이면 서비스를 중지하고 원본을 삭제하지 않은 채 무결성 확인 백업을 남깁니다.
4. Discord·Pushbullet 장애이면 재연결 간격, session/cursor 키의 존재, 마지막 오류만 확인합니다. 태그 상태가 활성화된 경우 `READY`·`RESUMED` 뒤 상태 임베드가 갱신되었는지도 확인합니다.

   응답 본문이나 토큰을 기록하지 않습니다.
5. 즉시 중지가 필요하면 sudo systemctl stop yul-vending-machine.service를 실행합니다.

## 수동 백업과 복원

백업·복원은 운영자가 승인된 시점에 수동 실행합니다. 자동 cron이나 systemd timer는 제공하지 않습니다.

~~~sh
sudo sh /root/yul-vending-machine/current/deploy/backup.sh
sudo sh /root/yul-vending-machine/current/deploy/backup.sh /root/yul-vending-machine/shared/backups/manual-<timestamp>.db
~~~

backup.sh는 SQLite online backup과 무결성 검사를 수행하고 0600 백업을 만듭니다. 복원 전에는 restore.sh가 pre-restore 백업을 만들고 선택한 파일의 무결성을 확인합니다.

~~~sh
sudo systemctl stop yul-vending-machine.service
sudo sh /root/yul-vending-machine/current/deploy/restore.sh /root/yul-vending-machine/shared/backups/manual-<timestamp>.db
sudo sh /root/yul-vending-machine/current/deploy/healthcheck.sh
~~~

복원 후 healthcheck가 실패하면 서비스를 중지하고 pre-restore 백업으로 되돌립니다. 백업 파일도 운영 데이터이므로 외부 공유와 로그 출력을 금지합니다.

## 롤백

이전 릴리스가 검증된 상태로 남아 있는지 확인한 뒤 release ID를 지정합니다.

~~~sh
sudo sh /usr/local/sbin/yul-vending-machine-rollback <previous-release-id> /etc/yul-vending-machine/trusted/<previous-release-id>.SHA256SUMS.sha256
sudo sh /root/yul-vending-machine/current/deploy/healthcheck.sh
~~~

`rollback-trusted.sh`는 릴리스 밖의 다이제스트와 대상 릴리스를 먼저 검증하고, 재시작 후 healthcheck를 통과하지 못하면 이전 current 링크로 복구합니다. 이전 바이너리가 현재 schema를 읽을 수 있는지 릴리스별 호환성 테스트를 통과한 경우에만 롤백하세요. 릴리스 내부 `rollback.sh`를 직접 root로 실행하지 않습니다.

## 보안과 종료 점검

- [ ] 릴리스와 설정·DB가 분리되어 있다.
- [ ] 설정·DB·백업 권한이 운영 계정 전용이다.
- [ ] validate-config와 healthcheck.sh를 통과했다.
- [ ] source 필터와 Toss canonical fixture를 확인했다.
- [ ] 길드 태그를 사용할 경우 Server Members Intent, 길드·로그·상태 채널 ID와 권한을 확인했다.
- [ ] 초기 색인, 태그 상태 변경, `READY`·`RESUMED` 재색인, 상태 메시지 재사용을 확인했다.
- [ ] 제한된 자격 증명으로 Gateway READY·heartbeat·resume·재연결과 Push cursor를 관찰했다.
- [ ] 실제 Push 이벤트가 0건이면 cursor 전진이나 자동 매칭 성공으로 보고하지 않았다.
- [ ] 검증용 원격 임시 디렉터리와 로컬 캡처 파일을 삭제했다.
- [ ] 중지 시 native 부모·Gateway 자식·WebSocket이 정리되는지 확인했다.
