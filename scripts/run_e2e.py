#!/usr/bin/env python3
"""실제 시작 장면의 E2E를 시간·오류 로그·전체 기능 커버리지와 함께 검증한다."""
import argparse
import datetime as dt
import json
import os
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--capture', action='store_true')
parser.add_argument('--out', default='build/e2e')
args = parser.parse_args()
out = (root / args.out).resolve()
out.mkdir(parents=True, exist_ok=True)
now = lambda: dt.datetime.now(dt.timezone.utc).isoformat()
metadata = {'plannedAt': now(), 'sourceSha': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip(), 'status': 'running'}
metadata['startedAt'] = now()
command = [os.environ.get('GODOT_BIN', 'godot'), '--audio-driver', 'Dummy']
if not args.capture:
    command += ['--headless']
command += ['--path', str(root/'godot'), '--script', 'res://tools/e2e/journey.gd', '--', '--out', str(out)]
if args.capture:
    command += ['--capture']
env = dict(os.environ, GITHUB_SHA=metadata['sourceSha'])
status = 1
try:
    result = subprocess.run(command, cwd=root, env=env, capture_output=True, text=True, timeout=240)
    output = result.stdout + result.stderr
    (out/'godot.log').write_text(output)
    print(output, end='')
    status = result.returncode
    if any(line.startswith(('SCRIPT ERROR:', 'ERROR:')) for line in output.splitlines()):
        status = 1
    if status == 0:
        status = subprocess.run([sys.executable, str(root/'scripts/check_e2e_coverage.py'), '--inventory', str(root/'docs/qa/feature-inventory.json'), '--journey', str(out/'journey.json')], cwd=root).returncode
except subprocess.TimeoutExpired as error:
    (out/'godot.log').write_text(str(error.stdout or '') + str(error.stderr or ''))
    metadata['error'] = 'timeout after 240 seconds'
    print(metadata['error'], file=sys.stderr)
finally:
    metadata['completedAt'] = now()
    metadata['status'] = 'passed' if status == 0 else 'failed'
    (out/'execution.json').write_text(json.dumps(metadata, indent=2)+'\n')
sys.exit(status)
