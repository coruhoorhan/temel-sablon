---
description: Veri kurallarÄ± â€” doÄŸrulama, dÃ¶nÃ¼ÅŸÃ¼m, null handling, timezone, pagination
globs: src/**/*.{ts,tsx}
priority: P0
last_review_date: 2026-08-02
ttl_days: 90
---

# 6. Veri

**Kaynak:** typescript-eslint strict + Zod + kural dokÃ¼manÄ± + verifier
**Zorlama:** makine kurallarÄ± + verifier (Zod zorunluluÄŸu, zaman, sayfalama)

## ALWAYS

### R6-01 Â· SÄ±nÄ±r geÃ§iÅŸinde ÅŸema doÄŸrulama (Zod zorunlu)
**Ne:** API/parse/girdi â†’ tip eÅŸlemesi `as` ile deÄŸil ÅŸema ile. **Neden:** `as User` yalanÄ± runtime'da yok.
âŒ `const u = res.data as User`
âœ… `const u = UserSchema.parse(res.data)` (fail-fast) veya `safeParse` + hata yolu
**Zorlayan:** verifier (V6-1) â€” makine `no-unnecessary-type-assertion` kÄ±smen yakalar

### R6-02 Â· no-base-to-string
**Ne:** object â†’ string otomatik dÃ¶nÃ¼ÅŸÃ¼mÃ¼ yasak. **Neden:** `[object Object]` sessizce UI'a girer.
**Zorlayan:** `@typescript-eslint/no-base-to-string` (error)

### R6-03 Â· no-unnecessary-type-assertion
**Ne:** gereksiz `as` yasak. **Neden:** tip zaten biliniyorsa assertion = gereksiz risk.
**Zorlayan:** `@typescript-eslint/no-unnecessary-type-assertion` (error)

### R6-04 Â· await-thenable + require-await
**Ne:** await yalnÄ±zca gerÃ§ek promise; async fonksiyon iÃ§inde mutlaka await. **Neden:** yanlÄ±ÅŸ senkron/async kullanÄ±mÄ±.
**Zorlayan:** `@typescript-eslint/await-thenable` + `require-await` (error)

### R6-05 Â· restrict-plus-operands
**Ne:** `+` yalnÄ±zca sayÄ±lar. **Neden:** `"1" + 2 = "12"` stringleÅŸme sÃ¼rprizleri.
âŒ `total = base + count` (count: string olabilir) âœ… `Number(base) + count`
**Zorlayan:** `@typescript-eslint/restrict-plus-operands` (error)

### R6-06 Â· Null handling (noUncheckedIndexedAccess)
**Ne:** dizin eriÅŸimi `T | undefined` dÃ¶ner; her eriÅŸimde kontrol. **Neden:** runtime undefined patlamasÄ±.
âŒ `items[0].name` âœ… `const first = items[0]; if (!first) return null; first.name`
**Zorlayan:** tsc `noUncheckedIndexedAccess` (FAZ 1 config)

## ASK FIRST
- R6-A1: timezone â€” tarihler hangi zona gÃ¶re? UTC depolama + gÃ¶rÃ¼nÃ¼mde yerel dÃ¶nÃ¼ÅŸÃ¼m ÅŸart
- R6-A2: pagination â€” yeni liste API'si sayfalama kullanÄ±yor mu? sonsuz kaydÄ±rma planÄ±?
- R6-A3: bÃ¼yÃ¼k payload/stream â€” JSON.parse yerine akÄ±ÅŸ gerekiyor mu?

## NEVER
- âŒ `as User` / herhangi bir sÄ±nÄ±r geÃ§iÅŸinde assertions (R6-01)
- âŒ `new Date(string)` yerel zona gÃ¶re parse (timezone kuralÄ± ihlali)
- âŒ state'te Date/Map â€” dÃ¶nÃ¼ÅŸtÃ¼rerek sakla (bkz. 03-state)
- âŒ kayÄ±p null kontrolÃ¼ (noUncheckedIndexedAccess bypass: `!` de yasak â€” R1-02)

## Verifier maddeleri
- V6-1: her API sÄ±nÄ±rÄ± (fetch/parse/storage) ÅŸema doÄŸrulamadan geÃ§iyor mu?
- V6-2: timezone â€” diff'teki tarih iÅŸlemleri UTC temelli mi? gÃ¶rÃ¼nÃ¼m dÃ¶nÃ¼ÅŸÃ¼mÃ¼ var mÄ±?
- V6-3: pagination â€” liste getiren yeni kod sayfalama/limit eksikliÄŸi var mÄ±?
- V6-4: silinen nullable alanlar â€” optional chaining yerine `!` kullanÄ±lmÄ±ÅŸ mÄ±?
