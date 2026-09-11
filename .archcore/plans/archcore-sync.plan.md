---
title: "Plan: archcore-sync"
description: archcore CLI ile tam senkron — status 0 issue, MCP wiring, setup gate
status: accepted
approved_by: Kullanici
plan_hash: 4b45f9f7b9c2fad467c07236fe76647e6174df018e3d11c15e598bc3941351be
last_approved: 2026-09-11T07:17:04Z
last_review_date: 2026-09-11T07:17:04Z
ttl_days: 90
allowed_paths:
  - setup.sh
  - opencode.json
  - README.md
  - CLAUDE.md
  - CHANGELOG.md
  - KULLANIM-KLAVUZU.md
  - .archcore/plans/*
  - .archcore/rules/*
  - .archcore/temel-mimari.doc.md
  - .archcore/TEMEL-MIMARI.md
  - .archcore/drift.md
  - .archcore/drift-guide.guide.md
  - .archcore/templates/*
  - .archcore/settings.json
  - .archcore/plans/archcore-sync.plan.md
---

# Plan: archcore-sync

## Bağlam

`archcore status` bu repoda 45 issue buluyor: dosya adı ihlalleri (TEMEL-MIMARI.md,
drift.md, plans/README.md), eksik `title`/`status` frontmatter'ı (19 plan + 11 kural),
11-hafiza.rule.md'de bozuk YAML. Ayrıca `opencode.json`'da archcore MCP `enabled: false`.
CLI kuralları kodda sabit (internal/docs + cmd/status.go) — gevşetme ayarı yok, dosyalar uyar.

## Çözüm tasarımı

1. Rename (slug lowercase + geçerli tip): TEMEL-MIMARI.md → temel-mimari.doc.md,
   drift.md → drift-guide.guide.md, plans/README.md → plans-guide.guide.md.
   Referanslar güncellenir (README, CLAUDE, CHANGELOG, KULLANIM-KLAVUZU,
   11-hafiza.rule.md, opencode.json instructions).
2. Frontmatter: tüm planlara `title`, tüm kurallara `title` + `status: accepted`,
   11-hafiza description tırnaklanır. Plan şablonuna `title` eklenir (gelecek planlar yeşil).
3. Düzenlenen accepted planların `plan_hash`i yeniden hesaplanır (re-onay bu planın
   onayıyla kapsanır — liste raporda).
4. opencode.json: archcore MCP `enabled: true` (JSON-RPC smoke test) + instructions yolu güncellenir.
5. setup.sh DOĞRULAMA'ya `archcore status` kapısı eklenir (CLI yoksa warn, kırmızıysa fail).
6. Plugin: opencode desteklenen host değil (claude/cursor/codex/copilot) — N/A raporlanır.

## Etkilenen dosyalar

- [ ] .archcore rename ×3 + frontmatter (plan ×19, kural ×11, şablon)
- [ ] setup.sh, opencode.json, README.md, CLAUDE.md, CHANGELOG.md, KULLANIM-KLAVUZU.md

## Test planı

- `archcore status` → 0 issue; `archcore doctor` temiz
- `archcore mcp` JSON-RPC initialize yanıtı
- `npm run verify`, `arch:check`, `bash -n setup.sh`, plan-gate negatif/pozitif
- Taze klasör kurulumu → KURULUM BAŞARILI (archcore kapısı dahil)

## Geri alma planı

`git revert` (tek commit) — rename'ler git mv ile izlenebilir.

## Riskler

- Accepted planlara dokunuş hash kırar → aynı committe hash tazelenir, liste kullanıcıya raporlanır.
- `archcore status` gelecek CLI sürümünde kural değiştirirse kapı kızarır (pin yok).
