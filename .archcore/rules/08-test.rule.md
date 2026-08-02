---
description: Test kurallarÄ± â€” coverage eÅŸiÄŸi, testing-library disiplini, AAA deseni
globs: src/**/*.test.{ts,tsx}, src/**/__tests__/**
priority: P0
last_review_date: 2026-08-02
ttl_days: 90
---

# 8. Test

**Kaynak:** Vitest 4 + @vitest/coverage-v8 Â· testing-library Â· jest-dom
**Zorlama:** Vitest coverage eÅŸiÄŸi (makine) + testing-library kurallarÄ± + verifier (AAA, sÃ¶zleÅŸme testi)

## ALWAYS

### R8-01 Â· Coverage eÅŸiÄŸi (yeni kod)
**Ne:** %80/75/80/80 (lines/functions/branches/statements) + perFile; `coverage.include` yalnÄ±z src.
**Neden:** gerilemeye kapalÄ± kalite; "test yazdÄ±m" demek yetmez â€” Ã¶lÃ§Ã¼lÃ¼r.
**Zorlayan:** Vitest config (FAZ 1): `coverage: { thresholds: { lines: 80, functions: 75, branches: 80, statements: 80 }, perFile: true }`

### R8-02 Â· prefer-user-event
**Ne:** kullanÄ±cÄ± simÃ¼lasyonu fireEvent yerine user-event. **Neden:** gerÃ§ek etkileÅŸim farklÄ±dÄ±r (keydown vs click).
âŒ `fireEvent.click(btn)` âœ… `await user.click(btn)`
**Zorlayan:** `testing-library/prefer-user-event` (error)

### R8-03 Â· no-node-access + no-container
**Ne:** DOM'a doÄŸrudan eriÅŸim/container yasak. **Neden:** test gerÃ§ek kullanÄ±cÄ± gibi olmalÄ±.
âŒ `screen.getByTestId('x')` yerine container sorgusu
**Zorlayan:** `testing-library/no-node-access` + `no-container` (error)

### R8-04 Â· no-debugging-utils
**Ne:** `screen.debug()` commit'te kalmaz. **Neden:** geÃ§ici debug gÃ¼rÃ¼ltÃ¼sÃ¼.
**Zorlayan:** `testing-library/no-debugging-utils` (error)

### R8-05 Â· AAA deseni (Arrange-Act-Assert)
**Ne:** her test Ã¼Ã§ bÃ¶lÃ¼m + tek davranÄ±ÅŸ iddiasÄ±. **Neden:** baÅŸarÄ±sÄ±z testin "ne bozuldu" sorusu 5 sn'de yanÄ±tlanÄ±r.
**Zorlayan:** verifier (V8-1) â€” yapÄ±sal makine kuralÄ± yok

## ASK FIRST
- R8-A1: sÃ¶zleÅŸme-doÄŸrulayan test â€” kritik iÅŸ mantÄ±ÄŸÄ±nda ÅŸema (Zod) + happy/unhappy yol testleri ÅŸart mÄ±?
- R8-A2: snapshot testleri yalnÄ±zca kararlÄ± UI'da; deÄŸiÅŸen UI'da snapshot = gÃ¼rÃ¼ltÃ¼
- R8-A3: E2E (Playwright) â€” kritik akÄ±ÅŸlar FAZ 6 pilotunda kararlaÅŸtÄ±rÄ±lacak

## NEVER
- âŒ `getByTestId` (testing-library kuralÄ± â€” kullanÄ±cÄ± gÃ¶rÃ¼nÃ¼rlÃ¼ÄŸÃ¼ yerine test kancasÄ±)
- âŒ `.only` / `.skip` commit'e girmez (CI'da Ã§alÄ±ÅŸtÄ±rÄ±lan config'te yasak: `--forbidOnly`)
- âŒ gerÃ§ek aÄŸ Ã§aÄŸrÄ±sÄ± (msw/fetch mock ÅŸart)
- âŒ coverage dÃ¼ÅŸÃ¼rme â€” eÅŸik altÄ± test commit'i K2/CI'da bloklanÄ±r

## Verifier maddeleri
- V8-1: AAA deseni â€” testler dÃ¼zenli mi, tek davranÄ±ÅŸ mÄ± iddia ediyor?
- V8-2: sÃ¶zleÅŸme testi â€” yeni iÅŸ mantÄ±ÄŸÄ± iÃ§in happy+unhappy yol var mÄ±?
- V8-3: test kapsamÄ± â€” diff'teki kritik dallar (hata yollarÄ±) test edilmiÅŸ mi? (C7 checklist)
