# F97 — Living HoF financialHealth persisted — Design

**Data:** 2026-08-10  
**Specs:** [F89 FH](2026-08-09-f89-hof-financial-health-design.md) · [F90 bands](2026-08-09-f90-hof-financial-health-bands-design.md) · [F96 UI](2026-08-09-f96-hof-board-cash-penalty-ui-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

FH/band só derivados. World **v29**.

## Decisão

Slice approach **1** — bump **v30**:

1. `CareerRecord.financialHealth` + `financialHealthBand` (defaults 100 / Strong)
2. Write-through em `ClubCash.adjust` · Twin commit · `fromSession`
3. Save/load campos · migrate: missing → derive from cash
4. Bridge prefer record fields · nav F97

## Fora de scope (F98+)

- LLD-028 Health Index · UI milhões

## Critérios de done

- [x] Campos · write-through · v30 · testes · nav · docs (impl)
