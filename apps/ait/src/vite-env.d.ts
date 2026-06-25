/// <reference types="vite/client" />

interface ImportMetaEnv {
  // AppsInToss(AIT) 마켓 전용 전면 광고 adGroupId. 미설정 시 테스트 ID 사용.
  // Google Play / App Store 광고 ID와는 다른 값이며 그쪽은 별도 관리한다.
  readonly VITE_AIT_INTERSTITIAL_AD_ID?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
