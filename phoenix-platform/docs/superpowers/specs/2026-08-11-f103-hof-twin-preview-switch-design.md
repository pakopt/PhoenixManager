# F103 — Living HoF Twin preview switch — Design

**Data:** 2026-08-11  
**Specs:** [F102 GovTwinActions](2026-08-11-f102-hof-gov-twin-actions-design.md) · [F100 CASH_CRISIS](2026-08-11-f100-hof-twin-cash-crisis-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Status força preview INDUCT/STATUS_QUO; botões F102 commitam sem mostrar what-if do scenario. World **v31**.

## Decisão

Slice approach **1** — sem bump (fica v31):

1. Bridge `govtwin-preview` `{ scenario }` → status com `governanceTwin` do scenario
2. `GovTwinActions`: choice select + **Commit** · default `lastTwinScenario` ou `BUDGET_UP`
3. `GovTwin:` reflecte preview selecionado · nav F103

## Fora de scope (F104+)

- STATUS_QUO · mapa 5-previews no status · LLD-028

## Critérios de done

- [x] Bridge preview · select UI · Commit · nav · docs · v31 (impl)
