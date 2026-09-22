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

// AppsInToss 보안 정책: 외부 코드 문자열을 받아 실행하는 eval/JavaScriptBridge.eval 이 금지된다.
// Godot Web export의 엔진 로더(index.js)에는 그 구현체 _godot_js_eval 가 항상 포함되어
// 내부에서 literal eval()을 호출하고, 식별자/문자열에도 "eval" 토큰이 남는다.
// 게임은 더 이상 JavaScriptBridge.eval 을 쓰지 않으므로(=> get_interface 방식),
// (1) 본문의 eval 호출을 제거하고
// (2) JS 식별자/지역변수/메시지에서 "eval" 토큰을 모두 제거(리네임)한다.
// 단, WASM import 키 `godot_js_eval` 만은 wasm 측 import 이름과 일치해야 해서 유지한다
//     (호출부가 아니라 단순 식별자이며 eval( / bare eval 형태가 아니다).
sanitizeGodotEval(join(destDir, 'index.js'));
relaxEmscriptenSafariGate(join(destDir, 'index.js'));

console.log(`[sync:godot] ${copied}개 파일 복사 완료 → ${destDir}`);

/**
 * Godot Web 로더(index.js)에서 eval 실행과 "eval" 토큰을 제거한다.
 * - eval() 호출 본문 → no-op
 * - JS 함수 식별자 _godot_js_eval → _godot_js_run (import 키 godot_js_eval 은 유지)
 * - 지역 변수 eval_ret → js_ret
 * - import 키 godot_js_eval 만 남기고, 그 외엔 eval( / bare `eval` 토큰이 없어야 한다(회귀 가드).
 */
function sanitizeGodotEval(indexJsPath) {
  if (!existsSync(indexJsPath)) {
    console.error(`[sync:godot] index.js 를 찾을 수 없습니다: ${indexJsPath}`);
    process.exit(1);
  }
  let js = readFileSync(indexJsPath, 'utf8');

  // 1) Godot 4.x export가 생성하는 eval 실행 블록(한 줄, 미니파이됨)을 no-op으로 치환.
  const EVAL_BLOCK =
    'try{if(p_use_global_ctx){const global_eval=eval;eval_ret=global_eval(js_code)}else{eval_ret=eval(js_code)}}catch(e){GodotRuntime.error(e)}';
  const NOOP_BLOCK =
    'try{GodotRuntime.error("JavaScriptBridge bridge call is disabled by AppsInToss policy");}catch(e){}';
  const hadBlock = js.includes(EVAL_BLOCK);
  if (hadBlock) js = js.split(EVAL_BLOCK).join(NOOP_BLOCK);

  // 2) JS 함수 식별자(_godot_js_eval)와 지역 변수(eval_ret)를 "eval" 없는 이름으로 리네임.
  //
  //    정의와 참조를 한 번에 바꾼다. 예전에는 `function _godot_js_eval(` 와
  //    `godot_js_eval:_godot_js_eval` 두 패턴만 바꿨는데, 그건 로더 미니파이 결과에
  //    기대는 방식이라 Godot 버전이 올라가면 조용히 깨진다. 실제로 4.7.2 는 wasm import
  //    매핑을 `$e:_godot_js_eval` 로 줄여서, 정의만 리네임되고 참조가 남아
  //    런타임에 `_godot_js_eval is not defined` 로 죽었다.
  //
  //    wasm ABI 이름은 이 축약 키(`$e` 등)이지 JS 함수명이 아니므로 전체 치환해도 안전하다.
  js = js.split('_godot_js_eval').join('_godot_js_run');
  js = js.split('eval_ret').join('js_ret');

  if (hadBlock) {
    writeFileSync(indexJsPath, js);
    console.log('[sync:godot] index.js: eval 실행 제거 + "eval" 토큰 리네임 완료 (import 키 godot_js_eval 만 유지)');
  } else {
    // 블록을 못 찾았다면 Godot 버전이 바뀐 것이므로 회귀 가드에서 잡히게 둔다.
    writeFileSync(indexJsPath, js);
  }

  // 회귀 가드: eval( 호출이나 bare `eval` 토큰이 남으면 실패.
  //
  // 예전 가드는 `godot_js_eval` 를 통째로 지운 뒤에 검사했는데, 그러면 리네임에서
  // 빠진 `_godot_js_eval` 참조가 `_` 로 줄어 검사망을 그대로 빠져나갔다. 실제로
  // 그 구멍 때문에 깨진 번들이 배포 직전까지 통과했다. 이제 예외 없이 검사한다.
  const danger = js.match(/\beval\b|eval\s*\(|=eval\b/g);
  if (danger) {
    console.error(`[sync:godot] index.js 에 eval 토큰이 남아 있습니다 (${danger.length}건). Godot 버전 변경으로 패치 패턴이 달라졌을 수 있습니다.`);
    console.error('  scripts/sync-godot-web.mjs 의 EVAL_BLOCK / 리네임 패턴을 현재 export 결과에 맞게 갱신하세요.');
    process.exit(1);
  }
}

/**
 * emscripten 런타임의 Safari 버전 게이트가 Android WebView 를 막지 않게 한다.
 *
 * emscripten 은 UA 에 `Safari/` 가 있고 `Version/x` 가 잡히면 Safari 로 보고
 * v15.2.0 미만이면 실행을 중단한다. Android WebView 의 UA 는
 *   ... Version/4.0 Chrome/152.0.0.0 Mobile Safari/537.36
 * 이라 Safari 4.0 으로 오인돼, Chrome 기반 웹뷰인데도 엔진이 시작조차 못 한다
 * (`This emscripten-generated code requires Safari v15.2.0 (detected v040000)`).
 * AppsInToss 웹뷰에서 스플래시만 보이고 멈추는 원인이다. lucid-chess 가 같은
 * 증상을 실기기에서 잡아 확인했다.
 *
 * UA 에 `Chrome/` 이 있으면 Safari 분기를 타지 않게 한다. 진짜 Safari 는
 * `Chrome/` 이 없으므로 기존대로 검사받는다.
 *
 * 이 게이트는 Godot(=emscripten) 버전에 따라 없을 수도 있다. Godot 4.6.3 에는 있고
 * 4.7.2 에는 없다. 그래서 없으면 통과시키고, 있는데 패치가 안 되면 실패시킨다.
 */
function relaxEmscriptenSafariGate(indexJsPath) {
  const source = readFileSync(indexJsPath, 'utf8');
  const TARGET = 'userAgent.includes("Safari/")&&userAgent.match(';
  const PATCHED = 'userAgent.includes("Safari/")&&!userAgent.includes("Chrome/")&&userAgent.match(';

  if (source.includes(PATCHED)) {
    console.log('[sync:godot] index.js: emscripten Safari 게이트가 이미 완화돼 있다.');
    return;
  }
  if (!source.includes(TARGET)) {
    // 게이트 자체가 없는 빌드다. 다만 검사 문구가 남아 있는데 패턴만 못 찾은 경우는
    // 미니파이가 바뀐 것이므로 조용히 넘기면 안 된다.
    if (source.includes('requires Safari')) {
      console.error('[sync:godot] emscripten Safari 게이트를 찾았지만 패치 패턴이 맞지 않습니다.');
      console.error('  Godot/emscripten 버전 변경으로 미니파이 결과가 달라졌을 수 있습니다.');
      console.error('  scripts/sync-godot-web.mjs 의 TARGET 을 현재 로더에 맞게 갱신하세요.');
      process.exit(1);
    }
    console.log('[sync:godot] index.js: emscripten Safari 게이트가 없다(해당 없음).');
    return;
  }

  writeFileSync(indexJsPath, source.split(TARGET).join(PATCHED));
  console.log('[sync:godot] index.js: emscripten Safari 게이트 완화 (Chrome 계열 웹뷰 통과)');
}
