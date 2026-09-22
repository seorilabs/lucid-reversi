# Release Targets

## Current Launch Priority

- Primary target: AppsInToss
- Default launch locale: Korean
- Secondary targets: Google Play and Apple App Store remain in the repo-local inventory, but their console identifiers, signing, and store assets are not blockers for the AppsInToss-first candidate gate.

## Google Play

- Target: Godot Android AAB
- Priority: **첫 공개 마켓**. 2026-09-22 v2.2.8(versionCode 50) production 승격, 검토 중
- Android package name: `com.etlegame.reversi` (옛 Reversi Online 리브랜딩 승계. `docs/05-markets/google-play.md` 참조)
- Firebase Android app: **없음**. 분석은 GA4 Measurement Protocol(REST)만 쓰고 Firebase SDK를 넣지 않는다
- Release track: internal testing 우선
- Runner policy: release AAB/APK는 RPI ARC가 아니라 x64 Linux runner에서 빌드한다.

## Apple App Store

- Target: Godot iOS export + Xcode archive
- Priority: AppsInToss 이후 후속 마켓
- iOS bundle ID: `com.etlegame.reversi` (Android package name과 통일)
- Apple Developer Team: `HCDUXX4Z3X`
- TestFlight target: internal testing 우선
- Runner policy: App Store build는 macOS/Xcode runner에서 빌드한다.

## AppsInToss

- Target: Godot Web export + AIT Web wrapper
- Priority: first launch target
- AppsInToss appName: `lucid-reversi` (콘솔 확정값)
- Delivery shape: Godot Web export wrapper
- Default locale: Korean
- Sandbox QA status: passed — 실기기 `intoss://lucid-reversi` 로딩·동작 확인 완료. 인앱 광고는 샌드박스에서 검증 불가라 콘솔 출시하기 QR로 실 토스앱 확인이 남는다
- Runner policy: Web/AIT 후보 빌드는 private repo 기준 `seorilabs-x64` 사용 가능.

## Current Phase Boundary

- Phase 0: starter-template-game 승격, repo-local docs/config 원장 구성
- Phase 1: 순수 리버시 규칙/AI/codec/save DTO 및 smoke test
- Phase 2: Godot 싱글플레이 UI, 로컬 저장, 설정 toggle
- AppsInToss candidate preparation is now the first release path.
- Google Play/App Store console registration and store uploads remain deferred until a later deployment approval.
