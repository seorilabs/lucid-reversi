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

- Support URL: `https://www.seorilabs.com/support/` (App Review 필수. 다른 Seorilabs 앱과 같은 경로)
- Marketing URL: 비움(선택). 이 앱은 seorilabs.com에 제품 랜딩이 없다
- Copyright: `2026 Seori Labs`
- Privacy Policy URL: `https://www.seorilabs.com/apps/lucid-reversi/privacy/`

## Release

- TestFlight target: internal testing
- Signing team: `HCDUXX4Z3X`
- ASC Provider: `HCDUXX4Z3X`
- Signing: manual / `Apple Distribution` / App Store 프로비저닝 프로파일
- Build runner: macOS/Xcode runner. RPI ARC runner는 App Store build 대상이 아니다.

## Ads

- **AdMob 전면(Interstitial) 광고 탑재** (iOS·Android 공용). 한 판 종료 시 1회 노출(`_interstitial_shown_this_game` 가드).
- 플러그인: `godot-sdk-integrations/godot-admob` v6.0 (iOS·Android 공용, Godot 4.6 지원). GDScript 애드온(`godot/addons/AdmobPlugin`)과 `godot/ios/plugins/AdmobPlugin.gdip`는 커밋, xcframework(약 45MB)는 `.gitignore` → iOS export 전 `scripts/install_ios_admob_plugin.sh`로 다운로드.
- 광고 ID: App `ca-app-pub-9932778305312246~3300846492`, Interstitial `ca-app-pub-9932778305312246/5917919124`. **2026-09-22에 publisher를 `pub-2444587584524186`에서 주력 계정 `pub-9932778305312246`으로 옮겼다**(이전 ID로 올라간 빌드는 v2.2.2). 비맞춤형(`PersonalizationState.DISABLED`)·IDFA/추적 미사용.
- Info.plist 주입: `IosExportPlugin`이 export 시 `GADApplicationIdentifier` + `SKAdNetworkItems`를 자동 주입(`godot/addons/AdmobPlugin/ios_export.cfg` 기반, `is_real=true`라 릴리스엔 실 App ID). CocoaPods 불필요(self-contained xcframework, mediation 미사용 → Podfile 미생성) → org `xcodebuild archive -project` 경로 그대로.
- 어댑터: `godot/scripts/mobile_ads.gd`(bootstrap 계층, `check_architecture.sh` 경계 준수). `main.gd:_request_interstitial_ad()`에서 iOS·Android를 함께 처리. 개발/비릴리스 빌드는 AdMob 공식 테스트 ID(`OS.is_debug_build` 분기), 릴리스만 실 유닛.
- AdMob은 이제 iOS·Android 공용이다. `AdmobPlugin.gd`가 `IosExportPlugin`과 `AndroidExportPlugin`을 모두 등록한다. Android 쪽은 `android_export.cfg`와 `scripts/build_admob_plugin.sh`(aar 다운로드)가 함께 간다.

## Privacy / Review

- **App Privacy: 확정(2026-09-22).** 근거는 앱에 실제 포함된 `GoogleMobileAds.framework/PrivacyInfo.xcprivacy`의 `NSPrivacyCollectedDataTypes`다. 임의 판단이 아니다.

  | 구획 | 데이터 타입 | 목적 |
  |---|---|---|
  | Linked to You | Location / Coarse Location | Third-Party Advertising, Analytics |
  | Linked to You | Identifiers / Device ID | Third-Party Advertising, Analytics |
  | Linked to You | Usage Data / Advertising Data | Third-Party Advertising, Analytics |
  | Linked to You | Usage Data / Product Interaction | Third-Party Advertising, Analytics |
  | Not Linked | Diagnostics / Crash Data | Analytics |
  | Not Linked | Diagnostics / Performance Data | Third-Party Advertising, Analytics |
  | Not Linked | Diagnostics / Other Diagnostic Data | Third-Party Advertising, Analytics |

  - `Developer's Advertising or Marketing` 목적은 체크하지 않는다. 자체 마케팅에 쓰지 않는다.
  - GA4는 익명 `client_id`와 게임 이벤트만 보낸다. 계정이 없어 신원 연결이 없고 위 Device ID / Product Interaction(Analytics)에 포함된다. 별도 항목을 더하지 않는다.
  - **App Privacy는 ASC API에 엔드포인트가 없다**(`appDataUsages`, `appPrivacyDetails` 등 전부 404). 콘솔에서만 입력한다.
- **Tracking: No.** 비맞춤형 광고만 요청(`PersonalizationState.DISABLED`), IDFA 미사용, ATT 프롬프트 없음(`ios_export.cfg att_enabled=false` → 빌드에 `NSUserTrackingUsageDescription` 없음). ATT 없이 Tracking=Yes로 신고하면 오히려 반려된다.
- Export compliance: `ITSAppUsesNonExemptEncryption = false`. 업로드된 빌드의 `usesNonExemptEncryption=false`로 ASC에서 확인했다.
- Content rights: **`USES_THIRD_PARTY_CONTENT`로 변경 완료(2026-09-22, API)**. AdMob 크리에이티브가 third-party 콘텐츠이고 게재 권리는 AdMob 약관으로 갖는다. 게임 자산이 first-party라는 이유로 "없음"을 고르면 안 된다.
- Age rating: `advertising: true`가 이미 선언돼 있다. 폭력/도박/UGC 없음 → `FOUR_PLUS` 유지.
- Review notes: **영어로 쓴다**(심사팀이 읽는 산출물). 전문은 `app-store/app-store.config.json`의 `listing.reviewNotes`.

## Assets

- App icon: 1024x1024 store icon(`app-store/assets/AppIcon-1024.png`, 알파 없음) + Xcode AppIcon.appiconset(iPhone+iPad 슬롯)
- iPhone 6.9" screenshot: `app-store/screenshots/iphone-6.9/01-board.png` (1320×2868) ✅ 실 시뮬레이터 캡처
- iPad 13" screenshot: `app-store/screenshots/ipad-13/01-board.png` (2064×2752) ✅ 실 시뮬레이터 캡처
- 캡처 방법: x86_64(Rosetta) 시뮬레이터 빌드(Godot 엔진 simulator lib가 arm64 슬라이스 없음) → iPhone 16 Pro Max / iPad Pro 13"(M4) 부팅·실행·`simctl io screenshot`.
- ASC 슬롯 이름은 `APP_IPHONE_67` / `APP_IPAD_PRO_3GEN_129`다. 6.9"·13" 캡처가 이 슬롯에 들어간다(Apple이 통합).
- 비고: 720×1280 기준 배치는 유지하며, 더 긴 화면에서는 늘어난 논리 높이를 플레이 컨트롤 위 여백으로 흡수해 하단 데드 스페이스 증가를 막는다. 화면당 1장씩이라 다양화하려면 탭 입력 화면 수동 보완.

## 출시 상태 (2026-09-22 ASC API 확인)

- **이 앱은 이미 App Store에 공개 판매 중이다.** `2.2.0`~`2.2.3`이 모두 `READY_FOR_SALE`이고, 현재 스토어에 보이는 건 **2.2.3**이다.
- 활성 로케일은 **`en-US`와 `ko` 둘뿐**이다. Play와 달리 `ja`가 없다.
- ⚠️ **v2.2.6(build 2002006)은 2026-09-18 업로드만 되고 `appStoreVersion` 레코드를 만들지 않아 심사에 제출되지 않았다.** 업로드 성공은 제출이 아니다. 이 함정 때문에 2.2.6이 스토어에 나가지 않았다.
- 빌드 번호 규칙: 마케팅 버전을 `major*1000000 + minor*1000 + patch`로 인코딩한다(2.2.8 → `2002008`).

## v2.2.8 심사 준비 (2026-09-22)

- ✅ 업로드: GitHub Actions run `35698910461` → build `2002008`, `processingState=VALID`
- ✅ `appStoreVersion` 2.2.8 생성(`releaseType=AFTER_APPROVAL`), 빌드 연결
- ✅ 출시노트(`whatsNew`) `ko`/`en-US` 기록
- ✅ 콘텐츠 권리 `USES_THIRD_PARTY_CONTENT`
- ✅ 심사 노트(영어) + 연락처
- ✅ 스크린샷: 이전 버전에서 두 슬롯 모두 승계(`COMPLETE`)
- ✅ App Privacy 콘솔 입력(위 표) — 콘솔 요약이 `이 앱에서 수집되는 7개의 데이터 유형: 충돌 데이터, 실적 데이터, 기타 진단 데이터, 제품 상호 작용, 대략적인 위치, 기기 ID, 광고 데이터`로 바뀐 것까지 확인했다. 바꾸기 전에는 비연결 4건만 있었다.
- ✅ **Submit for Review 완료** — `reviewSubmission 22ef8345-bc90-4896-9b2b-db8404f3a912`, 제출 시각 `2026-09-22T07:51:06Z`, 버전 상태 `WAITING_FOR_REVIEW`

## 남은 콘솔/수동 게이트

- [x] 업로드된 빌드를 버전에 연결(build 2002008)
- [x] iPhone 6.9" + iPad 13" 스크린샷
- [x] 콘텐츠 권리 / 연령등급 광고 선언 / 수출규정
- [x] **App Privacy 콘솔 입력** — 위 표대로 7건 게시 완료
- [x] **Submit for Review** — 2026-09-22 제출, `WAITING_FOR_REVIEW`
- [ ] 심사 결과 확인(승인 시 `releaseType=AFTER_APPROVAL`이라 자동 출시된다)
- [ ] TestFlight 실기기에서 AdMob 전면광고 재확인(v2.2.2에서 표시 확인 완료, 이후 빌드 미검증)
