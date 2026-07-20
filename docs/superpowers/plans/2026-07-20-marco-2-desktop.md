# Marco 2 Desktop — Implementation Plan

> **For agentic workers:** Use `superpowers:executing-plans` or implement task-by-task.

**Goal:** Electron app with table + advance matchday + last results, backed by `packages/application` GameSession.

**Architecture:** electron-vite `apps/desktop` → IPC → `GameSession` → simulation. Renderer never touches fs/database.

**Tech Stack:** Electron, electron-vite, React, Tailwind, Zustand, Vitest, existing @phoenix packages.

## Global Constraints

- Day = one matchday
- No React in application/engines
- Snapshots JSON-serializable
- `pnpm season` must keep working
- macOS first

---

### Task 1: Simulation matchday helpers

**Files:**
- Create: `packages/simulation/src/league-table.ts`, `packages/simulation/src/simulate-matchday.ts`
- Modify: `packages/simulation/src/run-season.ts` to use helpers
- Test: existing `run-season.test.ts` still passes

- [ ] Extract `emptyRow`, `applyResult`, `sortTable`, `clubStrength`, `hashSlug`
- [ ] Export `simulateMatchday(world, fixtures, matchday, seed, table) → { results, table }`
- [ ] `pnpm --filter @phoenix/simulation test`

### Task 2: `packages/application` GameSession

**Files:**
- Create: `packages/application/` package
- Create: `src/game-session.ts`, `src/snapshot.ts`, `src/game-session.test.ts`

- [ ] `startSession` / `advanceDay` / `getSnapshot`
- [ ] Tests: start zeros; advance once fills results; 38 advances → finished
- [ ] Commit

### Task 3: `apps/desktop` electron-vite

**Files:**
- Create: `apps/desktop/` with main, preload, renderer
- Root scripts: `dev:desktop`, `build:desktop`

- [ ] Scaffold electron-vite + React + Tailwind
- [ ] IPC bridge for session
- [ ] Single screen UI
- [ ] `pnpm dev:desktop` works

### Task 4: Docs

- [ ] Mirror plan (this file)
- [ ] Update `docs/plano.md` Marco 2 ✅
- [ ] Commit spec + docs
