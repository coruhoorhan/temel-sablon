---
description: Performans kuralları — render disiplini, memo stratejisi, N+1, karmaşıklık
globs: src/**/*.{ts,tsx}
priority: P1
last_review_date: 2026-08-02
ttl_days: 90
---

# 7. Performans

**Kaynak:** @eslint-react · react-hooks · sonarjs · knip · verifier
**Zorlama:** makine kuralları + verifier (N+1, memo stratejisi)

## ALWAYS

### R7-01 · no-missing-key
**Ne:** liste render'ında `key` zorunlu. **Neden:** React diff bozulur, gizli state kaybı.
**Zorlayan:** `@eslint-react/no-missing-key` (error)

### R7-02 · no-array-index-key
**Ne:** dizin key yasak (sabit olmayan listelerde). **Neden:** ekleme/silme key karışıklığı.
❌ `items.map((i, idx) => <Row key={idx} />)`
✅ `items.map((i) => <Row key={i.id} />)` (benzersiz id şart)
**Zorlayan:** `react/no-array-index-key` (error)

### R7-03 · jsx-no-bind (yeni fonksiyon üretimi)
**Ne:** render'da inline fonksiyon yasak (gereksizse). **Neden:** her render yeni referans → children yeniden render.
❌ `<Button onClick={() => save(x)} />` ✅ `useCallback(() => save(x), [x])` veya etkinlik yukarı taşı
**Zorlayan:** `react/jsx-no-bind` (error, uygun config ile)

### R7-04 · cognitive-complexity
**Ne:** fonksiyon bilişsel karmaşıklığı eşiğin altında. **Neden:** iç içe koşul = ajan hatası üreme alanı.
**Zorlayan:** `sonarjs/cognitive-complexity` (error, eşik config'te — FAZ 1)

### R7-05 · Ölü kod
**Ne:** kullanılmayan export/import/dosya commit'e girmez. **Neden:** bakım yükü + ajanın yanlış bağlam seçimi.
**Zorlayan:** knip (FAZ 1) + `no-unused-vars` (error)

## ASK FIRST
- R7-A1: yeni memoization → gerçek profil ihtiyacı mı? erken optimizasyon yasağı
- R7-A2: N+1 şüphesi → veri şekli değişikliği (batch) konuş (verifier zorunlu)
- R7-A3: büyük liste → virtualize mi? (react-window vs)

## NEVER
- ❌ render içinde ağır hesaplama (filter/sort inline)
- ❌ her render'da yeni context value (R3-06 ile birlikte)
- ❌ kullanılmayan parametre/import bırakma (knip + no-unused-vars)
- ❌ aynı veriyi birden çok kez fetch etmek (cache/dedupe şart)

## Verifier maddeleri
- V7-1: N+1 — diff'te döngü içinde fetch/query var mı?
- V7-2: memo stratejisi — gereksiz memo (erken optimizasyon) mu, eksik memo (gereksiz render) mı?
- V7-3: büyük veri yüzeyi — tüm liste client'a mı çekiliyor, sayfalama/select gerekli mi?
