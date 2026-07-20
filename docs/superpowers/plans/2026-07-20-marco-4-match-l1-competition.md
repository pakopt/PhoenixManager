# Marco 4 Match L1 + Competition — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Layer-1 minute timeline for the managed club’s fixtures and a simple 8-team knockout cup wired through GameSession + desktop UI.

**Architecture:** `match-engine/layer1` produces `DetailedMatch`; new `@phoenix/competition` owns knockout bracket; `GameSession` picks L1 vs L3, schedules cup after MD 5/10/15, persists `managedClubId` + cup on save v2; desktop shows highlight timeline + taça panel.

**Tech Stack:** Existing pnpm/Turborepo TS monorepo, Zod contracts, Vitest, Electron IPC, React/Zustand desktop.

## Global Constraints

- Architecture: UI → Application → Simulation/Match/Competition → Database
- Day = matchday (not calendar date)
- Simulation packages must not import React
- Entities reference by slug IDs only
- L1 only for fixtures involving `managedClubId` (league and/or cup)
- Snapshot highlight: at most one timeline; prefer cup L1 if both ran in same `advanceDay`
- Cup draws: re-roll L3 until a winner (no penalties)
- Save v2 additive fields (do not bump version)
- Node >= 22; keep `pnpm season` league path on L3 only
- Spec: `docs/superpowers/specs/2026-07-20-marco-4-match-l1-competition-design.md`

## File map

| Path | Responsibility |
|------|----------------|
| `packages/match-engine/src/layer1.ts` | Minute timeline match sim |
| `packages/match-engine/src/layer1.test.ts` | L1 tests |
| `packages/match-engine/src/index.ts` | Export L1 |
| `packages/competition/*` | New package: knockout bracket |
| `packages/contracts/src/schemas.ts` | Save + cup Zod types |
| `packages/simulation/src/simulate-matchday.ts` | Optional L1 for managed club |
| `packages/application/src/snapshot.ts` | highlight / cup / managedClubId / clubs |
| `packages/application/src/game-session.ts` | Session orchestration |
| `packages/application/src/game-session.test.ts` | Session tests |
| `apps/desktop/electron/main.ts` + `preload.ts` | IPC `managedClubId` |
| `apps/desktop/src/store.ts` + `App.tsx` | UI |
| `docs/plano.md` | Marco 4 status |

---

### Task 1: Layer-1 match engine

**Files:**
- Create: `packages/match-engine/src/layer1.ts`
- Create: `packages/match-engine/src/layer1.test.ts`
- Modify: `packages/match-engine/src/index.ts`

**Interfaces:**
- Consumes: `Rng` from `@phoenix/shared`; `MatchResult`, `Slug` from `@phoenix/contracts`
- Produces:
  - `MatchEvent = { minute: number; type: 'chance' | 'goal'; clubId: Slug; text: string }`
  - `DetailedMatch = { result: MatchResult; events: MatchEvent[] }`
  - `simulateMatchDetailed(input: Layer1Input): DetailedMatch`
  - `Layer1Input` same fields as `Layer3Input`

- [ ] **Step 1: Write the failing test**

```ts
// packages/match-engine/src/layer1.test.ts
import { describe, expect, it } from 'vitest';
import { createRng } from '@phoenix/shared';
import { simulateMatchDetailed } from './layer1.js';

describe('simulateMatchDetailed layer-1', () => {
  it('is deterministic for the same seed and strengths', () => {
    const input = {
      homeClubId: 'london-fc-en' as const,
      awayClubId: 'capital-blues-en' as const,
      homeStrength: 75,
      awayStrength: 70,
    };
    const a = simulateMatchDetailed({ ...input, rng: createRng(42) });
    const b = simulateMatchDetailed({ ...input, rng: createRng(42) });
    expect(a).toEqual(b);
  });

  it('goal events match result totals', () => {
    const detailed = simulateMatchDetailed({
      homeClubId: 'a',
      awayClubId: 'b',
      homeStrength: 80,
      awayStrength: 60,
      rng: createRng(7),
    });
    const homeGoals = detailed.events.filter(
      (e) => e.type === 'goal' && e.clubId === 'a',
    ).length;
    const awayGoals = detailed.events.filter(
      (e) => e.type === 'goal' && e.clubId === 'b',
    ).length;
    expect(homeGoals).toBe(detailed.result.homeGoals);
    expect(awayGoals).toBe(detailed.result.awayGoals);
  });

  it('keeps all goals when trimming to ~12 events', () => {
    const detailed = simulateMatchDetailed({
      homeClubId: 'a',
      awayClubId: 'b',
      homeStrength: 99,
      awayStrength: 99,
      rng: createRng(123),
    });
    expect(detailed.events.length).toBeLessThanOrEqual(12);
    const goals = detailed.events.filter((e) => e.type === 'goal').length;
    expect(goals).toBe(detailed.result.homeGoals + detailed.result.awayGoals);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pnpm --filter @phoenix/match-engine test`

Expected: FAIL — cannot resolve `./layer1.js` / `simulateMatchDetailed` missing

- [ ] **Step 3: Implement `layer1.ts`**

```ts
// packages/match-engine/src/layer1.ts
import type { MatchResult, Slug } from '@phoenix/contracts';
import type { Rng } from '@phoenix/shared';

export type Layer1Input = {
  homeClubId: Slug;
  awayClubId: Slug;
  homeStrength: number;
  awayStrength: number;
  rng: Rng;
};

export type MatchEvent = {
  minute: number;
  type: 'chance' | 'goal';
  clubId: Slug;
  text: string;
};

export type DetailedMatch = {
  result: MatchResult;
  events: MatchEvent[];
};

function lambdas(homeStrength: number, awayStrength: number): { home: number; away: number } {
  const homeAttack = homeStrength / 70;
  const awayAttack = awayStrength / 70;
  return {
    home: Math.max(0.2, 1.15 * homeAttack * (1.1 - awayAttack * 0.35) + 0.25),
    away: Math.max(0.2, 1.05 * awayAttack * (1.1 - homeAttack * 0.35)),
  };
}

function minuteP(lambda: number): number {
  return 1 - Math.exp(-lambda / 90);
}

function trimEvents(events: MatchEvent[], max = 12): MatchEvent[] {
  if (events.length <= max) return events;
  const goals = events.filter((e) => e.type === 'goal');
  const chances = events.filter((e) => e.type === 'chance');
  const room = Math.max(0, max - goals.length);
  return [...goals, ...chances.slice(0, room)].sort((a, b) => a.minute - b.minute);
}

export function simulateMatchDetailed(input: Layer1Input): DetailedMatch {
  const { home, away } = lambdas(input.homeStrength, input.awayStrength);
  const pHome = minuteP(home);
  const pAway = minuteP(away);
  const convert = 0.35;

  let homeGoals = 0;
  let awayGoals = 0;
  const raw: MatchEvent[] = [];

  for (let minute = 1; minute <= 90; minute += 1) {
    if (input.rng.next() < pHome) {
      if (input.rng.next() < convert) {
        homeGoals += 1;
        raw.push({
          minute,
          type: 'goal',
          clubId: input.homeClubId,
          text: `Golo! (${minute}')`,
        });
      } else {
        raw.push({
          minute,
          type: 'chance',
          clubId: input.homeClubId,
          text: `Oportunidade falhada (${minute}')`,
        });
      }
    }
    if (input.rng.next() < pAway) {
      if (input.rng.next() < convert) {
        awayGoals += 1;
        raw.push({
          minute,
          type: 'goal',
          clubId: input.awayClubId,
          text: `Golo! (${minute}')`,
        });
      } else {
        raw.push({
          minute,
          type: 'chance',
          clubId: input.awayClubId,
          text: `Oportunidade falhada (${minute}')`,
        });
      }
    }
  }

  return {
    result: {
      homeClubId: input.homeClubId,
      awayClubId: input.awayClubId,
      homeGoals,
      awayGoals,
    },
    events: trimEvents(raw),
  };
}
```

Export from `index.ts`:

```ts
export { simulateMatch } from './layer3.js';
export type { Layer3Input } from './layer3.js';
export { simulateMatchDetailed } from './layer1.js';
export type { Layer1Input, MatchEvent, DetailedMatch } from './layer1.js';
```

- [ ] **Step 4: Run tests**

Run: `pnpm --filter @phoenix/match-engine test`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add packages/match-engine/src/layer1.ts packages/match-engine/src/layer1.test.ts packages/match-engine/src/index.ts
git commit -m "$(cat <<'EOF'
feat(match-engine): add layer-1 minute timeline simulation

EOF
)"
```

---

### Task 2: Contracts — cup + managedClubId on save

Do contracts **before** the competition package so knockout helpers share one type source.

**Files:**
- Modify: `packages/contracts/src/schemas.ts`
- Modify: `packages/contracts/src/index.ts`
- Modify: `packages/contracts/src/schemas.test.ts` (if present)

**Interfaces:**
- Produces:
  - `cupRoundSchema` / `CupRound`
  - `cupTieSchema` / `CupTie`
  - `cupStateSchema` / `CupState`
  - `saveGameSchema.managedClubId?: Slug`
  - `saveGameSchema.cup?: CupState`

- [ ] **Step 1: Add schemas**

```ts
export const cupRoundSchema = z.enum(['qf', 'sf', 'final']);
export const cupTieSchema = z.object({
  homeClubId: slugSchema,
  awayClubId: slugSchema,
  result: matchResultSchema.optional(),
});
export const cupStateSchema = z.object({
  competitionId: slugSchema,
  round: cupRoundSchema,
  ties: z.array(cupTieSchema),
  completed: z.boolean(),
});
export type CupRound = z.infer<typeof cupRoundSchema>;
export type CupTie = z.infer<typeof cupTieSchema>;
export type CupState = z.infer<typeof cupStateSchema>;

// inside saveGameSchema:
managedClubId: slugSchema.optional(),
cup: cupStateSchema.optional(),
```

Export from `index.ts`.

- [ ] **Step 2: Run** `pnpm --filter @phoenix/contracts test && pnpm --filter @phoenix/contracts build` — PASS

- [ ] **Step 3: Commit**

```bash
git add packages/contracts
git commit -m "$(cat <<'EOF'
feat(contracts): add managedClubId and cup to save v2 schema

EOF
)"
```

---

### Task 3: `@phoenix/competition` knockout package

**Files:**
- Create: `packages/competition/package.json`
- Create: `packages/competition/tsconfig.json`
- Create: `packages/competition/vitest.config.ts`
- Create: `packages/competition/src/knockout.ts`
- Create: `packages/competition/src/knockout.test.ts`
- Create: `packages/competition/src/index.ts`

**Interfaces:**
- Consumes: `CupState`, `CupRound`, `Slug`, `MatchResult` from `@phoenix/contracts`; `createRng` from `@phoenix/shared`
- Produces:
  - `pickEntrants(clubIds, seed, n = 8): Slug[]`
  - `createKnockoutCup({ competitionId, clubIds, seed }): CupState` — round `qf`, 4 ties, `completed: false`
  - `cupRoundAfterMatchday(matchday): CupRound | null` — 5→qf, 10→sf, 15→final
  - `nextCupRound(round): CupRound | null`
  - `advanceKnockout(state, results: MatchResult[]): CupState` — attach results; build next round from winners; after final → `completed: true`

- [ ] **Step 1: Scaffold package** (mirror `packages/calendar`: name `@phoenix/competition`, deps contracts + shared)

- [ ] **Step 2: Write failing tests**

```ts
import { describe, expect, it } from 'vitest';
import {
  advanceKnockout,
  createKnockoutCup,
  cupRoundAfterMatchday,
  pickEntrants,
} from './knockout.js';

const clubs = [
  'c1', 'c2', 'c3', 'c4', 'c5', 'c6', 'c7', 'c8', 'c9', 'c10',
] as const;

describe('knockout', () => {
  it('pickEntrants is deterministic and size n', () => {
    expect(pickEntrants(clubs, 42, 8)).toEqual(pickEntrants(clubs, 42, 8));
    expect(pickEntrants(clubs, 42, 8)).toHaveLength(8);
  });

  it('createKnockoutCup starts at qf with 4 ties', () => {
    const cup = createKnockoutCup({
      competitionId: 'phoenix-cup-en',
      clubIds: [...clubs],
      seed: 1,
    });
    expect(cup.round).toBe('qf');
    expect(cup.ties).toHaveLength(4);
    expect(cup.completed).toBe(false);
  });

  it('cupRoundAfterMatchday maps 5/10/15', () => {
    expect(cupRoundAfterMatchday(5)).toBe('qf');
    expect(cupRoundAfterMatchday(10)).toBe('sf');
    expect(cupRoundAfterMatchday(15)).toBe('final');
    expect(cupRoundAfterMatchday(6)).toBeNull();
  });

  it('advanceKnockout builds sf from qf winners', () => {
    const cup = createKnockoutCup({
      competitionId: 'phoenix-cup-en',
      clubIds: [...clubs],
      seed: 2,
    });
    const results = cup.ties.map((t, i) => ({
      homeClubId: t.homeClubId,
      awayClubId: t.awayClubId,
      homeGoals: i % 2 === 0 ? 2 : 0,
      awayGoals: i % 2 === 0 ? 0 : 2,
    }));
    const next = advanceKnockout(cup, results);
    expect(next.round).toBe('sf');
    expect(next.ties).toHaveLength(2);
  });
});
```

- [ ] **Step 3: Run** `pnpm --filter @phoenix/competition test` — expect FAIL

- [ ] **Step 4: Implement `knockout.ts`** — Fisher–Yates shuffle; pair consecutive entrants; winners by goals (caller guarantees no draws); pair winners for next round

- [ ] **Step 5: Run** `pnpm --filter @phoenix/competition test && pnpm --filter @phoenix/competition build` — PASS

- [ ] **Step 6: Commit**

```bash
git add packages/competition
git commit -m "$(cat <<'EOF'
feat(competition): add 8-team knockout cup helpers

EOF
)"
```

---

### Task 4: simulateMatchday optional L1 highlight

**Files:**
- Modify: `packages/simulation/src/simulate-matchday.ts`
- Create: `packages/simulation/src/simulate-matchday.test.ts` (or extend existing test file)

**Interfaces:**
- Input adds `highlightClubId?: Slug`
- Output adds `highlight?: DetailedMatch` from `@phoenix/match-engine`

- [ ] **Step 1: Failing test** — when `highlightClubId` is in a matchday fixture, `highlight` is defined and that fixture’s entry in `results` equals `highlight.result`

- [ ] **Step 2: Implement** — matching fixture uses `simulateMatchDetailed`; others `simulateMatch`; at most one highlight (first match)

- [ ] **Step 3:** `pnpm --filter @phoenix/simulation test` — PASS

- [ ] **Step 4: Commit**

```bash
git add packages/simulation
git commit -m "$(cat <<'EOF'
feat(simulation): optional layer-1 highlight on matchday

EOF
)"
```

---

### Task 5: GameSession — managed club, cup, snapshot, save/load

**Files:**
- Modify: `packages/application/package.json` — add `@phoenix/competition` and `@phoenix/match-engine` if needed
- Modify: `packages/application/src/snapshot.ts`
- Modify: `packages/application/src/game-session.ts`
- Modify: `packages/application/src/game-session.test.ts`
- Modify: `packages/application/src/index.ts` if needed

**Interfaces:**
- `StartSessionOptions.managedClubId?: Slug` (default `london-fc-en`)
- Snapshot adds `managedClubId`, `clubs: { id; name }[]`, `highlight?`, `cup?`
- Private: `managedClubId`, `cup: CupState`, last highlight source for prefer-cup
- `advanceDay`: league with `highlightClubId` → reputation → if `cupRoundAfterMatchday(next) === cup.round` && !completed, simulate ties (L1 if managed in tie else L3; draw → re-roll L3) → `advanceKnockout` → cup L1 overrides league highlight
- `save` / `load`: persist/restore `managedClubId` + `cup`; missing cup → `createKnockoutCup`

- [ ] **Step 1: Failing tests**

```ts
it('exposes highlight for managed club league fixture', async () => { /* … */ });
it('runs cup round after matchday 5', async () => { /* advance 5×; cup advanced past qf */ });
it('persists managedClubId and cup on save/load', async () => { /* round-trip */ });
```

- [ ] **Step 2: Implement session + snapshot**

Cup tie helper:

```ts
function simulateDecisiveTie(/* strengths, rng, managedClubId, tie */): {
  result: MatchResult;
  detailed?: DetailedMatch;
} {
  // L1 if managed plays; else L3
  // while draw: L3 re-roll with rng.fork(salt++)
}
```

`nextRoundAfterMatchday`: smallest of 5/10/15 greater than current matchday if cup not completed.

- [ ] **Step 3:** `pnpm --filter @phoenix/application test` — PASS

- [ ] **Step 4: Commit**

```bash
git add packages/application
git commit -m "$(cat <<'EOF'
feat(application): wire managed club L1 and knockout cup into session

EOF
)"
```

---

### Task 6: Desktop IPC + UI

**Files:**
- Modify: `apps/desktop/electron/main.ts`
- Modify: `apps/desktop/electron/preload.ts`
- Modify: `apps/desktop/src/store.ts`
- Modify: `apps/desktop/src/App.tsx`
- Modify: desktop global `window.phoenix` types if separate file

**UI:**
- Dropdown **Clube gerido** from `snapshot.clubs`; change → `start(42, mods, id)`
- Panel **O teu jogo** when `highlight` present (score + events)
- Panel **Taça** (round label, ties, or “Próxima ronda após jornada X”)

- [ ] **Step 1: IPC + store** — pass `managedClubId` through `session:start`

- [ ] **Step 2: App.tsx panels**

- [ ] **Step 3:** `pnpm typecheck` (and desktop build if needed) — PASS

- [ ] **Step 4: Commit**

```bash
git add apps/desktop
git commit -m "$(cat <<'EOF'
feat(desktop): managed club selector, match timeline, and cup panel

EOF
)"
```

---

### Task 7: Docs

**Files:**
- Modify: `docs/plano.md` — Marco 4 ✅; fase actual Marco 4

- [ ] **Step 1: Update plano** (only after Tasks 1–6 done)

- [ ] **Step 2: Commit**

```bash
git add docs/plano.md
git commit -m "$(cat <<'EOF'
docs: mark Marco 4 complete in plano

EOF
)"
```

---

## Self-review (plan vs spec)

| Spec requirement | Task |
|------------------|------|
| L1 timeline chance/goal, ~12 events | 1 |
| L1 is the real result | 1 + 4 |
| Knockout package 8 clubs | 3 |
| Cup after MD 5/10/15 | 3 + 5 |
| Draw re-roll L3 | 5 |
| Prefer cup highlight | 5 |
| managedClubId default london-fc-en | 5 |
| Save v2 additive fields | 2 + 5 |
| Missing cup → regenerate | 5 |
| Desktop UI | 6 |
| season CLI stays L3 | 4 (flag unused by CLI) |

Contracts own `CupState` (Task 2) before competition helpers (Task 3). No TBD placeholders.
