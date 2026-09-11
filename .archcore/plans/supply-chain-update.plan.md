---
description: Supply chain manifest guncellemesi — @vitest/eslint-plugin sonrasi package-lock.json SHA-256 senkronu
status: accepted
title: "supply-chain-update — Lockfile SHA-256 Senkronu"
approved_by: Kullanici
plan_hash: cd22ed55339d647c0bdeacb8ca59b6180bc64d9fad46167f84743fb6f6d6d2bd
last_approved: 2026-09-11T12:29:54Z
last_review_date: 2026-09-11T12:29:54Z
ttl_days: 90
allowed_paths:
  - .archcore/supply-chain-manifest.txt
  - .archcore/plans/supply-chain-update.plan.md
---

# Plan: supply-chain-update

## Bağlam
@vitest/eslint-plugin eklendikten sonra package-lock.json SHA-256 hash'i güncellendi.
Supply chain kapısının (setup.sh ve CI supply-chain.yml) yeşil kalması için
.archcore/supply-chain-manifest.txt dosyası yeni hash ile eşitlendi.

## Etkilenen Dosyalar
- [x] .archcore/supply-chain-manifest.txt
- [x] .archcore/plans/supply-chain-update.plan.md
