# Enable Firebase/GA4 Analytics (외부 전송)

- Status: accepted
- Date: 2026-07-06

## Context

잔존율·이탈 등 제품 지표를 확인하려면 분석 계측이 실제로 외부(GA4)로 전송돼야 한다.
초안(`feature/firebase-analytics`)은 존재하지 않는 플랫폼 브리지(Android singleton `LucidFirebase`,
Web `__lucidReversiFirebase`)를 호출해 iOS/Web/Android 어디서도 전송되지 않는 no-op이었고,
`game_over` 중복·이어하기 승패 판정 뒤집힘·매 수(move) 이벤트 과다 등의 결함이 있었다.
외부 전송을 켜는 것은 데이터 수집 공시(App Privacy·Play 데이터안전·AIT·개인정보처리방침)를 동반한다.

## Decision

- GA4 분석 외부 전송을 **켠다**. 연동은 **GA4 Measurement Protocol(REST-first)** — 플랫폼 네이티브
  브리지가 아니라 `HTTPRequest`로 직접 POST 하므로 iOS/Web/AIT 공통 동작. 구현:
  `scripts/ga4_mp_sender.gd`(Node·전송기) ← `scripts/analytics.gd`(어댑터) ← `scripts/bootstrap/main.gd`.
- GA4/Firebase 프로젝트: **lucid-reversi**(게임별 1프로젝트, 2026-07-06 프로비저닝). measurement_id/api_secret은
  `godot/analytics.config.json`(gitignore)로 주입, 커밋 금지. 예시는 `godot/analytics.config.example.json`.
- 전송 조건: **릴리스 빌드 + config 존재 + 비-headless** 만(에디터/디버그·헤드리스는 미전송, 실데이터 오염 방지).
- 이벤트: `game_open`(세션, 전송기 자동), `game_start`, `game_over`(result/점수/수/난이도), `settings_changed`.
  `move`는 볼륨·노이즈 대비 가치가 낮아 제외(수 관련 지표는 `game_over.total_moves`).
- 세션/DAU/잔존율은 GA4가 client_id + session_id + engagement_time_msec로 자동 집계. 예약 이벤트명은 스킵.

### 수집 데이터 프로필 (공시 기준)

| 항목 | 값 |
| --- | --- |
| 사용 데이터 | 익명 게임 이벤트(game_open/game_start/game_over/settings_changed 카운터·식별자) |
| 식별자 | 앱 설치별 GA4 client_id(user:// 로컬 생성 난수, 계정·연락처·이메일 아님) |
| 목적 | 서비스 분석·개선(잔존율·이탈 지점) |
| 처리자 | Google Analytics 4 |
| PII | **미수집** — 개인정보는 이벤트에 싣지 않는다 |
| Linked to identity | **아니오**(계정 없음) |
| Tracking / ATT | **아니오**(광고·IDFA 없음 → ATT 불필요) |
| 저장 | 게임 진행은 기기 로컬(user://). 분석 이벤트만 GA4로 전송 |

## Consequences

- **App Store App Privacy 타이밍**: 현재 심사 중 v2.2.1은 analytics 미포함 → No Data Collected 유지
  (2026-06-30 Guideline 5.1.2(i) 반려 대응). **GA4 analytics 포함 다음 빌드부터** Data Collected(사용 데이터·식별자,
  Not Linked, Not Used for Tracking)로 전환. 근거/답변은 `app-store/app-store.config.json`의 `dataCollection` 참조.
- 후속 공시 갱신(analytics 포함 빌드 릴리스 전): 개인정보처리방침, Google Play **데이터 안전**, AppsInToss 공시,
  `docs/05-markets/{app-store,google-play,apps-in-toss,firebase}.md`를 위 프로필로 갱신("수집 없음" → "익명 분석 수집").
- 잔존율 조회(GA4→BigQuery)는 과금 연결 + BigQuery export 링크 + per-game 읽기 SA 후 `ga4-bigquery-analytics` 스킬로.
  (프로비저닝 시 과금 미탐지로 읽기 SA/BigQuery는 보류 상태 — 조회 시점에 보정.)
