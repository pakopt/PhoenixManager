# F114 — Living HoF Twin 5-preview map — Design

**Data:** 2026-08-13  
**Specs:** [F103 preview switch](2026-08-11-f103-hof-twin-preview-switch-design.md) · [F113 auto-crisis](2026-08-12-f113-hof-cash-crisis-auto-trigger-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Status só tem um `governanceTwin` (selected). Falta mapa das 5 acções. World **v31**.

## Decisão

Slice approach **B** — sem bump (fica v31):

1. `GovernanceDigitalTwin.previewActions` — Induct→Fire→Investor→Budget→Crisis
2. Bridge `hof.governanceTwinPreviews[]`
3. UI linhas compactas + selected intacto · nav F114

## Fora de scope (F115+)

- Quo no mapa · cmd on-demand · Health Index dims · Crisis Engine

## Critérios de done

- [x] previewActions · bridge · UI · teste · nav · docs · v31 (impl)
