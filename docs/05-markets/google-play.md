# Google Play

## App Identity

- Package name: `com.etlegame.reversi` (iOS bundle id와 통일)
- App name: 루시드 리버시
- Default language: Korean
- Category: Games / Board

## 기존 앱 승계

`com.etlegame.reversi`는 Play에서 이미 쓰이고 있는 패키지다. 등록정보는
**'Reversi Online' / '리버시 온라인'**(온라인 통신대국)이고 production 2.1.2(versionCode 47)까지
배포된 이력이 있다. 루시드 리버시는 이 앱을 **리브랜딩해 승계**한다.

- 배포하면 기존 등록정보를 교체하고, 기존 사용자에게 업데이트로 나간다.
- 설치수와 리뷰를 승계하는 대신 온라인 대국을 기대하는 사용자에게 다른 게임이 전달된다.
- 업로드 키는 versionCode 47을 서명한 그 키여야 한다. Play App Signing이 켜져 있으면
  Play Console에서 업로드 키 재설정으로 복구할 수 있다.

**versionCode 주의**: 원장 `android.lastVersionCode=47`이 baseline이다. 원장 도입 이전 태그
(`v2.2.3`~`v2.2.5`)는 legacy 공식(`1,000,000,000 + encodedVersion`)으로 떨어져 `1002002005`가
나온다. 상한이 2,100,000,000이고 되돌릴 수 없으므로 **기존 태그를 Play에 직접 올리지 않는다.**
`release-tag` 워크플로우로 새 태그를 끊어 원장이 48을 할당하게 한다.

## Release

- First track: internal testing
- `Deploy to Google Play`의 `upload` 기본값은 **true**다. 업로드를 막는 실제 장치는
  `google-play` Environment의 `required_reviewers`(사람 승인)와 배포 브랜치 제한(`main`, `v*`)이다.
  기본값을 false로 두면 릴리스마다 켜는 것을 잊어 빌드만 하고 끝나는 쪽이 더 잦다.
  빌드만 확인하려면 dispatch에서 `upload: false`를 명시한다.
- AAB 서명: org 워크플로우가 업로드 키스토어(secrets `GOOGLE_PLAY_UPLOAD_KEYSTORE_BASE64`/`GOOGLE_PLAY_UPLOAD_KEYSTORE_PASSWORD`, alias var `GOOGLE_PLAY_UPLOAD_KEY_ALIAS`)로 서명.
- Play App Signing: 권장(업로드 키 → Play가 최종 서명). Play Console 앱 등록 시 설정.
- 업로드: WIF(`GOOGLE_WORKLOAD_IDENTITY_PROVIDER` + `GOOGLE_PLAY_SERVICE_ACCOUNT_EMAIL` vars)로 Android Publisher API 업로드.
- Build runner: x64 Linux runner. RPI ARC runner는 Android release AAB/APK 대상이 아니다.

## Policy / Data Safety

- Ads: **미탑재**(릴리스 빌드 인프라만 구성). org 워크플로우는 `vars.ADMOB_APP_ID`가 비면 AdMob 단계를 자동 스킵. AdMob은 현재 iOS 전용.
- In-app purchases: 없음
- Analytics: GA4 Measurement Protocol(REST, `godot/scripts/ga4_mp_sender.gd`). Firebase SDK 미사용 → google-services.json/Firebase Android app 불요.
- Crash reporting: 없음(Firebase Crashlytics 미사용)
- Account deletion requirement: 계정 기능 없음. Firebase Auth를 추가하지 않는 한 삭제 URL 대상 아님.

## Assets

- App icon: 확정 필요
- Feature graphic: 확정 필요
- Phone screenshots: 확정 필요
- Tablet screenshots: 확정 필요

## Current Implementation

- Godot project name: `루시드 리버시`
- Playable MVP: AI 대전, 로컬 2인 패스 앤 플레이, 난이도, 합법 수 표시, 패스, 게임오버, 로컬 저장
- Android device smoke: `npm run build:android:smoke` creates `build/android/lucid-reversi-device-smoke.apk` by packaging the Godot export pack into the local Android debug template.
- **릴리스 AAB 빌드 인프라 구성 완료**:
  - `godot/export_presets.cfg`에 Android preset(`Android`) 커밋 — `package/unique_name=com.etlegame.reversi`, gradle AAB(`gradle_build/use_gradle_build=true`, `export_format=0`), arm64-v8a, keystore는 env 주입용으로 비움.
  - `scripts/install_android_build_template.sh`(org 워크플로우가 export 직전 호출): editor settings에 Android SDK/JDK 경로 주입 + Godot Android build template(`godot/android/build`, `.gitignore` 대상) 설치.
  - 배포 경로: `.github/workflows/deploy-google-play.yml` → org `godot-deploy-google-play.yml`(`godot --export-release Android` → 서명 → WIF 업로드).
- 실 배포 전 필요한 GitHub secrets/vars:
  - secrets: `GOOGLE_PLAY_UPLOAD_KEYSTORE_BASE64`, `GOOGLE_PLAY_UPLOAD_KEYSTORE_PASSWORD`, `GOOGLE_PLAY_UPLOAD_KEY_PASSWORD`
  - vars: `GOOGLE_PLAY_UPLOAD_KEY_ALIAS`, `GOOGLE_WORKLOAD_IDENTITY_PROVIDER`, `GOOGLE_PLAY_SERVICE_ACCOUNT_EMAIL`
  - Android 광고 미탑재이므로 `ADMOB_APP_ID`는 **미설정**(설정 시 AdMob 강제 포함).
- 남은 것: Play Console 앱 레코드 생성, store graphics(아이콘/피처그래픽/스크린샷), Android 런처 아이콘 자산(현재 preset은 기본 아이콘).
