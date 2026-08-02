---
id: mojibake-duzeltme
status: accepted
created: 2026-08-02
approved_by: Kullanici
last_approved: 2026-08-02T11:15:39Z
last_review_date: 2026-08-02T11:15:39Z
ttl_days: 90
plan_hash: 7bb39f38c81e684b813113a525c786467590281e2896364f6ec9d105563e07df
scope:
  allowed_paths:
    - .archcore/rules/01-tipler.rule.md
    - .archcore/rules/02-mimari.rule.md
    - .archcore/rules/03-state.rule.md
    - .archcore/rules/04-guvenlik.rule.md
    - .archcore/rules/05-hata.rule.md
    - .archcore/rules/06-veri.rule.md
    - .archcore/rules/07-performans.rule.md
    - .archcore/rules/08-test.rule.md
    - .archcore/rules/09-temizlik.rule.md
    - .archcore/rules/10-yapi.rule.md
  allowed_commands:
    - npm run verify

---

# mojibake-duzeltme — 10 kural dosyasında Türkçe karakter onarımı

## Bağlam
Kullanıcı bildirdi (alt ajan doğrulamasıyla doğrulandı): `.archcore/rules/`
01-10 numaralı kural dosyalarında Türkçe karakterler mojibake (çift kodlama)
durumda — `yönetimi` → `yÃ¶netimi`, `—` → `â€”`. Kaynak: FAZ 0'daki toplu
yazımda kodlama hatası. 11-hafiza ve diğer tüm dosyalar temiz (doğrulandı).

## Çözüm tasarımı
1. Her dosya: UTF-8 okunur → string Windows-1252 baytlarına çevrilir →
   UTF-8 olarak yeniden yazılır (round-trip, kopya üzerinde doğrulandı:
   `mojibake-test2.md` başarılı)
2. BOM eklenmez, LF korunur (UTF8Encoding($false) — bilinen Windows tuzağı)
3. İçerik semantiği DEĞİŞMEZ — yalnızca karakter onarımı; frontmatter
   (last_review_date/ttl_days/plan_hash) dokunulmaz
4. Yeni commit: `fix: kural dosyalarinda turkce karakter onarimi` +
   `plan: mojibake-duzeltme`

## Etkilenen dosyalar
- [ ] .archcore/rules/01-tipler.rule.md
- [ ] .archcore/rules/02-mimari.rule.md
- [ ] .archcore/rules/03-state.rule.md
- [ ] .archcore/rules/04-guvenlik.rule.md
- [ ] .archcore/rules/05-hata.rule.md
- [ ] .archcore/rules/06-veri.rule.md
- [ ] .archcore/rules/07-performans.rule.md
- [ ] .archcore/rules/08-test.rule.md
- [ ] .archcore/rules/09-temizlik.rule.md
- [ ] .archcore/rules/10-yapi.rule.md

## Test planı
- 10 dosyada mojibake deseni (Ã/â€/ÅŸ/ÄŸ/Ä±) kalmadı
- Türkçe karakterlerin tümü doğru (ör. `yönetimi`, `—`, `koşul`)
- npm run verify yeşil (içerik değişikliği kodu etkilemez ama kapı testi)

## Geri alma planı
Git geçmişinden eski commit kurtarılabilir; onarım tek yönlü, hash değişmez
(plan_hash body'den hesaplanır — frontmatter dokunulmuyor).

## Riskler
- UTF-8 baytlarının CP1252 round-trip'i saf değilse yeni bozulma —
  test dosyasında doğrulandı (03-state kopyası temiz çıktı)
- CRLF/LF kayması — ReadAllText/WriteAllText bayt düzeyinde korur
