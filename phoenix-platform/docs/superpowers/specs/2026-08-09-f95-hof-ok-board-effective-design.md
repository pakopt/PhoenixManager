# F95 — Living HoF Ok → boardEffective — Design

**Data:** 2026-08-09  
**Specs:** [F94 Weak](2026-08-09-f94-hof-weak-board-effective-design.md) · [F92 Crit](2026-08-09-f92-hof-crit-board-effective-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Ok não pesa no Board. World **v29**.

## Decisão

Slice approach **1** — sem bump (fica v29):

1. `OK_BOARD_PENALTY = 1` · Crit→5 · Weak→2 · Ok→1 · Strong→0
2. Twin herda · nav F95

## Fora de scope (F96+)

- Strong penalty · FH persistido · UI penalty · LLD-028

## Critérios de done

- [x] Ok −1 · testes · nav · docs · v29 (impl)
