# GitHub 공개 배포 체크리스트

이 문서는 저장소를 공개 GitHub 저장소로 미러링하거나 첫 릴리스를 만들 때 사용하는 점검표입니다. 체크리스트를 완료해도 실제 운영 승인이나 금융·개인정보 처리 적합성이 자동으로 보장되는 것은 아닙니다.

## 1. 공개 범위 확인

- [ ] 저장소 이름, 설명, 기본 브랜치와 공개 여부를 확인했다.
- [ ] `git ls-files`로 공개될 파일을 전부 검토했다.
- [ ] `git log -p --all`로 공개할 커밋 이력까지 확인했다. 과거 커밋에 비밀값이나 내부 인프라가 있으면 이력을 정리하거나 공개용 브랜치를 새로 만든다.
- [ ] `.local-vending.ini`, `config.ini`, `data/`, `*.db`, `build/` 산출물이 추적되지 않는지 확인했다.
- [ ] 실제 Push 원문, 계좌번호, 잔액, 개인정보가 fixture·문서·테스트 출력에 남아 있지 않다.
- [ ] 길드 태그 fixture·문서·테스트 출력에 실제 멤버 ID·표시 이름·운영 채널 ID가 남아 있지 않다.
- [ ] Windows x64와 Linux AArch64 native 산출물·소스·검증 결과를 공개 범위에 포함할지 확인했고, native 운영 범위와 테스트 전용 범위를 구분했다.

권장 점검 명령:

```powershell
git status --short --ignored
git ls-files
git grep -n -I -E 'token|secret|password|Authorization|account|private-key|172\.30\.|root@|private-host|install-root' -- . ':!docs/public-release-checklist.md'
```

검색 결과는 모두 사람이 확인합니다. 공개 저장소에는 내부 호스트, SSH 키 경로, 운영 설정, 자격 증명, DB, 실제 Push 원문을 남기지 않고 `<private-host>`, `<private-key-file>`, `<release-id>` 같은 placeholder만 사용합니다.


## 2. 문서와 라이선스

- [ ] README의 빠른 시작이 깨끗한 환경에서 재현된다.
- [ ] 설정 키와 명령이 [설정 가이드](configuration.md) 및 실제 CLI와 일치한다.
- [ ] [Discord 길드 태그 관측](discord-guild-tags.md)의 Python/Linux 지원 범위와 Windows native 제한이 README·설정·native 문서와 일치한다.
- [ ] 운영 호스트·계정·릴리스 ID가 모두 placeholder 또는 비공개 배포 기록으로 분리되어 있다.
- [ ] [기여 가이드](../CONTRIBUTING.md)와 [보안 정책](../SECURITY.md)을 검토했다.
- [ ] 저장소 루트의 [LICENSE](../LICENSE)에 Apache License 2.0 전문이 포함되어 있고, README에는 SPDX 식별자 `Apache-2.0`이 명시되며 패키지 메타데이터는 해당 `LICENSE` 파일을 가리킨다. 제3자 라이선스·NOTICE 필요 여부도 확인했다.
- [ ] 외부 서비스의 상표·API 사용 조건과 실제 운영 데이터 처리 고지를 검토했다.

## 3. 자동 검증

- [ ] Python 회귀 테스트를 통과했다.

  ```powershell
  python -m unittest discover -s tests -v
  ```

- [ ] native 경계 테스트를 통과했거나, 실행 불가 사유와 대체 검증 환경을 기록했다.

  ```powershell
  python -m unittest tests.test_native_cli tests.test_native_core tests.test_native_protocol_contracts -v
  ```

- [ ] 변경한 아키텍처의 native launcher를 빌드했다.
- [ ] Linux AArch64 릴리스라면 `deploy/verify-release.sh`로 해시·ELF·동적 의존성·설정 검증을 실행했다.
- [ ] GitHub Actions의 `native-windows-x64`와 `native-linux-aarch64` job이 skip 없이 통과했고, 두 status check를 기본 브랜치 보호와 첫 릴리스 workflow의 필수 항목으로 지정했다.
- [ ] Linux AArch64 job에서 `panel-text`, `init-db`, 주문 생성·조회 smoke와 `tests.test_native_cli`·`tests.test_native_core`·`tests.test_native_protocol_contracts`를 실제 ARM64 실행 환경에서 통과했다.
- [ ] Windows/Linux native가 동일한 canonical direct-mirror fixture에서 같은 FNV-1a golden fingerprint를 생성하는지 확인했다.
- [ ] 길드 태그를 포함한 릴리스라면 Server Members Intent와 상태 메시지 재색인·복구를 승인된 통합 환경에서 확인했다.
- [ ] `.github/workflows/ci.yml`의 모든 third-party action이 immutable commit SHA로 고정되어 있고, CI 로그와 artifact에 `.local-vending.ini`, `config.ini`, DB, 캡처 파일이 포함되지 않는다.

## 4. GitHub 저장소 설정

- [ ] 기본 브랜치 보호, 필수 status check, 최소 권한 토큰 정책을 설정했다.
- [ ] Dependabot 또는 사용 중인 보안 업데이트 방식을 결정했다.
- [ ] Issues·Discussions·Security Advisories의 공개 범위를 프로젝트 운영 방식에 맞게 설정했다.
- [ ] 실제 운영 토큰을 GitHub Actions secret에 넣지 않고, 통합 테스트에는 제한된 별도 자격 증명을 사용한다.
- [ ] CI 로그와 artifact에 설정 파일·Push 원문·DB가 포함되지 않는지 확인했다.

## 5. 첫 릴리스

- [ ] 변경 로그에 지원 플랫폼, 알려진 제한, 데이터 마이그레이션을 적었다.
- [ ] Windows native는 만료 주문을 `PENDING`으로 유지하고 `expires_at` 조건으로만 매칭에서 제외한다는 상태 정책을 변경 로그와 운영 문서에 적었다.
- [ ] 직접 미러 fingerprint가 lifecycle 5개를 제외한 bounded payload 필드를 폭넓게 포함하며, Windows/Linux native FNV namespace·Python SHA-256 namespace·원시 직렬화 민감성과 기존 DB 교체 시 중복 검토를 적었다.
- [ ] 생성 시각·수정 시각이 없는 direct mirror도 수신 시각 기준 유일 매칭이면 자동 반영한다는 정책과 오래된 이벤트 오반영 위험을 문서화하고, 양 native·Python 회귀 테스트로 고정했다.
- [ ] Discord interaction의 application·guild·channel·panel message 범위 검증과 interaction ID replay payload 일치 검증을 native 양쪽에서 확인했다.
- [ ] 릴리스 아카이브에 운영 설정·DB·토큰이 들어가지 않았는지 확인했다.
- [ ] `config.example.ini`의 Toss 계약과 공란인 길드 채널·역할 ID를 운영값으로 오인하지 않도록 문서와 릴리스 노트를 확인했다.
- [ ] SHA-256 manifest와 source commit을 릴리스 메타데이터에 기록했다.
- [ ] `SHA256SUMS`의 다이제스트를 릴리스와 다른 신뢰 경로로 전달·보관하고, `install-trusted.sh`/`rollback-trusted.sh`의 고정 호스트 진입점만 사용한다. 릴리스 내부 `install.sh`·`rollback.sh`를 root로 직접 실행하지 않는다.
- [ ] 설치 전 staging tree에서 외부 다이제스트, manifest 경로·중복·필수 service unit, ELF·설정 검증을 모두 통과했다.
- [ ] 운영 배포 전 [운영 Runbook](operations-runbook.md)의 백업·롤백·healthcheck 절차를 리허설했다.
- [ ] 공개 후에는 비밀값이 노출되지 않았는지 다시 검색하고, 문제가 있으면 즉시 폐기·재발급한다.
- [ ] README와 문서의 저장소 URL·릴리스 링크를 실제 GitHub 저장소 주소로 교체했다.
