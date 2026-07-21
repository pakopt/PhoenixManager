# Phoenix Manager — Marco 5c Club AI (Design)

**Date:** 2026-07-21  
**Status:** Approved  
**Depends on:** [Marco 5b Finance Ledger](2026-07-21-marco-5b-finance-design.md)

## Intent

Make the transfer market **alive**: NPC clubs trade among themselves each matchday, **respond** to the managed club’s buy/sell proposals (accept / reject / one counter), and **bid** for managed players (inbox). Only the managed club has a cash balance; NPC behaviour is symbolic (rating, squad size, reputation). No multi-club finance or multi-turn auctions.

## Decisions

| Topic | Choice |
|-------|--------|
| Approach | Helpers in `@phoenix/application` (`club-ai.ts`) + state on `GameSession` (no new package) |
| Scope | NPC↔NPC + player↔NPC + NPC bids on managed squad |
| Timing | Hybrid: player proposals resolve immediately; NPC↔NPC + new `npc_bid` on `advanceMatchday` |
| NPC cash | None — managed club only keeps `balance` / ledger |
| Negotiation | One counter max; player then accept or decline (no second counter) |
| Fee reference | `fair = transferFee(rating) = rating × 100_000` (same as 5a.2) |
| Incoming bids | 0–2 `npc_bid` per advance; unanswered expire on next advance |
| Save | v2 additive `pendingOffers` optional; no version bump |

## Architecture

```
UI (Mercado / Plantel / Ofertas)
  → session IPC
  → GameSession (pendingOffers + existing balance/ledger/patches)
  → club-ai helpers (thresholds, NPC↔NPC picks, bid generation)
Save: pendingOffers[] (+ balance, ledger, patches)
```

- Pure helpers in `club-ai.ts` (decision + selection); `GameSession` owns offers and executes transfers.
- Existing `buyPlayer` / `sellPlayer` become wrappers that `propose*(id, fair)` (immediate accept at full fee) so current UI keeps working until offer UI ships.
- Deterministic RNG: session sub-stream for AI rolls (same seed → same decisions).

## Offer model

```ts
type OfferKind = 'player_buy' | 'player_sell' | 'npc_bid';
type OfferStatus = 'pending' | 'countered';

type PendingOffer = {
  id: string; // offer-{seq}
  kind: OfferKind;
  playerId: Slug;
  fromClubId: Slug; // payer / initiator
  toClubId: Slug;   // current owner club
  amount: number;
  status: OfferStatus;
  counterAmount?: number;
  createdMatchday: number;
};
```

Snapshot enriches with `playerName`, `fromClubName`, `toClubName`, `fairFee` for UI.

`pendingOffers` only holds **open** deals: `npc_bid` (`pending` or `countered`) and managed proposals that received a counter (`countered`). Immediate accept/reject never leaves a row.

## Rules (exact)

### Response to managed proposals (`player_buy` / `player_sell`)

```
fair = transferFee(player.rating)
ratio = amount / fair

if player_buy and seller would drop below 11 players → reject
if ratio >= 1.00 → accept (execute transfer)
if ratio >= 0.85 → counter
  counterAmount = fair
  if kind == player_buy AND seller.reputation >= 70 → counterAmount = fair * 1.05
else → reject
```

After counter: status `countered`. Player calls `acceptCounter` or `declineOffer` only (no re-counter).

### Managed accepting a deal

- `player_buy` / accept buy-side: require `balance >= amount`; debit + `transfer_out` ledger; patch `player.clubId`.
- `player_sell` / accept sell-side / accept `npc_bid`: credit + `transfer_in`; patch clubId; refuse if managed squad would drop below 11.
- Reject / decline / expire: no balance or patch change.

### NPC bids on managed squad (`npc_bid`)

On each `advanceMatchday` (see order below):

1. **Expire** every offer still in `pendingOffers` (no cash movement).
2. Simulate league (+ cup if scheduled); managed wages then gate (5b).
3. Run up to **3** NPC↔NPC transfers.
4. Generate **K** `npc_bid` where `K ∈ {0,1,2}` from the AI RNG (uniform unless fewer valid targets).
   - Target: managed players in the lower third of squad rating (if squad size < 3, any managed player); distinct players per bid.
   - Buyer: non-managed club with reputation within ±15 of managed, else highest reputation non-managed.
   - `amount = fair`; status `pending`; `createdMatchday` = matchday just played.

Player may `respondOffer(id, 'accept' | 'reject' | 'counter', counterAmount?)` once. If the player counters, NPC reuses the threshold table vs `fair` but maps the “counter” band to **accept at `counterAmount`** or **reject** only (NPC never emits a second counter).

### NPC↔NPC (advance)

Up to **3** transfers per matchday between non-managed clubs:

- Seller must remain ≥ 11 players; buyer must have < 25 players after.
- Prefer buyer reputation ≥ seller; pick a mid/low-rating player from seller.
- Apply `patches.players` only — no NPC ledger or balance.

### Matchday order

```
advanceMatchday:
  expire all pendingOffers
  simulate league (+ cup if scheduled)
  managed wages then gate (5b)
  NPC↔NPC transfers (≤3)
  generate npc_bid (K = 0..2)
```

## Session API

| Method | Behaviour |
|--------|-----------|
| `proposeBuy(playerId, amount?)` | Default amount = fair; AI responds immediately |
| `proposeSell(playerId, amount?)` | Same for sell |
| `respondOffer(offerId, action, counterAmount?)` | For `npc_bid` (and optionally pending player offers if ever deferred) |
| `acceptCounter(offerId)` / `declineOffer(offerId)` | Resolve `countered` |
| `buyPlayer` / `sellPlayer` | Wrappers: propose at fair (backward compatible) |
| `advanceMatchday` | As order above |

## Save v2 (additive)

```json
{
  "version": 2,
  "balance": 5000000,
  "ledger": [],
  "pendingOffers": [
    {
      "id": "offer-1",
      "kind": "npc_bid",
      "playerId": "player-slug",
      "fromClubId": "rival-fc",
      "toClubId": "london-fc-en",
      "amount": 4000000,
      "status": "pending",
      "createdMatchday": 3
    }
  ]
}
```

Load: `pendingOffers ?? []`. Legacy saves remain valid.

## Desktop

- Mercado / Plantel: propose with editable amount (default fair); show accept / reject / counter result; **Aceitar contra** / **Recusar** when countered.
- New **Ofertas** panel: list snapshot `pendingOffers`; badge when non-empty; actions Accept / Reject / Counter (npc_bid).
- Optional one-line summary after advance (“N transfers NPC · M ofertas novas”) in Ofertas.
- IPC: expose propose / respond / acceptCounter / decline (or fold into existing channels); snapshot carries offers.

## Testing / success

- Unit: threshold table; squad-size guards; NPC↔NPC caps; bid count 0–2; expiry clears offers; wrappers still buy/sell at fair.
- Integration: save/load restores `pendingOffers`; accept bid updates balance + ledger + patches.
- Determinism: same seed → same AI decisions for a fixed action sequence.
- Desktop Ofertas + propose flows wired; `pnpm test` + `pnpm typecheck` green.

## Out of scope

- NPC club balances / wages / gate
- Multi-turn haggling or auctions
- Transfer window calendar
- Free agents / loans
- UI history of NPC↔NPC deals
- `@phoenix/transfer` package extraction
- Database editor (5d)

## Roadmap

Mark **5c** ✅ in `docs/plano.md` when done; leave **5d** editor pending.
