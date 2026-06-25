#!/usr/bin/env bash
set -euo pipefail

scan_paths=(
  "packages/product-core/src"
  "packages/product-core/tests"
)

godot_core_file="godot/scripts/reversi_engine.gd"

for path in "${scan_paths[@]}"; do
  if [ ! -d "${path}" ]; then
    echo "Missing architecture scan path: ${path}" >&2
    exit 1
  fi
done

if [ ! -f "${godot_core_file}" ]; then
  echo "Missing Godot pure core file: ${godot_core_file}" >&2
  exit 1
fi

forbidden_pattern='(from|import|require|extends|class_name).*(Godot|Firebase|firebase|Firestore|firestore|AppsInToss|Toss|StoreKit|BillingClient|AdMob|JavaScriptBridge|Node|Control|SceneTree)'

if rg -n "${forbidden_pattern}" "${scan_paths[@]}" --glob '!README.md'; then
  echo "Architecture boundary violation found in product core." >&2
  exit 1
fi

godot_forbidden_pattern='(extends Node|extends Control|SceneTree|Firebase|firebase|AppsInToss|Toss|AdMob|JavaScriptBridge)'

if rg -n "${godot_forbidden_pattern}" "${godot_core_file}"; then
  echo "Architecture boundary violation found in Godot Reversi engine." >&2
  exit 1
fi

echo "Architecture boundary check passed."
