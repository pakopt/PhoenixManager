# F106 — Living HoF CashForm M/Raw toggle — Design

**Data:** 2026-08-11  
**Specs:** [F98 CashForm millions](2026-08-10-f98-hof-cash-form-millions-design.md) · [F93 CashForm](2026-08-09-f93-hof-cash-ui-form-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

CashForm só aceita milhões (F98); falta entrada em unidades raw. World **v31**.

## Decisão

Slice approach **1** — sem bump (fica v31):

1. Choice **M** / **Raw** (default M)
2. M → `×1e6` · Raw → `Math.round(n)` absoluto
3. Trocar unidade limpa o valor · bridge intacto · nav F106

## Fora de scope (F107+)

- localStorage · LLD-028 · engine

## Critérios de done

- [x] Toggle M/Raw · labels/placeholders · nav · docs · v31 (impl)
