#!/usr/bin/env bash
# ci-watch.sh — GitHub CI İzleme ve Otonom Log Çekme Yardımcısı
# Victor Falcon pr-ci iş akışını çalıştırmak için gh cli sarmalayıcısıdır.

set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "[ci-watch] UYARI: 'gh' (GitHub CLI) kurulu değil. CI durumunu web arayüzünden izleyin." >&2
  exit 0
fi

PR_ARG="${1:-}"

echo "[ci-watch] CI kontrolleri izleniyor..."
if ! gh pr checks ${PR_ARG} --watch --fail-fast; then
  echo "[ci-watch] CI kontrolü BAŞARISIZ oldu! Başarısız loglar çekiliyor..."
  gh run view --log-failed || true
  exit 1
fi

echo "[ci-watch] Tüm CI kontrolleri YEŞİL! Görev başarıyla tamamlandı."
exit 0
