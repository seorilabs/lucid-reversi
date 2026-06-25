#!/usr/bin/env bash
set -euo pipefail

required_files=(
  "docs/README.md"
  "docs/01-planning/product-spec.md"
  "docs/02-decisions/0001-docs-as-source-of-truth.md"
  "docs/03-architecture/clean-architecture.md"
  "docs/05-markets/google-play.md"
  "docs/05-markets/app-store.md"
  "docs/05-markets/apps-in-toss.md"
  "docs/06-release/release-checklist.md"
  "docs/07-qa/test-strategy.md"
  "docs/08-ops/dependencies.md"
)

for file in "${required_files[@]}"; do
  if [ ! -f "${file}" ]; then
    echo "Missing docs source file: ${file}" >&2
    exit 1
  fi
done

if ! grep -q "Lucid Reversi" docs/01-planning/product-spec.md; then
  echo "Product spec does not mention Lucid Reversi." >&2
  exit 1
fi

if ! grep -q "루시드 리버시" docs/01-planning/product-spec.md; then
  echo "Product spec does not mention 루시드 리버시." >&2
  exit 1
fi

echo "Docs source-of-truth structure check passed."
