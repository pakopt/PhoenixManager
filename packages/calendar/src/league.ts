import type { Fixture, Slug } from '@phoenix/contracts';

/**
 * Circle-method round-robin (double: home + away).
 * For n clubs → (n-1)*2 matchdays, n/2 games each, n*(n-1) total fixtures.
 */
export function generateLeagueFixtures(
  competitionId: Slug,
  clubIds: readonly Slug[],
): Fixture[] {
  if (clubIds.length < 2) {
    throw new Error('Need at least 2 clubs');
  }
  if (clubIds.length % 2 !== 0) {
    throw new Error('League calendar requires an even number of clubs');
  }

  const n = clubIds.length;
  const rounds = n - 1;
  const half = n / 2;

  // Mutable circle: index 0 stays fixed; rotate the rest each round
  const circle = [...clubIds];
  const firstHalf: Fixture[] = [];

  for (let round = 0; round < rounds; round += 1) {
    for (let i = 0; i < half; i += 1) {
      const a = circle[i]!;
      const b = circle[n - 1 - i]!;
      // Alternate home advantage across rounds for balance
      const homeIsA = (round + i) % 2 === 0;
      const homeClubId = homeIsA ? a : b;
      const awayClubId = homeIsA ? b : a;

      firstHalf.push({
        id: `${competitionId}-md${round + 1}-${homeClubId}-vs-${awayClubId}`,
        competitionId,
        matchday: round + 1,
        homeClubId,
        awayClubId,
      });
    }

    // Rotate: keep first fixed, move last into position 1
    const fixed = circle[0]!;
    const moving = circle.slice(1);
    const last = moving.pop()!;
    circle.splice(0, circle.length, fixed, last, ...moving);
  }

  const secondHalf: Fixture[] = firstHalf.map((f) => ({
    id: `${competitionId}-md${f.matchday + rounds}-${f.awayClubId}-vs-${f.homeClubId}`,
    competitionId,
    matchday: f.matchday + rounds,
    homeClubId: f.awayClubId,
    awayClubId: f.homeClubId,
  }));

  return [...firstHalf, ...secondHalf];
}

export function fixturesForMatchday(fixtures: readonly Fixture[], matchday: number): Fixture[] {
  return fixtures.filter((f) => f.matchday === matchday);
}

export function totalMatchdays(clubCount: number): number {
  return (clubCount - 1) * 2;
}
