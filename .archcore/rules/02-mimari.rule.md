---
description: FSD mimari kurallarÄ± â€” katman hiyerarÅŸisi, import sÄ±nÄ±rlarÄ±, public API
globs: src/**
priority: P0
last_review_date: 2026-08-02
ttl_days: 90
---

# 2. Mimari (FSD)

**Kaynak:** feature-sliced.design Â· Steiger 0.6 (resmi FSD linter)
**Zorlama:** Steiger (forbidden-imports / no-cross-imports / public-api) + import/no-cycle + verifier

## ALWAYS

### R2-01 Â· Katman hiyerarÅŸisi (sadece yukarÄ±dan aÅŸaÄŸÄ±ya import)
**Ne:** app â†’ pages â†’ widgets â†’ features â†’ entities â†’ shared. AÅŸaÄŸÄ± katman yukarÄ± import EDEMEZ.
**Neden:** katman sÄ±zÄ±ntÄ±sÄ± = mimari Ã§Ã¼rÃ¼me; FSD'nin tÃ¼m vaadi bu sÄ±nÄ±rda.
âŒ `entities/` iÃ§inden `features/x` import etmek
âœ… yukarÄ± katman, aÅŸaÄŸÄ± katmanÄ± tÃ¼ketir; veri akÄ±ÅŸÄ± event/handler Ã¼zerinden
**Zorlayan:** Steiger `forbidden-imports` (error)

### R2-02 Â· Slice'lar arasÄ± yalnÄ±zca public API
**Ne:** baÅŸka slice'Ä±n `index.ts` dÄ±ÅŸÄ±ndan import yasak. **Neden:** kapsÃ¼lleme; iÃ§ deÄŸiÅŸiklik dÄ±ÅŸarÄ± sÄ±zmaz.
âŒ `import { X } from '@/features/user/model/helpers'`
âœ… `import { X } from '@/features/user'`
**Zorlayan:** Steiger `no-cross-imports` + `public-api` (error)

### R2-03 Â· SirkÃ¼ler import yasak
**Ne:** `A â†’ B â†’ A` zinciri olmaz. **Neden:** init sÄ±rasÄ± bozulur, ajan diff'inde gÃ¶rÃ¼nmez kÄ±rÄ±lma.
**Zorlayan:** `import-x/no-cycle` (error, ESLint 10 â€” eslint-plugin-import desteklemediÄŸi iÃ§in fork)

### R2-04 Â· Segment disiplini (ui/model/lib/api/config)
**Ne:** segment dÄ±ÅŸÄ±na Ã§Ä±kan dosyalama yasak; `model/` state iÃ§erir, `lib/` saf fonksiyon, `api/` istek.
**Neden:** ajanÄ±n dosya iÃ§i baÄŸlamÄ±nÄ± daraltÄ±r (150 satÄ±r + tek sorumluluk).
**Zorlayan:** Steiger segment kuralÄ± (FAZ 1 config) + verifier (niyet sapmasÄ±)

## ASK FIRST
- R2-A1: shared â†’ features doÄŸrudan baÄŸÄ±mlÄ±lÄ±k (kural ihlali demektir) â†’ tasarÄ±m konuÅŸ
- R2-A2: yeni katman/slice â†’ Ã¶nce `fsd.guide.md` gÃ¼ncelle
- R2-A3: iki katmanÄ± aynÄ± slice'a koymak â†’ niyet aÃ§Ä±k deÄŸilse konuÅŸ

## NEVER
- âŒ aÅŸaÄŸÄ± katmandan yukarÄ± katmana import
- âŒ slice iÃ§ segment delme (`@/features/user/model` â€” public API dÄ±ÅŸÄ±)
- âŒ 3+ seviye iÃ§ iÃ§e segment (ui/ui/ui) â€” yeni slice sinyali
- âŒ aynÄ± slice'Ä±n iki alt dizininde ortak durumun iki kopyasÄ± (bkz. 03-state)

## Verifier maddeleri (C3 diff kapsamÄ± iÃ§inde denetler)
- V2-1: diff'teki import'lar Steiger'Ä±n gÃ¶remediÄŸi glob/manual alias kullanÄ±yor mu?
- V2-2: "mimari niyet" â€” dosya yeri ile sorumluluÄŸu uyumlu mu?
- V2-3: public API'ye eklenen export gerekli mi, yoksa kapsÃ¼lleme deliÄŸi mi?
