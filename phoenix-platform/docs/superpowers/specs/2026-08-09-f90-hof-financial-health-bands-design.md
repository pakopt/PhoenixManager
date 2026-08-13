# F90 — Living HoF financialHealth bands — Design

**Data:** 2026-08-09  
**Specs:** [F89 financialHealth](2026-08-09-f89-hof-financial-health-design.md) · [LLD-028](../../17-low-level-design/LLD-028-club-finance-economy-business-architecture.md) (stub)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

FH numérico sem label legível. World **v29**.

## Decisão

Slice approach **1** — sem bump (fica v29):

1. `ClubCash.financialHealthBand(health)` → Crit/Weak/Ok/Strong  
   (`0–24` · `25–49` · `50–74` · `75–100`)
2. Bridge `hof.financialHealthBand`
3. UI ` · FH{n} {band}` · nav F90

## Fora de scope (F91+)

- Campo persistido · Health Index LLD-028 · `setClubCash`

## Critérios de done

- [x] Band · bridge · UI · testes · nav · docs · v29 (impl)
