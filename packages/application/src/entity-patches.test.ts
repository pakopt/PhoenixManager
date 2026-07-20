import { describe, expect, it } from 'vitest';
import type { Club } from '@phoenix/contracts';
import { applyClubPatches, cloneClubs, diffClubs } from './entity-patches.js';

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
});
