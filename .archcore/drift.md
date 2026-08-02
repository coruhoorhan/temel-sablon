# Drift / TTL — Şema ve Otomasyon

> Bölüm 8.3 madde 6 (TTL kontratı) + madde 14 (yaşlanma = arşivleme, silme değil) uygulaması.
> Denetçi: `.archcore/bin/verify-drift` (FAZ 4) — salt-okunur, archcore-auditor deseni.

## 1. Frontmatter şeması

| Alan | Zorunlu | Varsayılan | Açıklama |
|---|---|---|---|
| `last_review_date` | evet (yoksa UYARI) | — | ISO-8601 (ör: `2026-08-02` veya `2026-08-02T10:00:00Z`). İnsan gözden geçirme anı; güncelleme = belgeyi tazeleme |
| `ttl_days` | hayır | 90 | Gözden geçirme sonrası ömür (gün). `last_review_date + ttl_days < bugün` ⇒ bayat |
| `status` | tür bazlı | draft | draft → pending_review → accepted → rejected / superseded. `rejected`/`superseded` arşiv kaydıdır, SİLİNMEZ (madde 14) |
| `created` | hayır | — | Belge oluşturulma anı (ISO-8601) |
| `id` / `plan_hash` / `approved_by` / `last_approved` | plan | — | Plan türü şeması (bkz. `plan.plan.md.tmpl`; `plan_hash` onaylı body'yi korur) |
| `description` / `globs` / `priority` | rule | — | Kural türü şeması (bkz. `01-tipler.rule.md`) |

## 2. TTL kontratı (Bölüm 8.3 madde 6)

- **30 gün drift:** içerik ile kod/gerçekliğin ayrışma eşiği. `verify-drift` bunu OYNAMAZ — içerik-kod uyumu ayrı araçların işi (archcore-auditor / Dosu deseni; bkz. 9.3 olgunluk: Dosu > archcore --drift #13 açık).
- **90 gün yaş:** `ttl_days` varsayılanı. `last_review_date` üzerinden bu süre aşılırsa belge **bayat** → insan gözden geçirir, `last_review_date` günceller. Güncelleme kalıcı belge değişikliğidir → PR'dan geçer (madde 4).

## 3. Taranan dosyalar

- **Taranır:** `.archcore/**/*.md` — `rules/`, `plans/` ve gelecekteki 19 belge türünün tamamı (frontmatter'lı).
- **TARANMAZ:** köprü dosyaları (`AGENTS.md`, `README.md` — kod tarafı), `templates/` (`*.tmpl`), frontmatter'sız dosyalar.

## 4. Örnek frontmatter

```yaml
---
id: auth-refresh-tokens
status: accepted
created: 2026-08-02T10:00:00Z
last_review_date: 2026-08-02
ttl_days: 90
---
```

## 5. Otomasyon akışı

1. `bash .archcore/bin/verify-drift` — bilgi amaçlı, exit 0 (bayat liste insan işine yönlendirir)
2. `bash .archcore/bin/verify-drift --strict` — bayat varsa exit 1 (aylık/çeyreklik bakım görevi)
3. pre-push (lefthook) + CI (GitHub Actions) — öneri için bkz. FAZ 4 raporu
4. İnsan: bayat belgeyi gözden geçir → `last_review_date` güncelle → PR. Plan belgelerinde frontmatter değişikliği `plan_hash`'i kırar → yeniden onay gerekir (`approve-plan`)
