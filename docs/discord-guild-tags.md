# Discord 길드 태그 관측

Linux AArch64 native와 Python 기준 구현은 Discord의 `GUILD_MEMBER_UPDATE` 이벤트를 이용해 지정한 길드의 `뀨?` 길드 태그 상태를 관측합니다. 이 기능은 입금 매칭·누적 후원 금액과 독립된 운영 편의 기능이며, 태그 착용 상태에 따라 설정된 Discord 역할을 자동으로 부여·회수합니다.

## 지원 범위

| 런타임 | 변경 로그 | 현재 착용자 상태 | 재시작·resume 재색인 |
| --- | :---: | :---: | :---: |
| Python 기준 구현 | 지원 | 지원 | 지원 |
| Linux AArch64 native | 지원 | 지원 | 지원 |
| Windows x64 native | 미지원 | 미지원 | 미지원 |

Windows x64 native는 결제·Gateway·Push 회귀 검증용으로 유지합니다. Windows native `run`에서 길드 태그 관측이 필요하면 Python 기준 구현 또는 Linux AArch64 운영 경로를 사용하세요.

## 설정

```ini
DISCORD_GUILD_ID=<길드 ID>
DISCORD_GUILD_TAG_LOG_CHANNEL_ID=<변경 로그 채널 ID>
DISCORD_GUILD_TAG_STATUS_CHANNEL_ID=<현재 착용자 채널 ID>
DISCORD_GUILD_TAG_ROLE_ID=
DISCORD_INTENTS=1
```

`DISCORD_GUILD_TAG_LOG_CHANNEL_ID`는 착용·해제 상태가 실제로 바뀐 경우에만 로그를 보낼 채널입니다. 최초 관측이나 동일 상태의 반복 이벤트는 로그를 만들지 않습니다.

`DISCORD_GUILD_TAG_STATUS_CHANNEL_ID`에는 "🏷️ `뀨?` 현재 착용자" 임베드 하나를 유지합니다. 임베드는 활성 사용자를 표시 이름 기준으로 정렬하고, 메시지 멘션은 허용하지 않습니다. 공개 템플릿은 채널 ID를 공란으로 두므로 운영 길드의 채널 ID를 직접 입력하세요.

`DISCORD_GUILD_TAG_ROLE_ID`는 태그 착용자에게 부여하고 태그 해제 시 회수할 역할 ID입니다. 역할 동기화를 사용하지 않으려면 빈 값으로 설정합니다. 공개 저장소에는 실제 역할 ID를 기록하지 마세요.

Python 또는 Linux AArch64에서 길드 태그 채널이나 역할 ID 중 하나라도 설정하면 런타임이 `GUILD_MEMBERS` intent 비트(값 `2`)를 기존 `DISCORD_INTENTS`에 추가합니다.

Discord Developer Portal에서도 해당 봇에 Server Members Intent를 활성화하고, 길드에서 멤버 조회·메시지 읽기·메시지 보내기·임베드 링크 권한을 부여해야 합니다. 역할 동기화를 사용하려면 봇에 `Manage Roles` 권한을 부여하고 대상 역할보다 봇의 최고 역할을 위에 배치해야 합니다.

운영 전에는 봇이 `DISCORD_GUILD_ID`에 실제로 가입되어 있는지 확인하세요. Windows x64 native는 이 기능과 intent 자동 추가를 제공하지 않습니다.

공개 설정 템플릿은 세 키를 공란으로 제공합니다. Linux native에서 관측과 역할 동기화를 끄려면 세 키를 설정 파일에 명시적으로 빈 값으로 적고 재시작하세요. Python `run`도 태그 키가 비어 있으면 태그 기능을 비활성화한 상태로 시작하므로, 태그를 사용할 때만 운영 길드의 채널·역할 ID를 입력하세요.

## 상태 판정

이벤트의 `user.primary_guild`가 다음 조건을 모두 만족할 때 해당 길드 태그를 착용한 것으로 판정합니다.

```text
primary_guild.identity_guild_id == DISCORD_GUILD_ID
primary_guild.identity_enabled == true
```

`primary_guild`가 없거나 길드 ID가 다르면 비활성으로 취급합니다. 이벤트의 `guild_id`가 설정된 길드와 다르면 무시합니다. 표시 이름은 `nick`, `global_name`, `username`, 사용자 ID 순으로 선택합니다.

## 초기화와 재연결

Linux native는 Gateway 연결 전에 한 번 길드 멤버 목록을 조회합니다. Python과 Linux native 모두 `READY`·`RESUMED` 이벤트 뒤에 REST API로 다시 조회해 현재 상태와 역할을 보정합니다.

멤버가 1,000명보다 많으면 Python은 `after` 커서로 페이지를 이어 받고, Linux native도 페이지 단위로 전체 목록을 색인합니다. 재색인은 누락된 이벤트를 보정하기 위한 것이며, 결제 DB의 주문·원장과는 별도입니다.

상태 임베드의 채널·메시지 ID와 마지막 활성 사용자 목록은 SQLite `settings`에 저장합니다.

```text
discord.guild_tag_status_channel_id
discord.guild_tag_status_message_id
discord.guild_tag_status_members
```

기존 메시지가 있으면 PATCH로 갱신하고, 메시지가 삭제되었거나 채널이 바뀌었으면 새 메시지를 만든 뒤 ID를 다시 저장합니다. Linux native는 상태 DB가 비어 있거나 메시지 ID가 유실된 경우에도 상태 채널의 최근 메시지에서 봇이 만든 동일한 상태 임베드를 찾아 재사용한 뒤, 찾지 못할 때만 새 메시지를 생성합니다.

## 장애·재시도

- 상태 채널 갱신이 실패하면 Python은 dirty 상태를 유지하고 주기적 재시도 루프에서 다시 보냅니다.
- Linux native는 REST·Gateway 재연결과 함께 저장된 마지막 상태를 유지하며, 다음 동기화가 성공하면 현재 멤버 목록과 역할 상태를 보정합니다.
- 변경 로그 전송 실패는 결제 트랜잭션이나 태그 상태 저장을 되돌리지 않습니다. 실패 원인은 토큰이나 원문 없이 운영 로그에서 확인합니다.
- Linux native에서 태그 관측을 긴급 중지하려면 서비스를 중지하거나 두 태그 채널을 비운 별도 검증 설정으로 재시작합니다. Python `run`도 태그 채널을 비우면 태그 기능만 중지하고 결제 처리는 계속합니다. 결제 자동 반영을 끄는 `AUTO_CREDIT=0` 모드는 제공하지 않습니다.

## 개인정보와 보안

상태 목록에는 Discord 사용자 ID와 표시 이름이 포함될 수 있습니다. 로그·이슈·fixture에 실제 멤버 목록을 복사하지 말고, 운영 DB와 설정 파일을 기존 결제 데이터와 같은 접근 통제로 보호하세요. 역할 API 오류가 발생하면 Gateway 오류 처리와 다음 재색인에서 다시 동기화를 시도합니다.

관련 설정은 [설정 가이드](configuration.md), 운영 확인 순서는 [운영 Runbook](operations-runbook.md), native 차이는 [Native 전환 검증](native-transition.md)을 참고하세요.
