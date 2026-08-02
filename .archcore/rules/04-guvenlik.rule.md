---
description: GÃ¼venlik kurallarÄ± â€” XSS, injection, secret, auth/IDOR, OWASP Agentic
globs: src/**/*.{ts,tsx}
priority: P0
last_review_date: 2026-08-02
ttl_days: 90
---

# 4. GÃ¼venlik

**Kaynak:** eslint-plugin-security 4 Â· @eslint-react Â· gitleaks Â· Semgrep/CodeQL (FAZ 3) Â· verifier
**Zorlama:** makine kurallarÄ± (aÅŸaÄŸÄ±da) + Semgrep + gitleaks + verifier (senaryo maddeleri)

## ALWAYS

### R4-01 Â· no-dangerously-set-innerhtml
**Ne:** innerHTML/insertAdjacentHTML yasak. **Neden:** XSS; ajan kodu bu yolla 1. gÃ¼n delinir.
âŒ `el.innerHTML = userComment`
âœ… `createElement + textContent` veya doÄŸrulanmÄ±ÅŸ sanitizer (DOMPurify) + zorunlu yorum
**Zorlayan:** `@eslint-react/dom/no-dangerously-set-innerhtml` (error)

### R4-02 Â· detect-eval-with-expression
**Ne:** eval/new Function yasak. **Neden:** kod enjeksiyonu.
**Zorlayan:** `security/detect-eval-with-expression` (error)

### R4-03 Â· detect-object-injection
**Ne:** kullanÄ±cÄ± girdisiyle obj[prop] eriÅŸimi yasak. **Neden:** prototype pollution, property injection.
âŒ `user[req.body.key]`
âœ… allowlist: `const KEYS = ['a','b'] as const; if (KEYS.includes(k)) obj[k]`
**Zorlayan:** `security/detect-object-injection` (error)

### R4-04 Â· Secret politikasÄ± (gitleaks + .env kuralÄ±)
**Ne:** hiÃ§bir secret commit'e girmez; `.env*` hiÃ§bir baÄŸlama enjekte edilmez.
**Neden:** key sÄ±zÄ±ntÄ±sÄ± geri dÃ¶ndÃ¼rÃ¼lemez; gitleaks hook + CI yakalar.
**Zorlayan:** gitleaks `detect --staged` (K1) + CI job + ruleset

### R4-05 Â· detect-unsafe-regex + detect-non-literal-fs-filename + detect-possible-timing-attacks + detect-bidi-characters
**Ne:** ReDoS regex, dinamik dosya yolu, timing sÄ±zÄ±ntÄ±sÄ±, bidi yÃ¶n kontrol karakteri yasak.
**Zorlayan:** `security/detect-unsafe-regex` / `detect-non-literal-fs-filename` / `detect-possible-timing-attacks` / `detect-bidi-characters` (error)

## ASK FIRST
- R4-A1: yeni harici URL/redirect â†’ SSRF senaryosu konuÅŸ (Semgrep p/owasp-top-ten FAZ 3)
- R4-A2: auth/IDOR â€” kaynaÄŸa eriÅŸim yetkisi kontrol edildi mi? (verifier zorunlu)
- R4-A3: CSP/headers deÄŸiÅŸikliÄŸi â†’ gÃ¼venlik notu + CHANGELOG

## NEVER
- âŒ `.env` / secret'larÄ± kod iÃ§ine, yorum iÃ§ine, console'a yazma
- âŒ kullanÄ±cÄ± girdisini `URLSearchParams`/SQL/`fetch` URL'ine raw birleÅŸtirme (Semgrep SQLi/SSRF)
- âŒ `dangerouslySetInnerHTML` (R4-01 muafiyeti yok â€” sanitizer bile ASK FIRST'tir)
- âŒ OWASP ASI ihlali: ajan-dÄ±ÅŸÄ± girdiyi prompt'a raw birleÅŸtirme (prompt injection yÃ¼zeyi)

## Verifier maddeleri (C8 OWASP taze bakÄ±ÅŸ)
- V4-1: diff'teki input akÄ±ÅŸÄ± â€” girdi â†’ render/query/redirect zinciri temiz mi?
- V4-2: auth senaryosu â€” kaynaÄŸa sahiplik/rol kontrolÃ¼ var mÄ±? IDOR aÃ§Ä±ÄŸÄ±?
- V4-3: OWASP ASI01-10 â€” LLM girdisi ayrÄ±ÅŸtÄ±rÄ±lÄ±yor mu, trusted boundary var mÄ±?
- V4-4: yeni baÄŸÄ±mlÄ±lÄ±k varsa gÃ¼venilirlik (socket.dev OSV taramasÄ± FAZ 3'te)
