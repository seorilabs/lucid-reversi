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
    // Godot → JS 브리지: 게임에서 한 판 종료 시 JavaScriptBridge로 호출해 전면 광고를 띄운다.
    __aitShowInterstitialAd?: () => void;
  }
}
