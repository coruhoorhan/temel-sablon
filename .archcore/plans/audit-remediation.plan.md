---
description: Audit remediation — fail-closed security, plan-gate parity, setup correctness
status: accepted
approved_by: Kullanici
plan_hash: 123989c6defa99b76240175256482610579c80b823876edd635c55a486601ebf
last_approved: 2026-08-13T13:25:12Z
last_review_date: 2026-08-13T13:25:12Z
ttl_days: 90
allowed_paths:
  - .github/workflows/verify.yml
  - .github/workflows/agt-verify.yml
  - .github/workflows/mcpscan.yml
  - .github/workflows/midas.yml
  - .github/workflows/security-sca.yml
  - .github/workflows/security-container.yml
  - .github/workflows/supply-chain.yml
  - setup.sh
  - package.json
  - package-lock.json
  - .archcore/supply-chain-manifest.txt
  - AGENTS.md
  - .archcore/bin/verify-commit-msg
  - .archcore/bin/verify-push
  - .archcore/bin/verify-pr
  - .archcore/plans/audit-remediation.plan.md
  - KULLANIM-KLAVUZU.md
  - README.md
  - CHANGELOG.md
---

# Plan: audit-remediation

## Amaç

Audit sırasında bulunan fail-open güvenlik kapılarını, eksik gerçek-config taramalarını,
plan-gate eşitsizliklerini ve setup.sh'nin yanlış başarı raporlamasını düzeltmek.

## Kararlar

1. HIGH/CRITICAL güvenlik bulguları CI'ı kırar; güvenlik taramaları `continue-on-error` ile
   başarıya dönemez.
2. CI önce template'lerden gerçek ignored config'leri üretir ve taramalar gerçek config'i
   kullanır.
3. `verify-pr`, `verify-push` ve `verify-commit-msg` aynı zorunlu plan alanlarını ister:
   accepted status, boş olmayan insan `approved_by`, dolu `plan_hash` ve en az bir
   `allowed_paths` girdisi.
4. OSV custom sorgusu package-lock içindeki tüm `node_modules/` paketlerini doğru
   `querybatch` şemasıyla sorgular; ağ veya API hatası kırmızı sonuçtur.
5. setup.sh bir güvenlik veya doğrulama adımı başarısız olduğunda sıfır çıkış kodu vermez.

## Doğrulama

- `npm run verify`
- `npm run arch:check`
- `bash -n setup.sh .archcore/bin/*.sh`
- Tüm workflow YAML parse kontrolü
- Plan-gate negatif ve pozitif senaryoları
- GitHub branch protection ve required checks API doğrulaması
