## 변경 내용

<!-- 무엇을 바꾸었고 왜 필요한지 적어 주세요. -->

## 검증

- [ ] `python -m unittest discover -s tests -v`
- [ ] `python -m unittest tests.test_native_cli tests.test_native_protocol_contracts -v` 또는 실행 불가 사유 기록
- [ ] 변경한 아키텍처의 native 빌드·검증 결과 기록

## 데이터·보안 확인

- [ ] 실제 토큰·계좌번호·Push 원문·운영 DB를 포함하지 않음
- [ ] fixture의 개인정보를 마스킹함
- [ ] schema/migration 변경 여부를 설명함
- [ ] 설정·운영 문서를 갱신함

## 참고 사항

- 알려진 제한, 호환성 영향, 후속 작업을 적어 주세요.
