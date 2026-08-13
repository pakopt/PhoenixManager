# F92 — Living HoF Crit → boardEffective — Design

**Data:** 2026-08-09  
**Specs:** [F90 bands](2026-08-09-f90-hof-financial-health-bands-design.md) · [LLD-030](../../17-low-level-design/LLD-030-club-board-ownership-governance-architecture.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

FH/band existem mas não afectam Board. World **v29**.

## Decisão

Slice approach **1** — sem bump (fica v29):

1. Após `maxOf` em `HallOfFameRules.boardEffective`, se band==Crit → `−5` · clamp 0–100
2. Const `CRIT_BOARD_PENALTY = 5` · Weak/Ok/Strong = 0
3. Twin herda via `boardEffective` · nav F92

## Fora de scope (F93+)

- Penalty noutras bands · FH persistido · UI cash form · LLD-028

## Critérios de done

- [x] Penalty · testes · nav · docs · v29 (impl)
