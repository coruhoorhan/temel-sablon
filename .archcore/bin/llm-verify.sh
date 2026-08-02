#!/usr/bin/env bash
# llm-verify.sh — K1 LLM verifier kapısı (lefthook job'ı, FAZ 2'de etkinleşir)
# 1) skip listesi: lockfile/generated/docs/vendor → LLM çağrısı YOK
# 2) diff ≤300 satır → opencode verifier ajanı
# 3) diff >300 → "diff'i böl" uyarısı (yalnız deterministik kalır)
# 4) 60sn timeout = fail-open (LLM arızası commit'i engellemez)
# Çıkış: 0=geçti · 2=BLOCK (deterministik kapılarla aynı semantik)

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
STAGED="${1:-}"

# --- 1. skip listesi ---
SKIP_PATTERN='(^|/)(lockfile|pnpm-lock\.yaml|package-lock\.json|yarn\.lock|bun\.lockb|\.gen\.|/generated/|/docs/|/vendor/)(/|$|\.)'
if [[ -n "$STAGED" ]]; then
  if printf '%s' "$STAGED" | grep -qE "$SKIP_PATTERN"; then
    echo "[llm-verify] skip: dosya skip listesinde (lockfile/generated/docs/vendor)"
    exit 0
  fi
fi

# --- 2. diff boyutu eşiği ---
diff_lines=0
diff_lines="$(git diff --cached --numstat 2>/dev/null | awk '{a+=$1; d+=$2} END {print a+d}')"
diff_lines="${diff_lines:-0}"

if [[ "$diff_lines" -gt 300 ]]; then
  echo "[llm-verify] UYARI: diff $diff_lines satır > 300 — 'diff'i böl' (verifier atlandı, deterministik kapılar çalışır)" >&2
  exit 0
fi

if [[ "$diff_lines" -eq 0 ]]; then
  echo "[llm-verify] diff yok — atlandı"
  exit 0
fi

# --- 3. verifier ajanı (headless, JSON) ---
# Bölüm 10.1: opencode run --agent verifier --format json --auto
# Bölüm 8.2: exit 2 = BLOCK (Claude Code semantiği; 1 = non-blocking)
# Diff dosyaya yazılır, verifier read tool ile okur (bash tool'una güven yok).
DIFF_FILE="/tmp/llm-verify-diff.txt"
git diff --cached > "$DIFF_FILE"

timeout 60 bash -c '
  opencode run --agent verifier --format json --auto \
    "Şu diff dosyasını denetle: '$DIFF_FILE'" 2>/dev/null || true
' >/tmp/llm-verify-out.json 2>/tmp/llm-verify-err.log || {
  echo "[llm-verify] timeout/arıza → fail-open (kapı atlandı, günlük: /tmp/llm-verify-err.log)" >&2
  exit 0
}

# --- 4. çıktı işleme: BLOCK bulgu varsa exit 2 ---
if grep -q '"severity": *"BLOCK"' /tmp/llm-verify-out.json 2>/dev/null; then
  echo "[llm-verify] BLOCK bulgular var — commit reddedildi (rapor: /tmp/llm-verify-out.json)" >&2
  exit 2
fi

# JSON şeması bozuksa fail-closed mi fail-open mi? → fail-open (Bölüm 10.2 kararı: 60sn timeout fail-open)
if ! grep -q '"verdict"' /tmp/llm-verify-out.json 2>/dev/null; then
  echo "[llm-verify] UYARI: verifier çıktısı parse edilemedi — fail-open" >&2
  exit 0
fi

echo "[llm-verify] OK: verifier PASS ($diff_lines satır)"
exit 0
