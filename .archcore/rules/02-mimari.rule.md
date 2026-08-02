---
description: FSD mimari kuralları — katman hiyerarşisi, import sınırları, public API
globs: src/**
priority: P0
last_review_date: 2026-08-02
ttl_days: 90
---

# 2. Mimari (FSD)

**Kaynak:** feature-sliced.design · Steiger 0.6 (resmi FSD linter)
**Zorlama:** Steiger (forbidden-imports / no-cross-imports / public-api) + import/no-cycle + verifier

## ALWAYS

### R2-01 · Katman hiyerarşisi (sadece yukarıdan aşağıya import)
**Ne:** app → pages → widgets → features → entities → shared. Aşağı katman yukarı import EDEMEZ.
**Neden:** katman sızıntısı = mimari çürüme; FSD'nin tüm vaadi bu sınırda.
❌ `entities/` içinden `features/x` import etmek
✅ yukarı katman, aşağı katmanı tüketir; veri akışı event/handler üzerinden
**Zorlayan:** Steiger `forbidden-imports` (error)

### R2-02 · Slice'lar arası yalnızca public API
**Ne:** başka slice'ın `index.ts` dışından import yasak. **Neden:** kapsülleme; iç değişiklik dışarı sızmaz.
❌ `import { X } from '@/features/user/model/helpers'`
✅ `import { X } from '@/features/user'`
**Zorlayan:** Steiger `no-cross-imports` + `public-api` (error)

### R2-03 · Sirküler import yasak
**Ne:** `A → B → A` zinciri olmaz. **Neden:** init sırası bozulur, ajan diff'inde görünmez kırılma.
**Zorlayan:** `import-x/no-cycle` (error, ESLint 10 — eslint-plugin-import desteklemediği için fork)

### R2-04 · Segment disiplini (ui/model/lib/api/config)
**Ne:** segment dışına çıkan dosyalama yasak; `model/` state içerir, `lib/` saf fonksiyon, `api/` istek.
**Neden:** ajanın dosya içi bağlamını daraltır (150 satır + tek sorumluluk).
**Zorlayan:** Steiger segment kuralı (FAZ 1 config) + verifier (niyet sapması)

## ASK FIRST
- R2-A1: shared → features doğrudan bağımlılık (kural ihlali demektir) → tasarım konuş
- R2-A2: yeni katman/slice → önce `fsd.guide.md` güncelle
- R2-A3: iki katmanı aynı slice'a koymak → niyet açık değilse konuş

## NEVER
- ❌ aşağı katmandan yukarı katmana import
- ❌ slice iç segment delme (`@/features/user/model` — public API dışı)
- ❌ 3+ seviye iç içe segment (ui/ui/ui) — yeni slice sinyali
- ❌ aynı slice'ın iki alt dizininde ortak durumun iki kopyası (bkz. 03-state)

## Verifier maddeleri (C3 diff kapsamı içinde denetler)
- V2-1: diff'teki import'lar Steiger'ın göremediği glob/manual alias kullanıyor mu?
- V2-2: "mimari niyet" — dosya yeri ile sorumluluğu uyumlu mu?
- V2-3: public API'ye eklenen export gerekli mi, yoksa kapsülleme deliği mi?
