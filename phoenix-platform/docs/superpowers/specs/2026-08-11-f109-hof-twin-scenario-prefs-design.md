# F109 — Living HoF Twin scenario prefs + sync — Design

**Data:** 2026-08-11  
**Specs:** [F108 cash unit sync](2026-08-11-f108-hof-cash-unit-sync-design.md) · [F104 Quo](2026-08-11-f104-hof-twin-status-quo-button-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Select Twin não sobrevive a reload nem sincroniza entre painéis. World **v31**.

## Decisão

Slice approach **2** — sem bump (fica v31):

1. `ManagerPrefs.govTwinScenario` · `GOV_TWIN_SCENARIO_EVENT`
2. Hook `useGovTwinScenario` — init prefs → lastTwinScenario → Quo
3. `GovTwinActions` consome hook · nav F109

## Fora de scope (F110+)

- Title hint Quo · LLD-028 · auto-log personality

## Critérios de done

- [x] Prefs · hook · GovTwinActions · nav · docs · v31 (impl)
