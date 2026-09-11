---
description: Mekanik barikatlar — post-commit anti-bypass, local allowed_paths scope kontrolu, steiger fast-arch, tdd-impact ve eslint hardening
status: accepted
title: "mechanical-gates — Agent Evasion ve Mekanik Kapi Saglamlastirma"
approved_by: Kullanici
plan_hash: 4e0c3cf6863c120bad098bdb58530f3abb57a4fa3444b930b8d7c912618fec8c
last_approved: 2026-09-11T12:21:58Z
last_review_date: 2026-09-11T12:21:58Z
ttl_days: 90
allowed_paths:
  - setup.sh
  - lefthook.yml
  - eslint.config.mjs
  - AGENTS.md
  - .archcore/bin/*
  - tools/architecture/src/steiger-rules/*
  - .archcore/plans/mechanical-gates.plan.md
---

# Plan: mechanical-gates

## Bağlam
Yapay zeka ajanlarının sözlü prompt kurallarını (`max-lines: 150`, FSD katman hiyerarşisi, plan onayı, TDD)
ihlal etmesini engellemek için yerel Git hook'ları ve işletim sistemi düzeyinde mekanik kapılar kurulmuştur.
Ajanın `--no-verify` ile kaçması, izin verilmeyen dosyaları değiştirmesi ve FSD ihlalleri yapması fiziksel olarak engellenir.

## Çözüm Tasarımı
1. `post-commit` anti-bypass: `git commit --no-verify` ile atılan kuralsız commit'ler `verify-post-commit` tarafından yakalanıp anında `git reset --soft HEAD~1` ile geri alınır.
2. `verify-commit-msg` ve `verify-push` scope kontrolü: Staged dosyalar ve push commit diff'leri planın `allowed_paths` alanına karşı sıkı denetlenir. Kapsam dışı dosya varsa işlem durdurulur.
3. `lefthook.yml` pre-commit ve pre-push: `fast-arch` (steiger) pre-commit'e, `arch-check` pre-push'a eklenir.
4. `tools/architecture/src/steiger-rules/index.js`: `@/` ve `~/` path alias'ları ile re-export ve dinamik importlar kapsama alınır.
5. `verify-tdd-impact.sh`: `*.spec.*` ve `test/**` desteklenir; sadece üretim kodları (`.ts`, `.tsx`) için test şartı aranır.
6. `eslint.config.mjs`: `reducers/**` klasör muafiyeti daraltılır.
7. `setup.sh`: Yeni kurulan her projede `post-commit` ve anti-bypass testi devreye alınır.

## Etkilenen Dosyalar
- [x] .archcore/bin/verify-commit-msg
- [x] .archcore/bin/verify-push
- [x] .archcore/bin/verify-pr
- [x] .archcore/bin/verify-tdd-impact.sh
- [x] .archcore/bin/verify-post-commit
- [x] tools/architecture/src/steiger-rules/index.js
- [x] lefthook.yml
- [x] eslint.config.mjs
- [x] setup.sh
- [x] AGENTS.md
- [x] .archcore/plans/mechanical-gates.plan.md
