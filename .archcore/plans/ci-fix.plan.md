---
description: CI kırmızı fix — template üretimi + Node 20 steiger uyumluluğu (verify/agent-mesh/midas)
status: accepted
approved_by: coruhoorhan (insan)
plan_hash: 6fe883e7fd9176cbb18afc2ec84bf4ee1eca8d4d56844654ab39ae98dfd90b2e
last_approved: 2026-08-10T07:26:43Z
last_review_date: 2026-08-10T07:26:43Z
ttl_days: 90
allowed_paths:
  - .github/workflows/verify.yml
  - .github/workflows/agent-mesh.yml
  - steiger.config.js
  - .github/workflows/midas.yml
  - .archcore/plans/ci-fix.plan.md
  - setup.sh
---

# Plan: ci-fix

## Amaç

GitHub Actions'da kırmızı 3 workflow'u yeşile çevir. Kök nedenler:

1. **Template üretimi yok:** `.agt/fixtures/`, `.agt/manifest.yaml`, `.midas/config.yaml`
   gitignore'lı ve repo'da yok — yalnız `.template`'ler commit'li. CI'da `setup.sh`
   çalışmadığı için dosyalar üretilmiyor → AGT fixture bulamıyor, midas doctor fail,
   agent-mesh manifest bulamıyor.
2. **Steiger `.ts` import:** `steiger.config.js` doğrudan `.ts` import ediyor —
   Node 20 ESM `.ts` uzantısını tanımıyor (`ERR_UNKNOWN_FILE_EXTENSION`).

## Kapsam (değiştirilecek dosyalar)

- `.github/workflows/verify.yml` — governance job'a fixture üretimi, memory job'a config üretimi
- `.github/workflows/agent-mesh.yml` — manifest üretimi adımı
- `.github/workflows/midas.yml` — config üretimi (varsa)
- `steiger.config.js` — Node 20 uyumlu (`.ts` import yerine çalışan çözüm)
- `setup.sh` — CI için template üretim fonksiyonu (reuse: `wire_agt`/`wire_midas` mantığı)
- `.archcore/plans/ci-fix.plan.md` — bu plan

## Kapsam DIŞI

- Kod değişikliği (yalnız CI/config)
- Yeni özellik

## Doğrulama

1. Lokal: `npx steiger ./src` Node 20 ile çalışır (veya matrix Node 20 kaldırılır)
2. Lokal: template üretim adımı `setup.sh --ci-prepare` çalışır
3. GitHub Actions: 3 workflow yeşil

## Kabul kriterleri

- [ ] verify / governance: fixture replay geçer
- [ ] verify / memory: midas doctor geçer
- [ ] verify / code-quality (Node 20): arch:check geçer
- [ ] agent-mesh: manifest bulunur, shadow/strict geçer
- [ ] GitHub'da 6 failing → 0
