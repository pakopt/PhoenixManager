import { describe, expect, it } from 'vitest';
import type { Club, Player } from '@phoenix/contracts';
import {
  applyClubPatches,
  applyPlayerPatches,
  cloneClubs,
  clonePlayers,
  diffClubs,
  diffPlayers,
} from './entity-patches.js';

function club(partial: Partial<Club> & Pick<Club, 'id' | 'name'>): Club {
  return {
    nationId: 'england',
    reputation: 50,
    ...partial,
  };
}

describe('entity patches', () => {
  it('diffs and applies reputation changes', () => {
    const baseline = new Map<string, Club>([
      ['london-fc-en', club({ id: 'london-fc-en', name: 'London FC', reputation: 80 })],
    ]);
    const current = cloneClubs(baseline);
    current.set('london-fc-en', {
      ...current.get('london-fc-en')!,
      reputation: 82,
    });

    const patches = diffClubs(baseline, current);
    expect(patches).toEqual([{ id: 'london-fc-en', changes: { reputation: 82 } }]);

    const restored = cloneClubs(baseline);
    applyClubPatches(restored, patches);
    expect(restored.get('london-fc-en')?.reputation).toBe(82);
  });

  it('diffs and applies clubId changes for players', () => {
    const baseline = new Map<string, Player>([
      [
        'striker-01-london-fc-en',
        {
          id: 'striker-01-london-fc-en',
          name: 'Alex Striker',
          clubId: 'manchester-fc-en',
          nationId: 'england',
          position: 'FW',
          rating: 72,
          age: 24,
        },
      ],
    ]);
    const current = clonePlayers(baseline);
    current.set('striker-01-london-fc-en', {
      ...current.get('striker-01-london-fc-en')!,
      clubId: 'london-fc-en',
    });

    const patches = diffPlayers(baseline, current);
    expect(patches).toEqual([
      {
        id: 'striker-01-london-fc-en',
        changes: { clubId: 'london-fc-en' },
      },
    ]);

    const restored = clonePlayers(baseline);
    applyPlayerPatches(restored, patches);
    expect(restored.get('striker-01-london-fc-en')?.clubId).toBe('london-fc-en');
  });
});
