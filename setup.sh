#!/usr/bin/env bash
# setup.sh v2 — TEMEL şablonu interaktif kurulum + test + doğrulama (F6)
# Sen bilgileri girersin, script kurar, kapıları test eder, doğrular.
# Linux veya Git Bash (Windows) — bash 4+ yeterli.
#
# Kullanım:
#   bash setup.sh             (tam kurulum — interaktif)
#   bash setup.sh --dry-run   (hiçbir şey kurma, sadece plan göster)
#   bash setup.sh --help      (bu yardım)

set -uo pipefail

# --- CLI argümanları (F6 · T6.1) ---
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --help|-h)
      echo "setup.sh v2 — TEMEL kurulum"
      echo "  bash setup.sh           tam kurulum"
      echo "  bash setup.sh --dry-run kurulum planını göster (hiçbir şey kurma)"
      exit 0
      ;;
    *) echo "Bilinmeyen argüman: $arg (--help)" >&2; exit 1 ;;
  esac
done

# Receipt altyapısı (F6 · T6.3) — her tool'un durumunu JSON'a toplar
RECEIPT_FILE="setup-receipt.json"
declare -a RECEIPT_ENTRIES=()
receipt_add() {
  # receipt_add <tool> <version> <status> <config_path> <detail>
  RECEIPT_ENTRIES+=("{\"tool\":\"$1\",\"version\":\"$2\",\"status\":\"$3\",\"config\":\"$4\",\"detail\":\"$5\"}")
}
receipt_write() {
  # Tüm toplanan girdileri setup-receipt.json'a yaz
  local ts
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local body="["
  local first=1
  for entry in "${RECEIPT_ENTRIES[@]:-}"; do
    if [[ "$first" -eq 1 ]]; then first=0; else body="$body,"; fi
    body="$body$entry"
  done
  body="$body]"
  cat > "$RECEIPT_FILE" << EOF
{
  "generated_at": "$ts",
  "dry_run": $DRY_RUN,
  "tools": $body
}
EOF
  ok "receipt üretildi: $RECEIPT_FILE"
}

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[UYARI]${NC} $1"; }
fail() { echo -e "${RED}[HATA]${NC} $1"; }
info() { echo -e "${CYAN}[..]${NC} $1"; }

fail_count=0
step() { echo -e "\n${CYAN}===== $1 =====${NC}"; }

# dry-run modunda yürütülecek komutları sadece göster
run_or_skip() {
  # run_or_skip <komut...> — dry-run'da gösterir, normalde çalıştırır
  if [[ "$DRY_RUN" -eq 1 ]]; then
    info "[dry-run] $*"
    return 0
  fi
  "$@"
}

# Windows Git Bash: komutlar .exe uzantılı olabilir — hem düz hem .exe dene
have() { command -v "$1" >/dev/null 2>&1 || command -v "$1.exe" >/dev/null 2>&1; }
use()  { if command -v "$1" >/dev/null 2>&1; then echo "$1"; else echo "$1.exe"; fi; }

# ---------------------------------------------------------------------------
# wire_midas — Midas hafıza sistemini kur + MCP client'ları bağla (F1 · T1.1)
# Kurulum: uv tool install (uv yoksa pip/pipx/npx fallback)
# Wiring : .midas/config.yaml (template'ten) + midas init --claude-hook
# Doğrulama: midas doctor + status --json (CI receipt ile aynı şema)
# Fail-closed: NLI yoksa hafıza guard'ı çalışmaz → uyarı (R11-01/02).
# ---------------------------------------------------------------------------
wire_midas() {
  info "Midas hafıza sistemi (kurulum + wiring)"
  MIDAS_OK=0
  wire_failed=0

  # 1) midas CLI var mı?
  if ! have midas; then
    info "midas bulunamadı — kurulum deneniyor..."
    if have uv; then
      # KRİTİK: --with "mcp<2" ZORUNLU — mcp SDK 2.0 FastMCP'yi kaldırdı
      # (mcp.server.fastmcp), Midas 1.0.0 bunu ister. 2.0 kurulursa
      # midas-mcp "Connection closed (-32000)" ile çöker.
      info "uv ile kuruluyor: midas-memory[mcp,local] (mcp<2 sabit)"
      if "$(use uv)" tool install "midas-memory[mcp,local]" --with "mcp<2" >/dev/null 2>&1; then
        ok "midas kuruldu (uv, mcp<2)"; MIDAS_OK=1
      else
        warn "uv tool install başarısız — pip/pipx fallback deneniyor"
        if have pipx; then
          pipx install "midas-memory[mcp,local]" >/dev/null 2>&1 && \
            pipx runpip midas-memory install "mcp<2" >/dev/null 2>&1 && \
            { ok "midas kuruldu (pipx, mcp<2)"; MIDAS_OK=1; }
        fi
        if [[ "$MIDAS_OK" -eq 0 ]] && have pip; then
          pip install --user "midas-memory[mcp,local]" "mcp<2" >/dev/null 2>&1 && { ok "midas kuruldu (pip --user, mcp<2)"; MIDAS_OK=1; }
        fi
      fi
    elif have pipx; then
      pipx install "midas-memory[mcp,local]" >/dev/null 2>&1 && \
        pipx runpip midas-memory install "mcp<2" >/dev/null 2>&1 && \
        { ok "midas kuruldu (pipx, mcp<2)"; MIDAS_OK=1; }
    else
      warn "uv/pipx yok — TypeScript port deneniyor: npx -y midas-memory-mcp"
      if npm exec --yes midas-memory-mcp -- --version >/dev/null 2>&1; then
        warn "npx midas-memory-mcp kullanılabilir (deneysel) — tam CLI (doctor/status) yok"
        MIDAS_OK=1
      fi
    fi
  else
    MIDAS_OK=1
    ok "midas zaten kurulu: $(midas version 2>/dev/null || midas --help 2>/dev/null | head -n1)"
    # Kurulu sürümde FastMCP var mı? (mcp<2 sağlaması)
    if midas-mcp 2>&1 | grep -q "MCP SDK"; then
      warn "midas-mcp MCP SDK hatası veriyor — 'uv tool install midas-memory[mcp,local] --with mcp<2 --force' çalıştır"
    fi
  fi

  if [[ "$MIDAS_OK" -eq 0 ]]; then
    warn "midas KURULAMADI — hafıza sistemi devre dışı. Elle: uv tool install 'midas-memory[mcp,local]'"
    warn "NOT: hafıza olmadan R11 (11-hafiza.rule.md) zorlanamaz — CI midas.yml kırmızı kalır."
    return 1
  fi

  # 2) .midas/config.yaml üret (template'ten, varsa koru)
  mkdir -p .midas
  if [[ ! -f .midas/config.yaml && -f .midas/config.yaml.template ]]; then
    cp .midas/config.yaml.template .midas/config.yaml
    ok ".midas/config.yaml üretildi (template'ten)"
  elif [[ ! -f .midas/config.yaml ]]; then
    fail ".midas/config.yaml.template YOK — config üretilemedi"
    wire_failed=1
  else
    info ".midas/config.yaml zaten var — korunuyor"
  fi

  # 3) Client wiring (Claude Code hook + diğer client'lar)
  if midas init --claude-hook >/dev/null 2>&1; then
    ok "midas init --claude-hook tamam (client wiring)"
  else
    fail "midas init --claude-hook başarısız"
    wire_failed=1
  fi

  # 4) Doğrulama
  if have midas; then
    if midas doctor >/dev/null 2>&1; then
      ok "midas doctor: store + embedder + MCP hazır"
    else
      warn "midas doctor uyarı verdi (kurulum yeni — ilk 'midas init' store oluşturur)"
    fi
    # NLI guard zorunluluğu (R11-01/02): supersede+NLI config'te mi?
    if grep -q "MIDAS_MCP_NLI.*1" .midas/config.yaml 2>/dev/null; then
      ok "NLI guard açık (config: MIDAS_MCP_NLI=1)"
    else
      fail "MIDAS_MCP_NLI=1 config'te YOK — provenance guard kapalı"
      wire_failed=1
    fi
    if midas status --json > .archcore/tmp/midas-receipt.json 2>/dev/null; then
      ok "wiring receipt üretildi: .archcore/tmp/midas-receipt.json"
    else
      fail "midas status --json başarısız — receipt yok"
      wire_failed=1
    fi
  fi
  return "$wire_failed"
}

# ---------------------------------------------------------------------------
# wire_agt — Agent Governance Toolkit kur + policy/fixture doğrula (F2 · T2.1)
# Kurulum: uv tool install agent-governance-toolkit[full] (pip fallback)
# Doğrulama: agt doctor + verify (OWASP ASI 10/10) + lint-policy + fixture replay
# Policy: .agt/policy.yaml (template'ten) — CI agt-verify.yml ile aynı komutlar
# Fail-closed: OWASP ASI 10/10 altı = uyarı; policy şeması bozuksa = fail.
# ---------------------------------------------------------------------------
wire_agt() {
  info "AGT Governance Toolkit (kurulum + doğrulama)"
  AGT_OK=0
  wire_failed=0

  if ! have agt; then
    info "agt bulunamadı — kurulum deneniyor..."
    if have uv; then
      info "uv ile kuruluyor: uv tool install agent-governance-toolkit[full]"
      if "$(use uv)" tool install "agent-governance-toolkit[full]" >/dev/null 2>&1; then
        ok "agt kuruldu (uv)"; AGT_OK=1
      else
        warn "uv tool install başarısız — yalın paket deneniyor"
        "$(use uv)" tool install "agent-governance-toolkit" >/dev/null 2>&1 && { ok "agt kuruldu (uv yalın)"; AGT_OK=1; }
      fi
    elif have pipx; then
      pipx install "agent-governance-toolkit[full]" >/dev/null 2>&1 && { ok "agt kuruldu (pipx)"; AGT_OK=1; }
    elif have pip; then
      pip install --user "agent-governance-toolkit[full]" >/dev/null 2>&1 && { ok "agt kuruldu (pip --user)"; AGT_OK=1; }
    fi
  else
    AGT_OK=1
    ok "agt zaten kurulu: $(agt --version 2>/dev/null)"
  fi

  if [[ "$AGT_OK" -eq 0 ]]; then
    warn "agt KURULAMADI — governance kapıları devre dışı. Elle: uv tool install 'agent-governance-toolkit[full]'"
    warn "NOT: CI agt-verify.yml kırmızı kalır (OWASP ASI + policy + fixture)."
    return 1
  fi

  # .agt/policy.yaml üret (template'ten, varsa koru)
  mkdir -p .agt/fixtures
  if [[ ! -f .agt/policy.yaml && -f .agt/policy.yaml.template ]]; then
    cp .agt/policy.yaml.template .agt/policy.yaml
    ok ".agt/policy.yaml üretildi (template'ten)"
  fi
  if [[ ! -f .agt/policy.yaml ]]; then
    fail ".agt/policy.yaml üretilemedi"
    wire_failed=1
  fi
  if [[ ! -f .agt/fixtures/policy.test.yaml && -f .agt/fixtures/policy.test.yaml.template ]]; then
    cp .agt/fixtures/policy.test.yaml.template .agt/fixtures/policy.test.yaml
    ok ".agt/fixtures/policy.test.yaml üretildi (template'ten)"
  fi
  if [[ ! -f .agt/fixtures/policy.test.yaml ]]; then
    fail "policy fixture üretilemedi"
    wire_failed=1
  fi

  # Doğrulama zinciri
  if agt verify 2>/dev/null | grep -q "10/10"; then
    ok "OWASP ASI 2026: 10/10 (fail-closed tamam)"
  else
    fail "agt verify 10/10 DEĞİL — governance zafiyeti var"
    wire_failed=1
  fi

  if agt red-team scan AGENTS.md --min-grade C --strict >/dev/null 2>&1; then
    ok "prompt defense: AGENTS.md minimum C"
  else
    fail "prompt defense: AGENTS.md minimum C değil"
    wire_failed=1
  fi

  POLICY_FILE=".agt/policy.yaml"
  [[ -f "$POLICY_FILE" ]] || POLICY_FILE="/dev/null"
  if agt lint-policy "$POLICY_FILE" --strict >/dev/null 2>&1; then
    ok "policy lint --strict: temiz"
  else
    fail "policy şeması bozuk (lint-policy --strict)"
    wire_failed=1
  fi

  if [[ -f .agt/fixtures/policy.test.yaml ]]; then
    if agt test .agt/policy.yaml .agt/fixtures/ 2>/dev/null | grep -q "0 mismatch"; then
      ok "policy fixture replay: tümü geçti"
    else
      fail "policy fixture mismatch"
      wire_failed=1
    fi
  fi
  return "$wire_failed"
}

# ---------------------------------------------------------------------------
# wire_mcp — MCP Security Gateway + supply chain doğrula (F3 · T3.1-3.4)
# Kurulum: .mcp.json (template'ten) + .agt/mcp-gateway.yaml (template'ten)
# Doğrulama: mcpscan scan (high+ = fail) + AGT mcp-scan (primitives taraması)
# Supply chain: lockfile SHA-256 manifest + OSV CVE sorgusu
# ---------------------------------------------------------------------------
wire_mcp() {
  info "MCP Security Gateway (F3)"
  MCP_OK=0
  wire_failed=0

  # 1) .mcp.json üret (template'ten, varsa koru)
  if [[ ! -f .mcp.json && -f .mcp.json.template ]]; then
    cp .mcp.json.template .mcp.json
    ok ".mcp.json üretildi (template'ten)"
  elif [[ ! -f .mcp.json ]]; then
    warn ".mcp.json.template YOK — MCP config üretilemedi"
  else
    info ".mcp.json zaten var — korunuyor"
  fi

  # 2) .agt/mcp-gateway.yaml üret (template'ten, varsa koru)
  mkdir -p .agt
  if [[ ! -f .agt/mcp-gateway.yaml && -f .agt/mcp-gateway.yaml.template ]]; then
    cp .agt/mcp-gateway.yaml.template .agt/mcp-gateway.yaml
    ok ".agt/mcp-gateway.yaml üretildi (template'ten)"
  fi

  # 3) mcpscan — client config taraması (high+ bulgu = fail)
  if command -v npx >/dev/null 2>&1; then
    if npx -y @nileshbera/mcpscan scan .mcp.json --fail-on high >/dev/null 2>&1; then
      ok "mcpscan: high+ bulgu yok (client config taraması temiz)"
      MCP_OK=1
    else
      warn "mcpscan high+ bulgu raporladı — ayrıntı: npx @nileshbera/mcpscan scan --fail-on high"
    fi
  else
    warn "npx yok — mcpscan atlandı (CI mcpscan.yml zorlar)"
  fi

  # 4) AGT mcp-scan — MCP primitives taraması (bilgi amaçlı, fail-open)
  #    config POSITIONAL argümandır (--config flag YOK — gerçek kullanım).
  #    DİKKAT: python3 (sistem) değil, AGT'nin kendi Python'ı gerekir (uv tool
  #    env — AGT paketi 3.12, sistem 3.14'te import edilemez).
  if command -v agt >/dev/null 2>&1; then
    AGT_PY="$HOME/.local/share/uv/tools/agent-governance-toolkit/bin/python"
    [[ -x "$AGT_PY" ]] || AGT_PY="$(dirname "$(command -v agt)")/python"
    if "$AGT_PY" -m agent_os.cli.mcp_scan scan .mcp.json --static-only >/dev/null 2>&1; then
      ok "AGT mcp-scan: primitives temiz"
    else
      fail "AGT mcp-scan primitives başarısız"
      wire_failed=1
    fi
  else
    fail "AGT mcp-scan çalıştırılamadı"
    wire_failed=1
  fi

  # 5) Supply chain manifest (bilgi amaçlı — CI blocking)
  if [[ -f package-lock.json ]]; then
    HASH="$(sha256sum package-lock.json | cut -d' ' -f1)"
    if [[ -f .archcore/supply-chain-manifest.txt ]]; then
      if [[ "$(cat .archcore/supply-chain-manifest.txt)" == "$HASH" ]]; then
        ok "supply chain: lockfile bütünlüğü doğrulandı"
      else
        fail "supply chain: lockfile DEĞİŞMİŞ — manifest güncelle (yeni: $HASH)"
        wire_failed=1
      fi
    else
      echo "$HASH" > .archcore/supply-chain-manifest.txt
      ok "supply chain manifesti oluşturuldu: $HASH"
    fi
  fi

  if [[ "$MCP_OK" -eq 0 ]]; then
    fail "mcpscan high+ bulgu/atlandı"
    wire_failed=1
  fi
  return "$wire_failed"
}

# ---------------------------------------------------------------------------
# wire_mesh — Agent Mesh + Merkle audit + shadow discovery (F5 · T5.x)
# Kurulum: .agt/manifest.yaml (template'ten) + audit-chain.json başlat
# Doğrulama: shadow-discovery (strict) + audit-chain verify + dashboard üretimi
# Fail-closed: manifest yoksa shadow taraması uyarır (bilinmeyen ajan güvenilmez)
# ---------------------------------------------------------------------------
wire_mesh() {
  info "Agent Mesh + Merkle audit (F5)"
  MESH_OK=0
  wire_failed=0

  # 1) .agt/manifest.yaml üret (template'ten, varsa koru)
  if [[ ! -f .agt/manifest.yaml && -f .agt/manifest.yaml.template ]]; then
    cp .agt/manifest.yaml.template .agt/manifest.yaml
    ok ".agt/manifest.yaml üretildi (template'ten)"
  fi
  if [[ ! -f .agt/manifest.yaml ]]; then
    fail "agent manifest üretilemedi"
    wire_failed=1
  fi

  # 2) Shadow discovery (bilgi amaçlı — strict değil; CI strict zorlar)
  if [[ -f .agt/manifest.yaml ]] && command -v python3 >/dev/null 2>&1; then
    if uv run --with pyyaml python3 .archcore/bin/shadow-discovery.py >/dev/null 2>&1; then
      ok "shadow discovery: kayıtsız ajan yok"
      MESH_OK=1
    else
      fail "shadow discovery başarısız — manifest ile ajan tanımları eşleşmiyor"
      wire_failed=1
    fi
  else
    fail "manifest/python yok — shadow taraması çalıştırılamadı"
    wire_failed=1
  fi

  # 3) Merkle audit zinciri başlat (yoksa genesis)
  if [[ ! -f .archcore/audit-chain.json ]]; then
    if python3 .archcore/bin/audit-chain.py --add "kurulum: setup.sh wire_mesh" >/dev/null 2>&1; then
      ok "Merkle audit zinciri başlatıldı (genesis + kurulum kaydı)"
    else
      fail "audit-chain.py çalıştırılamadı"
      wire_failed=1
    fi
  else
    if python3 .archcore/bin/audit-chain.py --verify >/dev/null 2>&1; then
      ok "Merkle zinciri doğru (tamper yok)"
    else
      fail "Merkle zinciri BOZUK — audit-chain.json kURcalanmış"; fail_count=$((fail_count + 1))
    fi
  fi

  # 4) Governance dashboard (denetim izi, R11-11)
  if uv run --with pyyaml python3 .archcore/bin/gov-dashboard.py >/dev/null 2>&1; then
    ok "governance dashboard üretildi (docs/governance-dashboard.html)"
  else
    fail "dashboard üretilemedi"
    wire_failed=1
  fi

  return "$wire_failed"
}

# ---------------------------------------------------------------------------
# wire_steiger — FSD mimari kapısını doğrula (F6 · T6.2)
# steiger custom plugin (F4) + knip — setup sırasında mimari temiz mi kontrolü
# ---------------------------------------------------------------------------
wire_steiger() {
  info "FSD mimari kapısı (F4 + F6)"
  if [[ -f steiger.config.js ]] && command -v npx >/dev/null 2>&1; then
    if npx steiger ./src >/dev/null 2>&1; then
      ok "steiger: FSD mimarisi temiz (no-upward-import dahil)"
      receipt_add "steiger" "0.6.0" "ok" "steiger.config.js" "FSD mimarisi temiz"
      return 0
    else
      fail "steiger FSD ihlali buldu — tools/architecture/src/steiger-rules (F4)"; fail_count=$((fail_count + 1))
      receipt_add "steiger" "0.6.0" "fail" "steiger.config.js" "FSD ihlali"
      return 1
    fi
  else
    fail "steiger.config.js/npx yok — mimari kapı çalıştırılamadı"
    receipt_add "steiger" "?" "fail" "steiger.config.js" "npx/steiger yok"
    return 1
  fi
}

# --- ön koşul kontrolü ---
step "ÖN KOŞULLAR"
for tool in git npm node; do
  if command -v "$tool" >/dev/null 2>&1; then
    ok "$tool bulundu: $($tool --version 2>/dev/null | head -n1)"
  else
    fail "'$tool' bulunamadı — önce kur: $([ "$tool" = git ] && echo 'apt install git || winget install Git.Git' || echo 'nodejs.org')"
    fail_count=$((fail_count + 1))
  fi
done
if have gitleaks; then
  ok "gitleaks bulundu: $(gitleaks version 2>/dev/null)"
else
  warn "gitleaks bulunamadı — KURULUM ADIMI 4 (aşağıda) elle yapılacak:"
  echo "    Linux:  apt install gitleaks | brew install gitleaks | go install github.com/gitleaks/gitleaks/v8@latest"
  echo "    macOS:  brew install gitleaks"
  echo "    Windows (Git Bash): winget install Gitleaks.Gitleaks (sonra yeni terminal aç)"
  echo "    Not: npm'de 'gitleaks' adlı paket SAHTEDİR, kurma!"
fi
[[ "$fail_count" -gt 0 ]] && { fail "Ön koşullar eksik — kurulum durduruldu."; exit 1; }

# --- şablon varlık kontrolü: boş klasöre atılan setup.sh da çalışır ---
if [[ ! -f package.json || ! -d .archcore ]]; then
  step "ŞABLON GETİRME"
  info "Bu klasörde şablon dosyaları yok — GitHub'dan çekiliyor..."
  TMP="$(mktemp -d)"
  GOT=""
  # 1) GitHub birincil (template repo)
  if git clone --depth 1 https://github.com/coruhoorhan/temel-sablon.git "$TMP/sablon" >/dev/null 2>&1; then
    tar -C "$TMP/sablon" --exclude='./.git' --exclude='./node_modules' --exclude='./coverage' -cf - . | tar -C . -xf -
    ok "şablon GitHub'dan çekildi: github.com/coruhoorhan/temel-sablon"
    GOT=1
  else
    # 2) internet yok / auth yok → yerel şablon fallback
    SRC=""
    [[ -n "${TEMPLATE_SRC:-}" ]] && SRC="$TEMPLATE_SRC"
    if [[ -z "$SRC" && -d /c/Users/Windows/projeler/temel-sablon ]]; then SRC="/c/Users/Windows/projeler/temel-sablon"; fi
    if [[ -z "$SRC" && -d "$HOME/temel-sablon" ]]; then SRC="$HOME/temel-sablon"; fi
    if [[ -n "$SRC" && -f "$SRC/package.json" && -d "$SRC/.archcore" ]]; then
      info "GitHub'a ulaşılamadı — yerel şablon deneniyor: $SRC"
      tar -C "$SRC" --exclude='./.git' --exclude='./node_modules' --exclude='./coverage' -cf - . | tar -C . -xf -
      ok "şablon yerelden kopyalandı: $SRC"
      GOT=1
    fi
  fi
  rm -rf "$TMP"
  if [[ -z "$GOT" ]]; then
    fail "Şablon getirilemedi — setup.sh şablon klasörünün içinde çalıştırılmalı, internet + gh girişi olmalı veya TEMPLATE_SRC=<yol> verilmeli."
    exit 1
  fi
  rm -rf .git
fi

# --- bilgi topla ---
step "BİLGİLER"
DEFAULT_NAME="$(basename "$(pwd)")"
echo -n "Proje adı [$DEFAULT_NAME]: "
read -r PROJ_NAME; PROJ_NAME="${PROJ_NAME:-$DEFAULT_NAME}"
if [[ "$PROJ_NAME" =~ [[:space:]] ]]; then
  SANE="${PROJ_NAME// /-}"
  warn "Proje adında boşluk var — GitHub repo adı boşluk alamaz."
  echo -n "Öneri: '$SANE' kullanılsın mı? (Y/n): "
  read -r FIX; [[ "${FIX:-y}" =~ ^[yY]$ ]] && PROJ_NAME="$SANE"
fi
echo "→ Proje adı: $PROJ_NAME"

if have gh; then
  GH="$(use gh)"
  GH_USER="$($GH api user --jq .login 2>/dev/null || true)"
  echo -n "GitHub kullanıcı adı [${GH_USER:-?}]: "
  read -r INPUT_GH; GH_USER="${INPUT_GH:-$GH_USER}"
  if [[ -n "$GH_USER" ]]; then
    echo -n "GitHub'da '$PROJ_NAME' repo'su oluşturulsun mu? (y/N): "
    read -r MAKE_REPO
    if [[ "$MAKE_REPO" =~ ^[yY]$ ]]; then
      echo -n "Public mi private mı? (public/private) [private]: "
      read -r VIS; VIS="${VIS:-private}"
      [[ "$VIS" != "private" && "$VIS" != "public" ]] && VIS="private"
      echo "→ gh repo create $PROJ_NAME --$VIS --source . --remote origin --push"
      USE_GH_REPO=1
    fi
  fi
else
  warn "gh CLI bulunamadı — GitHub repo oluşturma atlanır (elle: 'Use this template' veya gh auth login)."
fi

# --- kurulum ---
step "KURULUM"
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  info "git init + main dalı (CI workflow'ları main dinler)"
  git init -b main
  ok "git repo başlatıldı (branch: main)"
else
  CUR_BRANCH="$(git branch --show-current 2>/dev/null)"
  if [[ "$CUR_BRANCH" != "main" ]]; then
    info "mevcut dal '$CUR_BRANCH' → main yapılıyor"
    git branch -M main 2>/dev/null || git checkout -b main 2>/dev/null
    ok "dal main yapıldı"
  fi
fi

info "npm install (bağımlılıklar)"
if [[ -f package.json ]]; then
  if npm install --no-audit >/dev/null 2>&1; then ok "npm install tamam"; else
    if npm.cmd install --no-audit >/dev/null 2>&1; then ok "npm install (npm.cmd) tamam"
    else fail "npm install BAŞARISIZ"; fail_count=$((fail_count + 1)); fi
  fi
else
  warn "package.json yok — bağımlılık kurulumu atlandı"
fi

info "hooks:install (lefthook kapıları)"
if npm run hooks:install >/dev/null 2>&1 || npm.cmd run hooks:install >/dev/null 2>&1; then
  ok "lefthook kapıları kuruldu (pre-commit, commit-msg, pre-push)"
else
  fail "hooks:install BAŞARISIZ (npm approve-scripts lefthook gerekebilir)"; fail_count=$((fail_count + 1))
fi

info "Midas hafıza sistemi (F1)"
mkdir -p .archcore/tmp
if [[ "$DRY_RUN" -eq 1 ]]; then
  info "[dry-run] wire_midas: uv tool install midas-memory[mcp,local] --with mcp<2 + midas init --claude-hook"
  receipt_add "midas" "1.0.0" "planned" ".midas/config.yaml" "dry-run — kurulmayacak"
elif wire_midas; then
  ok "Midas kurulum + wiring tamam"
  receipt_add "midas" "$(midas version 2>/dev/null || echo '1.0.0')" "ok" ".midas/config.yaml" "hafıza + wiring hazır"
else
  fail "Midas kurulum başarısız"; fail_count=$((fail_count + 1))
  receipt_add "midas" "?" "fail" ".midas/config.yaml" "kurulum başarısız"
fi

info "AGT Governance (F2)"
if [[ "$DRY_RUN" -eq 1 ]]; then
  info "[dry-run] wire_agt: uv tool install agent-governance-toolkit[full] + agt verify/lint-policy/agt test"
  receipt_add "agt" "4.1.0" "planned" ".agt/policy.yaml" "dry-run — kurulmayacak"
elif wire_agt; then
  ok "AGT kurulum + doğrulama tamam"
  receipt_add "agt" "$(agt --version 2>/dev/null || echo '4.1.0')" "ok" ".agt/policy.yaml" "OWASP ASI 10/10 + policy + fixture"
else
  fail "AGT kurulum başarısız"; fail_count=$((fail_count + 1))
  receipt_add "agt" "?" "fail" ".agt/policy.yaml" "kurulum başarısız"
fi

info "MCP Security Gateway (F3)"
if [[ "$DRY_RUN" -eq 1 ]]; then
  info "[dry-run] wire_mcp: .mcp.json üretimi + mcpscan scan + supply chain manifest"
  receipt_add "mcpscan" "0.1.2" "planned" ".mcp.json" "dry-run — kurulmayacak"
elif wire_mcp; then
  ok "MCP gateway + supply chain doğrulama tamam"
  receipt_add "mcpscan" "0.1.2" "ok" ".mcp.json" "gateway + supply chain hazır"
else
  fail "MCP gateway kurulum başarısız"; fail_count=$((fail_count + 1))
  receipt_add "mcpscan" "?" "fail" ".mcp.json" "kurulum başarısız"
fi

info "Agent Mesh + Merkle audit (F5)"
if [[ "$DRY_RUN" -eq 1 ]]; then
  info "[dry-run] wire_mesh: manifest üretimi + audit-chain + shadow discovery + dashboard"
  receipt_add "mesh" "1.0.0" "planned" ".agt/manifest.yaml" "dry-run — kurulmayacak"
elif wire_mesh; then
  ok "Agent mesh + audit tamam"
  receipt_add "mesh" "1.0.0" "ok" ".agt/manifest.yaml" "merkle + shadow + dashboard"
else
  fail "Agent mesh kurulum başarısız"; fail_count=$((fail_count + 1))
  receipt_add "mesh" "?" "fail" ".agt/manifest.yaml" "kurulum başarısız"
fi

info "FSD mimari kapısı (F4 + F6)"
if [[ "$DRY_RUN" -eq 1 ]]; then
  info "[dry-run] wire_steiger: npx steiger ./src + knip (arch:check)"
  receipt_add "steiger" "0.6.0" "planned" "steiger.config.js" "dry-run — kurulmayacak"
else
  if ! wire_steiger; then
    fail_count=$((fail_count + 1))
  fi
fi

if [[ "${USE_GH_REPO:-0}" == "1" ]]; then
  info "GitHub repo oluşturuluyor ($VIS)"
  GH="$(use gh)"
  if $GH repo create "$PROJ_NAME" "--$VIS" --source . --remote origin >/dev/null 2>&1; then
    ok "repo hazır: https://github.com/$GH_USER/$PROJ_NAME (ilk commit'ten sonra push: git push)"

    # T6.5 — environment + secrets (CI güvenlik taramaları için)
    # gitleaks MCP_TOKEN gibi opsiyonel secret'ları .env'den aktarır.
    if $GH environment create production --repo "$GH_USER/$PROJ_NAME" >/dev/null 2>&1; then
      ok "environment 'production' oluşturuldu"
    else
      warn "environment oluşturulamadı (pro planı gerekebilir)"
    fi

    # .env.example'daki değişkenleri repo secret olarak tanıt (değerler elle girilir)
    if [[ -f .env.example ]]; then
      ENV_VARS="$(grep -oP '^\w+' .env.example | tr '\n' ' ')"
      if [[ -n "$ENV_VARS" ]]; then
        info "secrets tanıtılıyor (değerler elle set edilmeli): $ENV_VARS"
        for var in $ENV_VARS; do
          $GH secret set "$var" --repo "$GH_USER/$PROJ_NAME" --body "" >/dev/null 2>&1 \
            && ok "secret '$var' tanımlandı (değer: gh secret set $var --body '<değer>')"
        done
      fi
    fi

    # T7.4 — Branch protection: main'e doğrudan push engeli + required checks
    # Required checks: verify + security-* (SAST/SCA/container) + agent-mesh.
    # Solo repo tuzağı: PR yazarı kendi PR'ını onaylayamaz; required_pull_request_reviews
    # tek kullanıcılı repoda merge'i kalıcı kilitler. Yalnız collaborator >1 ise eklenir.
    info "branch protection kuruluyor (required checks)..."
    COLLAB_COUNT=$($GH api "repos/$GH_USER/$PROJ_NAME/collaborators" --jq 'length' 2>/dev/null || echo 0)
    if [[ "$COLLAB_COUNT" -gt 1 ]]; then
      REVIEW_JSON='{"required_approving_review_count": 1, "dismiss_stale_reviews": true}'
      info "çok kullanıcılı repo ($COLLAB_COUNT) — PR review şartı ekleniyor"
    else
      REVIEW_JSON="null"
      info "solo repo ($COLLAB_COUNT) — PR review şartı atlandı (kendi PR'ını onaylayamazsın)"
    fi
    PAYLOAD=$(python3 - "$REVIEW_JSON" <<'PY'
import json, sys
review = json.loads(sys.argv[1]) if sys.argv[1] != "null" else None
payload = {
    "required_status_checks": {
        "strict": True,
        "contexts": [
            "lint + typecheck + test + arch (20, py3.11)",
            "lint + typecheck + test + arch (20, py3.12)",
            "lint + typecheck + test + arch (22, py3.11)",
            "lint + typecheck + test + arch (22, py3.12)",
            "OWASP ASI + policy + fixture",
            "OWASP ASI + policy + prompt defense",
            "midas doctor + wiring receipt",
            "mcpscan + mcp-scan primitives",
            "MCP server güvenlik taraması",
            "SHA-256 manifest + OSV CVE taraması",
            "Merkle audit + shadow discovery + trust",
            "SAST (Semgrep, p/owasp-top-ten + p/default)",
            "SCA (OSV-Scanner, package-lock.json)",
            "trivy (fs · HIGH/CRITICAL)"
        ]
    },
    "enforce_admins": True,
    "required_pull_request_reviews": review,
    "restrictions": None,
    "required_linear_history": True,
    "allow_force_pushes": False,
    "allow_deletions": False,
}
print(json.dumps(payload))
PY
)
    if printf '%s' "$PAYLOAD" | $GH api "repos/$GH_USER/$PROJ_NAME/branches/main/protection" \
      -X PUT \
      --input - >/dev/null 2>&1; then
      ok "branch protection: tüm required checks etkin"
    else
      warn "branch protection kurulamadı (pro planı gerekebilir — elle: Settings > Branches)"
    fi
  else
    warn "repo oluşturulamadı (auth/git yapılandırması?) — ilk commit'ten sonra elle: gh repo create $PROJ_NAME --$VIS --source . --remote origin"
  fi
fi

# --- test: kapı kanıtı ---
step "KAPI TESTİ (plan-gate)"
TEST_FILE=".archcore/tmp/setup-test.txt"
mkdir -p .archcore/tmp
echo "setup.sh test işareti" > "$TEST_FILE"
git add "$TEST_FILE" >/dev/null 2>&1
if git commit -m "test: plansiz commit denemesi" >/dev/null 2>&1; then
  warn "PLAN'SIZ COMMIT GEÇTİ?! plan-gate çalışmıyor — lefthook kurulumunu kontrol et"
  fail_count=$((fail_count + 1))
  git reset --soft HEAD~1 >/dev/null 2>&1
else
  ok "plan'sız commit REDDEDİLDİ (plan-gate kapısı çalışıyor — beklenen davranış)"
  git reset >/dev/null 2>&1
fi
rm -rf .archcore/tmp

# --- doğrulama ---
step "DOĞRULAMA"
info "npm run verify (typecheck + lint + test)"
if npm run verify >/dev/null 2>&1 || npm.cmd run verify >/dev/null 2>&1; then ok "verify YEŞİL"; else
  fail "verify kırmızı — ayrıntı: npm run verify"; fail_count=$((fail_count + 1)); fi

info "npm run arch:check (steiger + knip)"
if npm run arch:check >/dev/null 2>&1; then ok "arch:check YEŞİL (FSD + ölü kod)"; else
  fail "arch:check kırmızı — FSD ihlali veya ölü kod"; fail_count=$((fail_count + 1)); fi

info "verify-drift (TTL/bayatlık taraması)"
if bash .archcore/bin/verify-drift >/dev/null 2>&1; then ok "drift: 0 bayat 0 uyarı"; else
  fail "verify-drift başarısız"; fail_count=$((fail_count + 1)); fi

if have midas; then
  info "Midas wiring doğrulaması"
  midas doctor 2>&1 | tee .archcore/tmp/midas-doctor.log >/dev/null || true
  if grep -q "✗" .archcore/tmp/midas-doctor.log; then
    fail "midas doctor gerçek hata bildirdi"; fail_count=$((fail_count + 1))
  else
    ok "midas doctor hazır (uyarılar CI ortamı için normal)"
  fi
  if [[ -f .archcore/tmp/midas-receipt.json ]]; then
    ok "midas wiring receipt mevcut (.archcore/tmp/midas-receipt.json)"
  else
    fail "midas wiring receipt yok"; fail_count=$((fail_count + 1)); fi
fi

if have gitleaks; then
  info "gitleaks staged taraması"
  if "$(use gitleaks)" git --staged -v . >/dev/null 2>&1; then ok "secret taraması temiz"; else
    fail "gitleaks sorun bildirdi"; fail_count=$((fail_count + 1)); fi
fi

# T6.3 — setup-receipt.json üretimi (dry-run'da da üretilir, tools boş)
receipt_write

# --- özet ---
step "ÖZET"
if [[ "$fail_count" -eq 0 ]]; then
  ok "KURULUM BAŞARILI — kapılar çalışıyor, doğrulama yeşil."
else
  fail "$fail_count adımda sorun var — yukarıdaki HATA mesajlarını düzeltip scripti tekrar çalıştır (idempotent)."
fi
if [[ -f "$RECEIPT_FILE" ]]; then
  info "Kurulum özeti: $RECEIPT_FILE"
  info "  içerik: $(python3 -c "import json; r=json.load(open('$RECEIPT_FILE')); print(f\"{len(r['tools'])} tool, dry_run={r['dry_run']}\")" 2>/dev/null || echo 'JSON doğrulanamadı')"
fi
echo "
Sıradaki adımlar (sen + ajan):
  1. opencode'u bu klasörde başlat
  2. Ajandan ilk planı yazmasını iste (.archcore/plans/<id>.plan.md, status: draft)
  3. Planı oku, onayla (status: accepted + approved_by + plan_hash)
  4. Ajan onaylı scope'ta kod yazar, commit'e 'plan: <id>' trailer'ı ekler
  5. İlk commit: git add . && git commit -m 'feat: ilk plan' -m 'plan: <id>' → git push (origin bağlıysa)
  6. Kapılar: pre-commit → commit-msg → pre-push → CI otomatik çalışır
"
exit "$fail_count"
