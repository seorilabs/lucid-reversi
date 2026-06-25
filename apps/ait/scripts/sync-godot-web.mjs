// build/pages 의 Godot Web export 산출물을 apps/ait/public/godot 로 복사한다.
// React wrapper가 자체 index.html을 쓰므로 export의 index.html은 제외한다.
import { cpSync, existsSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(__dirname, '../../..');
const srcDir = resolve(repoRoot, 'build/pages');
const destDir = resolve(__dirname, '../public/godot');

const EXCLUDE = new Set(['index.html', '.nojekyll', '.DS_Store']);

if (!existsSync(srcDir)) {
  console.error(`[sync:godot] Godot Web export가 없습니다: ${srcDir}`);
  console.error('  먼저 리포 루트에서 `npm run build:godot:web` 를 실행하세요.');
  process.exit(1);
}

rmSync(destDir, { recursive: true, force: true });
mkdirSync(destDir, { recursive: true });

let copied = 0;
for (const name of readdirSync(srcDir)) {
  if (EXCLUDE.has(name)) continue;
  cpSync(join(srcDir, name), join(destDir, name), { recursive: true });
  copied += 1;
}

// 빈 디렉터리를 git에 유지하기 위한 placeholder 복원 (public/godot/* 는 gitignore됨)
writeFileSync(join(destDir, '.gitkeep'), '');

// AppsInToss 보안 정책: 외부 코드 문자열을 실행하는 eval 사용이 금지된다.
// Godot Web export의 엔진 로더(index.js)에는 JavaScriptBridge.eval 구현체인
// _godot_js_eval 가 항상 포함되며 내부에서 literal eval()을 호출한다.
// 게임은 더 이상 JavaScriptBridge.eval 을 쓰지 않으므로(=> get_interface 방식),
// WASM import 심볼은 유지하되 함수 본문의 eval 호출만 제거(no-op)한다.
stripGodotEval(join(destDir, 'index.js'));

console.log(`[sync:godot] ${copied}개 파일 복사 완료 → ${destDir}`);

/**
 * Godot Web 로더의 _godot_js_eval 본문에서 eval 호출을 제거한다.
 * - import 바인딩(_godot_js_eval)은 그대로 두어 WASM instantiate가 깨지지 않게 한다.
 * - 패치 후에도 literal `eval(` 가 남아 있으면 빌드를 실패시킨다(정책 회귀 방지).
 */
function stripGodotEval(indexJsPath) {
  if (!existsSync(indexJsPath)) {
    console.error(`[sync:godot] index.js 를 찾을 수 없습니다: ${indexJsPath}`);
    process.exit(1);
  }
  let js = readFileSync(indexJsPath, 'utf8');

  // Godot 4.x export가 생성하는 eval 블록(한 줄, 미니파이됨).
  const EVAL_BLOCK =
    'try{if(p_use_global_ctx){const global_eval=eval;eval_ret=global_eval(js_code)}else{eval_ret=eval(js_code)}}catch(e){GodotRuntime.error(e)}';
  const NOOP_BLOCK =
    'try{GodotRuntime.error("JavaScriptBridge.eval is disabled by AppsInToss security policy");}catch(e){}';

  if (js.includes(EVAL_BLOCK)) {
    js = js.split(EVAL_BLOCK).join(NOOP_BLOCK);
    writeFileSync(indexJsPath, js);
    console.log('[sync:godot] index.js: _godot_js_eval 의 eval 호출 제거(no-op) 완료');
  }

  // 회귀 가드: eval 호출(`eval(`) 또는 eval 별칭 할당(`=eval`)이 남아 있으면 실패시킨다.
  // 식별자 _godot_js_eval / eval_ret 은 \b 경계 덕분에 매칭되지 않는다.
  const danger = js.match(/\beval\s*\(|=eval\b/g);
  if (danger) {
    console.error(`[sync:godot] index.js 에 eval 사용이 남아 있습니다 (${danger.length}건). Godot 버전 변경으로 패치 패턴이 달라졌을 수 있습니다.`);
    console.error('  scripts/sync-godot-web.mjs 의 EVAL_BLOCK 패턴을 현재 export 결과에 맞게 갱신하세요.');
    process.exit(1);
  }
}
