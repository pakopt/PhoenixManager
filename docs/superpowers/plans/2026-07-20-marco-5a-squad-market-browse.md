# Marco 5a Squad & Market Browse — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add read-only `squad` and `market` player lists to `SessionSnapshot` and show Plantel + Mercado panels on the desktop.

**Architecture:** Pure helpers in `packages/application` build sorted player rows from `world.players` / clubs; `GameSession.getSnapshot()` includes them; desktop filters market by position client-side. No new package, no IPC methods, no save changes.

**Tech Stack:** Existing TS monorepo, Vitest, Electron/React/Zustand desktop.

## Global Constraints

- Architecture: UI → Application → Simulation/Match/Competition → Database
- Renderer never imports DB/fs; only snapshot + IPC
- Browse only — no `clubId` mutations, fees, finance
- Squad = players with `clubId === managedClubId`
- Market = all other players (~380)
- Sort: position GK→DF→MF→FW, then rating desc
- Spec: `docs/superpowers/specs/2026-07-20-marco-5a-squad-market-browse-design.md`

## File map

| Path | Responsibility |
|------|----------------|
| `packages/application/src/player-lists.ts` | Build/sort squad + market rows |
| `packages/application/src/player-lists.test.ts` | Unit tests for helpers |
| `packages/application/src/snapshot.ts` | Types `SnapshotPlayer`, `SnapshotMarketPlayer`; extend `SessionSnapshot` |
| `packages/application/src/game-session.ts` | Wire lists into `getSnapshot` |
| `packages/application/src/game-session.test.ts` | Integration assertions |
| `packages/application/src/index.ts` | Export new snapshot types |
| `apps/desktop/src/App.tsx` | Plantel + Mercado UI |
| `docs/plano.md` | Marco 5a status |

---

### Task 1: Player list helpers + snapshot types

**Files:**
- Create: `packages/application/src/player-lists.ts`
- Create: `packages/application/src/player-lists.test.ts`
- Modify: `packages/application/src/snapshot.ts`
- Modify: `packages/application/src/index.ts`

**Interfaces:**
- Produces:
  - `SnapshotPlayer = { id, name, position: 'GK'|'DF'|'MF'|'FW', rating, age }`
  - `SnapshotMarketPlayer = SnapshotPlayer & { clubId, clubName }`
  - `buildSquad(players: Iterable<Player>, managedClubId: Slug): SnapshotPlayer[]`
  - `buildMarket(players: Iterable<Player>, clubs: Map<Slug, Club>, managedClubId: Slug): SnapshotMarketPlayer[]`
  - Position order constant: `GK=0, DF=1, MF=2, FW=3`

- [ ] **Step 1: Add types to `snapshot.ts` and export from `index.ts`**

```ts
export type SnapshotPlayer = {
  id: Slug;
  name: string;
  position: 'GK' | 'DF' | 'MF' | 'FW';
  rating: number;
  age: number;
};

export type SnapshotMarketPlayer = SnapshotPlayer & {
  clubId: Slug;
  clubName: string;
};

// SessionSnapshot +=
squad: SnapshotPlayer[];
market: SnapshotMarketPlayer[];
```

Export `SnapshotPlayer` and `SnapshotMarketPlayer` from `index.ts`.

- [ ] **Step 2: Write failing helper tests**

```ts
// packages/application/src/player-lists.test.ts
import { describe, expect, it } from 'vitest';
import type { Club, Player } from '@phoenix/contracts';
import { buildMarket, buildSquad } from './player-lists.js';

const clubs = new Map<string, Club>([
  ['london-fc-en', { id: 'london-fc-en', name: 'London FC', nationId: 'england', reputation: 80 }],
  ['rivals-en', { id: 'rivals-en', name: 'Rivals', nationId: 'england', reputation: 70 }],
]);

const players: Player[] = [
  {
    id: 'p-mf',
    name: 'Mid',
    clubId: 'london-fc-en',
    nationId: 'england',
    position: 'MF',
    rating: 70,
    age: 24,
  },
  {
    id: 'p-gk',
    name: 'Keep',
    clubId: 'london-fc-en',
    nationId: 'england',
    position: 'GK',
    rating: 60,
    age: 30,
  },
  {
    id: 'p-out',
    name: 'Away',
    clubId: 'rivals-en',
    nationId: 'england',
    position: 'FW',
    rating: 75,
    age: 22,
  },
];

describe('buildSquad', () => {
  it('filters managed club and sorts by position then rating', () => {
    const squad = buildSquad(players, 'london-fc-en');
    expect(squad.map((p) => p.id)).toEqual(['p-gk', 'p-mf']);
  });
});

describe('buildMarket', () => {
  it('excludes managed club and includes clubName', () => {
    const market = buildMarket(players, clubs, 'london-fc-en');
    expect(market).toHaveLength(1);
    expect(market[0]).toMatchObject({
      id: 'p-out',
      clubId: 'rivals-en',
      clubName: 'Rivals',
    });
  });
});
```

- [ ] **Step 3: Run tests — expect FAIL**

Run: `pnpm --filter @phoenix/application test -- player-lists`

- [ ] **Step 4: Implement `player-lists.ts`**

```ts
import type { Club, Player, Slug } from '@phoenix/contracts';
import type { SnapshotMarketPlayer, SnapshotPlayer } from './snapshot.js';

const POSITION_ORDER: Record<SnapshotPlayer['position'], number> = {
  GK: 0,
  DF: 1,
  MF: 2,
  FW: 3,
};

function comparePlayers(a: SnapshotPlayer, b: SnapshotPlayer): number {
  const pos = POSITION_ORDER[a.position] - POSITION_ORDER[b.position];
  if (pos !== 0) return pos;
  return b.rating - a.rating;
}

function toSnapshotPlayer(p: Player): SnapshotPlayer {
  return {
    id: p.id,
    name: p.name,
    position: p.position,
    rating: p.rating,
    age: p.age,
  };
}

export function buildSquad(
  players: Iterable<Player>,
  managedClubId: Slug,
): SnapshotPlayer[] {
  return [...players]
    .filter((p) => p.clubId === managedClubId)
    .map(toSnapshotPlayer)
    .sort(comparePlayers);
}

export function buildMarket(
  players: Iterable<Player>,
  clubs: ReadonlyMap<Slug, Club>,
  managedClubId: Slug,
): SnapshotMarketPlayer[] {
  return [...players]
    .filter((p) => p.clubId !== managedClubId)
    .map((p) => ({
      ...toSnapshotPlayer(p),
      clubId: p.clubId,
      clubName: clubs.get(p.clubId)?.name ?? p.clubId,
    }))
    .sort(comparePlayers);
}
```

- [ ] **Step 5: Tests PASS**

Run: `pnpm --filter @phoenix/application test -- player-lists`

- [ ] **Step 6: Commit**

```bash
git add packages/application/src/player-lists.ts packages/application/src/player-lists.test.ts packages/application/src/snapshot.ts packages/application/src/index.ts
git commit -m "$(cat <<'EOF'
feat(application): add squad and market player list helpers

EOF
)"
```

---

### Task 2: Wire GameSession snapshot + tests

**Files:**
- Modify: `packages/application/src/game-session.ts` (`getSnapshot`)
- Modify: `packages/application/src/game-session.test.ts`

**Interfaces:**
- Consumes: `buildSquad`, `buildMarket` from Task 1
- `getSnapshot` always sets `squad` and `market` (empty arrays only if no players — unexpected)

- [ ] **Step 1: Failing session test**

```ts
it('exposes managed squad and market excluding managed club', async () => {
  const snap = await session.start({
    databaseRoot,
    savesRoot,
    seed: 42,
    managedClubId: 'london-fc-en',
  });
  expect(snap.squad.length).toBeGreaterThan(0);
  expect(snap.squad.every((p) => /* club implied by managed */ true)).toBe(true);
  // Stronger: all squad ids belong to london via world — assert none of market share squad ids
  const squadIds = new Set(snap.squad.map((p) => p.id));
  expect(snap.market.every((p) => !squadIds.has(p.id))).toBe(true);
  expect(snap.market.every((p) => p.clubId !== 'london-fc-en')).toBe(true);
  expect(snap.market[0]?.clubName).toBeTruthy();
});
```

Use existing test harness paths from `game-session.test.ts`.

- [ ] **Step 2: Implement in `getSnapshot`**

```ts
import { buildMarket, buildSquad } from './player-lists.js';

// inside getSnapshot return:
squad: buildSquad(this.world.players.values(), this.managedClubId),
market: buildMarket(this.world.players.values(), this.world.clubs, this.managedClubId),
```

Confirm `WorldDatabase` exposes `players: Map<Slug, Player>` (it does via loader).

- [ ] **Step 3: Fix any TypeScript errors from `SessionSnapshot` requiring new fields** — all return sites of `getSnapshot` are one method; callers just receive wider type.

- [ ] **Step 4:** `pnpm --filter @phoenix/application test` — PASS

- [ ] **Step 5: Commit**

```bash
git add packages/application/src/game-session.ts packages/application/src/game-session.test.ts
git commit -m "$(cat <<'EOF'
feat(application): include squad and market in session snapshot

EOF
)"
```

---

### Task 3: Desktop UI + plano

**Files:**
- Modify: `apps/desktop/src/App.tsx`
- Modify: `docs/plano.md`

**UI:**
- After existing highlight/cup sections (or in a new `md:grid-cols-2` row): **Plantel** table and **Mercado** table.
- Local React state: `marketPositionFilter: 'ALL' | 'GK' | 'DF' | 'MF' | 'FW'` (default `ALL`).
- Filter: `snapshot.market.filter(p => filter === 'ALL' || p.position === filter)`.
- Reuse existing surface/border table styles from standings table.

- [ ] **Step 1: Add Plantel + Mercado panels** (Portuguese labels)

Plantel columns: Nome, Pos, Rating, Idade.  
Mercado columns: Nome, Clube, Pos, Rating, Idade + select filtro.

- [ ] **Step 2:** `pnpm --filter @phoenix/desktop typecheck` (and/or `pnpm typecheck`) — PASS

- [ ] **Step 3: Update `docs/plano.md`**

```markdown
| **5a** | Squad + mercado (read-only) | ✅ |
| **5a.2+** | Buy/sell, finance, club-ai, editor | ⏳ |
```

Set fase actual to Marco 5a; note plantel/mercado panels.

- [ ] **Step 4: Commit**

```bash
git add apps/desktop/src/App.tsx docs/plano.md
git commit -m "$(cat <<'EOF'
feat(desktop): show plantel and read-only transfer market

EOF
)"
```

---

## Self-review (plan vs spec)

| Spec | Task |
|------|------|
| SnapshotPlayer / SnapshotMarketPlayer | 1 |
| buildSquad / buildMarket sort | 1 |
| Wire getSnapshot | 2 |
| Plantel + Mercado UI + position filter | 3 |
| No mutations / save unchanged | all tasks (no save code) |
| plano split 5a | 3 |

No TBD placeholders. Types live in `snapshot.ts`; helpers in `player-lists.ts`.
