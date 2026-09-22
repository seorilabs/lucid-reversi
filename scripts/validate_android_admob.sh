#!/usr/bin/env bash
set -euo pipefail

# 빌드된 AAB 의 AndroidManifest 에 AdMob APPLICATION_ID 가 제대로 들어갔는지 확인한다.
#
# 왜 필요한가:
#   AdmobPlugin 의 AndroidExportPlugin 은 android_export.cfg 로드에 실패해도 aar 과
#   play-services-ads 의존성을 그대로 포함한다. 그 경우 meta-data 가 비거나 빠진 채
#   SDK 만 링크되고, Google Mobile Ads SDK 는 유효한 APPLICATION_ID 가 없으면 앱 시작 시
#   크래시한다. export 는 성공하므로 업로드 직전까지 아무도 모른다.
#   그래서 산출물을 직접 열어 fail-closed 로 막는다.
#
# org 재사용 워크플로우(seorilabs/.github: godot-deploy-google-play.yml)의
# `post_export_validation_script` 로 연결한다. 그 단계는 AAB_PATH 를 넘겨준다.
#
# 로컬에서 직접 쓰려면:
#   AAB_PATH=build/android/lucid-reversi.aab bash scripts/validate_android_admob.sh

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
aab_path="${AAB_PATH:-}"
config_path="$root_dir/play-store/google-play.config.json"

fail() {
  echo "[admob-validate] $1" >&2
  exit 1
}

[ -n "$aab_path" ] || fail "AAB_PATH 가 필요하다."
[ -f "$aab_path" ] || fail "AAB 를 찾을 수 없다: $aab_path"
[ -f "$config_path" ] || fail "config 를 찾을 수 없다: $config_path"
command -v unzip >/dev/null 2>&1 || fail "unzip 이 필요하다."
command -v python3 >/dev/null 2>&1 || fail "python3 가 필요하다."

expected_app_id="$(python3 -c "
import json, sys
ads = json.load(open('$config_path')).get('ads', {})
if not ads.get('enabled'):
    print('')
else:
    print(ads.get('androidAppId', ''))
")"

if [ -z "$expected_app_id" ]; then
  echo "[admob-validate] ads.enabled=false 이므로 AdMob 검증을 건너뛴다."
  exit 0
fi

case "$expected_app_id" in
  ca-app-pub-*~*) ;;
  *) fail "config 의 ads.androidAppId 형식이 AdMob App ID 가 아니다: $expected_app_id" ;;
esac

# AdMob 공식 테스트 App ID 가 릴리스 산출물에 들어가면 안 된다.
[ "$expected_app_id" != "ca-app-pub-3940256099942544~3347511713" ] \
  || fail "config 의 ads.androidAppId 가 AdMob 공식 테스트 ID 다."

manifest_pb="$(mktemp)"
trap 'rm -f "$manifest_pb"' EXIT
unzip -p "$aab_path" base/manifest/AndroidManifest.xml > "$manifest_pb" 2>/dev/null \
  || fail "AAB 에서 base/manifest/AndroidManifest.xml 를 읽지 못했다: $aab_path"

# protobuf 로 인코딩된 manifest 라 문자열만 추출해 대조한다.
found_app_id="$(strings "$manifest_pb" | grep -oE 'ca-app-pub-[0-9]+~[0-9]+' | head -1 || true)"

[ -n "$found_app_id" ] \
  || fail "AAB manifest 에 AdMob APPLICATION_ID 가 없다. android_export.cfg 로드 실패로 SDK 만 링크됐을 수 있고, 이 AAB 는 앱 시작 시 크래시한다."

strings "$manifest_pb" | grep -q "com.google.android.gms.ads.APPLICATION_ID" \
  || fail "AAB manifest 에 com.google.android.gms.ads.APPLICATION_ID meta-data 이름이 없다."

[ "$found_app_id" = "$expected_app_id" ] \
  || fail "AAB manifest 의 AdMob App ID 가 config 와 다르다. manifest=$found_app_id config=$expected_app_id"

# 광고를 켰으면 SDK 가 넣는 AD_ID 권한도 있어야 한다. 없으면 Play 의 광고 ID 선언과 어긋난다.
strings "$manifest_pb" | grep -q "com.google.android.gms.permission.AD_ID" \
  || fail "AAB manifest 에 com.google.android.gms.permission.AD_ID 권한이 없다. AdMob SDK 가 링크되지 않았을 수 있다."

echo "[admob-validate] OK — APPLICATION_ID=$found_app_id, AD_ID 권한 확인"
