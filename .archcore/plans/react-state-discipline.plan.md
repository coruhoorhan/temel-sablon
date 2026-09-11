---
description: React Hooks ve State mekanik disiplini — rules-of-hooks, exhaustive-deps, set-state-in-effect ve purity kurallarinin ESLint 10 entegrasyonu
status: accepted
title: "react-state-discipline — State ve React Hooks Mekanik Kilidi"
approved_by: Kullanici
plan_hash: 565a33f369ff3b6ed5842e1d21a504ce074314df1732dec86526ebdbc8fe7ada
last_approved: 2026-09-11T12:44:31Z
last_review_date: 2026-09-11T12:44:31Z
ttl_days: 90
allowed_paths:
  - package.json
  - package-lock.json
  - eslint.config.mjs
  - .archcore/supply-chain-manifest.txt
  - .archcore/plans/react-state-discipline.plan.md
---

# Plan: react-state-discipline

## Bağlam
03-state.rule.md içinde vaat edilen fakat daha önce ertelenmiş olan React Hooks disiplini
(rules-of-hooks, exhaustive-deps, set-state-in-effect, immutability, purity),
eslint-plugin-react-hooks ile doğrudan ESLint 10 konfigürasyonuna bağlandı.

## Çözüm Tasarımı
1. `eslint-plugin-react-hooks` kuruldu ve `eslint.config.mjs` içine eklendi.
2. `rules-of-hooks`, `exhaustive-deps`, `set-state-in-effect`, `set-state-in-render`, `immutability`, `purity` kuralları P0 (error) olarak zorlandı.
3. Supply chain manifest SHA-256 hash'i eşitlendi.

## Etkilenen Dosyalar
- [x] package.json
- [x] package-lock.json
- [x] eslint.config.mjs
- [x] .archcore/supply-chain-manifest.txt
- [x] .archcore/plans/react-state-discipline.plan.md
---
