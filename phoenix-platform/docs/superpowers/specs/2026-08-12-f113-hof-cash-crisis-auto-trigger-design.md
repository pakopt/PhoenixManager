# F113 — Living HoF Cash Crisis auto-trigger — Design

**Data:** 2026-08-12  
**Specs:** [F100 CASH_CRISIS](2026-08-11-f100-hof-twin-cash-crisis-design.md) · [F112 HI UI](2026-08-12-f112-hof-health-index-ui-alias-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Crit (HI) não dispara Twin `CASH_CRISIS` — só Commit manual. World **v31**.

## Decisão

Slice approach **B** — sem bump (fica v31):

1. `GovernanceDigitalTwin.maybeAutoCashCrisis(before, after, at)`
2. Gatilho: transição → Crit · cooldown `lastTwinScenario != CASH_CRISIS`
3. Wire em `CareerServiceImpl` adjust/set/`applyClubCashDelta`
4. Nav F113 · testes · docs

## Fora de scope (F114+)

- Flag persistida · Crisis Engine completo · bump v32 · mapa 5-previews

## Critérios de done

- [x] Helper · wire · teste · nav · docs · v31 (impl)
