# Test Strategy

## Core

- Device, network, Firebase emulator, native runtime 없이 실행되어야 한다.
- 빠르고 deterministic해야 한다.
- Phase 1 core는 `godot/scripts/reversi_engine.gd`이며 `godot/tests/test_runner.gd`에서 smoke를 실행한다.

## Covered Smoke Cases

- main scene 설정과 resource 존재
- initial BLACK valid moves
- first BLACK move flip and score
- opponent pass handling
- 패스 직후 상태 표시와 다음 정상 착수 뒤 현재 차례 표시 복귀, 누적 `pass_count` 유지, 기존 save 기본값
- full-board game over and winner
- 6x6/8x8/10x10 초기 합법수·뒤집기·평가와 board-size 설정 정규화
- 크기 태그 가변 board codec의 10x10 round trip과 기존 18-byte 8x8 fixture 복원
- save DTO round trip
- 고정 seed별 MEDIUM/HARD 동점 최선 수 분산, 동일 seed save/restore 재현, EASY 첫 정렬 수와 최선 평가 유지
- 빈칸 8개 HARD 종반의 유일한 확정 승 수, 종국 돌 차이 평가, 강제 패스, EASY 비적용, 5초 실행 예산
- 개시·중반·종반 돌 개수 가중 전환, mobility 결정론, 적게 뒤집고 착수 가능수가 높은 MEDIUM/HARD 선택, EASY 1-ply 유지
- 게임 save에서 환경설정 제외 및 기존 save 설정의 prefs 마이그레이션
- 게임 save 손상·삭제와 무관한 prefs 복원, 신규 설치 기본 prefs 생성, 설정 변경 즉시 저장
- 글자 배율이 score/status/result 텍스트와 설정 컨트롤에 적용·영속화되고 ko/en 접근성 라벨이 존재하는지 확인
- 모션 줄이기에서 착수·뒤집기·펄스 tween이 생성되지 않고 점수·합법수·차례·최종 보드가 즉시 갱신되는지 확인
- 진행 중 새 게임·돌 색 변경 확인, 취소 시 보드·수순 보존, 확인 시 초기화, 첫 수 전·종료 후 즉시 재시작, ko/en 문구 확인
- 플레이어 착수와 AI 응수를 한 라운드로 되돌리는 Undo 및 저장 DTO round trip
- 난이도별 승/무/패 통계 저장 round trip, 기존 세이브 기본값, 게임오버 1회 집계
- 종료 세이브 복원·결과 오버레이 재진입 시 전면 광고 0회, 실제 다음 판 종료 시 정확히 1회 요청
- 승리·패배 결과 카드와 승자 돌 강조가 대국당 1회만 실행되고, 무승부는 승자 강조 없이 등장하며, 모션 줄이기에서는 트윈 없이 기존 판정·점수가 표시되는지 확인
- 착수 표시 기본값·기존 prefs 보정, 설정 내부 ko/en 토글, OFF 즉시 숨김, 재실행 영속화, ON 복원, OFF 중 잘못된 착수 펄스 유지
- 일본어 번역 키 완전성, 일본어 기기 로케일 선택, 설정 세그먼트 전환·재실행 영속화, 한국어 missing-key fallback, 일본어 번들 폰트의 실제 글리프 범위
- 설정 내부 정보 섹션 위치, 앱 이름·iOS export 버전 일치, ko/en 라벨, 지원 이메일 URI, 미설정 개인정보 처리방침 숨김과 설정 시 외부 URI 호출
- 플레이 방법 시트의 최초 대국 1회 자동 표시와 prefs 영속화, 설정 내부 재진입, ko/en 착수·뒤집기·패스·종료/승패 문구, 세로 스크롤, 닫기·외부 탭, 게임 상태 불변
- classic/arctic/ember 단색 보드 서피스·격자선 분리, classic 그린 우세, 테마별 색 구분, 힌트·hover·마지막 수 테두리 유지

## Architecture

- `packages/product-core` scaffold import boundary를 확인한다.
- `godot/scripts/reversi_engine.gd`가 Node/UI/market SDK를 직접 참조하지 않는지 확인한다.
- platform SDK import는 adapter 계층으로 제한한다.

## Godot

- import pass를 먼저 수행한다.
- compile check는 Godot 로그의 `SCRIPT ERROR` / `ERROR:`를 실패로 처리한다.
- smoke scene은 `res://tests/test_runner.tscn`을 실행한다.
- UI smoke는 설정 메뉴가 기본적으로 숨겨져 있고, 보드 바로 아래 기세 strip이 compact/full-width이며, 새 게임/흑백 전환은 playfield에 있고 난이도/테마 같은 설정 controls는 메뉴를 열 때만 보이는지 확인한다.
- 모바일 터치 smoke는 주요 플레이 버튼이 56px 이상 높이로 노출되고, 설정 메뉴 안의 난이도/보드/돌/언어 선택이 작은 select box가 아니라 큰 세그먼트 버튼으로 보이는지 확인한다.
- Undo smoke는 빈 이력·입력 잠금·AI 응수 대기 중 버튼 비활성화, 플레이어+AI 라운드 복원 후 이력 소진, 게임 종료 후 결과 오버레이 종료·대국 재개를 확인한다.
- 결과 통계 smoke는 동일 게임오버 오버레이를 반복 갱신해도 현재 난이도 전적이 1회만 증가하고 ko/en 전환과 새 게임에서 누적값이 유지되는지 확인한다.
- 결과 연출 smoke는 기존 전체 화면 `result_overlay` 안에서 카드 등장과 승자 돌 펄스가 1회만 생성되고, 무승부·모션 줄이기·승/무/패 텍스트와 점수 표기를 함께 검증한다.
- 전면 광고 smoke는 종료 세이브 복원 시 가드가 소진되어 있고 결과 오버레이 재진입에서 요청하지 않으며, 새 게임 후 다음 종료에서만 정확히 1회 요청하는지 프로브로 확인한다.
- 플립 smoke는 착수 원점에서의 거리 증가에 따라 연쇄 지연이 커지고, 회전 tilt 방향이 교차하는지 확인한다. 3개 돌 테마의 중간 색 전환·잔상·깜빡임은 Web 또는 실기기에서 육안 확인한다.
- 설정 smoke는 manual load와 미구현 추천 수 힌트 toggle이 노출되지 않고, 진동 toggle이 ko/en으로 노출·저장되며, 설정 패널 내부 터치는 열린 상태를 유지하고 패널 외부 터치는 닫히는지 확인한다.
- 플레이 방법 smoke는 최초 대국에서만 자동 표시되고 이후에는 설정에서 다시 열리며, 착수·뒤집기·패스·종료/승패 4단계와 ko/en 문구, 세로 스크롤, 닫기 버튼·시트 외부 탭, 현재 보드·수순 보존을 확인한다.
- 착수 표시 smoke는 기존 설정 패널 안의 `show_moves` 토글만 사용하고, 기본 ON 및 기존 prefs 보정, OFF/ON 즉시 렌더, 재실행 복원, ko/en 라벨과 잘못된 착수 피드백을 확인한다.
- 일본어 smoke는 기존 언어 세그먼트의 `日本語` 선택만 추가하고, `ko` 키와 `ja` 키의 일치, 주요 HUD·설정 문구, `prefs_v1.json` 재실행 복원, `ja_JP`/`ja-JP` 기기 로케일 선택, 한국어 fallback, M PLUS Rounded 1c 글리프 범위를 확인한다.
- 보드 크기 smoke는 6x6/8x8/10x10 세그먼트가 설정 패널 안에만 있고, 선택 즉시 해당 크기의 새 대국·동적 셀 크기·save/prefs를 재구성하는지 확인한다.
- 접근성 smoke는 100/115/130% 글자 배율과 모션 줄이기 toggle의 prefs 영속화, ko/en 라벨, tween 없는 최종 상태 렌더를 확인한다.
- 새 게임 확인 smoke는 진행 중 대국에서 새 게임·흑·백 버튼이 동일한 가드를 사용하고, 취소와 확인 결과 및 첫 수 전·종료 후 예외를 검증한다.
- 사운드 smoke는 `sound=false` 설정에서 착수 사운드가 생성되지 않는지 확인한다. 실제 음색은 Web smoke에서 착수/뒤집힘/대량 뒤집힘 상황으로 확인한다.
- 햅틱 smoke는 착수·일반 플립·대량 플립·게임 종료 profile이 구분되고, 게임 종료가 한 판에 1회만 요청되며, toggle OFF와 headless에서 안전하게 no-op 되는지 확인한다. 실제 진동 강도는 Android/iOS/AIT 실기기에서 확인한다.
- Android device smoke는 `npm run build:android:smoke`로 만든 local debug APK를 연결 기기에 설치한 뒤, process/window focus, `SCREEN_ORIENTATION_PORTRAIT`, crash 로그 없음, 실제 `screencap`을 확인한다.

## Release

- Google Play, App Store, AppsInToss, Firebase blocker를 분리해 inventory한다.
