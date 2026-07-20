# Phoenix Manager — Marco 4 Match L1 + Competition (Design)

**Date:** 2026-07-20  
**Status:** Approved  
**Depends on:** [Marco 3.5 Entity Patches](2026-07-20-marco-3.5-entity-patches-design.md)

## Intent

Add a **thin Layer-1 match timeline** for the managed club’s highlight fixture, plus a **simple knockout cup**, without simulating L1 for every match or introducing player-level lineups yet.

## Decisions

| Topic | Choice |
|-------|--------|
| Scope | C — L1 for managed club fixtures only (league and/or cup) + simple cup |
| Snapshot highlight | At most one timeline: prefer cup L1 if both ran in the same `advanceDay`, else league L1 |
| Highlight match | Managed club (`managedClubId`; default `london-fc-en`) |
| L1 model | Minute timeline (1–90): chance / goal events; cap ~12 events |
| Rest of fixtures | Stay Layer 3 (Poisson club-level) |
| Cup | Knockout of 8 league clubs; QF → SF → Final |
| Cup schedule | One cup round after every 5 league matchdays (after MD 5, 10, 15) |
| Cup draws | Re-roll L3 until a winner (no penalties this marco) |
| Package | New `packages/competition` for knockout; `layer1.ts` in `match-engine` |

## Architecture

```
UI → Application (GameSession) → Simulation / Match / Competition → Database
```

- `match-engine/layer1.ts` — `simulateMatchDetailed` → `{ result, events[] }`
- `packages/competition` — bracket create / advance round
- `GameSession` — owns `managedClubId`, cup state; chooses L1 vs L3 per fixture
- Desktop renderer — still never imports DB/fs; only snapshot + IPC

## Layer 1

**Input:** home/away club ids + strengths + `rng` (same strength source as L3: reputation).

**Loop:** minutes 1–90. Each minute, each side may generate a “chance” with probability derived from the same λ family as L3 (scaled per minute). Failed chances → `chance` events; converted chances → `goal`. Goal totals need not match a separate L3 roll — L1 **is** the match result for that fixture.

**Output:**

```ts
type MatchEvent = {
  minute: number;
  type: 'chance' | 'goal';
  clubId: Slug;
  text: string;
};

type DetailedMatch = {
  result: MatchResult; // same shape as L3 — feeds table
  events: MatchEvent[]; // capped ~12; all goals kept, chances trimmed first
};
```

Count of `goal` events for home/away must equal `result.homeGoals` / `awayGoals`.

## Competition (cup)

- Competition id: `phoenix-cup-en`.
- Entrants: shuffle league club list with `seed`, take first **8** (deterministic).
- State: round (`qf` | `sf` | `final`) + ties `{ homeClubId, awayClubId, result? }` + `completed: boolean`.
- After league MD 5 / 10 / 15 (same `advanceDay`, after league fixtures): simulate that cup round (L1 if managed club plays in a tie, else L3). Draw → re-roll L3 until a winner.
- Winners form next round; three rounds total. Reputation bump on cup wins = same as league.

## Session / saves

Extend save **v2** (same version; additive fields):

- `managedClubId: Slug`
- `cup: { competitionId, round, ties, completed }` (shape owned by `competition` package)

Load:

1. `loadWorld` → club patches (3.5)
2. Restore league matchday / table / lastResults
3. Restore `managedClubId` (default `london-fc-en` if missing)
4. If `cup` missing on older saves → **regenerate bracket** from seed + current league clubs (progress may reset for cup only)

`StartSessionOptions` gains `managedClubId?: Slug`.

## Snapshot / UI

`SessionSnapshot` gains:

- `managedClubId`
- `highlight?: { homeName, awayName, homeGoals, awayGoals, events }`
- `cup?: { round, ties: SnapshotCupTie[], nextRoundAfterMatchday?: number }`

Desktop:

- Start: dropdown **Clube gerido** (20 clubs)
- After advance: **O teu jogo** (timeline) when highlight present
- **Taça** panel: current round + ties / results; or “próxima ronda após jornada X”

## Testing / success

- Unit tests: L1 event/goal consistency; cup bracket advance; session L1 only for managed fixture
- `pnpm test` + `pnpm typecheck` green
- `pnpm season` unchanged (league L3 path)
- Desktop shows highlight + cup

## Out of scope

- Player XI / scorers / tactics
- Penalties
- L1 for all matches
- Minute-by-minute “watch” UI
- Competition editor / multi-cup
- Transfers, finance, club-ai
