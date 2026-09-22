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

## Play Console 실측 (2026-09-22)

`Seolee Apps` 개발자 계정(계정 ID `5547060480954653351`)에서 읽기 전용으로 확인했다.
프로덕션은 `활성`, **활성 기기 15대**, 171개 국가다. 활성 기기가 적어 승계로 인한 기존 사용자
영향은 작다.

### 승계 때문에 옛 게임 기준으로 남은 선언 — 교체 전 정리 대상

| 항목 | Console 현재 값 | 실제 |
|---|---|---|
| 광고 ID | `앱에서 광고 ID를 사용한다고 지정하셨습니다`(2022-09-16) | **2026-09-22 AdMob 탑재로 사실과 맞아졌다.** SDK가 `AD_ID` 권한을 manifest merge로 넣으므로 정정 불필요 |
| 콘텐츠 등급 | IARC 완료지만 설문이 **2015-06-02** 제출본 | 리브랜딩 후 재설문 필요. 대한민국은 `Google Play 3세 이상`이고 GRAC 별도 등급은 표시되지 않음 |
| 개인정보처리방침 | `http://35.221.214.124/privacypolicy.html`(2019-06-13) | 평문 HTTP + 원시 IP. 교체 필요 |
| 스토어 등재정보 | `Reversi Online`, 온라인 대전·차례 알림·멀티플레이 설명 | `play-store/listing/`의 새 문안으로 교체 예정 |

**광고 탑재로 바뀐 것**: 2026-09-22에 Android AdMob을 탑재해 위 표의 정리 방향이 달라졌다.
광고 포함 선언은 아니오에서 **예**로 바꿔야 하고, 콘텐츠 등급 재설문은 **광고 포함**으로 답해야 하며,
데이터 보안에는 AdMob 수집 항목을 반영해야 한다. 광고 ID 선언만은 정정이 필요 없어졌다.

### 확인된 상태

- 앱 액세스 권한: `특수한 액세스 권한 없이 모든 기능 이용 가능` — 현재 구현과 일치
- 광고 포함 선언: **아니오** — 광고 탑재 전 기준이라 새 빌드 업로드와 함께 **예로 바꿔야 한다**
- 데이터 보안: `앱에서 데이터를 수집 또는 공유하지 않습니다`(2025-10-09).
  GA4 Measurement Protocol로 익명 `client_id`를 외부 전송하므로 **재검토가 필요한 지점**이다.
- 건강 앱·금융 기능: 해당 없음으로 완료(2025-10-09)
- **정부 앱 선언만 미완료** — 앱 콘텐츠의 유일한 `주의 필요` 항목
- 타겟층: 6~8세부터 만 18세 이상까지
- Play 앱 서명: `사용 중`, 업로드 키 인증서 등록됨 — 승계 경로가 열려 있음을 확인
- 기본 언어 `en-US`, 등록 언어는 `en-US`, `ko-KR` 2개

### 타겟 API 정책 오류 2건 — 새 빌드로 해소된다

프로덕션의 규정 미준수 최고 대상 API 수준이 **Android 10(API 29)**이다.

1. 제공 범위 제한 — `Android 15(API 35) 이상을 타겟팅해야 함` (2023-08-31부터)
2. 업데이트 거부 — `Android 16(API 36) 이상을 타겟팅해야 함` (**2026-08-31 시행**)

Godot 4.6.3과 4.7.2의 Android build template 모두 `config.gradle`의 기본
`targetSdk`가 **36**이고, export preset의 `gradle_build/target_sdk`가 비어 있으면 그 기본값을
쓴다. 따라서 새로 빌드한 AAB는 두 요건을 모두 충족한다. 기존 versionCode 47(API 29) 때문에
표시되는 오류이며, 새 빌드를 올리면 해소된다.

## 업로드 blocker — WIF impersonation 권한 (2026-09-22, 미해소)

v2.2.7(versionCode 49) internal 업로드가 세 번 실패했다. 빌드·서명·AdMob 검증은 모두 통과했고
업로드 단계에서만 막힌다.

| 시도 | 실패 지점 | 조치 |
|---|---|---|
| 1 | `Backoffice package_name binding이 없다` | caller에 `package_name` 추가(#145)로 해소 |
| 2, 3 | `GOOGLE_PLAY_EDIT_CREATE_FAILED` | **미해소** — 아래 원인 |

org 업로더는 provider 에러 텍스트를 숨기고 코드만 남긴다(`never prints provider error text`).
같은 WIF 경로로 `edits().insert()`를 직접 호출하는 임시 진단 워크플로우를 돌려 실제 오류를 얻었다.

```
token refresh FAILED: RefreshError ('Unable to acquire impersonated credentials', ...
  "message": "Permission 'iam.serviceAccounts.getAccessToken' denied on resource ...",
  "status": "PERMISSION_DENIED", "reason": "IAM_PERMISSION_DENIED"
```

GitHub OIDC로 받은 principalSet이 `seorilabs-play-publisher` SA를 impersonate할 수 없다.
**WIF 바인딩은 저장소마다 따로 부여해야 하는데 이 저장소 몫이 없다.** 같은 SA의 키 파일로는
로컬에서 edit 생성이 정상이므로 SA 자체의 Play 권한과 scope는 문제가 아니다.

`babycare`가 2026-08-07에 같은 blocker를 겪고 저장소별 바인딩으로 해소한 선례가 있다
(`babycare/docs/06-release/store-upload-setup.md`).

해소 명령(프로젝트 IAM 권한을 가진 계정으로 실행해야 한다. `seorilabs-provisioner`는
`iam.serviceAccounts.getIamPolicy`가 없어 거부된다):

```bash
gcloud iam service-accounts add-iam-policy-binding \
  seorilabs-play-publisher@seorilabs-gws.iam.gserviceaccount.com \
  --project=seorilabs-gws \
  --role=roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/138773558853/locations/global/workloadIdentityPools/github-actions/attribute.repository/seorilabs/lucid-reversi"
```

함께 확인된 것: org var `GOOGLE_PLAY_UPLOAD_KEY_ALIAS`의 selected 저장소 목록에 이 저장소가
없어 CI에서 값이 비어 있었다. 카탈로그의 `lucid-reversi-upload`를 repo var로 넣어 해소했다.

## Policy / Data Safety

- Ads: **AdMob 전면(Interstitial) 광고 탑재**(2026-09-22). 한 판 종료 시 1회 노출.
  - Android App ID `ca-app-pub-9932778305312246~6509011613`, Interstitial `ca-app-pub-9932778305312246/7985744813`
  - 비맞춤형(`PersonalizationState.DISABLED`)
  - `AndroidExportPlugin`이 `android_export.cfg`를 읽어 `com.google.android.gms.ads.APPLICATION_ID` meta-data를 주입한다. 이 meta-data 없이 SDK만 링크되면 앱 시작 시 크래시한다.
  - AdMob SDK(`play-services-ads:24.9.0`)가 manifest merge로 `com.google.android.gms.permission.AD_ID`와 `ACCESS_ADSERVICES_*`를 자동 추가한다. **Play Console의 "광고 ID 사용" 선언이 이제 사실과 맞는다.**
  - 네이티브 aar은 `.gitignore` 대상. `scripts/build_admob_plugin.sh`가 받아 배치하며 org Play 워크플로우가 export 직전에 자동 호출한다.
  - 필요한 repo vars: `ADMOB_APP_ID`, `ADMOB_INTERSTITIAL_AD_UNIT_ID`(org 워크플로우가 테스트 ID가 아닌지 검증만 한다)
- In-app purchases: 없음
- Analytics: GA4 Measurement Protocol(REST, `godot/scripts/ga4_mp_sender.gd`). Firebase SDK 미사용 → google-services.json/Firebase Android app 불요.
- Crash reporting: 없음(Firebase Crashlytics 미사용)
- Account deletion requirement: 계정 기능 없음. Firebase Auth를 추가하지 않는 한 삭제 URL 대상 아님.
- 개인정보처리방침: `https://www.seorilabs.com/apps/lucid-reversi/privacy/` (seorilabs-official PR #32로 추가).
  Play Console에 등록된 옛 URL `http://35.221.214.124/privacypolicy.html`(2019, 평문 HTTP + 원시 IP)을 이걸로 교체한다.

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
- **런처 아이콘은 서리 랩스 로고로 채웠다**(2026-09-22). `godot/branding/android/`의
  `launcher_192.png`, `adaptive_foreground_432.png`, `adaptive_background_432.png`를
  export preset의 `launcher_icons/*`에 연결했다. 부트 스플래시(`splash_screen/icon`)와 같은
  로고라 실행 흐름이 이어진다. 스토어 아이콘(흑백 돌)과는 의도적으로 다르다.
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
- **플랫폼 SDK vendoring 완료(2026-09-22)**: `godot/addons/seorilabs_platform` v0.7.8.
  GitHub Release asset(`seorilabs-platform-gdscript-0.7.8.tar.gz`)을 `.sha256`으로 검증한 뒤 풀었고,
  `SOURCE`가 그 asset URL을 가리킨다. plugin.cfg 없는 순수 스크립트 라이브러리라 editor plugin
  등록은 필요 없다. `seorilabs/platform` 레지스트리에 `lucid-reversi`는 이미 `active`이고
  `features`는 `firebase_custom_token_bridge`만 true, 나머지(config·events·iap·ads)는 false다.
  기능을 켜는 배선은 후속 작업이며, 그때 `docs/07-qa/test-strategy.md`의 "platform SDK import는
  adapter 계층으로 제한한다" 규칙을 따른다.
- 실 배포 전 필요한 GitHub secrets/vars:
  - secrets: `GOOGLE_PLAY_UPLOAD_KEYSTORE_BASE64`, `GOOGLE_PLAY_UPLOAD_KEYSTORE_PASSWORD`, `GOOGLE_PLAY_UPLOAD_KEY_PASSWORD`
  - vars: `GOOGLE_PLAY_UPLOAD_KEY_ALIAS`, `GOOGLE_WORKLOAD_IDENTITY_PROVIDER`, `GOOGLE_PLAY_SERVICE_ACCOUNT_EMAIL`
  - AdMob vars: `ADMOB_APP_ID`, `ADMOB_INTERSTITIAL_AD_UNIT_ID` **설정 완료**(2026-09-22). org 워크플로우는 테스트 ID가 아닌지 검증만 한다.
- **AAB 빌드 검증 완료(2026-09-21)**: `Deploy to Google Play`(upload=false, main) run
  [35612098803](https://github.com/seorilabs/lucid-reversi/actions/runs/35612098803) 성공.
  `build/android/lucid-reversi.aab`, versionName 2.2.6 / versionCode 48, 업로드 키 서명까지 통과했다.
  2026-08-29 실패 원인(`Target folder does not exist: "build/android"`)은 org 워크플로우에서 이미
  해결돼 재현되지 않았다.
- 남은 것: 등재정보 텍스트 교체 반영, store graphics(아이콘/피처그래픽/스크린샷) 제작,
  Android 런처 아이콘 자산(현재 preset은 기본 아이콘), 앱 콘텐츠 섹션(Data safety·콘텐츠 등급·
  광고 선언·target API) 재확인. 앱 레코드는 승계라 새로 만들지 않는다.
