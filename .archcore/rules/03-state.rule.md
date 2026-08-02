---
description: State yönetimi kuralları — React hooks disiplini, store deseni, immutable güncelleme
globs: src/**/*.{ts,tsx}
priority: P0
last_review_date: 2026-08-02
ttl_days: 90
---

# 3. State

**Kaynak:** react-hooks recommended-latest · @eslint-react · kural dokümanı + verifier
**Zorlama:** react-hooks plugin (makine) + verifier (mimari niyet)

## ALWAYS

### R3-01 · rules-of-hooks
**Ne:** hooks yalnızca top-level, yalnızca component/hook içinde, koşul yok.
**Zorlayan:** `react-hooks/rules-of-hooks` (error)

### R3-02 · exhaustive-deps
**Ne:** useEffect/useMemo/useCallback deps listesi tam. **Neden:** bayat closure = sessiz bug.
**Zorlayan:** `react-hooks/exhaustive-deps` (error)

### R3-03 · set-state-in-effect yasak (setState → effect → setState döngüsü)
**Ne:** effect içinde state set etme; derived value kullan. **Neden:** ekstra render + sonsuz döngü riski.
❌ `useEffect(() => { setFiltered(list.filter(x)) }, [list])`
✅ `const filtered = useMemo(() => list.filter(x), [list])`
**Zorlayan:** `react-hooks/set-state-in-effect` (error, recommended-latest)

### R3-04 · set-state-in-render yasak
**Ne:** render sırasında state yazma. **Neden:** render tutarsızlığı, Suspense kırılması.
**Zorlayan:** `react-hooks/set-state-in-render` (error)

### R3-05 · Immutable güncelleme (purity)
**Ne:** state'i asla mutate etme; yeni referans döndür. **Neden:** memo/React Compiler optimizasyonu çöker.
❌ `state.items.push(x); setState(state)`
✅ `setState({ ...state, items: [...state.items, x] })`
**Zorlayan:** `react-hooks/immutability` + `react-hooks/purity` (error)

### R3-06 · no-unstable-context-value
**Ne:** context value her render'da yeni obje olamaz. **Neden:** tüm consumer'ları gereksiz render eder.
❌ `<Ctx.Provider value={{ a, b }}>` (inline literal)
✅ `const value = useMemo(() => ({ a, b }), [a, b])`
**Zorlayan:** `@eslint-react/no-unstable-context-value` (error)

## ASK FIRST
- R3-A1: yeni global store → tek store deseni var mı? neden tekrar icat?
- R3-A2: selector'da fonksiyon üretimi (perf) → memoize et
- R3-A3: server state'i client store'a kopyalamak → cache yerine server state düşün

## NEVER
- ❌ iki store'da aynı domain durumu (kopya gerçeği) — bkz. R3-A1
- ❌ effect zincirinde setState (A effect'i B'yi, B effect'i C'yi set eder)
- ❌ context'e fonksiyon değeri inline (her render yeni referans)
- ❌ state'te serialize edilemeyen değer (Date/Map) — doğrudan değil, dönüşümle

## Verifier maddeleri
- V3-1: tek store deseni ihlali — aynı domain iki yerde state'li mi?
- V3-2: selector kuralı — select'te hesaplama/koşul var mı?
- V3-3: server/client state ayrımı — server verisi client cache'e kopyalanmış mı?
- V3-4: diff'te gizli mutation (eslint'in görmediği lib fonksiyonları) var mı?
