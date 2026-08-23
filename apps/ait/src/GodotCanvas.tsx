import { useEffect, useRef, useState, type CSSProperties } from 'react';

// public/godot 로 sync된 Godot Web export 기준 값.
// 원본 build/pages/index.html 의 GODOT_CONFIG 에서 executable/fileSizes 경로만 /godot 로 보정.
const GODOT_BASE = '/godot';
const GODOT_CONFIG = {
  args: [] as string[],
  canvasResizePolicy: 2,
  emscriptenPoolSize: 8,
  ensureCrossOriginIsolationHeaders: true,
  executable: `${GODOT_BASE}/index`,
  experimentalVK: false,
  fileSizes: {
    [`${GODOT_BASE}/index.pck`]: 798096,
    [`${GODOT_BASE}/index.wasm`]: 37700666,
  },
  gdextensionLibs: [],
  focusCanvas: true,
  godotPoolSize: 4,
};

const GODOT_THREADS_ENABLED = false;

function loadGodotLoader(): Promise<void> {
  if (window.Engine) return Promise.resolve();
  const existing = document.getElementById('godot-loader') as HTMLScriptElement | null;
  if (existing) {
    return new Promise((resolve, reject) => {
      existing.addEventListener('load', () => resolve());
      existing.addEventListener('error', () => reject(new Error('Godot loader 로드 실패')));
    });
  }
  return new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.id = 'godot-loader';
    script.src = `${GODOT_BASE}/index.js`;
    script.async = true;
    script.onload = () => resolve();
    script.onerror = () => reject(new Error('Godot loader 로드 실패'));
    document.body.appendChild(script);
  });
}

export default function GodotCanvas() {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const [ready, setReady] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    let engine: Engine | null = null;

    (async () => {
      try {
        await loadGodotLoader();
        if (cancelled) return;

        const EngineCtor = window.Engine;
        const canvas = canvasRef.current;
        if (!EngineCtor || !canvas) {
          throw new Error('Engine 또는 canvas를 찾을 수 없습니다.');
        }

        const missing = EngineCtor.getMissingFeatures({ threads: GODOT_THREADS_ENABLED });
        if (missing.length > 0) {
          throw new Error(`이 환경에서 실행에 필요한 기능이 없습니다:\n${missing.join('\n')}`);
        }

        engine = new EngineCtor({ ...GODOT_CONFIG, canvas });
        await engine.startGame();
        if (!cancelled) setReady(true);
      } catch (e) {
        if (!cancelled) setError(e instanceof Error ? e.message : String(e));
      }
    })();

    return () => {
      cancelled = true;
      engine?.requestQuit?.();
    };
  }, []);

  return (
    <div style={{ position: 'fixed', inset: 0, background: '#f9fbfb' }}>
      <canvas
        ref={canvasRef}
        id="canvas"
        style={{ display: 'block', width: '100%', height: '100%', outline: 'none' }}
      >
        Your browser does not support the canvas tag.
      </canvas>

      {!ready && !error && (
        <div style={overlayStyle}>
          <img src={`${GODOT_BASE}/index.png`} alt="서리랩스" style={splashImageStyle} />
        </div>
      )}

      {error && (
        <div style={{ ...overlayStyle, color: '#ffb4b4', whiteSpace: 'pre-line', padding: '0 24px', textAlign: 'center' }}>
          {error}
        </div>
      )}
    </div>
  );
}

const overlayStyle: CSSProperties = {
  position: 'absolute',
  inset: 0,
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  color: '#10140f',
  background: '#f9fbfb',
  font: '15px/1.4 -apple-system, system-ui, sans-serif',
  pointerEvents: 'none',
};

const splashImageStyle: CSSProperties = {
  display: 'block',
  width: 'min(56vw, 320px)',
  height: 'auto',
};
