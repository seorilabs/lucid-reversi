#!/usr/bin/env bash
set -euo pipefail

# Godot Android gradle build template 설치 + editor settings 에 Android SDK/JDK 경로 주입.
#
# org 재사용 워크플로우(seorilabs/.github: godot-deploy-google-play.yml)가 AAB export 직전에
# scripts/install_android_build_template.sh 로 호출한다. `godot --export-release Android` 는
#   (1) 프로젝트에 Android build template(godot/android/build)이 설치돼 있고,
#   (2) editor settings 의 export/android/android_sdk_path·java_sdk_path 로 SDK/JDK 를 인식해야
# 성공한다. org 워크플로우는 ANDROID_HOME/PATH 만 준비하므로 editor settings 주입은 여기서 한다.
#
# 로직 출처: seorilabs/lizard-tycoon scripts/export_godot_android.sh 의 템플릿 설치 블록.
#
# 환경 변수:
#   GODOT_PROJECT_DIR   : Godot 프로젝트 경로 (기본 godot)
#   ANDROID_HOME / ANDROID_SDK_ROOT : Android SDK 경로 (platform-tools/build-tools 포함)
#   JAVA_HOME           : JDK 경로 (미설정 시 java 위치로 추정)
#   GODOT_VERSION / GODOT_STATUS : export template 버전 (기본 4.6.3 / stable)

project_dir="${GODOT_PROJECT_DIR:-godot}"
godot_version="${GODOT_VERSION:-4.6.3}"
godot_status="${GODOT_STATUS:-stable}"

fail() { echo "[android-template] $1" >&2; exit 1; }

[ -d "${project_dir}" ] || fail "프로젝트 디렉토리 없음: ${project_dir}"
command -v godot >/dev/null 2>&1 || fail "godot 바이너리가 PATH 에 없다. scripts/ensure_godot.sh 참고."
command -v unzip >/dev/null 2>&1 || fail "unzip 이 필요하다."

# --- editor settings 에 Android SDK/JDK 경로 주입 ---------------------------
sdk_root="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
[ -n "${sdk_root}" ] || fail "ANDROID_HOME(또는 ANDROID_SDK_ROOT)가 필요하다."
[ -d "${sdk_root}/platform-tools" ] || echo "[android-template] 경고: ${sdk_root}/platform-tools 가 없다." >&2

java_home="${JAVA_HOME:-}"
if [ -z "${java_home}" ] && command -v java >/dev/null 2>&1; then
  java_home="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
fi
[ -n "${java_home}" ] || fail "JAVA_HOME(또는 java)가 필요하다."

case "$(uname -s)" in
  Darwin)
    config_dir="${HOME}/Library/Application Support/Godot"
    template_root="${HOME}/Library/Application Support/Godot/export_templates/${godot_version}.${godot_status}"
    ;;
  *)
    config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/godot"
    template_root="${XDG_DATA_HOME:-${HOME}/.local/share}/godot/export_templates/${godot_version}.${godot_status}"
    ;;
esac
mkdir -p "${config_dir}"

# Godot 은 Android export 시 editor settings 의 android_sdk_path/java_sdk_path 를 읽는다.
# 헤드리스에서 기본 editor settings 를 한 번 생성한 뒤 두 값을 덮어쓴다.
echo "[android-template] materializing editor settings" >&2
godot --headless --editor --quit-after 2 --path "${project_dir}" >/dev/null 2>&1 || true

# godot 이 쓰는 editor settings 파일은 버전별(editor_settings-<major>.<minor>.tres)이다.
# 실행 중인 Godot 버전에 해당하는 파일을 정확히 지정한다(멀티버전 환경에서 다른 버전 파일을 고르지 않도록).
minor="${godot_version%.*}"
settings_file="${config_dir}/editor_settings-${minor}.tres"
if [ ! -f "${settings_file}" ]; then
  alt="$(ls -1 "${config_dir}"/editor_settings-*.tres 2>/dev/null | sort | tail -n 1 || true)"
  if [ -n "${alt}" ]; then
    settings_file="${alt}"
  else
    printf '[gd_resource type="EditorSettings" format=3]\n\n[resource]\n' > "${settings_file}"
  fi
fi

python3 - "${settings_file}" "${sdk_root}" "${java_home}" <<'PY'
import re, sys
path, sdk, java = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, "r", encoding="utf-8") as fh:
    text = fh.read()

def upsert(text, key, value):
    line = f'{key} = "{value}"'
    pattern = re.compile(rf'^{re.escape(key)} = .*$', re.MULTILINE)
    if pattern.search(text):
        return pattern.sub(line, text)
    if "[resource]" in text:
        return text.rstrip() + "\n" + line + "\n"
    return text.rstrip() + "\n[resource]\n" + line + "\n"

text = upsert(text, "export/android/android_sdk_path", sdk)
text = upsert(text, "export/android/java_sdk_path", java)
with open(path, "w", encoding="utf-8") as fh:
    fh.write(text)
print(f"[android-template] editor settings updated: {path}")
PY

# --- Android gradle 빌드 템플릿 설치 ----------------------------------------
android_source="${template_root}/android_source.zip"
[ -f "${android_source}" ] || fail "Android export template 없음: ${android_source} (ensure_godot.sh --with-export-templates 필요)"

build_dir="${project_dir}/android/build"
# Godot 은 build template 버전을 res://android/.build_version(android 직하)에서 읽는다.
# (build 하위가 아님. 값은 VERSION_FULL_CONFIG = "<major>.<minor>.<patch>.<status>", 예: 4.6.3.stable)
version_marker="${project_dir}/android/.build_version"
if [ ! -f "${version_marker}" ]; then
  echo "[android-template] installing Android build template -> ${build_dir}" >&2
  mkdir -p "${build_dir}"
  unzip -q -o "${android_source}" -d "${build_dir}"
  echo "${godot_version}.${godot_status}" > "${version_marker}"
  touch "${project_dir}/android/.gdignore"
else
  echo "[android-template] build template already installed: ${version_marker}" >&2
fi

echo "[android-template] done" >&2
