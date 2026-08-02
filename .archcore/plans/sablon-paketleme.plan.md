---
id: sablon-paketleme
status: accepted
created: 2026-08-02
approved_by: Kullanici
last_approved: 2026-08-02T10:38:42Z
last_review_date: 2026-08-02T10:38:42Z
ttl_days: 90
plan_hash: 4278a45c41db6075be9e521c9fc8309c4cd95ac393745058d43e8064b2114a4c
scope:
  allowed_paths:
    - "**"
  allowed_commands:
    - git init
    - git add
    - git commit
    - npm run hooks:install
    - npm run verify

---

# sablon-paketleme — Şablonu yeni proje başlangıcı olarak paketleme

## Bağlam
TEMEL şablonu test oturumunda kirletildi (faz2-hook-test planı, 3 test
commit'i, ornek-plan fixture'ında UTF-8 bozulması). Kullanıcı şablonu
"yeni projeye başlayacakmış gibi" temiz bir başlangıç noktası yapmak istiyor:
bir sonraki kullanım (yeni proje veya GitHub template repo) temiz başlasın.

## Çözüm tasarımı
1. Test izlerini temizle: faz2-hook-test.plan.md silindi (yapıldı),
   ornek-plan fixture'ı draft + düzgün UTF-8 (yapıldı)
2. `.git/` geçmişini sıfırla (test commit'leri şablon geçmişine girmesin)
3. Hook'ları yeniden kur (npm run hooks:install)
4. İlk temiz commit: "feat: TEMEL sablon ilk surum (v1.0)"
5. Doğrulama: npm run verify + kapı zinciri bu commit'le yeniden test edilir

## Etkilenen dosyalar
- [ ] `.git/` (sıfırlanacak)
- [ ] `.archcore/plans/faz2-hook-test.plan.md` (silindi ✅)
- [ ] `.archcore/plans/ornek-plan.plan.md` (fixture, draft ✅)
- [ ] README.md (gerekirse: "cp -r" → template repo talimatı)

## Test planı
- npm run verify yeşil
- İlk temiz commit tüm kapılardan geçer (plan: sablon-paketleme)
- verify-drift 0 bayat 0 uyarı

## Geri alma planı
.git silinmesi geri alınamaz ama içerik zaten temiz; şablon dosyaları
ayrıca `C:\Users\Windows\AppData\Local\Temp\opencode\ui-main` gibi
kaynaklarla karıştırılmaz — yedek yok gerekmez (dosyaların kendisi dursun).

## Riskler
- Hook'lar git init sonrası yeniden kurulmazsa commit kapıları çalışmaz
- İlk commit'te lefthook stash sorunu (HEAD yok) — tüm dosyalar staged
  tutularak aşılır (FAZ 2'de öğrenildi)
