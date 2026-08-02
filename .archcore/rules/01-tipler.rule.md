---
description: Tip gÃ¼venliÄŸi kurallarÄ± â€” strictTypeChecked ailesi + manuel tip kurallarÄ±
globs: src/**/*.{ts,tsx}
priority: P0
last_review_date: 2026-08-02
ttl_days: 90
---

# 1. Tipler

**Kaynak:** typescript-eslint strictTypeChecked (68 kural) Â· Google TS Style
**Zorlama:** ESLint 10 flat config (FAZ 1) + verifier yalnÄ±zca manuel maddeler

## ALWAYS

### R1-01 Â· no-explicit-any
**Ne:** `any` yasak. **Neden:** tip gÃ¼venliÄŸini tamamen kapatÄ±r, verifier'Ä±n kanÄ±t zincirini kÄ±rar.
âŒ `const x: any = parse(raw)`
âœ… `const x: unknown = parse(raw); const y = narrow(x);`

### R1-02 Â· no-non-null-assertion
**Ne:** `!` operatÃ¶rÃ¼ yasak. **Neden:** runtime'da patlar, yalan "kesin var" iddiasÄ±.
âŒ `user!.name`
âœ… `if (user === null) throw new ApiError('user-missing'); user.name`
**Zorlayan:** `@typescript-eslint/no-non-null-assertion` (error)

### R1-03 Â· no-unsafe-* (assignment/member-access/call/argument/return-type)
**Ne:** `any` taÅŸÄ±yan ifade Ã¼zerinde gÃ¼vensiz iÅŸlem yasak. **Neden:** `any` sÄ±zÄ±ntÄ±sÄ± zinciri.
**Zorlayan:** strictTypeChecked grubu (varsayÄ±lan error)

### R1-04 Â· switch-exhaustiveness-check
**Ne:** switch, union'Ä±n TÃœM varyantlarÄ±nÄ± kapsamalÄ±. **Neden:** yeni varyant sessizce kaybolur.
âŒ `switch (status) { case 'a': ... }` (b/c sessiz)
âœ… `default: { const _exhaustive: never = status; throw new ApiError('unreachable'); }`
**Zorlayan:** `@typescript-eslint/switch-exhaustiveness-check` (error) â€” v8.64+ kuralÄ±, strict config'te YOK, config'te elle ekli (FAZ 1 âœ…)

### R1-05 Â· strict-boolean-expressions
**Ne:** `if (value)` yalnÄ±zca gerÃ§ek boolean. **Neden:** `0`/`""`/`NaN` sÃ¼rprizleri.
âŒ `if (items.length)` âœ… `if (items.length > 0)`
**Zorlayan:** `@typescript-eslint/strict-boolean-expressions` (error) â€” strict config'te YOK, config'te elle ekli (FAZ 1 âœ…)

### R1-06 Â· no-floating-promises
**Ne:** iÅŸlenmemiÅŸ promise bÄ±rakma. **Neden:** sessiz hata yutma, yarÄ±ÅŸ durumlarÄ±.
âŒ `saveUser(u)` âœ… `await saveUser(u)` veya `void saveUser(u).catch(handle)`
**Zorlayan:** `@typescript-eslint/no-floating-promises` (error)

### R1-07 Â· no-unnecessary-condition
**Ne:** her zaman doÄŸru/yanlÄ±ÅŸ koÅŸul yasak. **Neden:** kod yalan sÃ¶ylÃ¼yor demektir.
**Zorlayan:** `@typescript-eslint/no-unnecessary-condition` (error)

### R1-08 Â· only-throw-error
**Ne:** yalnÄ±zca Error throw. **Neden:** string throw hata zincirini bozar.
âŒ `throw 'hata'` âœ… `throw new ApiError('hata', { code: 'E_X' })`

## ASK FIRST
- R1-A1: `as` assertion'Ä± â†’ Zod/narrow fonksiyonu Ã¶ner; kullanÄ±lÄ±yorsa yorum + ticket ÅŸart
- R1-A2: `no-non-null-assertion` inline disable â†’ gerekÃ§eli yorum zorunlu

## NEVER
- âŒ `any` (tek istisna: `catch` eski kod kÃ¶prÃ¼sÃ¼, ticket'lÄ±)
- âŒ `!` operatÃ¶rÃ¼
- âŒ unsafe zincir: `(x as any).foo.bar`
- âŒ boÅŸ `catch` bloÄŸu (bkz. 05-hata R5-01)
