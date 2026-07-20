import type { Fixture, MatchResult, Slug, TableRow } from '@phoenix/contracts';
import type { WorldDatabase } from '@phoenix/database';
import { simulateMatch } from '@phoenix/match-engine';
import { createRng } from '@phoenix/shared';
import { applyResult, clubStrength, hashSlug } from './league-table.js';

export type SimulateMatchdayInput = {
  world: WorldDatabase;
  fixtures: readonly Fixture[];
  matchday: number;
  seed: number;
  table: Map<Slug, TableRow>;
};

export type SimulateMatchdayOutput = {
  results: MatchResult[];
  table: Map<Slug, TableRow>;
};

export function simulateMatchday(input: SimulateMatchdayInput): SimulateMatchdayOutput {
  const rootRng = createRng(input.seed);
  const dayFixtures = input.fixtures.filter((f) => f.matchday === input.matchday);
  const results: MatchResult[] = [];

  for (const fixture of dayFixtures) {
    const matchRng = rootRng.fork(fixture.matchday * 1_000_003 + hashSlug(fixture.id));
    const result = simulateMatch({
      homeClubId: fixture.homeClubId,
      awayClubId: fixture.awayClubId,
      homeStrength: clubStrength(input.world, fixture.homeClubId),
      awayStrength: clubStrength(input.world, fixture.awayClubId),
      rng: matchRng,
    });
    results.push(result);
    applyResult(input.table, result);
  }

  return { results, table: input.table };
}
