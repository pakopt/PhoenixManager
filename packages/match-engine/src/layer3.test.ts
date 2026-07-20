import { describe, expect, it } from 'vitest';
import { createRng } from '@phoenix/shared';
import { simulateMatch } from './layer3.js';

describe('simulateMatch layer-3', () => {
  it('is deterministic for the same seed and strengths', () => {
    const a = simulateMatch({
      homeClubId: 'london-fc-en',
      awayClubId: 'capital-blues-en',
      homeStrength: 75,
      awayStrength: 70,
      rng: createRng(42),
    });
    const b = simulateMatch({
      homeClubId: 'london-fc-en',
      awayClubId: 'capital-blues-en',
      homeStrength: 75,
      awayStrength: 70,
      rng: createRng(42),
    });
    expect(a).toEqual(b);
  });

  it('returns non-negative goals', () => {
    const rng = createRng(99);
    for (let i = 0; i < 50; i += 1) {
      const r = simulateMatch({
        homeClubId: 'a',
        awayClubId: 'b',
        homeStrength: 60,
        awayStrength: 60,
        rng,
      });
      expect(r.homeGoals).toBeGreaterThanOrEqual(0);
      expect(r.awayGoals).toBeGreaterThanOrEqual(0);
    }
  });
});
