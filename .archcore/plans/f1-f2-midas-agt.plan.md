---
description: F1 (Midas hafıza) + F2 (AGT governance) entegrasyonu — şablona hafıza ve OWASP ASI katmanları eklenir
status: accepted
approved_by: coruhoorhan (insan)
plan_hash: 019fd12958c5210ee985e21604f02f3ca76326b8fb6a9ced653615fd149cf527
last_approved: 2026-08-10T05:44:06Z
last_review_date: 2026-08-10T05:44:06Z
ttl_days: 90
allowed_paths:
  - .agt/fixtures/policy.test.yaml.template
  - .agt/manifest.yaml.template
  - .agt/policy.yaml.template
  - .archcore/plans/f1-f2-midas-agt.plan.md
  - .github/workflows/agt-verify.yml
  - .github/workflows/midas.yml
  - .gitignore
  - .midas/config.yaml.template
  - AGENTS.md
  - lefthook.yml
  - midas-policy.md
  - setup.sh
---

# Plan: f1-f2-midas-agt

## Amaç

TEMEL şablonuna iki üretim katmanı ekler:
1. **F1 — Midas hafıza sistemi:** TTL + supersession + provenance guard'lı kalıcı hafıza (ajan sözleşmesi + config + CI auditor)
2. **F2 — AGT governance:** OWASP ASI 2026 doğrulaması + deterministik policy (tool kuralları) + agent manifest + prompt defense

## Kapsam (değiştirilecek dosyalar)

- `setup.sh` — `wire_midas()` + `wire_agt()` fonksiyonları, KURULUM + DOĞRULAMA bağlantısı
- `.midas/config.yaml.template` — Midas env haritası (TTL, NLI, supersede, guard)
- `midas-policy.md` — ajan hafıza sözleşmesi (R11-01..14 makine tarafı)
- `.agt/policy.yaml.template` — ACS şema policy (deny: yıkıcı, audit: harici/secret)
- `.agt/fixtures/policy.test.yaml.template` — 6 policy fixture
- `.agt/manifest.yaml.template` — coder/verifier/human kimlik + trust + delegation
- `.github/workflows/midas.yml` — salt-okunur hafıza auditor (R11-12)
- `.github/workflows/agt-verify.yml` — OWASP ASI 10/10 + policy + fixture kapısı
- `lefthook.yml` — pre-push: AGT lint + prompt defense
- `.gitignore` — .midas/ + .agt/ üretilen dosyalar
- `AGENTS.md` — Midas + AGT bölümleri

## Kapsam DIŞI

- Push/publish (local commit yalnız)
- F3-F8 fazları (MCP Gateway, Steiger, Agent Mesh, setup v2, CI birleştirme, dokümantasyon)
- AGENTS.md prompt defense F notunun düzeltilmesi (T8'de)

## Doğrulama

1. `bash -n setup.sh` — syntax
2. `npm run verify` — regresyon (lint + tsc + test)
3. `wire_midas` + `wire_agt` izole çalıştırma — tüm kontroller yeşil
4. `agt verify` 10/10 · `agt lint-policy --strict` temiz · `agt test` 6/6 fixture
5. `midas doctor` + `midas status --json` — wiring receipt
6. lefthook YAML geçerli + hooks sync

## Kabul kriterleri

- [ ] setup.sh Midas + AGT kurar ve doğrular
- [ ] Policy şeması lint'ten geçer, fixture'lar 0 mismatch
- [ ] OWASP ASI 2026 10/10
- [ ] CI workflow'ları YAML geçerli, lokal simülasyonu yeşil
- [ ] Üretilen config/policy dosyaları commit'e girmez (gitignore)
