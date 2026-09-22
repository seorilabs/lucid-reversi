import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

import aitDevtools from '@apps-in-toss/devtools/unplugin';

// Godot Web export(public/godot/*)는 정적 자산으로 그대로 서빙된다.
//
// devtools 는 개발 편의 도구이고 @apps-in-toss/web-framework 를 mock 구현으로 alias 한다.
// 배포 번들에 섞이면 실 SDK 대신 mock 이 올라가므로 dev 서버에서만 켠다.
// 플러그인 자체도 NODE_ENV 로 스스로를 끄지만, 그건 환경변수에 의존하는 방어라
// NODE_ENV 를 달리 준 빌드에서 뚫린다. vite 의 command 로 막는 편이 확실하다.
export default defineConfig(({ command }) => {
  const isDev = command === 'serve';
  return {
    plugins: [...(isDev ? [aitDevtools.vite()] : []), react()],
    server: {
      port: 5173,
    },
  };
});
