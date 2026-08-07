# TEMEL — Ajan-Hazır Proje Şablonu

Her projede kopyala-başlat: kural kataloğu (11 kategori), plan onay kapısı
(ajan-bağımsız, git-merkezli), commit öncesi doğrulama altyapısı, hafıza, governance
ve MCP güvenliği.

> Mimari doküman: [`.archcore/TEMEL-MIMARI.md`](.archcore/TEMEL-MIMARI.md) — şablonun
> içinde yaşar, `setup.sh` her yeni projeye kopyalar.

## Özellikler (v2.0.0)

| Faz | Katman | Ne sağlar |
|---|---|---|
| F1 | Hafıza (Midas) | TTL/supersession/dedup, provenance hiyerarşisi, CI auditor |
| F2 | Governance (AGT) | OWASP ASI 2026 10/10, policy fixtures, prompt defense |
| F3 | MCP güvenliği | Gateway (interception/signing/rate-limit/CVE), mcpscan, supply chain |
| F4 | Mimari (Steiger) | Custom FSD plugin — katman sızıntısı zorlaması |
| F5 | Agent Mesh | Merkle audit chain, shadow AI tespiti, governance dashboard |
| F6 | Setup v2 | `--dry-run`/`--help`, setup-receipt.json, GitHub env/secrets |
| F7 | CI/CD birleşik | verify.yml (4 job, Node 20/22 × Python 3.11/3.12 matrix), branch protection |
| F8 | Dokümantasyon | Mimari doküman, CLAUDE.md import'lar, CHANGELOG, drawio diyagramlar |

## Yapı

```
temel/
├── AGENTS.md                  köprü: kurallar nerede, kapılar nerede, NEVER listesi
├── CLAUDE.md                  Claude Code köprüsü (aynı import yapısı)
├── lefthook.yml               kapı zinciri: K1 pre-commit + K2 pre-push + commit-msg
├── commitlint.config.mjs      conventional commit (yalnız sözdizimi)
├── .github/workflows/
│   ├── verify.yml             birleşik CI (F7): typecheck/lint/test/arch/plan-gate/AGT/Midas/mcpscan
│   ├── agt-verify.yml         OWASP ASI + policy + fixture (F2)
│   ├── midas.yml              hafıza auditor (F1)
│   ├── mcpscan.yml            MCP client config tarama (F3)
│   ├── supply-chain.yml       lockfile + OSV (F3)
│   ├── agent-mesh.yml         merkle + shadow + trust (F5)
│   └── security-*.yml         SAST (Semgrep) / SCA (OSV) / container (Trivy)
├── .gitignore
└── .archcore/
    ├── TEMEL-MIMARI.md        mimari doküman (F8)
    ├── plans/                 onay state'i — <id>.plan.md (status/hash/scope)
    ├── templates/
    │   └── plan.plan.md.tmpl  plan şablonu
    ├── rules/                 11 kural dosyası (01-tipler … 11-hafiza)
    └── bin/                   kapı scriptleri (hook + CI + sunucu aynı kod)
        ├── verify-commit-msg
        ├── verify-push
        └── verify-pr
└── docs/                      mimari diyagramlar (F8) + governance dashboard (F5)
```

## Diyagramlar

| Diyagram | Açıklama |
|---|---|
| `docs/architecture.drawio` | Genel mimari — katmanlar + kapılar |
| `docs/sequence.drawio` | Plan onay akışı (SORU→PLAN→ONAY→KOD) |
| `docs/dataflow.drawio` | Hafıza/governance veri akışı |
| `docs/governance-dashboard.html` | F5 çıktısı (gov-dashboard.py üretir) |

## Kurulum (yeni proje)

**Tek komut (önerilen):** boş bir klasöre `setup.sh` at, çalıştır — gerisini script yapar:

```bash
curl -O https://raw.githubusercontent.com/coruhoorhan/temel-sablon/main/setup.sh
bash setup.sh
```

Script interaktiftir: **sadece proje adını** sorar, sonra şablonu GitHub'dan çeker,
`git init` (main) + `npm install` + kapıları kurar, plansız commit'i REDDETME testini
yapar, `verify` + drift + gitleaks ile doğrular ve özet basar. (gh girişi varsa
GitHub'da repo oluşturmayı da sorar: y/N → public/private.)

Elle kurulum (script'siz — sadece gerektiğinde):

1. Şablonu kopyala: `cp -r temel/. <yeni-proje>/`
2. Git'i başlat (**main** dalı — CI workflow'ları main dinler):
   `git init && git branch -M main`
3. Bağımlılıkları kur: `npm install && npm run hooks:install`
4. **Sistem araçları (npm DEĞİL):** `gitleaks` — `apt install gitleaks` / `brew install gitleaks` / `go install github.com/gitleaks/gitleaks/v8@latest` (npm'de "gitleaks" adlı paket SAHTEDİR, kurma)
5. Plan onay akışını oku: `.archcore/plans/README.md` (yaşam döngüsü, bkz. aşağısı)
6. FAZ 1-6'ya göre makine yığınını kur (doküman Bölüm 5)

## Çalışma döngüsü (ajan + insan)

1. Ajan sorular sorar → cevaplar plana kaynak olur
2. Ajan `.archcore/plans/<id>.plan.md` oluşturur (`status: draft`)
3. İnsan onaylar: `status: accepted` + `approved_by` + `plan_hash` (plan-gate skill'i yapar)
4. Ajan onaylı scope'ta kod yazar, commit'e `plan: <id>` ekler
5. Kapılar: commit-msg → pre-push → CI → ruleset (Katman 2-5)

## Kapı scriptleri (manuel test)

```bash
# bir commit mesajını denetle
echo "feat(x): y\n\nplan: my-plan" | .archcore/bin/verify-commit-msg -
# push denetimi (hook içinden çağrılır)
.archcore/bin/verify-push origin
# CI denetimi (PR range)
.archcore/bin/verify-pr origin/main HEAD
```

## Önemli kurallar

- Üretim dosyası ≤150 etkin satır (ESLint max-lines FAZ 1'de zorlanır)
- Onaylı plan değiştiyse `plan_hash` kırılır → **yeniden onay şart**
- `.env` asla commit'e girmez (gitleaks + ruleset)
- MCP dosya-düzenleme araçları yasak (opencode #30291 bypass) — bkz. AGENTS.md NEVER
- `setup.sh` tüm şablonu (`.archcore` dahil) `tar` ile kopyalar — mimari doküman
  yeni projede otomatik yaşar
