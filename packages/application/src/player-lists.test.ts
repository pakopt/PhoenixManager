import { describe, expect, it } from 'vitest';
import type { Club, Player } from '@phoenix/contracts';
import { buildMarket, buildSquad } from './player-lists.js';
import { transferFee } from './transfer.js';

const clubs = new Map<string, Club>([
  ['london-fc-en', { id: 'london-fc-en', name: 'London FC', nationId: 'england', reputation: 80 }],
  ['rivals-en', { id: 'rivals-en', name: 'Rivals', nationId: 'england', reputation: 70 }],
]);

const players: Player[] = [
  {
    id: 'p-mf-high',
    name: 'Mid High',
    clubId: 'london-fc-en',
    nationId: 'england',
    position: 'MF',
    rating: 80,
    age: 26,
  },
  {
    id: 'p-mf',
    name: 'Mid',
    clubId: 'london-fc-en',
    nationId: 'england',
    position: 'MF',
    rating: 70,
    age: 24,
  },
  {
    id: 'p-gk',
    name: 'Keep',
    clubId: 'london-fc-en',
    nationId: 'england',
    position: 'GK',
    rating: 60,
    age: 30,
  },
  {
    id: 'p-out',
    name: 'Away',
    clubId: 'rivals-en',
    nationId: 'england',
    position: 'FW',
    rating: 75,
    age: 22,
  },
];

describe('buildSquad', () => {
  it('filters managed club and sorts by position then rating', () => {
    const squad = buildSquad(players, 'london-fc-en');
    expect(squad.map((p) => p.id)).toEqual(['p-gk', 'p-mf-high', 'p-mf']);
    const mids = squad.filter((p) => p.position === 'MF');
    expect(mids.map((p) => p.rating)).toEqual([80, 70]);
    expect(squad.map((p) => p.fee)).toEqual([
      transferFee(60),
      transferFee(80),
      transferFee(70),
    ]);
  });
});

describe('buildMarket', () => {
  it('excludes managed club and includes clubName', () => {
    const market = buildMarket(players, clubs, 'london-fc-en');
    expect(market).toHaveLength(1);
    expect(market[0]).toMatchObject({
      id: 'p-out',
      clubId: 'rivals-en',
      clubName: 'Rivals',
      fee: transferFee(75),
    });
  });
});
