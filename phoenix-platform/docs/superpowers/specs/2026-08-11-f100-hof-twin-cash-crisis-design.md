# F100 — Living HoF Twin CASH_CRISIS — Design

**Data:** 2026-08-11  
**Specs:** [F76 BUDGET_UP](2026-08-08-f76-hof-twin-budget-up-design.md) · [F99 Sponsor](2026-08-11-f99-hof-sponsor-daily-stub-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Twin tem inflow de cash (`BUDGET_UP` / `NEW_INVESTOR`) mas sem scenario de crise de caixa. World **v30**.

## Decisão

Slice approach **1** — bump **v31**:

1. Enum `GovernanceTwinScenario.CASH_CRISIS`
2. Espelho inverso de `BUDGET_UP`: cash **−1_000_000** · board **−5** · pressure **+5** · satBonus **−5**
3. Preview/commit · CashHist reason `CASH_CRISIS` · FH write-through
4. Bridge `valueOf` (já genérico) · `BLOCK_VERSION = 31` · nav F100

## Fora de scope (F101+)

- Auto-trigger · Institutional Crisis Engine · LLD-028

## Critérios de done

- [x] Enum + Twin wire · teste · v31 · nav · docs (impl)
