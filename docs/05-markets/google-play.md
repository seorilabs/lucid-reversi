# Google Play

## App Identity

- Package name: `com.etlegame.reversi` (iOS bundle id와 통일)
- App name: 루시드 리버시
- Default language: `en-US` (Play 실측. 2015년 등록 당시 기준이며 게임 내 기본 로케일 `ko`와는 별개)
- 지원 언어: 한국어, 영어, 일본어
- Category: Games / Board

## 기존 앱 승계

`com.etlegame.reversi`는 Play에서 이미 쓰이고 있는 패키지다. 등록정보는
**'Reversi Online' / '리버시 온라인'**(온라인 통신대국)이고 production 2.1.2(versionCode 47)까지
배포된 이력이 있다. 루시드 리버시는 이 앱을 **리브랜딩해 승계**한다.

- 배포하면 기존 등록정보를 교체하고, 기존 사용자에게 업데이트로 나간다.
- 설치수와 리뷰를 승계하는 대신 온라인 대국을 기대하는 사용자에게 다른 게임이 전달된다.
- **서명 키 이관 완료(2026-09-18)**: 원 서명 키(2015년 ETLE 명의)를 PEPK로 Google에 이관해
  Play App Signing 앱 서명 키가 됐다. CI는 분리된 전용 업로드 키로 서명하므로, 원본 키는
  더 이상 업로드 경로에 필요하지 않다.

### 등재정보 교체 (2026-09-21 기준 미반영)

Play 실측으로 등재정보는 아직 `Reversi Online` / `리버시 온라인`이고, 설명 본문이 푸시 알림
턴제 온라인 대전, 전세계 매칭, 구글 플레이 리더보드처럼 **현재 게임에 없는 기능**을 설명한다.

- 교체 문안: `play-store/listing/{ko-KR,en-US,ja-JP}.json` (Play 한도 검증 통과)
- 교체 이전 원본: `play-store/listing/legacy-reversi-online.json` (되돌림 근거로 보존)
- 게임이 일본어를 지원하는데 Play에는 ja-JP 등재정보가 없어 새로 추가한다.
- 이미지 자산은 기본 언어(en-US)에만 있다 — 아이콘 1, 피처그래픽 1, 폰 3, 7인치 3, 10인치 3.
  ko-KR은 이미지가 없어 en-US를 상속한다. 전부 루시드 리버시 자산으로 교체해야 한다.
- **반영 시점**: 스토어 페이지는 트랙과 무관하게 즉시 반영된다. production에 옛 앱이 남아 있는
  동안 문구만 바꾸면 설명과 실제 내려받는 앱이 달라져 "오해를 부르는 등재정보"에 걸릴 소지가
  있다. 등재정보 교체는 **루시드 리버시 빌드의 production 승격과 동시에** 한다.

**versionCode 주의**: 원장 `android.lastVersionCode`는 2026-09-21 기준 **48**(v2.2.6이 소비)이고
Play production은 47이다. 다음 태그가 49를 받는다. 원장 도입 이전 태그
(`v2.2.3`~`v2.2.5`)는 legacy 공식(`1,000,000,000 + encodedVersion`)으로 떨어져 `1002002005`가
나온다. 상한이 2,100,000,000이고 되돌릴 수 없으므로 **기존 태그를 Play에 직접 올리지 않는다.**
`release-tag` 워크플로우로 새 태그를 끊어 원장이 다음 값을 할당하게 한다.

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

승계 이전 자산은 전부 옛 `Reversi Online` 것이라 교체 대상이다. 아래는 제작을 마친 교체본이다.

| 슬롯 | 파일 | 규격 | 제작 방법 |
|---|---|---|---|
| App icon | `play-store/assets/icon-512.png` | 512x512 PNG | 게임의 실제 돌 SVG(`classic_black/white`)와 칠기·황동 톤으로 합성. 원본은 `icon-512.source.html` |
| Feature graphic | `play-store/assets/feature-graphic-{ko-KR,en-US,ja-JP}.png` | 1024x500 PNG | `moonlit-lacquer-backdrop` + 실제 보드 캡처 + `DoHyeon`/`MPLUSRounded1c` 타이틀 |
| Phone screenshots | `play-store/screenshots/phone/*.png` (5장) | 1080x1920 PNG | **실기기 캡처**(Android 16). `wm size 1080x1920`으로 Play 최대 종횡비 2:1을 맞춘 뒤 캡처하고 원복 |
| Tablet screenshots | `play-store/screenshots/tablet/*.png` (3장) | 1200x1920 PNG | **데스크톱 Godot 캡처**. `--resolution 1200x1920`(Retina 2배라 논리 창 600x960)로 띄우고 창 영역만 캡처. 7인치·10인치 슬롯 공용 |

- 태블릿 캡처는 게임 저장 데이터(`prefs_v1.json`, `save_v1.json`)로 테마·보드 크기·진행 국면을 만들어 찍었다.
  작업 전 백업하고 끝나면 원복한다.
- **런처 아이콘은 아직 Godot 기본 아이콘이다.** 스토어 아이콘과 런처 아이콘이 다르므로 릴리스 전에
  `godot/export_presets.cfg`의 Android 아이콘 슬롯을 채워야 한다.
- iOS 아이콘(`app-store/assets/AppIcon-1024.png`)은 청록 다이아몬드로 이 아이콘과 다르다. 마켓 간
  아이콘 통일 여부는 별도 결정 사항이다.

## Current Implementation

- Godot project name: `루시드 리버시`
- Playable MVP: AI 대전, 로컬 2인 패스 앤 플레이, 난이도, 합법 수 표시, 패스, 게임오버, 로컬 저장
- Android device smoke: `npm run build:android:smoke` creates `build/android/lucid-reversi-device-smoke.apk` by packaging the Godot export pack into the local Android debug template.
- **릴리스 AAB 빌드 인프라 구성 완료**:
  - `godot/export_presets.cfg`에 Android preset(`Android`) 커밋 — `package/unique_name=com.etlegame.reversi`, gradle AAB(`gradle_build/use_gradle_build=true`, `export_format=1`), arm64-v8a, keystore는 env 주입용으로 비움.
  - `scripts/install_android_build_template.sh`(org 워크플로우가 export 직전 호출): editor settings에 Android SDK/JDK 경로 주입 + Godot Android build template(`godot/android/build`, `.gitignore` 대상) 설치.
  - 배포 경로: `.github/workflows/deploy-google-play.yml` → org `godot-deploy-google-play.yml`(`godot --export-release Android` → 서명 → WIF 업로드).
- 실 배포 전 필요한 GitHub secrets/vars:
  - secrets: `GOOGLE_PLAY_UPLOAD_KEYSTORE_BASE64`, `GOOGLE_PLAY_UPLOAD_KEYSTORE_PASSWORD`, `GOOGLE_PLAY_UPLOAD_KEY_PASSWORD`
  - vars: `GOOGLE_PLAY_UPLOAD_KEY_ALIAS`, `GOOGLE_WORKLOAD_IDENTITY_PROVIDER`, `GOOGLE_PLAY_SERVICE_ACCOUNT_EMAIL`
  - Android 광고 미탑재이므로 `ADMOB_APP_ID`는 **미설정**(설정 시 AdMob 강제 포함).
- **AAB 빌드 검증 완료(2026-09-21)**: `Deploy to Google Play`(upload=false, main) run
  [35612098803](https://github.com/seorilabs/lucid-reversi/actions/runs/35612098803) 성공.
  `build/android/lucid-reversi.aab`, versionName 2.2.6 / versionCode 48, 업로드 키 서명까지 통과했다.
  2026-08-29 실패 원인(`Target folder does not exist: "build/android"`)은 org 워크플로우에서 이미
  해결돼 재현되지 않았다.
- 남은 것: 등재정보 텍스트 교체 반영, store graphics(아이콘/피처그래픽/스크린샷) 제작,
  Android 런처 아이콘 자산(현재 preset은 기본 아이콘), 앱 콘텐츠 섹션(Data safety·콘텐츠 등급·
  광고 선언·target API) 재확인. 앱 레코드는 승계라 새로 만들지 않는다.
