#!/usr/bin/env bash
set -euo pipefail

# godot-admob(Android) 네이티브 바이너리(aar) 설치.
#
# 이 repo에는 GDScript 애드온(godot/addons/AdmobPlugin)만 커밋하고, 네이티브 바이너리는
# .gitignore 대상이다. Android export(godot --export-release Android)는
# AdmobPlugin.gd(AndroidExportPlugin._get_android_libraries)가
#   res://addons/AdmobPlugin/bin/release/AdmobPlugin-release.aar
#   res://addons/AdmobPlugin/bin/debug/AdmobPlugin-debug.aar
# 를 gradle 프로젝트에 링크하므로, 위 경로에 aar이 존재해야 한다. 없으면 gradle이
# "Transform's input file does not exist"로 실패한다.
#
# org 재사용 워크플로우(seorilabs/.github: godot-deploy-google-play.yml)가 Android build
# template 설치 직전에 scripts/build_admob_plugin.sh 를 자동 호출한다. 이름이 build지만
# 실제로는 릴리스 asset 다운로드다(org 계약이 이 이름을 쓴다).
#
# iOS 쪽 대응 스크립트는 scripts/install_ios_admob_plugin.sh 다.
#
# 환경 변수:
#   GODOT_PROJECT_DIR       : Godot 프로젝트 경로 (기본 godot)
#   ADMOB_PLUGIN_VERSION    : godot-admob 릴리스 태그 (기본 v6.0)
#   ADMOB_PLUGIN_REPO       : 릴리스 repo (기본 godot-sdk-integrations/godot-admob)
#   ADMOB_FORCE_REINSTALL   : 1이면 기존 바이너리를 지우고 재설치

project_dir="${GODOT_PROJECT_DIR:-godot}"
plugin_version="${ADMOB_PLUGIN_VERSION:-v6.0}"
plugin_repo="${ADMOB_PLUGIN_REPO:-godot-sdk-integrations/godot-admob}"
force="${ADMOB_FORCE_REINSTALL:-0}"

fail() {
  echo "[android-admob] $1" >&2
  exit 1
}

[ -d "$project_dir" ] || fail "프로젝트 디렉토리 없음: $project_dir"
command -v unzip >/dev/null 2>&1 || fail "unzip이 필요하다."

bin_dir="$project_dir/addons/AdmobPlugin/bin"
release_aar="$bin_dir/release/AdmobPlugin-release.aar"
debug_aar="$bin_dir/debug/AdmobPlugin-debug.aar"

if [ "$force" = "1" ]; then
  rm -rf "$bin_dir"
fi

if [ -f "$release_aar" ] && [ -f "$debug_aar" ]; then
  echo "[android-admob] aar already installed: $bin_dir"
  exit 0
fi

asset="AdmobPlugin-Android-${plugin_version}.zip"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

echo "[android-admob] downloading $plugin_repo $plugin_version / $asset"
if command -v gh >/dev/null 2>&1; then
  gh release download "$plugin_version" --repo "$plugin_repo" --pattern "$asset" --dir "$tmp_dir" \
    || fail "릴리스 asset 다운로드 실패: $asset"
else
  url="https://github.com/${plugin_repo}/releases/download/${plugin_version}/${asset}"
  curl -fsSL "$url" -o "$tmp_dir/$asset" || fail "릴리스 asset 다운로드 실패: $url"
fi

# aar만 꺼낸다. zip의 .gd/plugin.cfg는 이 repo에서 수정한 애드온을 덮어쓰면 안 된다
# (AdmobPlugin.gd의 export plugin 등록, android_export.cfg 연동).
unzip -o -q "$tmp_dir/$asset" "addons/AdmobPlugin/bin/*" -d "$tmp_dir/extract" \
  || fail "zip에서 aar을 찾지 못했다: $asset"

mkdir -p "$bin_dir/release" "$bin_dir/debug"
cp "$tmp_dir/extract/addons/AdmobPlugin/bin/release/AdmobPlugin-release.aar" "$release_aar" \
  || fail "release aar 복사 실패"
cp "$tmp_dir/extract/addons/AdmobPlugin/bin/debug/AdmobPlugin-debug.aar" "$debug_aar" \
  || fail "debug aar 복사 실패"

echo "[android-admob] installed:"
echo "  $release_aar"
echo "  $debug_aar"
