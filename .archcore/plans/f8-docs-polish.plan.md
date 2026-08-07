---
description: F8 (Dokümantasyon & Polish) — mimari doküman, import'lar, README/CHANGELOG v2.0.0, drawio diyagramlar
status: accepted
approved_by: coruhoorhan (insan)
plan_hash: 2c0032628193f79c16e110a80afac15b667dd902c7ed2468867b02b7b5d861d3
last_approved: 2026-08-07T08:33:28Z
last_review_date: 2026-08-07T08:33:28Z
ttl_days: 90
allowed_paths:
  - .archcore/TEMEL-MIMARI.md
  - AGENTS.md
  - CLAUDE.md
  - README.md
  - CHANGELOG.md
  - docs/architecture.drawio
  - docs/sequence.drawio
  - docs/dataflow.drawio
  - .archcore/plans/f8-docs-polish.plan.md
---

# Plan: f8-docs-polish

## Amaç

F1-F7 katmanlarını dokümante et: mimari dokümanı şablon içine taşı (`.archcore/TEMEL-MIMARI.md`), CLAUDE.md import'ları oluştur, README/CHANGELOG v2.0.0 güncelle, drawio diyagramları ekle.

## Kapsam (değiştirilecek dosyalar)

- `.archcore/TEMEL-MIMARI.md` — YENİ mimari doküman (setup.sh kopyalar; README'deki "projenin dışında" notu kaldırılır)
- `AGENTS.md` — import satırları (`.midas/midas-policy.md`, `.agt/policy.yaml`, `tools/architecture/steiger-rules/`)
- `CLAUDE.md` — YENİ (aynı import yapısı, Claude ajanları için)
- `README.md` — F1-F8 özellik tablosu + diyagram embed + mimari notu düzelt
- `CHANGELOG.md` — YENİ v2.0.0 entry (breaking changes + migration)
- `docs/architecture.drawio` — YENİ (mevcut kaynaktan kopya, `/home/coruho/Music/docs/architecture.drawio`)
- `docs/sequence.drawio` — YENİ (plan onay akışı)
- `docs/dataflow.drawio` — YENİ (hafıza/governance veri akışı)
- `.archcore/plans/f8-docs-polish.plan.md` — bu plan (onay state'i)

## Kapsam DIŞI

- Push/publish
- Workflow değişiklikleri (F7 sonrası dokunulmaz)
- setup.sh davranış değişikliği (yalnız TEMEL-MIMARI referansı dokümantasyon kapsamında)
- Yeni özellik/kod — yalnız dokümantasyon

## Doğrulama (gerçekleştirildi)

1. TEMEL-MIMARI.md mevcut değildi → yeni içerik üretildi (README notu güncellendi) ✓
2. drawio kaynağı mevcut (30KB, geçerli mxfile) → kopyalandı; sequence/dataflow yeni üretildi ✓
3. Drawio XML geçerli (mxfile/mxCell hiyerarşisi) ✓
4. AGENTS.md import'ları gerçek yollara işaret ediyor ✓
5. CHANGELOG v2.0.0: breaking changes + migration ✓

## Kabul kriterleri

- [x] `.archcore/TEMEL-MIMARI.md` şablon içinde yaşar, README "projenin dışında" demez
- [x] `AGENTS.md` + `CLAUDE.md` import'ları: @.midas @.agt @tools
- [x] `README.md` yeni özellikler + diyagram embed
- [x] `CHANGELOG.md` v2.0.0 entry (breaking + migration)
- [x] `docs/*.drawio` (3 diyagram) draw.io ile açılır
