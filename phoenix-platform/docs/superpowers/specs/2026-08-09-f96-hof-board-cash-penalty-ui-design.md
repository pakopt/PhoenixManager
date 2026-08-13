# F96 — Living HoF boardCashPenalty UI — Design

**Data:** 2026-08-09  
**Specs:** [F95 Ok](2026-08-09-f95-hof-ok-board-effective-design.md) · [F90 bands](2026-08-09-f90-hof-financial-health-bands-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Penalty Crit/Weak/Ok existe no engine mas não aparece na UI. World **v29**.

## Decisão

Slice approach **1** — sem bump (fica v29):

1. `HallOfFameRules.boardCashPenalty(cash)` · reutilizado por `boardEffective`
2. Bridge `hof.boardCashPenalty`
3. UI ` · −{n}` junto a FH se `n>0` · omit Strong · nav F96

## Fora de scope (F97+)

- FH persistido · UI milhões · LLD-028 · sempre mostrar `−0`

## Critérios de done

- [x] Função · bridge · UI · testes · nav · docs · v29 (impl)
