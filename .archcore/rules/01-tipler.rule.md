---
description: Tip güvenliği kuralları — strictTypeChecked ailesi + manuel tip kuralları
globs: src/**/*.{ts,tsx}
priority: P0
last_review_date: 2026-08-02
ttl_days: 90
---

# 1. Tipler

**Kaynak:** typescript-eslint strictTypeChecked (68 kural) · Google TS Style
**Zorlama:** ESLint 10 flat config (FAZ 1) + verifier yalnızca manuel maddeler

## ALWAYS

### R1-01 · no-explicit-any
**Ne:** `any` yasak. **Neden:** tip güvenliğini tamamen kapatır, verifier'ın kanıt zincirini kırar.
❌ `const x: any = parse(raw)`
✅ `const x: unknown = parse(raw); const y = narrow(x);`

### R1-02 · no-non-null-assertion
**Ne:** `!` operatörü yasak. **Neden:** runtime'da patlar, yalan "kesin var" iddiası.
❌ `user!.name`
✅ `if (user === null) throw new ApiError('user-missing'); user.name`
**Zorlayan:** `@typescript-eslint/no-non-null-assertion` (error)

### R1-03 · no-unsafe-* (assignment/member-access/call/argument/return-type)
**Ne:** `any` taşıyan ifade üzerinde güvensiz işlem yasak. **Neden:** `any` sızıntısı zinciri.
**Zorlayan:** strictTypeChecked grubu (varsayılan error)

### R1-04 · switch-exhaustiveness-check
**Ne:** switch, union'ın TÜM varyantlarını kapsamalı. **Neden:** yeni varyant sessizce kaybolur.
❌ `switch (status) { case 'a': ... }` (b/c sessiz)
✅ `default: { const _exhaustive: never = status; throw new ApiError('unreachable'); }`
**Zorlayan:** `@typescript-eslint/switch-exhaustiveness-check` (error) — v8.64+ kuralı, strict config'te YOK, config'te elle ekli (FAZ 1 ✅)

### R1-05 · strict-boolean-expressions
**Ne:** `if (value)` yalnızca gerçek boolean. **Neden:** `0`/`""`/`NaN` sürprizleri.
❌ `if (items.length)` ✅ `if (items.length > 0)`
**Zorlayan:** `@typescript-eslint/strict-boolean-expressions` (error) — strict config'te YOK, config'te elle ekli (FAZ 1 ✅)

### R1-06 · no-floating-promises
**Ne:** işlenmemiş promise bırakma. **Neden:** sessiz hata yutma, yarış durumları.
❌ `saveUser(u)` ✅ `await saveUser(u)` veya `void saveUser(u).catch(handle)`
**Zorlayan:** `@typescript-eslint/no-floating-promises` (error)

### R1-07 · no-unnecessary-condition
**Ne:** her zaman doğru/yanlış koşul yasak. **Neden:** kod yalan söylüyor demektir.
**Zorlayan:** `@typescript-eslint/no-unnecessary-condition` (error)

### R1-08 · only-throw-error
**Ne:** yalnızca Error throw. **Neden:** string throw hata zincirini bozar.
❌ `throw 'hata'` ✅ `throw new ApiError('hata', { code: 'E_X' })`

## ASK FIRST
- R1-A1: `as` assertion'ı → Zod/narrow fonksiyonu öner; kullanılıyorsa yorum + ticket şart
- R1-A2: `no-non-null-assertion` inline disable → gerekçeli yorum zorunlu

## NEVER
- ❌ `any` (tek istisna: `catch` eski kod köprüsü, ticket'lı)
- ❌ `!` operatörü
- ❌ unsafe zincir: `(x as any).foo.bar`
- ❌ boş `catch` bloğu (bkz. 05-hata R5-01)
