# Product Spec

## 기본 정보

- Korean app name: 루시드 리버시
- English app name: Lucid Reversi
- App ID: `lucid-reversi`
- One-line pitch: 짧은 세션에 AI와 바로 둘 수 있는 모바일 리버시.
- Genre: Board game / Reversi / Single-player strategy
- Target audience: 클래식 보드게임을 짧게 즐기는 모바일 사용자
- Primary launch target: AppsInToss first
- Default locale: Korean (`ko`). English (`en`) and Japanese (`ja`) are supported in-app as secondary locales.
- Typography: Korean/Latin uses Do Hyeon, with M PLUS Rounded 1c as a bundled Japanese glyph fallback. Text outlines and high contrast preserve mobile HUD readability.
- Monetization: 광고 기반 후보. 게임 종료 전면 광고 hook은 Phase 2 이후 adapter에서 연결한다.
- Support email: `cs@seorilabs.com`

## 핵심 루프

- Primary loop: 색상과 난이도를 고르고 AI와 한 판을 둔다.
- Session length: 3-5분
- Progression: EASY, MEDIUM, HARD 난이도를 바꿔 반복 대국하고 난이도별 로컬 승/무/패 전적을 누적한다.
- Failure/retry model: 승패/무승부 후 즉시 새 게임을 시작한다. 진행 중인 대국에서는 새 게임이나 돌 색 변경 전에 초기화 확인을 받는다.
- Retention surface: 최근 대국 상태와 설정을 로컬 자동 저장/자동 복원한다.
- Localization: AppsInToss는 한국어를 기본으로 노출하고, 앱 내부 언어 선택에서 영어 또는 일본어로 전환할 수 있다. 일본어 기기 로케일의 신규 설치는 일본어를 선택한다.

## UX Direction

- Mobile playfield-first: 게임판, 점수, 차례, 착수 가능 위치, 돌 뒤집힘 애니메이션을 화면 중심 경험으로 둔다.
- Board-adjacent feedback starts immediately under the board: full-width advantage meter first, then one compact row for 새 게임, 선공/후공, 착수 가능 수.
- Non-gameplay controls live in the top-right settings menu: 난이도, 보드 크기, 사운드, 진동, 착수 표시, 보드/돌 테마, 언어, 글자 크기, 모션 줄이기, 플레이 방법, 정보. 플레이 방법은 착수·뒤집기·패스·종료/승패를 설명하는 4단계 스크롤 시트이며, 단계 이동 때 실제 보드 셀을 강조한다. 최초 대국에서 자동 표시하고 완료·건너뛰기·닫기를 한 뒤에는 다시 자동 표시하지 않으며 설정에서 언제든 다시 열 수 있다. 정보 섹션은 앱 이름·export와 동기화된 버전·지원 이메일을 표시하고, 개인정보 처리방침 URL이 확정되어 주입된 경우에만 링크를 노출한다. Mobile settings use large segmented buttons instead of select boxes, and tapping outside the settings panel closes it.
- In-play fun feedback should stay close to the board: a single theme-derived board surface with thin grid lines, last-move highlight, default-on legal move markers, midpoint color-swap disc flip with a placement-origin wave, placement sound, flip sound, big-flip sound, and a full-width advantage meter. Classic uses the traditional green Othello surface while Arctic and Ember derive their own surface/grid pair.
- 보드 상단과 왼쪽에는 셀 중심에 맞춘 열 문자와 행 숫자 좌표를 표시한다. 기본 8x8은 좌상단 A1부터 우하단 H8이며 6x6/10x10 보드에서는 A-F/1-6, A-J/1-10으로 확장한다. 좌표는 셀 버튼 밖에서 입력을 무시한다.
- 한 수 무르기는 보드 하단 컨트롤에서 플레이어 착수와 이어진 AI 응수를 되돌리며, 게임 종료 뒤에도 결과 오버레이를 닫고 대국을 재개할 수 있다.
- 게임 종료는 기존 전체 화면 결과 오버레이에서 카드 등장과 승자 돌 1회 펄스로 강조한다. 모션 줄이기에서는 정적 최종 결과만 즉시 표시한다.
- Avoid bottom control decks that compete with the board or make the game feel like a settings dashboard.

## MVP Scope

- Must-have:
  - 6x6 / 8x8 / 10x10 리버시 싱글플레이(기본 8x8)
  - 플레이어 선공/후공 선택
  - 난이도 3단계: EASY depth 1, MEDIUM depth 3, HARD depth 5
  - 합법 수 표시, 패스 처리, 게임오버/승패/무승부 처리
  - 최근 대국/보드 상태 로컬 자동 저장/복원
  - 돌 착수 사운드, 일반 뒤집힘 사운드, 대량 뒤집힘 보너스 사운드와 상황별 햅틱
  - 설정: 사운드, 진동, 착수 표시, 보드 테마, 돌 테마, 언어, 글자 크기, 모션 줄이기, 플레이 방법, 정보
  - 한국어 기본 UI와 영어·일본어 보조 UI
- Should-have:
  - 게임 종료 광고 hook
  - 출시용 로고, 스플래시, 스크린샷 생성 구조
  - AppsInToss Web wrapper
- Out of scope:
  - 실시간 멀티플레이
  - ELO/랭킹
  - Firebase Auth 기반 계정
  - TCP PVP 서버
  - 인앱 결제
  - 서버 권위 판정

## Core Rules

- Board size: `6 x 6`, `8 x 8`, `10 x 10` (default: `8 x 8`)
- Piece enum: `NONE = 0`, `BLACK = 1`, `WHITE = 2`, `VALID = 3`
- Coordinate: `x = row`, `y = col`
- Display coordinate: `y = A..`, `x = 1..`이며 좌상단 `(0, 0)`은 `A1`이다.
- Start position: `N/2`를 기준으로 중앙 4칸에 WHITE/BLACK 교차 배치
  - `(N/2-1,N/2-1) WHITE`
  - `(N/2-1,N/2) BLACK`
  - `(N/2,N/2-1) BLACK`
  - `(N/2,N/2) WHITE`
- First turn: BLACK
- Initial valid moves for BLACK: 중앙 4칸의 바깥 직교 방향 4칸(8x8은 `(2,3)`, `(3,2)`, `(4,5)`, `(5,4)`)
- Winner:
  - black count > white count: BLACK
  - white count > black count: WHITE
  - otherwise draw

## AI

- EASY: depth 1
- MEDIUM: depth 3
- HARD: depth 5
- MEDIUM switches to exact terminal search at 6 or fewer empty cells; HARD switches at 8 or fewer. EASY always keeps depth 1.
- Evaluation: mobility 차이와 corner/edge/near-corner 위치 가중을 반영하고, 돌 개수 차이는 빈칸 비율에 따라 개시 0·중반 1·종반 4 가중을 적용한다.
- 모든 난이도에서 최선 평가가 같은 수는 대국별 seed로 균등 선택한다. 같은 seed와 보드 상태는 같은 수를 재현하며, 서로 다른 EASY 대국은 동점 최선 수 사이에서 전개가 달라질 수 있다.
- EASY는 depth 1을 유지하고 차선 수를 선택하지 않으며, 동점 최선 수에만 seed 변주를 적용한다.

## Persistence / Codec

- Local save path: `user://save_v1.json`
- User preferences path: `user://prefs_v1.json`
- 플레이 방법 완료·건너뛰기 여부는 `how_to_play_seen`으로 환경설정에 저장하며 게임 save와 분리한다. 단순 자동 표시만으로 완료 처리하지 않는다.
- Board codec: `LR` magic + codec version + board-size tag + current turn + 셀당 2-bit 가변 payload.
- Legacy board codec: 기존 8 rows x 16-bit little-endian + 16-bit current turn(18 bytes)은 읽기 호환을 유지한다.
- Valid move cells can be encoded with `VALID = 3` for review/share payloads.
- 대국별 AI seed를 game save에 저장한다. seed가 없는 기존 save는 board payload에서 결정론적으로 복원한다.

## 승인

- Planning approval status: approved
- Approver: user
- Approved date: 2026-06-18
- Approved phases in this pass: Phase 0, Phase 1, Phase 2
