import { useEffect } from 'react';
import GodotCanvas from './GodotCanvas';
import { isAdSupported, preloadInterstitialAd, showInterstitialAd } from './ads';

export default function App() {
  useEffect(() => {
    if (isAdSupported()) preloadInterstitialAd();

    // Godot → JS 브리지: 게임에서 한 판 종료 시 전면 광고를 노출한다.
    // AppsInToss 보안 정책상 JavaScriptBridge.eval 은 금지되므로, 게임은 eval 대신
    // JavaScriptBridge.get_interface("__aitBridge") 로 이 전역 객체를 받아 메서드를 직접 호출한다.
    // (godot/scripts/bootstrap/main.gd 의 _request_interstitial_ad)
    window.__aitBridge = { showInterstitialAd: () => showInterstitialAd() };

    return () => {
      delete window.__aitBridge;
    };
  }, []);

  return <GodotCanvas />;
}
