# F115 — Living HoF Health Index liquidity dim — Design

**Data:** 2026-08-13  
**Specs:** [F112 HI UI](2026-08-12-f112-hof-health-index-ui-alias-design.md) · [F97 FH persisted](2026-08-10-f97-hof-financial-health-persisted-design.md) · LLD-028 §16  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

HI é só FH stub; falta 1ª dimensão LLD-028 (`liquidity`). World **v31**.

## Decisão

Slice approach **A** — bump **v32**:

1. `CareerRecord.liquidity` write-through (= `financialHealth(cash)`)
2. Save/load · migrate missing → derive from cash/FH
3. Bridge `hof.liquidity` · UI ` · Liq{n}` + HI intacto · nav F115

## Fora de scope (F116+)

- Solvabilidade/estabilidade/… · HealthIndex object · remover FH · ledger

## Critérios de done

- [x] liquidity · v32 · bridge · UI · testes · nav · docs (impl)
