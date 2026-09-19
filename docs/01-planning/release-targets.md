# Release Targets

## Current Launch Priority

- Primary target: AppsInToss
- Default launch locale: Korean
- Secondary targets: Google Play and Apple App Store remain in the repo-local inventory, but their console identifiers, signing, and store assets are not blockers for the AppsInToss-first candidate gate.

## Google Play

- Target: Godot Android AAB
- Priority: AppsInToss 이후 후속 마켓
- Android package name: 확정 필요
- Firebase Android app: 확정 필요
- Release track: internal testing 우선
- Runner policy: release AAB/APK는 RPI ARC가 아니라 x64 Linux runner에서 빌드한다.

## Apple App Store

- Target: Godot iOS export + Xcode archive
- Priority: AppsInToss 이후 후속 마켓
- iOS bundle ID: 확정 필요
- Apple Developer Team: 확정 필요
- TestFlight target: internal testing 우선
- Runner policy: App Store build는 macOS/Xcode runner에서 빌드한다.

## AppsInToss

- Target: Godot Web export + AIT Web wrapper
- Priority: first launch target
- AppsInToss appName: 확정 필요
- Delivery shape: Godot Web export wrapper
- Default locale: Korean
- Sandbox QA status: 확정 필요
- Runner policy: Web/AIT 후보 빌드는 private repo 기준 `seorilabs-x64` 사용 가능.

## Current Phase Boundary

- Phase 0: starter-template-game 승격, repo-local docs/config 원장 구성
- Phase 1: 순수 리버시 규칙/AI/codec/save DTO 및 smoke test
- Phase 2: Godot 싱글플레이 UI, 로컬 저장, 설정 toggle
- AppsInToss candidate preparation is now the first release path.
- Google Play/App Store console registration and store uploads remain deferred until a later deployment approval.
