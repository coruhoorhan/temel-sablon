---
description: F6 (setup.sh v2) — full wiring + receipt + dry-run + GitHub secrets/environments
status: accepted
approved_by: coruhoorhan (insan)
plan_hash: 0890234e3ed61375fd88568fb8ab56687e200f9e712e36761bc24c585190bb48
last_approved: 2026-08-07T06:05:32Z
last_review_date: 2026-08-07T06:05:32Z
ttl_days: 90
allowed_paths:
  - setup.sh
  - .gitignore
  - .archcore/plans/f6-setup-v2.plan.md
  - AGENTS.md
  - .github/workflows/**
---

# Plan: f6-setup-v2

## Amaç

setup.sh'i v2'ye taşı: `--dry-run`/`--help` desteği, `setup-receipt.json` üretimi, `wire_steiger` fonksiyonu, GitHub environment + secrets.

## Kapsam (değiştirilecek dosyalar)

- `setup.sh` — CLI argümanları (--dry-run/--help), receipt altyapısı, wire_steiger, GitHub env/secrets, receipt_write
- `.gitignore` — setup-receipt.json
- `AGENTS.md` — setup v2 bölümü (dokümantasyon)

## Kapsam DIŞI

- Push/publish
- F7 (CI birleştirme), F8 (dokümantasyon)
- Gerçek GitHub secret değerleri (elle set edilir)

## Doğrulama (gerçekleştirildi)

1. `bash -n setup.sh` syntax ✓
2. `--help` çalışıyor ✓
3. `--dry-run`: 5 tool "planned" statüsüyle receipt'e yazıldı, hiçbir kurulum yapılmadı ✓
4. Tam kurulum: 5 tool "ok" statüsü, tüm kapılar yeşil (plan-gate reddi dahil) ✓
5. Receipt JSON şeması doğru (tool/version/status/config/detail) ✓
6. npm verify + arch:check regresyon ✓

## Kabul kriterleri

- [x] setup.sh modüler (5 wire fonksiyonu, her biri bağımsız)
- [x] --dry-run hiçbir şey kurmuyor, plan gösteriyor
- [x] setup-receipt.json {tool, version, status, config, detail, timestamp} üretiyor
- [x] Kapı testleri (agt/midas/steiger/mcpscan/arch:check) receipt'e yazılıyor
- [x] GitHub repo + environment + secrets otomasyonu (gh CLI)
