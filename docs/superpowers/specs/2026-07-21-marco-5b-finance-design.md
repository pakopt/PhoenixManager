# Phoenix Manager — Marco 5b Club Finance Ledger (Design)

**Date:** 2026-07-21  
**Status:** Approved  
**Depends on:** [Marco 5a.2 Buy / Sell](2026-07-20-marco-5a2-buy-sell-design.md)

## Intent

Give the **managed club** a typed, persisted **finance ledger** and automatic cashflow each matchday (squad wages + home gate receipts), while transfer buy/sell continue to move the Caixa and append ledger rows. No multi-club finance, stadium capacity, or insolvency system yet.

## Decisions

| Topic | Choice |
|-------|--------|
| Approach | Helpers in `@phoenix/application` (`finance.ts`) + state on `GameSession` (no new package) |
| Scope | Managed club only |
| Depth | Full typed ledger + season totals in UI |
| Matchday flow | Every `advanceDay`: always wages; gate if managed is home (league and/or cup that day) |
| Wage formula | `playerWage(rating) = rating * 1_000`; squad sum |
| Gate formula | `gateReceipt(reputation) = reputation * 10_000` |
| Negative balance | Allowed for automatic cashflow; buy still requires `balance >= fee` |
| Order on matchday | Wages first, then gate (if any) |
| Save | v2 additive `ledger` optional; no version bump |

## Architecture

```
UI (Caixa + Finanças)
  → existing session IPC / snapshot
  → GameSession (balance + ledger)
  → finance helpers (formulas + entry builders)
Save: balance + ledger[] (+ existing patches)
```

- Pure helpers: `playerWage`, `squadWages`, `gateReceipt`, helpers to build ledger entries.
- `GameSession` owns `private ledger: LedgerEntry[]` (append-only).
- Buy/sell already mutate `balance`; also append `transfer_out` / `transfer_in`.
- Snapshot exposes `balance` + `ledger`. Season totals (Receitas / Despesas / Resultado) are derived in the UI from the ledger.

## Ledger entry

```ts
type LedgerType = 'wages' | 'gate' | 'transfer_in' | 'transfer_out';

type LedgerEntry = {
  id: string;
  matchday: number; // jornada em que ocorreu
  type: LedgerType;
  amount: number; // signed: + revenue, − expense
  balanceAfter: number;
  note?: string;
};
```

**IDs:**
- Wages: `md-{matchday}-wages`
- Gate: `md-{matchday}-gate`
- Transfer: `xfer-{playerId}-{seq}` (unique within session)

## Rules (exact)

```ts
playerWage(rating) = rating * 1_000
squadWages(managedPlayers) = sum(playerWage(p.rating))
gateReceipt(reputation) = reputation * 10_000

advanceDay (after simulating matchday `next`):
  append wages: amount = -squadWages(...), matchday = next
  homeThisDay =
    managed is homeClubId in any league fixture for `next`
    OR managed is homeClubId in any cup tie simulated on this advanceDay
  if homeThisDay:
    append at most one gate entry:
      amount = +gateReceipt(managedClub.reputation), matchday = next
  // balance may go negative; at most one wages + one gate per matchday

buyPlayer (existing + ledger):
  if balance < fee → throw "Saldo insuficiente"
  balance -= fee
  append transfer_out {
    amount: -fee,
    note: player.name,
    matchday: current matchday (0 before any advance)
  }

sellPlayer (existing + ledger):
  balance += fee
  append transfer_in {
    amount: +fee,
    note: player.name,
    matchday: current matchday (0 before any advance)
  }
```

## Save v2 (additive)

```json
{
  "version": 2,
  "balance": 5000000,
  "ledger": [
    {
      "id": "md-1-wages",
      "matchday": 1,
      "type": "wages",
      "amount": -420000,
      "balanceAfter": 4580000
    }
  ]
}
```

Load: `ledger ?? []`. Legacy saves without `ledger` remain valid.

## Desktop

- Keep **Caixa** in header.
- New **Finanças** panel: ledger table newest-first; columns Jornada | Tipo | Valor | Saldo após | Nota.
- Type labels PT: Salários, Bilheteira, Transferência (compra), Transferência (venda).
- Season totals above table: Receitas / Despesas / Resultado (sums of positive / negative / all `amount`).
- No new IPC: ledger rides on `SessionSnapshot`.

## Testing / success

- Unit: formulas; wages always on advance; gate only when home; buy/sell ledger rows; negative balance allowed after wages.
- Integration: save/load restores `ledger` + `balance`.
- Desktop Finanças wired; `pnpm test` + `pnpm typecheck` green.

## Out of scope

- Other clubs’ finances
- Stadium capacity / attendance / ticket price
- Daily sponsor, monthly salary day (Flutter parity)
- FFP / bankruptcy / block advance on debt
- `@phoenix/finance` package extraction
- Club AI (5c), database editor (5d)

## Roadmap

Mark **5b** ✅ in `docs/plano.md`; leave **5c** club-ai, **5d** editor pending.
