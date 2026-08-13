# F111 — Living HoF Twin history labels + personality axes — Design

**Data:** 2026-08-12  
**Specs:** [F110 Commit title](2026-08-12-f110-hof-commit-title-hint-design.md) · LLD-030 §8/§17  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Twin grava `label=""` · UI Pers sem nomes PT · history mostra só enum. World **v31**.

## Decisão

Slice approach **A** — sem bump (fica v31):

1. Engine: mapa PT por cenário Twin → `GovernanceHistoryEntry.label`
2. UI: GovHist `label (scenario)@at:±delta` · Pers nomes PT numa linha
3. Nav F111 · README · LLD-030 · teste label

## Labels Twin

| Scenario | Label |
|----------|--------|
| INDUCT_HOF | Indução HoF |
| FIRE_MANAGER | Despedir manager |
| NEW_INVESTOR | Novo investidor |
| BUDGET_UP | Aumento de orçamento |
| CASH_CRISIS | Crise de caixa |

## Fora de scope (F112+)

- Auto-log President/Ownership/Shareholders PT · i18n · eixos editáveis · LLD-028 · Crisis auto-trigger

## Critérios de done

- [x] Label Twin · formatters · nav · docs · teste · v31 (impl)
