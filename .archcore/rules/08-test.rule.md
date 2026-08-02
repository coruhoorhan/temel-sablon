---
description: Test kuralları — coverage eşiği, testing-library disiplini, AAA deseni
globs: src/**/*.test.{ts,tsx}, src/**/__tests__/**
priority: P0
last_review_date: 2026-08-02
ttl_days: 90
---

# 8. Test

**Kaynak:** Vitest 4 + @vitest/coverage-v8 · testing-library · jest-dom
**Zorlama:** Vitest coverage eşiği (makine) + testing-library kuralları + verifier (AAA, sözleşme testi)

## ALWAYS

### R8-01 · Coverage eşiği (yeni kod)
**Ne:** %80/75/80/80 (lines/functions/branches/statements) + perFile; `coverage.include` yalnız src.
**Neden:** gerilemeye kapalı kalite; "test yazdım" demek yetmez — ölçülür.
**Zorlayan:** Vitest config (FAZ 1): `coverage: { thresholds: { lines: 80, functions: 75, branches: 80, statements: 80 }, perFile: true }`

### R8-02 · prefer-user-event
**Ne:** kullanıcı simülasyonu fireEvent yerine user-event. **Neden:** gerçek etkileşim farklıdır (keydown vs click).
❌ `fireEvent.click(btn)` ✅ `await user.click(btn)`
**Zorlayan:** `testing-library/prefer-user-event` (error)

### R8-03 · no-node-access + no-container
**Ne:** DOM'a doğrudan erişim/container yasak. **Neden:** test gerçek kullanıcı gibi olmalı.
❌ `screen.getByTestId('x')` yerine container sorgusu
**Zorlayan:** `testing-library/no-node-access` + `no-container` (error)

### R8-04 · no-debugging-utils
**Ne:** `screen.debug()` commit'te kalmaz. **Neden:** geçici debug gürültüsü.
**Zorlayan:** `testing-library/no-debugging-utils` (error)

### R8-05 · AAA deseni (Arrange-Act-Assert)
**Ne:** her test üç bölüm + tek davranış iddiası. **Neden:** başarısız testin "ne bozuldu" sorusu 5 sn'de yanıtlanır.
**Zorlayan:** verifier (V8-1) — yapısal makine kuralı yok

## ASK FIRST
- R8-A1: sözleşme-doğrulayan test — kritik iş mantığında şema (Zod) + happy/unhappy yol testleri şart mı?
- R8-A2: snapshot testleri yalnızca kararlı UI'da; değişen UI'da snapshot = gürültü
- R8-A3: E2E (Playwright) — kritik akışlar FAZ 6 pilotunda kararlaştırılacak

## NEVER
- ❌ `getByTestId` (testing-library kuralı — kullanıcı görünürlüğü yerine test kancası)
- ❌ `.only` / `.skip` commit'e girmez (CI'da çalıştırılan config'te yasak: `--forbidOnly`)
- ❌ gerçek ağ çağrısı (msw/fetch mock şart)
- ❌ coverage düşürme — eşik altı test commit'i K2/CI'da bloklanır

## Verifier maddeleri
- V8-1: AAA deseni — testler düzenli mi, tek davranış mı iddia ediyor?
- V8-2: sözleşme testi — yeni iş mantığı için happy+unhappy yol var mı?
- V8-3: test kapsamı — diff'teki kritik dallar (hata yolları) test edilmiş mi? (C7 checklist)
