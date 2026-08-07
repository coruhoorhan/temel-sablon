# TEMEL Mimarisi (v2.0.0)

> Bu doküman şablonun sistem mimarisini açıklar: katmanlar, kapılar ve veri akışı.
> `setup.sh` bu dosyayı yeni projeye `.archcore/TEMEL-MIMARI.md` olarak kopyalar.

## 1. Genel Bakış

TEMEL, ajan-bağımsız bir **governance katmanı**dır: ajan ne kadar yetenekli olursa olsun,
plan onayı olmadan kod yazamaz, kapsam dışı dosyaya dokunamaz, hafızayı denetimsiz
değiştiremez. Felsefe: **insan onayı merkezde, makine zorlaması her katmanda.**

```
┌─────────────────────────────────────────────────────────┐
│ KATMAN 1  Bilgi      .archcore/rules/ (11 kategori)      │
│ KATMAN 2  Zorlama    commit-msg → pre-push → CI → ruleset│
│ KATMAN 3  Ajan       SORU → PLAN → ONAY → KOD akışı      │
│ KATMAN 4  Hafıza     Midas (TTL/supersession/dedup)      │
│ KATMAN 5  Güvenlik   AGT + MCP gateway + supply chain    │
└─────────────────────────────────────────────────────────┘
```

## 2. Katman Detayları

### Katman 1 — Bilgi (rules)

- `.archcore/rules/01-tipler.rule.md` … `11-hafiza.rule.md` — 11 kural kategorisi.
- Her kural ya makine kapısına (ESLint kural ID / tsc flag / vitest eşiği) ya da
  verifier kontrol listesine bağlanır.
- Boyut sınırı: üretim dosyası ≤150 etkin satır (ESLint `max-lines`).

### Katman 2 — Zorlama (kapılar)

| Kapı | Script | Ne zorlar |
|---|---|---|
| commit-msg | `.archcore/bin/verify-commit-msg` | `plan: <id>` + accepted + hash |
| pre-push | `.archcore/bin/verify-push` | itilen commit'ler plan referanslı + kapsam |
| drift/TTL | `.archcore/bin/verify-drift` | 30g drift / 90g yaş, çift yönlü supersession |
| CI | `.github/workflows/verify.yml` | lint + tsc + test + arch + plan-gate + AGT + Midas |
| Ruleset | GitHub branch protection | force-push/silme blok, required checks |

### Katman 3 — Ajan akışı

1. **SORU:** belirsizliği 4-10 soruyla netleştir.
2. **PLAN:** `.archcore/plans/<id>.plan.md` → `status: draft`.
3. **ONAY:** insan onaylar → `status: accepted` + `approved_by` + `plan_hash`.
4. **KOD:** onaylı scope'ta yaz, commit'e `plan: <id>` trailer'ı ekle.

Plansız kod yazmak YASAK (NEVER listesi). Onaylı plan değişirse `plan_hash` kırılır →
yeniden onay şart.

### Katman 4 — Hafıza (Midas)

- `.midas/config.yaml` (NLI=1, SUPERSEDE=1 zorunlu) + `midas-policy.md` (capture kuralı).
- Makine zorlaması TTL/supersession/dedup Midas'ta; CI `.github/workflows/midas.yml`
  salt-okunur auditor olarak çalışır.
- Dış içerik hafızaya doğrudan yazılamaz — candidates/ + source + insan onayı.

### Katman 5 — Güvenlik (AGT + MCP + supply chain)

- **AGT (OWASP ASI 2026):** `.agt/policy.yaml` tool kuralları, manifest trust mesh,
  `agt verify` 10/10 CI kapısı, prompt defense `--min-grade C` blocking.
- **MCP gateway:** `.agt/mcp-gateway.yaml` — tool interception, response scan,
  message signing, session auth, rate limit, CVE feed, trust gating.
- **Supply chain:** lockfile SHA-256 manifest + OSV.dev CVE sorgusu.

## 3. Agent Mesh

- `.agt/manifest.yaml` — DID kimlikleri, trust_score, delegation, trust decay.
- `.archcore/bin/audit-chain.py` — karar kayıtlarını SHA-256 zincirler (tamper-evident).
- `.archcore/bin/shadow-discovery.py` — manifest'te olmayan ajan tespiti (strict = red).
- `.archcore/bin/gov-dashboard.py` → `docs/governance-dashboard.html`.

## 4. CI/CD (F7)

- `.github/workflows/verify.yml` — tek birleşik pipeline (typecheck + lint + test + arch
  + plan-gate + AGT + Midas + mcpscan), code-quality job'da Node 20/22 × Python 3.11/3.12
  matrix.
- Security-* workflow'ları ayrı: SAST (Semgrep), SCA (OSV-Scanner), container (Trivy).
- Branch protection: main'e required checks (verify + security-* + agent-mesh).

## 5. Diyagramlar

- `docs/architecture.drawio` — genel mimari (katmanlar + kapılar).
- `docs/sequence.drawio` — plan onay akışı (SORU→PLAN→ONAY→KOD).
- `docs/dataflow.drawio` — hafıza/governance veri akışı.
- `docs/governance-dashboard.html` — F5 dashboard çıktısı (üretilir).

## 6. Kurulum Notu

`setup.sh` interaktiftir: proje adını sorar, şablonu çeker, `git init` (main) + kapıları
kurar, plansız commit'i REDDETME testini yapar, doğrular ve özet basar. Bu mimari
dokümanı her yeni projeye `.archcore/` içinde kopyalanır — "projenin dışında" değildir.
