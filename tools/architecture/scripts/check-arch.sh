#!/usr/bin/env bash
# tools/architecture/scripts/check-arch.sh — FSD mimari kapısı (F4 · T4.3)
# Steiger (custom plugin dahil) + knip — CI ve pre-commit'te çalışır.
# İhlal varsa exit 1 → commit/push/CI engellenir.

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "[arch] steiger ./src (FSD + temel/no-upward-import)..."
npx steiger ./src

echo "[arch] knip (ölü kod)..."
npx knip

echo "[arch] OK — mimari kapılar temiz"
