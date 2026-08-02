---
id: kurulum-scripti
status: accepted
created: 2026-08-02
approved_by: Kullanici
last_approved: 2026-08-02T11:53:50Z
last_review_date: 2026-08-02T11:53:50Z
ttl_days: 90
plan_hash: 9474bf680e62bb2d45119e193b476bf86e50c4ffa0369236e5563bbb470daf8f
scope:
  allowed_paths:
    - setup.sh
    - README.md
    - .archcore/plans/**
  allowed_commands:
    - bash setup.sh
    - npm run verify
    - git commit
    - git push

---

# kurulum-scripti — İnteraktif setup.sh (kullanıcı kendi başına kurulum)

## Bağlam
FAZ 6'nın amacı: şablonu kullananın KENDİSİ kurup deneyimlemesi. Şu ana kadar
kurulumu ben yaptım — bu, kullanıcının öğrenme/deneyimleme hedefine aykırı.
Kullanıcı istedi: interaktif bir .sh script'i — bilgileri kullanıcı girer,
script kurulum + test + doğrulama yapar.

## Çözüm tasarımı
`setup.sh` (şablon kökünde, bash, Linux + Git Bash uyumlu):
1. **Bilgi topla (interaktif read):** proje adı (varsayılan: mevcut klasör),
   GitHub kullanıcı adı (gh varsa otomatik), repo oluşturulsun mu (gh),
   public/private, gitleaks yüklü mü (değilse kurulum komutunu göster)
2. **Kurulum:** git init + branch main, npm install, hooks:install
3. **Test (kapı kanıtı):** plansız commit denemesi → plan-gate REDDETMELİ
   (reddettiğini göster, sonra değişikliği geri al); geçerli örnek plan
   oluşturup onay akışını gösterme (fixture ile)
4. **Doğrulama:** npm run verify, verify-drift (0 bayat 0 uyarı), gitleaks
5. **Özet:** ne kuruldu, kapılar ne yapar, sıradaki adımlar (ilk plan +
   onay akışı) — her adımda "neden" açıklaması ekrana yazılır (eğitim amaçlı)
6. çıkış kodu: tüm testler geçtiyse 0, tek hata → hata mesajı + 1

README'ye kurulum bölümü güncellenir: "En kolay: bash setup.sh".

## Etkilenen dosyalar
- [ ] setup.sh (yeni — şablon kökü)
- [ ] README.md (kurulum bölümü: setup.sh önerilir, elle adımlar altında kalır)

## Test planı
- `bash -n setup.sh` — syntax
- Script Windows Git Bash'te kuru test: bilgiler verilerek çalışır,
  plansız commit REDDİ kanıtlanır, verify yeşil
- Kullanıcı deneme-iskelet'te kendi çalıştırarak deneyimler

## Geri alma planı
setup.sh silinir, README eski haline döner.

## Riskler
- Windows Git Bash'te `npm` yerine `npm.cmd` gerekebilir — script çift
  deneme yapar (command -v npm.cmd || npm)
- gitleaks PATH'te olmayabilir — script bulamazsa kurulum komutu önerir,
  kullanıcı kurup tekrar çalıştırabilir (idempotent tasarım)
- İlk commit'te lefthook stash sorunu — script tüm dosyaları stage edip
  öyle commit önerir (FAZ 2'de öğrenilen ders)
