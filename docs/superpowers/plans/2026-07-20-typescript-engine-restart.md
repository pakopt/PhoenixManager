# Phoenix Manager — Recomeço TypeScript (Marco 1)

> **For agentic workers:** Prefer `superpowers:subagent-driven-development` ou `superpowers:executing-plans`.

**Goal:** Arquivar Flutter e entregar um monorepo TS onde `pnpm season` carrega um data pack, simula uma liga de 20 clubes (camada 3) e imprime a tabela — sem UI.

**Architecture:** Thin vertical slice. UI nunca entra nos packages de engine. Dados = JSON shards + slugs + Maps em memória. Motores comunicam por contratos Zod.

**Tech Stack:** TypeScript strict, pnpm workspaces, Turborepo, Zod, Vitest, Node 22+, tsc.

**Status:** Marco 1 implementado (2026-07-20). Design: [`../specs/2026-07-20-typescript-engine-restart-design.md`](../specs/2026-07-20-typescript-engine-restart-design.md).

## Tasks

- [x] Task 1: Spec + arquivo Flutter → `legacy/flutter/` + branch `legacy/flutter-v0.8`
- [x] Task 2: Scaffold pnpm + Turborepo
- [x] Task 3: Contracts + shared RNG
- [x] Task 4: Database loader + core seed (20 clubs / 400 players)
- [x] Task 5: Calendar round-robin
- [x] Task 6: Match engine layer-3
- [x] Task 7: Simulation + CLI `pnpm season`
- [x] Task 8: Docs + hygiene

## Critério de done

```bash
pnpm install
pnpm test
pnpm typecheck
pnpm season -- --seed 42
```

## Fora de scope (próximos marcos)

Electron, editor, saves/patches runtime, transfer/finance/club-ai, match camadas 1–2, marcadores individuais, migração de saves Flutter.
