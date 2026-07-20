# Phoenix Manager — Marco 5a.2 Buy / Sell Transfers (Design)

**Date:** 2026-07-20  
**Status:** Approved  
**Depends on:** [Marco 5a Squad & Market Browse](2026-07-20-marco-5a-squad-market-browse-design.md)

## Intent

Allow the managed club to **buy** and **sell** players with a symbolic fee and a minimal cash balance — persisted via save v2 `balance` + `patches.players`. No full finance system yet (that is 5b).

## Decisions

| Topic | Choice |
|-------|--------|
| Approach | Mutations on `GameSession` + player entity patches (no new package) |
| Fee | `rating * 100_000` |
| Starting balance | `5_000_000` on new session; missing on load → same default |
| Buy | Requires `balance >= fee`; sets `player.clubId = managedClubId`; deducts fee |
| Sell | Player must be on managed squad; reject if squad size `<= 11`; credit fee; move to lowest-rep other club |
| Sell destination | League club with lowest reputation ≠ managed (tie-break: slug ascending) |
| Negotiation / AI / wages | Out of scope |

## Architecture

```
UI → IPC buyPlayer/sellPlayer → GameSession → world.players + balance
Save: balance + patches.players (diff vs baseline after core+mods)
```

- Pure helpers: `transferFee(rating)`, `pickSellDestinationClub(clubs, managedClubId)`, `diffPlayers` / `applyPlayerPatches` (mirror club patches).
- Baseline players Map kept like `baselineClubs` after world load.
- Snapshot gains `balance: number`; market/squad rows may include `fee: number` (or UI computes from rating).

## Rules (exact)

```ts
transferFee(rating: number): number // rating * 100_000

buyPlayer(playerId):
  player must exist and player.clubId !== managedClubId
  fee = transferFee(player.rating)
  if balance < fee → throw "Saldo insuficiente"
  player.clubId = managedClubId
  balance -= fee

sellPlayer(playerId):
  player must exist and player.clubId === managedClubId
  if squadSize(managed) <= 11 → throw "Plantel mínimo de 11 jogadores"
  fee = transferFee(player.rating)
  player.clubId = pickSellDestinationClub(...)
  balance += fee
```

## Save v2 (additive)

```json
{
  "version": 2,
  "balance": 5000000,
  "patches": {
    "clubs": [],
    "players": [{ "id": "…", "changes": { "clubId": "london-fc-en" } }]
  }
}
```

Load order: `loadWorld` → club patches → player patches → restore matchday/table/cup → `balance` (default 5M if absent).

## Desktop / IPC

- Display **Caixa** in header.
- Mercado: Fee + **Comprar** (disabled if fee > balance).
- Plantel: Fee + **Vender** (disabled if squad length ≤ 11).
- IPC: `session:buyPlayer(playerId)`, `session:sellPlayer(playerId)` → return updated `SessionSnapshot`.
- Errors surfaced via existing store error string.

## Testing / success

- Unit: fee formula; sell destination deterministic; buy/sell mutate clubId + balance; reject insufficient funds / min squad.
- Integration: save/load restores balance and player clubIds via patches.
- Desktop wired; `pnpm test` + `pnpm typecheck` green.

## Out of scope

- Gate receipts, wages, P&L (5b)
- Transfer window / listing period
- Club AI counter-offers
- Free agents / loan
- `@phoenix/transfer` package extraction

## Roadmap

Mark **5a.2** ✅ in `docs/plano.md`; leave **5b** finance, **5c** club-ai, **5d** editor pending.
