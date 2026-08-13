# F99 — Living HoF Sponsor daily stub — Design

**Data:** 2026-08-11  
**Specs:** [F88 wages/matchday](2026-08-09-f88-hof-periodic-cash-design.md) · [F97 FH persisted](2026-08-10-f97-hof-financial-health-persisted-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Só há outflow periódico (Wages). Falta stub de inflow diário (sponsor). World **v30**.

## Decisão

Slice approach **1** — sem bump (fica v30):

1. `ClubCash.SPONSOR_PER_DAY = +5_000` · `REASON_SPONSOR = "Sponsor"`
2. `advanceDays`: após Wages → `applyClubCashDelta(SPONSOR_PER_DAY * days, REASON_SPONSOR)`
3. CashHist / FH write-through via `adjust` existente
4. Nav F99

## Fora de scope (F100+)

- Twin `CASH_CRISIS` · contratos sponsor · LLD-028 · UI nova

## Critérios de done

- [x] Constantes + wire advanceDays · teste · nav · docs · v30 (impl)
