---
description: Performans kurallarÄ± â€” render disiplini, memo stratejisi, N+1, karmaÅŸÄ±klÄ±k
globs: src/**/*.{ts,tsx}
priority: P1
last_review_date: 2026-08-02
ttl_days: 90
---

# 7. Performans

**Kaynak:** @eslint-react Â· react-hooks Â· sonarjs Â· knip Â· verifier
**Zorlama:** makine kurallarÄ± + verifier (N+1, memo stratejisi)

## ALWAYS

### R7-01 Â· no-missing-key
**Ne:** liste render'Ä±nda `key` zorunlu. **Neden:** React diff bozulur, gizli state kaybÄ±.
**Zorlayan:** `@eslint-react/no-missing-key` (error)

### R7-02 Â· no-array-index-key
**Ne:** dizin key yasak (sabit olmayan listelerde). **Neden:** ekleme/silme key karÄ±ÅŸÄ±klÄ±ÄŸÄ±.
âŒ `items.map((i, idx) => <Row key={idx} />)`
âœ… `items.map((i) => <Row key={i.id} />)` (benzersiz id ÅŸart)
**Zorlayan:** `react/no-array-index-key` (error)

### R7-03 Â· jsx-no-bind (yeni fonksiyon Ã¼retimi)
**Ne:** render'da inline fonksiyon yasak (gereksizse). **Neden:** her render yeni referans â†’ children yeniden render.
âŒ `<Button onClick={() => save(x)} />` âœ… `useCallback(() => save(x), [x])` veya etkinlik yukarÄ± taÅŸÄ±
**Zorlayan:** `react/jsx-no-bind` (error, uygun config ile)

### R7-04 Â· cognitive-complexity
**Ne:** fonksiyon biliÅŸsel karmaÅŸÄ±klÄ±ÄŸÄ± eÅŸiÄŸin altÄ±nda. **Neden:** iÃ§ iÃ§e koÅŸul = ajan hatasÄ± Ã¼reme alanÄ±.
**Zorlayan:** `sonarjs/cognitive-complexity` (error, eÅŸik config'te â€” FAZ 1)

### R7-05 Â· Ã–lÃ¼ kod
**Ne:** kullanÄ±lmayan export/import/dosya commit'e girmez. **Neden:** bakÄ±m yÃ¼kÃ¼ + ajanÄ±n yanlÄ±ÅŸ baÄŸlam seÃ§imi.
**Zorlayan:** knip (FAZ 1) + `no-unused-vars` (error)

## ASK FIRST
- R7-A1: yeni memoization â†’ gerÃ§ek profil ihtiyacÄ± mÄ±? erken optimizasyon yasaÄŸÄ±
- R7-A2: N+1 ÅŸÃ¼phesi â†’ veri ÅŸekli deÄŸiÅŸikliÄŸi (batch) konuÅŸ (verifier zorunlu)
- R7-A3: bÃ¼yÃ¼k liste â†’ virtualize mi? (react-window vs)

## NEVER
- âŒ render iÃ§inde aÄŸÄ±r hesaplama (filter/sort inline)
- âŒ her render'da yeni context value (R3-06 ile birlikte)
- âŒ kullanÄ±lmayan parametre/import bÄ±rakma (knip + no-unused-vars)
- âŒ aynÄ± veriyi birden Ã§ok kez fetch etmek (cache/dedupe ÅŸart)

## Verifier maddeleri
- V7-1: N+1 â€” diff'te dÃ¶ngÃ¼ iÃ§inde fetch/query var mÄ±?
- V7-2: memo stratejisi â€” gereksiz memo (erken optimizasyon) mu, eksik memo (gereksiz render) mÄ±?
- V7-3: bÃ¼yÃ¼k veri yÃ¼zeyi â€” tÃ¼m liste client'a mÄ± Ã§ekiliyor, sayfalama/select gerekli mi?
