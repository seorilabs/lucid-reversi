# AppsInToss

## App Identity

- appName: lucid-reversi
- Display name: 루시드 리버시
- Brand icon (콘솔 관리. 3.x config 스키마에서 제거됨): `https://static.toss.im/appsintoss/38345/764909ef-3849-428b-ae2e-1f868ec00ebf.png`
- Registration logo asset (console upload): `apps-in-toss/release-assets/lucid-reversi-icon-600.png` (위 HTTPS 아이콘과 동일 이미지, 600x600, alpha 없음)
- Default locale: Korean
- Secondary in-app locales: English, Japanese

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
- Build runner: private repo 기준 Web/AIT 후보 빌드는 `seorilabs-x64` 사용 가능

## Review / Sandbox

- Sandbox QA: passed(게임 렌더/조작) — 실기기 `intoss://lucid-reversi` 로딩·동작 확인 완료(`granite dev`, Metro `8081` + vite `5173`, Android USB `adb reverse`). 인앱 광고는 샌드박스 테스트 불가 → 콘솔 출시하기 QR로 실 토스앱 검증 필요
- Registration images: local assets generated and validated
- Ads/live SDK status: 사용함 — AppsInToss **전면(Interstitial)** 광고(`loadFullScreenAd`/`showFullScreenAd`). 한 판 종료 시 1회 노출(Godot `_request_interstitial_ad` → `JavaScriptBridge.get_interface("__aitBridge").showInterstitialAd()` → `src/ads.ts`). AppsInToss 보안 정책상 `JavaScriptBridge.eval`(외부 코드 문자열 실행)은 금지되어 eval 없는 `get_interface` 브리지를 사용한다.
- Result share: 결과 오버레이의 공유 버튼이 Godot `__aitBridge.shareResult(text)` → wrapper `src/share.ts` → AppsInToss `setClipboardText`로 로컬라이즈된 승패·최종 점수를 복사한다. `granite.config.ts`에는 clipboard write 권한만 선언하며 권한 거부·채널 부재는 no-op 한다.
  - 광고 ID는 **마켓별로 다름**. AIT 전용 live `adGroupId` `ait.v2.live.f2389330c1ce431a`는 `apps/ait/.env.production`에 설정 → `vite build`(=`ait build`) production 빌드에만 주입. dev/샌드박스(`granite dev`)는 `.env.production`을 안 읽어 테스트 ID `ait-ad-test-interstitial-id`로 동작(live ID의 dev 사용은 정책 위반 방지).
  - Google Play / App Store 광고는 이 wrapper가 아니라 각 마켓 네이티브 연동(예: Godot AdMob)에서 별도 ID로 관리. AIT 브리지는 web export에서만 발동(`OS.has_feature("web")`).
  - 출시용 `.ait`에는 live ID 임베드 검증 완료(production 번들 grep: live ID 포함, 테스트 ID 없음).
- Console fields: 입력 완료

## Notes

- `.ait` packaging success는 AppsInToss release readiness와 다르다.
- Godot runtime은 iframe으로 감싸지 않고 wrapper에서 직접 로드하는 방향을 기본으로 한다.
- Non-game이 아닌 게임 앱이므로 TDS는 필수 조건이 아니다.
- AppsInToss 노출 문구와 첫 실행 UI는 한국어를 기본값으로 한다.
- Godot Web/AIT 한글 렌더링에는 OFL 라이선스 `godot/assets/fonts/DoHyeon-Regular.ttf`를 번들하고, 일본어 글리프에는 `godot/assets/fonts/MPLUSRounded1c-Regular.ttf` fallback을 사용한다.

## Current Implementation

- Godot Web export workflow는 템플릿에서 가져왔다.
- Godot project name and initial scene title are Korean.
- In-app strings support `ko`, `en`, and `ja`; `settings.locale` 기본값은 `ko`이며 일본어 기기 신규 설치는 `ja`를 선택한다.
- Korean/Latin UI uses Do Hyeon Regular, Japanese glyphs use bundled M PLUS Rounded 1c fallback, and all labels retain text outlines and raised muted text contrast.
- `npm run check:release:ait`는 AppsInToss-first 후보 blocker만 점검한다.
- `apps/ait`는 `@apps-in-toss/web-framework`(granite) 기반 Vite React 래퍼로 스캐폴드 완료했다. `appName`은 콘솔 확정값 `lucid-reversi`로 고정.
- Godot Web export(`build/pages`)는 `npm run sync:godot`로 `apps/ait/public/godot`에 복사되고, `GodotCanvas.tsx`가 `Engine`을 직접 로드해 canvas에 렌더한다(iframe 미사용).
- `npm run build`(= `ait build`)로 `apps/ait/lucid-reversi.ait` 생성 검증 완료(약 14MB). 콘솔 업로드용은 `release-artifacts/apps-in-toss/lucid-reversi.ait`.
- 광고는 `src/ads.ts`의 AppsInToss 전면(Interstitial) 광고로 연동. 한 판 종료 시 Godot(`main.gd:_request_interstitial_ad`)가 `JavaScriptBridge.get_interface("__aitBridge")`로 wrapper가 노출한 전역 객체를 받아 `showInterstitialAd()`를 호출해 1회 노출. AppsInToss 보안 정책상 `JavaScriptBridge.eval`은 금지되어 eval 없는 `get_interface` 브리지를 쓰며, sync 시 엔진 로더(`index.js`)의 `_godot_js_eval` 본문 eval 호출도 제거한다(`scripts/sync-godot-web.mjs`). 광고 SDK는 토스앱 환경에서만 동작(`isSupported()`), 샌드박스/로컬 브라우저에서는 비활성.
- 실기기 검증: **3.x부터는 콘솔 QR(배포 후 `intoss-private://` 링크)로 한다.** `granite dev`/`ait dev`가 모두 없어져 Metro 8081 경로는 더 이상 쓰지 않는다. 로컬 개발은 `npm run dev`(= `vite --host`)와 devtools mock SDK로 한다.
- Registration image assets are stored under `apps-in-toss/release-assets/`: `600x600` logo, `1932x828` thumbnail, and three `636x1048` vertical screenshots. They pass the AppsInToss registration image validation script with no alpha channel.

## web-framework 3.x 업그레이드 (2026-09-22)

`@apps-in-toss/web-framework`를 **2.10.7 → 3.5.0**으로 올렸다. 공식 명령 `ait migrate v3`로 변환했다(수동 편집 아님).

### 바뀐 것

| 2.x | 3.x |
|---|---|
| `granite.config.ts` | `apps-in-toss.config.ts` |
| `brand.displayName`, `brand.icon` | **제거** — 콘솔에서 관리 |
| `outdir` | `webBundleDir` |
| `web.host` / `web.port` / `web.commands` | **제거** — `package.json` 스크립트로 이동 |
| `ait build`가 웹 빌드까지 수행 | **`ait build`는 `webBundleDir`를 그대로 패킹만 한다.** 앞에 `vite build`가 필요 |
| `granite dev` (Metro 8081 + vite 5173) | `vite --host`. **`ait dev`/`granite dev` 둘 다 없다** |
| — | `@apps-in-toss/devtools` 추가(브라우저 mock SDK) |
| — | `ait deploy --timeout` **삭제** — 업로드 대기시간을 늘릴 수단이 없다 |
| — | `navigationBar`, `webView` config 지원 |

`package.json` 스크립트: `dev`는 `vite --host`, `build`는 `tsc --noEmit && vite build && ait build`.

`ait deploy`의 `--api-key` / `--memo` / `--location`은 그대로라 org 재사용 워크플로(`godot-deploy-ait.yml`)의 `npm run deploy -- ...` 계약은 깨지지 않는다.

**다만 2.x에 있던 `--timeout`이 3.x에서 사라졌다.** 워크플로가 그 옵션을 쓰지 않으니 무해하다고 볼 게 아니라, **업로드가 느릴 때 늘릴 수단이 없어진 것**이 리스크다. 실제로 v2.2.9 첫 배포가 약 106초 만에 `최대 대기시간을 초과했어요`로 실패했다. 같은 아티팩트를 재시도하니 **17초 만에 성공**해 일시적 장애로 판명됐다. 크기 문제도 아니다 — lucid-chess는 Godot 번들이 47MB인데도 3.x로 배포에 성공한다(우리는 15MB). **배포가 타임아웃으로 실패하면 먼저 그대로 재시도한다.**

### 검증한 것

- `npm run build` 성공 → `lucid-reversi.ait` 생성. `.ait` 안에 `sources/assets/index-*.js`와 `sources/godot/*`가 정상 포함됐다.
- **devtools가 프로덕션 번들에 섞이지 않는다.** 이 플러그인은 web-framework를 mock으로 alias하므로 배포 번들에 들어가면 실 SDK 대신 mock이 올라간다. `vite build` 산출물에서 `devtools`/`mock`/`panel` 문자열이 **0건**이고 실제 SDK 참조만 남은 것을 확인했다.
- **devtools는 `command === 'serve'`일 때만 켠다.** 플러그인 자체도 `NODE_ENV !== "production"`으로 스스로를 끄지만 그건 환경변수 의존 방어라 뚫린다. 실측으로 확인했다.

  | 빌드 | 번들 크기 | `devtools` | `mock` | `panel` |
  |---|---|---|---|---|
  | 정상(`vite build`) | 198KB | 0 | 0 | 0 |
  | 플러그인 무조건 등록 + `NODE_ENV=development` | **852KB** | 14 | **7** | **23** |
  | `command==='serve'` 제한 + `NODE_ENV=development` | 385KB | 3 | 0 | 0 |

  두 번째 행이 사고다. mock SDK가 통째로 들어간다. 세 번째 행의 `devtools` 3건은 React의 `react-devtools` 안내 문자열이라 무관하다. lucid-chess도 같은 이유로 `command` 기준 제한을 쓴다.
- 의존성이 1686개 줄었다. 2.x가 끌고 오던 React Native 계열이 빠졌다.

### 출시 전 반드시 볼 것

- ⚠️ **3.x 번들을 출시하면 2.x로 롤백할 수 없다.** 마이그레이션 도구가 명시한 경고다. 콘솔 QR로 실기기 검증을 끝낸 뒤 출시한다.
- ⚠️ **CORS 정책이 바뀐다.** 외부 API를 호출한다면 Origin 허용 목록에 아래를 등록해야 한다.
  - `https://lucid-reversi.web.tossmini.com` (실서비스)
  - `https://lucid-reversi.private-web.tossmini.com` (콘솔 QR 테스트)

  이 앱의 래퍼(`apps/ait/src`)는 외부 도메인을 직접 호출하지 않는다. Godot 번들이 GA4 Measurement Protocol(`www.google-analytics.com/mp/collect`)로 전송하는데, 이 엔드포인트는 우리가 Origin 목록을 관리하는 대상이 아니다. **3.x 첫 배포 후 GA4 이벤트가 실제로 들어오는지 확인이 필요하다.**
- ~~실기기 샌드박스 접속 방식이 3.x에서도 같은지 확인하지 못했다.~~ → **해소.** 3.x는 배포 후 콘솔 QR로 검증한다.

### 실기기 검증 (2026-09-22, v2.2.10)

**콘솔 QR 실기기에서 게임이 정상 실행되는 것을 확인했다.** 사용자 확인.

여기까지 오는 데 두 번의 실패가 있었고 원인이 서로 달랐다. 3.x로 올리는 다른 Godot 프로젝트도 같은 순서로 밟게 된다.

| 배포 | 결과 | 원인 |
|---|---|---|
| v2.2.9 (1차) | 업로드 실패 | `ait deploy` 타임아웃 106초. 재시도로 17초에 성공 |
| v2.2.9 (2차) | 업로드 성공, **게임 안 열림** | 아래 두 가지가 겹침 |
| v2.2.10 | **정상** | 두 원인 모두 해소 |

#### 게임이 안 열린 원인 두 가지

**(a) emscripten Safari 게이트가 Android 웹뷰를 막았다.** emscripten은 UA에 `Safari/`가 있고 `Version/x`가 잡히면 Safari로 보고 v15.2.0 미만이면 실행을 중단한다. Android WebView UA는 `... Version/4.0 Chrome/152.0.0.0 Mobile Safari/537.36`이라 Safari 4.0으로 오인된다.

```
This emscripten-generated code requires Safari v15.2.0 (detected v040000)
```

`sync-godot-web.mjs`의 `relaxEmscriptenSafariGate()`가 UA에 `Chrome/`이 있으면 Safari 분기를 타지 않게 로더를 고친다. **이 게이트는 Godot 4.6.3(CI)에는 있고 4.7.2(로컬)에는 없다.** 없으면 통과시키되 `requires Safari` 문구만 남았으면 미니파이가 바뀐 것이므로 실패시킨다.

**(b) `ait migrate v3`가 게임 웹뷰 모드 키를 떨어뜨렸다.** 없으면 큰 wasm이 instantiate 되지 않아 스플래시에서 멈춘다. 3.5.0 설정 타입에는 없지만 CLI가 `bundle.json`에 그대로 직렬화해 플랫폼까지 전달한다. `apps-in-toss.config.ts`에서 변수로 분리해 넣는다(객체 리터럴을 직접 넘기면 초과 속성 검사에 걸린다).

#### 재현·검증 방법

배포 번들을 Android WebView UA로 열면 실기기 없이 재현된다.

```
Mozilla/5.0 (Linux; Android 15; SM-S913N) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/152.0.0.0 Mobile Safari/537.36
```

| | 패치 전 | 패치 후 |
|---|---|---|
| canvas | 300x150 (초기값) | 390x844 |
| Godot 배너 | 없음 | 출력됨 |
| 에러 | `requires Safari v15.2.0 (detected v040000)` | 없음 |

배포본 `ait-lucid-reversi-v2.2.10-52`에서 `bundle.json`의 `webView.type=game`, Safari 게이트 완화, 옛 게이트 잔존 없음을 확인했다.

#### 함께 고친 것 — eval sanitizer가 미니파이 패턴에 기대고 있었다

Godot 4.7.2는 wasm import 매핑을 `$e:_godot_js_eval`로 줄인다. 기존 sanitizer는 `godot_js_eval:_godot_js_eval` 패턴만 찾아 정의만 리네임하고 참조를 남겼고, 브라우저에서 `_godot_js_eval is not defined`로 죽었다. 회귀 가드는 `godot_js_eval`을 예외로 지운 뒤 검사해서 잔여 참조가 `_`로 줄어 그대로 통과했다. 전체 치환으로 바꾸고 가드 예외를 없앴다. CI는 4.6.3을 써서 배포본에는 영향이 없었지만 로컬 4.7.2 빌드는 깨져 있었다.

### 출시 (2026-09-22)

- [x] **콘솔 출시(release) 완료** — v2.2.10(SDK 3.5.0). 사용자가 콘솔에서 직접 수행했다.
  - 이 시점부터 **2.x로 롤백할 수 없다.** 이후 문제가 생기면 3.x 위에서 고쳐 재배포한다.
  - 콘솔 출시 상태는 AIT CLI/API로 조회할 방법이 없어 콘솔에서만 확인된다.

### 남은 확인

- [ ] 결과 공유(클립보드 복사) 실기기 동작 확인
- [ ] 전면광고 노출 확인 (live `adGroupId` 주입 경로는 `vite build` 그대로라 유지)
- [ ] GA4 이벤트 유입 확인 — 3.x CORS 변경과 도메인 변경(`lucid-reversi.web.tossmini.com`) 영향을 실측해야 한다. 게임이 Measurement Protocol로 직접 전송하므로 출시 후 실사용 이벤트로 확인한다.

### lucid-chess 3.x 전환 선례 대조 (seorilabs/lucid-chess#283)

같은 조직의 lucid-chess가 먼저 3.x로 갔다. 거기서 터진 문제를 항목별로 대조했다.

| lucid-chess가 겪은 문제 | 루시드 리버시 |
|---|---|
| 자동 변환이 `dev`/`build`에 직접 넣어둔 `sync:godot`을 지웠다 | 해당 없음. `predev`/`prebuild` 훅을 써서 npm이 자동 실행한다 |
| 자동 변환이 보안 검사(`check:ait:security`)를 빌드에서 지웠다 | 해당 없음. eval 처리·회귀 가드가 `sync-godot-web.mjs` 안에 있고 `prebuild`로 항상 돈다 |
| 보안 검사가 업로드보다 먼저여야 한다 | 순서 유지: `sync:godot` → `vite build` → `ait build` |
| devtools `^3.4.0`이 미배포라 `npm install`이 `ETARGET`으로 실패 | 해당 없음. 3.5.0은 실제 배포돼 있다 |
| devtools를 `command === 'serve'`로 제한해야 한다 | **처음엔 놓쳤고 뒤에 반영했다**(위 표) |
| `granite.config.ts` 잔여 참조로 릴리스 검사가 깨진다 | `scripts/check_release_readiness.sh`와 문서를 새 경로로 옮겼다 |
| `webViewProps` → `webView` | 해당 없음(`webViewProps` 미사용) |

**교훈**: `ait migrate v3`는 `dev`/`build` 스크립트를 통째로 덮어쓴다. 그 스크립트에 프로젝트 고유 단계를 체인으로 넣어 뒀다면 소리 없이 사라진다. `pre*` 훅으로 분리해 두면 살아남는다.

배포 아티팩트도 직접 열어 확인했다. `sources/godot/index.js`에 유지 대상 `godot_js_eval` 키를 뺀 eval 토큰이 **0건**이고, no-op 치환과 `_godot_js_run` 리네임이 적용돼 있다.
