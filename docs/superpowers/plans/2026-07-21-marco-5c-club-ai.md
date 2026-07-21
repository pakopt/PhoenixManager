# Marco 5c Club AI — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Alive transfer market — NPC↔NPC trades each matchday, immediate accept/reject/counter on managed buy/sell, and NPC bids on the managed squad with an Ofertas inbox.

**Architecture:** Pure helpers in `packages/application/src/club-ai.ts`; `GameSession` owns `pendingOffers` and executes transfers; save v2 adds optional `pendingOffers`; desktop adds propose/respond IPC + Ofertas panel. No new package; NPC clubs have no balance.

**Tech Stack:** Existing TS monorepo, Zod contracts, Vitest, Electron + React/Zustand, `@phoenix/shared` Mulberry32 RNG.

## Global Constraints

- Architecture: UI → Application → … → Database; renderer never imports DB/fs
- Managed club only has `balance` / ledger; NPC behaviour is symbolic
- `fair = transferFee(rating) = rating * 100_000`
- Thresholds: `≥1.00` accept; `0.85–0.99` counter; `<0.85` reject
- Counter once max; NPC never second-counters (maps counter-band to accept/reject)
- Squad guards: seller ≥11 after sale; buyer &lt;25 after NPC↔NPC
- Advance order: expire offers → sim → wages/gate → NPC↔NPC (≤3) → npc_bid (K=0..2)
- Unanswered offers expire at start of next advance (no cash)
- Save v2 additive `pendingOffers` optional (do not bump version)
- Spec: `docs/superpowers/specs/2026-07-21-marco-5c-club-ai-design.md`

## File map

| Path | Responsibility |
|------|----------------|
| `packages/contracts/src/schemas.ts` | Offer schemas + optional `pendingOffers` on save |
| `packages/contracts/src/schemas.test.ts` | Accept save with/without offers |
| `packages/contracts/src/index.ts` | Re-exports |
| `packages/application/src/club-ai.ts` | Thresholds, NPC↔NPC picks, bid generation |
| `packages/application/src/club-ai.test.ts` | Unit tests |
| `packages/application/src/snapshot.ts` | `pendingOffers` on snapshot |
| `packages/application/src/game-session.ts` | Offer API, advance AI, save/load |
| `packages/application/src/game-session.test.ts` | Integration |
| `packages/application/src/index.ts` | Exports |
| `apps/desktop/electron/main.ts` | IPC handlers |
| `apps/desktop/electron/preload.ts` | Bridge API |
| `apps/desktop/src/vite-env.d.ts` | Window types |
| `apps/desktop/src/store.ts` | Zustand actions |
| `apps/desktop/src/App.tsx` | Ofertas + propose UX |
| `docs/plano.md` | Marco 5c ✅ |

---

### Task 1: Offer schema + club-ai helpers

**Files:**
- Modify: `packages/contracts/src/schemas.ts`
- Modify: `packages/contracts/src/schemas.test.ts`
- Modify: `packages/contracts/src/index.ts`
- Create: `packages/application/src/club-ai.ts`
- Create: `packages/application/src/club-ai.test.ts`
- Modify: `packages/application/src/index.ts`

**Interfaces:**
- Consumes: `Club`, `Player`, `Slug` from `@phoenix/contracts`; `Rng` from `@phoenix/shared`; `transferFee` from `./transfer.js`
- Produces:
  - Contracts: `OfferKind`, `OfferStatus`, `PendingOffer`, schemas
  - `decideNpcResponse(args): 'accept' | 'reject' | 'counter'`
  - `counterAmountFor(kind, fair, sellerReputation): number`
  - `pickNpcNpcTransfers(...): Array<{ playerId; fromClubId; toClubId }>`
  - `pickNpcBids(...): Array<{ playerId; fromClubId; amount }>`
  - `aiBidCount(rng: Rng): 0 | 1 | 2`

**Contracts — add after `ledgerEntrySchema`:**

```ts
export const offerKindSchema = z.union([
  z.literal('player_buy'),
  z.literal('player_sell'),
  z.literal('npc_bid'),
]);
export type OfferKind = z.infer<typeof offerKindSchema>;

export const offerStatusSchema = z.union([
  z.literal('pending'),
  z.literal('countered'),
]);
export type OfferStatus = z.infer<typeof offerStatusSchema>;

export const pendingOfferSchema = z.object({
  id: z.string().min(1),
  kind: offerKindSchema,
  playerId: slugSchema,
  fromClubId: slugSchema,
  toClubId: slugSchema,
  amount: z.number().finite(),
  status: offerStatusSchema,
  counterAmount: z.number().finite().optional(),
  createdMatchday: z.number().int().min(0),
});
export type PendingOffer = z.infer<typeof pendingOfferSchema>;

// on saveGameSchema:
pendingOffers: z.array(pendingOfferSchema).optional(),
```

Export new schemas/types from `packages/contracts/src/index.ts`.

**club-ai.ts (core):**

```ts
import type { Club, Player, Slug } from '@phoenix/contracts';
import type { Rng } from '@phoenix/shared';
import { transferFee } from './transfer.js';

export type AiDecision = 'accept' | 'reject' | 'counter';

export function decideNpcResponse(args: {
  kind: 'player_buy' | 'player_sell';
  amount: number;
  fair: number;
  sellerSquadSize: number; // size BEFORE sale for buy from NPC
}): AiDecision {
  if (args.kind === 'player_buy' && args.sellerSquadSize <= 11) return 'reject';
  const ratio = args.amount / args.fair;
  if (ratio >= 1) return 'accept';
  if (ratio >= 0.85) return 'counter';
  return 'reject';
}

export function counterAmountFor(
  kind: 'player_buy' | 'player_sell',
  fair: number,
  sellerReputation: number,
): number {
  if (kind === 'player_buy' && sellerReputation >= 70) return fair * 1.05;
  return fair;
}

/** When player counters an npc_bid: NPC never re-counters. */
export function decideNpcReplyToPlayerCounter(args: {
  amount: number;
  fair: number;
}): 'accept' | 'reject' {
  const d = decideNpcResponse({
    kind: 'player_sell', // squad guard N/A for bid reply; use sell path ratios only
    amount: args.amount,
    fair: args.fair,
    sellerSquadSize: 99,
  });
  return d === 'reject' ? 'reject' : 'accept';
}

export function aiBidCount(rng: Rng): 0 | 1 | 2 {
  return rng.int(0, 2) as 0 | 1 | 2;
}

export function pickNpcNpcTransfers(
  clubs: ReadonlyMap<Slug, Club>,
  players: ReadonlyMap<Slug, Player>,
  managedClubId: Slug,
  rng: Rng,
  maxTransfers: number,
): Array<{ playerId: Slug; fromClubId: Slug; toClubId: Slug }> {
  // Implement per spec: ≤maxTransfers; seller ≥11 after; buyer <25 after;
  // prefer buyer.reputation >= seller.reputation; mid/low rating from seller.
  // Mutate a working copy of squad sizes; do not mutate maps.
}

export function pickNpcBids(
  clubs: ReadonlyMap<Slug, Club>,
  players: ReadonlyMap<Slug, Player>,
  managedClubId: Slug,
  rng: Rng,
  count: number,
): Array<{ playerId: Slug; fromClubId: Slug; amount: number }> {
  // Lower-third rating targets (or any if squad < 3); distinct players;
  // buyer reputation within ±15 of managed else highest non-managed;
  // amount = transferFee(rating).
}
```

- [ ] **Step 1: Add failing contracts tests** for save with `pendingOffers` and without.

```ts
it('accepts v2 save with optional pendingOffers', () => {
  const save = saveGameSchema.parse({
    /* minimal valid v2 fields… */
    pendingOffers: [
      {
        id: 'offer-1',
        kind: 'npc_bid',
        playerId: 'p1',
        fromClubId: 'c1',
        toClubId: 'c2',
        amount: 4_000_000,
        status: 'pending',
        createdMatchday: 3,
      },
    ],
  });
  expect(save.pendingOffers).toHaveLength(1);
});

it('accepts v2 save without pendingOffers', () => {
  const save = saveGameSchema.parse({ /* … no pendingOffers */ });
  expect(save.pendingOffers).toBeUndefined();
});
```

Copy a minimal valid v2 object from existing ledger tests in `schemas.test.ts`.

- [ ] **Step 2:** `pnpm --filter @phoenix/contracts test` — fail until schema added; implement schema + exports; PASS.

- [ ] **Step 3: Failing club-ai unit tests**

```ts
import { createRng } from '@phoenix/shared';
import {
  aiBidCount,
  counterAmountFor,
  decideNpcReplyToPlayerCounter,
  decideNpcResponse,
  pickNpcBids,
  pickNpcNpcTransfers,
} from './club-ai.js';
import { transferFee } from './transfer.js';

describe('decideNpcResponse', () => {
  it('accepts at or above fair', () => {
    expect(
      decideNpcResponse({
        kind: 'player_buy',
        amount: transferFee(50),
        fair: transferFee(50),
        sellerSquadSize: 15,
      }),
    ).toBe('accept');
  });

  it('counters between 0.85 and fair', () => {
    const fair = transferFee(50);
    expect(
      decideNpcResponse({
        kind: 'player_buy',
        amount: fair * 0.9,
        fair,
        sellerSquadSize: 15,
      }),
    ).toBe('counter');
  });

  it('rejects below 0.85', () => {
    const fair = transferFee(50);
    expect(
      decideNpcResponse({
        kind: 'player_sell',
        amount: fair * 0.8,
        fair,
        sellerSquadSize: 15,
      }),
    ).toBe('reject');
  });

  it('rejects buy when seller would drop below 11', () => {
    expect(
      decideNpcResponse({
        kind: 'player_buy',
        amount: transferFee(50),
        fair: transferFee(50),
        sellerSquadSize: 11,
      }),
    ).toBe('reject');
  });
});

describe('counterAmountFor', () => {
  it('uses 1.05×fair for high-rep seller on buy', () => {
    expect(counterAmountFor('player_buy', 1_000_000, 70)).toBe(1_050_000);
  });

  it('uses fair otherwise', () => {
    expect(counterAmountFor('player_buy', 1_000_000, 69)).toBe(1_000_000);
    expect(counterAmountFor('player_sell', 1_000_000, 99)).toBe(1_000_000);
  });
});

describe('decideNpcReplyToPlayerCounter', () => {
  it('accepts counter-band as accept (no second counter)', () => {
    const fair = 1_000_000;
    expect(decideNpcReplyToPlayerCounter({ amount: fair * 0.9, fair })).toBe('accept');
  });
});

describe('aiBidCount', () => {
  it('is deterministic for a seed', () => {
    expect(aiBidCount(createRng(42))).toBe(aiBidCount(createRng(42)));
  });
});

// Add small in-memory club/player maps for pickNpcNpcTransfers / pickNpcBids:
// - never touches managedClubId as seller/buyer incorrectly
// - respects 11 / 25 caps
// - returns ≤ max / count
```

- [ ] **Step 4:** `pnpm --filter @phoenix/application test` — new tests fail; implement `club-ai.ts`; PASS.

- [ ] **Step 5: Export** helpers from `packages/application/src/index.ts`.

- [ ] **Step 6: Commit**

```bash
git add packages/contracts packages/application/src/club-ai.ts packages/application/src/club-ai.test.ts packages/application/src/index.ts
git commit -m "$(cat <<'EOF'
feat: add pendingOffers schema and club-ai helpers

EOF
)"
```

---

### Task 2: GameSession offers, advance AI, snapshot, save/load

**Files:**
- Modify: `packages/application/src/snapshot.ts`
- Modify: `packages/application/src/game-session.ts`
- Modify: `packages/application/src/game-session.test.ts`
- Modify: `packages/application/src/index.ts` (export result types if needed)

**Interfaces:**
- Consumes: Task 1 helpers + existing `transferFee`, finance ledger helpers, `createRng`
- Produces:
  - `SessionSnapshot.pendingOffers: SnapshotPendingOffer[]`
  - `ProposeResult = { outcome: 'accepted' | 'rejected' | 'countered'; snapshot: SessionSnapshot; offerId?: string; counterAmount?: number; message?: string }`
  - `proposeBuy(playerId, amount?: number): ProposeResult`
  - `proposeSell(playerId, amount?: number): ProposeResult`
  - `respondOffer(offerId, action: 'accept' | 'reject' | 'counter', counterAmount?: number): ProposeResult`
  - `acceptCounter(offerId): ProposeResult`
  - `declineOffer(offerId): ProposeResult`
  - `buyPlayer` / `sellPlayer` wrappers → propose at fair (return `SessionSnapshot` still — use `.snapshot` from propose when outcome accepted, else throw if rejected — **keep wrappers returning SessionSnapshot**: if not `accepted`, throw with PT message so existing tests that expect success at fair still pass)

**Snapshot type:**

```ts
export type SnapshotPendingOffer = PendingOffer & {
  playerName: string;
  fromClubName: string;
  toClubName: string;
  fairFee: number;
};

// SessionSnapshot adds:
pendingOffers: SnapshotPendingOffer[];
```

**GameSession private state:**

```ts
private pendingOffers: PendingOffer[] = [];
private offerSeq = 0;
```

On `start()`: clear offers. On `loadWithRoots`: `this.pendingOffers = save.pendingOffers ?? []`; restore `offerSeq` from max numeric suffix in ids (or `pendingOffers.length` + transfer history — prefer parse `offer-(\d+)` max).

**AI RNG:** `createRng(this.seed).fork(0x0c1b_a100 ^ this.matchday)` (or similar fixed salt) for advance AI; do not reuse match sim forks.

**proposeBuy sketch:**

```ts
proposeBuy(playerId: Slug, amount?: number): ProposeResult {
  // validate market player
  const fair = transferFee(player.rating);
  const offerAmount = amount ?? fair;
  if (this.balance < offerAmount) throw new Error('Saldo insuficiente');
  const sellerSize = [...this.world.players.values()].filter(p => p.clubId === player.clubId).length;
  const decision = decideNpcResponse({
    kind: 'player_buy',
    amount: offerAmount,
    fair,
    sellerSquadSize: sellerSize,
  });
  if (decision === 'accept') {
    this.executeBuy(player, offerAmount); // extract from current buyPlayer body
    return { outcome: 'accepted', snapshot: this.getSnapshot() };
  }
  if (decision === 'reject') {
    return { outcome: 'rejected', snapshot: this.getSnapshot() };
  }
  this.offerSeq += 1;
  const offer: PendingOffer = {
    id: `offer-${this.offerSeq}`,
    kind: 'player_buy',
    playerId,
    fromClubId: this.managedClubId,
    toClubId: player.clubId,
    amount: offerAmount,
    status: 'countered',
    counterAmount: counterAmountFor('player_buy', fair, this.world.clubs.get(player.clubId)?.reputation ?? 50),
    createdMatchday: this.matchday,
  };
  this.pendingOffers = [...this.pendingOffers, offer];
  return { outcome: 'countered', snapshot: this.getSnapshot(), offerId: offer.id, counterAmount: offer.counterAmount };
}
```

Mirror for `proposeSell` (destination via `pickSellDestinationClub` only when accepting; for counter, store intended `toClubId` from a provisional pick so acceptCounter knows destination — call `pickSellDestinationClub` once when creating the countered offer and store as `toClubId`).

**acceptCounter / declineOffer:** only `status === 'countered'`; accept executes at `counterAmount`; remove from `pendingOffers`.

**respondOffer** for `npc_bid`:
- accept → sell to `fromClubId` at `amount` (ledger transfer_in)
- reject → remove
- counter → NPC `decideNpcReplyToPlayerCounter`; accept at counterAmount or reject/remove

**advanceDay / advanceMatchday** — at the **start**, before sim:

```ts
this.pendingOffers = []; // expire all open offers
```

After wages/gate (existing block ~200–222), append:

```ts
const aiRng = createRng(this.seed).fork(0x0c1ba100 ^ next);
const npcMoves = pickNpcNpcTransfers(
  this.world.clubs,
  this.world.players,
  this.managedClubId,
  aiRng,
  3,
);
for (const move of npcMoves) {
  const p = this.world.players.get(move.playerId);
  if (!p) continue;
  this.world.players.set(move.playerId, { ...p, clubId: move.toClubId });
}
const k = aiBidCount(aiRng);
const bids = pickNpcBids(
  this.world.clubs,
  this.world.players,
  this.managedClubId,
  aiRng,
  k,
);
for (const bid of bids) {
  this.offerSeq += 1;
  this.pendingOffers.push({
    id: `offer-${this.offerSeq}`,
    kind: 'npc_bid',
    playerId: bid.playerId,
    fromClubId: bid.fromClubId,
    toClubId: this.managedClubId,
    amount: bid.amount,
    status: 'pending',
    createdMatchday: next,
  });
}
```

**save:** add `pendingOffers: this.pendingOffers`.  
**getSnapshot:** map offers with names + `fairFee: transferFee(player.rating)`.

**Wrappers:**

```ts
buyPlayer(playerId: Slug): SessionSnapshot {
  const result = this.proposeBuy(playerId);
  if (result.outcome !== 'accepted') {
    throw new Error('Transferência recusada');
  }
  return result.snapshot;
}
```

Same pattern for `sellPlayer`. Existing tests at fair fee should still pass.

- [ ] **Step 1: Failing tests** in `game-session.test.ts`:

```ts
it('proposeBuy at fair accepts and debits balance', async () => { /* … */ });
it('proposeBuy below 0.85 rejects without balance change', async () => { /* … */ });
it('proposeBuy in counter band stores countered offer', async () => { /* … */ });
it('acceptCounter completes buy at counterAmount', async () => { /* … */ });
it('advanceDay expires pending offers then may add npc_bid', async () => { /* … */ });
it('accept npc_bid credits balance and moves player', async () => { /* … */ });
it('save/load restores pendingOffers', async () => { /* … */ });
it('NPC↔NPC on advance moves a non-managed player', async () => {
  // assert some clubId changed among non-managed OR document flaky-free
  // approach: spy by seeding until one transfer, or unit-test picks only
  // Prefer asserting pickNpcNpcTransfers in club-ai tests; session test
  // only checks advance clears offers and bid array length ∈ 0..2
});
it('buyPlayer wrapper still works at fair', async () => { /* existing */ });
```

- [ ] **Step 2:** Run `pnpm --filter @phoenix/application test` — FAIL.

- [ ] **Step 3: Implement** snapshot + session methods + save/load + advance hooks.

- [ ] **Step 4:** Tests PASS. `pnpm --filter @phoenix/application typecheck` PASS.

- [ ] **Step 5: Commit**

```bash
git add packages/application
git commit -m "$(cat <<'EOF'
feat(application): club AI offers, NPC transfers, and pendingOffers persistence

EOF
)"
```

---

### Task 3: Desktop IPC + Ofertas UI

**Files:**
- Modify: `apps/desktop/electron/main.ts`
- Modify: `apps/desktop/electron/preload.ts`
- Modify: `apps/desktop/src/vite-env.d.ts`
- Modify: `apps/desktop/src/store.ts`
- Modify: `apps/desktop/src/App.tsx`

**Interfaces:**
- Consumes: `ProposeResult` / session methods from Task 2
- Produces: UI propose flow + Ofertas panel

**IPC (main.ts):**

```ts
ipcMain.handle('session:proposeBuy', (_e, playerId: string, amount?: number) =>
  session.proposeBuy(playerId as Slug, amount),
);
ipcMain.handle('session:proposeSell', (_e, playerId: string, amount?: number) =>
  session.proposeSell(playerId as Slug, amount),
);
ipcMain.handle(
  'session:respondOffer',
  (_e, offerId: string, action: 'accept' | 'reject' | 'counter', counterAmount?: number) =>
    session.respondOffer(offerId, action, counterAmount),
);
ipcMain.handle('session:acceptCounter', (_e, offerId: string) =>
  session.acceptCounter(offerId),
);
ipcMain.handle('session:declineOffer', (_e, offerId: string) =>
  session.declineOffer(offerId),
);
```

Keep existing `buyPlayer` / `sellPlayer` handlers.

**preload + vite-env:** mirror the five new methods returning `ProposeResult` (define a shared type in preload/vite-env matching application, or inline).

**store.ts:** actions that set `snapshot` from `result.snapshot` and optionally `lastOfferMessage` from outcome for a small banner.

**App.tsx:**
- Comprar / Vender: prompt or inline number input defaulting to `player.fee`; call `proposeBuy`/`proposeSell`.
- If `countered`, show inline actions Aceitar contra / Recusar using `acceptCounter` / `declineOffer`.
- New **Ofertas** section (after Mercado or before Finanças): table of `snapshot.pendingOffers`; badge count in heading; buttons Aceitar / Recusar / Contrapropor (for `npc_bid` + `pending`).
- Kind labels PT: Compra, Venda, Oferta recebida.
- Exhaustive switch on kind/status for labels (typescript-exhaustive-switch).

- [ ] **Step 1: Wire IPC + preload + types**

- [ ] **Step 2: Store actions + App UI**

- [ ] **Step 3:** `pnpm --filter @phoenix/desktop typecheck` — PASS

- [ ] **Step 4: Commit**

```bash
git add apps/desktop
git commit -m "$(cat <<'EOF'
feat(desktop): transfer proposals and Ofertas inbox for club AI

EOF
)"
```

---

### Task 4: Docs plano

**Files:**
- Modify: `docs/plano.md` — version/fase **Marco 5c**; table row **5c** ✅; short note on NPC market + Ofertas; leave **5d** pending

- [ ] **Step 1: Update plano**

- [ ] **Step 2: Commit**

```bash
git commit -m "$(cat <<'EOF'
docs: mark Marco 5c club AI complete in plano

EOF
)"
```

---

## Self-review (plan vs spec)

| Spec | Task |
|------|------|
| pendingOffers schema + save | 1, 2 |
| Threshold / counter formulas | 1 |
| proposeBuy/Sell + acceptCounter/decline | 2 |
| npc_bid generate + respond | 2 |
| Expire on advance | 2 |
| NPC↔NPC ≤3 | 1 (picks) + 2 (apply) |
| Wrappers buy/sell at fair | 2 |
| Snapshot enrichment | 2 |
| Desktop Ofertas + propose UX | 3 |
| plano 5c | 4 |
| Out of scope (NPC cash, auctions, window) | not scheduled |

No TBD. Types: `PendingOffer` / `ProposeResult` / `AiDecision` consistent across tasks. `decideNpcReplyToPlayerCounter` uses sell-path ratios without squad guard (sellerSquadSize 99).
