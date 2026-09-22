# AppsInToss Wrapper

Godot Web export를 AppsInToss(`@apps-in-toss/web-framework` 3.x)로 패키징하는 래퍼다.

## 구성

- AppsInToss `appName`: `lucid-reversi` (콘솔 확정값)
- `brand`: 3.x에서는 `primaryColor`만 둔다. `displayName`/`icon`은 스키마에서 빠졌고 콘솔에서 관리한다.
- Godot Web export 원본: `build/pages/` → `npm run sync:godot`로 `public/godot/`에 복사. 이때 AppsInToss 보안 정책(eval 금지)에 맞춰 엔진 로더 `index.js`의 `_godot_js_eval` 본문 eval 호출을 제거한다(`scripts/sync-godot-web.mjs`).
- Web export 렌더: `src/GodotCanvas.tsx`가 `index.js`의 `Engine`을 직접 로드해 canvas에 렌더
- 인앱 광고: `src/ads.ts` (AppsInToss 전면/Interstitial). 한 판 종료 시 Godot `_request_interstitial_ad`가 `JavaScriptBridge.get_interface("__aitBridge").showInterstitialAd()`(eval 미사용)로 노출. wrapper는 `App.tsx`에서 `window.__aitBridge`를 등록한다.
- 결과 공유: Godot 결과 버튼이 `__aitBridge.shareResult(text)`를 호출하면 wrapper의 `src/share.ts`가 AppsInToss `setClipboardText`로 복사한다. 클립보드 쓰기 권한이 없거나 SDK가 지원되지 않으면 안전하게 no-op 한다.

## 명령어

```bash
npm install
npm run sync:godot   # build/pages → public/godot 복사
npm run dev          # vite --host (3.x에는 ait dev/granite dev 가 없다)
npm run build        # ait build → lucid-reversi.ait 생성
```

> 3.x는 Metro를 쓰지 않는다. `vite --host`만 띄우고, 브라우저에서는 `@apps-in-toss/devtools`가 SDK를 mock으로 바꿔 준다(개발 빌드 한정). 실기기 검증은 콘솔 QR(`https://lucid-reversi.private-web.tossmini.com`)로 한다.

### Android 실기기 샌드박스 (USB)

```bash
adb reverse tcp:8081 tcp:8081
adb reverse tcp:5173 tcp:5173
```

샌드박스 앱에서 `intoss://lucid-reversi` 접속. (iOS/와이파이는 `web.host`를 PC LAN IP로 두고 접속)

**주의: 인앱 광고는 샌드박스에서 테스트 불가.** 콘솔 '출시하기' QR로 실제 토스앱에서만 검증된다. 따라서 한 판 종료 시 전면 광고는 샌드박스에서 노출되지 않는 게 정상이다(게임 동작은 정상).

## Guardrails

- Godot runtime은 iframe으로 감싸지 않는다. 생성된 JS runtime/canvas를 래퍼에서 직접 로드한다.
- 개발/QA에서는 테스트 광고 ID(`ait-ad-test-*`)만 사용한다. 실 광고 ID 테스트는 정책 위반이다.
- `.ait` 생성 성공은 콘솔 등록/이미지/sandbox QA 완료를 의미하지 않는다.
