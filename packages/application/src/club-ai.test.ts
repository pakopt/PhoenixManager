import { describe, expect, it } from 'vitest';
import type { Club, Player, Slug } from '@phoenix/contracts';
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

function club(partial: Partial<Club> & Pick<Club, 'id' | 'name'>): Club {
  return {
    nationId: 'england',
    reputation: 50,
    ...partial,
  };
}

function player(partial: Partial<Player> & Pick<Player, 'id' | 'name' | 'clubId'>): Player {
  return {
    nationId: 'england',
    position: 'MF',
    rating: 50,
    age: 25,
    ...partial,
  };
}

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

describe('pickNpcNpcTransfers', () => {
  const managedClubId: Slug = 'london-fc-en';

  function buildNpcTransferFixture(): {
    clubs: Map<Slug, Club>;
    players: Map<Slug, Player>;
  } {
    const clubs = new Map<Slug, Club>([
      [managedClubId, club({ id: managedClubId, name: 'London FC', reputation: 80 })],
      ['seller-fc-en', club({ id: 'seller-fc-en', name: 'Seller FC', reputation: 40 })],
      ['buyer-fc-en', club({ id: 'buyer-fc-en', name: 'Buyer FC', reputation: 55 })],
    ]);

    const players = new Map<Slug, Player>();
    for (let i = 0; i < 12; i++) {
      players.set(`seller-p${i}`, player({
        id: `seller-p${i}`,
        name: `Seller P${i}`,
        clubId: 'seller-fc-en',
        rating: 40 + i,
      }));
    }
    for (let i = 0; i < 24; i++) {
      players.set(`buyer-p${i}`, player({
        id: `buyer-p${i}`,
        name: `Buyer P${i}`,
        clubId: 'buyer-fc-en',
        rating: 50,
      }));
    }
    return { clubs, players };
  }

  it('never uses managed club as seller or buyer', () => {
    const { clubs, players } = buildNpcTransferFixture();
    const transfers = pickNpcNpcTransfers(
      clubs,
      players,
      managedClubId,
      createRng(99),
      3,
    );

    for (const t of transfers) {
      expect(t.fromClubId).not.toBe(managedClubId);
      expect(t.toClubId).not.toBe(managedClubId);
    }
  });

  it('respects seller 11 and buyer 25 squad caps', () => {
    const { clubs, players } = buildNpcTransferFixture();
    const transfers = pickNpcNpcTransfers(
      clubs,
      players,
      managedClubId,
      createRng(7),
      3,
    );

    const squadSizes = new Map<Slug, number>();
    for (const p of players.values()) {
      squadSizes.set(p.clubId, (squadSizes.get(p.clubId) ?? 0) + 1);
    }
    for (const t of transfers) {
      squadSizes.set(t.fromClubId, (squadSizes.get(t.fromClubId) ?? 0) - 1);
      squadSizes.set(t.toClubId, (squadSizes.get(t.toClubId) ?? 0) + 1);
    }

    expect(squadSizes.get('seller-fc-en')).toBeGreaterThanOrEqual(11);
    expect(squadSizes.get('buyer-fc-en')).toBeLessThan(25);
  });

  it('returns at most maxTransfers', () => {
    const { clubs, players } = buildNpcTransferFixture();
    const transfers = pickNpcNpcTransfers(
      clubs,
      players,
      managedClubId,
      createRng(1),
      2,
    );
    expect(transfers.length).toBeLessThanOrEqual(2);
  });
});

describe('pickNpcBids', () => {
  const managedClubId: Slug = 'london-fc-en';

  function buildBidFixture(): {
    clubs: Map<Slug, Club>;
    players: Map<Slug, Player>;
  } {
    const clubs = new Map<Slug, Club>([
      [managedClubId, club({ id: managedClubId, name: 'London FC', reputation: 70 })],
      ['near-fc-en', club({ id: 'near-fc-en', name: 'Near FC', reputation: 75 })],
      ['far-fc-en', club({ id: 'far-fc-en', name: 'Far FC', reputation: 30 })],
    ]);

    const players = new Map<Slug, Player>([
      ['p-low', player({ id: 'p-low', name: 'Low', clubId: managedClubId, rating: 40 })],
      ['p-mid', player({ id: 'p-mid', name: 'Mid', clubId: managedClubId, rating: 60 })],
      ['p-high', player({ id: 'p-high', name: 'High', clubId: managedClubId, rating: 80 })],
    ]);

    return { clubs, players };
  }

  it('never uses managed club as bidding club incorrectly', () => {
    const { clubs, players } = buildBidFixture();
    const bids = pickNpcBids(clubs, players, managedClubId, createRng(5), 2);

    for (const bid of bids) {
      expect(bid.fromClubId).not.toBe(managedClubId);
    }
  });

  it('targets lower-third managed players when squad has at least 3', () => {
    const { clubs, players } = buildBidFixture();
    const bids = pickNpcBids(clubs, players, managedClubId, createRng(3), 1);

    expect(bids).toHaveLength(1);
    expect(bids[0]?.playerId).toBe('p-low');
    expect(bids[0]?.amount).toBe(transferFee(40));
  });

  it('returns at most count distinct players', () => {
    const { clubs, players } = buildBidFixture();
    const bids = pickNpcBids(clubs, players, managedClubId, createRng(11), 2);

    expect(bids.length).toBeLessThanOrEqual(2);
    const playerIds = bids.map((b) => b.playerId);
    expect(new Set(playerIds).size).toBe(playerIds.length);
  });
});
