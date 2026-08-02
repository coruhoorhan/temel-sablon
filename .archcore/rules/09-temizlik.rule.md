---
description: Temizlik kurallarÄ± â€” format, dosya boyutu, commit disiplini, Ã¶lÃ¼ kod, TODO yasaÄŸÄ±
globs: src/**/*.{ts,tsx}
priority: P1
last_review_date: 2026-08-02
ttl_days: 90
---

# 9. Temizlik

**Kaynak:** Prettier/Biome 2.4 Â· sonarjs Â· commitlint Â· knip Â· kural dokÃ¼manÄ±
**Zorlama:** makine kurallarÄ± + verifier (boyut niyeti, TODO denetimi)

## ALWAYS

### R9-01 Â· Dosya â‰¤150 etkin satÄ±r
**Ne:** Ã¼retim dosyasÄ± 150 etkin satÄ±rÄ± aÅŸamaz (skipBlankLines + skipComments â€” yorum/boÅŸlukla ÅŸiÅŸirme yok).
**Neden:** ajan doÄŸruluÄŸu kÄ±sa dosyada %83â†’%89 (arXiv 2603.20432); shadcn/ui medyan 59.5 satÄ±r.
**Zorlayan:** ESLint `max-lines` (FAZ 1): `src/**/*.{ts,tsx}` max 150, skipBlank+skipComments
**Muaf:** `*.test.*` `*.spec.*` `__tests__` `*.stories.*` `fixtures/**` `mocks/**` + machine/reducer (ikinci grup 400)
**AÅŸarsa:** FSD segmentlerine bÃ¶l (ui/ alt-component, model/ hook, lib/ saf fonksiyon, api/ istek)

### R9-02 Â· Format determinizmi
**Ne:** format tek araÃ§, tek config (Prettier 3/Biome); lint-format ayrÄ±lmaz.
**Zorlayan:** Prettier/Biome check (K1 hook + CI)

### R9-03 Â· no-duplicate-string
**Ne:** aynÄ± string 3+ kez tekrar etmez. **Neden:** kopya = gÃ¼ncelleme kaÃ§Ä±rma bug'Ä±.
**Zorlayan:** `sonarjs/no-duplicate-string` (error)

### R9-04 Â· prefer-immediate-return + no-inverted-boolean-check
**Ne:** gereksiz deÄŸiÅŸken atama ve ters koÅŸul okunabilirliÄŸi. **Zorlayan:** `sonarjs/prefer-immediate-return` + `no-inverted-boolean-check` (error)

### R9-05 Â· TODO yasaÄŸÄ±
**Ne:** `TODO/FIXME/HACK` commit'e girmez; iÅŸ ticket'a/plan dosyasÄ±na gider.
**Neden:** TODO'lar unutulur, plan sistemi var â€” oraya yaz.
**Zorlayan:** verifier (V9-1) + grep kuralÄ± (K1 hook: `grep -rn 'TODO\|FIXME' src --exclude-dir=node_modules`)

### R9-06 Â· Conventional commit + plan trailer
**Ne:** `type(scope): subject` + `plan: <id>` trailer'Ä± zorunlu. **Neden:** geÃ§miÅŸ otomatik okunur; onay kapÄ±sÄ± trailer'Ä± okur.
âœ… `feat(auth): add refresh token rotation\n\nplan: auth-refresh-tokens`
**Zorlayan:** commitlint (K1) + `.archcore/bin/verify-commit-msg` (plan kapÄ±sÄ±)

### R9-07 Â· Atomik commit
**Ne:** tek commit = tek mantÄ±ksal deÄŸiÅŸiklik (â‰¤300 satÄ±r diff). **Neden:** bÃ¼yÃ¼k diff verifier'Ä± atlar (K1 eÅŸiÄŸi), geri alma zorlaÅŸÄ±r.
**Zorlayan:** verifier (V9-2) + K1 "diff'i bÃ¶l" uyarÄ±sÄ±

## ASK FIRST
- R9-A1: 150'yi aÅŸma eÅŸiÄŸinde â†’ bÃ¶lme planÄ± konuÅŸ, disable deÄŸil
- R9-A2: inline disable (eslint) â†’ gerekÃ§eli yorum ÅŸart, aylÄ±k denetim

## NEVER
- âŒ TODO/FIXME/HACK komiteleri
- âŒ gizli kod yorumlarÄ± ("burada ne yapÄ±yorduk?") â€” sil ya da belgele
- âŒ `console.log` Ã¼retim kodu (dev-only; loglama altyapÄ±sÄ± kullan)
- âŒ kullanÄ±lmayan import/export (knip + no-unused-vars)

## Verifier maddeleri
- V9-1: TODO/yorum kalÄ±ntÄ±sÄ± + gerekÃ§esiz disable var mÄ±?
- V9-2: diff kapsamÄ± â€” tek sorumluluk mu? iliÅŸkisiz deÄŸiÅŸiklik karÄ±ÅŸmÄ±ÅŸ mÄ±? (C3/C9)
