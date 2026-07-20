import type { Fixture, MatchResult, Slug, TableRow } from '@phoenix/contracts';
import type { WorldDatabase } from '@phoenix/database';
import {
  simulateMatch,
  simulateMatchDetailed,
  type DetailedMatch,
} from '@phoenix/match-engine';
import { createRng } from '@phoenix/shared';
import { applyResult, clubStrength, hashSlug } from './league-table.js';

export type SimulateMatchdayInput = {
  world: WorldDatabase;
  fixtures: readonly Fixture[];
  matchday: number;
  seed: number;
  table: Map<Slug, TableRow>;
  highlightClubId?: Slug;
};

export type SimulateMatchdayOutput = {
  results: MatchResult[];
  table: Map<Slug, TableRow>;
  highlight?: DetailedMatch;
};

function fixtureInvolvesClub(fixture: Fixture, clubId: Slug): boolean {
  return fixture.homeClubId === clubId || fixture.awayClubId === clubId;
}

export function simulateMatchday(input: SimulateMatchdayInput): SimulateMatchdayOutput {
  const rootRng = createRng(input.seed);
  const dayFixtures = input.fixtures.filter((f) => f.matchday === input.matchday);
  const results: MatchResult[] = [];
  let highlight: DetailedMatch | undefined;

  for (const fixture of dayFixtures) {
    const matchRng = rootRng.fork(fixture.matchday * 1_000_003 + hashSlug(fixture.id));
    const matchInput = {
      homeClubId: fixture.homeClubId,
      awayClubId: fixture.awayClubId,
      homeStrength: clubStrength(input.world, fixture.homeClubId),
      awayStrength: clubStrength(input.world, fixture.awayClubId),
      rng: matchRng,
    };

    const shouldHighlight =
      input.highlightClubId !== undefined &&
      highlight === undefined &&
      fixtureInvolvesClub(fixture, input.highlightClubId);

    let result: MatchResult;
    if (shouldHighlight) {
      const detailed = simulateMatchDetailed(matchInput);
      highlight = detailed;
      result = detailed.result;
    } else {
      result = simulateMatch(matchInput);
    }

    results.push(result);
    applyResult(input.table, result);
  }

  return { results, table: input.table, highlight };
}
