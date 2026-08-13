# F91 — Living HoF setClubCash — Design

**Data:** 2026-08-09  
**Specs:** [F87 adjustClubCash](2026-08-09-f87-hof-adjust-club-cash-design.md) · [F90 bands](2026-08-09-f90-hof-financial-health-bands-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Só existe `adjust` (delta). Falta set absoluto. World **v29**.

## Decisão

Slice approach **1** — sem bump (fica v29):

1. `ClubCash.set` → `adjust(amount − clubCash)`
2. `CareerService.setClubCash` — rejeita `amount < 0`, reason vazio, no-op se `amount == cash`
3. Bridge `cash-set` `{ amount, reason }` · nav F91

## Fora de scope (F92+)

- UI form · FH persistido · Health Index LLD-028

## Critérios de done

- [x] set · service · bridge · testes · nav · docs · v29 (impl)
