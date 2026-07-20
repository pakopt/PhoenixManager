import { describe, expect, it } from 'vitest';
import {
  advanceKnockout,
  createKnockoutCup,
  cupRoundAfterMatchday,
  pickEntrants,
} from './knockout.js';

const clubs = [
  'c1', 'c2', 'c3', 'c4', 'c5', 'c6', 'c7', 'c8', 'c9', 'c10',
] as const;

describe('knockout', () => {
  it('pickEntrants is deterministic and size n', () => {
    expect(pickEntrants(clubs, 42, 8)).toEqual(pickEntrants(clubs, 42, 8));
    expect(pickEntrants(clubs, 42, 8)).toHaveLength(8);
  });

  it('createKnockoutCup starts at qf with 4 ties', () => {
    const cup = createKnockoutCup({
      competitionId: 'phoenix-cup-en',
      clubIds: [...clubs],
      seed: 1,
    });
    expect(cup.round).toBe('qf');
    expect(cup.ties).toHaveLength(4);
    expect(cup.completed).toBe(false);
  });

  it('cupRoundAfterMatchday maps 5/10/15', () => {
    expect(cupRoundAfterMatchday(5)).toBe('qf');
    expect(cupRoundAfterMatchday(10)).toBe('sf');
    expect(cupRoundAfterMatchday(15)).toBe('final');
    expect(cupRoundAfterMatchday(6)).toBeNull();
  });

  it('advanceKnockout builds sf from qf winners', () => {
    const cup = createKnockoutCup({
      competitionId: 'phoenix-cup-en',
      clubIds: [...clubs],
      seed: 2,
    });
    const results = cup.ties.map((t, i) => ({
      homeClubId: t.homeClubId,
      awayClubId: t.awayClubId,
      homeGoals: i % 2 === 0 ? 2 : 0,
      awayGoals: i % 2 === 0 ? 0 : 2,
    }));
    const next = advanceKnockout(cup, results);
    expect(next.round).toBe('sf');
    expect(next.ties).toHaveLength(2);
  });

  it('advanceKnockout completes the final', () => {
    const final = {
      competitionId: 'phoenix-cup-en',
      round: 'final' as const,
      ties: [{ homeClubId: 'c1', awayClubId: 'c2' }],
      completed: false,
    };
    const completed = advanceKnockout(final, [
      { homeClubId: 'c1', awayClubId: 'c2', homeGoals: 2, awayGoals: 1 },
    ]);
    const [completedTie] = completed.ties;

    expect(completed.completed).toBe(true);
    expect(completed.round).toBe('final');
    expect(completedTie?.result).toEqual({
      homeClubId: 'c1',
      awayClubId: 'c2',
      homeGoals: 2,
      awayGoals: 1,
    });
  });
});
