# Phoenix Manager — Marco 2 Desktop (Design)

**Date:** 2026-07-20  
**Status:** Approved (sections 1–3)  
**Depends on:** [Marco 1 TS Engine Restart](2026-07-20-typescript-engine-restart-design.md)

## Intent

Provar o loop interactivo **Engine First** num desktop Electron: a UI pede “avançar jornada”; a simulação corre no main process via um package `application` partilhável com a CLI.

```
React UI → IPC → GameSession (application) → simulation / calendar / match / database
```

## Decisions

| Topic | Choice |
|-------|--------|
| UX | Table + advance matchday + last matchday results |
| Architecture | Shared `packages/application`; Electron main is a thin IPC adapter |
| Desktop scaffold | electron-vite monolithic (`apps/desktop`) |
| UI stack | React + Tailwind + shadcn/ui (Button, Table); Zustand for snapshot |
| “Day” meaning | One league **matchday** (not calendar date) |
| Platform | macOS first |

## Section 1 — Architecture

```
apps/desktop            electron-vite (main + preload + renderer)
packages/application    GameSession: start / advanceDay / getSnapshot
packages/simulation     reused (+ matchday helpers extracted for advanceDay)
packages/ui             optional thin shared presentational bits (or inline in desktop for M2)
```

- Renderer never imports `@phoenix/database` or Node `fs`.
- Snapshots are plain JSON (no `Map`).
- One `GameSession` instance lives in the main process.

## Section 2 — UI + session API

### Single screen

1. Header: competition name, `Jornada N / 38`, seed  
2. Last results list (empty before first advance)  
3. League table  
4. **Avançar jornada** (disabled when `finished`) + **Nova sessão**

### `GameSession` API

```ts
startSession({ databaseRoot, seed, competitionId? }) → SessionSnapshot
advanceDay() → SessionSnapshot
getSnapshot() → SessionSnapshot
```

`SessionSnapshot` fields: `matchday`, `totalMatchdays`, `finished`, `table` (with `clubName`), `lastResults`, `seed`, `competitionName`.

### IPC

Preload exposes `window.phoenix.session.{ start, advanceDay, getSnapshot }`.

## Section 3 — Tooling + done

| Piece | Choice |
|-------|--------|
| App | `apps/desktop` (electron-vite) |
| Scripts | `pnpm dev:desktop`, `pnpm build:desktop` |
| Tests | Vitest on `application` (advance 1 day, finish after 38) |
| Regression | `pnpm season` still works |

### Done when

```bash
pnpm test
pnpm typecheck
pnpm dev:desktop
```

App: zero table → advance fills results + table → after 38 matchdays button disables.

### Out of scope

Saves/patches, club selection, “run full season” button, TanStack Router, match layer 1, store packaging.
