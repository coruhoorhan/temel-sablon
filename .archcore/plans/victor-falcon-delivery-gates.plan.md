---
description: Victor Falcon teslimat is akisi (ship, technical-review, product-review, qa-change, pr-ci) ve mekanik QA/E2E kanit kapisi entegrasyonu
status: accepted
title: "victor-falcon-delivery-gates — Teslimat Disiplini ve Görsel QA Mekanik Kapısı"
approved_by: Kullanici
plan_hash: b2903b5bac89f387ee19cd891417e5cf4784724cfb8b14b105fc9d6ab485f27f
last_approved: 2026-09-11T13:14:14Z
last_review_date: 2026-09-11T13:14:14Z
ttl_days: 90
allowed_paths:
  - package.json
  - package-lock.json
  - playwright.config.ts
  - e2e/smoke.spec.ts
  - eslint.config.mjs
  - lefthook.yml
  - .gitignore
  - AGENTS.md
  - setup.sh
  - .archcore/supply-chain-manifest.txt
  - .archcore/bin/verify-qa-evidence.sh
  - .archcore/bin/ci-watch.sh
  - .agents/skills/ship/SKILL.md
  - .agents/skills/technical-review/SKILL.md
  - .agents/skills/product-review/SKILL.md
  - .agents/skills/qa-change/SKILL.md
  - .agents/skills/pr-ci/SKILL.md
  - .archcore/plans/victor-falcon-delivery-gates.plan.md
---

# Plan: victor-falcon-delivery-gates

## Bağlam
Victor Falcon'un otonom teslimat becerileri (ship, technical-review, product-review, qa-change, pr-ci)
ile TEMEL'in OS/Git seviyesindeki mekanik bariyerleri birlestirilerek eksiksiz bir teslimat motoru olusturuldu.

## Çözüm Tasarımı
1. `@playwright/test` ve `playwright.config.ts` eklenerek UI görsel kanıt ve E2E altyapısı kuruldu.
2. `.archcore/bin/verify-qa-evidence.sh` mekanik kapısı eklenip `lefthook.yml` pre-commit'e bağlandı.
3. Next.js sayfa sınırı (max 75 satır) ve FSD UI katmanı saflık kuralı (UI içinde fetch yasağı) `eslint.config.mjs`'e eklendi.
4. `.agents/skills/` altına `ship`, `technical-review`, `product-review`, `qa-change` ve `pr-ci` becerileri eklendi.
5. `.archcore/bin/ci-watch.sh` GitHub CI log izleyici ve teşhis aracı eklendi.
6. `AGENTS.md` ve `setup.sh` bu yeni yeteneklerle güncellendi.
