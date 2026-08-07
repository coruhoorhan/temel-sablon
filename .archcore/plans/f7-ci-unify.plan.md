---
description: F7 (CI/CD Unification) — verify.yml birleşik pipeline + matrix + artifact + branch protection
status: accepted
approved_by: coruhoorhan (insan)
plan_hash: 1cd60bbdac79168c0eff162896e75f3d52b0b67df07b6e27c95b250ad9c300d9
last_approved: 2026-08-07T06:03:06Z
last_review_date: 2026-08-07T06:03:06Z
ttl_days: 90
allowed_paths:
  - ".github/workflows/verify.yml"
  - ".github/workflows/ci.yml"
  - "setup.sh"
  - "AGENTS.md"
  - ".archcore/plans/f6-setup-v2.plan.md"
  - ".archcore/plans/f7-ci-unify.plan.md"
  - ".gitignore"
---

# Plan: f7-ci-unify

## Amaç

CI pipeline'ını birleştir: ci.yml → verify.yml (4 job, matrix Node 20/22 × Python 3.11/3.12), artifact upload (AGT/midas/mcpscan), branch protection (gh api).

## Kapsam (değiştirilecek dosyalar)

- `.github/workflows/verify.yml` — YENİ birleşik pipeline (ci.yml süperseti)
- `.github/workflows/ci.yml` — SİLİNİR (verify.yml yerini alır)
- `setup.sh` — T7.4 branch protection (gh api branches/main/protection)
- `AGENTS.md` — F7 bölümü

## Kapsam DIŞI

- Push/publish
- F8 (dokümantasyon)
- Security-* workflow'larının değiştirilmesi (zaten olgun, ayrı kalır)
- supply-chain.yml'nin OSV çakışması (security-sca zaten OSV kullanıyor — not edildi)

## Doğrulama (gerçekleştirildi)

1. verify.yml YAML geçerli (4 job, matrix doğru) ✓
2. Tüm 9 workflow YAML parse ✓
3. CI simülasyonu: typecheck/lint/test/arch:check yeşil ✓
4. plan-gate CI RED yakaladı (F6 allowed_paths eksikti) → düzeltildi, yeniden onaylandı ✓
5. bash -n setup.sh ✓ · dry-run 5 satır ✓

## Kabul kriterleri

- [x] verify.yml tek pipeline: typecheck + lint + test + arch + plan-gate
- [x] Matrix: Node 20/22 × Python 3.11/3.12
- [x] Artifact upload: AGT attestation + midas receipt + mcpscan report
- [x] Branch protection: gh api (pro planı gerekir, fallback mesajı)
- [x] ci.yml silindi, verify.yml onun yerini aldı
