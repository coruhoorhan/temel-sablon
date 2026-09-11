#!/usr/bin/env bash
# verify-qa-evidence — UI ve Görsel Kanıt Mekanik Kapısı
# UI dosyasına dokunan her değişiklik, ya E2E/Bileşen testi ya da .scratch/qa/ altında kanıt içermek zorundadır.
# Victor Falcon qa-change disiplininin OS/Git seviyesindeki mekanik kilididir.

set -euo pipefail

files=()
if [[ "${1:-}" == "--stdin" ]]; then
  mapfile -t files
elif [[ $# -eq 2 ]]; then
  mapfile -t files < <(git diff --name-only "$1" "$2" 2>/dev/null || true)
else
  echo "kullanım: $0 (--stdin | BASE HEAD)" >&2
  exit 2
fi

ui_hit=0
e2e_hit=0

for f in "${files[@]}"; do
  case "$f" in
    e2e/*.spec.*|e2e/**/*.spec.*|e2e/*.test.*|e2e/**/*.test.*|src/**/*.test.tsx|src/**/*.spec.tsx)
      e2e_hit=1
      ;;
    src/**/*.tsx|src/**/*.jsx|src/app/**/*.ts|src/pages/**/*.ts|src/**/ui/**)
      ui_hit=1
      ;;
  esac
done

if [[ "$ui_hit" -eq 1 && "$e2e_hit" -eq 0 ]]; then
  # Eğer test dosyası commit'te yoksa, son 1 saat içinde .scratch/qa altında görsel kanıt var mı bak
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  QA_DIR="$ROOT/.scratch/qa"
  has_artifact=0
  if [[ -d "$QA_DIR" ]]; then
    if find "$QA_DIR" -type f \( -name "*.png" -o -name "*.mp4" -o -name "*.webm" -o -name "*.html" \) -mmin -60 | grep -q .; then
      has_artifact=1
    fi
  fi

  if [[ "$has_artifact" -eq 0 ]]; then
    echo "[qa-gate] RED: UI koduna dokundun ama E2E testi (e2e/*.spec.ts) veya görsel kanıt (.scratch/qa/*.png/*.mp4) yok." >&2
    echo "[qa-gate] Victor Falcon qa-change kuralı: Kanıtsız UI teslimatı yasaktır." >&2
    echo "[qa-gate] Çözüm: E2E testi ekle ('npm run test:e2e') veya Playwright ile kanıt üretip .scratch/qa klasörüne kaydet." >&2
    exit 1
  fi
fi

echo "[qa-gate] OK"
exit 0
