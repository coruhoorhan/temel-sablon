---
name: plan-gate
description: Ajan-bağımsız plan onay akışı. Kod yazmadan önce .archcore/plans/ altına plan oluştur, insan onayı (status: accepted) al, ancak ondan sonra kod yaz. Commit mesajına "plan: <id>" trailer'ı ekle.
---

# plan-gate — Plan Önce, Kod Sonra

Bu skill, **ajan fark etmeksizin** (opencode, Claude Code, Codex, Cursor, Gemini, elle)
aynı onay akışını uygular. Onayın tek kaynağı repo içindeki `.archcore/plans/` dizinidir.

## Kural
**`status: accepted` plan olmadan kod yazmak yasaktır.**
Kapı bunu zorlar: commit-msg hook (`plan: <id>` trailer), pre-push, CI (`.archcore/bin/*`).
Yazma anı bloklanmasan bile commit/push aşamasında reddedilirsin.

## Akış

### 1. SORU FAZI
Belirsiz gereksinimlerde 4-10 soru sor. Cevap gelmeden plana başlama.
Soruları sohbet dışına taşıma — her cevap plana kaynak olarak yazılır.

### 2. PLAN FAZI
1. `.archcore/templates/plan.plan.md.tmpl` şablonunu kopyala:
   `.archcore/plans/<plan-id>.plan.md` (`<plan-id>`: kebab-case, benzersiz)
2. `id`, `created` doldur; `status: draft`
3. `scope.allowed_paths` doldur (glob listesi — kapı bunu denetler)
4. Plan dosyasını kullanıcıya sun: **"Onaylıyor musun?"**

### 3. ONAY FAZI (insan, ajan asla kendini onaylamaz)
Kullanıcı onaylayınca dosyayı güncelle:
1. `status: draft → accepted`
2. `approved_by: <insan-adı>` (kullanıcıdan doğrula)
3. `last_approved: <ISO-8601>`
4. `plan_hash: <sha256-of-body>` — body'nin (frontmatter `plan_hash` satırı hariç) sha256'sı.
   Bash: `sed '/^plan_hash:/d' file | sha256sum | cut -d' ' -f1`
5. **Onaydan sonra body'yi değiştirme** — hash kırılır, kapı yeniden onay ister.

### 4. KOD FAZI
- Onaylı planın `scope.allowed_paths` kapsamındaki dosyalarda çalış
- Commit mesajı: conventional commit + `plan: <id>` trailer
- `plan: <id>` trailer'ı commit BODY'de olmalı (git hook okur):
  ```
  feat(auth): add refresh token rotation

  plan: auth-refresh-tokens
  ```

## Ret / Revizyon
- Plan reddedildiyse (`status: rejected`): yeni revizyon = yeni `id` veya `status: draft`'a geri
- Plan değiştiyse (onay sonrası): kullanıcıya **yeniden onay** sor

## İpuçları
- Plan kısa tut (≤150 satır — kural dosyaları gibi): bağlam, tasarım, etkilenen dosyalar, test, geri alma
- Belirsizliği plana "Riskler" bölümüne yaz — onaylama insanın işi, yazmak senin
- İki plan aynı anda aktif olabilir — scope'ları çakışıyorsa insana sor
