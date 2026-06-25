#!/usr/bin/env bash
set -euo pipefail

required_dirs=(
  "packages/product-core/src/domain"
  "packages/product-core/src/use_cases"
  "packages/product-core/src/ports"
  "packages/product-core/tests"
)

required_files=(
  "godot/scripts/reversi_engine.gd"
  "godot/tests/test_runner.gd"
)

for dir in "${required_dirs[@]}"; do
  if [ ! -d "${dir}" ]; then
    echo "Missing core directory: ${dir}" >&2
    exit 1
  fi
done

for file in "${required_files[@]}"; do
  if [ ! -f "${file}" ]; then
    echo "Missing core file: ${file}" >&2
    exit 1
  fi
done

echo "Core scaffold and Reversi engine smoke entrypoint are present."
