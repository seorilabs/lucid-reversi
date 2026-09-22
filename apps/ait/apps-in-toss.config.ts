import { defineConfig } from '@apps-in-toss/web-framework/config';

// web-framework 3.x 설정 파일. 2.x의 granite.config.ts를 `ait migrate v3`로 변환한 것이다.
// appName은 AppsInToss 콘솔 등록 정보와 반드시 일치해야 한다.
// 3.x에서 brand는 primaryColor만 남았다. displayName과 icon은 스키마에서 빠졌고 콘솔에서 관리한다.
// webBundleDir(= 2.x의 outdir)는 `ait build`가 그대로 아티팩트에 담는 디렉터리다.
// `ait build`는 웹 빌드를 실행하지 않으므로 그 전에 `vite build`가 끝나 있어야 한다.
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

  webBundleDir: 'dist'
});
