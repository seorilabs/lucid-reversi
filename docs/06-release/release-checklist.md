# Release Checklist

## Phase 0-2 Gate

- [x] `starter-template-game` copied into `lucid-reversi`
- [x] Product docs identify Lucid Reversi
- [x] Reversi rules/AI/codec/save DTO implemented
- [x] Godot smoke tests cover initial moves, flip, pass, game over, codec, save round trip
- [x] Playable Godot single-player shell exists
- [x] Korean default UI with English secondary locale
- [x] Bundled game-readable Korean font for Godot Web/AIT
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
- [x] Korean game font is bundled for Web/AIT
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
- [ ] Data safety confirmed

## App Store

- [ ] Bundle ID confirmed
- [ ] Xcode/macOS build path confirmed
- [ ] Signing/provisioning confirmed
- [ ] TestFlight notes ready
- [ ] Privacy labels confirmed

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
