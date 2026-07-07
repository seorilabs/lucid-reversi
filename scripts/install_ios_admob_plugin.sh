#!/usr/bin/env bash
set -euo pipefail

# godot-admob(iOS) 네이티브 바이너리(xcframework) 설치.
#
# 이 repo에는 GDScript 애드온(godot/addons/AdmobPlugin)과 플러그인 정의
# (godot/ios/plugins/AdmobPlugin.gdip)만 커밋한다. 용량이 큰 xcframework(약 45MB:
# GoogleMobileAds/UserMessagingPlatform/AdmobPlugin)는 .gitignore 대상이라,
# iOS export 전에 이 스크립트로 릴리스에서 내려받아 배치한다.
#
# iOS export(godot --export-release iOS)는 AdmobPlugin.gd(EditorExportPlugin)가
#   res://ios/framework/GoogleMobileAds.xcframework
#   res://ios/framework/UserMessagingPlatform.xcframework
#   res://ios/plugins/AdmobPlugin.{debug,release}.xcframework
# 를 Xcode 프로젝트에 링크하므로, 위 경로에 바이너리가 존재해야 한다.
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
  echo "[ios-admob] $1" >&2
  exit 1
}

[ -d "${project_dir}" ] || fail "Godot 프로젝트 디렉토리가 없다: ${project_dir}"

framework_dir="${project_dir}/ios/framework"
plugins_dir="${project_dir}/ios/plugins"
marker="${framework_dir}/GoogleMobileAds.xcframework"

if [ "${force}" != "1" ] && [ -d "${marker}" ]; then
  echo "[ios-admob] 이미 설치됨: ${marker} (재설치하려면 ADMOB_FORCE_REINSTALL=1)"
  exit 0
fi

command -v curl >/dev/null 2>&1 || fail "curl 이 필요하다."
command -v unzip >/dev/null 2>&1 || fail "unzip 이 필요하다."

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/godot-admob.XXXXXX")"
cleanup() { rm -rf "${tmp_dir}"; }
trap cleanup EXIT

archive="${tmp_dir}/AdmobPlugin-iOS-${plugin_version}.zip"
url="https://github.com/${plugin_repo}/releases/download/${plugin_version}/AdmobPlugin-iOS-${plugin_version}.zip"

echo "[ios-admob] downloading ${url}" >&2
curl -fsSL "${url}" -o "${archive}" || fail "다운로드 실패: ${url}"
unzip -q -o "${archive}" -d "${tmp_dir}/extracted" || fail "압축 해제 실패"

src="${tmp_dir}/extracted"
[ -d "${src}/ios/framework/GoogleMobileAds.xcframework" ] || fail "예상한 xcframework 가 릴리스에 없다."

mkdir -p "${framework_dir}" "${plugins_dir}"

# 큰 SDK 프레임워크
rm -rf "${framework_dir}/GoogleMobileAds.xcframework" "${framework_dir}/UserMessagingPlatform.xcframework"
cp -R "${src}/ios/framework/GoogleMobileAds.xcframework" "${framework_dir}/"
cp -R "${src}/ios/framework/UserMessagingPlatform.xcframework" "${framework_dir}/"

# 플러그인 네이티브 바이너리(debug/release). .gdip 는 repo 커밋본을 유지한다.
for variant in debug release; do
  rm -rf "${plugins_dir}/AdmobPlugin.${variant}.xcframework"
  cp -R "${src}/ios/plugins/AdmobPlugin.${variant}.xcframework" "${plugins_dir}/"
done

echo "[ios-admob] installed AdMob iOS binaries (${plugin_version}) into ${project_dir}/ios" >&2
du -sh "${framework_dir}" "${plugins_dir}" 2>/dev/null || true
