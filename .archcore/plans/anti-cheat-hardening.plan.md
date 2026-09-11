---
description: Anti-cheat kurallari — vitest/expect-expect sahte test engeli, complexity 10 ve max-params 3, zero-any ve pre-push 80 coverage hard-gate
status: accepted
title: "anti-cheat-hardening — Sahte Test, Complexity ve Zero-Any Barikatlari"
approved_by: Kullanici
plan_hash: 6f1b5cb498618e83fa64879b6f9560302ddd5e55f62ecb78774b3872f83c348c
last_approved: 2026-09-11T12:28:18Z
last_review_date: 2026-09-11T12:28:18Z
ttl_days: 90
allowed_paths:
  - .gitignore
  - package.json
  - package-lock.json
  - eslint.config.mjs
  - lefthook.yml
  - .archcore/plans/anti-cheat-hardening.plan.md
---

# Plan: anti-cheat-hardening

## Bağlam
Yapay zeka ajanlarının TDD kapılarını sahte / assertion-free testlerle atlamasını engellemek,
spagetti fonksiyonlar (complexity > 10) yazmasını önlemek, `any` tip kaçışlarını sıfırlamak
ve pre-push aşamasında %80 coverage eşiğini zorunlu kılmak için mekanik lint ve test kontrolleri eklendi.

## Çözüm Tasarımı
1. `@vitest/eslint-plugin`:
   - `vitest/expect-expect`: Her test bloğu en az 1 gerçek assertion içermelidir (sahte test engeli).
   - `vitest/no-disabled-tests`: `test.skip` veya `it.todo` ile test atlama engellendi.
   - `vitest/no-focused-tests`: `test.only` kalıntıları engellendi.
   - `vitest/no-identical-title`: Kopyala-yapıştır testler engellendi.
   - `vitest/no-conditional-expect`: Koşullu assertion kaçışı engellendi.
2. Karmaşıklık Kuralları:
   - `complexity: ['error', { max: 10 }]`: Fonksiyon karmaşıklığı 10 ile sınırlandı.
   - `max-params: ['error', 3]`: Fonksiyon başına maksimum 3 parametre (DTO zorunluluğu).
   - `max-nested-callbacks: ['error', 3]`: İç içe callback derinliği sınırlandı.
3. Tip Disiplini:
   - `@typescript-eslint/no-explicit-any: 'error'`: Üretim kodunda any kullanımı kesin olarak yasaklandı.
   - `@typescript-eslint/no-non-null-assertion: 'error'`: Tip ezme yasaklandı.
4. Pre-push Coverage Kapısı:
   - `lefthook.yml` pre-push'ta `npm test` yerine `npm run coverage` (%80 eşik denetimi) bağlandı.

## Etkilenen Dosyalar
- [x] package.json
- [x] package-lock.json
- [x] eslint.config.mjs
- [x] lefthook.yml
- [x] .gitignore
- [x] .archcore/plans/anti-cheat-hardening.plan.md
