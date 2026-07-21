# Marco 5b Club Finance Ledger — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Persist a typed finance ledger for the managed club, apply wages + home gate each `advanceDay`, record buy/sell as ledger rows, and show a Finanças panel with season totals.

**Architecture:** Pure helpers in `packages/application/src/finance.ts`; `GameSession` owns `ledger` + mutates `balance`; save v2 adds optional `ledger`; desktop derives totals from snapshot.ledger (no new IPC).

**Tech Stack:** Existing TS monorepo, Zod contracts, Vitest, Electron + React/Zustand.

## Global Constraints

- Architecture: UI → Application → … → Database
- Renderer never imports DB/fs
- Managed club only
- `playerWage(rating) = rating * 1_000`; `squadWages` = sum; `gateReceipt(reputation) = reputation * 10_000`
- Every `advanceDay`: wages then at most one gate if managed is home (league and/or cup that day)
- Negative balance allowed for wages/gate; buy still requires `balance >= fee`
- Save v2 additive `ledger` optional (do not bump version)
- Spec: `docs/superpowers/specs/2026-07-21-marco-5b-finance-design.md`

## File map

| Path | Responsibility |
|------|----------------|
| `packages/contracts/src/schemas.ts` | `ledgerEntrySchema` + optional `ledger` on save |
| `packages/contracts/src/schemas.test.ts` | Accept save with ledger / without |
| `packages/application/src/finance.ts` | Formulas + entry builders |
| `packages/application/src/finance.test.ts` | Unit tests |
| `packages/application/src/snapshot.ts` | `ledger` on `SessionSnapshot` |
| `packages/application/src/game-session.ts` | Append ledger on advance/buy/sell; save/load |
| `packages/application/src/game-session.test.ts` | Integration |
| `packages/application/src/index.ts` | Exports |
| `apps/desktop/src/App.tsx` | Finanças panel |
| `docs/plano.md` | Marco 5b ✅ |

---

### Task 1: Ledger schema + finance helpers

**Files:**
- Modify: `packages/contracts/src/schemas.ts`
- Modify: `packages/contracts/src/schemas.test.ts`
- Create: `packages/application/src/finance.ts`
- Create: `packages/application/src/finance.test.ts`
- Modify: `packages/application/src/index.ts`

**Interfaces:**
- Consumes: `Player` from `@phoenix/contracts`
- Produces:
  - `LedgerType`, `LedgerEntry` (re-export from contracts or application)
  - `playerWage(rating: number): number`
  - `squadWages(players: Iterable<{ rating: number }>): number`
  - `gateReceipt(reputation: number): number`
  - `appendLedgerEntry(ledger: LedgerEntry[], entry: Omit<LedgerEntry, 'balanceAfter'>, balanceBefore: number): { ledger: LedgerEntry[]; balance: number }` — or simpler: caller updates balance then pushes `{ ...entry, balanceAfter: balance }`

Prefer explicit builder helpers:

```ts
export function playerWage(rating: number): number {
  return rating * 1_000;
}

export function squadWages(players: Iterable<{ rating: number }>): number {
  let total = 0;
  for (const p of players) total += playerWage(p.rating);
  return total;
}

export function gateReceipt(reputation: number): number {
  return reputation * 10_000;
}

export function makeWagesEntry(matchday: number, amount: number, balanceAfter: number): LedgerEntry
export function makeGateEntry(matchday: number, amount: number, balanceAfter: number): LedgerEntry
export function makeTransferEntry(
  type: 'transfer_in' | 'transfer_out',
  playerId: string,
  seq: number,
  matchday: number,
  amount: number,
  balanceAfter: number,
  note: string,
): LedgerEntry
```

**Contracts schema:**

```ts
export const ledgerTypeSchema = z.union([
  z.literal('wages'),
  z.literal('gate'),
  z.literal('transfer_in'),
  z.literal('transfer_out'),
]);

export const ledgerEntrySchema = z.object({
  id: z.string().min(1),
  matchday: z.number().int().min(0),
  type: ledgerTypeSchema,
  amount: z.number().finite(),
  balanceAfter: z.number().finite(),
  note: z.string().optional(),
});

// on saveGameSchema:
ledger: z.array(ledgerEntrySchema).optional(),
```

- [ ] **Step 1: Add schema + failing contracts test** for save with `ledger` array and save without `ledger`.

- [ ] **Step 2:** `pnpm --filter @phoenix/contracts test` — new tests fail until schema added; then implement schema; PASS.

- [ ] **Step 3: Failing finance unit tests**

```ts
expect(playerWage(70)).toBe(70_000);
expect(squadWages([{ rating: 40 }, { rating: 50 }])).toBe(90_000);
expect(gateReceipt(55)).toBe(550_000);
expect(makeWagesEntry(1, -90_000, 4_910_000).id).toBe('md-1-wages');
expect(makeGateEntry(1, 550_000, 5_460_000).id).toBe('md-1-gate');
expect(makeTransferEntry('transfer_out', 'p1', 1, 0, -100_000, 4_900_000, 'Alice').id).toBe(
  'xfer-p1-1',
);
```

- [ ] **Step 4: Implement `finance.ts` + export from `index.ts`**

- [ ] **Step 5:** `pnpm --filter @phoenix/contracts test && pnpm --filter @phoenix/application test` — PASS for new tests

- [ ] **Step 6: Commit**

```bash
git commit -m "$(cat <<'EOF'
feat: add finance ledger schema and wage/gate helpers

EOF
)"
```

---

### Task 2: GameSession cashflow + save/load ledger

**Files:**
- Modify: `packages/application/src/snapshot.ts` — add `ledger: LedgerEntry[]` to `SessionSnapshot`
- Modify: `packages/application/src/game-session.ts`
- Modify: `packages/application/src/game-session.test.ts`

**Interfaces:**
- Consumes: finance helpers from Task 1; `fixturesForMatchday` from `@phoenix/calendar`
- Produces: `SessionSnapshot.ledger`; save includes `ledger`; load restores `ledger ?? []`

**Session state:**
- `private ledger: LedgerEntry[] = []`
- `private transferSeq = 0`
- On `start`: `this.ledger = []`; `this.transferSeq = 0`
- On `save`: include `ledger: this.ledger`
- On `load`: `this.ledger = save.ledger ?? []`; set `transferSeq` to max existing xfer seq or `ledger.length`

**`advanceDay` (after match/cup simulation, after `this.matchday = next`):**

```ts
const managedPlayers = [...this.world.players.values()].filter(
  (p) => p.clubId === this.managedClubId,
);
const wageAmount = -squadWages(managedPlayers);
this.balance += wageAmount;
this.ledger = [
  ...this.ledger,
  makeWagesEntry(next, wageAmount, this.balance),
];

const leagueHome = fixturesForMatchday(this.fixtures, next).some(
  (f) => f.homeClubId === this.managedClubId,
);
const cupHome =
  /* cup round was simulated this advanceDay */ &&
  this.cup.ties.some((t) => t.homeClubId === this.managedClubId);
// Capture whether cup ran before mutating cup state, or check cupRoundAfterMatchday(next) === previous round.
// Exact: compute `cupPlayedThisDay` boolean when entering the cup block; if managed is home in those ties, gate.

if (leagueHome || cupHome) {
  const club = this.world.clubs.get(this.managedClubId);
  const gateAmount = gateReceipt(club?.reputation ?? 50);
  this.balance += gateAmount;
  this.ledger = [...this.ledger, makeGateEntry(next, gateAmount, this.balance)];
}
```

**Reputation timing:** gate uses reputation **after** `bumpWinningReputations` (already called before cup). Spec does not require pre-bump; use current club reputation after bumps.

**buyPlayer / sellPlayer:** after balance mutation, `this.transferSeq += 1` and append transfer entry with `matchday: this.matchday`.

**getSnapshot:** include `ledger: [...this.ledger]`.

- [ ] **Step 1: Failing tests**

```ts
it('appends wages on advanceDay', …);
it('appends gate when managed is league home', …);
it('does not append gate when managed is away only', …);
it('appends at most one gate when home in league and cup same day', …); // if fixture allows; otherwise skip with comment
it('records transfer_out on buy and transfer_in on sell', …);
it('allows negative balance after wages', …); // drain via buys then advance
it('persists ledger across save/load', …);
```

- [ ] **Step 2: Implement session + snapshot changes**

- [ ] **Step 3:** `pnpm --filter @phoenix/application test` — PASS

- [ ] **Step 4: Commit**

```bash
git commit -m "$(cat <<'EOF'
feat(application): apply matchday wages/gate and persist ledger

EOF
)"
```

---

### Task 3: Desktop Finanças panel

**Files:**
- Modify: `apps/desktop/src/App.tsx`

**Interfaces:**
- Consumes: `snapshot.ledger`, `snapshot.balance` (types flow from application via existing preload)
- Produces: Finanças UI; no new IPC

**UI:**
- After Plantel/Mercado (or as third section): heading **Finanças**
- Totals row:
  - Receitas = sum of `amount > 0`
  - Despesas = sum of `amount < 0` (show absolute or signed consistently — show as positive magnitude with label Despesas, or show signed; prefer: Receitas = sum positives, Despesas = -sum negatives, Resultado = sum all)
- Table newest-first: `[...ledger].reverse()` or copy then reverse
- Columns: Jornada | Tipo | Valor | Saldo após | Nota
- Type label helper:

```ts
function ledgerTypeLabel(type: LedgerEntry['type']): string {
  switch (type) {
    case 'wages': return 'Salários';
    case 'gate': return 'Bilheteira';
    case 'transfer_out': return 'Transferência (compra)';
    case 'transfer_in': return 'Transferência (venda)';
    default: {
      const _exhaustive: never = type;
      return _exhaustive;
    }
  }
}
```

Format money with `toLocaleString('pt-PT')` like Caixa.

- [ ] **Step 1: Add Finanças panel to App.tsx**

- [ ] **Step 2:** `pnpm --filter @phoenix/desktop typecheck` — PASS

- [ ] **Step 3: Commit**

```bash
git commit -m "$(cat <<'EOF'
feat(desktop): show finance ledger and season totals

EOF
)"
```

---

### Task 4: Docs plano

**Files:**
- Modify: `docs/plano.md` — Marco **5b** ✅; fase actual 5b; note ledger/wages/gate; leave **5c** / **5d** pending

- [ ] **Step 1: Update plano**

- [ ] **Step 2: Commit**

```bash
git commit -m "$(cat <<'EOF'
docs: mark Marco 5b finance ledger complete in plano

EOF
)"
```

---

## Self-review (plan vs spec)

| Spec | Task |
|------|------|
| Schema ledger + formulas | 1 |
| advanceDay wages + ≤1 gate home | 2 |
| buy/sell ledger rows | 2 |
| save/load ledger | 2 |
| Snapshot.ledger | 2 |
| Finanças UI + totals | 3 |
| plano 5b | 4 |
| Out of scope (stadium, FFP, other clubs) | not scheduled |

No TBD. Gate: at most one per matchday. Totals derived in UI.
