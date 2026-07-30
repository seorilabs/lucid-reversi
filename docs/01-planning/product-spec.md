# Product Spec

## 기본 정보

- Korean app name: 루시드 리버시
- English app name: Lucid Reversi
- App ID: `lucid-reversi`
- One-line pitch: 짧은 세션에 AI와 바로 둘 수 있는 모바일 리버시.
- Genre: Board game / Reversi / Single-player strategy
- Target audience: 클래식 보드게임을 짧게 즐기는 모바일 사용자
- Primary launch target: AppsInToss first
- Default locale: Korean (`ko`). English (`en`) is supported in-app as a secondary locale.
- Korean typography: game-readable display font with text outlines and high contrast for mobile HUD readability.
- Monetization: 광고 기반 후보. 게임 종료 전면 광고 hook은 Phase 2 이후 adapter에서 연결한다.
- Support email: `cs@seorilabs.com`

## 핵심 루프

- Primary loop: 색상과 난이도를 고르고 AI와 한 판을 둔다.
- Session length: 3-5분
- Progression: EASY, MEDIUM, HARD 난이도를 바꿔 반복 대국하고 난이도별 로컬 승/무/패 전적을 누적한다.
- Failure/retry model: 승패/무승부 후 즉시 새 게임을 시작한다. 진행 중인 대국에서는 새 게임이나 돌 색 변경 전에 초기화 확인을 받는다.
- Retention surface: 최근 대국 상태와 설정을 로컬 자동 저장/자동 복원한다.
- Localization: AppsInToss는 한국어를 기본으로 노출하고, 앱 내부 언어 선택에서 영어로 전환할 수 있다.

## UX Direction

- Mobile playfield-first: 게임판, 점수, 차례, 착수 가능 위치, 돌 뒤집힘 애니메이션을 화면 중심 경험으로 둔다.
- Board-adjacent feedback starts immediately under the board: full-width advantage meter first, then one compact row for 새 게임, 선공/후공, 착수 가능 수.
- Non-gameplay controls live in the top-right settings menu: 난이도, 사운드, 진동, 보드/돌 테마, 언어, 글자 크기, 모션 줄이기. Mobile settings use large segmented buttons instead of select boxes, and tapping outside the settings panel closes it.
- In-play fun feedback should stay close to the board: last-move highlight, always-on legal move markers, midpoint color-swap disc flip with a placement-origin wave, placement sound, flip sound, big-flip sound, and a full-width advantage meter.
- Avoid bottom control decks that compete with the board or make the game feel like a settings dashboard.

## MVP Scope

- Must-have:
  - 8x8 리버시 싱글플레이
  - 플레이어 선공/후공 선택
  - 난이도 3단계: EASY depth 1, MEDIUM depth 3, HARD depth 5
  - 합법 수 표시, 패스 처리, 게임오버/승패/무승부 처리
  - 최근 대국/보드 상태 로컬 자동 저장/복원
  - 돌 착수 사운드, 일반 뒤집힘 사운드, 대량 뒤집힘 보너스 사운드와 상황별 햅틱
  - 설정: 사운드, 진동, 보드 테마, 돌 테마, 언어, 글자 크기, 모션 줄이기
  - 한국어 기본 UI와 영어 보조 UI
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

- Board size: `8 x 8`
- Piece enum: `NONE = 0`, `BLACK = 1`, `WHITE = 2`, `VALID = 3`
- Coordinate: `x = row`, `y = col`
- Start position:
  - `(3,3) WHITE`
  - `(3,4) BLACK`
  - `(4,3) BLACK`
  - `(4,4) WHITE`
- First turn: BLACK
- Initial valid moves for BLACK: `(2,3)`, `(3,2)`, `(4,5)`, `(5,4)`
- Winner:
  - black count > white count: BLACK
  - white count > black count: WHITE
  - otherwise draw

## AI

- EASY: depth 1
- MEDIUM: depth 3
- HARD: depth 5
- Evaluation: piece count plus corner, edge, and near-corner weights.

## Persistence / Codec

- Local save path: `user://save_v1.json`
- User preferences path: `user://prefs_v1.json`
- Board codec: 8 rows x 16-bit little-endian plus 16-bit current turn = 18 bytes.
- Valid move cells can be encoded with `VALID = 3` for review/share payloads.

## 승인

- Planning approval status: approved
- Approver: user
- Approved date: 2026-06-18
- Approved phases in this pass: Phase 0, Phase 1, Phase 2
