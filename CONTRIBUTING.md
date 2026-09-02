# 기여 가이드

버그 수정, 문서 개선, 테스트 보강을 환영합니다. 이 프로젝트는 Discord와 금융 알림을 연결하므로, 작은 변경도 재현 가능한 테스트와 민감정보 검토를 함께 제출하는 것을 기본으로 합니다.

## 개발 환경 준비

```powershell
git clone https://github.com/<owner>/<repo>.git
Set-Location yul-vending-machine
python -m unittest discover -s tests -v
```

Python 3.11 이상을 사용합니다. Python 런타임 의존성은 없으며, native 빌드가 필요할 때는 전역 설치 대신 프로젝트 내부 `.tools/`를 준비합니다.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File build/bootstrap-tools.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File build/build.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File build/build-core.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File build/build-aarch64.ps1
```

## 변경 원칙

- Python 기준 구현과 Windows/Linux native의 동작 계약을 함께 고려합니다.
- 금액은 원화 정수와 64비트 범위를 유지하고, 주문 상태·원장·누적 금액의 원자성을 깨뜨리지 않습니다.
- Push 이벤트는 source 필터, 입금자명·금액 단일 매칭, 중복 방지를 모두 통과해야 반영합니다.
- 자동 반영이 아닌 이벤트는 지급하지 않고 상태와 조회 결과로 남깁니다.
- 길드 태그 관측은 태그 상태를 기록·표시하고 설정된 역할을 동기화합니다. Python/Linux native와 Windows native의 지원 범위를 분리해 문서화합니다.
- 실제 Discord·Pushbullet·은행 데이터 없이도 재현할 수 있도록 fixture를 우선 추가합니다.
- 운영 경로를 변경하면 `deploy/` 스크립트, systemd unit, 운영 문서를 함께 검토합니다.
- 공개 문서와 예시는 placeholder를 사용하며, 내부 호스트·운영 채널 ID·실제 사용자 정보는 포함하지 않습니다.

## 테스트

변경 범위에 맞춰 다음 명령을 실행하고 PR 본문에 결과를 적어 주세요.

```powershell
python -m unittest discover -s tests -v
python -m unittest tests.test_native_cli tests.test_native_core tests.test_native_protocol_contracts -v
```

native 바이너리가 없는 로컬 환경에서는 native 테스트가 조건부로 건너뛸 수 있습니다. 공개 CI의 Windows x64·Linux AArch64 native job에서는 바이너리·core를 준비한 뒤 skip 없이 실행해야 합니다.

Linux AArch64 동작을 바꿨다면 AArch64 호스트 또는 `qemu-aarch64`에서 실제 launcher를 실행한 결과를 추가하세요. 원격 검증을 수행할 때는 고유한 임시 디렉터리를 사용하고, 종료 후 정확히 삭제하며, 제한된 자격 증명만 사용합니다.

길드 태그 관측을 변경할 때는 `GUILD_MEMBER_UPDATE` 상태 전이와 초기·`READY`·`RESUMED` 재색인을 계약 테스트로 확인합니다. 상태 메시지 재사용·복구도 검증합니다.

테스트 fixture에는 실제 멤버 ID·표시 이름·운영 채널 ID를 넣지 않고 마스킹된 값을 사용합니다. Developer Portal의 privileged intent 활성화는 CI가 아닌 승인된 통합 검증에서 확인합니다.

## Fixture와 민감정보

- Pushbullet fixture의 이름, 계좌번호, 잔액, 토큰, 실제 알림 본문은 마스킹합니다.
- fixture 파일에는 운영 데이터베이스나 자격 증명을 참조하는 경로를 넣지 않습니다.
- 캡처된 원문은 로컬 임시 파일로만 사용하고 커밋·이슈·PR·CI artifact에 업로드하지 않습니다.
- 실수로 비밀값을 커밋했다면 단순히 파일을 지우지 말고 해당 토큰을 즉시 폐기·재발급한 뒤 [보안 정책](SECURITY.md)에 따라 신고합니다.

## 문서 변경

설정 키, 명령, 데이터 모델, 릴리스 절차가 바뀌면 다음 문서의 링크와 예시를 함께 갱신합니다.

- `README.md`
- `docs/configuration.md`
- `docs/vending-machine-plan.md`
- `docs/operations-runbook.md`
- `docs/native-transition.md`
- `docs/discord-guild-tags.md`
- `docs/public-release-checklist.md`

공개 문서에는 `<owner>/<repo>`, `<private-host>`, `<release-id>` 같은 표기를 사용합니다. 운영 계정, SSH 키 경로, 자격 증명, 실제 수치는 공개 저장소에 기록하지 않습니다.

## 커밋과 Pull Request

커밋 제목은 변경 목적이 드러나도록 짧게 작성합니다. 예: `fix: duplicate push 처리`, `docs: 공개 배포 가이드 정리`.

PR에는 다음 내용을 포함해 주세요.

- 변경 목적과 영향 범위
- 실행한 테스트 명령과 결과
- native 또는 배포 경로를 바꾼 경우 검증한 아키텍처
- 길드 태그를 바꾼 경우 Python/Linux 지원 여부, Windows 제한, intent·권한 검토 결과
- 데이터베이스 schema/migration 변경 여부
- 문서·fixture·보안 검토 여부
- 알려진 제한이나 후속 작업

리뷰가 끝나기 전에는 실서비스 자격 증명, 운영 DB, 실제 Push 원문을 PR에 첨부하지 않습니다. 새로운 기능이나 운영 설정을 추가하면 관련 issue template과 문서 링크도 함께 확인하세요.
