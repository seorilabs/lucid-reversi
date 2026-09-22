# Release Checklist

## Phase 0-2 Gate

- [x] `starter-template-game` copied into `lucid-reversi`
- [x] Product docs identify Lucid Reversi
- [x] Reversi rules/AI/codec/save DTO implemented
- [x] Godot smoke tests cover initial moves, flip, pass, game over, codec, save round trip
- [x] Playable Godot AI and local pass-and-play shell exists
- [x] Korean default UI with English and Japanese secondary locales
- [x] Bundled game-readable Korean font and Japanese glyph fallback for Godot Web/AIT
- [x] `npm run test`
- [x] `npm run build:godot:web`

## Common Release Gate

- [ ] `npm run test:core`
- [ ] `npm run check:architecture`
- [ ] `npm run test:godot`
- [x] `npm run check:docs` locally on 2026-06-19 after AppsInToss copy/image changes
- [x] `npm run build:godot:web` locally on 2026-06-19 after localization changes
- [ ] `npm run check:release`
- [ ] `npm run check:release:ait`
- [ ] Privacy/policy answers confirmed
- [ ] Release notes confirmed

## AppsInToss-First Candidate Gate

- [x] Default locale is Korean
- [x] In-app English secondary locale exists
- [x] In-app Japanese secondary locale and Japanese-device first-install selection exist
- [x] Korean game font is bundled for Web/AIT
- [x] Japanese fallback font is bundled for Web/AIT
- [x] Korean HUD text uses outline and higher contrast
- [ ] AppsInToss appName confirmed
- [x] AppsInToss brand icon local asset generated and validated
- [x] AppsInToss registration images ready locally
- [x] AppsInToss Korean registration copy drafted
- [ ] Godot Web export rebuilt after localization changes
- [ ] AIT wrapper project finalized
- [ ] `.ait` artifact generated
- [ ] Sandbox QA completed

## Google Play

- [ ] Package name confirmed
- [ ] AAB built on x64 Linux release path
- [ ] Signing confirmed
- [ ] Internal testing upload ready
- [x] Data safety confirmed — 2026-09-22 재선언. 수집 `앱 상호작용`(분석)·`기기 또는 기타 ID`(분석·광고), 공유 `기기 또는 기타 ID`(광고). 전송 중 암호화 예
- [x] production 승격 — v2.2.8 / versionCode 50, 등재정보 교체와 동시. **검토 중이며 공개 출시 아님**

## App Store

- [x] Bundle ID confirmed — `com.etlegame.reversi` (Lucid Reversi 전용. MatchPictureUnity=삭제됨, MatchSymbol=오타로 교체)
- [x] Xcode/macOS build path confirmed — Godot 4.6.3 iOS export(preset `iOS`) → Xcode 아카이브. Xcode 26.5
- [x] Signing/provisioning confirmed — 자동 서명, team `HCDUXX4Z3X`, 배포 재서명은 exportArchive(app-store-connect)에서 수행
- [x] 광고 결정 — AdMob 전면광고 탑재(2026-09-22, iOS·Android 공용). 한 판 종료 시 1회, 비맞춤형. 업로드된 v2.2.1/v2.2.2는 그 이전 빌드다
- [x] App Store 1024 아이콘(알파 없음) + iPhone 아이콘 카탈로그 생성
- [x] 빌드 업로드 완료 — com.etlegame.reversi v2.2.1 build 1, universal(1,2), 2026-06-26 "Upload succeeded" (ASC 처리 중)
- [x] iPhone 6.9"(1320×2868) + iPad 13"(2064×2752) 스크린샷 실 캡처 (app-store/screenshots/)
- [ ] App Privacy / 연령등급 / 콘텐츠 권리 / 수출규정 콘솔 답변
- [ ] TestFlight notes ready
- [ ] 빌드 선택 + Submit for Review (콘솔)

## AppsInToss

- [ ] AppsInToss appName confirmed
- [ ] Godot Web export ready
- [ ] Wrapper build ready
- [ ] `.ait` artifact generated
- [ ] Sandbox QA completed
- [x] Registration images ready locally
- [x] Korean registration copy drafted

## GitHub Pages

- [ ] GitHub Pages source is Actions workflow
- [ ] `Deploy Godot Web Pages` succeeds on `main`
- [ ] Published URL smoke-tested
