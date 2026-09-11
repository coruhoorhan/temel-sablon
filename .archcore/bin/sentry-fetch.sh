#!/usr/bin/env bash
# sentry-fetch.sh — Sentry API ile Otonom Hata ve Log Çekme Yardımcısı
# Victor Falcon sentry-issues ve sentry-logs iş akışlarını besleyen CLI aracı.

set -euo pipefail

MODE="${1:-issues}"
LIMIT="${2:-5}"

if [[ -z "${SENTRY_AUTH_TOKEN:-}" || -z "${SENTRY_ORG:-}" || -z "${SENTRY_PROJECT:-}" ]]; then
  if [[ "${MODE}" == "--mock" || "${MODE}" == "mock" ]]; then
    # Test ve simülasyon amaçlı mock Sentry payload'ı
    cat << 'JSON'
[
  {
    "id": "1001",
    "title": "TypeError: Cannot read properties of undefined (reading 'avatarUrl')",
    "culprit": "src/features/profile/ui/Avatar.tsx in render",
    "permalink": "https://sentry.io/organizations/demo/issues/1001/",
    "count": "42",
    "firstSeen": "2026-09-11T12:00:00Z",
    "lastSeen": "2026-09-11T16:00:00Z",
    "metadata": {
      "type": "TypeError",
      "value": "Cannot read properties of undefined (reading 'avatarUrl')"
    }
  }
]
JSON
    exit 0
  fi

  echo "[sentry-fetch] BİLGİ: SENTRY_AUTH_TOKEN, SENTRY_ORG veya SENTRY_PROJECT tanımlı değil." >&2
  echo "[sentry-fetch] Canlı Sentry ortamı için .env dosyasına kimlik bilgilerini ekleyin veya '--mock' ile test edin." >&2
  exit 1
fi

BASE_URL="https://sentry.io/api/0"

case "$MODE" in
  issues)
    curl -s -f \
      -H "Authorization: Bearer ${SENTRY_AUTH_TOKEN}" \
      -H "Content-Type: application/json" \
      "${BASE_URL}/projects/${SENTRY_ORG}/${SENTRY_PROJECT}/issues/?query=is:unresolved&limit=${LIMIT}"
    ;;
  logs)
    curl -s -f \
      -H "Authorization: Bearer ${SENTRY_AUTH_TOKEN}" \
      -H "Content-Type: application/json" \
      "${BASE_URL}/projects/${SENTRY_ORG}/${SENTRY_PROJECT}/events/?limit=${LIMIT}"
    ;;
  *)
    echo "Kullanım: $0 (issues | logs | mock) [limit]" >&2
    exit 1
    ;;
esac
