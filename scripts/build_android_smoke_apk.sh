#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_DIR="$ROOT_DIR/godot"
BUILD_DIR="$ROOT_DIR/build/android"
GODOT_BIN="${GODOT_BIN:-godot}"
ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
JAVA_HOME="${JAVA_HOME:-/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home}"
GODOT_VERSION="$("$GODOT_BIN" --version | cut -d. -f1-3).stable"
TEMPLATE_APK="$HOME/Library/Application Support/Godot/export_templates/$GODOT_VERSION/android_debug.apk"
KEYSTORE="$BUILD_DIR/debug.keystore"
PACK="$BUILD_DIR/lucid-reversi-device-smoke.pck"
UNSIGNED_APK="$BUILD_DIR/lucid-reversi-device-smoke-unsigned.apk"
ALIGNED_APK="$BUILD_DIR/lucid-reversi-device-smoke-aligned.apk"
SIGNED_APK="$BUILD_DIR/lucid-reversi-device-smoke.apk"

if [[ ! -f "$TEMPLATE_APK" ]]; then
  echo "Missing Godot Android debug template: $TEMPLATE_APK" >&2
  exit 1
fi

BUILD_TOOLS_VERSION="$(ls -1 "$ANDROID_HOME/build-tools" | sort | tail -n 1)"
ZIPALIGN="$ANDROID_HOME/build-tools/$BUILD_TOOLS_VERSION/zipalign"
APKSIGNER="$ANDROID_HOME/build-tools/$BUILD_TOOLS_VERSION/apksigner"

if [[ ! -x "$ZIPALIGN" || ! -x "$APKSIGNER" ]]; then
  echo "Missing Android build-tools under $ANDROID_HOME/build-tools/$BUILD_TOOLS_VERSION" >&2
  exit 1
fi

mkdir -p "$BUILD_DIR"

if [[ ! -f "$KEYSTORE" ]]; then
  if [[ -f "$HOME/Library/Application Support/Godot/keystores/debug.keystore" ]]; then
    cp "$HOME/Library/Application Support/Godot/keystores/debug.keystore" "$KEYSTORE"
  else
    "$JAVA_HOME/bin/keytool" -genkeypair \
      -keystore "$KEYSTORE" \
      -storepass android \
      -keypass android \
      -alias androiddebugkey \
      -keyalg RSA \
      -keysize 2048 \
      -validity 10000 \
      -dname "CN=Android Debug,O=Android,C=US"
  fi
fi

"$GODOT_BIN" --headless --path "$GODOT_DIR" --export-pack Web "$PACK"

rm -f "$UNSIGNED_APK" "$ALIGNED_APK" "$SIGNED_APK"
cp "$TEMPLATE_APK" "$UNSIGNED_APK"

TMP_DIR="$(mktemp -d /tmp/lucid-reversi-apk-assets.XXXXXX)"
mkdir -p "$TMP_DIR/assets"
cp "$PACK" "$TMP_DIR/assets/assets.sparsepck"
(cd "$TMP_DIR" && zip -q -0 "$UNSIGNED_APK" assets/assets.sparsepck)
rm -rf "$TMP_DIR"

"$ZIPALIGN" -f 4 "$UNSIGNED_APK" "$ALIGNED_APK"
"$APKSIGNER" sign \
  --ks "$KEYSTORE" \
  --ks-key-alias androiddebugkey \
  --ks-pass pass:android \
  --key-pass pass:android \
  --out "$SIGNED_APK" \
  "$ALIGNED_APK"
"$APKSIGNER" verify --verbose "$SIGNED_APK"

echo "$SIGNED_APK"
