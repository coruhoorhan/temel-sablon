---
description: setup.sh midas receipt sıralama hatası — tmp temizliği doğrulamadan önce receipt'i siliyor
status: accepted
approved_by: Kullanici
plan_hash: 3ebecaf451404551ee2a3d18f2be14275388a437b14102d12d3fdef4727b337e
last_approved: 2026-09-11T07:08:52Z
last_review_date: 2026-09-11T07:08:52Z
ttl_days: 90
allowed_paths:
  - setup.sh
  - .archcore/plans/setup-receipt-fix.plan.md
---

# Plan: setup-receipt-fix

## Amaç

Boş klasörde uçtan uca denemede bulunan gerçek bug: `setup.sh` %95 yeşil koşup finalde
hep `SETUP_EXIT:1` veriyor — `midas wiring receipt yok`. Sebep sıralama hatası:
satır 715 `rm -rf .archcore/tmp` (kapı testi temizliği), satır 172'de üretilen
`midas-receipt.json`'ı siliyor; satır 733 `tee` dizin yokken patlıyor, satır 739
receipt kontrolü kırmızıya düşüyor. Sonuç: `KURULUM BAŞARILI` hiç basılmıyor.

## Kararlar

1. Temizlik yalnızca test artığını siler (`setup-test.txt`), receipt'i ve dizini yaşatır.
2. Doğrulama adımı kendi dizinini garantiler (`mkdir -p` — idempotent script zaten).
3. Davranış değişikliği yok: plansız commit testi, verify, arch:check, drift, gitleaks aynen kalır.

## Doğrulama

- `bash -n setup.sh`
- Taze `/tmp` klasöründe `TEMPLATE_SRC=<repo> bash setup.sh` → `SETUP_EXIT:0` + `KURULUM BAŞARILI`
- `setup-receipt.json`: 5 tool `ok`, `dry_run:0`
- Plan-gate negatif (`plan:` yok → RED) + pozitif (`plan: setup-receipt-fix` → OK)
- Fix commit'i: `plan: setup-receipt-fix` trailer + `allowed_paths` scope uyumu
