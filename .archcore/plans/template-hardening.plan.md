---
description: Sifirdan patlayanlar — specbind PATH kaliciligi, TDD kapisi, template smoke e2e
status: accepted
title: "template-hardening — Sifirdan kurulum saglamlastirma"
approved_by: Kullanici
plan_hash: 83ed04ff54aee491322ff48e4797e5031f6ceb22d8f5a232660134308ddb8cec
last_approved: 2026-09-11T10:26:55Z
last_review_date: 2026-09-11T10:26:55Z
ttl_days: 90
allowed_paths:
  - setup.sh
  - .archcore/bin/*
  - .archcore/rules/*
  - lefthook.yml
  - .github/workflows/verify.yml
  - .archcore/rules/08-test.rule.md
  - KULLANIM-KLAVUZU.md
  - .archcore/plans/template-hardening.plan.md
---

# Plan: template-hardening

## Bağlam

Taze oturumda patlayanlar: specbind binary /tmp'de ölü, ajan TDD yapmamış,
e2e hiç yok, pre-push/CI denenmemiş. Şablon bunları zorlamadığı için kapıdan
kaçmış. Bu plan makine zorlamasına taşır.

## Çözüm tasarımı

1. setup.sh: specbind kurulumu `$HOME/.local/bin`'e sabitlenir (zaten öyle);
   dizin PATH'te yoksa `~/.bashrc`'ye idempotent export eklenir + receipt'e not.
2. Yeni kapı `verify-tdd-impact.sh`: commit `src/**` üretim dosyasına dokunup
   hiç test dosyasına dokunmuyorsa RED (TDD kaba zorlaması: testle birlikte gel).
   lefthook pre-commit + CI verify.yml'e bağlanır.
3. Yeni `smoke-e2e.sh`: şablonun kendi e2e'si — temp dizin, setup dry-run,
   plan-gate negatif/pozitif, archcore status. CI'de koşar.
4. 08-test kuralı: TDD red-green + kritik akışta e2e (playwright) ALWAYS olur;
   KULLANIM-KLAVUZU'na SORU-fazı notu.

## Etkilenen dosyalar

- [ ] setup.sh (PATH kalıcılığı)
- [ ] .archcore/bin/verify-tdd-impact.sh + smoke-e2e.sh (yeni)
- [ ] lefthook.yml, .github/workflows/verify.yml (kapı bağlantısı)
- [ ] .archcore/rules/08-test.rule.md, KULLANIM-KLAVUZU.md

## Test planı

- Taze /tmp klasöründe setup → specbind yeni kabukta bulunur
- Test koymadan src commit'i RED, testle birlikte OK
- smoke-e2e.sh CI'de yeşil; npm verify + arch:check yeşil

## Geri alma planı

`git revert` (tek commit).

## Riskler

- TDD kapısı kaba: refactor-only commit'lerde false-positive → mesajda
  bypass yolu (plan onayı) belirtilir, kapı fail-closed kalır.
- bashrc'ye yazma ilk kurulumda bir kez, idempotent guard'lı.
