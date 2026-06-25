import { useEffect } from 'react';
import GodotCanvas from './GodotCanvas';
import { isAdSupported, preloadInterstitialAd, showInterstitialAd } from './ads';

export default function App() {
  useEffect(() => {
    if (isAdSupported()) preloadInterstitialAd();

    // Godot → JS 브리지: 게임에서 한 판 종료 시 JavaScriptBridge로 호출해 전면 광고를 노출한다.
    // (godot/scripts/bootstrap/main.gd 의 _request_interstitial_ad)
    window.__aitShowInterstitialAd = () => showInterstitialAd();

    return () => {
      delete window.__aitShowInterstitialAd;
    };
  }, []);

  return <GodotCanvas />;
}
