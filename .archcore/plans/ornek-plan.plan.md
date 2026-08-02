---
id: ornek-plan
status: draft
created: 2026-08-02
approved_by:
last_approved:
last_review_date: 2026-08-02
ttl_days: 90
plan_hash:
scope:
  allowed_paths:
    - .archcore/plans/**
    - config/*
  allowed_commands:
    - npm run typecheck
    - npm test

---

# ornek-plan — Örnek Plan

## Bağlam
Kapı scriptlerinin test edilmesi için örnek plan. Bu dosya şablonun
fixture'ıdır: yeni projede silinir, yerine gerçek planlar yazılır.

## Çözüm tasarımı
Yok — test fixture'ı.

## Etkilenen dosyalar
- (test için boş)

## Test planı
Kapı scriptleri bu dosyayı accepted + hash doğrulamasında kullanır.

## Geri alma planı
Dosya silinir, kapı yeni referansı reddeder.

## Riskler
Yok.
