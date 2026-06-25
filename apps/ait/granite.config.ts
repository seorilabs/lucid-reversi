import { defineConfig } from '@apps-in-toss/web-framework/config';

// appName / brand 값은 AppsInToss 콘솔 등록 정보와 반드시 일치해야 한다.
// 샌드박스 접근: intoss://lucid-reversi
export default defineConfig({
  appName: 'lucid-reversi',
  brand: {
    displayName: '루시드 리버시',
    primaryColor: '#242424',
    // 콘솔에서 업로드한 아이콘의 HTTPS URL
    icon: 'https://static.toss.im/appsintoss/38345/764909ef-3849-428b-ae2e-1f868ec00ebf.png',
  },
  web: {
    // 실기기 샌드박스 테스트 시 host를 PC의 LAN IP로 바꾸고 dev를 'vite --host'로 둔다.
    host: 'localhost',
    port: 5173,
    commands: {
      // --host: 0.0.0.0 바인딩(IPv4 포함). adb reverse(127.0.0.1) 및 실기기 접근 호환.
      dev: 'vite --host',
      build: 'tsc --noEmit && vite build',
    },
  },
  permissions: [],
  outdir: 'dist',
});
