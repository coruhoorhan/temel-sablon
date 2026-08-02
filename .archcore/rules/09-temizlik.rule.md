---
description: Temizlik kuralları — format, dosya boyutu, commit disiplini, ölü kod, TODO yasağı
globs: src/**/*.{ts,tsx}
priority: P1
last_review_date: 2026-08-02
ttl_days: 90
---

# 9. Temizlik

**Kaynak:** Prettier/Biome 2.4 · sonarjs · commitlint · knip · kural dokümanı
**Zorlama:** makine kuralları + verifier (boyut niyeti, TODO denetimi)

## ALWAYS

### R9-01 · Dosya ≤150 etkin satır
**Ne:** üretim dosyası 150 etkin satırı aşamaz (skipBlankLines + skipComments — yorum/boşlukla şişirme yok).
**Neden:** ajan doğruluğu kısa dosyada %83→%89 (arXiv 2603.20432); shadcn/ui medyan 59.5 satır.
**Zorlayan:** ESLint `max-lines` (FAZ 1): `src/**/*.{ts,tsx}` max 150, skipBlank+skipComments
**Muaf:** `*.test.*` `*.spec.*` `__tests__` `*.stories.*` `fixtures/**` `mocks/**` + machine/reducer (ikinci grup 400)
**Aşarsa:** FSD segmentlerine böl (ui/ alt-component, model/ hook, lib/ saf fonksiyon, api/ istek)

### R9-02 · Format determinizmi
**Ne:** format tek araç, tek config (Prettier 3/Biome); lint-format ayrılmaz.
**Zorlayan:** Prettier/Biome check (K1 hook + CI)

### R9-03 · no-duplicate-string
**Ne:** aynı string 3+ kez tekrar etmez. **Neden:** kopya = güncelleme kaçırma bug'ı.
**Zorlayan:** `sonarjs/no-duplicate-string` (error)

### R9-04 · prefer-immediate-return + no-inverted-boolean-check
**Ne:** gereksiz değişken atama ve ters koşul okunabilirliği. **Zorlayan:** `sonarjs/prefer-immediate-return` + `no-inverted-boolean-check` (error)

### R9-05 · TODO yasağı
**Ne:** `TODO/FIXME/HACK` commit'e girmez; iş ticket'a/plan dosyasına gider.
**Neden:** TODO'lar unutulur, plan sistemi var — oraya yaz.
**Zorlayan:** verifier (V9-1) + grep kuralı (K1 hook: `grep -rn 'TODO\|FIXME' src --exclude-dir=node_modules`)

### R9-06 · Conventional commit + plan trailer
**Ne:** `type(scope): subject` + `plan: <id>` trailer'ı zorunlu. **Neden:** geçmiş otomatik okunur; onay kapısı trailer'ı okur.
✅ `feat(auth): add refresh token rotation\n\nplan: auth-refresh-tokens`
**Zorlayan:** commitlint (K1) + `.archcore/bin/verify-commit-msg` (plan kapısı)

### R9-07 · Atomik commit
**Ne:** tek commit = tek mantıksal değişiklik (≤300 satır diff). **Neden:** büyük diff verifier'ı atlar (K1 eşiği), geri alma zorlaşır.
**Zorlayan:** verifier (V9-2) + K1 "diff'i böl" uyarısı

## ASK FIRST
- R9-A1: 150'yi aşma eşiğinde → bölme planı konuş, disable değil
- R9-A2: inline disable (eslint) → gerekçeli yorum şart, aylık denetim

## NEVER
- ❌ TODO/FIXME/HACK komiteleri
- ❌ gizli kod yorumları ("burada ne yapıyorduk?") — sil ya da belgele
- ❌ `console.log` üretim kodu (dev-only; loglama altyapısı kullan)
- ❌ kullanılmayan import/export (knip + no-unused-vars)

## Verifier maddeleri
- V9-1: TODO/yorum kalıntısı + gerekçesiz disable var mı?
- V9-2: diff kapsamı — tek sorumluluk mu? ilişkisiz değişiklik karışmış mı? (C3/C9)
