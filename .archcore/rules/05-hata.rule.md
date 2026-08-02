---
description: Hata yÃ¶netimi kurallarÄ± â€” hata yutma yasaÄŸÄ±, hata zinciri bÃ¼tÃ¼nlÃ¼ÄŸÃ¼, kullanÄ±cÄ± mesajÄ±
globs: src/**/*.{ts,tsx}
priority: P0
last_review_date: 2026-08-02
ttl_days: 90
---

# 5. Hata YÃ¶netimi

**Kaynak:** sonarjs (S2486, S2737, S7722, S7718, S7786) + typescript-eslint + verifier
**Zorlama:** makine kurallarÄ± + verifier (zincir bÃ¼tÃ¼nlÃ¼ÄŸÃ¼, kullanÄ±cÄ± mesajÄ±)

## ALWAYS

### R5-01 Â· BoÅŸ catch yasak â€” hata yutma
**Ne:** `catch {}` / `catch (e) { void e }` yasak. **Neden:** sessiz hata = debug cehennemi.
âŒ `try { ... } catch { /* yok say */ }`
âœ… `catch (e) { logError(e, ctx); throw toFriendly(e); }` â€” en azÄ±ndan log + Ã¼st katmana
**Zorlayan:** `sonarjs/no-ignored-exceptions` (S2486, error)

### R5-02 Â· no-useless-catch
**Ne:** sÄ±rf fÄ±rlatmak iÃ§in yakalamak yasak. **Neden:** gerÃ§ek iÅŸ yapmÄ±yorsa catch gereksiz.
âŒ `catch (e) { throw e }` âœ… catch yok â€” doÄŸal yayÄ±lÄ±m
**Zorlayan:** `sonarjs/no-useless-catch` (S2737, error)

### R5-03 Â· Sonar S7722/S7718/S7786 (promise/async ailesi)
**Ne:** gereksiz Promise yaratma, yutulan return deÄŸeri, thenable kÃ¶tÃ¼ye kullanÄ±mÄ± yasak.
**Zorlayan:** `sonarjs/*` ilgili kurallar (FAZ 1 config; S7722: no-creation-of-promise-in-promise-returning-function vb.)

### R5-04 Â· no-misused-promises + use-unknown-in-catch
**Ne:** promise'i value gibi kullanma; catch parametresi `unknown` olmalÄ±.
âŒ `catch (e) { const msg = e.message }` (e: unknown kÄ±rÄ±lÄ±r)
âœ… `catch (e) { const msg = e instanceof ApiError ? e.message : 'Bilinmeyen hata' }`
**Zorlayan:** `@typescript-eslint/no-misused-promises` + `use-unknown-in-catch` (error)

### R5-05 Â· Hata zinciri korunur (her async katta ya yeniden fÄ±rlat ya dÃ¶nÃ¼ÅŸtÃ¼r)
**Ne:** yakalanan hata ya loglanÄ±p yeniden fÄ±rlatÄ±lÄ±r ya kullanÄ±cÄ± dostu dÃ¶nÃ¼ÅŸtÃ¼rÃ¼lÃ¼r; asla kaybolmaz.
**Neden:** Ã¼retimde hata gÃ¶rÃ¼nmezse = kullanÄ±cÄ± boÅŸ ekran gÃ¶rÃ¼r, log boÅŸ.
**Zorlayan:** verifier (V5-1) â€” makine kapsayamaz

## ASK FIRST
- R5-A1: `console.error` yerine loglama altyapÄ±sÄ± mÄ±? (yalnÄ±z dev'de console)
- R5-A2: kullanÄ±cÄ±ya gÃ¶sterilecek mesaj â†’ kÄ±lavuz metni (i18n) + gÃ¼venli (raw hata asla gÃ¶sterilmez)
- R5-A3: retry politikasÄ± â€” transient hata iÃ§in kaÃ§ deneme? backoff?

## NEVER
- âŒ boÅŸ catch (R5-01) â€” yorum bile yoksa bloklanÄ±r
- âŒ kullanÄ±cÄ±ya ham `err.message`/stack gÃ¶sterme (bilgi sÄ±zÄ±ntÄ±sÄ± + Ã§irkin)
- âŒ hata sonrasÄ± state'i yarÄ±da bÄ±rakmak (rollback/geri yÃ¼kleme planÄ± ÅŸart)
- âŒ unhandled promise rejection (no-floating-promises, bkz. 01-tipler R1-06)

## Verifier maddeleri
- V5-1: hata zinciri bÃ¼tÃ¼nlÃ¼ÄŸÃ¼ â€” diff'teki her try/catch zincirin neresinde, sonuÃ§ nereye gidiyor?
- V5-2: kullanÄ±cÄ± yÃ¼zeyi â€” hata durumunda UI ne gÃ¶steriyor? (boÅŸ ekran yasaÄŸÄ±)
- V5-3: toplu iÅŸlerde kÄ±smi baÅŸarÄ± â€” bazÄ± kayÄ±tlar baÅŸarÄ±lÄ± bazÄ±larÄ± hatalÄ±: durum raporlanÄ±yor mu?
