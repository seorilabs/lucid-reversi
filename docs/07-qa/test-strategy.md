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
- 보드 좌표의 A-H/1-8 매핑, 셀 중심 정렬, 입력 무시, UI 폰트·테마별 muted 대비, 테마·언어 재구성, 6x6/10x10 확장
- 기보 좌표 helper `(2, 3) -> C4`, 시간순 흑백 돌·좌표 행, 누적 수/마지막 착수 진입점, 긴 이력 세로 스크롤, 결과 화면 진입, 게임·입력 상태 불변, 새 게임 초기화, ko/en 문구
- 결과 공유 버튼의 ko/en 라벨, 앱 이름·승패·최종 흑백 점수 payload, 전체 로케일 키, 공유 채널 부재 no-op
- 음악 설정 기본값·정규화·즉시 영속화, ko/en 설정 시트 토글, 저음량 OGG 반복 속성, Music/SFX 버스 분리, 효과음과 독립된 재생·즉시 정지, headless audio player 미생성
- 고정 기보 재생의 최대 뒤집기·최종 코너 점유·최대 돌 우세 기대값과 입력 불변성, 손상 기보 fail-closed, 종료 save 복원 및 ko/en/ja 결과 하이라이트 렌더
- 플레이 컨트롤 힌트 버튼의 ko/en 라벨, 현재 플레이어 기준 합법 최선 수 1곳 강조, 게임 상태 불변, 다음 보드 상호작용 시 해제, AI 사고·입력 잠금·게임 종료·AI 차례·패스 상태 비활성화
- 크기 태그 가변 board codec의 10x10 round trip과 기존 18-byte 8x8 fixture 복원
- save DTO round trip
- 고정 seed별 EASY/MEDIUM/HARD 동점 최선 수 분산, 동일 seed save/restore 재현, 모든 난이도의 최선 평가 유지
- 빈칸 8개 HARD 종반의 유일한 확정 승 수, 종국 돌 차이 평가, 강제 패스, EASY 비적용, 5초 실행 예산
- 개시·중반·종반 돌 개수 가중 전환, mobility 결정론, 적게 뒤집고 착수 가능수가 높은 MEDIUM/HARD 선택, EASY 1-ply 유지
- 6x6/8x8/10x10 X-스퀘어 좌표와 열린 코너 감점 유지·같은 색 코너 확보 후 감점 해제, 확보된 X-스퀘어를 선택하는 EASY 고정 국면, 기존 C-스퀘어 평가 회귀
- EASY/MEDIUM/HARD 사고 지연 기본값 순서, ±0.04초 흔들림 범위·실제 샘플 변동, 탐색 경과 시간 차감, 대기 중 턴 변경 시 계산된 수 폐기
- 설정 내부 AI·2인 선택, 로컬 모드의 흑·백 교대 입력과 AI 미개입, 패스 뒤 차례, 흑·백 결과, AI 통계 비집계, save/prefs 재시작 복원, AI 모드 회귀
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
- 현재 플레이어 색 반투명 고스트 돌의 합법수별 렌더, AI 상대 차례·입력 잠금 숨김, 로컬 2인 현재 차례 색, 모든 보드 테마 대비, 착수 뒤 실제 돌 전환과 기존 place 애니메이션 회귀
- 점유 돌 비율 기반 오프닝·미들·엔드게임 판정, 디스크 차 계수의 단계별 증가, 위치 계수의 국면별 스케줄·전 국면 양수 유지, 기존 코너 보상과 열린 X/C 스퀘어 페널티 부호 회귀
- 상태·기보 카운터·우세 미터의 단일 밴드 통합, 점수 스트립 턴 배지와 컨트롤 중복 카운터 제거, 상시 밴드 1개 감소, 보드 크기 유지, 착수 전후 상태·점수·우세·미터 갱신
- 일본어 번역 키 완전성, 일본어 기기 로케일 선택, 설정 세그먼트 전환·재실행 영속화, 한국어 missing-key fallback, 일본어 번들 폰트의 실제 글리프 범위
- 설정 내부 정보 섹션 위치, 앱 이름·iOS export 버전 일치, ko/en 라벨, 지원 이메일 URI, 미설정 개인정보 처리방침 숨김과 설정 시 외부 URI 호출
- 플레이 방법 시트의 최초 대국 1회 자동 표시, 4단계 이전/다음/완료 이동, 단계별 보드 셀 강조, 완료·건너뛰기 prefs 영속화, 설정 내부 재진입, ko/en 문구, 세로 스크롤, 닫기·외부 탭, 게임 상태 불변
- 퍼즐 카탈로그 3개의 board/current_turn/description/goal/difficulty 계약, 코너·종국 승패 목표 판정, 설정 내부 선택 모달, ko/en/ja 문구, `create_state_from_board` 진입, 결과 오버레이 재사용, 일반 save·전적·광고 격리와 표준 새 게임 복귀
- classic/arctic/ember 단색 보드 서피스·격자선 분리, 테마 파생 내부 하이라이트·그림자, 입력을 무시하는 4개 가이드 점, 테마·언어 재구성, classic 그린 우세, 테마별 색 구분, 힌트·hover·마지막 수 테두리 유지

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
- 결과 하이라이트 smoke는 고정 기보의 순수 재생 지표와 기존 결과 모달 내부 3개 라인, 저장된 종료 대국 복원, 로케일 전환, 기보 부재 시 카드 숨김을 확인한다.
- 전면 광고 smoke는 종료 세이브 복원 시 가드가 소진되어 있고 결과 오버레이 재진입에서 요청하지 않으며, 새 게임 후 다음 종료에서만 정확히 1회 요청하는지 프로브로 확인한다.
- 플립 smoke는 착수 원점에서의 거리 증가에 따라 연쇄 지연이 커지고, 회전 tilt 방향이 교차하는지 확인한다. 3개 돌 테마의 중간 색 전환·잔상·깜빡임은 Web 또는 실기기에서 육안 확인한다.
- 설정 smoke는 manual load와 미구현 추천 수 힌트 toggle이 노출되지 않고, 진동 toggle이 ko/en으로 노출·저장되며, 패널이 화면 안에 고정된 채 세로 스크롤하고 내부 터치는 열린 상태를 유지하며 패널 외부 터치는 닫히는지 확인한다.
- 플레이 방법 smoke는 최초 대국에서만 자동 표시되고 이후에는 설정에서 다시 열리며, 착수·뒤집기·패스·종료/승패 4단계의 이전/다음/완료 이동과 각 단계의 보드 셀 강조를 확인한다. 완료·건너뛰기 모두 재실행 자동 표시를 막고, ko/en 문구·세로 스크롤·닫기 버튼·시트 외부 탭·현재 보드와 수순 보존도 함께 검증한다.
- 퍼즐 smoke는 설정 패널 내부 진입점과 3개 선택 카드, ko/en/ja 제목·설명·목표, 고정 board/current_turn/난이도 로드, 코너·승리 목표의 성공/실패, 결과 오버레이의 일반 새 게임 복귀를 확인한다. 퍼즐 착수 중 `save_v1.json`과 난이도별 전적이 변하지 않고 전면 광고·리플레이가 비활성화되는지도 프로브로 검증한다.
- 착수 표시 smoke는 기존 설정 패널 안의 `show_moves` 토글만 사용하고, 기본 ON 및 기존 prefs 보정, OFF/ON 즉시 렌더, 재실행 복원, ko/en 라벨과 잘못된 착수 피드백을 확인한다.
- 고스트 돌 smoke는 보드 렌더 레이어 안에서만 현재 차례 색과 합법수 수만큼 반투명 프리뷰가 보이고, AI 상대 차례·입력 잠금에는 숨으며, 로컬 2인에서는 흑·백 현재 차례 색을 따르는지 확인한다. 모든 현행 보드 테마의 보조 링 대비와 착수 뒤 불투명 실제 돌·기존 place 애니메이션 전환도 함께 검증한다.
- 일본어 smoke는 기존 언어 세그먼트의 `日本語` 선택만 추가하고, `ko` 키와 `ja` 키의 일치, 주요 HUD·설정 문구, `prefs_v1.json` 재실행 복원, `ja_JP`/`ja-JP` 기기 로케일 선택, 한국어 fallback, M PLUS Rounded 1c 글리프 범위를 확인한다.
- 보드 크기 smoke는 6x6/8x8/10x10 세그먼트가 설정 패널 안에만 있고, 선택 즉시 해당 크기의 새 대국·동적 셀 크기·save/prefs를 재구성하는지 확인한다.
- 보드 좌표 smoke는 설정 내부 기본 ON 토글과 즉시 숨김·복원·재실행 영속화, 흑·백 플레이의 동일 A1-H8 매핑과 셀 중심 정렬, 셀 버튼 밖 `MOUSE_FILTER_IGNORE`, UI 폰트·3개 테마별 muted 대비, 테마·언어 전환 재생성, 6x6/10x10 라벨 확장을 확인한다.
- 보드 표면 smoke는 3개 테마의 서피스에서 파생한 inset highlight·shadow, 기본 8x8의 2·6번째 교차점 4곳, guide layer와 점의 `MOUSE_FILTER_IGNORE`, 테마·언어 전환 뒤 재생성, 기존 힌트·hover·마지막 수 강조를 확인한다.
- 기보 smoke는 상태 바 진입점과 결과 화면 버튼, 수순의 시간순 번호·돌 아이콘·흑백 라벨·표준 좌표, 긴 목록의 세로 스크롤, 패널 열기 전후 게임/입력 상태 불변, 새 게임 뒤 빈 상태, ko/en 문구를 확인한다.
- 결과 공유 smoke는 결과 오버레이 버튼, ko/en 공유 payload, 전체 로케일 키, headless 채널 부재 no-op을 확인한다. AppsInToss wrapper는 `npm run lint`로 `setClipboardText` 브리지 타입을 검증한다.
- 힌트 smoke는 플레이 컨트롤의 ko/en 버튼, 현재 플레이어 돌 기준 탐색 결과와 일치하는 단일 합법수 강조, 검색 전후 상태 불변, 다음 보드 상호작용 시 강조 해제, AI 사고·입력 잠금·게임 종료·AI 차례·합법수 없음 비활성화를 확인한다.
- AI 사고 지연 smoke는 난이도별 중앙 상수와 흔들림 경계, 반복 샘플 차이, 탐색 시간이 목표 시간을 넘으면 추가 대기 0, 대기 중 턴 변경 뒤 보드·수순 불변과 pending 해제를 확인한다.
- 로컬 2인 smoke는 설정 패널 안의 AI·2인 세그먼트, 상시 HUD 요소 미추가, 흑·백 사람 교대 착수, AI 자동 착수 중단, 패스와 흑·백 기준 결과, AI 전적 분리, 활성 대국·모드 재실행 복원, AI 복귀 후 정상 응수를 확인한다.
- 접근성 smoke는 100/115/130% 글자 배율과 모션 줄이기 toggle의 prefs 영속화, ko/en 라벨, tween 없는 최종 상태 렌더를 확인한다.
- 새 게임 확인 smoke는 진행 중 대국에서 새 게임·흑·백 버튼이 동일한 가드를 사용하고, 취소와 확인 결과 및 첫 수 전·종료 후 예외를 검증한다.
- 사운드 smoke는 `sound=false` 설정에서 착수 사운드가 생성되지 않는지 확인한다. 실제 음색은 Web smoke에서 착수/뒤집힘/대량 뒤집힘 상황으로 확인한다.
- 햅틱 smoke는 착수·일반 플립·대량 플립·게임 종료 profile이 구분되고, 게임 종료가 한 판에 1회만 요청되며, toggle OFF와 headless에서 안전하게 no-op 되는지 확인한다. 실제 진동 강도는 Android/iOS/AIT 실기기에서 확인한다.
- Android device smoke는 `npm run build:android:smoke`로 만든 local debug APK를 연결 기기에 설치한 뒤, process/window focus, `SCREEN_ORIENTATION_PORTRAIT`, crash 로그 없음, 실제 `screencap`을 확인한다.

## Release

- Google Play, App Store, AppsInToss, Firebase blocker를 분리해 inventory한다.
