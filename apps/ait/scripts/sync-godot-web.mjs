// build/pages 의 Godot Web export 산출물을 apps/ait/public/godot 로 복사한다.
// React wrapper가 자체 index.html을 쓰므로 export의 index.html은 제외한다.
import { cpSync, existsSync, mkdirSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
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

console.log(`[sync:godot] ${copied}개 파일 복사 완료 → ${destDir}`);
