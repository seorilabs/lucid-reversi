#!/usr/bin/env bash
set -euo pipefail

bundle_sha="8a11a145fed35479a4a89ebc7ca97edd0a0f05fd"
workflow_dir=".github/workflows"

required_pins=(
  "cleanup-actions-storage.yml:cleanup-actions-storage.yml"
  "deploy-app-store.yml:godot-deploy-app-store.yml"
  "deploy-apps-in-toss.yml:godot-deploy-ait.yml"
  "deploy-godot-pages.yml:godot-pages.yml"
  "deploy-google-play.yml:godot-deploy-google-play.yml"
  "godot-checks.yml:godot-checks.yml"
  "release-tag.yml:release-tag.yml"
)

for binding in "${required_pins[@]}"; do
  caller="${binding%%:*}"
  reusable="${binding#*:}"
  expected="uses: seorilabs/.github/.github/workflows/${reusable}@${bundle_sha}"
  if ! grep -Fq "${expected}" "${workflow_dir}/${caller}"; then
    echo "Missing exact WorkflowBundle pin: ${caller} -> ${reusable}@${bundle_sha}" >&2
    exit 1
  fi
done

if grep -R -n -E 'secrets:[[:space:]]*inherit|seorilabs/\.github/.+@(main|master|latest)' "${workflow_dir}"; then
  echo "Release callers must use named secrets and immutable central SHAs." >&2
  exit 1
fi

play_caller="${workflow_dir}/deploy-google-play.yml"
tag_builder="${workflow_dir}/build-google-play.yml"

grep -Fq "package_name: com.etlegame.reversi" "${play_caller}"
grep -Fq 'upload: ${{ inputs.upload == '\''true'\'' || inputs.upload == true }}' "${play_caller}"
if grep -Eq '^[[:space:]]+version_(name|code):' "${play_caller}"; then
  echo "Repo-local Google Play version inputs are not release authority." >&2
  exit 1
fi

grep -Fq -- '- "v*.*.*"' "${tag_builder}"
grep -Fq "uses: ./.github/workflows/deploy-google-play.yml" "${tag_builder}"
grep -Fq "upload: false" "${tag_builder}"

# Tag creation must not implicitly upload to any market. AppsInToss and App Store
# remain explicit workflow_dispatch/workflow_call gates.
for manual_market in deploy-apps-in-toss.yml deploy-app-store.yml; do
  if grep -Eq '^[[:space:]]+push:' "${workflow_dir}/${manual_market}"; then
    echo "${manual_market} must remain an explicit gate without a tag push trigger." >&2
    exit 1
  fi
done

echo "Release workflow contract passed."
