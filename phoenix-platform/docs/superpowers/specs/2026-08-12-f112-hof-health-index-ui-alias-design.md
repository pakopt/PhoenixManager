# F112 — Living HoF Health Index UI alias — Design

**Data:** 2026-08-12  
**Specs:** [F97 FH persisted](2026-08-10-f97-hof-financial-health-persisted-design.md) · [LLD-028](../../17-low-level-design/LLD-028-club-finance-economy-business-architecture.md) §16/§28  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

UI mostra `FH` (cash/100k stub) sem nomear o **Financial Health Index** LLD-028 lite. World **v31**.

## Decisão

Slice approach **A** — sem bump (fica v31):

1. `formatFinancialHealth` → ` · HI{n}{band}`
2. Nav F112 · README · LLD-028/030 notas (HI = FH lite · sem ledger)

## Fora de scope (F113+)

- Campo `healthIndex` · dims multi · double-entry · rename interno · Crisis auto-trigger

## Critérios de done

- [x] UI `HI` · nav · docs · tsc · v31 (impl)
