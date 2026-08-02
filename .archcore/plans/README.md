# Onay State Dizini

Bu dizin, **plan onayının tek kaynağıdır** (Katman 1 — ajan-bağımsız).
Git hook'ları, CI ve sunucu tarafı buradaki dosyaları okur; ajan API'sine bağlı değildir.

## Yaşam döngüsü

```
draft ──insan onayı──▶ accepted ──revizyon──▶ (hash kırılır → yeniden onay)
  │                        │
  └─ret────▶ rejected      └─süpersede──▶ superseded (yeni plan)
```

- `status`: `draft | pending_review | accepted | rejected | superseded`
- `accepted` yalnızca insan yazar (ajan kendini onaylayamaz)
- `plan_hash`: frontmatter'daki `plan_hash:` satırı hariç body'nin sha256'sı
  — onay sonrası body değişikliği kapı tarafından yakalanır

## Şablon kullanımı

```bash
cp .archcore/templates/plan.plan.md.tmpl .archcore/plans/<id>.plan.md
```

Onay (insan + ajan birlikte):
1. kullanıcı onayladı → `status: accepted`
2. `approved_by: <insan-adı>`, `last_approved: <ISO-8601>`
3. `plan_hash`: `sed '/^plan_hash:/d' <file> | sha256sum | cut -d' ' -f1`

## Kapı denetimleri

| Denetim | Dosya | Ne kontrol eder |
|---|---|---|
| commit-msg | `verify-commit-msg` | `plan: <id>` trailer + accepted + hash + approved_by |
| pre-push | `verify-push` | itilen her commit aynı kurallar + scope dolu |
| CI/PR | `verify-pr` | tüm commit'ler + `allowed_paths` scope uyumu |

Not: Bu klasördeki dosyalar `.archcore/plans/*.plan.md` — ajan düzenler ama
**onay alanlarını** (status/approved_by/hash) insan doğrular.
