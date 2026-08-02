---
description: FSD (Feature-Sliced Design) klasör şeması kılavuzu — projeye özgü mimari kararların kaynağı
globs: src/**
priority: P0
---

# FSD Klasör Şeması

Bu kılavuz 10-yapi kuralının ("FSD niyeti") somut uygulamasıdır.
Yeni katman/slice kararı → buraya işlenir (R10-A1).

## Katman hiyerarşisi (yukarıdan aşağıya)

```
src/
├── app/          uygulama kurulumu: provider'lar, router, global stil
├── pages/        route'lar; yalnız widget/feature'ları birleştirir
├── widgets/      yeniden kullanılabilir büyük bloklar (header, sidebar)
├── features/     kullanıcı hikayesi parçası: auth, cart, search
├── entities/     iş kavramı: user, product, order
└── shared/       UI kiti, lib, api, config — herkese açık, kimseye bağımlı değil
```

**Kural: import yalnız yukarıdan aşağıya.** Katman sızıntısı = R2-01 ihlali.

## Slice yapısı (her features/entities/widgets üyesi)

```
features/auth/
├── ui/        component'ler (PascalCase.tsx)
├── model/     state + hooks (useAuth.ts, types)
├── lib/       saf fonksiyonlar (session.ts — yan etkisiz)
├── api/       fetch/istek katmanı (refresh.ts)
└── index.ts   PUBLIC API — dışarı yalnızca buradan export
```

- `index.ts` dışına import = R2-02 ihlali
- 150 satır aşılınca bölme deseni (09-temizlik): ui→alt-component, model→hook, lib→saf fonksiyon

## shared/ disiplini
- `shared/ui` (buttons, inputs), `shared/lib` (date, format), `shared/api` (client), `shared/config`
- shared yalnız framework-agnostik; domain bilgisi shared'e sızmaz (R6-A2 timezone gibi kurallar burada)

## Dosya adlandırma (10-yapi R10-05)
- kebab-case dosyalar · `useX.ts` hooks · `X.tsx` component · `*.types.ts` tipler
- test: `*.test.ts(x)` · story: `*.stories.tsx` · machine: `*.machine.ts`

## Yeni slice checklist (R10-A1)
1. Hangi katman? (app/pages/widgets/features/entities/shared)
2. Segment seti? (ui/model/lib/api/config — hepsi zorunlu değil)
3. Public API'de ne var? (index.ts — kapsülleme deliği taraması)
4. Burayı işle (bu dosyanın sonuna): `<!-- slice: <ad> — katman, açıklama, tarih -->`
