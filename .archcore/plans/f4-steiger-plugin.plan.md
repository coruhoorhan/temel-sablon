---
description: F4 (Steiger Custom FSD Plugin) — katman sızıntısı zorlaması
status: accepted
approved_by: coruhoorhan (insan)
plan_hash: 6b95bc5a39c7084e0595a680596e56efe0bd771346dd2ced6a37a3eee0a3ffda
last_approved: 2026-08-10T05:44:06Z
last_review_date: 2026-08-10T05:44:06Z
ttl_days: 90
allowed_paths:
  - .archcore/plans/f4-steiger-plugin.plan.md
  - AGENTS.md
  - steiger.config.js
  - tools/architecture/scripts/check-arch.sh
  - tools/architecture/src/steiger-rules/index.ts
  - tools/tsconfig.json
---

# Plan: f4-steiger-plugin

## Amaç

TEMEL şablonuna custom Steiger plugin ekler — FSD katman sızıntısını (yukarı import) makine kapısıyla zorlar.

## Kapsam (değiştirilecek dosyalar)

- `tools/architecture/src/steiger-rules/index.ts` — custom plugin (`no-upward-import` kuralı)
- `tools/architecture/scripts/check-arch.sh` — mimari kapı scripti
- `tools/tsconfig.json` — plugin tip güvenliği
- `steiger.config.js` — custom plugin import + kural ayarı
- `AGENTS.md` — Mimari (F4) bölümü

## Kapsam DIŞI

- Push/publish
- F5-F8 fazları
- Ek FSD kuralları (yalnız no-upward-import bu fazda)

## Doğrulama (gerçekleştirildi)

1. TS tip kontrolü: `tsc --noEmit -p tools/tsconfig.json` → 0 hata ✓
2. Fonksiyonel test: `features → app` ihlali yakalandı ✓
3. steiger tam check: temiz repo "No problems found" ✓
4. İhlal dosyası eklenince steiger REDDETTİ (exit 1) ✓
5. npm run verify regresyon ✓
6. npm run arch:check (steiger + knip) ✓

## Kabul kriterleri

- [x] Custom plugin tip güvenli (tsc temiz)
- [x] Yukarı import ihlali yakalanıyor (test edildi)
- [x] steiger.config.js plugin'i yüklüyor
- [x] CI + pre-commit arch:check ile zorlanıyor
