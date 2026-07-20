# Phoenix Manager — Marco 5a Squad & Market Browse (Design)

**Date:** 2026-07-20  
**Status:** Approved  
**Depends on:** [Marco 4 Match L1 + Competition](2026-07-20-marco-4-match-l1-competition-design.md)

## Intent

Expose a **read-only squad** for the managed club and a **read-only market list** of other clubs’ players in the desktop UI — without buy/sell, fees, or finance. Prepares the UI surface for Marco 5a.2 (mutations).

## Decisions

| Topic | Choice |
|-------|--------|
| Scope | Browse only (no `clubId` changes) |
| Approach | Snapshot fields from `GameSession` (no new package yet) |
| Market size | All non-managed-club players in world (~380) |
| Filters | Client-side position filter on market |
| Save | Unchanged |

## Architecture

```
UI → Application (GameSession.getSnapshot) → world.players / clubs
```

- Helpers in `packages/application` (e.g. `player-lists.ts`) build squad + market rows from `WorldDatabase`.
- Desktop renderer still never imports DB/fs; only snapshot + IPC.
- No new IPC methods — data rides on existing start / advanceDay / load / getSnapshot.

## Snapshot shape

```ts
type SnapshotPlayer = {
  id: Slug;
  name: string;
  position: 'GK' | 'DF' | 'MF' | 'FW';
  rating: number;
  age: number;
};

type SnapshotMarketPlayer = SnapshotPlayer & {
  clubId: Slug;
  clubName: string;
};

SessionSnapshot += {
  squad: SnapshotPlayer[];
  market: SnapshotMarketPlayer[];
}
```

- `squad`: players with `clubId === managedClubId`, sorted by position order (GK→DF→MF→FW) then rating desc.
- `market`: players with `clubId !== managedClubId`, same sort, plus club name.

## Desktop UI

- Panel **Plantel**: table nome / pos / rating / idade.
- Panel **Mercado**: table nome / clube / pos / rating / idade; filter select Todas | GK | DF | MF | FW (client-side).
- No buy/sell controls.

## Testing / success

- Unit test: after `start`, `snapshot.squad` matches players of `managedClubId`; market excludes that club.
- `pnpm test` + `pnpm typecheck` green.
- Desktop shows both panels.

## Out of scope

- Transfer mutations / fees / budget
- Transfer window calendar
- Club AI bids
- Contracts / wages
- Pagination server-side (not needed at ~400 players)
- New `@phoenix/transfer` package (defer until mutations)

## Roadmap note

Update `docs/plano.md`: split **5+** into **5a** (this) ✅ when done; leave **5a.2** buy/sell, **5b** finance, **5c** club-ai, **5d** editor as later.
