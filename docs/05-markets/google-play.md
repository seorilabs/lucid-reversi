# Google Play

## App Identity

- Package name: 확정 필요
- App name: 루시드 리버시
- Default language: Korean
- Category: Games / Board

## Release

- First track: internal testing
- AAB signing: 확정 필요
- Play App Signing: 확정 필요
- Build runner: x64 Linux runner. RPI ARC runner는 Android release AAB/APK 대상이 아니다.

## Policy / Data Safety

- Ads: 후보 있음. Phase 2 기준 실제 SDK 연결 없음.
- In-app purchases: 없음
- Analytics: 확정 필요
- Crash reporting: 확정 필요
- Account deletion requirement: 계정 기능 없음. Firebase Auth를 추가하지 않는 한 삭제 URL 대상 아님.

## Assets

- App icon: 확정 필요
- Feature graphic: 확정 필요
- Phone screenshots: 확정 필요
- Tablet screenshots: 확정 필요

## Current Implementation

- Godot project name: `루시드 리버시`
- Playable MVP: 싱글플레이, 난이도, 합법 수 표시, 패스, 게임오버, 로컬 저장
- Android device smoke: `npm run build:android:smoke` creates `build/android/lucid-reversi-device-smoke.apk` by packaging the Godot export pack into the local Android debug template.
- Not ready: release AAB preset, signing, Play Console app, store graphics
