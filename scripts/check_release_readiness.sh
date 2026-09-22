#!/usr/bin/env bash
set -euo pipefail

target="all"

usage() {
  cat <<'USAGE'
Usage:
  check_release_readiness.sh [--target all|apps-in-toss]

Targets:
  all            Checks the full multimarket release inventory.
  apps-in-toss   Checks only the AppsInToss-first release path.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      target="${2:?missing value for --target}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "${target}" in
  ait)
    target="apps-in-toss"
    ;;
  all|apps-in-toss)
    ;;
  *)
    echo "Unknown target: ${target}" >&2
    usage >&2
    exit 2
    ;;
esac

echo "Release readiness inventory (${target})"
echo

blockers=0

case "${target}" in
  apps-in-toss)
    required_paths=(
      "docs/01-planning/product-spec.md"
      "docs/05-markets/apps-in-toss.md"
      "docs/06-release/release-checklist.md"
    )
    required_release_configs=(
      "apps-in-toss/apps-in-toss.config.json"
      "apps/ait/apps-in-toss.config.ts"
    )
    ;;
  *)
    required_paths=(
      "docs/01-planning/product-spec.md"
      "docs/01-planning/release-targets.md"
      "docs/05-markets/google-play.md"
      "docs/05-markets/app-store.md"
      "docs/05-markets/apps-in-toss.md"
      "docs/05-markets/firebase.md"
      "docs/06-release/release-checklist.md"
    )
    required_release_configs=(
      "play-store/google-play.config.json"
      "app-store/app-store.config.json"
      "apps-in-toss/apps-in-toss.config.json"
      "apps/ait/apps-in-toss.config.ts"
    )
    ;;
esac

for path in "${required_paths[@]}"; do
  if [ ! -f "${path}" ]; then
    echo "Missing release source file: ${path}" >&2
    blockers=1
  fi
done

existing_release_configs=()
for file in "${required_release_configs[@]}"; do
  if [ ! -f "${file}" ]; then
    echo "Missing release config: ${file}" >&2
    blockers=1
    continue
  fi

  existing_release_configs+=("${file}")
done

scan_targets=("${required_paths[@]}")
if [ "${#existing_release_configs[@]}" -gt 0 ]; then
  scan_targets+=("${existing_release_configs[@]}")
fi

if grep -rnE "확정 필요|TBD|TODO" "${scan_targets[@]}"; then
  echo
  echo "Release blockers remain. Resolve placeholders before deployment approval." >&2
  blockers=1
fi

if [ "${blockers}" -ne 0 ]; then
  exit 1
fi

echo "No release placeholders found."
