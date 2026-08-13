# F89 — Living HoF financialHealth stub (derived) — Design

**Data:** 2026-08-09  
**Specs:** [F88 periodic cash](2026-08-09-f88-hof-periodic-cash-design.md) · [LLD-028](../../17-low-level-design/LLD-028-club-finance-economy-business-architecture.md) (stub)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Há `clubCash` mas sem sinal de saúde financeira. World **v29**.

## Decisão

Slice approach **1** — sem bump (fica v29):

1. `ClubCash.financialHealth(cash) = (cash / 100_000).coerceIn(0, 100)`
2. Bridge `hof.financialHealth`
3. UI ` · FH{n}` junto a Cash · nav F89

## Fora de scope (F90+)

- Campo persistido · bands · Health Index LLD-028 completo

## Critérios de done

- [x] Função · bridge · UI · testes · nav · docs · v29 (impl)
