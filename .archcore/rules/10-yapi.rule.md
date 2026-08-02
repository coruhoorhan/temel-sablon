---
description: YapÄ± kurallarÄ± â€” FSD klasÃ¶r ÅŸemasÄ±, dosya adlandÄ±rma, bileÅŸen dÃ¼zeni
globs: src/**
priority: P1
last_review_date: 2026-08-02
ttl_days: 90
---

# 10. YapÄ±

**Kaynak:** FSD guide (feature-sliced.design) Â· Airbnb JS Â· Prettier/Biome Â· verifier
**Zorlama:** makine kurallarÄ± + verifier (FSD niyeti, adlandÄ±rma tutarlÄ±lÄ±ÄŸÄ±)

## ALWAYS

### R10-01 Â· FSD klasÃ¶r ÅŸemasÄ±
**Ne:** `app/ pages/ widgets/ features/ entities/ shared/` â€” her slice: `ui/ model/ lib/ api/ config/`.
**Neden:** dosya konumu = sorumluluk; ajan 150 satÄ±rlÄ±k dosyayÄ± doÄŸru baÄŸlamda bulur.
**Zorlayan:** Steiger (FAZ 1) + verifier (V10-1)

### R10-02 Â· jsx-pascal-case (bileÅŸen adlarÄ±)
**Ne:** JSX bileÅŸenleri PascalCase. **Zorlayan:** `react/jsx-pascal-case` (error)

### R10-03 Â· jsx-filename-extension
**Ne:** JSX yalnÄ±zca `.tsx`. **Zorlayan:** `react/jsx-filename-extension` (error)

### R10-04 Â· sort-comp + func-style
**Ne:** bileÅŸen Ã¼ye sÄ±rasÄ± sabit; fonksiyon bildirimi tutarlÄ± (const arrow). **Zorlayan:** `react/sort-comp` + `func-style` (error)

### R10-05 Â· Dosya adlandÄ±rma deseni
**Ne:** kebab-case dosyalar; test `*.test.ts(x)`, story `*.stories.tsx`, tipler `*.types.ts`.
**Neden:** glob kuralÄ± (R9-01 muaf listesi) adlandÄ±rmaya baÄŸlÄ± â€” tutarsÄ±zlÄ±k boyut denetimini deler.
**Zorlayan:** glob doÄŸrulamasÄ± (K1: `git diff --name-only` + pattern check) + verifier

## ASK FIRST
- R10-A1: yeni slice tanÄ±mÄ± â†’ FSD niyeti toplantÄ±sÄ± (segment ÅŸemasÄ± + public API)
- R10-A2: shared/ bÃ¼yÃ¼mesi â†’ kategori mi yoksa entity mi? (shared ÅŸiÅŸerse taÅŸÄ±)
- R10-A3: index.ts public API geniÅŸlemesi â†’ gerÃ§ekten dÄ±ÅŸa aÃ§Ä±k olmalÄ± mÄ±? (kapsÃ¼lleme)

## NEVER
- âŒ klasÃ¶r yapÄ±sÄ±nda istisna (katman atlama, ortak dosyalar)
- âŒ bir dosyada birden Ã§ok sorumluluk (component + hook + api) â€” 150 satÄ±r zaten zorlar
- âŒ `index.ts` dÄ±ÅŸÄ±na import (R2-02 ile aynÄ±)
- âŒ Turkish/karÄ±ÅŸÄ±k dil dosya adlarÄ± (ascii kebab-case)

## Verifier maddeleri
- V10-1: yeni dosyanÄ±n segmenti sorumluluÄŸuna uygun mu? (FSD niyeti)
- V10-2: adlandÄ±rma glob kurallarÄ±na uyuyor mu? (boyut muaf listesiyle tutarlÄ± mÄ±?)
- V10-3: public API'ye sÄ±zan iÃ§ detay var mÄ±? (kapsÃ¼lleme deliÄŸi)
