# F110 — Living HoF Commit title hint (Quo/busy) — Design

**Data:** 2026-08-12  
**Specs:** [F105 Commit disabled](2026-08-11-f105-hof-commit-disabled-on-quo-design.md) · [F109 Twin prefs](2026-08-11-f109-hof-twin-scenario-prefs-design.md)  
**Repo código:** `~/Phoenix Platform`  
**Status:** approved

## Problema

Commit disabled em Quo/busy sem feedback no hover. World **v31**.

## Decisão

Slice approach **A** — sem bump (fica v31):

1. `title` nativo no Commit: busy → `"Ocupado"` · Quo → `"Sem commit em Status Quo"` · prioridade busy > Quo
2. Nav F110 · README · LLD-030

## Fora de scope (F111+)

- Tooltip custom · i18n · hide Commit · LLD-028 · auto-log personality

## Critérios de done

- [x] Title Quo / busy · nav · docs · v31 (impl)
