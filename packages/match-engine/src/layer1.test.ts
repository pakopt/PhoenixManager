import { describe, expect, it } from 'vitest';
import { createRng } from '@phoenix/shared';
import { simulateMatchDetailed } from './layer1.js';

describe('simulateMatchDetailed layer-1', () => {
  it('is deterministic for the same seed and strengths', () => {
    const input = {
      homeClubId: 'london-fc-en' as const,
      awayClubId: 'capital-blues-en' as const,
      homeStrength: 75,
      awayStrength: 70,
    };
    const a = simulateMatchDetailed({ ...input, rng: createRng(42) });
    const b = simulateMatchDetailed({ ...input, rng: createRng(42) });
    expect(a).toEqual(b);
  });

  it('goal events match result totals', () => {
    const detailed = simulateMatchDetailed({
      homeClubId: 'a',
      awayClubId: 'b',
      homeStrength: 80,
      awayStrength: 60,
      rng: createRng(7),
    });
    const homeGoals = detailed.events.filter(
      (e) => e.type === 'goal' && e.clubId === 'a',
    ).length;
    const awayGoals = detailed.events.filter(
      (e) => e.type === 'goal' && e.clubId === 'b',
    ).length;
    expect(homeGoals).toBe(detailed.result.homeGoals);
    expect(awayGoals).toBe(detailed.result.awayGoals);
  });

  it('keeps all goals when trimming to ~12 events', () => {
    const detailed = simulateMatchDetailed({
      homeClubId: 'a',
      awayClubId: 'b',
      homeStrength: 99,
      awayStrength: 99,
      rng: createRng(123),
    });
    expect(detailed.events.length).toBeLessThanOrEqual(12);
    const goals = detailed.events.filter((e) => e.type === 'goal').length;
    expect(goals).toBe(detailed.result.homeGoals + detailed.result.awayGoals);
  });
});
