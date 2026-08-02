---
description: Güvenlik kuralları — XSS, injection, secret, auth/IDOR, OWASP Agentic
globs: src/**/*.{ts,tsx}
priority: P0
last_review_date: 2026-08-02
ttl_days: 90
---

# 4. Güvenlik

**Kaynak:** eslint-plugin-security 4 · @eslint-react · gitleaks · Semgrep/CodeQL (FAZ 3) · verifier
**Zorlama:** makine kuralları (aşağıda) + Semgrep + gitleaks + verifier (senaryo maddeleri)

## ALWAYS

### R4-01 · no-dangerously-set-innerhtml
**Ne:** innerHTML/insertAdjacentHTML yasak. **Neden:** XSS; ajan kodu bu yolla 1. gün delinir.
❌ `el.innerHTML = userComment`
✅ `createElement + textContent` veya doğrulanmış sanitizer (DOMPurify) + zorunlu yorum
**Zorlayan:** `@eslint-react/dom/no-dangerously-set-innerhtml` (error)

### R4-02 · detect-eval-with-expression
**Ne:** eval/new Function yasak. **Neden:** kod enjeksiyonu.
**Zorlayan:** `security/detect-eval-with-expression` (error)

### R4-03 · detect-object-injection
**Ne:** kullanıcı girdisiyle obj[prop] erişimi yasak. **Neden:** prototype pollution, property injection.
❌ `user[req.body.key]`
✅ allowlist: `const KEYS = ['a','b'] as const; if (KEYS.includes(k)) obj[k]`
**Zorlayan:** `security/detect-object-injection` (error)

### R4-04 · Secret politikası (gitleaks + .env kuralı)
**Ne:** hiçbir secret commit'e girmez; `.env*` hiçbir bağlama enjekte edilmez.
**Neden:** key sızıntısı geri döndürülemez; gitleaks hook + CI yakalar.
**Zorlayan:** gitleaks `detect --staged` (K1) + CI job + ruleset

### R4-05 · detect-unsafe-regex + detect-non-literal-fs-filename + detect-possible-timing-attacks + detect-bidi-characters
**Ne:** ReDoS regex, dinamik dosya yolu, timing sızıntısı, bidi yön kontrol karakteri yasak.
**Zorlayan:** `security/detect-unsafe-regex` / `detect-non-literal-fs-filename` / `detect-possible-timing-attacks` / `detect-bidi-characters` (error)

## ASK FIRST
- R4-A1: yeni harici URL/redirect → SSRF senaryosu konuş (Semgrep p/owasp-top-ten FAZ 3)
- R4-A2: auth/IDOR — kaynağa erişim yetkisi kontrol edildi mi? (verifier zorunlu)
- R4-A3: CSP/headers değişikliği → güvenlik notu + CHANGELOG

## NEVER
- ❌ `.env` / secret'ları kod içine, yorum içine, console'a yazma
- ❌ kullanıcı girdisini `URLSearchParams`/SQL/`fetch` URL'ine raw birleştirme (Semgrep SQLi/SSRF)
- ❌ `dangerouslySetInnerHTML` (R4-01 muafiyeti yok — sanitizer bile ASK FIRST'tir)
- ❌ OWASP ASI ihlali: ajan-dışı girdiyi prompt'a raw birleştirme (prompt injection yüzeyi)

## Verifier maddeleri (C8 OWASP taze bakış)
- V4-1: diff'teki input akışı — girdi → render/query/redirect zinciri temiz mi?
- V4-2: auth senaryosu — kaynağa sahiplik/rol kontrolü var mı? IDOR açığı?
- V4-3: OWASP ASI01-10 — LLM girdisi ayrıştırılıyor mu, trusted boundary var mı?
- V4-4: yeni bağımlılık varsa güvenilirlik (socket.dev OSV taraması FAZ 3'te)
