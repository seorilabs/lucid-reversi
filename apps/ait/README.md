# AppsInToss Wrapper

Godot Web export를 AppsInToss(Granite `@apps-in-toss/web-framework`)로 패키징하는 래퍼다.

## 구성

- AppsInToss `appName`: `lucid-reversi` (콘솔 확정값)
- `brand.displayName`: 루시드 리버시
- `brand.icon`: `https://static.toss.im/appsintoss/38345/764909ef-3849-428b-ae2e-1f868ec00ebf.png` (콘솔 업로드 아이콘 HTTPS URL)
- Godot Web export 원본: `build/pages/` → `npm run sync:godot`로 `public/godot/`에 복사. 이때 AppsInToss 보안 정책(eval 금지)에 맞춰 엔진 로더 `index.js`의 `_godot_js_eval` 본문 eval 호출을 제거한다(`scripts/sync-godot-web.mjs`).
- Web export 렌더: `src/GodotCanvas.tsx`가 `index.js`의 `Engine`을 직접 로드해 canvas에 렌더
- 인앱 광고: `src/ads.ts` (AppsInToss 전면/Interstitial). 한 판 종료 시 Godot `_request_interstitial_ad`가 `JavaScriptBridge.get_interface("__aitBridge").showInterstitialAd()`(eval 미사용)로 노출. wrapper는 `App.tsx`에서 `window.__aitBridge`를 등록한다.

## 명령어

```bash
npm install
npm run sync:godot   # build/pages → public/godot 복사
npm run dev          # granite dev (Metro 8081 + vite 5173 동시 기동)
npm run build        # ait build → lucid-reversi.ait 생성
```

> dev 서버는 **Metro(8081)** + **vite(5173)** 두 포트를 쓴다. 샌드박스 앱은 8081로 접속해 RN 호스트 번들을 받고, 그 안에서 5173의 웹앱을 로드한다. `ait dev` 명령은 존재하지 않는다(`granite dev` 사용).

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
