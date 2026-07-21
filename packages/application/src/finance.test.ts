import { describe, expect, it } from 'vitest';
import {
  gateReceipt,
  makeGateEntry,
  makeTransferEntry,
  makeWagesEntry,
  playerWage,
  squadWages,
} from './finance.js';

describe('finance helpers', () => {
  it('computes player wage from rating', () => {
    expect(playerWage(70)).toBe(70_000);
  });

  it('sums squad wages', () => {
    expect(squadWages([{ rating: 40 }, { rating: 50 }])).toBe(90_000);
  });

  it('computes gate receipt from reputation', () => {
    expect(gateReceipt(55)).toBe(550_000);
  });

  it('builds wages ledger entry with deterministic id', () => {
    expect(makeWagesEntry(1, -90_000, 4_910_000).id).toBe('md-1-wages');
  });

  it('builds gate ledger entry with deterministic id', () => {
    expect(makeGateEntry(1, 550_000, 5_460_000).id).toBe('md-1-gate');
  });

  it('builds transfer ledger entry with deterministic id', () => {
    expect(
      makeTransferEntry(
        'transfer_out',
        'p1',
        1,
        0,
        -100_000,
        4_900_000,
        'Alice',
      ).id,
    ).toBe('xfer-p1-1');
  });
});
