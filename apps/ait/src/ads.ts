import { loadFullScreenAd, showFullScreenAd } from '@apps-in-toss/web-framework';

// 한 판 종료 후 전면(Interstitial) 광고를 노출한다.
//
// 광고 ID는 마켓별로 다르다. 이 값은 **AppsInToss(AIT) 마켓 전용** adGroupId이며,
// Google Play / App Store는 각 마켓 광고 연동(예: Godot 네이티브 AdMob)에서 별도의 ID로 관리한다.
//
// 실 ID는 빌드 시 환경변수 VITE_AIT_INTERSTITIAL_AD_ID 로 주입한다(소스에 실 ID를 커밋하지 않는다).
// 미설정 시 테스트 ID로 동작한다. 개발/샌드박스에서는 반드시 테스트 ID를 사용한다(실 ID 테스트는 정책 위반).
const TEST_INTERSTITIAL_AD_GROUP_ID = 'ait-ad-test-interstitial-id';
export const INTERSTITIAL_AD_GROUP_ID =
  import.meta.env.VITE_AIT_INTERSTITIAL_AD_ID ?? TEST_INTERSTITIAL_AD_GROUP_ID;

let adLoaded = false;
let unregisterLoad: (() => void) | null = null;

/** 전면 광고를 미리 로드한다. (load → show → load 패턴) */
export function preloadInterstitialAd(): void {
  if (!loadFullScreenAd.isSupported()) {
    console.warn('[ads] 현재 환경에서 인앱 광고를 사용할 수 없습니다. (토스앱에서만 동작)');
    return;
  }
  unregisterLoad?.();
  unregisterLoad = loadFullScreenAd({
    options: { adGroupId: INTERSTITIAL_AD_GROUP_ID },
    onEvent: (event) => {
      if (event.type === 'loaded') {
        adLoaded = true;
        console.log('[ads] 전면 광고 로드 완료');
      }
    },
    onError: (error) => {
      adLoaded = false;
      console.error('[ads] 전면 광고 로드 실패:', error);
    },
  });
}

/** 로드된 전면 광고를 노출한다. (한 판 종료 시 호출) */
export function showInterstitialAd(): void {
  if (!showFullScreenAd.isSupported()) {
    console.warn('[ads] 현재 환경에서 인앱 광고를 사용할 수 없습니다.');
    return;
  }
  if (!adLoaded) {
    // 아직 로드 전이면 이번 판은 건너뛰고 다음을 위해 미리 로드한다.
    console.warn('[ads] 전면 광고가 아직 로드되지 않아 이번 노출은 생략합니다.');
    preloadInterstitialAd();
    return;
  }

  showFullScreenAd({
    options: { adGroupId: INTERSTITIAL_AD_GROUP_ID },
    onEvent: (event) => {
      switch (event.type) {
        case 'impression':
          console.log('[ads] 전면 광고 노출 기록 (수익 발생 시점)');
          break;
        case 'dismissed':
          adLoaded = false;
          preloadInterstitialAd(); // 다음 판을 위해 미리 로드
          break;
        case 'failedToShow':
          console.error('[ads] 전면 광고 표시 실패');
          adLoaded = false;
          preloadInterstitialAd();
          break;
        default:
          break;
      }
    },
    onError: (error) => console.error('[ads] 전면 광고 표시 실패:', error),
  });
}

/** 광고 SDK 사용 가능 환경인지 (토스앱/샌드박스). */
export function isAdSupported(): boolean {
  try {
    return loadFullScreenAd.isSupported();
  } catch {
    return false;
  }
}
