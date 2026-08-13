# F98 — Living HoF CashForm millions — Design

**Data:** 2026-08-10  
**Specs:** [F93 CashForm](2026-08-09-f93-hof-cash-ui-form-design.md) · [F97 FH persisted](2026-08-10-f97-hof-financial-health-persisted-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

CashForm pede inteiros raw. World **v30**.

## Decisão

Slice approach **1** — sem bump (fica v30):

1. Input milhões decimais → `Math.round(n * 1_000_000)` para bridge
2. Labels `Delta (M)` / `Amount (M)` · placeholders `0.25` / `10`
3. Nav F98

## Fora de scope (F99+)

- Toggle M/raw · LLD-028 · engine change

## Critérios de done

- [x] CashForm milhões · nav · docs · v30 (impl)
