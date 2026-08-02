---
description: Yapı kuralları — FSD klasör şeması, dosya adlandırma, bileşen düzeni
globs: src/**
priority: P1
last_review_date: 2026-08-02
ttl_days: 90
---

# 10. Yapı

**Kaynak:** FSD guide (feature-sliced.design) · Airbnb JS · Prettier/Biome · verifier
**Zorlama:** makine kuralları + verifier (FSD niyeti, adlandırma tutarlılığı)

## ALWAYS

### R10-01 · FSD klasör şeması
**Ne:** `app/ pages/ widgets/ features/ entities/ shared/` — her slice: `ui/ model/ lib/ api/ config/`.
**Neden:** dosya konumu = sorumluluk; ajan 150 satırlık dosyayı doğru bağlamda bulur.
**Zorlayan:** Steiger (FAZ 1) + verifier (V10-1)

### R10-02 · jsx-pascal-case (bileşen adları)
**Ne:** JSX bileşenleri PascalCase. **Zorlayan:** `react/jsx-pascal-case` (error)

### R10-03 · jsx-filename-extension
**Ne:** JSX yalnızca `.tsx`. **Zorlayan:** `react/jsx-filename-extension` (error)

### R10-04 · sort-comp + func-style
**Ne:** bileşen üye sırası sabit; fonksiyon bildirimi tutarlı (const arrow). **Zorlayan:** `react/sort-comp` + `func-style` (error)

### R10-05 · Dosya adlandırma deseni
**Ne:** kebab-case dosyalar; test `*.test.ts(x)`, story `*.stories.tsx`, tipler `*.types.ts`.
**Neden:** glob kuralı (R9-01 muaf listesi) adlandırmaya bağlı — tutarsızlık boyut denetimini deler.
**Zorlayan:** glob doğrulaması (K1: `git diff --name-only` + pattern check) + verifier

## ASK FIRST
- R10-A1: yeni slice tanımı → FSD niyeti toplantısı (segment şeması + public API)
- R10-A2: shared/ büyümesi → kategori mi yoksa entity mi? (shared şişerse taşı)
- R10-A3: index.ts public API genişlemesi → gerçekten dışa açık olmalı mı? (kapsülleme)

## NEVER
- ❌ klasör yapısında istisna (katman atlama, ortak dosyalar)
- ❌ bir dosyada birden çok sorumluluk (component + hook + api) — 150 satır zaten zorlar
- ❌ `index.ts` dışına import (R2-02 ile aynı)
- ❌ Turkish/karışık dil dosya adları (ascii kebab-case)

## Verifier maddeleri
- V10-1: yeni dosyanın segmenti sorumluluğuna uygun mu? (FSD niyeti)
- V10-2: adlandırma glob kurallarına uyuyor mu? (boyut muaf listesiyle tutarlı mı?)
- V10-3: public API'ye sızan iç detay var mı? (kapsülleme deliği)
