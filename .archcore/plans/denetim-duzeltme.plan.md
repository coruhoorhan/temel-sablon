---
id: denetim-duzeltme
status: accepted
created: 2026-08-02
approved_by: Kullanici
last_approved: 2026-08-02T11:33:46Z
last_review_date: 2026-08-02T11:33:46Z
ttl_days: 90
plan_hash: 398d542d9a11d98d09acebae331ed2edc52a1e7d4c8c4bf53349c6159c62ce08
scope:
  allowed_paths:
    - .archcore/bin/**
    - lefthook.yml
    - .gitignore
    - README.md
    - .archcore/plans/**
  allowed_commands:
    - git update-index --chmod=+x
    - git add
    - git commit
    - git push
    - npm run verify
    - bash .archcore/bin/verify-*

---

# denetim-duzeltme — 3 alt ajan denetiminde bulunan 7 sorunun onarımı

## Bağlam
3 alt ajan denetimi (kod/infra, belge/içerik, kurulum klonu) 7 sorun tespit etti.
Kritik: pre-push plan kapısı çalışmıyor, scriptler Linux'ta executable değil,
CI plan-gate mevcut geçmişi reddediyor, mojibake-duzeltme.plan.md U+FFFD ile
bozuldu (CP1252 round-trip'i 0x9F'i ?'ye çevirdi — ajanın kendi hatası).

## Çözüm tasarımı
1. **S1 — verify-push düzeltmesi:** `git rev-list --not --all "$range"` yerine
   pre-push stdin'den gelen `<local_ref> <local_sha> <remote_ref> <remote_sha>`
   satırlarını oku; `git rev-list "$remote_sha".."$local_sha"` ile itilen
   commit'leri al (ilk push'ta remote_sha boş olabilir → tüm geçmişi tara)
2. **S1 — lefthook.yml:** plan-gate-push job'ına `use_stdin: true` ekle
3. **S2 — executable bit:** `git update-index --chmod=+x` ile 6 script 100755
   (verify-commit-msg, verify-push, verify-pr, verify-drift, approve-plan,
   llm-verify.sh)
4. **S3 — plan scope'ları:** 4 planın allowed_paths'ine `.archcore/plans/**`
   ekle + approve-plan ile yeniden onay (hash tazelenir) — plan belgeleri
   kendi kapsamında değişebilsin
5. **S4 — .gitignore:** `*.pem`, `*.key`, `*.p12`, `*.pfx`, `id_rsa*` desenleri
6. **U+FFFD — mojibake-duzeltme.plan.md:** write ile yeniden yaz (temiz
   Türkçe, 6 bölüm), approve-plan ile yeniden onay
7. **README:** "10 kategori / 10 kural dosyası" → 11 (11-hafiza mevcut)

## Etkilenen dosyalar
- [ ] .archcore/bin/verify-push (S1)
- [ ] lefthook.yml (S1)
- [ ] .archcore/bin/* — 6 script chmod (S2)
- [ ] .archcore/plans/*.plan.md — 4 plan scope + 1 yeniden yazım (S3, U+FFFD)
- [ ] .gitignore (S4)
- [ ] README.md (11 kural)

## Test planı
- `git rev-list --not --all` hatası: push ref'leri stdin'den verilerek
  verify-push'un plan'sız commit'i REDDETTİĞİ doğrulanır (test repo'su)
- `git ls-files -s .archcore/bin` → 100755
- `bash .archcore/bin/verify-pr HEAD~N HEAD` → 0 ihlal
- npm run verify yeşil
- verify-drift 0 bayat 0 uyarı

## Geri alma planı
Ayrı ayrı commit'ler geri alınabilir; chmod geri 100644'ye çevrilebilir.

## Riskler
- verify-push stdin formatı lefthook'a özgü olabilir — hem stdin'i hem
  `--not --all` yedeğini destekleyen çift katmanlı okuma (kırılmazlık)
- Plan yeniden onayları hash'i değiştirir — eski commit'lerin hash'i artık
  uymaz, CI yalnız HEAD~N aralığını tarar (sorun değil, push geçmişi taze)
