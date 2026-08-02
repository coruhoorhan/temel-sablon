---
id: mojibake-duzeltme
status: accepted
created: 2026-08-02
approved_by: Kullanici
last_approved: 2026-08-02T11:16:48Z
last_review_date: 2026-08-02T11:16:48Z
ttl_days: 90
plan_hash: 4f69a8d50dabbdd028f4903de4087cae6c33ce2e4b0dff58c8569b3d032d962a
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

# mojibake-duzeltme � 10 kural dosyasinda T�rk�e karakter onarimi

## Baglam
Kullanici bildirdi (alt ajan dogrulamasiyla dogrulandi): `.archcore/rules/`
01-10 numarali kural dosyalarinda T�rk�e karakterler mojibake (�ift kodlama)
durumda � `y�netimi` ? `yönetimi`, `�` ? `—`. Kaynak: FAZ 0'daki toplu
yazimda kodlama hatasi. 11-hafiza ve diger t�m dosyalar temiz (dogrulandi).

## ��z�m tasarimi
1. Her dosya: UTF-8 okunur ? string Windows-1252 baytlarina �evrilir ?
   UTF-8 olarak yeniden yazilir (round-trip, kopya �zerinde dogrulandi:
   `mojibake-test2.md` basarili)
2. BOM eklenmez, LF korunur (UTF8Encoding($false) � bilinen Windows tuzagi)
3. I�erik semantigi DEGISMEZ � yalnizca karakter onarimi; frontmatter
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

## Test plani
- 10 dosyada mojibake deseni (�/�/ş/ğ/ı) kalmadi
- T�rk�e karakterlerin t�m� dogru (�r. `y�netimi`, `�`, `kosul`)
- npm run verify yesil (i�erik degisikligi kodu etkilemez ama kapi testi)

## Geri alma plani
Git ge�misinden eski commit kurtarilabilir; onarim tek y�nl�, hash degismez
(plan_hash body'den hesaplanir � frontmatter dokunulmuyor).

## Riskler
- UTF-8 baytlarinin CP1252 round-trip'i saf degilse yeni bozulma �
  test dosyasinda dogrulandi (03-state kopyasi temiz �ikti)
- CRLF/LF kaymasi � ReadAllText/WriteAllText bayt d�zeyinde korur
