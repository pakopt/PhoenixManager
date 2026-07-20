import { describe, expect, it } from 'vitest';
import type { Club } from '@phoenix/contracts';
import {
  INITIAL_BALANCE,
  pickSellDestinationClub,
  transferFee,
} from './transfer.js';

function club(partial: Partial<Club> & Pick<Club, 'id' | 'name'>): Club {
  return {
    nationId: 'england',
    reputation: 50,
    ...partial,
  };
}

describe('transfer helpers', () => {
  it('computes transfer fee from rating', () => {
    expect(transferFee(70)).toBe(7_000_000);
    expect(transferFee(51)).toBe(5_100_000);
  });

  it('exposes initial balance constant', () => {
    expect(INITIAL_BALANCE).toBe(5_000_000);
  });

  it('picks lowest reputation club excluding managed', () => {
    const clubs = new Map<string, Club>([
      ['london-fc-en', club({ id: 'london-fc-en', name: 'London FC', reputation: 80 })],
      ['manchester-fc-en', club({ id: 'manchester-fc-en', name: 'Manchester FC', reputation: 40 })],
      ['liverpool-fc-en', club({ id: 'liverpool-fc-en', name: 'Liverpool FC', reputation: 30 })],
    ]);

    expect(pickSellDestinationClub(clubs, 'london-fc-en')).toBe('liverpool-fc-en');
  });

  it('breaks reputation ties by slug ascending', () => {
    const clubs = new Map<string, Club>([
      ['london-fc-en', club({ id: 'london-fc-en', name: 'London FC', reputation: 80 })],
      ['z-club-en', club({ id: 'z-club-en', name: 'Z Club', reputation: 30 })],
      ['a-club-en', club({ id: 'a-club-en', name: 'A Club', reputation: 30 })],
    ]);

    expect(pickSellDestinationClub(clubs, 'london-fc-en')).toBe('a-club-en');
  });

  it('throws when no destination club exists', () => {
    const clubs = new Map<string, Club>([
      ['london-fc-en', club({ id: 'london-fc-en', name: 'London FC', reputation: 80 })],
    ]);

    expect(() => pickSellDestinationClub(clubs, 'london-fc-en')).toThrow(
      'Nenhum clube de destino disponível',
    );
  });
});
