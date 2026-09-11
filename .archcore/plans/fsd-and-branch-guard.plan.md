---
description: FSD katman kilidi (fsd-layers-only), secret blokaji, main dal korumasi ve specbind check contracts entegrasyonu
status: accepted
title: "fsd-and-branch-guard — Non-FSD Klasor ve Dal Guvenlik Barikatlari"
approved_by: Kullanici
plan_hash: acc81020d80443bed0dd356ae1ffe33dab4318c0864b88d6474f1d9dc0813a44
last_approved: 2026-09-11T12:38:40Z
last_review_date: 2026-09-11T12:38:40Z
ttl_days: 90
allowed_paths:
  - setup.sh
  - steiger.config.js
  - tools/architecture/src/steiger-rules/*
  - .archcore/bin/*
  - .archcore/plans/fsd-and-branch-guard.plan.md
---

# Plan: fsd-and-branch-guard

## Bağlam
Steiger'ın FSD katmanı olmayan klasörleri (ör. `src/components/`, `src/utils/`) sessizce atlamasını engellemek,
secret dosyalarının (`.env`, `.pem`, `.key`) commit edilmesini kesin olarak durdurmak,
`main` dalına doğrudan commit atılmasını önleyip feature branch disiplinini zorunlu kılmak
ve `specbind check contracts` kontrolünü setup doğrulamasına eklemek için mekanik kontroller geliştirildi.

## Çözüm Tasarımı
1. `tools/architecture/src/steiger-rules/index.js` ve `steiger.config.js`:
   - `fsd-layers-only`: `src/` altında yalnızca standart 6 katmana (`shared`, `entities`, `features`, `widgets`, `pages`, `app`) izin verilir. `src/components/` gibi sahte katmanlar derhal engellenir.
2. `verify-commit-msg` ve `verify-post-commit`:
   - `.env*`, `*.pem`, `*.key` gibi secret dosyaları commit edilemez.
   - `main` veya `master` dalına doğrudan commit atılamaz (`ALLOW_MAIN_COMMIT=1` muafiyeti hariç).
3. `setup.sh` ve `smoke-e2e.sh`:
   - `specbind check contracts` sözleşme grafiği doğrulaması eklendi.
   - İlk kurulum için `ALLOW_MAIN_COMMIT=1` tanımlandı.

## Etkilenen Dosyalar
- [x] tools/architecture/src/steiger-rules/index.js
- [x] steiger.config.js
- [x] .archcore/bin/verify-commit-msg
- [x] .archcore/bin/verify-post-commit
- [x] .archcore/bin/smoke-e2e.sh
- [x] setup.sh
- [x] .archcore/plans/fsd-and-branch-guard.plan.md
