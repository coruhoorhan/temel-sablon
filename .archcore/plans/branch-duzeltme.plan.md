---
id: branch-duzeltme
status: accepted
created: 2026-08-02
approved_by: Kullanici
last_approved: 2026-08-02T10:55:54Z
last_review_date: 2026-08-02T10:55:54Z
ttl_days: 90
plan_hash: 47a3dacef8d8dedbe51440b18025af129b5b1f527107f9e2de5ffb458ffadc16
scope:
  allowed_paths:
    - README.md
    - lefthook.yml
    - .github/workflows/ci.yml
  allowed_commands:
    - git branch -M main
    - git push
    - npm run verify

---

# branch-duzeltme — Default branch'i main yap (CI tetikleme düzeltmesi)

## Bağlam
Alt ajan doğrulaması sorun buldu: 4 workflow (`ci.yml`, `security-sast.yml`,
`security-sca.yml`, `security-container.yml`) ve lefthook `llm-verify`'ın
`skip: ref: main` koşulu `main` dalını bekliyor; şablonun kendisi ve yerel
`git init` kullanımı `master` üretiyor → CI/güvenlik taramaları HİÇBİR
commit'te tetiklenmez, llm-verify pre-commit'te asla main'de çalışmaz.

## Çözüm tasarımı
1. Repo default branch: master → main (template kullanımıyla uyumlu — GitHub
   template'ten üretilen projeler main doğar)
   - `git branch -M main` + push + `gh api` ile default_branch=main
2. README "Kurulum" bölümüne adım ekle: yerel kopyada
   `git init && git branch -M main` — böylece `cp -r` kullanıcısı da main ile
   başlar, workflow'lar tetiklenir
3. `lefthook.yml` `skip: ref: main` koşulu zaten main diyor — değişiklik gerekmez
4. Yeni commit: `fix: main default branch (CI tetikleme duzeltmesi)` +
   `plan: branch-duzeltme` trailer

## Etkilenen dosyalar
- [ ] README.md (kurulum adımı: `git init && git branch -M main`)
- [ ] lefthook.yml (kontrol — skip ref zaten main, değişiklik gerekmezse dokunma)

## Test planı
- `git ls-remote --symref origin HEAD` → main
- gh api default_branch → main
- npm run verify yeşil (değişiklik README/lefthook ise kod etkilenmez)

## Geri alma planı
git branch -M master ile geri dön + default_branch PATCH.

## Riskler
- Workflow'lar main'de ilk push'ta tetiklenir — şablon repo'su private,
  işçi dakikaları test için sorun değil
- README'de `cp -r` akışı değişir — doküman tutarlılığı kontrol edilir
