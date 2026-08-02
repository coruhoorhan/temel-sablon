#!/usr/bin/env bash
# setup.sh — TEMEL şablonu interaktif kurulum + test + doğrulama
# Sen bilgileri girersin, script kurar, kapıları test eder, doğrular.
# Linux veya Git Bash (Windows) — bash 4+ yeterli.
#
# Kullanım:  bash setup.sh        (şablon kopyalandığı/hedeflendiği klasörde)

set -uo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[UYARI]${NC} $1"; }
fail() { echo -e "${RED}[HATA]${NC} $1"; }
info() { echo -e "${CYAN}[..]${NC} $1"; }

fail_count=0
step() { echo -e "\n${CYAN}===== $1 =====${NC}"; }

# Windows Git Bash: komutlar .exe uzantılı olabilir — hem düz hem .exe dene
have() { command -v "$1" >/dev/null 2>&1 || command -v "$1.exe" >/dev/null 2>&1; }
use()  { if command -v "$1" >/dev/null 2>&1; then echo "$1"; else echo "$1.exe"; fi; }

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

if [[ "${USE_GH_REPO:-0}" == "1" ]]; then
  info "GitHub repo oluşturuluyor ($VIS)"
  GH="$(use gh)"
  if $GH repo create "$PROJ_NAME" "--$VIS" --source . --remote origin --push >/dev/null 2>&1; then
    ok "repo hazır: https://github.com/$GH_USER/$PROJ_NAME"
  else
    warn "repo oluşturulamadı (auth/git yapılandırması?) — ilk commit'ten sonra elle: gh repo create $PROJ_NAME --$VIS --source . --push"
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

info "verify-drift (TTL/bayatlık taraması)"
if bash .archcore/bin/verify-drift >/dev/null 2>&1; then ok "drift: 0 bayat 0 uyarı"; else
  warn "verify-drift uyarı verdi (bilgi amaçlı, --strict değil)"; fi

if have gitleaks; then
  info "gitleaks staged taraması"
  if "$(use gitleaks)" git --staged -v . >/dev/null 2>&1; then ok "secret taraması temiz"; else
    fail "gitleaks sorun bildirdi"; fi
fi

# --- özet ---
step "ÖZET"
if [[ "$fail_count" -eq 0 ]]; then
  ok "KURULUM BAŞARILI — kapılar çalışıyor, doğrulama yeşil."
else
  fail "$fail_count adımda sorun var — yukarıdaki HATA mesajlarını düzeltip scripti tekrar çalıştır (idempotent)."
fi
echo "
Sıradaki adımlar (sen + ajan):
  1. opencode'u bu klasörde başlat
  2. Ajandan ilk planı yazmasını iste (.archcore/plans/<id>.plan.md, status: draft)
  3. Planı oku, onayla (status: accepted + approved_by + plan_hash)
  4. Ajan onaylı scope'ta kod yazar, commit'e 'plan: <id>' trailer'ı ekler
  5. Kapılar: pre-commit → commit-msg → pre-push → CI otomatik çalışır
"
exit "$fail_count"
