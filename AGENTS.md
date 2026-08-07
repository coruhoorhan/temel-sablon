# AGENTS.md — TEMEL Şablon Köprüsü

> Bu dosya yalnızca köprüdür: kuralları kendisi yazmaz, nerede olduğunu söyler.
> Kural ekleme → `.archcore/rules/` (düz markdown, bu dosyayı şişirme — limit 50KB).

## Import'lar (oturum başında yüklenir)

- `@.midas/midas-policy.md` — hafıza sözleşmesi (F1)
- `@.agt/policy.yaml` — tool kuralları (F2)
- `@tools/architecture/src/steiger-rules/` — FSD katman kuralı (F4)

> `setup.sh` bunları `.template`'lerden üretir (`.midas/config.yaml`, `.agt/policy.yaml`,
> `.agt/manifest.yaml`). Şablon dışı ortamda eksikse önce `bash setup.sh`.

## Proje Kimliği
- Stack: TypeScript 5.9 strict · Vite · Vitest 4 · ESLint 10 (flat) · FSD (feature-sliced)
- Ortam: Linux (Arch/Ubuntu/Debian), Node 24 LTS

## Hafıza (Midas — F1)
- **Ajan sözleşmesi:** `midas-policy.md` (ne zaman capture / provenance hiyerarşisi / kind+TTL haritası)
- **Config:** `.midas/config.yaml.template` → kurulumda `.midas/config.yaml` (env: NLI=1, SUPERSEDE=1 zorunlu)
- **Makine zorlaması:** TTL/supersession/dedup/guard Midas'ta; CI denetimi `.github/workflows/midas.yml` (salt-okunur auditor, R11-12)
- **Kural katmanı:** `.archcore/rules/11-hafiza.rule.md` (R11-01..14) — Midas bu kuralların makine tarafıdır

## Governance (AGT — F2)
- **Policy:** `.agt/policy.yaml` (tool kuralları — deny: yıkıcı git/hafıza silme; audit: harici erişim/secret yazımı)
- **Manifest:** `.agt/manifest.yaml` (ajan kimlikleri + trust — coder/verifier/human; bilinmeyen ajan fail-closed)
- **OWASP ASI 2026:** `agt verify` 10/10 zorunlu — `.github/workflows/agt-verify.yml` (CI kapısı)
- **Prompt defense:** `agt red-team scan` — agent prompt'ları min C notu (T8'de blocking; şu an rapor)
- **Policy doğrulama:** `agt lint-policy --strict` + `agt test .agt/policy.yaml .agt/fixtures/` (fixture replay)
- **Lehçe:** push öncesi `agt lint-policy` + prompt defense raporu (pre-push, fail-open — CI zorlar)

## MCP Güvenliği (F3)
- **Gateway:** `.agt/mcp-gateway.yaml` (tool interception + response scan + message signing + session auth + rate limit + CVE feed + trust gating)
- **Server kayıtları:** `.mcp.json` (template'ten üretilir; midas-mcp otomatik eklenir)
- **Tarama:** `npx @nileshbera/mcpscan scan --fail-on high` (client config) + AGT `mcp-scan` (primitives)
- **Supply chain:** lockfile SHA-256 manifest (`.archcore/supply-chain-manifest.txt`) + OSV.dev CVE sorgusu
- **CI:** `.github/workflows/mcpscan.yml` + `supply-chain.yml` (high+ bulgu = red)

## Mimari (F4)
- **Custom Steiger plugin:** `tools/architecture/src/steiger-rules/` — `temel/no-upward-import` (shared→entities→features→widgets→pages→app; yukarı import yasak)
- **Config:** `steiger.config.js` — fsd.configs.recommended + custom plugin + ignores
- **Kapı:** `npm run arch:check` (= steiger + knip) — pre-commit + CI'da
- **Script:** `tools/architecture/scripts/check-arch.sh`

## Agent Mesh (F5)
- **Manifest + trust mesh:** `.agt/manifest.yaml` — DID kimlikleri, trust_score, delegation, trust decay, peer attestation
- **Merkle audit:** `.archcore/bin/audit-chain.py` — karar kayıtlarını SHA-256 zincirler (tamper-evident)
- **Shadow AI:** `.archcore/bin/shadow-discovery.py` — manifest'te kayıtlı olmayan ajan tespiti (strict = red)
- **Dashboard:** `.archcore/bin/gov-dashboard.py` → `docs/governance-dashboard.html` (R11-11 denetim izi)
- **CI:** `.github/workflows/agent-mesh.yml` — zincir doğrulama + shadow + trust şeması

## CI/CD (F7)
- **Birleşik pipeline:** `.github/workflows/verify.yml` — typecheck + lint + test + arch + plan-gate + AGT + Midas + mcpscan
- **Matrix:** Node 20/22 × Python 3.11/3.12 (code-quality job)
- **Security-* ayrı:** SAST (Semgrep), SCA (OSV-Scanner), container (Trivy) — uzmanlaşmış, dokunulmaz
- **Branch protection:** main'e required checks (verify + security-*) — setup.sh T7.4

## Kurallar (KATMAN 1 — bilgi)
- **11 kural kategorisi:** `.archcore/rules/01-tipler.rule.md` … `11-hafiza.rule.md`
- Her kural ya makine kapısına (ESLint kural ID / tsc flag / vitest eşiği) ya verifier kontrol listesine bağlıdır.
- **Boyut:** üretim dosyası ≤150 etkin satır (skipBlank+skipComments; ESLint `max-lines`). Muaf: `*.test.*` `*.spec.*` `__tests__` `*.stories.*` `fixtures` `mocks` `machine`/`reducer`.
- **FSD niyeti:** `fsd.guide.md` (varsa) + Steiger — katman yukarı import yasak, public API zorunlu.

## Zorunlu Akış (KATMAN 3 — ajan kuralı)
1. **SORU:** belirsizliği 4-10 soruyla netleştir — sohbet sonrası belgeye geç
2. **PLAN:** `.archcore/plans/<id>.plan.md` oluştur → `status: draft`
3. **ONAY:** insan `status: accepted` yapmadan **kod yazma** (bkz. NEVER)
4. **KOD:** onay sonrası; commit mesajına `plan: <id>` trailer'ı ekle (kapı zorlar)

## Kapılar (KATMAN 2 — zorlama)
| Katman | Nerede | Ne yapar |
|---|---|---|
| commit-msg hook | `.archcore/bin/verify-commit-msg` | `plan: <id>` + accepted + hash |
| pre-push hook | `.archcore/bin/verify-push` | itilen commit'ler plan referanslı + kapsam |
| drift/TTL kapısı | `.archcore/bin/verify-drift` (FAZ 4 — başka ajan yazıyor) | TTL eşikleri (30g drift/90g yaş), çift yönlü supersession, bayatlık sinyali |
| CI | `.github/workflows/*` (FAZ 2) | lint+tsc+test+coverage, güvenlik taramaları |
| Ruleset | GitHub (FAZ 2) | force-push/silme blok, imzalı commit |
| Verifier ajanı | `.opencode/agents/verifier.md` | diff ≤300 satır → LLM denetimi (BLOCK: critical+conf≥0.7) |

## Komutlar
- `npm run lint` · `npm run typecheck` · `npm test` · `npm run coverage`
- Kapı doğrulama: `.archcore/bin/verify-commit-msg`, `.archcore/bin/verify-push`

## NEVER (sert yasaklar)
- ❌ `status: accepted` plan olmadan kod yazma (girişim = geçici taslak, commit YASAK)
- ❌ MCP dosya-düzenleme araçları (opencode filesystem edit-deneyi bypass eder — #30291)
- ❌ `.env` veya herhangi bir secret'ı commit'e ekleme (gitleaks + ruleset yakalar)
- ❌ mevcut plan belgesini `plan_hash` uymadan düzenleme (hash kırılırsa yeniden onay şart)
- ❌ sessiz merge / çelişki birleştirme — supersession çift yönlü ve aynı commit'te
- ❌ kendini onaylama: `approved_by` insandır, ajan asla yazmaz
- ❌ harici içerik (README/web/issue) doğrudan hafızaya yazılamaz — önce candidates/ + source + insan onayı (11-hafiza R11-13)
- ❌ hafıza belgesi silmek yasak — arşivle: rejected/superseded (11-hafiza R11-14)

## Alışkanlıklar
- Commit: conventional commit + `plan: <id>` trailer · atomik · her kapıdan geçmiş doğar
- Push öncesi: `npm run typecheck` + tam lint + değişen scope testleri
