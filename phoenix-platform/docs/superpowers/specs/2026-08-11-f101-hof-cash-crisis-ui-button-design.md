# F101 — Living HoF Cash Crisis UI button — Design

**Data:** 2026-08-11  
**Specs:** [F100 CASH_CRISIS](2026-08-11-f100-hof-twin-cash-crisis-design.md) · [F93 CashForm](2026-08-09-f93-hof-cash-ui-form-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Engine/bridge `govtwin-commit` + `CASH_CRISIS` existem; UI não expõe commit. World **v31**.

## Decisão

Slice approach **1** — sem bump (fica v31):

1. Hook `commitGovernanceTwin(scenario)` → `govtwin-commit`
2. Botão `Cash Crisis` junto a GovTwin (Dashboard + SidePanel)
3. Nav F101

## Fora de scope (F102+)

- Row completa Twin · preview switch · Command Palette · LLD-028

## Critérios de done

- [x] Hook · botão · nav · docs · v31 (impl)
