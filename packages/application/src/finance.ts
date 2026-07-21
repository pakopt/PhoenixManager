import type { LedgerEntry, LedgerType } from '@phoenix/contracts';

export type { LedgerEntry, LedgerType };

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

export function makeWagesEntry(
  matchday: number,
  amount: number,
  balanceAfter: number,
): LedgerEntry {
  return {
    id: `md-${matchday}-wages`,
    matchday,
    type: 'wages',
    amount,
    balanceAfter,
  };
}

export function makeGateEntry(
  matchday: number,
  amount: number,
  balanceAfter: number,
): LedgerEntry {
  return {
    id: `md-${matchday}-gate`,
    matchday,
    type: 'gate',
    amount,
    balanceAfter,
  };
}

export function makeTransferEntry(
  type: 'transfer_in' | 'transfer_out',
  playerId: string,
  seq: number,
  matchday: number,
  amount: number,
  balanceAfter: number,
  note: string,
): LedgerEntry {
  return {
    id: `xfer-${playerId}-${seq}`,
    matchday,
    type,
    amount,
    balanceAfter,
    note,
  };
}
