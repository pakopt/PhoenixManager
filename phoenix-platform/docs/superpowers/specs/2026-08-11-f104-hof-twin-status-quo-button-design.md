# F104 — Living HoF Twin STATUS_QUO button — Design

**Data:** 2026-08-11  
**Specs:** [F103 preview switch](2026-08-11-f103-hof-twin-preview-switch-design.md) · [F102 GovTwinActions](2026-08-11-f102-hof-gov-twin-actions-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Row Twin omite `STATUS_QUO`; default era `BUDGET_UP`. World **v31**.

## Decisão

Slice approach **1** — sem bump (fica v31):

1. `GOV_TWIN_ACTIONS` + Quo no início
2. Default select: `lastTwinScenario` válido, senão `STATUS_QUO`
3. Commit Quo = no-op (engine) · nav F104

## Fora de scope (F105+)

- Commit disabled em Quo · LLD-028 · mapa previews

## Critérios de done

- [x] Quo na row · default · nav · docs · v31 (impl)
