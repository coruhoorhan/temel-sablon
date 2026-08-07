# CLAUDE.md — TEMEL Şablon (Claude Code için köprü)

> Bu dosya Claude Code'un oturum başında okuduğu köprüdür. Kurallar burada değil,
> `.archcore/rules/` ve aşağıdaki import dosyalarındadır — bu dosya yalnızca nereye
> bakılacağını söyler (limit 50KB).

## Import'lar (Claude Code oturum başında yükler)

- `@.midas/midas-policy.md` — hafıza sözleşmesi: ne zaman capture, provenance hiyerarşisi, kind+TTL haritası
- `@.agt/policy.yaml` — tool kuralları (deny/audit/allow/block); CI `agt lint-policy --strict` zorlar
- `@tools/architecture/src/steiger-rules/` — FSD katman kuralı (no-upward-import)

> Not: Import edilen dosyalar `setup.sh` kurulumunda `.template`'lerden üretilir
> (`.midas/config.yaml`, `.agt/policy.yaml`, `.agt/manifest.yaml`). Şablon dışı bir
> ortamda bunlar yoksa önce `bash setup.sh` çalıştır.

## Proje Kimliği

- Stack: TypeScript 5.9 strict · Vite · Vitest 4 · ESLint 10 (flat) · FSD (feature-sliced)
- Ortam: Linux (Arch/Ubuntu/Debian), Node 24 LTS
- Mimari: `.archcore/TEMEL-MIMARI.md` — katmanlar, kapılar, veri akışı

## Zorunlu Akış (ajan kuralı — ihlal = kod yazma yasağı)

1. **SORU:** belirsizliği 4-10 soruyla netleştir — sohbet sonrası belgeye geç
2. **PLAN:** `.archcore/plans/<id>.plan.md` oluştur → `status: draft`
3. **ONAY:** insan `status: accepted` yapmadan **kod yazma** (bkz. NEVER)
4. **KOD:** onay sonrası; commit mesajına `plan: <id>` trailer'ı ekle (kapı zorlar)

## Kapılar (makine zorlaması — atlanamaz)

| Katman | Nerede | Ne yapar |
|---|---|---|
| commit-msg hook | `.archcore/bin/verify-commit-msg` | `plan: <id>` + accepted + hash |
| pre-push hook | `.archcore/bin/verify-push` | itilen commit'ler plan referanslı + kapsam |
| drift/TTL | `.archcore/bin/verify-drift` | TTL eşikleri (30g drift/90g yaş) |
| CI | `.github/workflows/verify.yml` | lint + tsc + test + arch + plan-gate + AGT + Midas |
| Ruleset | GitHub | force-push/silme blok, imzalı commit |

## NEVER (sert yasaklar)

- ❌ `status: accepted` plan olmadan kod yazma (girişim = geçici taslak, commit YASAK)
- ❌ MCP dosya-düzenleme araçları (opencode filesystem edit-deneyi bypass eder — #30291)
- ❌ `.env` veya herhangi bir secret'ı commit'e ekleme (gitleaks + ruleset yakalar)
- ❌ mevcut plan belgesini `plan_hash` uymadan düzenleme (hash kırılırsa yeniden onay şart)
- ❌ kendini onaylama: `approved_by` insandır, ajan asla yazmaz
- ❌ harici içerik doğrudan hafızaya yazılamaz — önce candidates/ + source + insan onayı
- ❌ hafıza belgesi silmek yasak — arşivle: rejected/superseded

## Alışkanlıklar

- Commit: conventional commit + `plan: <id>` trailer · atomik · her kapıdan geçmiş doğar
- Push öncesi: `npm run typecheck` + tam lint + değişen scope testleri
