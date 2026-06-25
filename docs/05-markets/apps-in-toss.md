# AppsInToss

## App Identity

- appName: lucid-reversi
- Display name: 루시드 리버시
- Brand icon (granite `brand.icon`): `https://static.toss.im/appsintoss/38345/764909ef-3849-428b-ae2e-1f868ec00ebf.png`
- Registration logo asset (console upload): `apps-in-toss/release-assets/lucid-reversi-icon-600.png` (위 HTTPS 아이콘과 동일 이미지, 600x600, alpha 없음)
- Default locale: Korean
- Secondary in-app locale: English

## Registration Copy

- Thumbnail headline: AI와 오델로 한판!
- Subtitle: 짧게 즐기는 모바일 리버시
- Short description: 선명한 보드와 빠른 AI 대전으로 한 수씩 판세를 뒤집는 모바일 리버시 게임입니다.
- Full description: 루시드 리버시는 AI와 바로 한 판 붙는 모바일 리버시 게임입니다. 선명한 보드와 큼직한 흑백 돌, 착수와 뒤집힘 피드백으로 작은 화면에서도 다음 수가 잘 보입니다. 난이도와 보드/돌 테마를 바꾸며 짧은 시간 안에 판세를 뒤집는 재미를 즐겨보세요.
- Search keywords: 오델로, 리버시, 보드게임, AI 대전, 전략게임, 두뇌게임, 흑백돌, 캐주얼게임
- English copy is kept in `apps-in-toss/apps-in-toss.config.json` for secondary locale readiness, but AppsInToss launch copy defaults to Korean.
- `오델로` 표현은 사용자가 요청한 한국어 검색/마케팅 문구다. 최종 콘솔 입력 전 상표성 표현 리스크를 확인한다.

## Delivery

- Runtime: Godot Web export wrapper
- Wrapper path: `apps/ait/`
- Build artifact: `.ait`
- First launch priority: yes
- Build runner: private repo 기준 Web/AIT 후보 빌드는 `seorilabs-rpi-arm64` 사용 가능

## Review / Sandbox

- Sandbox QA: passed(게임 렌더/조작) — 실기기 `intoss://lucid-reversi` 로딩·동작 확인 완료(`granite dev`, Metro `8081` + vite `5173`, Android USB `adb reverse`). 인앱 광고는 샌드박스 테스트 불가 → 콘솔 출시하기 QR로 실 토스앱 검증 필요
- Registration images: local assets generated and validated
- Ads/live SDK status: 사용함 — AppsInToss **전면(Interstitial)** 광고(`loadFullScreenAd`/`showFullScreenAd`). 한 판 종료 시 1회 노출(Godot `_request_interstitial_ad` → `window.__aitShowInterstitialAd` → `src/ads.ts`).
  - 광고 ID는 **마켓별로 다름**. AIT 전용 live `adGroupId` `ait.v2.live.f2389330c1ce431a`는 `apps/ait/.env.production`에 설정 → `vite build`(=`ait build`) production 빌드에만 주입. dev/샌드박스(`granite dev`)는 `.env.production`을 안 읽어 테스트 ID `ait-ad-test-interstitial-id`로 동작(live ID의 dev 사용은 정책 위반 방지).
  - Google Play / App Store 광고는 이 wrapper가 아니라 각 마켓 네이티브 연동(예: Godot AdMob)에서 별도 ID로 관리. AIT 브리지는 web export에서만 발동(`OS.has_feature("web")`).
  - 출시용 `.ait`에는 live ID 임베드 검증 완료(production 번들 grep: live ID 포함, 테스트 ID 없음).
- Console fields: 입력 완료

## Notes

- `.ait` packaging success는 AppsInToss release readiness와 다르다.
- Godot runtime은 iframe으로 감싸지 않고 wrapper에서 직접 로드하는 방향을 기본으로 한다.
- Non-game이 아닌 게임 앱이므로 TDS는 필수 조건이 아니다.
- AppsInToss 노출 문구와 첫 실행 UI는 한국어를 기본값으로 한다.
- Godot Web/AIT 한글 렌더링과 게임 UI 가독성을 위해 OFL 라이선스 `godot/assets/fonts/DoHyeon-Regular.ttf`를 번들한다.

## Current Implementation

- Godot Web export workflow는 템플릿에서 가져왔다.
- Godot project name and initial scene title are Korean.
- In-app strings support `ko` and `en`; `settings.locale` 기본값은 `ko`다.
- Korean UI uses Do Hyeon Regular with text outlines and raised muted text contrast for small mobile HUD labels.
- `npm run check:release:ait`는 AppsInToss-first 후보 blocker만 점검한다.
- `apps/ait`는 `@apps-in-toss/web-framework`(granite) 기반 Vite React 래퍼로 스캐폴드 완료했다. `appName`은 콘솔 확정값 `lucid-reversi`로 고정.
- Godot Web export(`build/pages`)는 `npm run sync:godot`로 `apps/ait/public/godot`에 복사되고, `GodotCanvas.tsx`가 `Engine`을 직접 로드해 canvas에 렌더한다(iframe 미사용).
- `npm run build`(= `ait build`)로 `apps/ait/lucid-reversi.ait` 생성 검증 완료(약 14MB). 콘솔 업로드용은 `release-artifacts/apps-in-toss/lucid-reversi.ait`.
- 광고는 `src/ads.ts`의 AppsInToss 전면(Interstitial) 광고로 연동. 한 판 종료 시 Godot(`main.gd:_request_interstitial_ad`)가 `JavaScriptBridge`로 `window.__aitShowInterstitialAd`를 호출해 1회 노출. 광고 SDK는 토스앱 환경에서만 동작(`isSupported()`), 샌드박스/로컬 브라우저에서는 비활성.
- 실기기 샌드박스 검증: `apps/ait`에서 `npm run dev`(= `granite dev`)로 Metro 8081 + vite 5173 기동. Android USB는 `adb reverse tcp:8081 tcp:8081 && adb reverse tcp:5173 tcp:5173` 후 `intoss://lucid-reversi` 접속. `ait dev` 명령은 없음.
- Registration image assets are stored under `apps-in-toss/release-assets/`: `600x600` logo, `1932x828` thumbnail, and three `636x1048` vertical screenshots. They pass the AppsInToss registration image validation script with no alpha channel.
