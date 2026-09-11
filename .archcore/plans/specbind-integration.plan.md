---
description: SpecBind entegrasyonu — lifecycle + skill kurulumu, commit kapısı köprüsü, setup binary adımı
status: accepted
title: "specbind-integration — SpecBind entegrasyonu"
approved_by: Kullanici
plan_hash: 41585f5a36e460fc0cf8be175092b9ebb1709a68831f602b4ca8de251a0241f4
last_approved: 2026-09-11T08:10:01Z
last_review_date: 2026-09-11T08:10:01Z
ttl_days: 90
allowed_paths:
  - .specbind.json
  - .specbind/*
  - .agents/skills/sb-*
  - AGENTS.md
  - setup.sh
  - KULLANIM-KLAVUZU.md
  - .archcore/plans/specbind-integration.plan.md
---

# Plan: specbind-integration

## Bağlam

SpecBind (Huruikagi/specbind v1.5.1, Rust CLI + 15 skill) kum havuzunda denendi:
`install` 55 create / 0 replace üretiyor, dosya çakışması yok. Eksik parçalarımız
(roadmap/milestone, contract-review, invalidation, sb-adopt) buradan gelir.
Kritik uyum noktası: SpecBind checkpoint commit'leri bizim `plan:` trailer
zorunluluğuna takılır — köprü şart.

## Çözüm tasarımı

1. `specbind install --agent generic --language en --project-instructions`
   (adoption skill'siz; `.specbind/` + 15 `sb-*` skill + AGENTS.md marked block).
2. Köprü: project-owned `.specbind/settings/adapters/git.md`'ye kural —
   bu repodaki her SpecBind checkpoint'i `plan: <aktif-plan>` trailer'ı taşır;
   her milestone'a karşılık bir `.archcore` planı açılır. Commit kapısı değişmez.
3. Yön kuralı (KULLANIM-KLAVUZU'na bölüm): discovery/plan/implement specbind'le,
   commit/push plan-gate'ten geçer; çakışmada plan-gate üstündür.
4. `setup.sh`: specbind binary adımı (resmi install.sh, SHA doğrulamalı;
   indirilemezse warn — offline kurulum çalışır) + receipt'e 6. tool.
5. Binary `mise` ile pinlenir (sürüm kilidi).

## Etkilenen dosyalar

- [ ] .specbind.json + .specbind/* (yeni)
- [ ] .agents/skills/sb-* (yeni, 15 skill)
- [ ] AGENTS.md (marked block append)
- [ ] setup.sh, KULLANIM-KLAVUZU.md (düzenle)

## Test planı

- `specbind milestone status` sandbox'ta hatasız açılır
- Checkpoint commit denemesi plan-gate'ten geçer (trailer köprüsü)
- `npm run verify`, `arch:check`, `archcore status`, plan-gate negatif/pozitif
- Taze klasör kurulumu → KURULUM BAŞARILI (specbind adımı dahil)

## Geri alma planı

`git revert` + `specbind uninstall` (tek commit; skill'ler product-managed).

## Riskler

- 3-star binary'de kırıcı değişiklik → mise pin + adapter'lar project-owned kalır.
- İki state machine ajanları şaşırtabilir → yön kuralı KULLANIM-KLAVUZU'nda.
- Plugin opencode'da yok; entegrasyon MCP/skill üzerinden, plugin değil.
