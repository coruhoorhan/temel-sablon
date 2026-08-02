---
description: State yÃ¶netimi kurallarÄ± â€” React hooks disiplini, store deseni, immutable gÃ¼ncelleme
globs: src/**/*.{ts,tsx}
priority: P0
last_review_date: 2026-08-02
ttl_days: 90
---

# 3. State

**Kaynak:** react-hooks recommended-latest Â· @eslint-react Â· kural dokÃ¼manÄ± + verifier
**Zorlama:** react-hooks plugin (makine) + verifier (mimari niyet)

## ALWAYS

### R3-01 Â· rules-of-hooks
**Ne:** hooks yalnÄ±zca top-level, yalnÄ±zca component/hook iÃ§inde, koÅŸul yok.
**Zorlayan:** `react-hooks/rules-of-hooks` (error)

### R3-02 Â· exhaustive-deps
**Ne:** useEffect/useMemo/useCallback deps listesi tam. **Neden:** bayat closure = sessiz bug.
**Zorlayan:** `react-hooks/exhaustive-deps` (error)

### R3-03 Â· set-state-in-effect yasak (setState â†’ effect â†’ setState dÃ¶ngÃ¼sÃ¼)
**Ne:** effect iÃ§inde state set etme; derived value kullan. **Neden:** ekstra render + sonsuz dÃ¶ngÃ¼ riski.
âŒ `useEffect(() => { setFiltered(list.filter(x)) }, [list])`
âœ… `const filtered = useMemo(() => list.filter(x), [list])`
**Zorlayan:** `react-hooks/set-state-in-effect` (error, recommended-latest)

### R3-04 Â· set-state-in-render yasak
**Ne:** render sÄ±rasÄ±nda state yazma. **Neden:** render tutarsÄ±zlÄ±ÄŸÄ±, Suspense kÄ±rÄ±lmasÄ±.
**Zorlayan:** `react-hooks/set-state-in-render` (error)

### R3-05 Â· Immutable gÃ¼ncelleme (purity)
**Ne:** state'i asla mutate etme; yeni referans dÃ¶ndÃ¼r. **Neden:** memo/React Compiler optimizasyonu Ã§Ã¶ker.
âŒ `state.items.push(x); setState(state)`
âœ… `setState({ ...state, items: [...state.items, x] })`
**Zorlayan:** `react-hooks/immutability` + `react-hooks/purity` (error)

### R3-06 Â· no-unstable-context-value
**Ne:** context value her render'da yeni obje olamaz. **Neden:** tÃ¼m consumer'larÄ± gereksiz render eder.
âŒ `<Ctx.Provider value={{ a, b }}>` (inline literal)
âœ… `const value = useMemo(() => ({ a, b }), [a, b])`
**Zorlayan:** `@eslint-react/no-unstable-context-value` (error)

## ASK FIRST
- R3-A1: yeni global store â†’ tek store deseni var mÄ±? neden tekrar icat?
- R3-A2: selector'da fonksiyon Ã¼retimi (perf) â†’ memoize et
- R3-A3: server state'i client store'a kopyalamak â†’ cache yerine server state dÃ¼ÅŸÃ¼n

## NEVER
- âŒ iki store'da aynÄ± domain durumu (kopya gerÃ§eÄŸi) â€” bkz. R3-A1
- âŒ effect zincirinde setState (A effect'i B'yi, B effect'i C'yi set eder)
- âŒ context'e fonksiyon deÄŸeri inline (her render yeni referans)
- âŒ state'te serialize edilemeyen deÄŸer (Date/Map) â€” doÄŸrudan deÄŸil, dÃ¶nÃ¼ÅŸÃ¼mle

## Verifier maddeleri
- V3-1: tek store deseni ihlali â€” aynÄ± domain iki yerde state'li mi?
- V3-2: selector kuralÄ± â€” select'te hesaplama/koÅŸul var mÄ±?
- V3-3: server/client state ayrÄ±mÄ± â€” server verisi client cache'e kopyalanmÄ±ÅŸ mÄ±?
- V3-4: diff'te gizli mutation (eslint'in gÃ¶rmediÄŸi lib fonksiyonlarÄ±) var mÄ±?
