---
description: Veri kuralları — doğrulama, dönüşüm, null handling, timezone, pagination
globs: src/**/*.{ts,tsx}
priority: P0
last_review_date: 2026-08-02
ttl_days: 90
---

# 6. Veri

**Kaynak:** typescript-eslint strict + Zod + kural dokümanı + verifier
**Zorlama:** makine kuralları + verifier (Zod zorunluluğu, zaman, sayfalama)

## ALWAYS

### R6-01 · Sınır geçişinde şema doğrulama (Zod zorunlu)
**Ne:** API/parse/girdi → tip eşlemesi `as` ile değil şema ile. **Neden:** `as User` yalanı runtime'da yok.
❌ `const u = res.data as User`
✅ `const u = UserSchema.parse(res.data)` (fail-fast) veya `safeParse` + hata yolu
**Zorlayan:** verifier (V6-1) — makine `no-unnecessary-type-assertion` kısmen yakalar

### R6-02 · no-base-to-string
**Ne:** object → string otomatik dönüşümü yasak. **Neden:** `[object Object]` sessizce UI'a girer.
**Zorlayan:** `@typescript-eslint/no-base-to-string` (error)

### R6-03 · no-unnecessary-type-assertion
**Ne:** gereksiz `as` yasak. **Neden:** tip zaten biliniyorsa assertion = gereksiz risk.
**Zorlayan:** `@typescript-eslint/no-unnecessary-type-assertion` (error)

### R6-04 · await-thenable + require-await
**Ne:** await yalnızca gerçek promise; async fonksiyon içinde mutlaka await. **Neden:** yanlış senkron/async kullanımı.
**Zorlayan:** `@typescript-eslint/await-thenable` + `require-await` (error)

### R6-05 · restrict-plus-operands
**Ne:** `+` yalnızca sayılar. **Neden:** `"1" + 2 = "12"` stringleşme sürprizleri.
❌ `total = base + count` (count: string olabilir) ✅ `Number(base) + count`
**Zorlayan:** `@typescript-eslint/restrict-plus-operands` (error)

### R6-06 · Null handling (noUncheckedIndexedAccess)
**Ne:** dizin erişimi `T | undefined` döner; her erişimde kontrol. **Neden:** runtime undefined patlaması.
❌ `items[0].name` ✅ `const first = items[0]; if (!first) return null; first.name`
**Zorlayan:** tsc `noUncheckedIndexedAccess` (FAZ 1 config)

## ASK FIRST
- R6-A1: timezone — tarihler hangi zona göre? UTC depolama + görünümde yerel dönüşüm şart
- R6-A2: pagination — yeni liste API'si sayfalama kullanıyor mu? sonsuz kaydırma planı?
- R6-A3: büyük payload/stream — JSON.parse yerine akış gerekiyor mu?

## NEVER
- ❌ `as User` / herhangi bir sınır geçişinde assertions (R6-01)
- ❌ `new Date(string)` yerel zona göre parse (timezone kuralı ihlali)
- ❌ state'te Date/Map — dönüştürerek sakla (bkz. 03-state)
- ❌ kayıp null kontrolü (noUncheckedIndexedAccess bypass: `!` de yasak — R1-02)

## Verifier maddeleri
- V6-1: her API sınırı (fetch/parse/storage) şema doğrulamadan geçiyor mu?
- V6-2: timezone — diff'teki tarih işlemleri UTC temelli mi? görünüm dönüşümü var mı?
- V6-3: pagination — liste getiren yeni kod sayfalama/limit eksikliği var mı?
- V6-4: silinen nullable alanlar — optional chaining yerine `!` kullanılmış mı?
