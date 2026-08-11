# F107 — Living HoF CashForm unit prefs — Design

**Data:** 2026-08-11  
**Specs:** [F106 M/Raw toggle](2026-08-11-f106-hof-cash-form-m-raw-toggle-design.md) · [F56 prefs](2026-08-05-f56-hof-manager-prefs-unify-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Toggle M/Raw (F106) não sobrevive a reload. World **v31**.

## Decisão

Slice approach **1** — sem bump (fica v31):

1. `ManagerPrefs.cashUnit?: "millions" | "raw"`
2. `readCashUnit` / `writeCashUnit` em `workspaceStorage`
3. CashForm init + write ao trocar · nav F107

## Fora de scope (F108+)

- Event sync Dashboard/SidePanel · Twin select persist · LLD-028

## Critérios de done

- [x] Prefs · CashForm · nav · docs · v31 (impl)
