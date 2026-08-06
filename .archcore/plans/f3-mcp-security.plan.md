---
description: F3 (MCP Security Gateway + MCPScan + supply chain) — MCP server güvenliği katmanı
status: accepted
approved_by: coruhoorhan (insan)
plan_hash: 401f1c324aa53fff283d78d644cc225a1950023ff1a0316db9fb682c9136a611
last_approved: 2026-08-06T07:47:31Z
last_review_date: 2026-08-06T07:47:31Z
ttl_days: 90
---

# Plan: f3-mcp-security

## Amaç

TEMEL şablonuna MCP güvenlik katmanı ekler:
1. **T3.1** `.mcp.json.template` — MCP server kayıtları (midas + remote şablon)
2. **T3.2** `mcpscan.yml` — client config taraması CI kapısı (high+ = fail)
3. **T3.3** `.agt/mcp-gateway.yaml.template` — AGT MCP Security Gateway (spec v1.0)
4. **T3.4** `supply-chain.yml` — SHA-256 manifest + OSV CVE taraması

## Kapsam (değiştirilecek dosyalar)

- `setup.sh` — `wire_mcp()` fonksiyonu (config üretimi + tarama + supply chain)
- `.mcp.json.template` — MCP server kayıtları
- `.agt/mcp-gateway.yaml.template` — gateway config (tool interception, response scan, signing, session, rate limit, CVE, trust)
- `.github/workflows/mcpscan.yml` — client config + primitives taraması
- `.github/workflows/supply-chain.yml` — SHA-256 + OSV
- `.gitignore` — .mcp.json + .agt/mcp-gateway.yaml
- `AGENTS.md` — MCP Güvenliği (F3) bölümü

## Kapsam DIŞI

- Push/publish (local commit yalnız)
- F4-F8 fazları
- Uzaktan MCP server gerçek bağlantısı (template placeholder)

## Doğrulama (gerçekleştirildi)

1. `bash -n setup.sh` — syntax ✓
2. mcpscan: `--fail-on high` → 0 high, exit 0 ✓
3. AGT mcp-scan: `No threats detected` ✓ (kritik bulgu: config positional argüman, python3.12 gerekli)
4. Supply chain manifest hash eşleşmesi ✓
5. Tüm workflow YAML'ları geçerli (8 workflow) ✓
6. npm verify regresyon ✓

## Kabul kriterleri

- [x] .mcp.json.template JSON geçerli, gateway YAML geçerli
- [x] mcpscan high+ bulgu = exit 1 (CI blocking)
- [x] AGT mcp-scan primitives taraması çalışıyor
- [x] Supply chain manifest üretiliyor ve doğrulanıyor
- [x] Üretilen config'ler commit'e girmez (gitignore)
