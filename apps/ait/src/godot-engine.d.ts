// Godot 4 Web export(index.js)가 전역으로 노출하는 Engine 타입 선언.
export {};

interface GodotEngineConfig {
  args?: string[];
  canvas?: HTMLCanvasElement;
  canvasResizePolicy?: number;
  emscriptenPoolSize?: number;
  ensureCrossOriginIsolationHeaders?: boolean;
  executable: string;
  experimentalVK?: boolean;
  fileSizes?: Record<string, number>;
  gdextensionLibs?: string[];
  focusCanvas?: boolean;
  godotPoolSize?: number;
}

interface GodotStartGameOptions {
  onProgress?: (current: number, total: number) => void;
}

declare global {
  class Engine {
    constructor(config: GodotEngineConfig);
    static getMissingFeatures(opts: { threads: boolean }): string[];
    startGame(options?: GodotStartGameOptions): Promise<void>;
    requestQuit?: () => void;
  }

  interface Window {
    Engine?: typeof Engine;
    // Godot → JS 브리지: 게임이 JavaScriptBridge.get_interface("__aitBridge") 로 받아
    // showInterstitialAd() 로 광고를 띄우고 shareResult() 로 결과 텍스트를 복사한다.
    __aitBridge?: {
      showInterstitialAd: () => void;
      shareResult: (text: string) => void;
    };
  }
}
