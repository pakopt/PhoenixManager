# F108 — Living HoF CashForm unit sync — Design

**Data:** 2026-08-11  
**Specs:** [F107 unit prefs](2026-08-11-f107-hof-cash-unit-prefs-design.md) · [F56 prefs](2026-08-05-f56-hof-manager-prefs-unify-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Dois `CashForm` (Dashboard + SidePanel) não sincronizam M/Raw na mesma tab. World **v31**.

## Decisão

Slice approach **1** — sem bump (fica v31):

1. `CASH_UNIT_EVENT` · hook `useCashUnit` (espelho HoF sentiment)
2. CashForm consome hook · sync externo limpa `valueText`
3. Nav F108

## Fora de scope (F109+)

- Twin select persist · LLD-028

## Critérios de done

- [x] Hook · CashForm · nav · docs · v31 (impl)
