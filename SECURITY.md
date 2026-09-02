# 보안 정책

이 프로젝트는 Discord 자격 증명, Pushbullet 토큰, 은행 표시 정보, 입금 알림과 SQLite 원장을 다룰 수 있습니다. 길드 태그 관측을 활성화하면 Discord 사용자 ID와 표시 이름이 로그·상태 임베드·SQLite 설정에 포함될 수 있으므로, 보안 문제와 개인정보 노출은 공개 이슈보다 비공개 신고를 우선해 주세요.

## 취약점 신고

1. GitHub 저장소의 **Security → Advisories → Report a vulnerability**가 활성화되어 있으면 비공개 취약점 신고를 생성합니다.
2. 해당 기능을 사용할 수 없으면 저장소 소유자가 별도로 안내한 비공개 연락처를 사용합니다. 공개 이슈·PR·Discussions에는 재현 절차, 토큰, 계좌번호, Push 원문을 올리지 마세요.
3. 신고에는 영향 범위, 재현 단계, 영향을 받는 커밋 또는 버전, 완화 방법을 포함하되 실제 비밀값과 개인정보는 포함하지 않습니다.

신고를 받으면 재현 가능성, 영향 범위, 완화·수정 계획을 확인한 뒤 신고자와 공개 시점을 조정합니다. 공개 일정은 수정본과 사용자의 운영 환경을 고려해 별도로 합의합니다.

## 보안 경계

- `DISCORD_BOT_TOKEN`과 `PUSHBULLET_ACCESS_TOKEN`은 설정 파일·환경 변수·비밀 저장소에서만 주입합니다.
- 운영 설정과 SQLite DB는 릴리스 디렉터리 밖에 두고, 운영 계정만 읽을 수 있도록 권한을 제한합니다.
- 로그와 CI artifact에는 토큰, Authorization 헤더, 계좌 전체 번호, Push 원문을 남기지 않습니다.
- Push source 필터와 입금자명·금액 단일 매칭을 모두 통과하지 않은 이벤트는 자동 반영하지 않습니다.
- `created`와 `modified`가 모두 없는 direct mirror도 현재 수신 시각 기준으로 자동 반영할 수 있습니다. 실제 입금·알림 발생 시각은 확인하지 않으므로 오래된 이벤트가 새 주문에 반영될 위험을 운영자가 관리해야 합니다.
- 원본 Push 본문은 DB에 저장하지 않고 해시와 파싱 결과만 저장합니다.
- 자동 반영은 DB의 `PAID`·원장·누적 금액·이벤트 소비 상태 기록과 완료 DM에 한정됩니다. 외부 송금은 수행하지 않습니다.
- 길드 태그 기능은 `GUILD_MEMBER_UPDATE`와 멤버 목록을 관측해 지정 채널에 상태를 표시하고, 설정된 역할을 태그 착용 상태에 맞춰 부여·회수합니다. 상태 목록에는 사용자 ID와 표시 이름이 포함될 수 있으므로 로그·백업·운영 티켓에는 필요한 범위로만 보관합니다.
- 태그 채널을 사용할 때는 `GUILD_MEMBERS` privileged intent를 Discord Developer Portal에서 명시적으로 승인하고, 봇을 대상 길드와 필요한 채널에만 배치합니다. 역할 동기화에는 `Manage Roles` 권한과 대상 역할보다 높은 봇 역할 순서가 필요합니다.
- systemd 운영 unit은 설정 사전 검증, `NoNewPrivileges`, `ProtectSystem`, `PrivateTmp`, `ReadWritePaths`, `UMask` 등의 제한을 적용합니다.

## 운영자가 확인할 사항

- 토큰이 노출되면 로그·쉘 history·CI 기록까지 확인하고 즉시 폐기·재발급합니다.
- 운영 Toss 형식이 바뀌면 fixture를 마스킹해 추가하고, `PARSE_FAILED`·`UNSUPPORTED`·중복·모호 매칭 회귀를 먼저 확인합니다.
- timestamp 없는 direct mirror 자동 반영을 사용할 경우 Pushbullet direct stream의 지연·재전송과 주문·원장 기록을 함께 관찰합니다.
- DB 이상이 의심되면 원본을 삭제하지 말고 서비스를 중지한 뒤 무결성 확인 백업으로 복구합니다.
- 길드 태그 상태를 사용할 경우 멤버 조회·로그·상태 채널 권한이 최소 범위인지, 상태 메시지와 `settings` 백업에 실제 사용자 메타데이터가 포함되는지 확인합니다.
- 전체 자동 반영을 긴급 중지해야 할 때는 설정값을 임의로 바꾸지 말고 systemd 서비스를 중지합니다. 현재 `AUTO_CREDIT=0` 또는 dry-run 모드는 지원하지 않습니다.
- 공개 배포 전에는 [GitHub 공개 배포 체크리스트](docs/public-release-checklist.md)로 Git 이력, fixture, CI artifact와 유지보수 문서를 함께 검토합니다.

세부 절차는 [운영 Runbook](docs/operations-runbook.md)과 [설정 가이드](docs/configuration.md)를 참고하세요.
