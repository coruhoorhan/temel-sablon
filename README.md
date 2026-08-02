# TEMEL — Ajan-Hazır Proje Şablonu

Her projede kopyala-başlat: kural kataloğu (11 kategori), plan onay kapısı
(ajan-bağımsız, git-merkezli), commit öncesi doğrulama altyapısı.

> Mimari doküman: `TEMEL-MIMARI.md` (projenin dışında, şablonun özelliği değil).

## Yapı

```
temel/
├── AGENTS.md                  köprü: kurallar nerede, kapılar nerede, NEVER listesi
├── lefthook.yml               kapı zinciri: K1 pre-commit + K2 pre-push + commit-msg
├── commitlint.config.mjs      conventional commit (yalnız sözdizimi)
├── .github/workflows/ci.yml   CI (K3): lint/typecheck/test/plan-gate/security
├── .gitignore
└── .archcore/
    ├── plans/                 onay state'i — <id>.plan.md (status/hash/scope)
    ├── templates/
    │   └── plan.plan.md.tmpl  plan şablonu
    ├── rules/                 11 kural dosyası (01-tipler … 11-hafiza)
    └── bin/                   kapı scriptleri (hook + CI + sunucu aynı kod)
        ├── verify-commit-msg
        ├── verify-push
        └── verify-pr
└── .agents/skills/plan-gate/  20+ ajanla çalışan plan akışı (SKILL.md)
└── .opencode/agents/verifier.md  LLM denetçi ajan tanımı
```

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
