# F93 — Living HoF Cash UI form — Design

**Data:** 2026-08-09  
**Specs:** [F87 adjust](2026-08-09-f87-hof-adjust-club-cash-design.md) · [F91 set](2026-08-09-f91-hof-set-club-cash-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Bridge `cash-adjust` / `cash-set` sem UI. World **v29**.

## Decisão

Slice approach **1** — sem bump (fica v29):

1. Hooks `adjustClubCash` / `setClubCash` em `useCareerBridge`
2. `CashForm` — toggle Adjust|Set · valor int · reason · Apply
3. Dashboard + SidePanel · nav F93

## Fora de scope (F94+)

- UI em milhões · FH persistido · LLD-028

## Critérios de done

- [x] CashForm · hooks · ambos ecrãs · nav · docs · v29 (impl)
