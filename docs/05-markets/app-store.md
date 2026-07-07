# Apple App Store

> Source of truth: `app-store/app-store.config.json`. 이 문서는 사람이 읽는 요약이다.

## App Identity

- Bundle ID: `com.etlegame.reversi` (Lucid Reversi 전용. 이전 시도 MatchPictureUnity=ASC 삭제됨, MatchSymbol=잘못된 id)
- SKU: `lucid-reversi`
- App name: 루시드 리버시
- Subtitle: 짧게 즐기는 모바일 리버시
- Category: Games / Board

## Listing Copy (ko-KR, ASC 한도 검증)

| 필드 | 값 | 한도 |
|---|---|---|
| Name | 루시드 리버시 | 7/30 |
| Subtitle | 짧게 즐기는 모바일 리버시 | 14/30 |
| Promotional Text | 선명한 보드와 빠른 AI 대전으로 한 수씩 판세를 뒤집는 모바일 리버시 게임입니다. | 46/170 |
| Keywords | 오델로,리버시,보드게임,AI 대전,전략게임,두뇌게임,흑백돌,캐주얼게임 | 38/100 |
| Description | 루시드 리버시는 AI와 바로 한 판 붙는 모바일 리버시 게임입니다. 선명한 보드와 큼직한 흑백 돌, 착수와 뒤집힘 피드백으로 작은 화면에서도 다음 수가 잘 보입니다. 난이도와 보드/돌 테마를 바꾸며 짧은 시간 안에 판세를 뒤집는 재미를 즐겨보세요. | <4000 |

- Support URL: 확정 필요 (App Review 필수)
- Marketing URL: 확정 필요 (선택)
- Copyright: 확정 필요

## Release

- TestFlight target: internal testing
- Signing team: `HCDUXX4Z3X`
- ASC Provider: `HCDUXX4Z3X`
- Signing: manual / `Apple Distribution` / App Store 프로비저닝 프로파일
- Build runner: macOS/Xcode runner. RPI ARC runner는 App Store build 대상이 아니다.

## Ads

- **AdMob 전면(Interstitial) 광고 탑재** (iOS). 한 판 종료 시 1회 노출(`_interstitial_shown_this_game` 가드).
- 플러그인: `godot-sdk-integrations/godot-admob` v6.0 (iOS 전용 사용, Godot 4.6 지원). GDScript 애드온(`godot/addons/AdmobPlugin`)과 `godot/ios/plugins/AdmobPlugin.gdip`는 커밋, xcframework(약 45MB)는 `.gitignore` → iOS export 전 `scripts/install_ios_admob_plugin.sh`로 다운로드.
- 광고 ID: App `ca-app-pub-2444587584524186~1005155551`, Interstitial `ca-app-pub-2444587584524186/8692073883`. 비맞춤형(`PersonalizationState.DISABLED`)·IDFA/추적 미사용.
- Info.plist 주입: `IosExportPlugin`이 export 시 `GADApplicationIdentifier` + `SKAdNetworkItems`를 자동 주입(`godot/addons/AdmobPlugin/ios_export.cfg` 기반, `is_real=true`라 릴리스엔 실 App ID). CocoaPods 불필요(self-contained xcframework, mediation 미사용 → Podfile 미생성) → org `xcodebuild archive -project` 경로 그대로.
- 어댑터: `godot/scripts/ios_ads.gd`(bootstrap 계층, `check_architecture.sh` 경계 준수). `main.gd:_request_interstitial_ad()`의 iOS 분기에서 호출. 개발/비릴리스 빌드는 AdMob 공식 테스트 ID(`OS.is_debug_build` 분기), 릴리스만 실 유닛.
- AdMob은 iOS 전용. `AdmobPlugin.gd`에서 `AndroidExportPlugin` 미등록(Android AAB에 AdMob 강제 포함 방지).

## Privacy / Review

- Privacy nutrition labels: **재검토 필요** — GA4(익명 client_id) + AdMob(비맞춤형·IDFA 미사용)을 반영해 다음 빌드 제출 전 확정. 현재 심사 중 v2.2.1(analytics/광고 미포함)은 No Data Collected 유지.
- Tracking: No — 비맞춤형·IDFA 미사용이라 ATT 불필요(`NSUserTrackingUsageDescription` 미포함).
- Export compliance: `ITSAppUsesNonExemptEncryption = false` (표준 SDK 전송 암호화만)
- Content rights: AdMob 광고(third-party 콘텐츠) 포함 — 콘솔 콘텐츠 권리 답변에 반영. 게임 자산은 first-party.
- Age rating: 광고 있음(AdMob 전면). 폭력/도박/UGC 없음 → 4+ 예상(광고 존재 자체는 연령등급에 큰 영향 없음).
- Review notes: 확정 필요

## Assets

- App icon: 1024x1024 store icon(`app-store/assets/AppIcon-1024.png`, 알파 없음) + Xcode AppIcon.appiconset(iPhone+iPad 슬롯)
- iPhone 6.9" screenshot: `app-store/screenshots/iphone-6.9/01-board.png` (1320×2868) ✅ 실 시뮬레이터 캡처
- iPad 13" screenshot: `app-store/screenshots/ipad-13/01-board.png` (2064×2752) ✅ 실 시뮬레이터 캡처
- 캡처 방법: x86_64(Rosetta) 시뮬레이터 빌드(Godot 엔진 simulator lib가 arm64 슬라이스 없음) → iPhone 16 Pro Max / iPad Pro 13"(M4) 부팅·실행·`simctl io screenshot`.
- 비고: 게임이 720×1280로 설계돼 더 긴 화면에서 하단 레터박스(검은 영역) 발생 — Apple 허용. 더 꽉 찬 화면 원하면 게임 stretch/aspect 조정(별도 작업). 화면당 1장씩이라 다양화하려면 탭 입력 화면 수동 보완.

## Build / Upload 상태 (2026-07-07)

- ✅ **업로드 성공** — `com.etlegame.reversi` v**2.2.2** build 1 (**AdMob 전면광고 포함**), universal(iPhone+iPad), min iOS 14.0. ASC 처리 중.
- 이전: v2.2.1 build 1(광고 미포함, 2026-06-26 업로드). 2.2.2는 AdMob 포함 별도 마케팅 버전.
- 경로: Godot 4.6.3 iOS export(preset `iOS`) → `xcodebuild archive` → `xcodebuild -exportArchive`(method=app-store-connect, destination=upload).
- 서명: **개발 자동 서명(Apple Development, automatic)** 아카이브 → exportArchive(`-allowProvisioningUpdates` + ASC API 키)에서 **Apple Distribution(Seori Labs) 배포 재서명 + 업로드**. manual+Distribution은 로컬에 `com.etlegame.reversi` App Store 프로파일이 없어 실패 → automatic development로 archive 후 export 재서명이 정답.
- scheme은 **`lucidreversi`**(Godot이 xcodeproj 파일명 기반으로 생성). `deploy-app-store.yml`의 `ios_scheme`도 이 값으로 맞춤.
- 경고: GoogleMobileAds/UserMessagingPlatform prebuilt framework에 dSYM 미포함 → Upload Symbols 경고(업로드 자체는 성공). AdMob 크래시 심볼화가 불완전할 수 있음.
- ⚠️ 이 AdMob 빌드는 export 파이프라인만 검증(실기기 미검증). **TestFlight 실기기 검증 필요.**
- 자세한 빌드 노트/함정: `docs/09-knowledge/ios-app-store-godot.md`.

## 남은 콘솔/수동 게이트

- [ ] **TestFlight 실기기 검증** (AdMob 전면광고 표시·크래시 없음 — 실기기 첫 검증)
- [ ] 콘솔에서 업로드된 빌드(v2.2.2 build 1) 선택
- [x] iPhone 6.9" + iPad 13" 스크린샷 1장씩 실 캡처 (추가 화면은 선택)
- [ ] App Privacy 재작성: GA4(익명 client_id)+AdMob(비맞춤형·IDFA 미사용) 반영 / 연령등급(광고 있음 → 4+) / 콘텐츠 권리(AdMob third-party 포함) / 수출규정(false)
- [ ] 메타데이터(이 문서 카피) 콘솔 반영, Support URL 확정
- [ ] Submit for Review (실기기 검증·App Privacy 갱신 후)
