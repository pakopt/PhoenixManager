# F94 — Living HoF Weak → boardEffective — Design

**Data:** 2026-08-09  
**Specs:** [F92 Crit](2026-08-09-f92-hof-crit-board-effective-design.md) · [F90 bands](2026-08-09-f90-hof-financial-health-bands-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Só Crit penaliza Board. Weak também deve pesar. World **v29**.

## Decisão

Slice approach **1** — sem bump (fica v29):

1. `WEAK_BOARD_PENALTY = 2` · `when` Crit→5 · Weak→2 · else→0
2. Twin herda · nav F94

## Fora de scope (F95+)

- Ok/Strong penalties · FH persistido · LLD-028

## Critérios de done

- [x] Weak −2 · testes · nav · docs · v29 (impl)
