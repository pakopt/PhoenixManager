# Marco 5a.2 Buy / Sell Transfers — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let the managed club buy/sell players with fee `rating * 100_000`, starting balance `5_000_000`, persist via save `balance` + `patches.players`, and wire desktop Comprar/Vender controls.

**Architecture:** Pure helpers for fee, sell destination, and player patches; `GameSession.buyPlayer` / `sellPlayer` mutate `world.players` + `balance`; IPC + Zustand store; UI shows caixa and action buttons.

**Tech Stack:** Existing TS monorepo, Zod contracts, Vitest, Electron IPC, React/Zustand.

## Global Constraints

- Architecture: UI → Application → … → Database
- Renderer never imports DB/fs
- Fee = `rating * 100_000`
- Starting / missing-load balance = `5_000_000`
- Buy: not already managed; `balance >= fee`; set `clubId = managed`; deduct fee
- Sell: on managed squad; reject if squad size `<= 11`; credit fee; destination = lowest reputation club ≠ managed (tie: slug asc)
- Save v2 additive: `balance` + `patches.players` (do not bump version)
- Spec: `docs/superpowers/specs/2026-07-20-marco-5a2-buy-sell-design.md`

## File map

| Path | Responsibility |
|------|----------------|
| `packages/contracts/src/schemas.ts` | Optional `balance` on save |
| `packages/application/src/transfer.ts` | fee + sell destination |
| `packages/application/src/transfer.test.ts` | Unit tests |
| `packages/application/src/entity-patches.ts` | `clonePlayers`, `diffPlayers`, `applyPlayerPatches` |
| `packages/application/src/entity-patches.test.ts` | Player patch round-trip |
| `packages/application/src/snapshot.ts` | `balance`; optional `fee` on player rows |
| `packages/application/src/game-session.ts` | buy/sell + save/load balance/patches |
| `packages/application/src/game-session.test.ts` | Integration |
| `packages/application/src/index.ts` | Exports |
| `apps/desktop/electron/main.ts` + `preload.ts` | IPC |
| `apps/desktop/src/store.ts` + `App.tsx` | UI |
| `docs/plano.md` | Marco 5a.2 ✅ |

---

### Task 1: Fee helper, sell destination, player patches, save schema

**Files:**
- Modify: `packages/contracts/src/schemas.ts` (+ test if present)
- Create: `packages/application/src/transfer.ts`
- Create: `packages/application/src/transfer.test.ts`
- Modify: `packages/application/src/entity-patches.ts`
- Modify: `packages/application/src/entity-patches.test.ts`
- Modify: `packages/application/src/index.ts`

**Interfaces:**
- `transferFee(rating: number): number` → `rating * 100_000`
- `INITIAL_BALANCE = 5_000_000`
- `pickSellDestinationClub(clubs: ReadonlyMap<Slug, Club>, managedClubId: Slug): Slug`
- `clonePlayers` / `diffPlayers` / `applyPlayerPatches` — diff only `clubId` (and optionally name if ever needed; for 5a.2 only `clubId`)
- `saveGameSchema.balance: z.number().optional()`

- [ ] **Step 1: Add `balance` to `saveGameSchema`; rebuild contracts**

```ts
balance: z.number().finite().optional(),
```

- [ ] **Step 2: Failing tests for transfer helpers**

```ts
expect(transferFee(70)).toBe(7_000_000);
// pickSellDestinationClub: two clubs lower rep than managed → pick lowest; tie by slug
```

- [ ] **Step 3: Implement `transfer.ts`**

```ts
export const INITIAL_BALANCE = 5_000_000;
export function transferFee(rating: number): number {
  return rating * 100_000;
}
export function pickSellDestinationClub(
  clubs: ReadonlyMap<Slug, Club>,
  managedClubId: Slug,
): Slug {
  const candidates = [...clubs.values()].filter((c) => c.id !== managedClubId);
  if (candidates.length === 0) throw new Error('Nenhum clube de destino disponível');
  candidates.sort((a, b) => {
    if (a.reputation !== b.reputation) return a.reputation - b.reputation;
    return a.id.localeCompare(b.id);
  });
  return candidates[0]!.id;
}
```

- [ ] **Step 4: Player patch helpers** (mirror clubs; apply only `clubId: string`)

- [ ] **Step 5:** `pnpm --filter @phoenix/contracts test && pnpm --filter @phoenix/application test` — PASS for new tests

- [ ] **Step 6: Commit**

```bash
git commit -m "$(cat <<'EOF'
feat: add transfer fee helpers and player entity patches

EOF
)"
```

---

### Task 2: GameSession buy/sell + snapshot balance + save/load

**Files:**
- Modify: `packages/application/src/snapshot.ts` — `balance: number`; add `fee` to `SnapshotPlayer` / `SnapshotMarketPlayer` via `player-lists` enrichment OR compute in getSnapshot map
- Modify: `packages/application/src/player-lists.ts` — include `fee: transferFee(rating)` on rows (cleanest)
- Modify: `packages/application/src/game-session.ts`
- Modify: `packages/application/src/game-session.test.ts`
- Modify: `packages/application/src/player-lists.test.ts` if fee asserted

**Session state:**
- `private balance = INITIAL_BALANCE`
- `private baselinePlayers!: Map<Slug, Player>` — set in `start` after loadWorld (clonePlayers)
- On `start`: `this.balance = INITIAL_BALANCE`
- On `save`: include `balance`, `patches.players: diffPlayers(baseline, world.players)`
- On `load`: after player patches applied, `this.balance = save.balance ?? INITIAL_BALANCE`
- Apply `applyPlayerPatches(world.players, save.patches?.players ?? [])` after club patches

**Methods:**

```ts
buyPlayer(playerId: Slug): SessionSnapshot
sellPlayer(playerId: Slug): SessionSnapshot
```

Portuguese error messages per spec.

- [ ] **Step 1: Failing tests**

```ts
it('buys a market player when balance allows', …);
it('rejects buy when balance insufficient', …);
it('sells when squad larger than 11 and credits balance', …);
it('rejects sell when squad size is 11 or less', …);
it('persists balance and player clubId patches on save/load', …);
```

For insufficient funds: temporarily set balance low via buying expensive players, or test helper — prefer buy until cash low, or add package-private test by buying a high-rating player after draining (loop buys). Simpler: use reflection/`as any` to set balance in test only if needed — prefer draining via repeated buys of cheap players, or expose nothing and construct scenario carefully.

Minimal approach for insufficient funds test: start session, find market player with fee > INITIAL_BALANCE (rating > 50 means fee > 5M — rating 51+ works). Seed world has ratings up to ~80, so find `rating >= 51` and attempt buy → expect throw.

- [ ] **Step 2: Implement session methods + snapshot `balance` + fee on lists**

- [ ] **Step 3:** `pnpm --filter @phoenix/application test` — PASS

- [ ] **Step 4: Commit**

```bash
git commit -m "$(cat <<'EOF'
feat(application): buy and sell players with balance and patches

EOF
)"
```

---

### Task 3: Desktop IPC + UI

**Files:**
- Modify: `apps/desktop/electron/main.ts` — handlers `session:buyPlayer`, `session:sellPlayer`
- Modify: `apps/desktop/electron/preload.ts`
- Modify: `apps/desktop/src/store.ts` — `buyPlayer` / `sellPlayer` actions
- Modify: `apps/desktop/src/App.tsx` — caixa; Comprar/Vender buttons

**UI:**
- Header near jornada: `Caixa: €{balance.toLocaleString('pt-PT')}`
- Mercado table: Fee column + Comprar (`disabled={busy || player.fee > snapshot.balance}`)
- Plantel: Fee + Vender (`disabled={busy || snapshot.squad.length <= 11}`)
- On click: `void buyPlayer(id)` / `sellPlayer(id)`; errors via existing `error` banner

- [ ] **Step 1: Wire IPC + store**

- [ ] **Step 2: UI columns/buttons**

- [ ] **Step 3:** `pnpm --filter @phoenix/desktop typecheck` — PASS

- [ ] **Step 4: Commit**

```bash
git commit -m "$(cat <<'EOF'
feat(desktop): buy/sell controls and cash balance display

EOF
)"
```

---

### Task 4: Docs

**Files:**
- Modify: `docs/plano.md` — Marco **5a.2** ✅; fase actual 5a.2; note fee/caixa

- [ ] **Step 1: Update plano**

- [ ] **Step 2: Commit**

```bash
git commit -m "$(cat <<'EOF'
docs: mark Marco 5a.2 buy/sell complete in plano

EOF
)"
```

---

## Self-review (plan vs spec)

| Spec | Task |
|------|------|
| transferFee / INITIAL_BALANCE / sell destination | 1 |
| player patches + save.balance schema | 1 |
| buy/sell rules + snapshot balance/fee | 2 |
| save/load patches.players + balance | 2 |
| IPC + UI Comprar/Vender + Caixa | 3 |
| plano | 4 |
| Out of scope finance/AI | not scheduled |

No TBD. Sell destination rule locked: lowest reputation ≠ managed, slug tie-break.
