---
description: Victor Falcon sentry-issues, sentry-logs ve delegate becerileri ile otonom self-healing altyapisi
status: accepted
title: "sentry-self-healing-skills — Sentry Otonom Onarim ve Telemetri Becerileri"
approved_by: Kullanici
plan_hash: 3c8725a7dbc1f0277e8894138c0cbc68090daeb03e91e93fd50aeceaf0036ef4
last_approved: 2026-09-11T13:27:26Z
last_review_date: 2026-09-11T13:27:26Z
ttl_days: 90
allowed_paths:
  - .agents/skills/sentry-issues/SKILL.md
  - .agents/skills/sentry-logs/SKILL.md
  - .agents/skills/delegate/SKILL.md
  - .archcore/bin/sentry-fetch.sh
  - .archcore/plans/sentry-self-healing-skills.plan.md
---

# Plan: sentry-self-healing-skills

## Bağlam
Victor Falcon'un Sentry ile otonom hata yakalama ve kendi kendini onarma (self-healing)
becerileri (sentry-issues, sentry-logs, delegate) TEMEL şablonuna dahil edildi.

## Çözüm Tasarımı
1. `.agents/skills/sentry-issues/SKILL.md` eklenerek canlı Sentry hatalarını TDD ile yakalayıp /ship üzerinden otonom PR açan döngü kuruldu.
2. `.agents/skills/sentry-logs/SKILL.md` eklenerek telemetri ve hata sıklığı izleme becerisi eklendi.
3. `.agents/skills/delegate/SKILL.md` Git worktree tabanlı izole alt-ajan dağıtımına uyarlandı.
4. `.archcore/bin/sentry-fetch.sh` CLI aracı eklenerek Sentry API sorguları ve mock test altyapısı bağlandı.
