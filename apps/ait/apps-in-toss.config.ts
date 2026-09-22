import { defineConfig } from '@apps-in-toss/web-framework/config';

// web-framework 3.x 설정 파일. 2.x의 granite.config.ts를 `ait migrate v3`로 변환한 것이다.
// appName은 AppsInToss 콘솔 등록 정보와 반드시 일치해야 한다.
// 3.x에서 brand는 primaryColor만 남았다. displayName과 icon은 스키마에서 빠졌고 콘솔에서 관리한다.
// webBundleDir(= 2.x의 outdir)는 `ait build`가 그대로 아티팩트에 담는 디렉터리다.
// `ait build`는 웹 빌드를 실행하지 않으므로 그 전에 `vite build`가 끝나 있어야 한다.
// 게임 웹뷰 모드. 2.x 의 webViewProps.type 에 해당하고 `ait migrate v3` 가 떨어뜨린다.
// 이 키가 없으면 AppsInToss 웹뷰에서 Godot 의 큰 wasm 이 instantiate 되지 않아
// 스플래시에서 멈춘다. engine.init() 이 resolve 도 reject 도 하지 않고 Godot 배너조차
// 찍히지 않으며, 다운로드는 100% 끝나고 렌더러도 살아 있다. lucid-chess 가 실기기에서
// 같은 증상을 잡아 이 키로 해소했다(v3.0.8 정상 / v3.0.9~15 정지).
//
// 3.5.0 설정 타입에는 이 키가 없지만 CLI 가 bundle.json 에 그대로 직렬화해 플랫폼까지
// 전달한다. 객체 리터럴을 직접 넘기면 초과 속성 검사에 걸리므로 변수로 분리한다.
const webView = {
  type: 'game',
  // 게임 화면에서 바운스 스크롤이 일어나면 보드 조작과 충돌한다.
  overScrollMode: 'never' as const,
};

export default defineConfig({
  appName: 'lucid-reversi',

  brand: {
    primaryColor: '#242424'
  },

  permissions: [
    {
      name: 'clipboard',
      access: 'write',
    },
  ],

  webBundleDir: 'dist',

  webView,
});
