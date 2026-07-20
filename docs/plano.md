# Plano — Project Phoenix Manager

**Versão:** TS Marco 1  
**Actualizado:** 20 de Julho de 2026  
**Fase actual:** **TypeScript Engine Restart — Marco 1 concluído**

Documento vivo do roadmap. Design: [`docs/superpowers/specs/2026-07-20-typescript-engine-restart-design.md`](superpowers/specs/2026-07-20-typescript-engine-restart-design.md). Plano de implementação: [`docs/superpowers/plans/2026-07-20-typescript-engine-restart.md`](superpowers/plans/2026-07-20-typescript-engine-restart.md).

---

## Visão

**Engine First** — o coração é um Simulation Engine TypeScript puro. A UI (Electron + React) chega depois e nunca invertida.

```
UI → Application → Simulation Engine → Database (JSON shards)
```

## Stack activa

| Camada | Tecnologia |
|--------|------------|
| Linguagem | TypeScript (strict) |
| Monorepo | pnpm workspaces + Turborepo |
| Validação | Zod (`@phoenix/contracts`) |
| Testes | Vitest |
| Dados | JSON shards + índices + data packs |
| CLI | `pnpm season` |

## Marcos

| Marco | Conteúdo | Estado |
|-------|----------|--------|
| **1** | Archive Flutter + monorepo TS + database + calendar + match L3 + season CLI | ✅ |
| **2** | Electron + UI mínima “avançar dia” | ⏳ |
| **3** | Saves/patches + mods | ⏳ |
| **4** | Match camada 1 + competition-engine | ⏳ |
| **5+** | Transfer, finance, club-ai, editor | ⏳ |

## Marco 1 — checklist

| Item | Estado |
|------|--------|
| Flutter em `legacy/flutter/` | ✅ |
| Branch `legacy/flutter-v0.8` | ✅ |
| Packages engine (`contracts`…`simulation`) | ✅ |
| Seed 20 clubes / 400 jogadores | ✅ |
| `pnpm test` / `pnpm typecheck` / `pnpm season` | ✅ |
| Época 380 jogos &lt; 2s | ✅ (~5 ms no seed 42) |

## Legacy Flutter

O jogo Flutter/Dart PSE v0.8 (Fase E lançamento) está arquivado:

- Código: [`legacy/flutter/`](../legacy/flutter/)
- Docs de loja/roadmap antigos: [`docs/legacy/`](legacy/)
- Snapshot git: branch `legacy/flutter-v0.8`

## Comandos

```bash
pnpm install
pnpm test
pnpm typecheck
pnpm season -- --seed 42
```
