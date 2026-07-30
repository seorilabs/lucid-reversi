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
- full-board game over and winner
- 18-byte board codec fixture and round trip
- save DTO round trip
- 플레이어 착수와 AI 응수를 한 라운드로 되돌리는 Undo 및 저장 DTO round trip
- 난이도별 승/무/패 통계 저장 round trip, 기존 세이브 기본값, 게임오버 1회 집계

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
- Undo smoke는 빈 이력·입력 잠금·AI 응수 대기 중 버튼 비활성화와 플레이어+AI 라운드 복원 후 이력 소진 상태를 확인한다.
- 결과 통계 smoke는 동일 게임오버 오버레이를 반복 갱신해도 현재 난이도 전적이 1회만 증가하고 ko/en 전환과 새 게임에서 누적값이 유지되는지 확인한다.
- 설정 smoke는 manual load, 힌트 toggle, 미구현 진동 toggle이 노출되지 않고, 설정 패널 내부 터치는 열린 상태를 유지하며 패널 외부 터치는 닫히는지 확인한다.
- 사운드 smoke는 `sound=false` 설정에서 착수 사운드가 생성되지 않는지 확인한다. 실제 음색은 Web smoke에서 착수/뒤집힘/대량 뒤집힘 상황으로 확인한다.
- Android device smoke는 `npm run build:android:smoke`로 만든 local debug APK를 연결 기기에 설치한 뒤, process/window focus, `SCREEN_ORIENTATION_PORTRAIT`, crash 로그 없음, 실제 `screencap`을 확인한다.

## Release

- Google Play, App Store, AppsInToss, Firebase blocker를 분리해 inventory한다.
