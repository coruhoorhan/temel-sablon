#!/usr/bin/env bash
# verify-tdd-impact — TDD kaba kapısı (R8): src üretim dosyasına dokunan
# değişiklik test dosyasıyla birlikte gelmeli. Safha ayrımı yapmaz
# (red-green sırasını değil, test varlığını denetler) — derin denetim verifier'da.
# Kullanım: verify-tdd-impact.sh --stdin  (dosya listesi stdin'den)
#           verify-tdd-impact.sh BASE HEAD (CI aralığı)
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

src_hit=0
test_hit=0
for f in "${files[@]}"; do
  case "$f" in
    src/*.test.*|src/**/*.test.*|src/*.spec.*|src/**/*.spec.*|src/**/__tests__/*|test/*|test/**/*|tests/*|tests/**/*)
      test_hit=1
      ;;
    src/**/*.d.ts|src/*.d.ts)
      ;;
    src/*.ts|src/**/*.ts|src/*.tsx|src/**/*.tsx|src/*.js|src/**/*.js|src/*.jsx|src/**/*.jsx)
      src_hit=1
      ;;
  esac
done

if [[ "$src_hit" -eq 1 && "$test_hit" -eq 0 ]]; then
  echo "[tdd] RED: src üretim dosyasına dokundun ama test yok." >&2
  echo "[tdd] Test ekle ya da kapsamı plan revizyonuyla netleştir." >&2
  exit 1
fi
echo "[tdd] OK"
exit 0
