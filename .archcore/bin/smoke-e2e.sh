#!/usr/bin/env bash
# smoke-e2e — şablonun kendi uçtan uca duman testi: commit'li ağaçtan temp
# dizine kurulum + kapıların pozitif/negatif senaryoları. CI'da koşar.
# Kullanım: smoke-e2e.sh  (repo kökünden)
set -euo pipefail
export ALLOW_MAIN_COMMIT=1

ROOT="$(git rev-parse --show-toplevel)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git -C "$ROOT" archive HEAD | tar -x -C "$TMP"
printf 'smoke-proje\n\n' | (cd "$TMP" && bash setup.sh > smoke.log 2>&1) || {
  echo "[smoke] RED: setup.sh başarısız — smoke.log kuyruğu:" >&2
  tail -n 15 "$TMP/smoke.log" >&2
  exit 1
}
grep -q "KURULUM BAŞARILI" "$TMP/smoke.log" || {
  echo "[smoke] RED: BAŞARILI imzası yok" >&2
  exit 1
}
(cd "$TMP" && printf 'test: plansiz\n' | .archcore/bin/verify-commit-msg - >/dev/null 2>&1) && {
  echo "[smoke] RED: plansız commit geçmemeliydi" >&2
  exit 1
}
echo "[smoke] OK: kurulum + plan-gate negatif senaryo yeşil"
exit 0
