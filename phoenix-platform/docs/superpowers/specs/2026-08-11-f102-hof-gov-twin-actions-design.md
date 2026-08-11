# F102 — Living HoF GovTwinActions row — Design

**Data:** 2026-08-11  
**Specs:** [F101 Cash Crisis UI](2026-08-11-f101-hof-cash-crisis-ui-button-design.md) · [F100 CASH_CRISIS](2026-08-11-f100-hof-twin-cash-crisis-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Só existe botão `Cash Crisis`. Falta row para os outros scenarios Twin. World **v31**.

## Decisão

Slice approach **1** — sem bump (fica v31):

1. Componente `GovTwinActions` — Induct / Fire / Investor / Budget / Crisis
2. Hook F101 `commitGovernanceTwin` · Dashboard + SidePanel
3. Omite STATUS_QUO · nav F102

## Fora de scope (F103+)

- Preview switch · Command Palette · LLD-028

## Critérios de done

- [x] GovTwinActions · wire · nav · docs · v31 (impl)
