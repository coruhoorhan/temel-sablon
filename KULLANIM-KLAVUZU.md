# TEMEL — Kullanım Kılavuzu

TEMEL, ajan-hazır bir proje şablonudur: plan onay kapısı, kural kataloğu, hafıza (Midas),
governance (AGT/OWASP ASI), MCP güvenliği, FSD mimari zorlaması ve birleşik CI.

Bu kılavuz, şablonu **gerçek bir projede test etmen** için adım adım rehberdir.
Tüm komutlar 2026-08-10'da boş bir klasörde `setup.sh` ile yapılan gerçek kurulumda
doğrulanmıştır.

---

## 1. Kurulum (yeni proje)

Boş bir klasöre `setup.sh` indir ve çalıştır — gerisini script yapar:

```bash
mkdir yeni-projem && cd yeni-projem
curl -O https://raw.githubusercontent.com/coruhoorhan/temel-sablon/main/setup.sh
bash setup.sh
```

Script soracaklarını sorar (proje adı, GitHub repo oluşturma — y/N). Kurulum şunları yapar:

| Adım | Ne kurar |
|---|---|
| Şablon çekme | GitHub'dan `temel-sablon` klonlar (internet yoksa yerel fallback) |
| git init | `main` dalı (CI workflow'ları main dinler) |
| npm install + hooks | lefthook kapıları (pre-commit, commit-msg, pre-push) |
| F1 Midas | hafıza config + wiring receipt |
| F2 AGT | OWASP ASI 10/10 + policy + fixture replay |
| F3 MCP | gateway config + mcpscan taraması + supply chain manifest |
| F5 Mesh | Merkle audit zinciri + shadow discovery + dashboard |
| F4/F6 Steiger | FSD mimari kapısı (no-upward-import) |
| Kapı testi | plansız commit'in **REDDEDİLDİĞİNİ** kanıtlar |
| Doğrulama | `npm run verify` + `arch:check` + drift + gitleaks |

**Beklenen çıktı:** `KURULUM BAŞARILI — kapılar çalışıyor, doğrulama yeşil.`
(`setup-receipt.json` — 5 tool, dry_run=0)

---

## 2. Çalışma döngüsü (ajan + insan)

Şablonun kalbi **plan onay kapısı**dır: plansız kod yazmak commit aşamasında reddedilir.

```
1. SORU  → ajan belirsizliği sorularla netleştirir
2. PLAN  → ajan .archcore/plans/<id>.plan.md yazar (status: draft)
3. ONAY  → sen onaylarsın (status: accepted + approved_by + plan_hash)
4. KOD   → ajan onaylı scope'ta yazar, commit'e 'plan: <id>' ekler
5. KAPILAR → pre-commit → commit-msg → pre-push → CI otomatik çalışır
```

### Plan onayı (insan)

```bash
# plan dosyası: .archcore/plans/<id>.plan.md
echo "y" | bash .archcore/bin/approve-plan <id> "adın-soyadın"
```

### Onaylı commit

```bash
git add -A
git commit -m "feat(x): açıklama

plan: <id>"
```

> `plan: <id>` trailer'ı **zorunlu** — yoksa commit-msg kapısı reddeder.

---

## 3. Kapıları test et (elle)

### 3.1 Plansız commit reddi

```bash
echo "test" > deneme.txt
git add deneme.txt
git commit -m "test: plansiz"   # ❌ REDDEDİLİR (plan: <id> yok)
git reset
```

### 3.2 Commit mesajı denetimi

```bash
echo "feat(x): y

plan: my-plan" | .archcore/bin/verify-commit-msg -
```

### 3.3 Push öncesi denetim

```bash
.archcore/bin/verify-push origin
```

### 3.4 Toplu plan-gate (CI simülasyonu)

```bash
.archcore/bin/verify-pr origin/main HEAD   # tüm commit'ler onaylı planlı mı?
```

Beklenen: `[plan-gate] CI: tüm commit'ler onaylı planlarla uyumlu.`

---

## 4. Katmanları test et (F1-F8)

### F1 — Midas hafıza

```bash
midas doctor
midas status --json          # wiring receipt: .archcore/tmp/midas-receipt.json
echo "hatırla" | midas remember "test notu" --kind note
midas recall "test"
```

### F2 — AGT governance

```bash
agt verify                   # OWASP ASI 2026 → 10/10
agt lint-policy .agt/policy.yaml --strict
agt test .agt/policy.yaml .agt/fixtures/
agt red-team scan --min-grade C   # prompt defense
```

### F3 — MCP güvenliği

```bash
npx -y @nileshbera/mcpscan scan --fail-on high
agt mcp-scan .mcp.json --static-only
cat .archcore/supply-chain-manifest.txt   # lockfile SHA-256
```

### F4 — FSD mimari zorlaması

```bash
npm run arch:check            # steiger + knip
# ihlal testi: features/ içinden app/ import et → yakalanmalı
```

### F5 — Agent Mesh

```bash
python3 .archcore/bin/audit-chain.py --verify       # Merkle zinciri
python3 .archcore/bin/shadow-discovery.py            # kayıtsız ajan yok
python3 .archcore/bin/gov-dashboard.py               # docs/governance-dashboard.html
```

### F6 — Setup v2

```bash
bash setup.sh --help
bash setup.sh --dry-run       # planlı mod — hiçbir şey kurmaz
cat setup-receipt.json        # 5 tool durumu
```

### F7 — Birleşik CI

`.github/workflows/verify.yml` — 4 job:
- **code-quality:** Node 20/22 × Python 3.11/3.12 matrix (typecheck + lint + test + arch)
- **governance:** AGT verify + lint-policy + fixture
- **memory:** midas auditor
- **mcp-security:** mcpscan + AGT mcp-scan

GitHub'da push sonrası otomatik çalışır. Lokal simülasyon:

```bash
npm run verify
npm run arch:check
```

### F8 — Dokümantasyon

```bash
cat .archcore/TEMEL-MIMARI.md     # mimari doküman (yeni projeye kopyalanır)
ls docs/*.drawio                  # draw.io ile açılabilir 3 diyagram
cat CHANGELOG.md                  # v2.0.0 + migration guide
```

---

## 5. GitHub'a ilk push (repo oluşturma dahil)

Setup sırasında "GitHub'da repo oluşturulsun mu? (y/N)" sorusuna `y` dersen:
repo oluşturulur, `production` environment tanımlanır, `.env.example`'daki secret'lar
tanıtılır ve branch protection (required checks) kurulur.

Elle (setup sırasında N dediysen):

```bash
gh repo create <proje-adı> --public --source . --remote origin
git add -A && git commit -m "feat: ilk plan" -m "plan: <id>"
git push -u origin main
```

---

## 6. Sık Sorulan Sorular

**Q: Plansız commit neden reddediliyor?**
A: commit-msg kapısı (`verify-commit-msg`) `plan: <id>` trailer'ı arar. Onaylı plan
olmadan kod projeye giremez — bu şablonun temel garantisidir.

**Q: `verify-pr` neden "CI RED" diyor?**
A: Commit'in değiştirdiği bir dosya planın `allowed_paths` listesinde yok. Plan
dosyasına dosyayı ekle ve planı yeniden onayla (hash kırılır → onay şart).

**Q: Onaylı planı değiştirdim, ne olur?**
A: `plan_hash` kırılır — kapılar reddeder. `approve-plan` ile yeniden onay alman gerekir.

**Q: Kurulum hangi sistem araçlarını ister?**
A: Node 24 LTS, Python 3.11+, `gitleaks` (npm DEĞİL — sahte paket var), `gh` (opsiyonel).
Eksikleri script kendisi uyarır.

**Q: Bu şablon hangi ajanlarla çalışır?**
A: Ajan-bağımsız: AGENTS.md (opencode/Codex/Cursor) + CLAUDE.md (Claude Code) köprüleri
aynı kapıları zorlar. `approved_by` her zaman insandır — ajan kendini onaylayamaz.

---

## 7. CI güvenlik kapıları

CI taramaları fail-closed çalışır: HIGH/CRITICAL SCA veya Trivy bulgusu,
geçersiz AGT policy/fixture, prompt-defense notunun C altına düşmesi veya gerçek
MCP config taramasının başarısız olması workflow'u kırmızı yapar.

`security-sca.yml`, `security-container.yml`, `mcpscan.yml` ve `verify.yml`
template'ten gerçek config'leri ürettikten sonra bu config'leri tarar.

Branch protection `setup.sh` tarafından şöyle kurulur: required status checks
(zorunlu), enforce admins, linear history ve force-push/deletion yasağı her zaman
açılır; **PR review şartı yalnız collaborator sayısı 1'den büyükse** eklenir —
solo repoda yazar kendi PR'ını onaylayamayacağı için bu şart merge'i kalıcı
kilitler. Collaborator eklersen review şartı otomatik devreye girer.

## 8. Yapı (hızlı referans)

```
├── AGENTS.md / CLAUDE.md      ajan köprüleri
├── setup.sh                   kurulum (v2: --dry-run/--help, receipt)
├── .archcore/
│   ├── TEMEL-MIMARI.md        mimari doküman
│   ├── plans/                 onay state'i (<id>.plan.md)
│   ├── rules/                 11 kural dosyası
│   ├── bin/                   kapı scriptleri (verify-commit-msg/push/pr, drift)
│   └── supply-chain-manifest.txt
├── .github/workflows/         verify.yml + agt/midas/mcpscan/supply-chain/agent-mesh/security-*
├── .midas/ .agt/ .mcp.json    kurulumda template'lerden üretilir (gitignore)
├── docs/                      drawio diyagramlar + governance dashboard
└── tools/architecture/        Steiger custom FSD plugin
```
