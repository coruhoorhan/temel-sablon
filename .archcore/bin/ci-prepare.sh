#!/usr/bin/env bash
# ci-prepare.sh — CI için template'lerden gerçek dosyaları üretir (T1.5/T2.1/T3.1/T5.1)
# Kök neden: .agt/, .midas/, .mcp.json gitignore'lı ve repo'da YOK — yalnız
# .template'ler commit'li. setup.sh bunları lokal üretir; CI'da da üretilmeli.
# Tüm workflow'lar checkout sonrası bunu çağırır: bash .archcore/bin/ci-prepare.sh
#
# Yalnız KOPYALAMA — tool kurmaz, doğrulama yapmaz (işi ilgili job yapar).
# İdempotent: dosya varsa dokunmaz.

set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

prep() { # prep <template> <hedef>
  local tmpl="$1" target="$2"
  if [[ -f "$target" ]]; then return 0; fi
  if [[ -f "$tmpl" ]]; then
    mkdir -p "$(dirname "$target")"
    cp "$tmpl" "$target"
    echo "[ci-prepare] $target ← template"
  else
    echo "[ci-prepare] UYARI: $tmpl yok — $target üretilemedi" >&2
  fi
}

# F1 — Midas config
prep .midas/config.yaml.template .midas/config.yaml

# F2 — AGT policy + fixtures + manifest
prep .agt/policy.yaml.template .agt/policy.yaml
prep .agt/fixtures/policy.test.yaml.template .agt/fixtures/policy.test.yaml
prep .agt/manifest.yaml.template .agt/manifest.yaml

# F3 — MCP gateway + .mcp.json
prep .agt/mcp-gateway.yaml.template .agt/mcp-gateway.yaml
prep .mcp.json.template .mcp.json

echo "[ci-prepare] tamam"
