---
description: F1-F5 plan dosyalarına allowed_paths ekleme — plan-gate scope kontrolü için geriye dönük düzeltme
status: accepted
approved_by: coruhoorhan (insan)
plan_hash: c46d8743705f87422900587238d83e23f6f89416de2a4fa474fed63c1664f2c1
last_approved: 2026-08-10T05:47:04Z
last_review_date: 2026-08-10T05:47:04Z
ttl_days: 90
allowed_paths:
  - .archcore/plans/f1-f2-midas-agt.plan.md
  - .archcore/plans/f3-mcp-security.plan.md
  - .archcore/plans/f4-steiger-plugin.plan.md
  - .archcore/plans/f5-agent-mesh.plan.md
  - .archcore/plans/f1-f5-plan-fix.plan.md
---

# Plan: f1-f5-plan-fix

## Amaç

F1-F5 plan dosyalarının frontmatter'ında `allowed_paths` yoktu → toplu `verify-pr`
(origin/main..HEAD) her dosyayı "plan scope'u dışında" sayıp 37 ihlal üretiyordu.
Her plan dosyasına, o planla commit'lenen gerçek dosya setini `allowed_paths` olarak
ekle ve yeniden onayla (hash kırıldı → yeniden onay şart).

## Kapsam (değiştirilecek dosyalar)

- `.archcore/plans/f1-f2-midas-agt.plan.md` — allowed_paths eklendi (12 dosya: .agt/.midas/workflows/AGENTS.md/lefthook/setup.sh)
- `.archcore/plans/f3-mcp-security.plan.md` — allowed_paths eklendi (9 dosya)
- `.archcore/plans/f4-steiger-plugin.plan.md` — allowed_paths eklendi (6 dosya)
- `.archcore/plans/f5-agent-mesh.plan.md` — allowed_paths eklendi (9 dosya)
- `.archcore/plans/f1-f5-plan-fix.plan.md` — bu plan (onay state'i)

## Kapsam DIŞI

- Kod değişikliği (yalnız plan frontmatter)
- F6-F8 planları (allowed_paths zaten var)
- Push (ayrı adım)

## Doğrulama (gerçekleştirildi)

1. 4 plan dosyasına allowed_paths eklendi ✓
2. 4 plan yeniden onaylandı — hash'ler tutarlı ✓
3. verify-pr toplu: 0 ihlal (hedef) ✓

## Kabul kriterleri

- [x] Tüm F1-F5 planları `allowed_paths` içerir
- [x] Hash'ler manuel hesaplamayla eşleşir
- [x] `verify-pr origin/main HEAD` → 0 ihlal
