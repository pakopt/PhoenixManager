# Plano — Project Phoenix Manager

**Versão:** TS Marco 2  
**Actualizado:** 20 de Julho de 2026  
**Fase actual:** **TypeScript — Marco 2 Desktop**

Design Marco 1: [`docs/superpowers/specs/2026-07-20-typescript-engine-restart-design.md`](superpowers/specs/2026-07-20-typescript-engine-restart-design.md)  
Design Marco 2: [`docs/superpowers/specs/2026-07-20-marco-2-desktop-design.md`](superpowers/specs/2026-07-20-marco-2-desktop-design.md)

---

## Visão

**Engine First** — UI Electron fala com `GameSession` via IPC; a engine nunca importa React.

```
React UI → IPC → packages/application → simulation → database
```

## Stack activa

| Camada | Tecnologia |
|--------|------------|
| Desktop | Electron + electron-vite |
| UI | React + Tailwind + Zustand |
| Application | `@phoenix/application` (GameSession) |
| Engine | TypeScript packages (calendar, match L3, …) |
| Dados | JSON shards |

## Marcos

| Marco | Conteúdo | Estado |
|-------|----------|--------|
| **1** | Monorepo TS + database + season CLI | ✅ |
| **2** | Electron + avançar jornada + tabela + resultados | ✅ |
| **3** | Saves/patches + mods | ⏳ |
| **4** | Match camada 1 + competition-engine | ⏳ |
| **5+** | Transfer, finance, club-ai, editor | ⏳ |

## Comandos

```bash
pnpm install
pnpm test
pnpm typecheck
pnpm season -- --seed 42
pnpm dev:desktop
```
