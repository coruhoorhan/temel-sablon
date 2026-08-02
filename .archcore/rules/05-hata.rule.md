---
description: Hata yönetimi kuralları — hata yutma yasağı, hata zinciri bütünlüğü, kullanıcı mesajı
globs: src/**/*.{ts,tsx}
priority: P0
last_review_date: 2026-08-02
ttl_days: 90
---

# 5. Hata Yönetimi

**Kaynak:** sonarjs (S2486, S2737, S7722, S7718, S7786) + typescript-eslint + verifier
**Zorlama:** makine kuralları + verifier (zincir bütünlüğü, kullanıcı mesajı)

## ALWAYS

### R5-01 · Boş catch yasak — hata yutma
**Ne:** `catch {}` / `catch (e) { void e }` yasak. **Neden:** sessiz hata = debug cehennemi.
❌ `try { ... } catch { /* yok say */ }`
✅ `catch (e) { logError(e, ctx); throw toFriendly(e); }` — en azından log + üst katmana
**Zorlayan:** `sonarjs/no-ignored-exceptions` (S2486, error)

### R5-02 · no-useless-catch
**Ne:** sırf fırlatmak için yakalamak yasak. **Neden:** gerçek iş yapmıyorsa catch gereksiz.
❌ `catch (e) { throw e }` ✅ catch yok — doğal yayılım
**Zorlayan:** `sonarjs/no-useless-catch` (S2737, error)

### R5-03 · Sonar S7722/S7718/S7786 (promise/async ailesi)
**Ne:** gereksiz Promise yaratma, yutulan return değeri, thenable kötüye kullanımı yasak.
**Zorlayan:** `sonarjs/*` ilgili kurallar (FAZ 1 config; S7722: no-creation-of-promise-in-promise-returning-function vb.)

### R5-04 · no-misused-promises + use-unknown-in-catch
**Ne:** promise'i value gibi kullanma; catch parametresi `unknown` olmalı.
❌ `catch (e) { const msg = e.message }` (e: unknown kırılır)
✅ `catch (e) { const msg = e instanceof ApiError ? e.message : 'Bilinmeyen hata' }`
**Zorlayan:** `@typescript-eslint/no-misused-promises` + `use-unknown-in-catch` (error)

### R5-05 · Hata zinciri korunur (her async katta ya yeniden fırlat ya dönüştür)
**Ne:** yakalanan hata ya loglanıp yeniden fırlatılır ya kullanıcı dostu dönüştürülür; asla kaybolmaz.
**Neden:** üretimde hata görünmezse = kullanıcı boş ekran görür, log boş.
**Zorlayan:** verifier (V5-1) — makine kapsayamaz

## ASK FIRST
- R5-A1: `console.error` yerine loglama altyapısı mı? (yalnız dev'de console)
- R5-A2: kullanıcıya gösterilecek mesaj → kılavuz metni (i18n) + güvenli (raw hata asla gösterilmez)
- R5-A3: retry politikası — transient hata için kaç deneme? backoff?

## NEVER
- ❌ boş catch (R5-01) — yorum bile yoksa bloklanır
- ❌ kullanıcıya ham `err.message`/stack gösterme (bilgi sızıntısı + çirkin)
- ❌ hata sonrası state'i yarıda bırakmak (rollback/geri yükleme planı şart)
- ❌ unhandled promise rejection (no-floating-promises, bkz. 01-tipler R1-06)

## Verifier maddeleri
- V5-1: hata zinciri bütünlüğü — diff'teki her try/catch zincirin neresinde, sonuç nereye gidiyor?
- V5-2: kullanıcı yüzeyi — hata durumunda UI ne gösteriyor? (boş ekran yasağı)
- V5-3: toplu işlerde kısmi başarı — bazı kayıtlar başarılı bazıları hatalı: durum raporlanıyor mu?
