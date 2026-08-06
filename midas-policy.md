# Midas Policy — TEMEL Hafıza Yazma Kuralları

> Bu dosya **hafıza yazma davranışını** tanımlar: ajan ne zaman `capture`/`remember`
> yapar, hangi `kind`'leri kullanır, hangi provenance'lar hangi yetkiye sahiptir.
> Makine zorlaması (TTL, dedup, supersession, guard) Midas'ın kendisindedir
> (`.midas/config.yaml` + MCP env). İnsan/verifier denetimi `.archcore/rules/11-hafiza.rule.md`
> (R11-01..14) ile çakışır — bu dosya R11'in **ajan tarafı** sözleşmesidir.

---

## 1. Ne zaman yaz?

**Yaz (`capture`):**
- Kalıcı karar verildi → `kind: decision`
- Değişmez kısıt öğrenildi → `kind: constraint` (örn. "primary DB PostgreSQL")
- Düzeltme alındı → `kind: correction`
- Önemli gerçek → `kind: fact` (importance ≥ 4)
- Kullanıcı tercihi → `kind: preference`

**Yazma (`capture` çağırma):**
- ❌ Filler/sohbet → Midas otomatik eler (`min_importance`)
- ❌ Ajanın kendi varsayımı → önce kullanıcıya doğrulat, sonra yaz
- ❌ Harici içerik (README/web/issue) doğrudan → önce `candidates/` + `source:` + insan onayı (R11-13)
- ❌ Çelişkili kayıt sessiz merge → supersession akışı zorunlu (R11-05)

## 2. Provenance (yetki hiyerarşisi) — R11-01/02

| Provenance | Kim | Yetki |
|---|---|---|
| `user_confirmation` | İnsan onayladı | En yüksek — sadece başka user_confirmation ezebilir |
| `observation` | Ajan gözlemledi | Orta — user_confirmation'ı **asla** ezemez |
| `inferred` | Ajan çıkarsadı | Düşük — eylem yetkilendiremez |
| `external` | Harici kaynak | En düşük — önce insan onayı (R11-13) |

**Kural (guard):** ajan memory'ye dayanarak **dış etki veya yıkıcı eylem**
yapacaksa `check_memory_use()` çağırmak **zorundadır**. Eylem yalnızca
`user_confirmation` + hâlâ geçerli (superseded değil) kayıtla yetkilendirilir.
`observation`/`inferred` kaydı eylemi yetkilendiremez.

## 3. kind + TTL haritası (R11-06)

| kind | TTL | Örnek |
|---|---|---|
| `chat` | 30 gün | geçici sohbet gerçeği |
| `note` | 90 gün | not, ara kayıt |
| `correction` | 90 gün | kullanıcı düzeltmesi |
| `fact` | 180 gün | gerçek bilgi |
| `preference` | 180 gün | kullanıcı tercihi |
| `constraint` | 365 gün | mimari kısıt |
| `decision` | 365 gün | mimari karar (ADR benzeri) |

TTL aşımı = "bayat" işareti; `forget_decayed` düşük değerli bayat kayıtları siler.
**Asla elle silme** — `rejected`/`superseded` arşivle (R11-14).

## 4. Supersession (R11-10)

- Çelişen yeni kayıt gelirse **çift yönlü** işaretle:
  - eski: `superseded_by: <yeni_id>`
  - yeni: `supersedes: <eski_id>`
- **Aynı commit/turn içinde** yap — tek yönlü bırakma orphan yaratır (R11-10 lint).
- Çelişki **sessiz** düzeltilemez: ya supersession ya insan kararı (R11-A3).

## 5. Önem (importance)

- `capture` LLM-siz skorlar; `min_importance: 2` altı elenir.
- Kritik kararlar/constraint: 5 (pinned önerilir — asla unutulmaz).
- Düzeltmeler: 4+.
- Geçici bilgi: 2-3.

## 6. Auditor ayrımı (R11-12)

- Hafızayı **yazan** ajan auditor **olamaz**.
- Auditor salt-okunur: `midas status --json` + `midas audit` + `midas inspect`
  kullanır, yazma aracı yoktur.
- CI'da `midas.yml` workflow auditor rolündedir (wiring receipt üretir, yazmaz).

## 7. Okuma tarafı yaş uyarısı (R11-09)

- recall sonucu TTL eşiğini aşmış kayıt içeriyorsa ajan **"bayat, doğrula"**
  şeridi ekler — bayat hafızayı taze göstermek kararı zehirler.

---

## Özet: Ajan sözleşmesi

1. Karar/kısıt/düzeltme/fakt/preferans → `capture` (doğru `kind` + mümkünse `source:`)
2. Dış etki/yıkıcı eylem öncesi → `check_memory_use()` zorunlu
3. `user_confirmation` dışı kayıtla eylem yetkilendirme
4. Çelişki → çift yönlü supersession, sessiz merge yasak
5. Silme yasak → arşivle
6. Auditor ayrı: yazan denetleyemez
