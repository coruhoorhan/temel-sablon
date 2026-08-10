---
description: Kullanım kılavuzu ekleme — TEMEL şablonunu test eden kullanıcı için adım adım rehber
status: accepted
approved_by: coruhoorhan (insan)
plan_hash: 04d0c2d63410719abf279fed3820d45f33653967eeca1af619638ed63ab0be2d
last_approved: 2026-08-10T06:06:02Z
last_review_date: 2026-08-10T06:06:02Z
ttl_days: 90
allowed_paths:
  - KULLANIM-KLAVUZU.md
  - .archcore/plans/kullanim-klavuzu.plan.md
---

# Plan: kullanim-klavuzu

## Amaç

Kullanıcının şablonu gerçek bir projede test edebilmesi için uçtan uca bir kullanım
kılavuzu (`KULLANIM-KLAVUZU.md`) ekle. İçerik, gerçek kurulum testinden (tmp klasöründe
setup.sh ile yapılan) elde edilen kanıtlara dayanır.

## Kapsam (değiştirilecek dosyalar)

- `KULLANIM-KLAVUZU.md` — YENİ: kurulum, kapı testleri, çalışma döngüsü, F1-F8 özellik testleri
- `.archcore/plans/kullanim-klavuzu.plan.md` — bu plan (onay state'i)

## Kapsam DIŞI

- Kod değişikliği (yalnız dokümantasyon)
- Push (ayrı adım, kullanıcı onayıyla)

## Doğrulama (gerçekleştirildi)

1. Gerçek kurulum testi /tmp/opencode/temel-kurulum-test'te yapıldı (5 tool ok) ✓
2. Kılavuzdaki komutlar aynı testte doğrulandı ✓

## Kabul kriterleri

- [x] KULLANIM-KLAVUZU.md adım adım test edilebilir
- [x] Tüm komutlar gerçek testten geçti
