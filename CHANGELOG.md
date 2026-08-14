# Changelog

## [Unreleased] — audit remediation

- Security SCA ve Trivy workflow'ları fail-closed yapıldı.
- OSV dependency sorgusu lockfile'daki tüm `node_modules/` paketlerini tarıyor.
- MCP taramaları template yerine kurulumda üretilen gerçek config'i kullanıyor.
- AGT prompt defense minimum C, policy ve fixture kontrolleri zorunlu hâle getirildi.
- Plan-gate katmanları `approved_by`, `plan_hash` ve `allowed_paths` alanlarını eşit biçimde zorluyor.
- `setup.sh` güvenlik/doğrulama hatalarını başarı olarak raporlamıyor.
- Branch protection'da solo-repo tuzağı düzeltildi: `required_pull_request_reviews`
  yalnız collaborator sayısı 1'den büyükse eklenir (yazar kendi PR'ını onaylayamaz).

Tüm önemli değişiklikler bu dosyada. Format: [Keep a Changelog](https://keepachangelog.com/tr/1.1.0/),
sürümleme: [Semantic Versioning](https://semver.org/).

## [v2.0.0] — 2026-08-07

### Breaking Changes

- **`ci.yml` kaldırıldı → `verify.yml` birleşik pipeline** (F7). Tek workflow:
  typecheck + lint + test + arch + plan-gate + AGT + Midas + mcpscan. CI status
  kontrolünüz varsa check adını `ci` yerine `verify` yapın.
- **`AGENTS.md` import yapısı değişti** (F8): `@.midas/midas-policy.md`,
  `@.agt/policy.yaml`, `@tools/architecture/src/steiger-rules/` artık oturum başında
  yüklenir. Eski doğrudan kural bağlantıları kaldırılmadı ama import'lar önceliklidir.
- **`CLAUDE.md` eklendi** (F8) — Claude Code ortamları için köprü. Yalnızca AGENTS.md
  okuyan ajanlar için zorunlu değil ama önerilir.
- **`TEMEL-MIMARI.md` taşındı** (F8): repo kökündeki referans kaldırıldı; doküman artık
  `.archcore/TEMEL-MIMARI.md` içinde yaşar ve `setup.sh` yeni projelere kopyalar.
- **Branch protection required checks** (F7): `verify` + `security-*` + `agent-mesh`
  — eski tek `ci` check'i artık geçerli değil.

### Added

- **F1 (Midas hafıza):** `.midas/config.yaml.template`, `midas-policy.md`,
  `.github/workflows/midas.yml` (salt-okunur auditor).
- **F2 (AGT governance):** `.agt/policy.yaml.template` (ACS şema), 6 policy fixture,
  `.agt/manifest.yaml.template`, `.github/workflows/agt-verify.yml` (OWASP ASI 10/10).
- **F3 (MCP güvenliği):** `.mcp.json.template`, `.agt/mcp-gateway.yaml.template`,
  `.github/workflows/mcpscan.yml` + `supply-chain.yml`, `.archcore/supply-chain-manifest.txt`.
- **F4 (Steiger plugin):** `tools/architecture/src/steiger-rules/` —
  `temel/no-upward-import` (FSD katman sızıntısı zorlaması), `steiger.config.js`,
  `tools/architecture/scripts/check-arch.sh`.
- **F5 (Agent Mesh):** `trust_mesh` + `shadow_discovery` manifest, `.archcore/bin/audit-chain.py`,
  `shadow-discovery.py`, `gov-dashboard.py`, `.github/workflows/agent-mesh.yml`.
- **F6 (setup v2):** `--dry-run`/`--help`, `setup-receipt.json`, `wire_steiger()`,
  GitHub env/secrets kurulumu.
- **F7 (CI birleşik):** `.github/workflows/verify.yml` — 4 job, Node 20/22 × Python
  3.11/3.12 matrix, artifact upload (AGT attestation + midas receipt + mcpscan report).
- **F8 (dokümantasyon):** `.archcore/TEMEL-MIMARI.md`, `CLAUDE.md`, `docs/architecture.drawio`,
  `docs/sequence.drawio`, `docs/dataflow.drawio`, `CHANGELOG.md`.

### Changed

- `setup.sh` — v2 (F6) + branch protection (F7); `tar` ile şablon kopyalama `.archcore`
  dahil (F8).
- `.gitignore` — Midas/AGT/MCP kurulum çıktıları hariç tutulur.
- README — F1-F8 özellik tablosu + diyagramlar (F8).

### Fixed

- `midas-mcp` SDK uyumluluğu: `--with "mcp<2"` sabitlemesi (mcp SDK 2.0 FastMCP'yi
  kaldırdı).
- `verify-pr` plan-gate: `allowed_paths` tırnak formatı düzeltildi (tırnaksız `- path`
  beklenir).
- YAML `{` tırnak bug'ı: `run:` içinde `{` içeren satırlar tek tırnakla sarılır.

### Security

- OWASP ASI 2026: `agt verify` 10/10 CI kapısı.
- MCP gateway: tool interception, response scan, message signing, session auth,
  rate limit, CVE feed, trust gating.
- Supply chain: lockfile SHA-256 manifest + OSV.dev CVE sorgusu.
- Agent mesh: Merkle audit chain (tamper-evident) + shadow AI strict red.
- Gitleaks pre-commit + ruleset (secret commit blok).

## Migration Guide (v1 → v2)

1. `setup.sh`'i güncelle (repo köküne yeni sürümü koy), tekrar çalıştır — `.archcore`
   ve `.github/workflows` otomatik güncellenir.
2. CI check adını `ci` → `verify` yapın (branch protection required checks).
3. Ajan ortamlarınızda `CLAUDE.md` kullanılıyorsa yeni köprü otomatik okunur; AGENTS.md
   import'ları `.midas`/`.agt`/`tools` varlığını gerektirir — `setup.sh` sonrası hazır.
4. Eski `TEMEL-MIMARI.md` kök referanslarını `.archcore/TEMEL-MIMARI.md`'ye çevirin.

[Keep a Changelog]: https://keepachangelog.com/tr/1.1.0/
[Semantic Versioning]: https://semver.org/
